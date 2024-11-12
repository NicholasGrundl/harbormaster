# Steps

Here we configure an SSL certificate to enable https encrypted connections (best practice)

## Prerequisite

- registered your <domain_name> with the droplet / VPS IP address

Run through these checks BEFORE setting up the SSL certificate

### Verify the Domain

Verify the domains are correct

Check DNS records:
Use the dig command or an online DNS lookup tool to check the A record for your domain:

```bash
dig <you_domain>.com
```
- The A record should point to your Digital Ocean VPS IP address.


Check CNAME record (if applicable):
If you're using a www subdomain, check its CNAME record:
```bash
dig www.<you_domain>.com
```
- It should point to your root domain or have an A record pointing to your VPS IP.


Verify propagation:
Visit https://www.whatsmydns.net/ and enter your domain to check if the DNS changes have propagated globally.

Test ping to domain:
```bash
ping <you_domain>.com
```
- This should return responses from your VPS IP address.

Connection Test:
Since Nginx isn't running, we can't test HTTP access. However, we can test if the server is reachable on port 80:
```bash
nc -vz <you_domain>.com 80
```
- This might show a connection refused error, which is expected if no service is listening on port 80.

### Stop the default enginx

First check if an nginx server is running:

```
sudo lsof -i :80
```

If so lets stop the running Nginx service
```
sudo systemctl stop nginx
```

To prevent it from starting automatically on system boot
```
sudo systemctl disable nginx
```

Verify nothing is running on the ports
```
sudo lsof -i :80
```


## Setup the certificate

### 1. Setup certbot

SSH into your VPS:

```bash
ssh $VPS_SSH_USER@$VPS_SSH_HOST
```

Update the package list and install Certbot with the Nginx plugin:

```bash
sudo apt update
sudo apt install certbot python3-certbot-nginx
```

Verify the installation:

```bash
certbot --version
```


### Step 2: Obtain SSL certificates using Certbot

Obtain SSL certificates using Certbot in standalone mode
```bash
sudo certbot certonly --standalone -d <you_domain>.com -d www.<you_domain>.com
```

> You will be asked to accept an agreement and provide an email. They are a non profit, do it :P

You should see something like the following:
```
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Requesting a certificate for <you_domain>.com and www.<you_domain>.com

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/<you_domain>.com/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/<you_domain>.com/privkey.pem
This certificate expires on 2024-12-20.
These files will be updated when the certificate renews.
Certbot has set up a scheduled task to automatically renew this certificate in the background.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
If you like Certbot, please consider supporting our work by:
 * Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
 * Donating to EFF:                    https://eff.org/donate-le
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

### 3. Update the nginx configuration

Modify your prod Nginx configuration file (`./nginx/nginx.conf`) in your project

```bash
# other content...

nginx:
    image: nginx:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /etc/letsencrypt:/etc/letsencrypt:ro
    depends_on:
      - backend

# other content...
```

### 4. Check for auto renewal

sudo systemctl status certbot.timer


## Troubleshooting

- If Certbot fails to obtain a certificate, ensure that your domain is correctly pointing to your Droplet's IP address
- Check Nginx logs for any errors: `sudo nginx -t` and `sudo journalctl -xeu nginx`
- If auto-renewal isn't working, check the Certbot logs: `sudo journalctl -u certbot`

## Important Notes

- Let's Encrypt certificates are valid for 90 days
- The auto-renewal process should attempt to renew certificates 30 days before expiration
- Ensure that your firewall allows incoming connections on port 443 (HTTPS)
- After setting up SSL, update your application configuration to use HTTPS if necessary

Remember to keep your SSL configuration up to date and monitor for any security advisories related to SSL/TLS.









##### ---- Verify this step as necessary or not

### 5. (optional) Setup auto renewal of the SSL and nginx container

Copy script to VPS
```bash
scp ../scripts/renew_ssl_cert.sh $VPS_SSH_USER@$VPS_SSH_HOST:~/vps-config/renew_ssl_cert.sh
ssh $VPS_SSH_USER@$VPS_SSH_HOST "chmod +x ~/vps-config/renew_ssl_cert.sh"
```

Add a cron job to run this script twice daily
```bash
0 0,12 * * * /path/to/renew_cert.sh
```

