package main

import "fmt"

var version = "dev" // overridden at build time via -ldflags

func main() {
	fmt.Printf("go-template version %s\n", version)
}
