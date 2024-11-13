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
│       ├── nginx.conf           # Local nginx configuration
│   │   └── keys/                # Development keys (gitignored)
│   │       ├── .gitkeep
│   │       └── README.md        # Instructions for development keys
│   │
│   └── production/              # Production environment
│       ├── .env.example         # Template for production environment variables
│       ├── docker-compose.yml   # Production compose file
│       ├── nginx.conf           # Production nginx configuration
│       └── setup/               # Production setup scripts
│           ├── init-vps.sh      # Initialize VPS directory structure
│           ├── setup-keys.sh    # Set up key directory structure
│           └── setup-ssl.sh     # Initial SSL certificate setup
│
├── nginx/                       # Nginx configuration templates and SSL setup
│   ├── Dockerfile               # Nginx container build
│   ├── conf.d/                  # Base nginx configuration templates
│   │   ├── default.conf         # Base configuration
│   │   └── ssl.conf             # SSL configuration template
│   └── scripts/                 # Utility scripts for nginx
│       └── ssl-renew.sh         # Let's Encrypt renewal script
│
├── scripts/                     # Development and utility scripts
│   ├── dev-setup.sh             # Set up local development environment
│   ├── generate-dev-keys.sh     # Generate development keys
│   ├── ssl-setup.sh             # Initial SSL certificate setup
│   └── deploy.sh                # Deploy to production VPS
│
├── .gitignore
├── README.md
└── Makefile                     # Common commands for local development
```


## Local Dockercompose

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
      - ../../nginx/conf.d:/etc/nginx/conf.d:ro
    depends_on:
      - dockyard
      - dockmaster
      - waypoint

volumes:
  backend_data:
```