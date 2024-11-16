# Local Development Testing Checklist

## Action Items:
- [x] make a very simple docker compose that tests the prebuilt images 
- [x] parameterize it to the current version using an env file
    - skip the local build variation for now
- [ ] rebuild dockmaster image so it is correct
    - pull changes for fastapi from windows machine and rebuild.
    - clean up tags and remove old images. make a fresh set starting from 0.0.1
    - check source code mounting into image or installing into image?
- [ ] rebuild dockyard image so it is correct
    - make it a proper package in the repo so it c an be built and installed editable
    - clean up tags and remove old images. make a fresh set starting from 0.0.1
    - check source code mounting into image or installing into image?
- [ ] test the docker compsoe local setup

# Steps

## 1. Google Artifact Registry Setup
- [x] Configure Docker to use Google Artifact Registry authentication
- [x] Create repository in Google Artifact Registry
- [x] Verify access to repository

## 2. Build and Push Images
- [x] Build waypoint (frontend) image
- [x] Build dockyard (backend) image
- [x] Build dockmaster (auth) image
- [x] Tag all images appropriately
- [x] Push images to Google Artifact Registry
- [x] Verify images in registry

## 3. Local prebuilt Images Test
- [x] dev key files
    - verify setup script openssl versus ssh-agent
    - create dev keys and gitignore
- [x] configure Env file settings
    - make file should use env.development file?
- [x] Verify fresh pull from GAR
- [ ] Verify compose launches images
- [ ] Verify all services are working
    - test on local host

## 4. Local Image Building mounted Test
- [ ] configure Env file settings
    - local build of images them use local image
    - make file should pass manual env arg to the call
- [ ] Test waypoint local relative build
- [ ] Test dockyard local relative build
- [ ] Test dockmaster local relative build
- [ ] look into github links or modules for loacl build by relative repo links?
- [ ] Test all services together with local builds

## 5. Local Source-Mounted Development Test [ ]
- [ ] configure Env file settings
    - local build of images with local source mount
    - make file should pass manual env arg to the call
- [ ] Run composition with mounted source code
- [ ] Verify live reload functionality

## Progress Log

### Built separate images to test local deploy
