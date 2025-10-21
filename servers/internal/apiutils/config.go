package apiutils

import (
	"log/slog"
	"os"
	"sync"

	"github.com/heatsynclabs/hsl-members-site/internal/vcs"
)

type ApiConfig struct {
	Port    int
	Env     string
	Version string
	Wg      sync.WaitGroup
	Logger  *slog.Logger
}

type Option func(*ApiConfig)

func WithLoggerOptions(logger *slog.Logger) Option {
	return func(config *ApiConfig) {
		config.Logger = logger
	}
}

func NewApiConfig(env string, port int, opts ...Option) *ApiConfig {
	cfg := &ApiConfig{
		Port:    port,
		Env:     env,
		Logger:  slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{AddSource: true})),
		Version: vcs.Version(),
		Wg:      sync.WaitGroup{},
	}

	for _, opt := range opts {
		opt(cfg)
	}

	return cfg
}
