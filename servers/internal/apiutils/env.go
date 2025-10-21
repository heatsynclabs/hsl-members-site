package apiutils

import (
	"os"
	"strconv"
	"time"
)

const (
	envKey = "ENV"
)

func CurrentEnv() string {
	return StringEnv(envKey, "dev")
}

func IntEnv(key string, defaultValue int) int {
	value := os.Getenv(key)

	if value == "" {
		return defaultValue
	}

	intValue, err := strconv.Atoi(value)
	if err != nil {
		return defaultValue
	}

	return intValue
}

func DurationEnv(key string, defaultValue time.Duration) time.Duration {
	value := os.Getenv(key)
	if value == "" {
		return defaultValue
	}

	duration, err := time.ParseDuration(value)
	if err != nil {
		return defaultValue
	}

	return duration
}

func StringEnv(key string, defaultValue string) string {
	value, ok := os.LookupEnv(key)
	if !ok {
		return defaultValue
	}

	return value
}

func BoolEnv(key string, defaultValue bool) bool {
	value := os.Getenv(key)
	if value == "" || (value != "true" && value != "false") {
		return defaultValue
	}

	return value == "true"
}
