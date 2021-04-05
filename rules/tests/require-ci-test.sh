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

# Define test cases that can be skipped
DIFF_README_ONLY="diff --git a/README.md b/README.md
index 12e5fb6..413900b 100644
--- a/README.md
+++ b/README.md
@@ -19,6 +19,31 @@ set -e
-Hello earth
+Hello world
"

DIFF_README_COMMENT="diff --git a/README.md b/README.md
index 12e5fb6..413900b 100644
--- a/README.md
+++ b/README.md
@@ -19,6 +19,31 @@ set -e
-Hello earth
+Hello world
diff --git a/example.sh b/example.sh
index 12e5fb6..413900b 100644
--- a/example.sh
+++ b/example.sh
@@ -19,6 +19,31 @@ set -e
-# exit 1
+# exit 0
"

DIFF_README_MULTICOMMENT="diff --git a/README.md b/README.md
index 12e5fb6..413900b 100644
--- a/README.md
+++ b/README.md
@@ -19,6 +19,31 @@ set -e
-Hello earth
+Hello world
diff --git a/example.js b/example.js
index 12e5fb6..413900b 100644
--- a/example.js
+++ b/example.js
@@ -19,6 +19,31 @@ set -e
+ /*
+  * Multiline comment
+  */
"

# Define test cases that cannot be skipped
DIFF_README_CODE="diff --git a/README.md b/README.md
index 12e5fb6..413900b 100644
--- a/README.md
+++ b/README.md
@@ -19,6 +19,31 @@ set -e
-Hello earth
+Hello world
diff --git a/example.sh b/example.sh
index 12e5fb6..413900b 100644
--- a/example.sh
+++ b/example.sh
@@ -19,6 +19,31 @@ set -e
-exit 1
+exit 0
"

DIFF_UNKNOWNFILE="diff --git a/file.mystery b/file.mystery
index 12e5fb6..413900b 100644
--- a/file.mystery
+++ b/file.mystery
@@ -19,6 +19,31 @@ set -e
-Hello earth
+Hello world
"

# Split string by newline character
IFS='\n'

echo $DIFF_README_ONLY | ./rules/require-ci.sh
if [ $? -ne 0 ]; then
    echo "Test failed"
    exit 1
fi

echo $DIFF_README_COMMENT | ./rules/require-ci.sh
if [ $? -ne 0 ]; then
    echo "Test failed"
    exit 1
fi

echo $DIFF_README_MULTICOMMENT | ./rules/require-ci.sh
if [ $? -ne 0 ]; then
    echo "Test failed"
    exit 1
fi

echo $DIFF_README_CODE | ./rules/require-ci.sh
if [ $? -eq 0 ]; then
    echo "Test failed"
    exit 1
fi

echo $DIFF_UNKNOWNFILE | ./rules/require-ci.sh
if [ $? -eq 0 ]; then
    echo "Test failed"
    exit 1
fi

echo "All tests pass"
