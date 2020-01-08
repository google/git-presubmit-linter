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
# This script checks file contents against a list of regular expressions
# In a CI system, you may pass in a list of files from a tar archive.
#
# For some CI systems, you may need to specify a custom IFS
# (Internal Field Separator)
#
# Example usage:
#   tar -tf archive.tar.gz | ./tools/filelist.sh listoffiles.txt
#   tar -tf archive.tar.gz | ./tools/filelist.sh listoftiles.txt ' '

if [ "$#" -lt 1 ]; then
    echo "Expected usage: '<files>' | ./tools/filelist.sh listoffiles.txt"
    exit 1
fi
if [ "$#" -gt 1 ]; then
    # Set the IFS (Internal Field Separator)
    IFS=$2
fi

REJECTED_FILES=0
while read tarFile
do
    VALID=0
    while read pattern
    do
        echo "$tarFile" | grep -Po "^$pattern\$" > /dev/null
        if [ $? -eq 0 ]; then
            # Package file matches a valid pattern
            VALID=1
            break
        fi
    done <<< `cat $1`
    if [ $VALID -ne 1 ]; then
        echo "$tarFile does not match any pattern"
        REJECTED_FILES=$((REJECTED_FILES + 1))
    fi
done
if [ $REJECTED_FILES -gt 0 ]; then
    echo "Filelist check failed ($REJECTED_FILES item(s) invalid)"
    exit 1
fi