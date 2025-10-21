package main

import (
	"context"
	"net/http"
	"os/signal"
	"syscall"

	"github.com/heatsynclabs/hsl-members-site/internal/apiutils"
	"github.com/heatsynclabs/hsl-members-site/internal/vcs"
)

func main() {
	println("Starting hello world server!")

	ctx, cancel := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer cancel()

	config := apiutils.NewApiConfig("hello", 8080)
	mux := http.NewServeMux()
	mux.Handle("GET /hello", helloHandler())
	err := apiutils.Serve(mux, config.Logger, config.Env, config.Port, vcs.Version(), ctx)
	if err != nil {
		panic(err)
	}
}

func helloHandler() http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Hello world!"))
		w.WriteHeader(http.StatusOK)
	})
}
