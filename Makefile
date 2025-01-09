.PHONY: clean

all: build

clean:
	cd cmd/sort && go clean

build:
	cd cmd/sort && go build

tests:
	./test/test_options.sh
	./test/test_diff_1.sh
	./test/test_diff_2.sh
	./test/test_diff_3.sh
	./test/test_long.sh
	./test/test_multiple.sh
	./test/test_reverse.sh

unit:
	go test -v ./...

bench: build
	cd internal/parse && go test -bench=.