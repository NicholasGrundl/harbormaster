#### Context ####
.PHONY: context
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


#### Docker Compose ####
# Development commands
.PHONY: dev
dev:
	docker compose -f environments/local/docker-compose.yml up

.PHONY: dev-build
dev-build:
	docker compose -f environments/local/docker-compose.yml up --build

.PHONY: dev-down
dev-down:
	docker compose -f environments/local/docker-compose.yml down

.PHONY: dev-logs
dev-logs:
	docker compose -f environments/local/docker-compose.yml logs -f

# Run with prebuilt images
.PHONY: dev-prebuilt
dev-prebuilt:
	./scripts/dev-prebuilt.sh $(registry) $(tag)

# Setup commands
.PHONY: setup-dev
setup-dev:
	./scripts/dev-setup.sh

.PHONY: clean
clean:
	docker compose -f environments/local/docker-compose.yml down -v