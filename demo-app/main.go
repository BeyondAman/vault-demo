package main

import (
	"fmt"
	"log"
	"os"
	"strings"
)

// Map to store environment variables
var environment map[string]string

func loadEnvFromFile(filePath string) error {
	environment = make(map[string]string)

	// Open the file
	file, err := os.Open(filePath)
	if (err != nil) {
		return err
	}
	defer file.Close()

	// Log that the file exists
	log.Printf("Configuration file %s exists.", filePath)

	// Read the file line by line
	fileInfo, err := file.Stat()
	if (err != nil) {
		return err
	}
	fileSize := fileInfo.Size()
	fileBytes := make([]byte, fileSize)
	_, err = file.Read(fileBytes)
	if (err != nil) {
		return err
	}

	lines := strings.Split(string(fileBytes), "\n")
	for _, line := range lines {
		parts := strings.SplitN(line, "=", 2)
		if len(parts) == 2 {
			environment[strings.TrimSpace(parts[0])] = strings.TrimSpace(parts[1])
			os.Setenv(strings.TrimSpace(parts[0]), strings.TrimSpace(parts[1]))
		}
	}

	// Log that the variables are loaded successfully
	log.Println("Variables loaded successfully.")
	return nil
}

func printCredentials() {
	log.Println("Printing the Secrets")

	// Access the environment variables directly
	username := os.Getenv("USERNAME")
	password := os.Getenv("PASSWORD")
	
	fmt.Printf("username: %s, password: %s\n", username, password)
	
	fmt.Println("Secret Printed Successfully.")
	fmt.Println("Shutting down the Server")

	os.Exit(0)
}

func main() {
	// Check if the file defined in SECRET_PATH exists
	secretPath := os.Getenv("SECRET_PATH")
	if _, err := os.Stat(secretPath); os.IsNotExist(err) {
		log.Fatalf("Configuration file %s does not exist. Exiting.", secretPath)
	}

	// Load environment variables from the file
	if err := loadEnvFromFile(secretPath); err != nil {
		log.Fatalf("Error loading environment variables from file: %s", err)
	}

	// print credentials in a separate goroutine
	printCredentials()
}