#!/bin/bash

rm archive-test.zip # Remove if needed
./tools/archive.sh archive-test.zip "tools/tests" "*"

zipinfo -1 archive-test.zip | grep "file1.txt"
if [ $? -eq 0 ]; then
    echo "Archive should not contain file1.txt"
    exit 1
fi

zipinfo -1 archive-test.zip | grep "file2.txt"
if [ $? -ne 0 ]; then
    echo "Archive is missing file2.txt"
    exit 1
fi

echo "All tests pass"