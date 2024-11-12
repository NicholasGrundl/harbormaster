# harbormaster
Devops for my website and flotilla

# Repo Setup

This repo pulls together a variety of services into a single webapp. We use this location for managing the configs and deployments.

## Folder Structure
```
infrastructure/
├── docker-compose.yml         # Production
├── docker-compose.dev.yml     # Development
├── nginx/
│   ├── conf.d/
│   └── nginx.conf
├── scripts/
│   ├── deploy.sh
│   └── setup-dev.sh
└── Makefile                  # Common commands

```

## example docker compose files

```
# docker-compose.dev.yml
version: '3.8'

services:
  dockmaster:
    build:
      context: ./dockmaster
      dockerfile: Dockerfile.dev
    volumes:
      - ./dockmaster:/app
      - ./dockmaster/tests:/app/tests  # Mount tests directory
    environment:
      - PYTHONPATH=/app
      - DEBUG=1
      - JWT_SECRET=devsecret123
      - POSTGRES_DB=dockmaster_dev
    ports:
      - "8000:8000"
    command: uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    volumes:
      - ./backend:/app
      - ./backend/tests:/app/tests
    environment:
      - PYTHONPATH=/app
      - DEBUG=1
      - AUTH_SERVICE_URL=http://dockmaster:8000
      - POSTGRES_DB=backend_dev
    ports:
      - "8001:8001"
    command: uvicorn app.main:app --reload --host 0.0.0.0 --port 8001

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    volumes:
      - ./frontend:/app
      - /app/node_modules
    environment:
      - REACT_APP_API_URL=http://localhost:8001
      - REACT_APP_AUTH_URL=http://localhost:8000
    ports:
      - "3000:3000"

---
# docker-compose.prod.yml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./nginx/ssl:/etc/nginx/ssl
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - dockmaster
      - backend
      - frontend

  dockmaster:
    build:
      context: ./dockmaster
      dockerfile: Dockerfile.prod
    environment:
      - JWT_SECRET=${JWT_SECRET}
      - ALLOWED_ORIGINS=${ALLOWED_ORIGINS}
      - POSTGRES_DB=dockmaster_prod
    expose:
      - 8000
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.prod
    environment:
      - AUTH_SERVICE_URL=http://dockmaster:8000
      - POSTGRES_DB=backend_prod
    expose:
      - 8001
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8001/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.prod
    expose:
      - 3000
```


# Deployment Details

## Secrets

We need a variety of secrets to get the microservice working.

- Each backend microservice has its own private key for JWT signing and service account authentication (forthcoming)
- Keys are stored on the VPS filesystem with strict permissions
- Docker services access keys through read-only volume mounts
- Follows principle of least privilege

### Directory Structure
```bash
/home/youruser/
├── docker-compose.yml
└── config/
    └── keys/
        ├── dockmaster.key    # Dockmaster service private key
        └── backend.key       # Backend service private key
```

### Security Checklist
- [x] Keys stored with 600 permissions (owner read/write only)
- [x] Keys directory with 700 permissions (owner access only)
- [x] Read-only volume mounts in Docker
- [x] Service-specific keys (no key sharing)
- [x] Specific file mounts (vs directory mounts)
- [x] Non-root container users
- [x] No-new-privileges security opt
- [x] Absolute paths in production
- [x] Clear documentation of setup process


### Initial Setup

1. Create key directory and set permissions:
```bash
# Create directory
mkdir -p ~/config/keys

# Set directory permissions
chmod 700 ~/config/keys

# Generate or copy your service keys
touch ~/config/keys/dockmaster.key ~/config/keys/backend.key

# Set key file permissions
chmod 600 ~/config/keys/*

# Verify permissions
ls -la ~/config/keys/
```

### Docker Compose example Configuration

```yaml
version: '3'
services:
  dockmaster:
    image: dockmaster:latest
    user: "1000:1000"  # Run as non-root user
    environment:
      - PRIVATE_KEY_PATH=/app/keys/dockmaster.key
    volumes:
      - ./config/keys/dockmaster.key:/app/keys/dockmaster.key:ro
    security_opt:
      - no-new-privileges:true

  dockyard:
    image: dockyard:latest
    user: "1000:1000"  # Run as non-root user
    environment:
      - PRIVATE_KEY_PATH=/app/keys/dockyard.key
    volumes:
      - ./config/keys/dockyard.key:/app/keys/dockyard.key:ro
    security_opt:
      - no-new-privileges:true
```