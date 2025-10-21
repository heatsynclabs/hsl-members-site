package testutils

import (
	"context"
	"time"

	"github.com/getsentry/sentry-go"
	"github.com/heatsynclabs/hsl-members-site/internal/middleware/sentrymw"
)

// AddDummySentryHub add a test-safe, no-op Sentry hub to a context for use in unit tests.
func AddDummySentryHub(ctx context.Context) context.Context {
	client, err := sentry.NewClient(sentry.ClientOptions{
		Dsn:       "https://examplePublicKey@o0.ingest.sentry.io/0",
		Transport: &noopTransport{},
	})
	if err != nil {
		panic("Error creating sentry client: " + err.Error())
	}

	hub := sentry.NewHub(client, sentry.NewScope())
	if hub == nil {
		panic("Error creating sentry hub")
	}

	return context.WithValue(ctx, sentrymw.SentryKey, hub)
}

type noopTransport struct{}

func (t *noopTransport) Configure(options sentry.ClientOptions) {}

func (t *noopTransport) SendEvent(event *sentry.Event) {}

func (t *noopTransport) Flush(timeout time.Duration) bool {
	return true
}

func (t *noopTransport) FlushWithContext(ctx context.Context) bool {
	return true
}

func (t *noopTransport) Close() {}
