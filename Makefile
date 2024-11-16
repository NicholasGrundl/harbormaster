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
.PHONY: contxt
context: context.clean context.settings

.PHONY: context.settings
context.settings:
	repo2txt -r . -o ./context/context-settings.txt \
	--exclude-dir context old \
	--ignore-types \
	--ignore-files LICENSE README.md \
	&& python -c 'import sys; open("context/context-settings.md","wb").write(open("context/context-settings.txt","rb").read().replace(b"\0",b""))' \
	&& rm ./context/context-settings.txt

.PHONY: context.clean
context.clean:
	@if [ -f ./context/context-* ]; then rm ./context/context-*; fi
