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

commit_msg_multiline="Adds new field
to protobuf and sample"
commit_msg_multiline_nosecondline="Adds new field

to both the protobuf and sample"

# Verify that there is no text on the second line
echo "$commit_msg_multiline_nosecondline" | ./rules/no-second-line.sh
if [ $? -ne 0 ]; then
    echo "Test failed"
    exit 1
fi

# Verify that there is text on the second line
echo "$commit_msg_multiline" | ./rules/no-second-line.sh
if [ $? -eq 0 ]; then
    echo "Test failed"
    exit 1
fi

echo "All tests pass"