#!/usr/bin/env sh
set -o errexit
set -o nounset
set -o pipefail

# FROM SORT DOCUMENTATION
#*** WARNING ***
#The locale specified by the environment affects sort order.
#Set LC_ALL=C to get the traditional sort order that uses
#native byte values.

LC_ALL=C sort Makefile &> real.out
./cmd/sort/sort Makefile > test.out
./test/test.sh
