# /nginx/Dockerfile
FROM nginx:1.25-alpine

# Install certbot for SSL certificate management
RUN apk add --no-cache certbot certbot-nginx

# Create required directories
RUN mkdir -p /var/www/_letsencrypt \
    && mkdir -p /etc/nginx/conf.d/environment

# Copy base configuration
COPY conf.d/default.conf /etc/nginx/conf.d/default.conf

# Environment configuration will be mounted as volume
# ## TODO: do i need these?
# EXPOSE 80

# CMD ["nginx", "-g", "daemon off;"]