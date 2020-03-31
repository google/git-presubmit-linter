#!/bin/bash
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Generates changelogs using Conventional Commits
#   and follows guidelines from Keep a Changelog
# See https://www.conventionalcommits.org/en/v1.0.0/
# See https://keepachangelog.com/en/1.0.0/
#
# Example usage:
#   ./tools/conventional-changelog.sh
#   ./tools/conventional-changelog.sh test
#   ./tools/conventional-changelog.sh github/v2.1.0
#   ./tools/conventional-changelog.sh github/v2.1.0 github/v2.1.3

PLACEHOLDER="2020-03-30|feat: Added something
2020-03-25|fix: Fix bugs
2020-03-25|fix(processor): Fix processing hangup
2020-03-20|build: Update dependencies
2020-03-15|chore: Convert array to object
2020-03-10|ci: Add lint test
2020-03-05|docs: Fix typo
2020-02-29|style: Switch from tabs to spaces
2020-02-24|refactor: Rename Adapter to Interface
2020-02-19|perf: Improve load times by 50%
2020-02-14|test: Add test for timeout
2020-02-09|vuln: Sanitize SQL entries
2020-01-31|fix!: The CPU no longer overheats when you hold down spacebar"

# Grab git logs in the format `<date>|<commit>`
if [ "$#" -eq 0 ]; then
    # Use last tag and HEAD
    TAG=$(git tag --sort=-creatordate | sed -ne 1p)
    COMMITS=$(git log --pretty="%ad|%s" --date=short $TAG..HEAD)
elif [ "$#" -eq 1 ]; then
    if [ "$1" == "test" ]; then
        # This is a test, use placeholder values
        TAG="github/v1.0.0"
        COMMITS=$PLACEHOLDER
    else
        # Use included tag and HEAD
        TAG=$1
        COMMITS=$(git log --pretty="%ad|%s" --date=short $1..HEAD)
    fi
elif [ "$#" -eq 2 ]; then
    # Use two parameterized tags
    TAG=$2
    COMMITS=$(git log --pretty="%ad|%s" --date=short $1..$2)
fi

IFS=$'\n'

# Create version subsections with scopes
declare -A added=()
declare -A changed=()
declare -A deprecated=()
declare -A fixed=()
declare -A security=()

# Parse each commit using Conventional Commit format
# Place it in a Keep A Changelog category
COMMIT_REGEX="^([[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2})\|([a-z]*\!?)(\(([a-z]*)\))?:\s(.*)$"

for commit in $COMMITS
do
    CATEGORY=$(echo $commit | sed -r "s/${COMMIT_REGEX}/\2/")
    SCOPE=$(echo $commit | sed -r "s/${COMMIT_REGEX}/\4/")
    COMMIT=$(echo $commit | sed -r "s/${COMMIT_REGEX}/\5/")

    if [ -z $SCOPE ]; then
        SCOPE="other" # Default
    fi

    echo $CATEGORY | grep '!' > /dev/null
    if [ $? -eq 0 ]; then
        deprecated[$SCOPE]+="* $COMMIT$IFS"
        break
    fi

    if [ $CATEGORY == 'feat' ]; then
        added["$SCOPE"]+="* $COMMIT$IFS"
    fi
    if [ $CATEGORY == 'fix' ]; then
        fixed["$SCOPE"]+="* $COMMIT$IFS"
    fi
    if [ $CATEGORY == 'vuln' ]; then
        security["$SCOPE"]+="* $COMMIT$IFS"
    fi
    if [ $CATEGORY == 'build' ] ||
       [ $CATEGORY == 'chore' ] ||
       [ $CATEGORY == 'ci' ] ||
       [ $CATEGORY == 'docs' ] ||
       [ $CATEGORY == 'style' ] ||
       [ $CATEGORY == 'refactor' ] ||
       [ $CATEGORY == 'perf' ] ||
       [ $CATEGORY == 'test' ]; then
        changed["$SCOPE"]+="* $COMMIT$IFS"
    fi
done

# Create changelog output
DATE=$(echo ${COMMITS[0]} | sed -r "s/${COMMIT_REGEX}/\1/")
# github/v2.12.0 -> v2.12.0
echo "# $(echo $TAG | sed 's/github\///') - $DATE"
# Create subsections for each category of commit
# Create optional subsubsections for each scoped change

# Deprecated
if [ ${#deprecated[@]} -ne 0 ]; then
echo "## Deprecated"
for scope in ${!deprecated[@]}
do
    if [ ${#deprecated[@]} -gt 1 ]; then
        echo "### $scope"
    fi
    echo "${deprecated[$scope]}"
done
fi

# Added
if [ ${#added[@]} -ne 0 ]; then
echo "## Added"
for scope in ${!added[@]}
do
    if [ ${#added[@]} -gt 1 ]; then
        echo "### $scope"
    fi
    echo "${added[$scope]}"
done
fi

# Changed
if [ ${#changed[@]} -ne 0 ]; then
echo "## Changed"
for scope in ${!changed[@]}
do
    if [ ${#changed[@]} -gt 1 ]; then
        echo "### $scope"
    fi
    echo "${changed[$scope]}"
done
fi

# Fixed
if [ ${#fixed[@]} -ne 0 ]; then
echo "## Fixed"
for scope in ${!fixed[@]}
do
    if [ ${#fixed[@]} -gt 1 ]; then
        echo "### $scope"
    fi
    echo "${fixed[$scope]}"
done
fi

# Security
if [ ${#security[@]} -ne 0 ]; then
echo "## Security"
for scope in ${!security[@]}
do
    if [ ${#security[@]} -gt 1 ]; then
        echo "### $scope"
    fi
    echo "${security[$scope]}"
done
fi
