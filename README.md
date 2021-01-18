# My cat photo identification service

Uses Vision API to detect images in a Cloud Function. Renders a front end iterating on the contents of a bucket, calling aforementioned function.

## Provisioning and inital deployment

Establish terraform state storage

```
PROJECT_ID=$(gcloud config get-value project)
gsutil mb gs://${PROJECT_ID}-tfstate
gsutil versioning set on gs://${PROJECT_ID}-tfstate
```

Set terraform configuration with state location

```
sed -i "" s/TFSTATE_BUCKET/${PROJECT_ID}-tfstate/g main.tf
```

Build base container image, and apply terraform

```
gcloud builds submit --tag gcr.io/${PROJECT_ID}/web-service web-service
terraform init
terraform apply
```

## Continuous Deployment

Allow Cloud Build editor access

```
gcloud services enable \
    cloudbuild.googleapis.com \
    compute.googleapis.com \
    cloudresourcemanager.googleapis.com

CLOUDBUILD_SA="$(gcloud projects describe $PROJECT_ID --format 'value(projectNumber)')@cloudbuild.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$CLOUDBUILD_SA --role roles/editor
```

Run the build

```
gcloud builds submit
```

## General Terraform tips


### State restoration

If state is lost, it can be recreated by importing the stateful elements, and deleting the stateless ones. For example:

```
terraform import -var PROJECT_ID google_storage_bucket.media PROJECT_ID-media
terraform import -var PROJECT_ID google_storage_bucket.source PROJECT_ID-source
gcloud functions delete processing-function
gcloud run services delete cats
```

### Manifest development

If when developing the terraform manifest and state is complex, configure manually, then export settings using [terraformer](https://github.com/GoogleCloudPlatform/terraformer).