# MyApp Infrastructure

## Overview/Welcome

Welcome to the infrastructure and deployment configuration for MyApp. This directory contains all the necessary files and instructions for setting up and maintaining the production environment for our application.

### File Structure

```
infra/
├── docker-compose.yml
├── docker-compose.dev.yml
├── Makefile
├── .bash_vps_functions
├── 0_vps_creation.md
├── 1_google_artifact_registry.md
├── 2_google_service_agents.md
├── 3_vps_artifact_registry.md
├── 4_ssl_certificate.md
├── 5_docker_images_build.md
├── 6_app_deployment.md
└── README.md
```

### Main Files and Folders

- `docker-compose.yml`: Production Docker Compose configuration
- `docker-compose.dev.yml`: Development Docker Compose configuration
- `Makefile`: Contains useful commands for managing the infrastructure
- `.bash_vps_functions`: Bash functions for VPS management
- Numbered markdown files: Step-by-step guides for various setup procedures

## First-time here

### Prerequisites

- Docker and Docker Compose
- Google Cloud Platform account
- A VPS or cloud instance (e.g., Digital Ocean droplet)
- Domain name (optional, but recommended for production)

### Initial Setup Guide

Follow these steps in order to set up your infrastructure for the first time:

1. VPS Creation: Follow instructions in `0_vps_creation.md`
2. Google Artifact Registry Setup: Follow `1_google_artifact_registry.md`
3. Google Service Agents: Set up as per `2_google_service_agents.md`
4. VPS Artifact Registry Configuration: Use `3_vps_artifact_registry.md`
5. SSL Certificate Setup: Follow `4_ssl_certificate.md`
6. Docker Images Build: Instructions in `5_docker_images_build.md`
7. Application Deployment: Deploy using `6_app_deployment.md`

### First-time Deployment

After completing the initial setup of the VPS:

1. Ensure all environment variables are set correctly
2. Connect to the droplet:
  ```
  make droplet.connect
  ```

After completing the initial setup of the gcloud artifact registry:
1. Ensure all environment variables are set correctly
2. Build the production images:
  ```
  make docker.build
  ```

3. Push the production images:
  ```
  make docker.push
  ```

Test the local deployment

1. Launch the dev dockercompose
  ```
  make compose.dev
  ```

2. Test the web app

3. Cleanup
  ```
  make compose.clean
  ```

## Experienced user

### Common Make routines

- `make droplet.connect` : ssh into the droplet as user
- `make droplet.deploy` : securely deploy changes to docker compose webapp
- `make docker.build` : rebuild and tag docker images
- `make docker.push` : push images to the google artifact repository
- `make compose.dev` : launch the local dev app
- `make compose.clean` : cleanup the local app

### Maintenance Procedures

#### Updating the application:

   [... TOdo more coming ] 

#### Rotating SSL certificates:
  
    [... TOdo more coming ] 


#### Checking service health:

   [... TOdo more coming ] 


### Credential Management

- To update Google Cloud credentials:
  1. Generate new service account key in Google Cloud Console
  2. Replace the key file on the VPS
  3. Update the `VPS_KEY_PATH` in `.env.config`

- To rotate SSH keys:
  1. Generate new SSH key pair
  2. Add new public key to VPS authorized_keys
  3. Update `VPS_SSH_KEY` in your local `.env.dev`

### Troubleshooting Common Issues

[... TOdo more coming see ideas below ] 

1. Container fails to start:
   - Check logs
   - Verify environment variables in `.env` files

2. SSL certificate issues:
   - Ensure certbot is up to date
   - Check certificate expiration



### Monitoring and Logging

[.. TODO more coming ] 
