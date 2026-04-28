# server-config - my ansible playground :)

The entry point is `hourly.yml` which is supposed to be called ... hourly.
(Thank you Mr Obvious!)

## Collections

Install the required Ansible collections before running the playbooks:

- `ansible-galaxy collection install -r collections/requirements.yml`

## vps12 SMTP relay

`vps12.manitra.net` is also in the `smtp_relay` group. Relay accounts are defined in `group_vars/smtp_relay.yml` under `relay_users`; each user has its own vaulted password, allowed sender regex, and allowed client IP list.

Before applying `hourly.yml`, make sure every relay user password referenced from `group_vars/smtp_relay.yml` exists in `group_vars/all/vault.yml`, under `smtp_relay.users`. The role fails safely when a relay password is empty or missing.

## Coolify restic backup

The `coolify` role includes restic backup support for every host in the
`[coolify]` inventory group.

### How it works

1. A wrapper script (`/usr/local/sbin/coolify-backup`) is deployed to the Coolify host.
2. At the scheduled time the script:
   - Auto-discovers all running Postgres/MySQL/MariaDB containers and runs
     logical dumps **inside** them.
   - Auto-discovers mounted Docker host paths from running containers.
   - Backs up the resolved paths with `restic`, **excluding** raw DB data
     directories, which are unsafe for live file snapshots.
   - Prunes old snapshots (daily/weekly/monthly retention).
   - Removes the generated dumps after they are safely stored in restic.
3. The restic repositories live on `vps06` under
  `/home/backuper/backup/<host>/`, accessed over SFTP as `backuper`.
  - `restic-coolify` stores the Coolify platform data.
  - `restic-<public-domain>` stores each discovered Coolify application project.
4. The role now bootstraps the source host SSH key, trusts `vps06`, creates the
   destination directory on `vps06`, and authorizes the source host key there.
5. The `backuper` account on `vps06` is managed through the `maintain` role, so
   the backup destination is codified in the repo too.

### Why this is the safe default

- **Do not** rely on live file-level copies of running Postgres/MySQL volumes.
- Back up databases with **logical dumps** from inside their containers.
- Back up upload/document/application files and Docker volumes with `restic`.
- Auto-discovery means new Coolify apps are covered without editing host vars.
- Exclude extra paths only when you intentionally want to skip them.

### Shared Coolify backup configuration

- `group_vars/coolify/main.yml` enables backup by default for the whole group.
- `group_vars/coolify/main.yml` also defaults `coolify_domain` to the inventory
  hostname, so a new Coolify host answers on its own DNS name automatically.
- `group_vars/coolify/main.yml` enables automatic localhost SSH bootstrap for
  Coolify and keeps primary-user key management non-exclusive on those hosts so
  the generated Coolify key is not stripped by the `maintain` role.
- `group_vars/coolify/vault.yml` is now a **whole-file vault**, so
  `ansible-vault edit group_vars/coolify/vault.yml` works normally.
- `group_vars/coolify/vault.example.yml` shows the plaintext structure,
  including where `coolify_restic_recovery_password` is stored.
- The repository base path is derived automatically as:
  `sftp:backuper@vps06.manitra.net:/home/backuper/backup/<inventory-short-host>`
- Each backup run creates or updates one repo per project, for example
  `restic-coolify`, `restic-sign.mg`, or `restic-mission.eto.mg`.
- Recovery-key management is enabled for the whole group.

### Manual overrides when autodiscovery is not enough

You can still add manual exceptions in `host_vars/<host>/main.yml`:

```yaml
coolify_backup_database_dumps_extra:
  - name: app1-postgres
    type: postgres
    container_name_prefix: "app1-postgres-"
    user: postgres
    password_env: POSTGRES_PASSWORD
    output: "{{ coolify_backup_generated_dir }}/app1-postgres.sql.gz"

coolify_restic_excludes:
  - "{{ coolify_base_dir }}/databases"
  - /var/lib/docker/volumes/app1-cache/_data
```

### Adding another Coolify host

See the *How to onboard another Coolify host* section at the top of
`roles/coolify/tasks/backup.yml` for the full checklist. The short version:
- Add the host to `[coolify]` in `inventory.ini`.
- Run `hourly.yml`.
- Only add `host_vars/<host>/main.yml` if that host needs exceptions such as
  manual dump overrides, extra excludes, or a non-inventory Coolify domain.
