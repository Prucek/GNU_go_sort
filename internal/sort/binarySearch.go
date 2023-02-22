package sort

import (
	"strings"
)

func binarySearch(lines []string, line string) int {
	low := 0
	high := len(lines) - 1

	for low <= high {
		mid := (low + high) / 2
		result := strings.Compare(lines[mid], line)

		if result >= 0 {
			high = mid - 1
		} else {
			low = mid + 1
		}
	}
	return low
}

func BinarySearchAppend(lines []string, line ...string) []string {
	for _, _line := range line {
		index := binarySearch(lines, _line)

		//resizable array
		lines = append(lines, "")
		copy(lines[index+1:], lines[index:])
		lines[index] = _line
	}
	return lines
}
