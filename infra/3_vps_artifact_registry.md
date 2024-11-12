## VPS Configuration

2. [VPS Configuration](#vps-configuration)
3. [Key Rotation](#key-rotation)
4. [Security Considerations](#security-considerations)
5. [Troubleshooting](#troubleshooting)





## Setup VPS OS system

The first thing to do is setup some defaulty locations on our VPS to hold configuration files and some custom functions .


### 0. configuration folders

Create a configuration folder for public/non confidential files

```bash
ssh ${VPS_SSH_USER}@${VPS_SSH_HOST} "mkdir -p ~/vps-config"
```

Create a folder for secrets / confidential files. Also set permissions.
```bash
ssh ${VPS_SSH_USER}@${VPS_SSH_HOST} "mkdir -p ~/.vps-secrets"
ssh ${VPS_SSH_USER}@${VPS_SSH_HOST} "chmod 700 ~/.vps-secrets"
```

### 1. environment variables

We will use the `.env.config` file to hold our VPS configuration (i.e. what registry to connect to, etc.). This file contains public information and nothing confidential.


```bash
# Google Artifact Registry (GAR)
PROJECT_ID=<you gar project id>
LOCATION=us-west1
REPOSITORY_NAME=< your gar repository name>
ARTIFACT_REGISTRY_HOST=${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY_NAME}

# Virtual Private Server (VPS)
VPS_REGISTRY_SERVICE_ACCOUNT=vps-artifact-registry-puller
VPS_KEY_PATH=~/.vps-secrets/gar-sa-key.json
```

### 1. VPS configuration scripts

Copy the `.env.config` to the VPS and custom functions for setting and unsetting

```bash
scp .env.config $VPS_SSH_USER@$VPS_SSH_HOST:~/vps-config/.env.config
scp .bash_vps_functions $VPS_SSH_USER@$VPS_SSH_HOST:~/vps-config/.bash_vps_functions
```


Update `.bashrc` to automatically setup the env on login

```bash
ssh $VPS_SSH_USER@$VPS_SSH_HOST "cat << 'EOF' >> ~/.bashrc

#>>> Customizations >>>>
bind '\"\\t\":menu-complete' 
if [ -f ~/vps-config/.bash_vps_functions ]; then
     . ~/vps-config/.bash_vps_functions 
fi
set_environment ~/vps-config/.env.config
# <<< Customizations <<<
EOF"
```

### Testing the setup

connect to the droplet via ssh then:

- confirm the default env is active `printenv`
- confirm the custom functions work `set_environment ./vps-config/.env.config`

Now we are ready to add the service agent and test the artifact registry integration!


## Setup the registry service agent

We add a read only service agent key previously created for our registry.

> This is a CONFIDENTIAL secret that lives on the VPS

It is read only so the security implications of a breach are minimal but do not share or expose this!


### 0. Create and Download JSON Key

Obtain the credentials for the read only service account.
- These will be transferred to the VPS on initial setup

> we will be deleteing them after copying them to the VPS this is critical

```bash
gcloud iam service-accounts keys create gar-sa-key.json \
  --iam-account $VPS_REGISTRY_SERVICE_ACCOUNT@$PROJECT_ID.iam.gserviceaccount.com
```

### 1. Securely Transfer Key to VPS

Move the service agent key to the VPS and change permissions

```bash
scp gar-sa-key.json $VPS_SSH_USER@$VPS_SSH_HOST:$VPS_KEY_PATH
ssh ${VPS_SSH_USER}@${VPS_SSH_HOST} "chmod 600 ${VPS_KEY_PATH}"
```

After transfering the key remove it

```bash
rm gar-sa-key.json
```

## Install OS libraries and register service agent

Here we install docker, gcloud sdk and other packagess then connect to the registry


### 2. Configure docker and gcloud

Before executing the following commands, log into your VPS:

```bash
ssh $VPS_SSH_USER@$VPS_SSH_HOST
```

### 3. Configure Docker Authentication

Still on the VPS, configure Docker to authenticate with Google Artifact Registry:

```bash
cat $VPS_KEY_PATH | docker login -u _json_key --password-stdin https://${ARTIFACT_REGISTRY_HOST}
```

### 4. Install gcloud CLI (if not already installed)

If the gcloud CLI is not already installed on your VPS, install it with these commands:

```bash
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-sdk
```

### 5. Authenticate gcloud with Service Account

Finally, authenticate gcloud with your service account:

```bash
gcloud auth activate-service-account --key-file=$VPS_KEY_PATH
```

### 6. Set Google Cloud Project

Set the Google Cloud project for gcloud:

```bash
gcloud config set project ${PROJECT_ID}
```

### Verify the docker setup

Test by trying to pull a docker image from the GAR repo

```bash
docker pull $ARTIFACT_REGISTRY_HOST/nginx
```
