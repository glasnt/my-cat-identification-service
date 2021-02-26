# My cat photo identification service

[![Open in Cloud Shell][shell_img]][shell_link]

[shell_img]: http://gstatic.com/cloudssh/images/open-btn.png
[shell_link]: https://console.cloud.google.com/cloudshell/open?git_repo=https://github.com/GoogleCloudPlatform/serverless-expeditions&page=editor&open_in_editor=terraform-serverless/README.md


To deploy using Terraform:

 * Create a new project on Google Cloud with [billing enabled](https://cloud.google.com/billing/docs/how-to/modify-project), and open [Cloud Shell](https://cloud.google.com/shell/docs/using-cloud-shell).
 * Clone this repo: 

    ```shell
    git clone https://github.com/GoogleCloudPlatform/serverless-expeditions 
    cd serverless-expeditions/terraform-serverless
    ```

  * Build the base service container:

    ```
    gcloud builds submit
    ```

  * Initialise and apply the Terraform manifests: 

    ```
    terraform init
    terraform apply
    ```

See [Infrastructure](infrastructure.md) for more details of this demo. 


## Learn more

 * [Managing Infrastructure as Code](https://cloud.google.com/solutions/managing-infrastructure-as-code)
 * [Processing images from Cloud Storage tutorial ](https://cloud.google.com/run/docs/tutorials/image-processing)
