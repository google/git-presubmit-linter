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
#   git log -1 --pretty=%B | ./line-length.sh 80

if [ "$#" -lt 1 ]; then
    echo "Expected usage: 'string' | ./line-length.sh <max>"
    echo "Looking for the maximum line length"
    exit 1
fi

while read line;
do
    echo $line
    if [ ${#line} -gt $1 ]; then
        echo "This line is too long, >$1 characters"
        exit 1
    fi
done

echo "Commit message length verified"