# My cat photo service


To deploy this service onto Google Cloud, you will need to create a project and setup billing

## Automated way

Install Terraform

```
terraform init
terraform apply
```

## Manual way 

Install the gcloud CLI. 

Create a storage bucket: 

```
gsutil mb gs://${PROJECT_ID}-bucket
```

Upload images to the bucket. 

Then, to deploy the application, build the container image: 

```
gcloud builds submit --tag gcr.io/${PROJECT_ID}/helloworld .
```


And deploy the service with this new image:

```
gcloud run deploy helloworld \
   --platform managed \
   --image gcr.io/${PROJECT_ID}/helloworld \
   --update-env-vars TARGET=gcloud \
   --allow-unauthenticated 
```
