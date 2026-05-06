# Agent Behavior Guidelines

## Working with You

- Ask before doing large refactors or changes outside the scope of the request
- Do not modify files unrelated to the current task
- If unsure about intent, ask — don't assume
- When creating models or database structures, always ask for the required fields before generating any code
- Point out potential issues, but don't fix them unless asked
- If a situation arises that is not covered by these rules, or a pattern is noticed that could become a rule, propose it and ask before adding it
- Do not make any changes when a question is asked, wait for clear instructions before making any changes
- Never leave dead code — use it or remove it
- Don't over-engineer — solve what's asked, nothing more
- Start every response after completing an operation with "Done!" followed by a short description of what was done.
- If a question is asked where an answer is expected, only answer the question and do not start modifications without approval
- Never run destructive commands without explicit permission first — this includes migrates, deletions, force operations, etc.
- Be transparent about what a command does!

## Code Generation

- When generating new files, follow the conventions already present in the project
- When the same code is repeated in multiple places, extract it (constant/variable/method/class) and suggest this proactively
- Never use names like "$data" or "$item": use clear names that show intent 

## AI-Specific Constraints

- Never write memories — do not create or update any memory files, ever
- Never run local tooling — no php, phpstan, phpcs, composer, pest, artisan, or any other CLI tool on the user's machine
