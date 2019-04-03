#!/bin/bash
# Example usage:
#   ./tools/changelog.sh
#   ./tools/changelog.sh github/v2.1.0
#   ./tools/changelog.sh github/v2.1.0 github/v2.1.3
if [ "$#" -eq 0 ]; then
    # Use last tag and HEAD
    tag=$(git tag --sort=-creatordate | sed -ne 1p)
    git log --pretty=%s $tag..HEAD | sed 's/^/* /'
elif [ "$#" -eq 1 ]; then
    # Use included tag and HEAD
    git log --pretty=%s $1..HEAD | sed 's/^/* /'
elif [ "$#" -eq 2 ]; then
    # Use two parameterized tags
    git log --pretty=%s $1..$2 | sed 's/^/* /'
fi