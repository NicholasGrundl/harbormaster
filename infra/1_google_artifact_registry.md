# Setting up Google Artifact Registry for Docker Images

To deploy to a VPS we need to set up a GCP registry where we can pull our docker images from

## Initial Setup: Installing and Configuring gcloud

1. **Install the Google Cloud SDK (gcloud)**
   - Visit the [Google Cloud SDK installation page](https://cloud.google.com/sdk/docs/install)
   - Follow the instructions for your operating system

2. **Initialize gcloud**
   ```bash
   gcloud init
   ```
   - Follow the prompts to log in and select your project

3. **Set up environment configuration variables**
   Create a `.env.config` file in your project root with the following content:
   ```bash
   PROJECT_ID="your-project-id"
   LOCATION="your-preferred-location"
   REPOSITORY_NAME="your-repository-name"
   ARTIFACT_REGISTRY_HOST=${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY_NAME}
   ```

   > a common location is `us-west1`
   
   Load these variables in your shell:
   ```bash
   source .env.config
   ```

4. **Set the active project**
   ```bash
   gcloud config set project $PROJECT_ID
   ```

## Prerequisites
- Google Cloud project is set up
- Billing is enabled for the project
- Google Cloud SDK (gcloud) is installed and configured

## Steps

1. **Enable the Artifact Registry API**
   ```bash
   gcloud services enable artifactregistry.googleapis.com
   ```

2. **Choose a location for your repository**
   - List available locations:
     ```bash
     gcloud artifacts locations list
     ```
   - Choose a location close to your deployment or development environment
   - Update the `LOCATION` in your `.env.config` file if necessary

3. **Create a new repository**
   ```bash
   gcloud artifacts repositories create $REPOSITORY_NAME \
       --repository-format=docker \
       --location=$LOCATION \
       --description="Docker repository for $PROJECT_ID"
   ```

4. **Configure Docker to authenticate with Artifact Registry**

    > see [google cloud platform docs](https://cloud.google.com/artifact-registry/docs/docker/authentication) for more details
   ```bash
   gcloud auth configure-docker ${LOCATION}-docker.pkg.dev
   ```

## Additional Notes
- Ensure you have the necessary permissions in your Google Cloud project to create and manage Artifact Registry repositories.
- Consider setting up IAM roles for fine-grained access control to your repository.
- Always keep your `.env` file secure and do not commit it to version control.

For more detailed information, refer to the [official Google Cloud documentation](https://cloud.google.com/artifact-registry/docs/docker/store-docker-container-images).


