#!/usr/bin/env sh
set -o errexit
set -o nounset
set -o pipefail

# FROM SORT DOCUMENTATION
#*** WARNING ***
#The locale specified by the environment affects sort order.
#Set LC_ALL=C to get the traditional sort order that uses
#native byte values.

FILE="cmd/sort/main.go Makefile README.md test/test_diff_1.sh" ./test/test.sh