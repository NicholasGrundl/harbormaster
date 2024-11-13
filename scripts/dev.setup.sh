# /scripts/dev-setup.sh
#!/bin/bash
set -e

# Generate development keys directory
mkdir -p environments/local/keys

# Copy example env if not exists
if [ ! -f environments/local/.env ]; then
  cp environments/local/.env.example environments/local/.env
  echo "Created .env file from example"
fi

# Generate development keys
if [ ! -f environments/local/keys/dockmaster.key ]; then
  openssl genpkey -algorithm RSA -out environments/local/keys/dockmaster.key
  echo "Generated dockmaster key"
fi

if [ ! -f environments/local/keys/dockyard.key ]; then
  openssl genpkey -algorithm RSA -out environments/local/keys/dockyard.key
  echo "Generated dockyard key"
fi

echo "Development environment setup complete!"

