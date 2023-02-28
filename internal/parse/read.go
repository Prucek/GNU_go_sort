package parse

import (
	"bufio"
	"io"
)

type AppendFunction func(lines []string, line ...string) []string
type SortFunction func(lines []string)
type SortAlgorithm struct {
	FnAppend AppendFunction
	FnSort   SortFunction
}

func readLineByLine(scanner *bufio.Scanner, returnChannel chan<- []string, fnAppend AppendFunction) {
	var lines []string
	for scanner.Scan() {
		line := scanner.Text()
		lines = fnAppend(lines, line)
	}
	returnChannel <- lines
}

func ScanLines(files []io.Reader, algo SortAlgorithm) (lines []string, err error) {
	var scanner *bufio.Scanner
	// using 1 channel for each file
	channel := make(chan []string, len(files))
	for _, f := range files {
		scanner = bufio.NewScanner(f)
		go readLineByLine(scanner, channel, algo.FnAppend)
	}
	for i := 0; i < len(files); i++ {
		lines = algo.FnAppend(lines, <-channel...)
	}
	algo.FnSort(lines)
	close(channel)
	return
}
