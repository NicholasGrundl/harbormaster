# /nginx/Dockerfile
FROM nginx:1.25-alpine

# Install certbot for SSL certificate management
RUN apk add --no-cache certbot certbot-nginx

# Create required directories
RUN mkdir -p /var/www/_letsencrypt \
    && mkdir -p /etc/nginx/conf.d/environment

# Copy configurations
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/default.conf /etc/nginx/conf.d/default.conf
# - Environment specific configuration volume mounted

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]