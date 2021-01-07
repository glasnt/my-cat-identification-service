# My cat photo identification service.


## Deployment

* Create a Google Cloud Project with active Billing
  * `PROJECT_ID=(yourproject)
* Create a service account
* Prepare Cloud Run service - Build a base container image
  * `gcloud builds submit --tag gcr.io/${PROJECT_ID}/web-service web-service`
* Prepare Cloud Function - Bundle the function code
  * `zip processing-function.zip processing-function/*`
* Run terraform

## Automated way

Install Terraform

```
terraform init
terraform apply
```

## Manual way 

gcloud buidls usbmit 

terraform apply

upload zipfile to bucket?