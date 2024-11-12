# MyApp Nginx Configuration

## Overview/Welcome

Welcome to the Nginx configuration for MyApp. This directory contains the necessary files to set up and customize the Nginx reverse proxy used in our application.

### File Structure

```
nginx/
├── Dockerfile
├── nginx.conf
├── nginx.dev.conf
└── README.md
```

### Main Files

- `Dockerfile`: Used to build the Docker image for the Nginx service
- `nginx.conf`: The main Nginx configuration file for production
- `nginx.dev.conf`: Nginx configuration for development environment

## First-time here

### How Nginx is Configured in the Project

In this project, Nginx serves as a reverse proxy, routing requests between the frontend and backend services. It handles:

1. Serving static files from the frontend build
2. Routing API requests to the backend service
3. SSL/TLS termination (in production)

### Basic Usage within Docker Compose

The Nginx service is defined in the main `docker-compose.yml` file. It's configured to:

1. Listen on port 80 (and 443 for HTTPS in production)
2. Forward API requests to the backend service
3. Serve the frontend static files

## Experienced user

### Customizing Nginx Configuration

Edit the `nginx.conf` file for production

Edit the `nginx.dev.conf` for development
- listens on http port 80, no ssl


### Performance Tuning Tips

[...TO DO, ideas below]

1. Enable Gzip compression:

2. Implement browser caching:

3. Optimize worker processes and connections:

4. Use upstream keepalive connections:


### Logging and Monitoring

[...TODo more coming]