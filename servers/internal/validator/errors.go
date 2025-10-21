package validator

import (
	"errors"
	"fmt"
	"log/slog"
	"maps"
	"strings"
)

type ErrFailedValidation struct {
	Reasons map[string]string
}

func (e ErrFailedValidation) Error() string {
	return concatErrors(e.Reasons)
}

func concatErrors(errs map[string]string) string {
	b := strings.Builder{}
	b.WriteString("validation failed: ")
	for k, v := range errs {
		b.WriteString(fmt.Sprintf("%s: %s; ", k, v))
	}
	return b.String()
}

func NewErrFailedValidation(reasons map[string]string) ErrFailedValidation {
	return ErrFailedValidation{Reasons: reasons}
}

func (e ErrFailedValidation) LogErrors(l *slog.Logger, message string) {
	errs := concatErrors(e.Reasons)
	l.Error(message, "reasons", errs)
}

func (e ErrFailedValidation) Compare(other ErrFailedValidation) bool {
	if len(e.Reasons) != len(other.Reasons) {
		return false
	}
	if !maps.Equal(e.Reasons, other.Reasons) {
		return false
	}
	return true
}

func IsValidationError(err error) bool {
	var v ErrFailedValidation
	return errors.As(err, &v)
}
