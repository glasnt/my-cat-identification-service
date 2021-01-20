# My cat photo identification service

Uses Vision API to detect images in a Cloud Function. Renders a front end iterating on the contents of a bucket, calling aforementioned function.

## Provisioning and configuration setup

Requires a Google Cloud product with billing enabled. Presumes running with a project owner account. 

* [Download](https://www.terraform.io/downloads.html) and install Terraform for your platform. (For Cloud Shell, get the latest Linux 64-Bit zip URL)

    ```
    wget https://releases.hashicorp.com/terraform/0.14.4/terraform_0.14.4_linux_amd64.zip -o terraform.zip # Version may change
    unzip terraform.zip
    chmod +x terraform
    sudo mv terraform /usr/local/bin/
    ```

* Clone the source code
    ```
    git clone (this repo) cat_service
    cd cat_service
    ```

* Establish terraform state storage in your project
    ```
    PROJECT_ID=$(gcloud config get-value project)
    gsutil mb gs://${PROJECT_ID}-tfstate
    gsutil versioning set on gs://${PROJECT_ID}-tfstate
    sed -i s/TFSTATE_BUCKET/${PROJECT_ID}-tfstate/g main.tf
    ```

## Build the base service container

```
gcloud builds submit
```

## Apply Terraform
```
terraform init
terraform apply
```

---

# General Terraform tips

### On error, reapply

Sometimes issues can occur where services are eventually consistant. If you encounter an error relating to services not being enabled, or resources not existing, try running terraform again before continuing.

### Check the version

This tutorial opts to use Cloud Builders for terraform, to prevent having to install terraform locally, or using an outdated version (this configuration uses syntax not available in the version available by default on Cloud Shell).

### State restoration

If state is lost, it can be recreated by importing the stateful elements, and deleting the stateless ones. For example:

```
terraform import -var project=${PROJECT_ID} google_storage_bucket.media ${PROJECT_ID}-media
terraform import -var project=${PROJECT_ID} google_storage_bucket.source ${PROJECT_ID}-source
gcloud functions delete processing-function
gcloud run services delete cats
```

Then run `terraform init && terraform apply` again. 

### Manifest development

If when developing the terraform manifest and state is complex, configure manually, then export settings using [terraformer](https://github.com/GoogleCloudPlatform/terraformer).


# Learn more

 * https://cloud.google.com/solutions/managing-infrastructure-as-code
