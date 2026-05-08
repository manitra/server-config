# General rules

- Never delete, reset, or wipe user data.
- Never run destructive data commands such as `docker compose down -v`, `DROP TABLE`, `DELETE FROM`, or `docker volume rm` on persistent database volumes.
- Do not read or write files outside the workspace. For temporary files, use `scripts/.tmp*` and keep them ignored by Git.
- If you have to write secrets, make sure they are in files ignored by Git

## Coding rules

- Time and memory efficient
- Very concise but easy to read and understand by humans
- No duplicate
- Testable
- Extensible or composable when possible
- Secure
- English only
- Comments only on complex or unintuitive parts
- No files above 800 lines when reasonably avoidable

Respect the rules and refactor immediately when you spot violations.

