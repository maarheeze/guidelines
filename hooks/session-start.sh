#!/usr/bin/env bash
#
# Puts the guidelines in the session's context, in this order:
#
# 1. the guidelines in this repository
# 2. every layer passed as a name and a directory, each one on top of the last:
#    session-start.sh volbyte /path/to/.ai/guidelines
#
# Run by the session-start hook that projects commit in .claude/settings.json.

set -u

guidelines="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.ai/guidelines"

print_layer() {
    local name="$1"
    local layer="$2"

    for file in "${layer}"/always/*.md; do
        [ -f "${file}" ] || continue
        cat "${file}"
        printf '\n'
    done

    [ -f "${layer}/index.md" ] || return

    printf '# %s index\n\n' "${name}"
    printf 'The files in this index are in `%s/`.\n\n' "${layer}"
    cat "${layer}/index.md"
    printf '\n'
}

printf '# Guidelines\n\n'
printf 'Before editing a file, open the files whose globs match its path, from every\n'
printf 'index below. Each layer after the first is on top of the ones before it.\n\n'

print_layer "Base" "${guidelines}"

while [ "$#" -ge 2 ]; do
    print_layer "$1" "$2"
    shift 2
done
