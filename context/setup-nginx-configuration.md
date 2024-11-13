# Nginx Setup and Configuration Guide

## Docker Image Structure

### Base Image Selection

**Rationale:**
- Alpine-based image for minimal size and attack surface
- Includes SSL and Let's Encrypt support for production
- Creates necessary directories for SSL certificates
- Creates default configuration for nginx
- deployment specific overides mounted in docker compose

### Security Considerations
- Running as non-root user where possible
- Minimal installed packages
- Read-only filesystem where possible
- Regular security updates

## Configuration Structure

### Base Configuration Template
The base configuration will be structured as follows:

```nginx
# /nginx/conf.d/default.conf.template
# Common configuration shared between environments
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    access_log /var/log/nginx/access.log main;

    # Basic Settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;

    # Gzip Settings
    gzip on;
    gzip_disable "msie6";
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-origin" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Include environment-specific configurations
    include /etc/nginx/conf.d/sites-enabled/*.conf;
}
```

### Environment-Specific Configurations

#### Local Development
```nginx
# /environments/local/nginx.conf
server {
    listen 80;
    server_name localhost;

    # Frontend
    location / {
        proxy_pass http://waypoint:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Backend API
    location /api/ {
        proxy_pass http://dockyard:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Auth Service
    location /auth/ {
        proxy_pass http://dockmaster:8001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

#### Production
```nginx
# /environments/production/nginx.conf
# This will be included in the SSL configuration
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;

    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/live/your-domain.com/privkey.pem;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;

    # Modern configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # HSTS (uncomment if you're sure)
    # add_header Strict-Transport-Security "max-age=63072000" always;

    # Frontend
    location / {
        proxy_pass http://waypoint:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Security headers
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    }

    # Backend API with rate limiting
    location /api/ {
        proxy_pass http://dockyard:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Rate limiting
        limit_req zone=api burst=10 nodelay;
        limit_req_status 429;
    }

    # Auth Service with rate limiting
    location /auth/ {
        proxy_pass http://dockmaster:8001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Rate limiting
        limit_req zone=auth burst=5 nodelay;
        limit_req_status 429;
    }

    # Let's Encrypt challenge location
    location /.well-known/acme-challenge/ {
        root /var/www/_letsencrypt;
    }
}
```

## Key Features and Decisions

1. **Security First**
   - SSL configuration with modern ciphers
   - Security headers included by default
   - Rate limiting for API endpoints
   - No server tokens
   - HSTS support (optional)

2. **Performance Optimization**
   - Gzip compression enabled
   - Efficient SSL session handling
   - WebSocket support
   - Proper proxy headers

3. **Maintainability**
   - Separate configurations for local and production
   - Template-based approach for easy updates
   - Clear documentation and comments
   - Structured directory layout

4. **Monitoring and Debugging**
   - Detailed access and error logging
   - Custom log format with relevant information
   - Easy to extend with additional monitoring

5. **SSL/TLS Handling**
   - Let's Encrypt integration
   - Automatic certificate renewal
   - HTTP to HTTPS redirect
   - Modern SSL configuration

## Implementation Notes

1. The configuration uses environment variables where appropriate
2. Production setup includes rate limiting to prevent abuse
3. Local development setup is simplified but maintains similar structure
4. SSL configuration is production-grade but optional for development
5. All configurations are modular and easy to extend