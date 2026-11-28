# Guidelines

Development guidelines for AI agents.

## Use it in a project

Commit this to the project as `.claude/settings.json`. If the file already exists,
add the `hooks` key to it.

```json
{
    "hooks": {
        "SessionStart": [
            {
                "hooks": [
                    {
                        "type": "command",
                        "command": "d=\"$HOME/.cache/maarheeze-guidelines\"; if [ -d \"$d/.git\" ]; then git -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=10 -C \"$d\" pull -q --ff-only; else git -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=10 clone -q --depth 1 https://github.com/maarheeze/guidelines.git \"$d\"; fi >/dev/null 2>&1; if [ -f \"$d/hooks/session-start.sh\" ]; then bash \"$d/hooks/session-start.sh\"; else echo 'The guidelines could not be downloaded. Tell the user before starting the task.'; fi",
                        "timeout": 30
                    }
                ]
            }
        ]
    }
}
```

Whoever checks out the project and trusts the folder gets the guidelines in every
session. The hook downloads this repository, or updates its copy in
`~/.cache/maarheeze-guidelines/`, so a change pushed here arrives at the next session
start. Without a connection, the last downloaded copy is used.

## Two delivery paths

Guidelines reach an agent in one of two ways, and which one a file uses is decided by
where it lives.

**`.ai/guidelines/always/` is inlined.** Everything in this directory is placed in the
agent's always-on context, before it has read a line of the task. It is for rules that
must hold whether or not the agent opened anything — how to work with the user, what it
may not do on your machine. Keep it ruthlessly small — everything here is paid for on
every task, whether or not it turns out to be relevant.

**Everything else is pulled through the index.** `.ai/guidelines/index.md` maps file
globs to guideline files. An agent opens the index, then opens only the files whose globs
match the path it is about to edit. A file that matches nothing in your project costs
that project nothing.

## Writing a guideline file

Add the file to the table in `index.md`, with the globs it applies to:

```markdown
| `**/*.php` | `php.md` |
```

The index is the only route to a file, so one that is missing from the table is never
delivered. The file itself says nothing about its own scope — the table is the single
place globs are written down.
