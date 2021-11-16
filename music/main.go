package main

import (
	"fmt"
	"net/http"
)

// handler 根处理器
func handler(w http.ResponseWriter, r *http.Request) {
	_, _ = fmt.Fprintf(w, "this is music server!")
}

func main() {
	http.HandleFunc("/", handler)
	_ = http.ListenAndServe(":80", nil)
}
