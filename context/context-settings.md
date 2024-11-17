
Repository Documentation
This document provides a comprehensive overview of the repository's structure and contents.
The first section, titled 'Directory/File Tree', displays the repository's hierarchy in a tree format.
In this section, directories and files are listed using tree branches to indicate their structure and relationships.
Following the tree representation, the 'File Content' section details the contents of each file in the repository.
Each file's content is introduced with a '[File Begins]' marker followed by the file's relative path,
and the content is displayed verbatim. The end of each file's content is marked with a '[File Ends]' marker.
This format ensures a clear and orderly presentation of both the structure and the detailed contents of the repository.

Directory/File Tree Begins -->

local/
├── README.md
├── docker-compose-mount.yml
├── docker-compose.yml
└── nginx.conf

<-- Directory/File Tree Ends

File Content Begin -->
[File Begins] README.md
# How to Run the local docker compose

## From preb uilt images in GAR


## From local builds (relative mount)

[File Ends] README.md

[File Begins] docker-compose-mount.yml
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
[File Ends] docker-compose-mount.yml

[File Begins] docker-compose.yml
# /environments/local/docker-compose.yml
version: '3.8'

services:
  dockmaster:
    image: ${AUTH_IMAGE}:${IMAGE_TAG:-latest}
    container_name: ${COMPOSE_PROJECT_NAME}-auth
    volumes:
      - ${DOCKMASTER_KEY_PATH}:/app/keys/dockmaster.key:ro
    env_file:
      - ${DOCKMASTER_ENVFILE_PATH}
    networks:
      - harbormaster
    ports:
      - "8001:8001"
    command: ["python", "-m", "uvicorn", "dockmaster.main:app", "--reload", "--host", "0.0.0.0", "--port", "8001"]


  dockyard:
    image: ${BACKEND_IMAGE}:${IMAGE_TAG:-latest}
    container_name: ${COMPOSE_PROJECT_NAME}-backend
    volumes:
      - ${DOCKYARD_KEY_PATH}:/app/keys/dockyard.key:ro
      - backend_data:/app/data
    networks:
      - harbormaster
    ports:
      - "8000:8000"
    command: ["python", "-m", "uvicorn", "dockyard.main:app", "--reload", "--host", "0.0.0.0", "--port", "8000"]
    depends_on:
      - dockmaster


  waypoint:
    image: ${FRONTEND_IMAGE}:${IMAGE_TAG:-latest}
    container_name: ${COMPOSE_PROJECT_NAME}-frontend
    environment:
      - NODE_ENV=${NODE_ENV:-development}
      - DEBUG=${DEBUG:-true}
    networks:
      - harbormaster
    ports:
      - "3000:3000"
    depends_on:
      - dockmaster
      - dockyard

  nginx:
    build:
      context: ../../nginx
    container_name: ${COMPOSE_PROJECT_NAME}-nginx
    ports:
      - "80:80"
    volumes:
      - ${NGINX_CONFIG_PATH:-./nginx.conf}:/etc/nginx/conf.d/environment/current.conf:ro
    networks:
      - harbormaster
    environment:
      - NGINX_DEBUG=1
    command: ["nginx-debug", "-g", "daemon off;"] 
    # command: ["nginx", "-c", "/etc/nginx/nginx.conf", "-g", "daemon off;"]
    depends_on:
      - dockmaster
      - dockyard
      - waypoint

networks:
  harbormaster:
    name: ${COMPOSE_PROJECT_NAME}-network

volumes:
  backend_data:
    name: ${COMPOSE_PROJECT_NAME}-backend-data
[File Ends] docker-compose.yml

[File Begins] nginx.conf
# /nginx/conf.d/environment/local.conf
server {
    listen 80;
    server_name localhost;

    # Frontend Routes
    location / {
        proxy_pass http://waypoint;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
    }

    # Backend API Routes
    location /api/ {
        proxy_pass http://dockyard;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Auth Service Routes
    location /auth/ {
        proxy_pass http://dockmaster;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Add these
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
    }
}
[File Ends] nginx.conf


<-- File Content Ends

Repository Documentation
This document provides a comprehensive overview of the repository's structure and contents.
The first section, titled 'Directory/File Tree', displays the repository's hierarchy in a tree format.
In this section, directories and files are listed using tree branches to indicate their structure and relationships.
Following the tree representation, the 'File Content' section details the contents of each file in the repository.
Each file's content is introduced with a '[File Begins]' marker followed by the file's relative path,
and the content is displayed verbatim. The end of each file's content is marked with a '[File Ends]' marker.
This format ensures a clear and orderly presentation of both the structure and the detailed contents of the repository.

Directory/File Tree Begins -->

production/
└── nginx.conf

<-- Directory/File Tree Ends

File Content Begin -->
[File Begins] nginx.conf
# /nginx/conf.d/environment/production.conf
# HTTP Server (Redirects & Health Checks)
server {
    listen 80;
    server_name ${DOMAIN};

    # Allow health checks over HTTP
    location /api/health {
        proxy_pass http://backend;
    }

    # Let's Encrypt challenge location
    location /.well-known/acme-challenge/ {
        root /var/www/_letsencrypt;
    }

    # Redirect everything else to HTTPS
    location / {
        return 301 https://$host$request_uri;
    }
}

# HTTPS Server
server {
    listen 443 ssl http2;
    server_name ${DOMAIN};

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;
    
    # SSL Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    
    # Frontend Routes
    location / {
        proxy_pass http://frontend;
    }

    # Backend API Routes
    location /api/ {
        proxy_pass http://backend;
        limit_req zone=api burst=10 nodelay;
    }

    # Auth Service Routes
    location /auth/ {
        proxy_pass http://auth;
        limit_req zone=auth burst=5 nodelay;
    }
}
[File Ends] nginx.conf


<-- File Content Ends

Repository Documentation
This document provides a comprehensive overview of the repository's structure and contents.
The first section, titled 'Directory/File Tree', displays the repository's hierarchy in a tree format.
In this section, directories and files are listed using tree branches to indicate their structure and relationships.
Following the tree representation, the 'File Content' section details the contents of each file in the repository.
Each file's content is introduced with a '[File Begins]' marker followed by the file's relative path,
and the content is displayed verbatim. The end of each file's content is marked with a '[File Ends]' marker.
This format ensures a clear and orderly presentation of both the structure and the detailed contents of the repository.

Directory/File Tree Begins -->

./
├── Makefile
├── TODO.md
├── nginx
│   ├── Dockerfile
│   ├── conf.d
│   │   └── default.conf
│   └── nginx.conf
└── scripts

<-- Directory/File Tree Ends

File Content Begin -->
[File Begins] Makefile
#### Environment Variables ####
# Allow override of env file path
ENV_FILE ?= environments/local/.env.development

# Load environment variables at the start
ifneq (,$(wildcard $(ENV_FILE)))
    include $(ENV_FILE)
    export $(shell sed 's/=.*//' $(ENV_FILE))
endif

# Add a required vars check
.PHONY: check.env
check.env:
	@if [ -z "$(ARTIFACT_REGISTRY_HOST)" ]; then \
		echo "Error: ARTIFACT_REGISTRY_HOST not set in $(ENV_FILE)"; \
		exit 1; \
	fi


#### Development ####
# Docker Compose
.PHONY: dev.compose
dev.compose: check.env
	docker compose -f environments/local/docker-compose.yml up --pull always

.PHONY: dev.compose.clean
dev.compose.clean: check.env
	docker compose -f environments/local/docker-compose.yml down -v

# .PHONY: dev-build
# dev-build:
# 	docker compose -f environments/local/docker-compose.yml up --build

# .PHONY: dev-down
# dev-down:
# 	docker compose -f environments/local/docker-compose.yml down

# .PHONY: dev-logs
# dev-logs:
# 	docker compose -f environments/local/docker-compose.yml logs -f

# # Run with prebuilt images
# .PHONY: dev-prebuilt
# dev-prebuilt:
# 	./scripts/dev-prebuilt.sh $(registry) $(tag)
# 	./scripts/dev-setup.sh



#### Context ####
.PHONY: context
context: context.clean context.settings

.PHONY: context.settings
context.settings:
	echo "" > ./context/context-settings.md
	repo2txt -r ./environments/local -o ./context/context-test.txt \
	--exclude-dir keys \
	&& python -c 'import sys; open("context/context-settings.md","ab").write(open("context/context-test.txt","rb").read().replace(b"\0",b""))' \
	&& rm ./context/context-test.txt
	repo2txt -r ./environments/production -o ./context/context-test.txt \
	--exclude-dir keys \
	&& python -c 'import sys; open("context/context-settings.md","ab").write(open("context/context-test.txt","rb").read().replace(b"\0",b""))' \
	&& rm ./context/context-test.txt
	repo2txt -r . -o ./context/context-test.txt \
	--exclude-dir context docs old environments \
	--ignore-files LICENSE README.md .env \
	&& python -c 'import sys; open("context/context-settings.md","ab").write(open("context/context-test.txt","rb").read().replace(b"\0",b""))' \
	&& rm ./context/context-test.txt

.PHONY: context.clean
context.clean:
	rm -f ./context/context-* || true

[File Ends] Makefile

[File Begins] TODO.md
# Reimplement

I want to reconfigure my app to be in separate repos to make development easier

This repo will be fore deployment and setting up the VPS

# 1. VPS Setup and scripts

Setting up and accessing a new VPS
- [ ] digital ocean droplet makefile
- [ ] docs with steps for setup
- [ ] where to keep secrets...?

# 2. Dockercompose

Docker compose files for dev and prod
- [ ] mount secrets as per the new `README.md`
- [ ] mount nginx configs (find a good way to do this)
- [ ] local/dev versus prod
- [ ] pull images from GAR

# 3. GCloud Registry setup

Setup and configure the google artifact registry 
- [ ] New registry setup
- [ ] credentials
- [ ] service worker setup

4. Deployment

Semi manual deployment to the VPS
- [ ] pulling images
- [ ] updating secrets files
- [ ] service accounts

5. Docs

Update docs with common routines
[File Ends] TODO.md

  [File Begins] nginx/Dockerfile
  # /nginx/Dockerfile
  FROM nginx:1.25-alpine
  
  # Install certbot for SSL certificate management
  RUN apk add --no-cache certbot certbot-nginx
  
  # Create required directories
  RUN mkdir -p /var/www/_letsencrypt \
      && mkdir -p /etc/nginx/conf.d/environment
  
  # Copy configurations
  COPY nginx.conf /etc/nginx/nginx.conf
  COPY conf.d/default.conf /etc/nginx/conf.d/default.conf
  # - Environment specific configuration volume mounted
  
  EXPOSE 80 443
  
  CMD ["nginx", "-g", "daemon off;"]
  [File Ends] nginx/Dockerfile

    [File Begins] nginx/conf.d/default.conf
    # Define upstream services
    upstream waypoint {
        server waypoint:3000;
    }
    
    upstream dockyard {
        server dockyard:8000;
    }
    
    upstream dockmaster {
        server dockmaster:8001;
    }
    
    # WebSocket support
    map $http_upgrade $connection_upgrade {
        default upgrade;
        ''      close;
    }
    
    # Common proxy settings
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;
    
    # Add debug logging
    error_log /var/log/nginx/error.log debug;
    
    # Rate limiting (used in production)
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=auth:10m rate=5r/s;
    [File Ends] nginx/conf.d/default.conf

  [File Begins] nginx/nginx.conf
  # Default nginx settings
  user nginx;
  worker_processes auto;
  error_log /var/log/nginx/error.log notice;
  pid /var/run/nginx.pid;
  
  events {
      worker_connections 1024;
  }
  
  http {
      include       /etc/nginx/mime.types;
      default_type  application/octet-stream;
  
      # Include all configurations
      include /etc/nginx/conf.d/*.conf;
  
      include /etc/nginx/conf.d/environment/*.conf;
  }
  [File Ends] nginx/nginx.conf


<-- File Content Ends

