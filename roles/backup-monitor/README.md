# backup-monitor

Weekly verification of the restic backups on the backup host (`vps06`), run by
`weekly.yml`.

## What a run checks

| Step | Catches |
| --- | --- |
| Snapshot freshness per repo | backups that stopped running |
| Legacy `<user>.<date>.tar` freshness | hosts still on classic Hestia backups |
| `restic check --read-data-subset=1%` | repository and sampled-data corruption |
| Restore drill (`tasks/restore-verify.yml`) | backups that exist but cannot be read back |

## The restore drill

Freshness and `restic check` never prove that the payload can be read back. The
drill reads real data out of the newest snapshot, for a bounded slice of repos
per run, rotating week by week (`weeks since epoch % slots`).

1. **Census** — `restic ls -l` must list files and protected bytes. A snapshot
   that silently stopped including anything is reported as `empty_snapshot`
   instead of passing as healthy.
2. **Payload** — the largest dump or archive within
   `backup_monitor_drill_max_file_bytes` (2 GiB by default) is streamed out with
   `restic dump` and validated: gzip integrity, tar listing, the dump's end
   marker (this catches a truncated `pg_dump`/`pg_dumpall`/`mysqldump`, whose
   trailer is always written last), or an exact stream length for other file
   types. Repos with no dump fall back to their largest regular file, so every
   repo still proves that bytes come back.
3. **Restore** — the same file is restored to
   `backup_monitor_drill_scratch_dir` and must be byte-identical to the streamed
   copy: same size, same sha256. This exercises the extraction path a real
   recovery uses, so a corruption on the way to disk cannot pass as success.

Any failure fails the playbook, and every run writes
`/var/log/backup-monitor/restore-drill-<date>.json` with the file, size and
sha256 of what was verified — so a missing day is itself evidence.

The monitor already runs on the *recovery* passphrases, so a passing drill also
proves that the escrowed recovery key opens the repositories.

## Cost

No extra host and no extra disk: two `restic ls` plus three reads and one write
of a single file per repo, on the host that already holds the repositories. Only
`backup_monitor_drill_repos_per_run` repos (2 by default) are drilled per run,
which keeps the weekly run short as the inventory grows. To drill every repo in
one go:

```bash
ansible-playbook weekly.yml -e backup_monitor_drill_repos_per_run=999
```

The scratch directory holds one file at a time and is removed by an EXIT trap,
and the free space is checked against the payload size before restoring, so a
drill can never fill the volume that holds the only copy.

## Choosing what gets drilled

By default the largest dump/archive in the snapshot is used. To pin a specific
file (for example the main application database), add an override to
`host_vars/<host>/main.yml`, or to a `group_vars/backup_monitor/` file if you
prefer to keep them in one place:

```yaml
backup_monitor_drill_files:
  vps11/restic-mysite: /data/coolify/backups/generated/mysite/auto-db.sql.gz
```

The key is the repository directory relative to `backup_monitor_base_path`, as
printed by the "Drill: show this week's selection" step.

## What it still does not prove

- **Survivability.** Every repository lives on `vps06` only. Losing that host,
  its provider account, or the `backuper` key that every source host root can
  reach loses the backups; re-running the jobs afterwards only starts a new
  history from the current state. A second, off-site copy is the missing piece.
- **That the dump loads.** The drill validates a dump's structure and trailer,
  not that `psql`/`mysql` can import it, and it does not boot an application.
  Worth doing by hand once per quarter for the repositories that matter.
- **Legacy tar backups.** They are plain files on the backup host rather than
  restic repositories, so they are only freshness-checked.

## Regression test

`scripts/.tmp-drill-test/` (git-ignored) contains a harness that runs the drill
shell body against a simulated `restic` covering the validators, the size cap,
overrides and both restore-integrity failures:

```bash
python3 scripts/.tmp-drill-test/harness.py
```
