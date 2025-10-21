package router

import (
	"fmt"
	"net/http"
	"slices"
)

type middlewareFunc func(next http.Handler) http.Handler

type Router struct {
	*http.ServeMux
	chain []middlewareFunc
}

func New() *Router {
	return &Router{
		ServeMux: http.NewServeMux(),
		chain:    []middlewareFunc{},
	}
}

func (r *Router) Use(middleware middlewareFunc) {
	r.chain = append(r.chain, middleware)
}

func (r *Router) handle(pattern string, handler http.Handler, middlewares []middlewareFunc) {
	middlewares = append(r.chain, middlewares...)

	for i := len(middlewares) - 1; i >= 0; i-- {
		handler = middlewares[i](handler)
	}
	r.ServeMux.Handle(pattern, handler)
}

func (r *Router) Group(fn func(r *Router)) {
	groupRouter := &Router{
		ServeMux: r.ServeMux,
		chain:    slices.Clone(r.chain),
	}
	fn(groupRouter)
}

func (r *Router) Get(pattern string, handler http.Handler, middlewares ...middlewareFunc) {
	r.handle(fmt.Sprintf("%s %s", http.MethodGet, pattern), handler, middlewares)
}

func (r *Router) Post(pattern string, handler http.Handler, middlewares ...middlewareFunc) {
	r.handle(fmt.Sprintf("%s %s", http.MethodPost, pattern), handler, middlewares)
}

func (r *Router) Put(pattern string, handler http.Handler, middlewares ...middlewareFunc) {
	r.handle(fmt.Sprintf("%s %s", http.MethodPut, pattern), handler, middlewares)
}

func (r *Router) Patch(pattern string, handler http.Handler, middlewares ...middlewareFunc) {
	r.handle(fmt.Sprintf("%s %s", http.MethodPatch, pattern), handler, middlewares)
}

func (r *Router) Delete(pattern string, handler http.Handler, middlewares ...middlewareFunc) {
	r.handle(fmt.Sprintf("%s %s", http.MethodDelete, pattern), handler, middlewares)
}

func (r *Router) Head(pattern string, handler http.Handler, middlewares ...middlewareFunc) {
	r.handle(fmt.Sprintf("%s %s", http.MethodHead, pattern), handler, middlewares)
}

func (r *Router) Options(pattern string, handler http.Handler, middlewares ...middlewareFunc) {
	r.handle(fmt.Sprintf("%s %s", http.MethodOptions, pattern), handler, middlewares)
}
