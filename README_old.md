# Harbormaster webapp devops

## Overview/Welcome

Welcome to Harbormaster, the deployment and devops repo for my web application. The we app implements:
- a FastAPI backend, React frontend, and Nginx reverse proxy. 

This project demonstrates a modern web application architecture with separate frontend and backend services deployed on a cheap simple digital_ocean VPS droplet.

### Project Structure

```
myapp/
├── infra/           # Infrastructure and deployment configurations
├── nginx/           # Nginx reverse proxy configuration
├── scripts/         # Utility scripts
├── Makefile         # Project-wide make targets
└── README.md        # This file
```

### Main Components

- **Infra**: Deployment and infrastructure management files
- **Nginx**: Reverse proxy to route requests between frontend and backend

## First-time here

### Prerequisites

- Docker
- Docker Compose
- Make
- Miniconda

> Follow the readme setup files for starting from scratch on WSL

### Setting up the project

0. Make sure you have all the prerequisites installed on your machine

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/harbormaster.git
   cd harbormaster
   ```

2. Create and activate a conda env
   ```
   conda create -n myapp python=3.10 pip nodejs
   conda activate myapp
   ```

3. Install python dependencies for the backend
   ```
   make install.python
   ```
4. Install Node dependencies for the frontend
   ```
   make install.node
   ```

5. Build + Tag the docker images:
   > We do most of the building from the infra folder

   - change to the `./infra` folder
   - rebuild the docker images and tag them
      ```
      make docker.build
      ```
### Launch the local dev app

> We do most of the local hosting from the infra folder

1. First change to the `./infra` folder
   - also make sure you have build the docker images you wish to test

2. Launch the local dev docker compose
      ```
      make compose.dev
      ```

3. Open your browser and navigate to `http://localhost:80`
   - Note right now you have to rebuild the images to get the changes showing up in the dev compose.
   - In the near future we will hot mount the dev src code so we can swap code live.

### Basic Usage

- The frontend application will be available at `http://localhost:80`
- The backend API will be accessible at `http://localhost:80/api`
- API documentation (Swagger UI) can be found at `http://localhost:80/api/docs`

## Experienced user

We like to use Makefiles where possible to manage dev commands etc.

[...common make targets]

- `make install` : install all python and node dependencies into conda env
- `make uninstall`: remove all python and node dependencies from conda env
- `make jupyter` : launch jupyter notebook


### Environment Variables

[... more coming soon]


### Development Workflow

> We do most of the local hosting from the infra folder

0. First change to the `./infra` folder
1. Make changes to the frontend or backend code
2. Rebuild and restart the affected services:
   ```
   make docker.build  # For all changes
   make docker.build.backend  # For backend changes
   make docker.build.frontend  # For frontend changes
   ```
3. Run development app:
   ```
   make compose.dev
   ```

### Testing

[... more coming soo]


### Monitoring

[...More coming soon]