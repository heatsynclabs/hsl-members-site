package apiutils

import "strings"

const (
	TrueString  = "true"
	FalseString = "false"
)

func ValidBoolFromString(s string) bool {
	s = strings.ToLower(s)
	return s == TrueString || s == FalseString
}

type BoolFilter int

const (
	BoolFilterUnassigned = iota
	BoolFilterTrue
	BoolFilterFalse
)

func BoolFilterFromString(s string) BoolFilter {
	switch strings.ToLower(s) {
	case TrueString:
		return BoolFilterTrue
	case FalseString:
		return BoolFilterFalse
	default:
		return BoolFilterUnassigned
	}
}

type OrderDirection int

const (
	OrderDirUnassigned = iota
	OrderDirAscending
	OrderDirDescending
)

const (
	ValidOrderDirectionAsc  = "asc"
	ValidOrderDirectionDesc = "desc"
)

func (d OrderDirection) String() string {
	var order string
	switch d {
	case OrderDirAscending:
		order = "ASC"
	case OrderDirDescending:
		order = "DESC"
	default:
		order = "DESC"
	}
	return order
}

var (
	ValidOrderDirections = []string{
		ValidOrderDirectionAsc,
		ValidOrderDirectionDesc,
	}
)

func OrderDirectionFromString(direction string) OrderDirection {
	switch strings.ToLower(direction) {
	case ValidOrderDirectionAsc:
		return OrderDirAscending
	case ValidOrderDirectionDesc:
		return OrderDirDescending
	default:
		return OrderDirUnassigned
	}
}
