package main

import (
	"fmt"
	"os"

	"github.com/minio/pkg/licverifier"
)

func main() {
	if len(os.Args) != 3 {
		fmt.Println("USAGE: minio-license-verify <PUB-KEY-PATH> <LICENSE-KEY>")
		os.Exit(1)
	}
	pubKeyBytes, err := os.ReadFile(os.Args[1])
	if err != nil {
		fmt.Printf("Can't read file '%s', error: %v\n", os.Args[1], err)
		os.Exit(1)
	}
	lic, err := licverifier.NewLicenseVerifier(pubKeyBytes)
	if err != nil {
		fmt.Printf("Invalid public key, error: %v\n", err)
		os.Exit(1)
	}
	_, err = lic.Verify(os.Args[2])
	if err != nil {
		fmt.Printf("Invalid license key, error: %v\n", err)
		os.Exit(1)
	}
	os.Exit(0)
}
