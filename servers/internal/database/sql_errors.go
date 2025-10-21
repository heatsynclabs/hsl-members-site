package database

import (
	"database/sql"
	"errors"
	"fmt"

	"github.com/lib/pq"
)

var (
	ErrRecordNotFound            = errors.New("record not found")
	ErrEditConflict              = errors.New("edit conflict")
	ErrForeignKeyViolation       = errors.New("foreign key violation")
	ErrVersionMismatch           = errors.New("version of entity does not match version in database")
	ErrResourceHasDependents     = errors.New("resource has dependents")
	ErrUniqueViolation           = errors.New("unique violation")
	ErrSerializationFailure      = errors.New("serialization failure")
	ErrNotNullViolation          = errors.New("not null violation")
	ErrCheckViolation            = errors.New("check constraint violation")
	ErrExclusionViolation        = errors.New("exclusion constraint violation")
	ErrDeadlockDetected          = errors.New("deadlock detected")
	ErrInvalidTextRepresentation = errors.New("invalid text representation")
	ErrNumericValueOutOfRange    = errors.New("numeric value out of range")
	ErrStringDataRightTruncation = errors.New("string data right truncation")
)

const (
	PsqlUniqueViolation           = "23505"
	PsqlForeignKeyViolation       = "23503"
	PsqlSerializationFailure      = "40001"
	PsqlCheckFailure              = "23514"
	PsqlNotNullViolation          = "23502"
	PsqlExclusionViolation        = "23P01"
	PsqlDeadlockDetected          = "40P01"
	PsqlInvalidTextRepresentation = "22P02"
	PsqlNumericValueOutOfRange    = "22003"
	PsqlStringDataRightTruncation = "22001"
)

func MapPostgresError(err error) error {
	if err == nil {
		return nil
	}

	if errors.Is(err, sql.ErrNoRows) {
		return ErrRecordNotFound
	}

	var (
		pqErr *pq.Error
		code  string
	)

	switch {
	case errors.As(err, &pqErr):
		code = string(pqErr.Code)
	default:
		return err
	}

	switch code {
	case PsqlUniqueViolation:
		return ErrUniqueViolation
	case PsqlForeignKeyViolation:
		return ErrForeignKeyViolation
	case PsqlSerializationFailure:
		return ErrSerializationFailure
	case PsqlNotNullViolation:
		return ErrNotNullViolation
	case PsqlCheckFailure:
		return ErrCheckViolation
	case PsqlExclusionViolation:
		return ErrExclusionViolation
	case PsqlDeadlockDetected:
		return ErrDeadlockDetected
	case PsqlInvalidTextRepresentation:
		return ErrInvalidTextRepresentation
	case PsqlNumericValueOutOfRange:
		return ErrNumericValueOutOfRange
	case PsqlStringDataRightTruncation:
		return ErrStringDataRightTruncation
	default:
		return err
	}
}

type ErrNilReturned string

func (e ErrNilReturned) Error() string {
	return fmt.Sprintf("%s was returned as nil", string(e))
}
