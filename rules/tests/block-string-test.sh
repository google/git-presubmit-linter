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

gitmessage1="diff --git a/README.md b/README.md
index 304484b..0401187 100644
--- a/README.md
+++ b/README.md
@@ -33,4 +33,9 @@ is no more than 80 characters. This command will pass.
 `./commit_message.sh "Adds new field to protobuf and sample" false 80`

 This will verify that the commit message above should be in past-tense and each
-line is no more than 80 characters. This command will fail.
\ No newline at end of file
+line is no more than 80 characters. This command will fail.
+
+## Git Diffs
+There are variety of changes that a contributor may make to a repo. To ensure
+that changes are consistent, this script can be used to verify a variety of
+potential changes.
\ No newline at end of file
"

gitmessage1_todo="diff --git a/README.md b/README.md
index 304484b..0401187 100644
--- a/README.md
+++ b/README.md
@@ -33,4 +33,9 @@ is no more than 80 characters. This command will pass.
 # (TODO @ Nick) Fix this typo
 `./commit_message.sh "Adds new field to protobuf and sample" false 80`

 This will verify that the commit message above should be in past-tense and each
-line is no more than 80 characters. This command will fail.
\ No newline at end of file
+line is no more than 80 characters. This command will fail.
+
+## Git Diffs
+todo remove this line later
+There are variety of changes that a contributor may make to a repo. To ensure
+that changes are consistent, this script can be used to verify a variety of
+potential changes.
\ No newline at end of file
"

# Verifies that the code does not have a TODO
echo "$gitmessage1" | ./rules/block-string.sh "TODO"
if [ $? -ne 0 ]; then
    echo "Test failed"
    exit 1
fi

# Verify that the commit has TODOs
echo "$gitmessage1_todo" | ./rules/block-string.sh "TODO"
if [ $? -eq 0 ]; then
    echo "Test failed"
    exit 1
fi

echo "All tests pass"