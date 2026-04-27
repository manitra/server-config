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

The `coolify` role includes optional restic backup support that mirrors the pattern used for Hestia hosts.

### How it works

1. A wrapper script (`/usr/local/sbin/coolify-backup`) is deployed to the Coolify host.
2. At the scheduled time the script:
   - Runs `pg_dumpall` **inside** the `coolify-db` container → crash-consistent dump.
   - Backs up `/data/coolify` with `restic`, **excluding** the raw Postgres data
     directory (`/data/coolify/databases`), which is unsafe for live file snapshots.
   - Prunes old snapshots (daily/weekly/monthly retention).
   - Removes the local dump (it is already stored in restic).
3. The restic repository lives on `vps06` at
   `/home/backuper/backup/<host>/restic-coolify`, accessed over SFTP as `backuper`.

### Enabling backup for vps11

1. **On vps06** (one-time manual step):
   ```
   mkdir -p /home/backuper/backup/vps11
   # append root@vps11 public key to /home/backuper/.ssh/authorized_keys
   ```
2. **Create the vault file** `host_vars/vps11.manitra.net/vault.yml`
   (ansible-vault encrypted):
   ```yaml
   coolify_restic_password: "<strong random password>"
   coolify_restic_recovery_password: "<recovery key password>"
   ```
   Generate a password: `openssl rand -base64 32`
3. **Activate** in `host_vars/vps11.manitra.net/main.yml`:
   ```yaml
   coolify_restic_backup_enabled: true
   ```
4. Run `hourly.yml` (or target the coolify role).  On the first backup run the
   script will initialise the restic repository automatically.

### Adding another Coolify host

See the *How to onboard another Coolify host* section at the top of
`roles/coolify/tasks/backup.yml` for the full checklist.  The short version:
- Add the host to `[coolify]` in `inventory.ini`.
- Create its `host_vars/<host>/main.yml` with `coolify_restic_backup_enabled: true`
  and the correct `coolify_restic_repo` path.
- Create `host_vars/<host>/vault.yml` with `coolify_restic_password`.
- Provision the target directory on vps06 and register the host's root SSH key.

