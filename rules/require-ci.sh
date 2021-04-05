#!/bin/bash
#
# Copyright 2021 Google LLC
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
#   git diff HEAD~1 | ./mandate-conventional-changelog.sh
#   if [ $? -eq 0 ]; then
#       # No need to run CI as no change was flagged
#       exit 0
#   fi
#   # Run tests

# Define a series of types to determine the 'state' of the parser
TYPE_CODE=0
TYPE_COMMENT_START=1
TYPE_COMMENT_MIDDLE=2
TYPE_COMMENT_END=3
TYPE_COMMENT_SINGLE=4
TYPE_DIFF_HEAD=5
CURRENT_LINE_STATE=$TYPE_CODE

CURRENT_FILEEXT=""
CURRENT_RESULT=0

# array_contains "string to find" "${array[@]}"
array_contains () {
    local el match="$1"
    shift
    for e; do [[ "$e" == "$match" ]] && return 0; done
    return 1 # Not found
}

# categorize_source "$line" "$CURRENT_EXT"
categorize_source () {
    echo $line | grep -n "^diff --git" > /dev/null
    if [ $? -eq 0 ]; then
        return $TYPE_DIFF_HEAD
    fi
    if [ $CURRENT_LINE_STATE -eq $TYPE_CODE ] ||
        [ $CURRENT_LINE_STATE -eq $TYPE_COMMENT_SINGLE ] ||
        [ $CURRENT_LINE_STATE -eq $TYPE_COMMENT_END ]; then
        # Identify the current line
        echo $line | grep -n "^[+-]\s*${MAP_SINGLE_COMMENT[$CURRENT_FILEEXT]}\s*" > /dev/null
        if [ $? -eq 0 ]; then
            return $TYPE_COMMENT_SINGLE
        fi

        echo $line | grep -n "^[+-]\s*${MAP_START_COMMENT[$CURRENT_FILEEXT]}\s*" > /dev/null
        if [ $? -eq 0 ]; then
            return $TYPE_COMMENT_START
        fi

        return $TYPE_CODE
    fi
    if [ $CURRENT_LINE_STATE -eq $TYPE_COMMENT_START ] ||
        [ $CURRENT_LINE_STATE -eq $TYPE_COMMENT_MIDDLE ]; then
        # See if we are still in multiline comment
        echo $line | grep -n "^[+-]\s*${MAP_END_COMMENT[$CURRENT_FILEEXT]}\s*" > /dev/null
        if [ $? -eq 0 ]; then
            return $TYPE_COMMENT_END
        fi

        return $TYPE_COMMENT_MIDDLE
    fi
}

# report_ignore_source
report_ignore_source () {
    array_contains "$CURRENT_FILE" "${SCANNED_FILES[@]}"
    if [[ $? == 1 && $CURRENT_FILE != "" ]]; then
        array_contains "$CURRENT_FILEEXT" "${EXT_SRC[@]}"
        if [ $? -eq 0 ]; then
            # Provide a helpful note
            echo "  Ignore $CURRENT_FILE. No source changes detected."
        fi
    fi
}

# Source code files
EXT_SRC=(
    "go"
    "java"
    "js"
    "py"
    "ts"
    "sh"
)

# Regex to define a line that is a comment for a given file extension.
# Each entry in EXT_SRC should be defined here.
# Declare as an associate array.
declare -A MAP_SINGLE_COMMENT
MAP_SINGLE_COMMENT=(
    ["go"]="//"
    ["java"]="//"
    ["js"]="//"
    ["py"]="#"
    ["ts"]="//"
    ["sh"]="#"
)

# Define the start and end of multiline comments.
# The parser reads line-by-line and so needs to identify these tokens.
# If the language does not support multiline comments, use the same token as
# for single lines.
declare -A MAP_START_COMMENT
MAP_START_COMMENT=(
    ["go"]="/*"
    ["java"]="/*"
    ["js"]="/*"
    ["py"]='"""'
    ["ts"]="/*"
    ["sh"]="#"
)

declare -A MAP_END_COMMENT
MAP_END_COMMENT=(
    ["go"]="*/"
    ["java"]="*/"
    ["js"]="*/"
    ["py"]='"""'
    ["ts"]="*/"
    ["sh"]="#"
)

# Documentation or other files
EXT_IGNORE=(
    # Documentation files
    "doc"
    "html"
    "html"
    "md"
    "rtf"
    "txt"
    # Image files
    "bmp"
    "gif"
    "jpeg"
    "jpg"
    "png"
    # Metadata files
    "gitignore"
)

SCANNED_FILES=()

while read line;
do
    categorize_source $line $CURRENT_FILEEXT
    CURRENT_LINE_STATE=$?
    if [ $CURRENT_LINE_STATE -eq $TYPE_DIFF_HEAD ]; then
        # Optional report from previous file
        report_ignore_source
        # Extract the file name from this line
        CURRENT_FILE=$(echo $line | sed -r "s/^diff --git a\\/([a-zA-Z0-9/.\\-]*)\s.*/\1/")
        CURRENT_FILEEXT=$(echo $CURRENT_FILE | sed -r "s/[a-zA-Z0-9/.\\-]*[.]([a-zA-Z])/\1/")
        echo "Checking $CURRENT_FILE ($CURRENT_FILEEXT)"
        array_contains "$CURRENT_FILEEXT" "${EXT_IGNORE[@]}"
        if [ $? -eq 0 ]; then
            # This is a doc file.
            # We can say with certainty that CI does not need to run
            # and no further processing is necessary.
            # So we can reset the state and quickly churn through all
            # lines of the diff.
            echo "  Ignore .${CURRENT_FILEEXT} file"
        else
            array_contains "$CURRENT_FILEEXT" "${EXT_SRC[@]}"
            if [ $? -ne 0 ]; then
                # Else this is neither a source file nor doc file.
                # It is unclear how to process this, so we will have to assume it
                # has some CI implications and exit.
                echo "ERROR: Do not know how to handle file $CURRENT_FILE"
                CURRENT_RESULT=1
            fi
        fi
    else
        array_contains "$CURRENT_FILEEXT" "${EXT_SRC[@]}"
        if [ $? -eq 0 ]; then
            # This is a line from a source file.
            #
            # Match "+source code"
            # Match "-source code"
            # Do not match "--- /dev/null"
            # Do not match "+++ b/file"
            echo $line | grep -n "^[+-][^+-]" > /dev/null
            if [ $? -eq 0 ]; then
                # Check if this is a comment by use category
                if [ $CURRENT_LINE_STATE -eq $TYPE_CODE ]; then
                    array_contains "$CURRENT_FILE" "${SCANNED_FILES[@]}"
                    if [ $? -eq 1 ]; then
                        # Report error for this file once
                        echo "ERROR: Source code changed in $CURRENT_FILE: \`$line\`"
                        CURRENT_RESULT=1
                        # Add to list of scanned files to prevent duplicate error messages
                        SCANNED_FILES+=($CURRENT_FILE)
                    fi
                fi
            fi
        fi
    fi
done

report_ignore_source

exit $CURRENT_RESULT
