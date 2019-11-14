#!/bin/bash
#
# Copyright 2018 Google LLC
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
# Example usage:
#   cat *.md | ./rules/path-exists.sh
#   cat *.md | ./rules/path-exists.sh --allow-redirects

# grep all filenames and URLs, then remove any ` characters
STDIN=`cat`
FILES=$(echo $STDIN |\
    grep -Po '[\s\b`](:?\.?\/?\w+)*[\w_-]+\.[a-z]\w+`?' |\
    cut -d "\`" -f 2)
URLS=$(echo $STDIN |\
    grep -Po 'https?:\/\/[\w./-]+' |\
    cut -d "\`" -f 2)
ALLOW_REDIRECTS=0

for var in "$@"
do
    if [ ${var} == "--allow-redirects" ]; then
        ALLOW_REDIRECTS=1
    fi
done

if [ ! -z "$FILES" ]; then
    while read -r line;
    do
        if [ ! -f ${line} ]; then
            # Check that this line is not a common name
            if [ ${line} == "node.js" ] || [ ${line} == "Node.js" ]; then
                continue
            fi
            # See if the file exists elsewhere
            FILE_PATH=$(find . -name "${line}" -type f)
            if [ -z "$FILE_PATH" ]; then
                # The file path is empty and URL is not okay
                echo "× ${line} not found!"
                exit 1
            fi
        fi
        echo "✓ ${line}"
        if [ ! -z "${FILE_PATH}" ]; then
            echo "    file found at ${FILE_PATH}"
            # Reset variable
            FILE_PATH=
        fi
    done <<< $FILES
fi

if [ ! -z "$URLS" ]; then
    while read -r line;
    do
        HTTP_STATUS=$(curl -s -o /dev/null -I -w "%{http_code}" ${line})
        if [ "${HTTP_STATUS}" == "301" ] && [ ! -z ${ALLOW_REDIRECTS} ]; then
            continue
        fi
        if [ "${HTTP_STATUS}" != "200" ]; then
            # The file path is empty and URL is not okay
            echo "× ${line} is invalid - returned status ${HTTP_STATUS}!"
            exit 1
        fi
        echo "✓ ${line}"
    done <<< $URLS
fi

echo "File references are all valid"