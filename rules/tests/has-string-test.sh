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
commit_msg_present="Adds new field to protobuf and sample"
commit_msg_bug="Adds new field

Bug: #123"
gitdiff_names="README.md
git_diff.sh
tests/test_git_diff.sh"

gitdiff_names_noreadme="git_diff.sh
tests/test_git_diff.sh"

# Verify that the commit message has an inclucing bug
echo "$commit_msg_bug" | ./rules/has-pattern.sh "Bug:"
if [ $? -ne 0 ]; then
    echo "Test failed"
    exit 1
fi

# Verify that the commit message does not have an included bug
echo "$commit_msg_present" | ./rules/has-pattern.sh "Bug:"
if [ $? -eq 0 ]; then
    echo "Test failed"
    exit 1
fi

# Verifies that the commit changed any README file
echo "$gitdiff_names" | ./rules/has-pattern.sh "README"
if [ $? -ne 0 ]; then
    echo "Test failed"
    exit 1
fi

# Verify that the commit has not changed any README file
echo "$gitdiff_names_noreadme" | ./rules/has-pattern.sh "README"
if [ $? -eq 0 ]; then
    echo "Test failed"
    exit 1
fi

echo "All tests pass"