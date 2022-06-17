package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	_ "github.com/jackc/pgx/v4/stdlib"
)

type Test struct {
	db *sql.DB
}

func New(dburl string) (*Test, error) {
	db, err := sql.Open("pgx", dburl)
	if err != nil {
		return nil, err
	}

	return &Test{db}, nil
}

func (t *Test) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	var tim time.Time
	row := t.db.QueryRow("SELECT now() as time")
	if err := row.Scan(&tim); err != nil {
		log.Println(err)
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintln(w, err)
		return
	}
	fmt.Fprintf(w, "time from database is %v\n", tim.Format(time.RFC3339))
}

func main() {
	port, ok := os.LookupEnv("PORT")
	if !ok {
		port = "8080"
	}
	dburl, ok := os.LookupEnv("PG_DB_URL")
	if !ok {
		log.Fatal("PG_DB_URL environment variable not set")
	}

	test, err := New(dburl)
	if err != nil {
		log.Fatal(err)
	}

	if err := http.ListenAndServe(fmt.Sprintf("0.0.0.0:%v", port), test); err != nil {
		log.Fatal(err)
	}
}
