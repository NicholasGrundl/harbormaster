# Updated Harbormaster Repository Structure

```bash
harbormaster/
├── .github/                      # GitHub Actions workflows
│   └── workflows/
│       ├── deploy-prod.yml       # Production deployment workflow
│       └── validate.yml          # Infrastructure validation workflow
│
├── environments/                 # Environment-specific configurations
│   ├── local/                   # Local development environment
│   │   ├── .env.example         # Template for local environment variables
│   │   ├── docker-compose.yml   # Local development compose file
│   │   ├── nginx/               # Local nginx configuration
│   │   │   └── conf.d/          # Site configurations
│   │   │       └── default.conf # Default nginx config
│   │   └── keys/                # Development keys (gitignored)
│   │       ├── .gitkeep
│   │       └── README.md        # Instructions for development keys
│   │
│   └── production/              # Production environment
│       ├── .env.example         # Template for production environment variables
│       ├── docker-compose.yml   # Production compose file
│       ├── nginx/               # Production nginx configuration
│       │   └── conf.d/          # Mirror VPS structure
│       │       ├── default.conf # HTTP configuration
│       │       └── ssl.conf     # HTTPS configuration
│       └── setup/               # Production setup scripts
│           ├── init-vps.sh      # Initialize VPS directory structure
│           ├── setup-keys.sh    # Set up key directory structure
│           └── setup-ssl.sh     # Initial SSL certificate setup
│
├── scripts/                     # Development and utility scripts
│   ├── dev-setup.sh            # Set up local development environment
│   ├── generate-dev-keys.sh    # Generate development keys
│   └── deploy.sh               # Deploy to production VPS
│
├── .gitignore
├── README.md
└── makefile                    # Common commands for local development
```

## Configuration Examples

### 1. Local Environment Variables (.env.example)
```bash
# /environments/local/.env.example

# Docker Registry (local development typically uses local builds)
ARTIFACT_REGISTRY_HOST=localhost
IMAGE_TAG=dev

# Service Images (local development typically uses service names)
IMAGE_FRONTEND=waypoint
IMAGE_BACKEND=dockyard
IMAGE_AUTH=dockmaster
IMAGE_NGINX=nginx

# Development Ports
FRONTEND_PORT=3000
BACKEND_PORT=8000
AUTH_PORT=8001

# Key Paths (relative to docker-compose.yml)
DOCKMASTER_KEY_PATH=./keys/dockmaster.key
DOCKYARD_KEY_PATH=./keys/dockyard.key
GCP_KEY_PATH=./keys/gcp-dev-key.json

# Development Settings
NODE_ENV=development
DEBUG=true
```

### 2. Production Environment Variables (.env.example)
```bash
# /environments/production/.env.example

# Docker Registry
ARTIFACT_REGISTRY_HOST=gcr.io/your-project-id
IMAGE_TAG=stable

# Service Images
IMAGE_FRONTEND=waypoint
IMAGE_BACKEND=dockyard
IMAGE_AUTH=dockmaster
IMAGE_NGINX=nginx

# Production Paths (absolute paths matching VPS structure)
DOCKMASTER_KEY_PATH=/home/youruser/config/keys/dockmaster.key
DOCKYARD_KEY_PATH=/home/youruser/config/keys/dockyard.key
GCP_KEY_PATH=/home/youruser/config/keys/gcp-key.json

# Service User
UID=1000
GID=1000

# Domain Configuration
DOMAIN_NAME=yourdomain.com

# Production Settings
NODE_ENV=production
```

### 3. Local Docker Compose
```yaml
# /environments/local/docker-compose.yml
version: '3.8'

services:
  dockmaster:
    build:
      context: ../../../dockmaster  # Assumes sibling repository
      dockerfile: Dockerfile
    ports:
      - "${AUTH_PORT}:8001"
    volumes:
      - ${DOCKMASTER_KEY_PATH}:/app/keys/dockmaster.key:ro
    environment:
      - PRIVATE_KEY_PATH=/app/keys/dockmaster.key
      - NODE_ENV=${NODE_ENV}
      - DEBUG=${DEBUG}
    
  dockyard:
    build:
      context: ../../../dockyard   # Assumes sibling repository
      dockerfile: Dockerfile
    ports:
      - "${BACKEND_PORT}:8000"
    volumes:
      - ${DOCKYARD_KEY_PATH}:/app/keys/dockyard.key:ro
      - backend_data:/app/data
    environment:
      - PRIVATE_KEY_PATH=/app/keys/dockyard.key
      - NODE_ENV=${NODE_ENV}
      - DEBUG=${DEBUG}

  waypoint:
    build:
      context: ../../../waypoint   # Assumes sibling repository
      dockerfile: Dockerfile
    ports:
      - "${FRONTEND_PORT}:3000"
    environment:
      - NODE_ENV=${NODE_ENV}
      - DEBUG=${DEBUG}
    depends_on:
      - dockyard
      - dockmaster

  nginx:
    build:
      context: ../../nginx
      dockerfile: Dockerfile
    ports:
      - "80:80"
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
    depends_on:
      - dockyard
      - dockmaster
      - waypoint

volumes:
  backend_data:
```

### 4. Production Docker Compose
```yaml
# /environments/production/docker-compose.yml
version: '3.8'

services:
  dockmaster:
    image: ${ARTIFACT_REGISTRY_HOST}/${IMAGE_AUTH}:${IMAGE_TAG}
    user: "${UID}:${GID}"
    volumes:
      - ${DOCKMASTER_KEY_PATH}:/app/keys/dockmaster.key:ro
      - ${GCP_KEY_PATH}:/app/keys/gcp-key.json:ro
    environment:
      - PRIVATE_KEY_PATH=/app/keys/dockmaster.key
      - GOOGLE_APPLICATION_CREDENTIALS=/app/keys/gcp-key.json
      - NODE_ENV=${NODE_ENV}
    security_opt:
      - no-new-privileges:true

  dockyard:
    image: ${ARTIFACT_REGISTRY_HOST}/${IMAGE_BACKEND}:${IMAGE_TAG}
    user: "${UID}:${GID}"
    volumes:
      - ${DOCKYARD_KEY_PATH}:/app/keys/dockyard.key:ro
      - ${GCP_KEY_PATH}:/app/keys/gcp-key.json:ro
      - backend_data:/app/data
    environment:
      - PRIVATE_KEY_PATH=/app/keys/dockyard.key
      - GOOGLE_APPLICATION_CREDENTIALS=/app/keys/gcp-key.json
      - NODE_ENV=${NODE_ENV}
    security_opt:
      - no-new-privileges:true

  waypoint:
    image: ${ARTIFACT_REGISTRY_HOST}/${IMAGE_FRONTEND}:${IMAGE_TAG}
    user: "${UID}:${GID}"
    environment:
      - NODE_ENV=${NODE_ENV}
    security_opt:
      - no-new-privileges:true
    depends_on:
      - dockyard
      - dockmaster

  nginx:
    image: ${ARTIFACT_REGISTRY_HOST}/${IMAGE_NGINX}:${IMAGE_TAG}
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /etc/letsencrypt:/etc/letsencrypt:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
    security_opt:
      - no-new-privileges:true
    depends_on:
      - dockyard
      - dockmaster
      - waypoint

volumes:
  backend_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/youruser/data/volumes/backend_data
```

### 5. Development Setup Script
```bash
#!/bin/bash
# /scripts/dev-setup.sh
set -e

# Generate development keys if they don't exist
if [ ! -f "environments/local/keys/dockmaster.key" ]; then
  ./scripts/generate-dev-keys.sh
fi

# Copy environment file if it doesn't exist
if [ ! -f "environments/local/.env" ]; then
  cp environments/local/.env.example environments/local/.env
fi

echo "Development environment setup complete"
echo "You can now run: docker-compose -f environments/local/docker-compose.yml up"
```

### 6. VPS Initialization Script
```bash
#!/bin/bash
# /environments/production/setup/init-vps.sh
set -e

# Create directory structure
mkdir -p ~/app
mkdir -p ~/config/keys
mkdir -p ~/config/nginx/{conf.d,ssl}
mkdir -p ~/data/volumes/backend_data
mkdir -p ~/scripts

# Set directory permissions
chmod 755 ~/app
chmod 750 ~/config ~/data ~/scripts
chmod 700 ~/config/keys

# Copy configuration files
cp docker-compose.yml ~/app/
cp .env.example ~/app/.env
cp nginx/conf.d/* ~/config/nginx/conf.d/

# Set file permissions
chmod 600 ~/app/.env

echo "VPS directory structure initialized"
echo "Next steps:"
echo "1. Update ~/app/.env with your configuration"
echo "2. Run setup-keys.sh to configure service keys"
echo "3. Run setup-ssl.sh to configure SSL certificates"
```

### 7. Makefile for Common Tasks
```makefile
# /makefile

# Development
.PHONY: dev-setup
dev-setup:
	@./scripts/dev-setup.sh

.PHONY: dev
dev:
	@docker-compose -f environments/local/docker-compose.yml up

.PHONY: dev-build
dev-build:
	@docker-compose -f environments/local/docker-compose.yml build

# Deployment
.PHONY: deploy
deploy:
	@./scripts/deploy.sh

# Cleanup
.PHONY: clean
clean:
	@docker-compose -f environments/local/docker-compose.yml down -v
```

## Key Features

1. **Development Experience**
   - Easy setup with `make dev-setup`
   - Local development uses builds from sibling repositories
   - Development keys generated automatically
   - Environment variables clearly documented

2. **Production Deployment**
   - Matches VPS directory structure
   - Clear separation of configuration and data
   - Security-focused settings
   - Easy initialization scripts

3. **Configuration Management**
   - Environment-specific docker-compose files
   - Clear variable templates
   - Separate nginx configurations
   - Easy to maintain and update

4. **Security**
   - Keys properly isolated
   - Production security features enabled
   - Clear documentation of sensitive files
   - Proper permission management

The repository structure now clearly separates development and production concerns while maintaining simplicity and security. Would you like me to elaborate on any specific aspect?