# Nginx Setup and Configuration Guide

## Docker Image Structure

- Alpine-based image for minimal size and attack surface
- Includes SSL and Let's Encrypt support for production
- Creates necessary directories for SSL certificates
- Creates default configuration for nginx
- deployment specific overides mounted in docker compose

## Docker Compose Volume Mounting

For local development:
```yaml
services:
  nginx:
    volumes:
      - ./nginx/conf.d/default.conf:/etc/nginx/conf.d/default.conf:ro
      - {path_to_conf file}:/etc/nginx/conf.d/environment/local.conf:ro
```

For production:
```yaml
services:
  nginx:
    volumes:
      - ./nginx/conf.d/default.conf:/etc/nginx/conf.d/default.conf:ro
      - {path_to_conf file}:/etc/nginx/conf.d/environment/production.conf:ro
      - ./ssl:/etc/letsencrypt:ro
```

## Implementation Notes:

1. **Base Configuration**
   - Contains all shared settings
   - Defines upstream servers
   - Sets up common proxy headers
   - Configures rate limiting zones

2. **Local Configuration**
   - Minimal setup for development
   - No SSL or rate limiting
   - Direct proxy passes

3. **Production Configuration**
   - Full SSL setup
   - Rate limiting enabled
   - Health check endpoint
   - Proper redirects

4. **Volume Mounting**
   - Environment-specific config mounted at runtime
   - Easy to switch between environments
   - SSL certificates mounted separately