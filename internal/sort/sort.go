package sort

import (
	"github.com/Prucek/GNU_go_sort/internal/parse"
	"sort"
	"strings"
)

func SortingAlgorithm(lines *[]string, arg *parse.Options) {
	sort.Slice(*lines, func(i, j int) bool {
		s1, s2 := (*lines)[i], (*lines)[j]
		result := strings.Compare(s1, s2)
		if arg.ReverseFlag {
			return result != -1
		}
		return result != 1
	})
}

// TODO sort when filling

//func BinarySearch(lines *[]string, line string) {
//	mid := (len(*lines) - 1) / 2
//	result := strings.Compare((*lines)[mid], line)
//	if result >= 0 {
//		BinarySearch(&(*lines)[mid:], line)
//	}
//}
