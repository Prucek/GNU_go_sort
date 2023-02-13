package gnu_sort

import (
	"bufio"
	"fmt"
	"os"
	"sort"
	"strings"
)

var READ_STDIN = false // else reading from files

func isFile(filename string) {
	info, err := os.Stat(filename)
	if os.IsNotExist(err) {
		fmt.Printf("sort: cannot read: %s: No such file or directory\n", filename)
		os.Exit(2)
	}
	if info.IsDir() {
		fmt.Printf("sort: read failed: %s: Is a directory\n", filename)
		os.Exit(2)
	}
}

func readLineByLine(scanner *bufio.Scanner, returnChannel chan []string) {
	var lines []string
	for scanner.Scan() {
		line := scanner.Text()
		lines = append(lines, line)
	}
	returnChannel <- lines
}

func SortingAlgorithm(lines *[]string) {
	sort.Slice(*lines, func(i, j int) bool {
		s1, s2 := (*lines)[i], (*lines)[j]
		result := strings.Compare(s1, s2)
		return result != 1
	})
}

func argumentParsing() []string {
	arg := os.Args
	if len(arg) == 1 {
		READ_STDIN = true
	} else if len(arg) > 1 {
		READ_STDIN = false
	}
	return arg
}

func ScanLines() []string {
	var lines []string
	arg := argumentParsing()
	var scanner *bufio.Scanner
	// using 1 channel for each file
	channel := make(chan []string, len(arg)-1)
	if READ_STDIN {
		scanner = bufio.NewScanner(os.Stdin)
		go readLineByLine(scanner, channel)

	} else {
		for i := 1; i < len(arg); i++ {
			isFile(arg[i])
			readFile, err := os.Open(arg[i])
			if err != nil {
				fmt.Println(err)
				os.Exit(2)
			}
			scanner = bufio.NewScanner(readFile)
			defer readFile.Close()
			go readLineByLine(scanner, channel)
		}
	}
	for i := 0; i < len(arg)-1; i++ {
		lines = append(lines, <-channel...)
	}

	return lines
}
