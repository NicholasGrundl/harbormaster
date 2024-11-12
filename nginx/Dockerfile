FROM nginx:latest

COPY nginx.dev.conf /etc/nginx/nginx.dev.conf
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

