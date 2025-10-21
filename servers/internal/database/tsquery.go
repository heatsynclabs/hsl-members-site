package database

import (
	"net/url"
	"regexp"
	"strings"
)

type TsQuery string

const (
	EmptyTsQuery TsQuery = ""
)

func NewTsQueryUrlEscaped(text string) TsQuery {
	return TsQuery(url.QueryEscape(text))
}

// filterTsQueryOperators removes special operators and numbers used in distance operators
// from the TsQuery, returning a cleaned version of the query.
func (q TsQuery) filterTsQueryOperators() TsQuery {
	// Remove special operators for ts query functions
	re := regexp.MustCompile(`[&|!<>:*()]`)
	filtered := re.ReplaceAllString(string(q), "")

	// Remove numbers that might be used in distance operators
	re = regexp.MustCompile(`\s+\d+\s+`)
	filtered = re.ReplaceAllString(filtered, " ")

	return TsQuery(strings.TrimSpace(filtered))
}

// AddPrefixMatching modifies the TsQuery by appending a prefix matching operator
// to each word in the query, enabling prefix-based search.
func (q TsQuery) AddPrefixMatching() TsQuery {
	q = q.filterTsQueryOperators()

	words := strings.Fields(string(q))
	for i, word := range words {
		words[i] = word + ":*"
	}
	search := strings.Join(words, " & ")

	return TsQuery(search)
}
