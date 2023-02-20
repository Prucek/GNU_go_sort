package sort

import (
	"github.com/Prucek/GNU_go_sort/internal/parse"
	"reflect"
	"testing"
)

// performing more test in the test shell scripts

func TestSort(t *testing.T) {

	type sortTest struct {
		input, expected []string
	}

	var sortTests = []sortTest{
		{[]string{"aa", "a"}, []string{"a", "aa"}},
		{[]string{"  ", " "}, []string{" ", "  "}},
		{[]string{"7", "9"}, []string{"7", "9"}},
		{[]string{"a", "9"}, []string{"9", "a"}},
		{[]string{"a", "("}, []string{"(", "a"}},
		{[]string{")", "("}, []string{"(", ")"}},

		{[]string{"a", "(", "0"}, []string{"(", "0", "a"}},
	}

	for _, test := range sortTests {
		ops := parse.Options{}
		if SortingAlgorithm(&test.input, &ops); !reflect.DeepEqual(test.input, test.expected) {
			t.Errorf("Output %q not equal to expected %q", test.input, test.expected)
		}
	}

}
