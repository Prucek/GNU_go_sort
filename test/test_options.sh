#!/usr/bin/env sh
set -o nounset
set -o pipefail

#not a file
FILE=a ./test/test.sh
#directory
FILE=. ./test/test.sh
