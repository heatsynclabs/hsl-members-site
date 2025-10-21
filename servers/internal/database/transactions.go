package database

import (
	"context"
	"database/sql"
	"fmt"
)

// TxFn is the type of function that can be executed in a transaction
type TxFn func(*sql.Tx) error

type Transactional interface {
	WithTransaction(ctx context.Context, fns ...TxFn) (err error)
	WithTransactionReadOnly(ctx context.Context, fns ...TxFn) (err error)
}

// WithTransaction executes multiple TxFns in a single transaction
func (db *DB) WithTransaction(ctx context.Context, fns ...TxFn) (err error) {
	return db.transaction(ctx, nil, fns...)
}

func (db *DB) WithTransactionReadOnly(ctx context.Context, fns ...TxFn) (err error) {
	opts := &sql.TxOptions{ReadOnly: true}
	return db.transaction(ctx, opts, fns...)
}

func (db *DB) transaction(ctx context.Context, opts *sql.TxOptions, fns ...TxFn) (err error) {
	tx, err := db.BeginTx(ctx, opts)
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}

	defer func() {
		if p := recover(); p != nil {
			// A panic occurred, rollback and repanic
			tx.Rollback()
			panic(p)
		} else if err != nil {
			// Something went wrong, rollback
			rbErr := tx.Rollback()
			if rbErr != nil {
				err = fmt.Errorf("failed to rollback transaction: %w; original error: %w", rbErr, err)
			}
		} else {
			// All good, commit
			commitErr := tx.Commit()
			if commitErr != nil {
				// Commit failed, attempt to rollback
				rbErr := tx.Rollback()
				if rbErr != nil {
					err = fmt.Errorf("commit failed: %v, subsequent rollback failed: %v", commitErr, rbErr)
				} else {
					err = fmt.Errorf("commit failed, transaction rolled back: %w", commitErr)
				}
			}

		}
	}()

	for i, fn := range fns {
		if err = fn(tx); err != nil {
			return fmt.Errorf("operation %d failed: %w", i+1, err)
		}
	}

	return
}
