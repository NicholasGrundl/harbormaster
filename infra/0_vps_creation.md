# TODO:

this documentation is good but should be fixed to:

- [ ]create an initial VPS (digital ocean)
   - setup a username non root
   - setup for ssh into droplet
- [ ] setup dev env file
   - .env file for local/dev SSH ip adress and username
   - setup makefile for setting dev env?
   - example calls for how to ssh and how to transfer files
- [ ] setup basic firewall
- [ ] install os dev/deployment packages? --> move to next readme?
   - installing docker
   - installing gcloud sdk?
   - installing basic cli tools
      - tree
- [ ] connect domain to the droplet
   - squarespace

We can remove the section on deployment here


## Create a new droplet

### Prerequisites

- A Digital Ocean account
- SSH key pair on your local machine

### 1. Create a new droplet in the gui

Sign in to your Digital Ocean account or create one if you haven't already.

Click "Create" and select "Droplets" from the dropdown menu.

Choose the following options:
   - Image: Ubuntu 24.04 (LTS) x64
   - Plan: Basic
   - CPU options: Regular with SSD
   - Choose the $5/mo option (1 GB / 1 CPU, 25 GB SSD)
   - Choose a datacenter region closest to your target audience
   - Select "SSH keys" for authentication
   - Choose a hostname for your Droplet

Click "Create Droplet" and wait for it to be provisioned.

Once the Droplet is created, note its IP address <your_droplet_ip>.

### 2. update and add a user

Connect to your Droplet via SSH 
```bash
ssh root@<your_droplet_ip>
```

> if asked to add the fingerprint say yes this is normal the first time

Upgrade system packages and add any utilities

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install tree -y
```

> you mayu be asked about a specific package related to ssh as this is the critical security package.
> feel free to upgrade or keep the local version provided by the VPS vendor


Set up a non-root user with sudo privileges:
```bash
adduser <your_username>
usermod -aG sudo <your_username>
```

> this is an important password, do not forget it!
> it will be used for sudo privleges on the node

### 3. Set up SSH key authentication for the new user:
   
Create ssh keys configurations

```bash
su - <your_username>
mkdir ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

Add your public SSH key to the `authorized_keys` file:

> the public key is found on your local machine, make sure its the public address...
>  for example for an ed25519 key format
>  `cat ~/.ssh/id_ed25519.pub`

```bash
echo <your_public_key> >> ~/.ssh/authorized_keys
```

Make sure the connection worked before proceeding

```bash
ssh <your_username>@<your_droplet_ip>
```


### 4. setup an environment file for developing

To persist and make connections while developing easier we will set up a local development
`.env.dev` file

```bash
#dev env for the droplet
VPS_SSH_HOST=<your_droplet_ip>
VPS_SSH_USER=<your_username>
```

From here on out when working on this project we can:
- export the env to our shell `set_environment .env.dev`
- connect to the droplet with `ssh $VPS_SSH_USER@$VPS_SSH_HOST`


## Configuring the Firewall

After setting up your Droplet and creating a non-root user, it's important to configure the firewall to secure your server. Follow these steps to set up and configure UFW (Uncomplicated Firewall):

### 1. Install UFW  on VPS

ssh into the VPS the configure the firewall

```bash
ssh $VPS_SSH_USER@$VPS_SSH_HOST
```
   
Install the basic firewall
```bash
sudo apt install ufw
```

### 2. Setup basic policies 

Set default policies:
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

Allow SSH connections:
```bash
sudo ufw allow ssh
```

Allow HTTP and HTTPS traffic:
```
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### 3. Enable and activate the firewall
Enable the firewall:
```bash
sudo ufw enable
```

Check the status of the firewall:
```bash
sudo ufw status verbose
```

If everything is working you should see:
```bash
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere
80/tcp                     ALLOW IN    Anywhere
443/tcp                    ALLOW IN    Anywhere
22/tcp (v6)                ALLOW IN    Anywhere (v6)
80/tcp (v6)                ALLOW IN    Anywhere (v6)
443/tcp (v6)               ALLOW IN    Anywhere (v6)
```

Verify the following 
- Ensure that the UFW status shows that it's active and that the correct rules are in place
- Verify that you can still connect via SSH
- Check that you can access your server via HTTP (and HTTPS once it's set up)

### Firewall Troubleshooting

- If you get locked out due to UFW rules, you may need to use the Digital Ocean console to access your Droplet and adjust the firewall settings
- Make sure you allowed SSH before enabling the firewall to prevent losing access to your Droplet



## Installing Docker and Docker Compose

To run MyApp on your Droplet, you need to install Docker and Docker Compose. Follow these steps:


### 1. SSH into the droplet/VPS

ssh into the VPS

```bash
ssh $VPS_SSH_USER@$VPS_SSH_HOST
```

### 1. Update prerequisites

Update the package index and install prerequisites:
```bash
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
```

Add Docker's official GPG key:
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

Add the Docker repository:
```bash
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```


### 2. Install the docker package
Update the package index again and install Docker:

```bash
sudo apt update
sudo apt install docker-ce
```

Add your user to the docker group:
```bash
sudo usermod -aG docker ${USER}
```

### 3. Install Docker Compose

Docker compose is installed from a link. Check the link periodically it may change over time with versions
```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

Verify the installations:
```bash
docker --version
docker-compose --version
```

### 4. Test Docker with a hello-world container

> Make sure to log out of the ssh connection then relogin before testing so the permissions are set correctly

Hello world ships with the install. lets test it

```bash
docker run hello-world
```

### Docker and Docker Compose Troubleshooting

- If you encounter permission issues with Docker, make sure your user is added to the docker group and you've logged out and back in
- If Docker Compose installation fails, check that you have curl installed and that you have a stable internet connection





## Configuring Domain with Squarespace

To configure your personal domain hosted on Squarespace to point to your Digital Ocean Droplet, follow these steps:

### 1. Log in to your Squarespace account

Login to square space or your provider

Go to the "Domains" section in your Squarespace dashboard.

Select the domain you want to use for your application.
- this is the domain you pruchased (e.g. `nicholasgrundl.com`)

Click on "Advanced settings" or "DNS settings" (the exact wording may vary).

Find the section for "A Records" or "Host Records".
- A record stands for "Address Record"

### 2. Create a new A record

Add an A record for the domain:
- Host: @ (or leave blank). 
- Points to: Your Digital Ocean Droplet's IP address (`$VPS_SSH_HOST`)
- TTL: 3600 (or 1 hour)

> "@" means the base host (e.g. `nicholasgrundl.com`)

If you want to use a subdomain (e.g., add a "www" prefix or other prefix to nicholasgrundl.com), create a CNAME record:
- Host: www (or your desired subdomain)
- Points to: @ (or your root domain)
- TTL: 3600 (or 1 hour)

> CNAME means "Canonical Name"

Save your changes.


### Verification

- Wait for DNS propagation (can take up to 48 hours, but often much less)
- Use a tool like `dig` or an online DNS checker to verify that your domain points to your Droplet's IP:
```bash
dig nicholasgrundl.com
```
- Try accessing your application using your domain name

### Troubleshooting

- If the domain doesn't point to your Droplet after 48 hours, double-check your DNS settings in Squarespace
- Ensure that your Droplet's firewall allows incoming connections on port 80 (and 443 for HTTPS)
- If using a subdomain, make sure both the A record for the root domain and the CNAME for the subdomain are set up correctly

Remember to update your application configuration to use the new domain name if necessary, and consider setting up HTTPS for secure connections to your application.