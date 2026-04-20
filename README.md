# server-config - my ansible playground :)

The entry point is `hourly.yml` which is supposed to be called ... hourly.
(Thank you Mr Obvious!)

## Collections

Install the required Ansible collections before running the playbooks:

- `ansible-galaxy collection install -r collections/requirements.yml`

## vps12 SMTP relay

`vps12.manitra.net` is also in the `smtp_relay` group. Relay accounts are defined in `group_vars/smtp_relay.yml` under `relay_users`; each user has its own vaulted password, allowed sender regex, and allowed client IP list.

Before applying `hourly.yml`, make sure every relay user password referenced from `group_vars/smtp_relay.yml` exists in `group_vars/all/vault.yml`, under `smtp_relay.users`. The role fails safely when a relay password is empty or missing.
