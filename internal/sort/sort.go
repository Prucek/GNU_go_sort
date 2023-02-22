package sort

import (
	"sort"
	"strings"
)

func SortingAlgorithm(lines *[]string) {
	sort.Slice(*lines, func(i, j int) bool {
		s1, s2 := (*lines)[i], (*lines)[j]
		result := strings.Compare(s1, s2)
		return result != 1
	})
}
