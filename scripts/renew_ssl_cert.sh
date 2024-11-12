#!/bin/bash
certbot renew --quiet
docker-compose restart nginx