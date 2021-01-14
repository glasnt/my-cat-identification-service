# My cat photo identification service.


## Provisioning and inital deployment

```
gcloud builds submit --tag gcr.io/${PROJECT_ID}/web-service web-service
terraform init
terraform apply
```

## Continuous Deployment

```
gcloud builds submit
```