#!/bin/sh
# Lint the BitBake metadata in this layer with oelint-adv.
#
# Install the linter first:  pip install oelint-adv
# Run from anywhere:          ./scripts/lint.sh
#
# Configuration lives in .oelint.cfg at the repo root.

set -eu

cd "$(dirname "$0")/.."

if ! command -v oelint-adv >/dev/null 2>&1; then
    echo "oelint-adv not found. Install it with: pip install oelint-adv" >&2
    exit 127
fi

# All BitBake metadata tracked in the layer.
FILES=$(git ls-files '*.bb' '*.bbappend' '*.bbclass' '*.inc' 'conf/*.conf')

if [ -z "$FILES" ]; then
    echo "No BitBake metadata found to lint."
    exit 0
fi

echo "Linting:"
echo "$FILES" | sed 's/^/  /'
echo

# oelint-adv exits non-zero when it reports any finding. --quiet drops the
# loaded-rules banner so only findings show. Options (release, rule
# suppressions, ...) come from .oelint.cfg at the repo root.
# $FILES is intentionally unquoted so each path becomes a separate argument;
# layer metadata paths contain no whitespace.
# shellcheck disable=SC2086
exec oelint-adv --quiet $FILES
