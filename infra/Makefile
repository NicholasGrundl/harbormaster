# Envrionment Variables are set as follows:
# Use environment variables if set, 
# otherwise use values from .env.dev 
# otherwise use default values
-include .env.dev
# VPS connection
VPS_SSH_USER ?= $(or $(VPS_SSH_USER),defaultuser)
VPS_SSH_HOST ?= $(or $(VPS_SSH_HOST),127.0.0.1)

-include .env.config
# GAR image building
ARTIFACT_REGISTRY_HOST ?= $(or $(ARTIFACT_REGISTRY_HOST),us-west1-docker.pkg.dev/)
IMAGE_FRONTEND ?= $(or $(IMAGE_FRONTEND),frontend)
IMAGE_BACKEND ?= $(or $(IMAGE_BACKEND),backend)
IMAGE_NGINX ?= $(or $(IMAGE_NGINX),nginx)
IMAGE_TAG ?= $(or $(IMAGE_TAG),latest)



### Droplet Deployment targets ###
# Connect to droplet
.PHONY: droplet.connect
droplet.connect:
	@echo "Connecting to $(VPS_SSH_HOST) as $(VPS_SSH_USER)..."
	@ssh $(VPS_SSH_USER)@$(VPS_SSH_HOST)

.PHONY: droplet.deploy
droplet.deploy:
	@echo "Deploying to $(VPS_SSH_HOST) as $(VPS_SSH_USER)..."
	@echo "- Copying .env.config"
	@scp .env.config $(VPS_SSH_USER)@$(VPS_SSH_HOST):~/vps-config/
	@echo "- Copying docker-compose.yml"
	@scp docker-compose.yml $(VPS_SSH_USER)@$(VPS_SSH_HOST):~/vps-config/
	@echo "- Running deployment script"
	@ssh $(VPS_SSH_USER)@$(VPS_SSH_HOST) "~/vps-config/deploy_app.sh"


### Docker Images ###
.PHONY: docker.build
docker.build: docker.build.backend docker.build.frontend docker.build.nginx
	@echo "Build completed successfully"

.PHONY: docker.build.backend
docker.build.backend:
	@echo "Building backend image..."
	docker build -t $(IMAGE_BACKEND):$(IMAGE_TAG) ../backend
	docker tag $(IMAGE_BACKEND):$(IMAGE_TAG) $(ARTIFACT_REGISTRY_HOST)/$(IMAGE_BACKEND):$(IMAGE_TAG)

.PHONY: docker.build.frontend
docker.build.frontend:
	@echo "Building frontend image..."
	docker build -t $(IMAGE_FRONTEND):$(IMAGE_TAG) ../frontend
	docker tag $(IMAGE_FRONTEND):$(IMAGE_TAG) $(ARTIFACT_REGISTRY_HOST)/$(IMAGE_FRONTEND):$(IMAGE_TAG)

.PHONY: docker.build.nginx
docker.build.nginx:
	@echo "Building nginx image..."
	docker build -t $(IMAGE_NGINX):$(IMAGE_TAG) ../nginx
	docker tag $(IMAGE_NGINX):$(IMAGE_TAG) $(ARTIFACT_REGISTRY_HOST)/$(IMAGE_NGINX):$(IMAGE_TAG)

# --- Push Images ---
.PHONY: docker.push
docker.push: docker.push.backend docker.push.frontend docker.push.nginx
	@echo "Push completed successfully"

.PHONY: docker.push.backend
docker.push.backend:
	@echo "Pushing backend image to GAR..."
	@IMAGE_NAME=$(IMAGE_BACKEND) ../scripts/push_to_gcr.sh

.PHONY: docker.push.frontend
docker.push.frontend:
	@echo "Pushing frontend image to GAR..."
	@IMAGE_NAME=$(IMAGE_FRONTEND) ../scripts/push_to_gcr.sh

.PHONY: docker.push.nginx
docker.push.nginx:
	@echo "Pushing nginx image to GAR..."
	@IMAGE_NAME=$(IMAGE_NGINX) ../scripts/push_to_gcr.sh


### Local development
.PHONY: compose.clean 
compose.clean: 
	@echo "Cleaning up development docker-compose..." 
	docker compose down

.PHONY: compose.local 
compose.dev: 
	@echo "Running local docker-compose..." 
	docker compose -f docker-compose.local.yml up -d
	@echo "Dev environment is up and running"
	@echo "frontend: http://localhost:3000"
	@echo "backend: http://localhost:8000"
	@echo "nginx: http://localhost:80"


.PHONY: compose.dev 
compose.dev: 
	@echo "Running development docker-compose..." 
	docker compose -f docker-compose.dev.yml up -d
	@echo "Dev environment is up and running"
	@echo "frontend: http://localhost:3000"
	@echo "backend: http://localhost:8000"
	@echo "nginx: http://localhost:80"
