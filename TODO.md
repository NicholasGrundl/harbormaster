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