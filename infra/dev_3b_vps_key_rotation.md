# TODO:

- section for key rotation commands
- script implementing the commands

- how to schedule the script?




















# ------------------------

## Key Rotation

We rotate keys periodically to ensure security is not comprimised

### Key Rotation Script

Create a file named `rotate_gcr_key.sh` with the following content:

```bash
#!/bin/bash

# Check if required environment variables are set
if [ -z "$PROJECT_ID" ] || [ -z "$SERVICE_ACCOUNT_NAME" ] || [ -z "$KEY_PATH" ]; then
    echo "Error: Required environment variables are not set."
    echo "Please ensure PROJECT_ID, SERVICE_ACCOUNT_NAME, and KEY_PATH are set in your .env file."
    exit 1
fi

# Construct the full service account email
SERVICE_ACCOUNT="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Create a new key
gcloud iam service-accounts keys create ${KEY_PATH}.new \
  --iam-account ${SERVICE_ACCOUNT}

# Set proper permissions
chmod 600 ${KEY_PATH}.new

# Authenticate Docker with the new key
cat ${KEY_PATH}.new | docker login -u _json_key --password-stdin https://${ARTIFACT_REGISTRY_HOST}

# If authentication was successful, replace the old key
if [ $? -eq 0 ]; then
  mv ${KEY_PATH}.new ${KEY_PATH}
  echo "Key rotated successfully"
else
  echo "Failed to authenticate with new key. Old key retained."
  rm ${KEY_PATH}.new
fi

# List and delete old keys, keeping the last 2
gcloud iam service-accounts keys list \
  --iam-account ${SERVICE_ACCOUNT} \
  --format="get(name)" | sort | head -n -2 | xargs -I {} gcloud iam service-accounts keys delete {} \
  --iam-account ${SERVICE_ACCOUNT} --quiet
```


## Schedule Key Rotation

Set up a cron job to run the script every 3 months:
```bash
(crontab -l 2>/dev/null; echo "0 0 1 */3 * ./scripts/vps_key_rotation") | crontab -
```

```
0 0 1 */3 * source /path/to/.env && /path/to/rotate_gcr_key.sh >> /path/to/key_rotation.log 2>&1
```
## Maintenance

- The key rotation script will run automatically every 3 months.
- Monitor the rotation process by checking the cron job's logs.
- Periodically review the service account's permissions to ensure they're still appropriate.

## Security Notes

1. Ensure that the service account has the minimum necessary permissions (principle of least privilege).
2. Store the service account key securely on the VPS with restricted permissions (chmod 600).
3. Rotate the service account key regularly (as set up in the cron job).
4. Keep the .env file with restricted permissions (chmod 600) to protect sensitive information.
5. Monitor and audit the usage of the service account regularly.

- Keep your service account key secure. It's sensitive information that grants access to your GCP resources.
- Regularly audit who has access to the VPS and the service account key.
- Consider using more advanced secret management solutions for production environments.
