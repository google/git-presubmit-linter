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
# Tests the variety of potential commit_messages

commit_msg_present="Adds new field to protobuf and sample"
commit_msg_present_2="He adds new field to protobuf and sample"
commit_msg_present_3="Triple-checks exception"
commit_msg_past="Added new field to protobuf and sample"
commit_msg_past_2="She Added new field to protobuf and sample"
commit_msg_imperative="Add new field to protobuf and sample"
commit_msg_imperative_2="Update dependencies"
commit_msg_na="I have made some changes"

# Verify that present-tense checking passes with present-tense verb
echo "$commit_msg_present" | ./rules/verb-tense.sh present
if [ $? -ne 0 ]; then
    echo "Test failed"
    exit 1
fi

# Verify that present-tense checking passes with hyphenated word
echo "$commit_msg_present_3" | ./rules/verb-tense.sh present
if [ $? -ne 0 ]; then
    echo "Test failed"
    exit 1
fi

# Verify that present-tense checking fails with past-tense verb
echo "$commit_msg_past" | ./rules/verb-tense.sh present
if [ $? -eq 0 ]; then
    echo "Test failed"
    exit 1
fi

# Verify that present-tense checking fails if it doesn't start with verb
echo "$commit_msg_present_2" | ./rules/verb-tense.sh present
if [ $? -eq 0 ]; then
    echo "Test failed"
    exit 1
fi

# Verify that past-tense checking succeeds with past-tense verb
echo "$commit_msg_past" | ./rules/verb-tense.sh past
if [ $? -ne 0 ]; then
    echo "Test failed"
    exit 1
fi

# Verify that past-tense checking fails with present-tense verb
echo "$commit_msg_present" | ./rules/verb-tense.sh past
if [ $? -eq 0 ]; then
    echo "Test failed"
    exit 1
fi

# Verify that past-tense checking fails if it doesn't start with verb
echo "$commit_msg_past_2" | ./rules/verb-tense.sh past
if [ $? -eq 0 ]; then
    echo "Test failed"
    exit 1
fi

# Verify that imperative-tense checking succeeds with imperative-tense verb
echo "$commit_msg_imperative" | ./rules/verb-tense.sh imperative
if [ $? -ne 0 ]; then
    echo "Test failed"
    exit 1
fi

# Verify that imperative-tense checking succeeds with imperative-tense verb
echo "$commit_msg_imperative_2" | ./rules/verb-tense.sh imperative
if [ $? -ne 0 ]; then
    echo "Test failed"
    exit 1
fi

# Verify that imperative-tense checking fails with present-tense verb
echo "$commit_msg_present" | ./rules/verb-tense.sh imperative
if [ $? -eq 0 ]; then
    echo "Test failed"
    exit 1
fi

# Verify that imperative-tense checking fails with past-tense verb
echo "$commit_msg_past" | ./rules/verb-tense.sh imperative
if [ $? -eq 0 ]; then
    echo "Test failed"
    exit 1
fi

# Verify that imperative-tense checking fails with invalid phrase
echo "$commit_msg_na" | ./rules/verb-tense.sh imperative
if [ $? -eq 0 ]; then
    echo "Test failed"
    exit 1
fi

echo "All tests passed"