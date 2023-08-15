# cp-terraform-gcp
Terraform for CP on GCP

edit terraform.tfvars and set your service account (1), resources owner name (2), a free subnetwork CIDR range (3),
network name (4) and enable access to your computer IP address (5)
```
project_id = "solutionsarchitect-01"
service_acct_email = "vcosqui-terraform-account@solutionsarchitect-01.iam.gserviceaccount.com" (1)
subnet_project = "demo"
vpc_cidr = "10.0.0.0/8"
subnet_cidr = "10.11.0.0/16" (3)
owner_name = "vcosqui" (2)
network_name = "vcosqui-vpc" (4)
region = "europe-west1"
zone = "europe-west1-c"
external_source_ranges = ["213.77.180.0/24", "90.75.217.0/24", "139.47.73.78/32"] (5)
```

get service account credentials json
```shell
gcloud iam service-accounts keys create gcloud-key.json --iam-account=vcosqui-terraform-account@solutionsarchitect-01.iam.gserviceaccount.com
```

grant service account project editor role
```shell
gcloud projects add-iam-policy-binding solutionsarchitect-01 --member='serviceAccount:vcosqui-terraform-account@solutionsarchitect-01.iam.gserviceaccount.com' --role='roles/editor'
```

create keys to connect via ssh
```shell
 ssh-keygen -t rsa
 cp ~/.ssh/id_rsa.pub .
```

run terraform init and apply
```shell
terraform init
terraform apply
```