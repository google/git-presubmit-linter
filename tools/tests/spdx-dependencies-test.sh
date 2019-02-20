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

if [ "$#" -lt 1 ]; then
    echo "Missing parameter: <libraries.io api key>"
    echo "To obtain licensing data, this script uses libraries.io"
    echo "An API key is required. Visit https://libraries.io/account"
    echo "to get one."
    exit 1
fi

# Test a valid list

DEPENDENCIES_NPM="
actions-on-google-testing\\n
typedoc-neo-theme"

echo -e $DEPENDENCIES_NPM | ./tools/spdx-dependencies.sh npm ./tools/tests/spdx-approved-licenses.txt $1
if [ $? -ne 0 ]; then
    echo "SPDX check did not pass as expected"
    exit 1
fi

# Test a list with invalid dependencies

DEPENDENCIES_NPM="
actions-on-google-testing-0\\n
typedoc-neo-theme"

echo -e $DEPENDENCIES_NPM | ./tools/spdx-dependencies.sh npm ./tools/tests/spdx-approved-licenses.txt $1
if [ $? -eq 0 ]; then
    echo "SPDX check did not fail as expected"
    exit 1
fi

# Test a list where a license is not approved

DEPENDENCIES_NPM="
actions-on-google-testing\\n
typedoc-neo-theme"

echo -e $DEPENDENCIES_NPM | ./tools/spdx-dependencies.sh npm ./tools/tests/spdx-approved-licenses-mit-only.txt $1
if [ $? -eq 0 ]; then
    echo "SPDX check did not fail as expected"
    exit 1
fi

DEPENDENCIES_PYPI="
google-assistant-sdk"

echo -e $DEPENDENCIES_PYPI | ./tools/spdx-dependencies.sh pypi ./tools/tests/spdx-approved-licenses.txt $1
if [ $? -ne 0 ]; then
    echo "SPDX check did not pass as expected"
    exit 1
fi

DEPENDENCIES_PYPI="
google-assistant-sdk-0\\n"

echo -e $DEPENDENCIES_PYPI | ./tools/spdx-dependencies.sh pypi ./tools/tests/spdx-approved-licenses.txt $1
if [ $? -eq 0 ]; then
    echo "SPDX check did not fail as expected"
    exit 1
fi

DEPENDENCIES_PYPI="
google-assistant-sdk"

echo -e $DEPENDENCIES_PYPI | ./tools/spdx-dependencies.sh pypi ./tools/tests/spdx-approved-licenses-mit-only.txt $1
if [ $? -eq 0 ]; then
    echo "SPDX check did not fail as expected"
    exit 1
fi


echo "All tests pass"