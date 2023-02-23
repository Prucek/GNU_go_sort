.PHONY: clean

all: build

clean:
	cd cmd/sort && go clean

build:
	cd cmd/sort && go build

tests: build
	./test/test_options.sh
	./test/test_diff_1.sh
	./test/test_diff_2.sh
	./test/test_diff_3.sh
	./test/test_long.sh
	./test/test_multiple.sh
	./test/test_reverse.sh
	cd internal/sort && go test
	cd cmd/sort && go clean