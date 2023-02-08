package main

import (
	"bufio"
	"fmt"
	"os"
)

func fileExists(filename string) {
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

func scan(scanner *bufio.Scanner) []string {
	var lines []string
	for scanner.Scan() {
		line := scanner.Text()
		lines = append(lines, line)
	}
	return lines
}

func main() {
	arg := os.Args
	var lines []string
	var scanner *bufio.Scanner
	if len(arg) == 1 {
		scanner = bufio.NewScanner(os.Stdin)
		lines = append(lines, scan(scanner)...)

	} else if len(arg) > 1 {
		for i := 1; i < len(arg); i++ {
			fileExists(arg[i])
			readFile, err := os.Open(arg[i])
			if err != nil {
				fmt.Println(err)
				os.Exit(2)
			}
			defer readFile.Close()
			scanner = bufio.NewScanner(readFile)
			lines = append(lines, scan(scanner)...)
		}
	}

	fmt.Println("output:")
	for _, l := range lines {
		fmt.Println(l)
	}
}
