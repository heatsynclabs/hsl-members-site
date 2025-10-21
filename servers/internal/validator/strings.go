package validator

import (
	"fmt"
	"regexp"
	"strings"
	"unicode"
)

var (
	RegexNoExtraSpaces = regexp.MustCompile(`^\S+(\s\S+)*$`)
)

func (v *Validator) FirstLetterUpper(s, key string) {
	if len(s) == 0 {
		v.Check(false, key, "must not be empty")
	}

	firstRune := []rune(s)[0]
	v.Check(unicode.IsUpper(firstRune), key, "must start with an uppercase letter")

	runes := []rune(s[1:])
	for _, r := range runes {
		v.Check(unicode.IsLower(r), key, "must only contain lowercase letters after first letter")
	}
}

func (v *Validator) AllFirstLetterUppercase(s, key string) {
	split := strings.Fields(s)
	for _, word := range split {
		v.FirstLetterUpper(word, key)
	}
}

func (v *Validator) AllLettersLowercase(s, key string) {
	for _, r := range s {
		if unicode.IsUpper(r) {
			v.Check(false, key, "must only contain lowercase letters")
		}
	}
}

func (v *Validator) OnlyOneWord(s, key string) {
	trimmed := strings.TrimSpace(s)
	v.Check(!strings.Contains(trimmed, " "), key, "must only contain one word")
}

func (v *Validator) NoTrailingSpaces(s, key string) {
	trimmed := strings.TrimSpace(s)
	v.Check(trimmed == s, key, "must not have trailing spaces")
}

func (v *Validator) NoExtraSpaces(s, key string) {
	v.Check(Matches(s, RegexNoExtraSpaces), key, "must not have extra spaces")
}

func (v *Validator) MaxLength(s, key string, length int) {
	v.Check(len(s) <= length, key, fmt.Sprintf("must be less than %d characters", length))
}

func (v *Validator) NotOnlySpaces(s, key string) {
	trimmed := strings.TrimSpace(s)
	v.Check(trimmed != "", key, "must not only contain spaces")
}

func (v *Validator) NoSpaces(s, key string) {
	v.Check(!strings.Contains(s, " "), key, "must not contain spaces")
	v.NoTrailingSpaces(s, key)
	v.NoExtraSpaces(s, key)
	v.NotOnlySpaces(s, key)
	v.OnlyOneWord(s, key)
}
