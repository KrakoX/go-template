package main

import "fmt"

var version = "dev" // overridden at build time via -ldflags

func main() {
	fmt.Printf("{{PROJECT_NAME}} version %s\n", version)
}
