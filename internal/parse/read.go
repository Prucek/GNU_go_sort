package parse

import (
	"bufio"
	"github.com/Prucek/GNU_go_sort/internal/validate"
	"os"
)

var READ_STDIN = false // else reading from Files
type Append func(lines []string, line ...string) []string

func readLineByLine(scanner *bufio.Scanner, returnChannel chan<- []string, fn Append) {
	var lines []string
	for scanner.Scan() {
		line := scanner.Text()
		lines = fn(lines, line)
	}
	returnChannel <- lines
}

func ScanLines(arg *Options, fn Append) (lines []string, err error) {
	var scanner *bufio.Scanner
	// using 1 channel for each file
	var channel chan []string
	if READ_STDIN {
		channel = make(chan []string, 1)
		scanner = bufio.NewScanner(os.Stdin)
		go readLineByLine(scanner, channel, fn)

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
			go readLineByLine(scanner, channel, fn)
		}
	}
	for i := 0; i < len(arg.Files); i++ {
		lines = fn(lines, <-channel...)
	}
	// sort.SortingAlgorithm(&lines)
	close(channel)
	return
}
