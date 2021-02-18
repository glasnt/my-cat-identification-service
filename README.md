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

    # Linux
    sed -i s/TFSTATE_BUCKET/${PROJECT_ID}-tfstate/g main.tf 

    # macOS
    sed -i "" s/TFSTATE_BUCKET/${PROJECT_ID}-tfstate/g main.tf
    ```

* (Optional) For a production use case, [create a service account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#adding-credentials) and enable the associated service: 

    ```
    gcloud service enable cloudresoursemanager.googleapis.com
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

## Configuration files


Terraform standard files: 

* `main.tf` - the main Terraform file
* `variables.tf` - declares variables
* `outputs.tf` - declares outputs

Custom files: 
* `project.tf` - the project level elements, including the IAM service account
* `function.tf` - the processing function, including the Cloud Function
* `service.tf` - the web service, including the Cloud Run service
* `media.tf` - the media assets, including the Cloud Storage bucket

## On error, reapply

Sometimes issues can occur where services are eventually consistant. If you encounter an error relating to services not being enabled, or resources not existing, try running terraform again before continuing.

## Check the version

This tutorial opts to use Cloud Builders for terraform, to prevent having to install terraform locally, or using an outdated version (this configuration uses syntax not available in the version available by default on Cloud Shell).

## State restoration

If state is lost, it can be recreated by importing the stateful elements, and deleting the stateless ones. For example:

```
terraform import -var project=${PROJECT_ID} google_storage_bucket.media ${PROJECT_ID}-media
terraform import -var project=${PROJECT_ID} google_storage_bucket.source ${PROJECT_ID}-source
gcloud functions delete processing-function
gcloud run services delete cats
```

Then run `terraform init && terraform apply` again. 

## Manifest development

If when developing the terraform manifest and state is complex, configure manually, then export settings using [terraformer](https://github.com/GoogleCloudPlatform/terraformer).

## Force re-deploy of service

```
gcloud builds submit
gcloud run deploy --image gcr.io/${PROJECT_ID}/cats
```

## Local debugging

Install functions framework, and run function locally:

```
cd function

virtualenv venv
source venv/bin/activate
pip install -r requirements.txt functions-framework

functions-framework --target detect_cat --debug
```

In another terminal, run service locally, refercing local function: 

```
cd service

virtualenv venv
source venv/bin/activate
pip install -r requirements.txt

BUCKET_NAME=${PROJECT_ID}-media FUNCTION_NAME=http://0.0.0.0:8080 PORT=8081 python app.py
```

Open website at [http://0.0.0.0:8081/](http://0.0.0.0:8081/)

# Learn more

 * [Managing Infrastructure as Code](https://cloud.google.com/solutions/managing-infrastructure-as-code)
 * [Processing images from Cloud Storage tutorial ](https://cloud.google.com/run/docs/tutorials/image-processing)
