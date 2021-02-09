#!/bin/bash
istrue () {
  case $1 in
    "true"|"yes"|"y") return 0;;
    *) return 1;;
  esac
}

set -e

# Go to GitHub workspace.
if [ -n "$GITHUB_WORKSPACE" ]; then
  cd "$GITHUB_WORKSPACE" || exit
fi

# Set repository from GitHub, if not set.
if [ -z "$INPUT_REPO" ]; then INPUT_REPO="$GITHUB_REPOSITORY"; fi
# Set user input from repository, if not set.
if [ -z "$INPUT_USER" ]; then INPUT_USER=$(echo "$INPUT_REPO" | cut -d / -f 1 ); fi
# Set project input from repository, if not set.
if [ -z "$INPUT_PROJECT" ]; then INPUT_PROJECT=$(echo "$INPUT_REPO" | cut -d / -f 2- ); fi


# Only show last tag.
if istrue "$INPUT_ONLYLASTTAG"; then
  INPUT_DUETAG=""
  INPUT_SINCETAG=$(git describe --abbrev=0 --tags "$(git rev-list --tags --skip=1 --max-count=1)")
fi

# Build arguments.
if [ -n "$INPUT_USER" ]; then ARG_USER="--user $INPUT_USER"; fi
if [ -n "$INPUT_PROJECT" ]; then ARG_PROJECT="--project $INPUT_PROJECT"; fi
if [ -n "$INPUT_TOKEN" ]; then ARG_TOKEN="--token $INPUT_TOKEN"; fi


# Generate change log.
# shellcheck disable=SC2086 # We specifically want to allow word splitting.
github_changelog_generator \
  $ARG_USER \
  $ARG_PROJECT \
  $ARG_TOKEN

# Locate change log.
FILE="CHANGELOG.md"
if [ -n "$INPUT_OUTPUT" ]; then FILE="$INPUT_OUTPUT"; fi

# Save change log to outputs.
if [[ -e "$FILE" ]]; then
  CONTENT=$(cat "$FILE")
  # Escape as per https://github.community/t/set-output-truncates-multiline-strings/16852/3.
  CONTENT="${CONTENT//'%'/'%25'}"
  CONTENT="${CONTENT//$'\n'/'%0A'}"
  CONTENT="${CONTENT//$'\r'/'%0D'}"
  echo ::set-output name=changelog::"$CONTENT"
fi
