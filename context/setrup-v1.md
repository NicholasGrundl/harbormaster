# Harbormaster Infrastructure Repository Structure

```
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
│   │   ├── nginx.conf           # Local nginx configuration
│   │   └── keys/                # Development keys (gitignored)
│   │       ├── .gitkeep         # Ensures directory exists in git
│   │       └── README.md        # Instructions for development keys
│   │
│   └── production/              # Production environment
│       ├── .env.example         # Template for production environment variables
│       ├── docker-compose.yml   # Production compose file
│       ├── nginx.conf           # Production nginx configuration
│       └── setup/               # Production setup scripts and templates
│           ├── key-setup.sh     # Script to set up key directory structure
│           └── gcp-auth.sh      # Script to set up GCP service account
│
├── nginx/                       # Nginx configuration templates and SSL setup
│   ├── Dockerfile              # Nginx container build
│   ├── conf.d/                 # Base nginx configuration templates
│   │   ├── default.conf        # Base configuration
│   │   └── ssl.conf           # SSL configuration template
│   └── scripts/               # Utility scripts for nginx
│       └── ssl-renew.sh       # Let's Encrypt renewal script
│
├── scripts/                    # Utility scripts
│   ├── deploy.sh              # Production deployment script
│   ├── setup-local.sh         # Local development setup
│   ├── ssl-setup.sh          # Initial SSL certificate setup
│   └── generate-dev-keys.sh   # Generate development keys
│
├── terraform/                  # Infrastructure as Code (if needed)
│   ├── main.tf                # Main Terraform configuration
│   ├── variables.tf           # Terraform variables
│   └── outputs.tf             # Terraform outputs
│
├── .gitignore                 # Git ignore rules
├── README.md                  # Repository documentation
└── docker-compose.override.yml.example  # Template for local overrides
```

## Key Management Structure

### Development Environment
```bash
environments/local/keys/
├── dockmaster.key     # Development JWT signing key for dockmaster
├── dockyard.key       # Development JWT signing key for dockyard
└── gcp-dev-key.json   # Development GCP service account key (if needed)
```

### Production Environment (on VPS)
```bash
/home/youruser/
├── docker-compose.yml
└── config/
    ├── keys/
    │   ├── dockmaster.key    # Production JWT signing key
    │   ├── dockyard.key      # Production JWT signing key
    │   └── gcp-key.json      # GCP service account key
    └── nginx/
        └── ssl/              # SSL certificates
```

## Environment Variables

### Local Development (.env.example)
```env
# Service Images
IMAGE_FRONTEND=waypoint
IMAGE_BACKEND=dockyard
IMAGE_AUTH=dockmaster
IMAGE_NGINX=nginx

# Local Development
COMPOSE_PROJECT_NAME=harbormaster-dev
ARTIFACT_REGISTRY_HOST=localhost

# Key Paths (relative to docker-compose.yml location)
DOCKMASTER_KEY_PATH=./keys/dockmaster.key
DOCKYARD_KEY_PATH=./keys/dockyard.key
GCP_KEY_PATH=./keys/gcp-dev-key.json

# Ports
FRONTEND_PORT=3000
BACKEND_PORT=8000
AUTH_PORT=8001
```

### Production (.env.example)
```env
# GCP Artifact Registry
ARTIFACT_REGISTRY_HOST=gcr.io/your-project-id
IMAGE_TAG=stable

# Service Images
IMAGE_FRONTEND=waypoint
IMAGE_BACKEND=dockyard
IMAGE_AUTH=dockmaster
IMAGE_NGINX=nginx

# Key Paths (absolute paths)
DOCKMASTER_KEY_PATH=/home/youruser/config/keys/dockmaster.key
DOCKYARD_KEY_PATH=/home/youruser/config/keys/dockyard.key
GCP_KEY_PATH=/home/youruser/config/keys/gcp-key.json

# Domain Configuration
DOMAIN_NAME=your-domain.com

# Service Users (non-root)
SERVICE_USER=1000:1000
```

## Docker Compose Examples

### Development (environments/local/docker-compose.yml)
```yaml
version: '3.8'

services:
  dockmaster:
    image: ${ARTIFACT_REGISTRY_HOST}/${IMAGE_AUTH}:${IMAGE_TAG:-latest}
    ports:
      - "${AUTH_PORT}:8001"
    volumes:
      - ${DOCKMASTER_KEY_PATH}:/app/keys/dockmaster.key:ro
    environment:
      - PRIVATE_KEY_PATH=/app/keys/dockmaster.key
    
  dockyard:
    image: ${ARTIFACT_REGISTRY_HOST}/${IMAGE_BACKEND}:${IMAGE_TAG:-latest}
    ports:
      - "${BACKEND_PORT}:8000"
    volumes:
      - ${DOCKYARD_KEY_PATH}:/app/keys/dockyard.key:ro
      - backend_data:/app/data
    environment:
      - PRIVATE_KEY_PATH=/app/keys/dockyard.key

  waypoint:
    image: ${ARTIFACT_REGISTRY_HOST}/${IMAGE_FRONTEND}:${IMAGE_TAG:-latest}
    ports:
      - "${FRONTEND_PORT}:3000"
    depends_on:
      - dockyard
      - dockmaster

volumes:
  backend_data:
```

### Production (environments/production/docker-compose.yml)
```yaml
version: '3.8'

services:
  dockmaster:
    image: ${ARTIFACT_REGISTRY_HOST}/${IMAGE_AUTH}:${IMAGE_TAG:-latest}
    user: ${SERVICE_USER}
    volumes:
      - ${DOCKMASTER_KEY_PATH}:/app/keys/dockmaster.key:ro
      - ${GCP_KEY_PATH}:/app/keys/gcp-key.json:ro
    environment:
      - PRIVATE_KEY_PATH=/app/keys/dockmaster.key
      - GOOGLE_APPLICATION_CREDENTIALS=/app/keys/gcp-key.json
    security_opt:
      - no-new-privileges:true
    
  dockyard:
    image: ${ARTIFACT_REGISTRY_HOST}/${IMAGE_BACKEND}:${IMAGE_TAG:-latest}
    user: ${SERVICE_USER}
    volumes:
      - ${DOCKYARD_KEY_PATH}:/app/keys/dockyard.key:ro
      - ${GCP_KEY_PATH}:/app/keys/gcp-key.json:ro
      - backend_data:/app/data
    environment:
      - PRIVATE_KEY_PATH=/app/keys/dockyard.key
      - GOOGLE_APPLICATION_CREDENTIALS=/app/keys/gcp-key.json
    security_opt:
      - no-new-privileges:true

  waypoint:
    image: ${ARTIFACT_REGISTRY_HOST}/${IMAGE_FRONTEND}:${IMAGE_TAG:-latest}
    user: ${SERVICE_USER}
    depends_on:
      - dockyard
      - dockmaster
    security_opt:
      - no-new-privileges:true

  nginx:
    image: ${ARTIFACT_REGISTRY_HOST}/${IMAGE_NGINX}:${IMAGE_TAG:-latest}
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /etc/letsencrypt:/etc/letsencrypt:ro
    depends_on:
      - dockyard
      - dockmaster
      - waypoint
    security_opt:
      - no-new-privileges:true

volumes:
  backend_data:
```

## Setup Scripts

### generate-dev-keys.sh
```bash
#!/bin/bash
set -e

# Create development keys directory
mkdir -p environments/local/keys
chmod 700 environments/local/keys

# Generate development keys
openssl genpkey -algorithm RSA -out environments/local/keys/dockmaster.key
openssl genpkey -algorithm RSA -out environments/local/keys/dockyard.key

# Set correct permissions
chmod 600 environments/local/keys/*

echo "Development keys generated successfully"
```

### environments/production/setup/key-setup.sh
```bash
#!/bin/bash
set -e

# Create production key directory
mkdir -p ~/config/keys
chmod 700 ~/config/keys

# Create key files (to be filled with actual keys)
touch ~/config/keys/dockmaster.key
touch ~/config/keys/dockyard.key
touch ~/config/keys/gcp-key.json

# Set permissions
chmod 600 ~/config/keys/*

echo "Production key directory structure created"
echo "Please securely transfer your keys to the following locations:"
echo "  - ~/config/keys/dockmaster.key"
echo "  - ~/config/keys/dockyard.key"
echo "  - ~/config/keys/gcp-key.json"
```

## Development Workflow with Keys

1. Local Development Setup:
   ```bash
   # Generate development keys
   ./scripts/generate-dev-keys.sh
   
   # Copy environment file
   cp environments/local/.env.example environments/local/.env
   
   # Start development environment
   docker-compose -f environments/local/docker-compose.yml up
   ```

2. Production Deployment:
   ```bash
   # On VPS: Set up key directory structure
   ./environments/production/setup/key-setup.sh
   
   # Securely transfer production keys
   # Deploy using production compose file
   docker-compose -f environments/production/docker-compose.yml up -d
   ```

## Security Notes

1. Development keys are gitignored and should never be committed
2. Production keys should be transferred securely to the VPS
3. All key volumes are mounted read-only
4. Services run as non-root users
5. no-new-privileges security option is enabled
6. Absolute paths are used in production
7. GCP service account key is used for pulling images from artifact registry