# server-config - my ansible playground :)

The entry point is `hourly.yml` which is supposed to be called ... hourly.
(Thank you Mr Obvious!)

## Collections

Install the required Ansible collections before running the playbooks:

- `ansible-galaxy collection install -r collections/requirements.yml`

## vps12 SMTP relay

`vps12.manitra.net` is also in the `smtp_relay` group. Before applying `hourly.yml`, set `vault_paositra_relay_password` in `group_vars/all/vault.yml` to the same SMTP secret configured on `prea`; the placeholder is intentionally empty so the relay role fails safely until the real secret is vaulted.
