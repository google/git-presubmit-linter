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
#   git log -1 --pretty=%B | ./has-pattern.sh "^[A-Z]*"

if [ "$#" -lt 1 ]; then
    echo "Expected usage: 'string' | ./has-pattern.sh <regex>"
    echo "Looking for the regex pattern to identify"
    exit 1
fi

grep -n "$1"
if [ $? -eq 0 ]; then
    exit 0
fi

echo "No pattern matching '$1' was found"
exit 1