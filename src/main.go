package main

import (
	"fmt"
	"net/http"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

func home(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Success!")
	log.Info().Msg("Endpoint Hit: home")
}

func handleRequests() {
	http.HandleFunc("/", home)

	err := http.ListenAndServe(":8000", nil)
	if err != nil {
		log.Fatal().Err(err).Msg("Cannot start service.")
	}
}

func main() {
	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	log.Info().Msg("Starting up Go server.")
	handleRequests()
}
