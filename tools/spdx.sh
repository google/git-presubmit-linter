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
#
# This script checks whether the input is a valid spdx identifier
#
# Example usage:
#   echo "MIT" | ./tools/spdx.sh
#   Exits with 0
#
#   echo "MITT" | ./tools/spdx.sh
#   Exits with 1
#
# List version 3.4 (2018-12-20)
# https://spdx.org/licenses/

read input
# Check contents against a list of identifiers
cat ./tools/spdx/license-ids.txt | grep -Po "^$input\$"