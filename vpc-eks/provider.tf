provider "aws" {
  region = "us-east-1"
}

# provider "helm" {
#   kubernetes {
#     host                   = data.aws_eks_cluster.cluster.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#     token                  = data.aws_eks_cluster_auth.cluster.token
#     # load_config_file       = false
#   }
# }

#### Store the state file to S3 Bucket #####
terraform {
    backend "s3" {
        bucket = "kabirinfrastructurexyz"
        key = "interview-infrastructure.tfstate"
        region = "us-east-1"
        encrypt = "true"
    }
}