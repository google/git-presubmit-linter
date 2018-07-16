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
#   git log -1 --pretty=%B | ./verb-tense.sh present

if [ "$#" -lt 1 ]; then
    echo "Expected usage: 'string' | ./verb-tense.sh <value>"
    echo "Values: "
    echo "  present - Add*s*"
    echo "  past - Add*ed*"
    echo "  imperative - Add"
    exit 1
fi

read msg # Read the first line of the message

if [ "$1" == "present" ]; then
    # Use present-tense only
    # "Adds"
    # "Removes"
    # "Checks"
    echo "Checking for present-tense in commit messages"
    echo $msg | grep '^[A-Z][a-z-]*s\s'
    if [ $? -ne 0 ]; then
        echo $msg
        echo "The first line of the commit message is not in the present tense"
        exit 1
    fi
elif [ "$1" == "past" ]; then
    # Use past-tense only
    # "Added"
    # "Removed"
    # "Checked"
    echo "Checking for past-tense in commit messages"
    echo $msg | grep '^[A-Z][a-z-]*ed\s'
    if [ $? -ne 0 ]; then
        echo $msg
        echo "The first line of the commit message is not in the past tense"
        exit 1
    fi
elif [ "$1" == "imperative" ]; then
    # Use the imperative form only
    # "Add"
    # "Remove"
    # "Check"
    echo "Checking for imperative-tense in commit messages"
    # This regular expression matches past or present. Check that grep does not match.
    echo $msg | grep -E '^[A-Z][a-z]*[es]d?\s'
    if [ $? -eq 0 ]; then
        echo $msg
        echo "The first line of the commit message is not in the imperative tense"
        exit 1
    fi
fi
echo "Commit message tense verified"