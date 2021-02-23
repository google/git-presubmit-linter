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
#   git log -1 --pretty=%B | ./mandate-conventional-changelog.sh
COMMIT_REGEX="^([a-z]*\!?)(\(([A-Za-z]*)\))?:\s(.*)$"

read msg # Read first line
echo "${msg}" | grep -Pn "${COMMIT_REGEX}" > /dev/null
if [ $? -eq 0 ]; then
    exit 0
fi

echo "Commit '${msg}' does not match conventional changelog format: https://www.conventionalcommits.org/en/v1.0.0/"
exit 1
