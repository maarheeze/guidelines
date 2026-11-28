#!/usr/bin/env bash
#
# Puts the guidelines in the session's context. Run by the session-start hook
# that projects commit in .claude/settings.json.

set -u

guidelines="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.ai/guidelines"

printf '# Guidelines\n\n'
printf 'Before editing a file, open the files from the index below whose globs match\n'
printf 'its path.\n\n'

for file in "${guidelines}"/always/*.md; do
    [ -f "${file}" ] || continue
    cat "${file}"
    printf '\n'
done

printf 'The files in the index below are in `%s/`.\n\n' "${guidelines}"
cat "${guidelines}/index.md"
