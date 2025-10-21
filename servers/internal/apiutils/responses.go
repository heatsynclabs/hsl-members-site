package apiutils

import (
	"fmt"

	"net/http"

	"github.com/heatsynclabs/hsl-members-site/internal/middleware/logger"
	"github.com/heatsynclabs/hsl-members-site/internal/middleware/requestid"
	"github.com/heatsynclabs/hsl-members-site/internal/middleware/sentrymw"
)

func logError(r *http.Request, err error) {
	var (
		method    = r.Method
		uri       = r.URL.RequestURI()
		requestId = r.Header.Get("X-Request-ID")
	)

	logg := logger.GetLoggerFromContext(r.Context())

	logg.Error(
		"server error",
		requestid.LogString, requestId,
		"error", err.Error(),
		"method", method,
		"uri", uri,
	)
}

func ErrorResponse(
	w http.ResponseWriter,
	r *http.Request,
	status int,
	message any,
) {
	env := Envelope{"error": message}

	err := WriteJson(w, status, env, nil)
	if err != nil {
		logError(r, err)
		w.WriteHeader(http.StatusInternalServerError)
	}
}

func ServerErrorResponse(w http.ResponseWriter, r *http.Request, err error) {
	logError(r, err)

	hub := sentrymw.GetHubFromContext(r.Context())
	hub.CaptureException(err)

	message := "the server encountered a problem and could not process your request"
	ErrorResponse(w, r, http.StatusInternalServerError, message)
}

func MethodNotAllowedResponse(w http.ResponseWriter, r *http.Request) {
	message := fmt.Sprintf("the %s method is not supported for this resource", r.Method)
	ErrorResponse(w, r, http.StatusMethodNotAllowed, message)
}

func NotFoundResponse(w http.ResponseWriter, r *http.Request) {
	message := "the requested resource could not be found"
	ErrorResponse(w, r, http.StatusNotFound, message)
}

func BadRequestResponse(w http.ResponseWriter, r *http.Request, err error) {
	ErrorResponse(w, r, http.StatusBadRequest, err.Error())
}

func FailedValidationResponse(w http.ResponseWriter, r *http.Request, errors map[string]string) {
	ErrorResponse(w, r, http.StatusUnprocessableEntity, errors)
}

func EditConflictResponse(w http.ResponseWriter, r *http.Request) {
	message := "unable to update record due to an edit conflict, please try again"
	ErrorResponse(w, r, http.StatusConflict, message)
}

func VersionConflictResponse(w http.ResponseWriter, r *http.Request) {
	message := "unable to update record due to a version conflict, please try again"
	ErrorResponse(w, r, http.StatusConflict, message)
}

func DependentResourcesResponse(w http.ResponseWriter, r *http.Request) {
	message := "the resource you're trying to delete has dependents"
	ErrorResponse(w, r, http.StatusConflict, message)
}

func UniqueViolationResponse(w http.ResponseWriter, r *http.Request, field string) {
	message := fmt.Sprintf("the resource you're trying to create already exists: %s", field)
	ErrorResponse(w, r, http.StatusConflict, message)
}

func ConstraintViolationResponse(w http.ResponseWriter, r *http.Request, field string) {
	message := fmt.Sprintf("the resource you're trying to create violates a constraint: %s", field)
	ErrorResponse(w, r, http.StatusConflict, message)
}

func ForbiddenResponse(w http.ResponseWriter, r *http.Request) {
	message := "you are not authorized to access this resource"
	ErrorResponse(w, r, http.StatusForbidden, message)
}

func TimeoutResponse(w http.ResponseWriter, r *http.Request) {
	message := "the request timed out"
	ErrorResponse(w, r, http.StatusRequestTimeout, message)
}
