# /scripts/dev-prebuilt.sh
#!/bin/bash
set -e

# Ensure we're in the project root
cd "$(dirname "$0")/.."

# Create temporary .env file
cat > environments/local/.env << EOF
DEV_MOUNT_SOURCE=false
ARTIFACT_REGISTRY=${1:-localhost:5000}
IMAGE_TAG=${2:-latest}
NODE_ENV=development
DEBUG=true
EOF

# Start the services
docker compose -f environments/local/docker-compose.yml up