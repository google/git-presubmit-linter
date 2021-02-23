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
commit_msg_fix="fix: lowercase works for non-Latin characters"
commit_msg_scope="fix(text): lowercase works for non-Latin characters"
commit_msg_breaking="fix!: removed lowercase"
commit_msg_fail="Fix lowercase for non-Latin characters"

# Verify a simple commit message passes
echo "$commit_msg_fix" | ./rules/mandate-conventional-commit.sh
if [ $? -ne 0 ]; then
    echo "Test failed"
    exit 1
fi

# Verify that a scoped commit message passes
echo "$commit_msg_fix" | ./rules/mandate-conventional-commit.sh
if [ $? -ne 0 ]; then
    echo "Test failed"
    exit 1
fi

# Verify a breaking commit passes
echo "$commit_msg_breaking" | ./rules/mandate-conventional-commit.sh
if [ $? -ne 0 ]; then
    echo "Test failed"
    exit 1
fi

# Verify that the commit not matching the format fails
echo "$commit_msg_fail" | ./rules/mandate-conventional-commit.sh
if [ $? -eq 0 ]; then
    echo "Test failed"
    exit 1
fi

echo "All tests pass"
