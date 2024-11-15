# Managing Environment Variables with .env Files

## Security Considerations

Before diving into usage, let's address important security considerations:

1. **Git Safety**
   ```gitignore
   # Always add to .gitignore
   .env
   .env.*
   !.env.example
   ```

2. **Key Management**
   - Store paths to keys, not the keys themselves:
   ```bash
   # Bad
   PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgk..."
   
   # Good
   PRIVATE_KEY_PATH="environments/local/keys/service.key"
   ```

3. **Sensitive Data**
   - Never commit sensitive data like API keys, passwords, or tokens
   - Use placeholders in example files
   - Consider using secret management services for production

## .env File Format

Example .env file with best practices:

```bash
### Service Configuration
# Development Mode
DEV_MODE=true                    # Enable development features
DEBUG=true                       # Enable debug logging
LOG_LEVEL=debug                  # Logging verbosity

### API Configuration
BASE_URL=api.example.com
API_URL=https://${BASE_URL}/v1   # Uses string expansion
API_VERSION=2.1

### Docker Registry Configuration
PROJECT_ID=my-registry
LOCATION=us-west1
REPOSITORY_NAME=my-dev-repo
# Uses multiple variable expansions
ARTIFACT_REGISTRY=${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY_NAME}

### Service Images
IMAGE_TAG=latest
BACKEND_IMAGE=${ARTIFACT_REGISTRY}/backend   # Uses expansion
```

**Key Features:**
- Uses `#` for comments
- Groups related variables with comment headers
- Supports string expansion (`${VAR}`)
- One variable per line
- UPPERCASE variable names
- Clear, descriptive names
- Optional inline comments

## Using in Python

1. Install python-dotenv:
```bash
pip install python-dotenv
```

2. Load in Python code:
```python
from dotenv import load_dotenv
import os

# Load .env file
load_dotenv()  # Default .env file
# Or specify path:
load_dotenv("/path/to/.env")

# Access variables
api_url = os.getenv("API_URL")
debug_mode = os.getenv("DEBUG", "false").lower() == "true"  # With default

# Type conversion example
log_level = os.getenv("LOG_LEVEL", "info").upper()
```

3. Advanced usage:
```python
from dotenv import load_dotenv, find_dotenv

# Auto-find .env file
load_dotenv(find_dotenv())

# Override existing env vars
load_dotenv(override=True)

# Load multiple files
load_dotenv(".env")
load_dotenv(".env.local", override=True)
```

## Using in Bash

### Direct Shell Usage
```bash
# Load environment variables with expansion
set -a; source .env; set +a

# Verify
echo $API_URL
```

### Makefile Integration
```makefile
# Allow override of env file path
ENV_FILE ?= .env

# Export all variables from env file
export $(shell grep -v '^#' $(ENV_FILE) | xargs)

# Example targets
build:
    echo "Building image: $$BACKEND_IMAGE:$$IMAGE_TAG"
    docker build -t $$BACKEND_IMAGE:$$IMAGE_TAG .

deploy:
    echo "Deploying to $$ENVIRONMENT"
    kubectl apply -f k8s/
```

Usage:
```bash
# Use default .env
make build

# Override env file
make deploy ENV_FILE=environments/prod.env
```

## Best Practices

1. **File Organization**
   ```
   .
   ├── .env                    # Local development (gitignored)
   ├── .env.example           # Template (committed)
   ├── environments/
   │   ├── development.env    # Dev environment
   │   ├── staging.env        # Staging environment
   │   └── production.env     # Production environment
   ```

2. **Version Control**
   - Commit `.env.example` with placeholders
   - Document required variables
   - Include setup instructions

3. **Validation**
   - Validate required variables on startup
   - Use typing/schema validation when possible
   - Provide clear error messages

4. **Documentation**
   - Comment non-obvious variables
   - Group related variables
   - Include units when applicable

5. **Defaults**
   - Provide sensible defaults
   - Document default values
   - Make critical variables required

## Troubleshooting

Common issues and solutions:

1. **Variable Not Found**
   - Check file path
   - Verify variable name/case
   - Ensure proper loading

2. **Expansion Not Working**
   - Verify syntax (`${VAR}`)
   - Check variable definition order
   - Ensure shell supports expansion

3. **Type Mismatches**
   - Convert strings to proper types
   - Use validation
   - Set explicit defaults

4. **File Not Found**
   - Check working directory
   - Verify file permissions
   - Use absolute paths when needed
