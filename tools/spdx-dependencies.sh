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
# This script checks project dependencies. Depending on the package
# manager, a different process will occur to obtain the license.
#
# Each license will be validated against an spdx identifier and a
# list provided by the developer listing the approved licenses that
# they can use.
#
# Example usage (npm):
#   cat package.json | jq .dependencies | grep -Po '".*":' | sed -e 's/[\":]//g' | ./tools/spdx-dependencies.sh npm approved-licenses.txt <libraries.io api key>
# Example usage (pypi):
#   cat requirements.txt | sed -r 's/([A-Za-z-]*).*/\1/g' | ./tools/spdx-dependencies.sh pypi approved-licenses.txt <libraries.io api key>

if [ "$#" -lt 2 ]; then
    echo "Expected usage: '<dependencies>' | ./tools/spdx-dependencies.sh <package-manager> approved-licenses.txt <libraries.io api key>"
    echo "  Supported package managers here: https://libraries.io/platforms"
    exit 1
fi

if [ "$#" -lt 3 ]; then
    echo "Missing parameter: <libraries.io api key>"
    echo "To obtain licensing data, this script uses libraries.io"
    echo "An API key is required. Visit https://libraries.io/account"
    echo "to get one."
    exit 2
fi

while read dependency
do
    # Escape any slashes in the dependency name
    dependency=`echo $dependency | sed -r 's/\//%2F/g'`
    API_RESPONSE=`curl -s "https://libraries.io/api/$1/$dependency?api_key=$3"`
    LICENSE=`echo $API_RESPONSE | sed -r 's/.*"normalized_licenses":\["([A-Za-z0-9.-]*)"].*/\1/g'`

    # Check if it has a valid spdx license
    echo $LICENSE | ./tools/spdx.sh > /dev/null
    if [ $? -ne 0 ]; then
        echo "$dependency does not have a valid license: $LICENSE"
        exit 3
    fi

    # Check if license matches approved licenses list
    cat $2 | grep $LICENSE > /dev/null
    if [ $? -ne 0 ]; then
        echo "$dependency does not have an approved license: $LICENSE"
        exit 4
    fi
done