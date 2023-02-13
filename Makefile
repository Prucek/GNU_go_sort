all:
	go build
	./main main.go

clean:
	rm -f main

tests:
	go build
	./test/test_options.sh
	./test/test_diff_1.sh
	./test/test_diff_2.sh
	./test/test_diff_3.sh
	./test/test_multiple.sh
	cd gnu_sort && go test
	rm main