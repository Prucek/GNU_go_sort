package gnu_sort

import (
	"bufio"
	"flag"
	"fmt"
	"os"
	"sort"
	"strings"
)

var READ_STDIN = false // else reading from files
var reverseFlag = false

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
		if reverseFlag {
			return result != -1
		}
		return result != 1
	})
}

func optionFlags() {
	flag.BoolVar(&reverseFlag, "reverse", false, "reverse the result of comparisons")
	flag.BoolVar(&reverseFlag, "r", false, "reverse the result of comparisons")
	flag.Parse()
}

func argumentParsing() []string {
	optionFlags()
	arg := flag.Args()

	if len(arg) == 0 {
		READ_STDIN = true
	} else if len(arg) > 0 {
		READ_STDIN = false
	}
	return arg
}

func ScanLines() []string {
	var lines []string
	files := argumentParsing()
	var scanner *bufio.Scanner
	// using 1 channel for each file
	var channel chan []string
	if READ_STDIN {
		channel = make(chan []string, 1)
		scanner = bufio.NewScanner(os.Stdin)
		go readLineByLine(scanner, channel)

	} else {
		channel = make(chan []string, len(files))
		for i := 0; i < len(files); i++ {
			isFile(files[i])
			readFile, err := os.Open(files[i])
			if err != nil {
				fmt.Println(err)
				os.Exit(2)
			}
			scanner = bufio.NewScanner(readFile)
			defer readFile.Close()
			go readLineByLine(scanner, channel)
		}
	}
	for i := 0; i < len(files); i++ {
		lines = append(lines, <-channel...)
	}

	return lines
}
