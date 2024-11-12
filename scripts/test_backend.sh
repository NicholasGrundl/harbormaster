#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to wait for a service to be ready
wait_for_service() {
    local host=$1
    local port=$2
    local service=$3
    
    echo "Waiting for $service to be ready..."
    while ! nc -z $host $port; do
        sleep 0.1
    done
    echo "$service is ready!"
}

# Ensure we're in the infra folder
cd "./infra"

# Start the services
docker-compose -f docker-compose.dev.yml up -d

# Wait for services to be ready
wait_for_service localhost 80 "Nginx"
wait_for_service localhost 8000 "Backend"

# Run tests
echo "Running API tests..."
curl -s http://localhost:80/ | grep -q "Hello"
curl -s http://localhost:80/api/testuser | grep -q "Hello testuser"

# Check logs
echo "Checking logs..."
docker-compose logs --tail=20

# Cleanup
echo "Cleaning up..."
docker-compose down

echo "All tests passed successfully!"