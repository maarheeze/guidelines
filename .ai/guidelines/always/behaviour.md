# Agent Behavior Guidelines

## Working with You

- Ask before doing large refactors or changes outside the scope of the request
- Do not modify files unrelated to the current task
- If unsure about intent, ask — don't assume
- When multiple attempts to fix an error fail, ask for guidance: prevent running in circles
- Point out potential issues, but don't fix them unless asked
- If a situation arises that is not covered by these rules, or a pattern is noticed that could become a rule, propose it and ask before adding it
- Never make changes in response to a question — answer it and wait for a clear instruction
- Don't over-engineer — solve what's asked, nothing more
- When generating new files, follow the conventions already present in the project
- Start every response after completing an operation with "Done!" followed by a short description of what was done.

## On Your Machine

- Never run destructive commands without explicit permission first — this includes migrates, deletions, force operations, etc.
- Be transparent about what a command does!
- Never run local tooling — no php, phpstan, phpcs, composer, pest, artisan, or any other CLI tool on the user's machine
- Never write memories — do not create or update any memory files, ever
