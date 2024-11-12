# Deployment

This markdown walks through first time setup for deployment as well as how to deploy.

## First Time setup

We set up a folder structure on the VPS and add necessary scripts called during deployment

### 1. Folder structure

We will use the following structure:
```bash
/home/user/
├── data/
│   └── (future mounted volumes, if needed)
└── vps-config/
    ├── docker-compose.yml
    └── deploy_app.sh
```

Create folders on VPS
```bash
ssh $VPS_SSH_USER@$VPS_SSH_HOST "mkdir -p ~/data"
```


### 2. Copy files to VPS

Ensure you have the following files ready on your local machine:

- `docker-compose.yml` : sets up the initial web app
- `./scripts/deploy_app.sh` : redeploys the app based on VPS env vars and configuration

Securely copy the files
```bash
scp docker-compose.yml $VPS_SSH_USER@$VPS_SSH_HOST:~/vps-config/
scp ../scripts/deploy_app.sh $VPS_SSH_USER@$VPS_SSH_HOST:~/vps-config/
```

Set correct permissions
```bash
ssh $VPS_SSH_USER@$VPS_SSH_HOST "chmod +x ~/vps-config/deploy_app.sh"
```

### 3. Verify the folder structure

SSH into the VPS and check the following

Run `tree ~`

You should see:
```bash
/home/nicholasgrundl
├── data
└── vps-config
    ├── deploy_app.sh
    ├── docker-compose.yml
    └── renew_ssl_cert.sh
```

Check for any existing docker containers 
```bash
docker ps
```

If none running try spinning up the webapp
```bash
cd ~/vps-config
docker compose up -d
```

If sucessful stop it (Ctrl+C) the cleanup
```bash
docker compose down
```

For more detailed logs
```bash
docker compose logs
```


## Deployment

When you want to deploy or redeploy follow these steps

### Prerequisites

- completed the first section above
- Ensure you have SSH access to your VPS.
- Make sure Docker and Docker Compose are installed on your VPS.
- Verify that the .env.config file is present in the ~/vps-config/
- Verify that the .deploy_app.sh file is present in the ~/vps-config/ 
- Verify that the .docker-compose.yml file is present in the ~/vps-config/ 

### Optional

> If you modify the docker-compose.yml file as you develop you should update that as well
```bash
scp docker-compose.yml $VPS_SSH_USER@$VPS_SSH_HOST:~/vps-config/
```

### 1. Connect to droplet

SSh into the droplet
```bash
ssh $VPS_SSH_USER@$VPS_SSH_HOST
```

Navigate to the directory containing the deployment script
```bash
cd ~/vps-config
```
Run the deployment script

```bash
./deploy_app.sh
```

Monitor the output for any errors or successful deployment messages.