#!/bin/bash
#
# Copyright 2019 Google LLC
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

tar -tf ./tools/tests/listoffiles-pass.tar.gz | ./tools/filelist.sh ./tools/tests/listoffiles.txt
if [ $? -ne 0 ]; then
    echo "listoffiles-pass.tar.gz check did not pass as expected"
    exit 1
fi

tar -tf ./tools/tests/listoffiles-fail.tar.gz | ./tools/filelist.sh ./tools/tests/listoffiles.txt
if [ $? -eq 0 ]; then
    echo "listoffiles-fail.tar.gz check did not fail as expected"
    exit 1
fi

echo "All tests pass"