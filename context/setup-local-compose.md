# Local Development Environment Guide

## Table of Contents
1. [Directory Structure](#directory-structure)
2. [Configuration Files](#configuration-files)
3. [Environment Variables](#environment-variables)
4. [Usage Scenarios](#usage-scenarios)
5. [Scripts and Utilities](#scripts-and-utilities)

## Directory Structure
```bash
harbormaster/
├── environments/
│   └── local/
│       ├── .env.example          # Template for environment variables
│       ├── docker-compose.yml    # Local compose configuration
│       ├── nginx.conf           # Local nginx configuration
│       └── keys/                # Development keys (gitignored)
│           ├── .gitkeep
│           └── README.md
├── nginx/
│   ├── Dockerfile
│   └── conf.d/
│       ├── default.conf         # Base nginx configuration
│       └── environment/
│           └── local.conf       # Local-specific nginx config
├── scripts/
│   ├── dev-setup.sh            # Initial setup script
│   └── dev-prebuilt.sh         # Prebuilt images script
├── .gitignore
├── README.md
└── Makefile
```

## Configuration Files

### 1. Environment Variables
```bash
# /environments/local/.env.example

# Development Mode
DEV_MOUNT_SOURCE=true            # Controls source code mounting and build behavior
NODE_ENV=development             # Node.js environment
DEBUG=true                       # Enable debug logging

# Docker Registry Configuration
ARTIFACT_REGISTRY=localhost:5000 # Registry URL for prebuilt images
IMAGE_TAG=latest                 # Image version tag

# Service Images
FRONTEND_IMAGE=${ARTIFACT_REGISTRY}/waypoint    # Frontend service image
BACKEND_IMAGE=${ARTIFACT_REGISTRY}/dockyard     # Backend service image
AUTH_IMAGE=${ARTIFACT_REGISTRY}/dockmaster      # Auth service image

# Service Ports (external:internal)
FRONTEND_PORT=3000              # Frontend service port
BACKEND_PORT=8000               # Backend service port
AUTH_PORT=8001                  # Auth service port
NGINX_PORT=80                   # Nginx port

# Project Configuration
COMPOSE_PROJECT_NAME=harbormaster   # Prefix for container names

# Key Paths
KEYS_DIR=./keys
DOCKMASTER_KEY_PATH=${KEYS_DIR}/dockmaster.key
DOCKYARD_KEY_PATH=${KEYS_DIR}/dockyard.key
GCP_KEY_PATH=${KEYS_DIR}/gcp-dev-key.json

# Nginx Configuration
NGINX_CONFIG_PATH=./nginx.conf
```

### 2. Docker Compose Configuration
```yaml
# /environments/local/docker-compose.yml
version: '3.8'

services:
  dockmaster:
    image: ${AUTH_IMAGE}:${IMAGE_TAG:-latest}
    build:
      context: ${DEV_MOUNT_SOURCE:+../../../dockmaster}
      dockerfile: Dockerfile
      target: ${NODE_ENV:-development}
    container_name: ${COMPOSE_PROJECT_NAME}-auth
    volumes:
      - ${DOCKMASTER_KEY_PATH}:/app/keys/dockmaster.key:ro
      - ${DEV_MOUNT_SOURCE:+../../../dockmaster/src:/app/src}
    environment:
      - PRIVATE_KEY_PATH=/app/keys/dockmaster.key
      - NODE_ENV=${NODE_ENV:-development}
      - DEBUG=${DEBUG:-true}
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8001/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - harbormaster
    command: ["npm", "run", "dev"]

  dockyard:
    image: ${BACKEND_IMAGE}:${IMAGE_TAG:-latest}
    build:
      context: ${DEV_MOUNT_SOURCE:+../../../dockyard}
      dockerfile: Dockerfile
      target: ${NODE_ENV:-development}
    container_name: ${COMPOSE_PROJECT_NAME}-backend
    volumes:
      - ${DOCKYARD_KEY_PATH}:/app/keys/dockyard.key:ro
      - ${DEV_MOUNT_SOURCE:+../../../dockyard/src:/app/src}
      - backend_data:/app/data
    environment:
      - PRIVATE_KEY_PATH=/app/keys/dockyard.key
      - NODE_ENV=${NODE_ENV:-development}
      - DEBUG=${DEBUG:-true}
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - harbormaster
    command: ["npm", "run", "dev"]
    depends_on:
      dockmaster:
        condition: service_healthy

  waypoint:
    image: ${FRONTEND_IMAGE}:${IMAGE_TAG:-latest}
    build:
      context: ${DEV_MOUNT_SOURCE:+../../../waypoint}
      dockerfile: Dockerfile
      target: ${NODE_ENV:-development}
    container_name: ${COMPOSE_PROJECT_NAME}-frontend
    volumes:
      - ${DEV_MOUNT_SOURCE:+../../../waypoint/src:/app/src}
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - DEBUG=${DEBUG:-true}
      - BACKEND_URL=http://localhost/api
      - AUTH_URL=http://localhost/auth
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - harbormaster
    command: ["npm", "run", "dev"]
    depends_on:
      dockyard:
        condition: service_healthy

  nginx:
    image: nginx:1.25-alpine
    container_name: ${COMPOSE_PROJECT_NAME}-nginx
    ports:
      - "${NGINX_PORT:-80}:80"
    volumes:
      - ../../nginx/conf.d/default.conf:/etc/nginx/conf.d/default.conf:ro
      - ${NGINX_CONFIG_PATH:-./nginx.conf}:/etc/nginx/conf.d/environment/local.conf:ro
    healthcheck:
      test: ["CMD", "nginx", "-t"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - harbormaster
    depends_on:
      waypoint:
        condition: service_healthy
      dockyard:
        condition: service_healthy
      dockmaster:
        condition: service_healthy

networks:
  harbormaster:
    name: ${COMPOSE_PROJECT_NAME}-network

volumes:
  backend_data:
    name: ${COMPOSE_PROJECT_NAME}-backend-data
```

### 3. Nginx Configuration
```nginx
# /nginx/conf.d/default.conf
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    # Define upstream services
    upstream frontend {
        server waypoint:3000;
    }

    upstream backend {
        server dockyard:8000;
    }

    upstream auth {
        server dockmaster:8001;
    }

    # Common proxy headers
    map $http_upgrade $connection_upgrade {
        default upgrade;
        ''      close;
    }

    # Proxy configuration template
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;

    # Include environment-specific configurations
    include /etc/nginx/conf.d/environment/*.conf;
}

# /environments/local/nginx.conf
server {
    listen 80;
    server_name localhost;

    # Frontend Routes
    location / {
        proxy_pass http://frontend;
    }

    # Backend API Routes
    location /api/ {
        proxy_pass http://backend;
    }

    # Auth Service Routes
    location /auth/ {
        proxy_pass http://auth;
    }
}
```

### 4. Utility Scripts
```bash
# /scripts/dev-setup.sh
#!/bin/bash
set -e

# Generate development keys directory
mkdir -p environments/local/keys

# Copy example env if not exists
if [ ! -f environments/local/.env ]; then
  cp environments/local/.env.example environments/local/.env
  echo "Created .env file from example"
fi

# Generate development keys
if [ ! -f environments/local/keys/dockmaster.key ]; then
  openssl genpkey -algorithm RSA -out environments/local/keys/dockmaster.key
  echo "Generated dockmaster key"
fi

if [ ! -f environments/local/keys/dockyard.key ]; then
  openssl genpkey -algorithm RSA -out environments/local/keys/dockyard.key
  echo "Generated dockyard key"
fi

echo "Development environment setup complete!"

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
```

### 5. Makefile
```makefile
.PHONY: dev dev-build dev-down dev-logs dev-prebuilt setup-dev clean

# Development commands
dev:
	docker compose -f environments/local/docker-compose.yml up

dev-build:
	docker compose -f environments/local/docker-compose.yml up --build

dev-down:
	docker compose -f environments/local/docker-compose.yml down

dev-logs:
	docker compose -f environments/local/docker-compose.yml logs -f

# Run with prebuilt images
dev-prebuilt:
	./scripts/dev-prebuilt.sh $(registry) $(tag)

# Setup commands
setup-dev:
	./scripts/dev-setup.sh

clean:
	docker compose -f environments/local/docker-compose.yml down -v
```

## Environment Variables Explained

### Development Control
- `DEV_MOUNT_SOURCE`: Controls whether to mount source code and build locally
  - `true`: Uses local source code, enables live reload
  - `false`: Uses prebuilt images from registry

### Docker Registry
- `ARTIFACT_REGISTRY`: Registry URL for prebuilt images
- `IMAGE_TAG`: Version tag for images
  - Use `latest` for most recent version
  - Use specific tags (e.g., `v1.2.3`) for testing specific versions

### Service Configuration
- `NODE_ENV`: Controls Node.js environment
- `DEBUG`: Enables detailed logging
- `*_PORT`: External ports for accessing services
- `COMPOSE_PROJECT_NAME`: Prefix for container names and network

### Security
- `*_KEY_PATH`: Paths to service keys
- All mounted volumes are read-only where possible

## Usage Scenarios

### 1. Local Development (Source Code)
```bash
# .env configuration
DEV_MOUNT_SOURCE=true
IMAGE_TAG=dev

# Start services
make dev
```

### 2. Testing Prebuilt Images
```bash
# Using dev-prebuilt script
make dev-prebuilt registry=gcr.io/my-project tag=latest

# Or manually configure .env
DEV_MOUNT_SOURCE=false
ARTIFACT_REGISTRY=gcr.io/my-project
IMAGE_TAG=latest
make dev
```

### 3. Testing Specific Versions
```bash
make dev-prebuilt registry=gcr.io/my-project tag=v1.2.3
```

### 4. Initial Setup
```bash
# First-time setup
make setup-dev

# Start development environment
make dev
```

## Common Operations

### Starting Services
```bash
# With local source
make dev

# With prebuilt images
make dev-prebuilt

# Rebuild and start
make dev-build
```

### Monitoring
```bash
# View logs
make dev-logs

# Check container status
docker compose -f environments/local/docker-compose.yml ps
```

### Cleanup
```bash
# Stop services
make dev-down

# Full cleanup (including volumes)
make clean
```

## Health Checks and Dependencies

- Services start in order: Auth → Backend → Frontend → Nginx
- Each service has health checks configured
- Services wait for dependencies to be healthy before starting
- Nginx waits for all services to be healthy

## Security Notes

1. Keys are mounted read-only
2. Source code mounting is conditional
3. Network is isolated
4. Debug mode can be disabled in production-like testing

## Troubleshooting

1. Check logs: `make dev-logs`
2. Verify health checks: `docker ps`
3. Ensure correct environment variables
4. Check network connectivity: `docker network inspect harbormaster-network`