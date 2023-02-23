#!/usr/bin/env sh
set -o nounset
set -o pipefail

#not a file
LC_ALL=C  sort a &> real.out
./cmd/sort/sort a > test.out
./test/test.sh
#directory
LC_ALL=C  sort . &> real.out
./cmd/sort/sort . > test.out
./test/test.sh
