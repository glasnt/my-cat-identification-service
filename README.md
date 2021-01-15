# My cat photo identification service.


## Provisioning and inital deployment

Establish terraform state storage

```
PROJECT_ID=$(gcloud config get-value project)
gsutil mb gs://${PROJECT_ID}-tfstate
gsutil versioning set on gs://${PROJECT_ID}-tfstate
```


Set terraform configuration with state location

```
sed -i s/TFSTATE_BUCKET/${PROJECT_ID}-tfstate/g main.tf
```

```
gcloud builds submit --tag gcr.io/${PROJECT_ID}/web-service web-service
terraform init
terraform apply
```

## Continuous Deployment

Allow Cloud Build editor access

```
gcloud services enable cloudbuild.googleapis.com compute.googleapis.com cloudresourcemanager.googleapis.com

CLOUDBUILD_SA="$(gcloud projects describe $PROJECT_ID \
    --format 'value(projectNumber)')@cloudbuild.gserviceaccount.com"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$CLOUDBUILD_SA --role roles/editor
```

```
gcloud builds submit
```

## Hints

If state is lost, it can be recreated by importing the stateful elements, and deleting the stateless ones:

```
terraform import -var PROJECT_ID google_storage_bucket.media PROJECT_ID-media
terraform import -var PROJECT_ID google_storage_bucket.source PROJECT_ID-source
gcloud functions delete processing-function
gcloud run services delete cats
```

Then init/apply again. 
