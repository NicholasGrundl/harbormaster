# Docker operations

Instructions on how to build, tag and push the docker images

## Build

We build docker images locally, then push them to the google artifact registry.

> Note we may eventually setup cloudbuild as well but for now this works well

### Build all images

run `make docker.build`

### Build a specific image

run `make docker.build.<imagename>`


## Push image to registry

We use a script to push images to the registry. While you can call this directly we prefer to use make tartgets as always.

### Tag and Push all images

run `make docker.push`

### Tag and Push a specific image

run `make docker.push.<imagename>`

