package parse

import (
	"bufio"
	"github.com/Prucek/GNU_go_sort/internal/validate"
	"os"
)

var READ_STDIN = false // modified in arguments.go
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

func ScanLines(arg *Options, algo SortAlgorithm) (lines []string, err error) {
	var scanner *bufio.Scanner
	// using 1 channel for each file
	var channel chan []string
	if READ_STDIN {
		channel = make(chan []string, 1)
		scanner = bufio.NewScanner(os.Stdin)
		go readLineByLine(scanner, channel, algo.FnAppend)

	} else {
		channel = make(chan []string, len(arg.Files))
		for i := 0; i < len(arg.Files); i++ {
			err = validate.IsFile(arg.Files[i])
			if err != nil {
				return
			}
			var readFile *os.File
			readFile, err = os.Open(arg.Files[i])
			if err != nil {
				return
			}
			scanner = bufio.NewScanner(readFile)
			defer readFile.Close()
			go readLineByLine(scanner, channel, algo.FnAppend)
		}
	}
	for i := 0; i < len(arg.Files); i++ {
		lines = algo.FnAppend(lines, <-channel...)
	}
	algo.FnSort(lines)
	close(channel)
	return
}
