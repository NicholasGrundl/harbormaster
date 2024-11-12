# Welcome

This document outlines the first steps to setting up you WSL Linux (Ubuntu) OS with the packages for development

We will be installing:
- Git : version control
- Make: general file builder and scripter
- Miniconda: virtual environment manager
- Docker: containerization software

# OS Packages

First update the package list and upgrade packages

    ```bash
    sudo apt update
    sudo apt upgrade
    ```
## General packages

1. Install packages:
   ```
   sudo apt install git -y
   sudo apt install tree -y
   sudo apt install make -y
   ```

## Docker

1. Install Docker:
   - Follow the official Docker installation guide for Ubuntu: https://docs.docker.com/engine/install/ubuntu/
   - After installation, run:
     ```
     sudo usermod -aG docker $USER
     ```
   - Log out and log back in for the changes to take effect

2. Install Docker Compose:
   - Run the following commands:
     ```
     sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
     sudo chmod +x /usr/local/bin/docker-compose
     ```

## Miniconda

1. Install Miniconda:
   - Download the Miniconda installer:
     ```
     wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
     ```
   - Run the installer:
     ```
     bash Miniconda3-latest-Linux-x86_64.sh
     ```
   - Follow the prompts to complete the installation
   - Restart your terminal or run `source ~/.bashrc`


## Verification
- Docker: Run `docker --version` and `docker-compose --version`
- Git: Run `git --version`
- Miniconda: Run `conda --version`

## Troubleshooting
- If you encounter any issues with Docker, ensure that the Docker service is running: `sudo service docker start`
- For Miniconda, if the `conda` command is not recognized, you may need to initialize it: `conda init bash`