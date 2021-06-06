################### VPC ##################################
## Create the VPC where the EKS Cluster will be deployed #
##########################################################
module "vpc" {
    source = "../vpc/"
    cidr = "10.32.0.0/16"
    name = "interview-vpc"
    private_subnets = ["10.32.0.0/24","10.32.1.0/24"]
    public_subnets = ["10.32.10.0/24","10.32.11.0/24"]
    availability_zones = ["us-east-1a","us-east-1b"]
    public_subnet_tags = {
        "kubernetes.io/cluster/${local.cluster_name}" = "shared"
        "kubernetes.io/role/elb"                      = "1"
    }

    private_subnet_tags = {
        "kubernetes.io/cluster/${local.cluster_name}" = "shared"
        "kubernetes.io/role/internal-elb"             = "1"
    }
}

########## IAMPolicy ###########
## Worker node policy          #
################################
resource "aws_iam_policy" "worker_policy" {
  name        = "worker-policy"
  description = "Worker policy for the ALB Ingress"

  policy = file("iam-policy.json")
}

################### EKS Cluster ####################################
## Create the an eks cluster in the newley created vpc and attache #
## the policy to the worker nodes                                  #
####################################################################
## Locking down the remove source to a specific version
## Locking it down to a specif version prevents infrastructure drift incase the remote
## module gets updated
module "eks" {
  source       = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=v12.1.0"
  cluster_name = local.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnets      = module.vpc.public_subnets

  node_groups = {
    eks_nodes = {
      desired_capacity = 3
      max_capacity     = 3
      min_capaicty     = 3

      instance_type = "t2.small"
    }
  }
  workers_additional_policies = [aws_iam_policy.worker_policy.arn]

  manage_aws_auth = false
#   write_kubeconfig   = true
#   config_output_path = "./"
}

################### HELM ######################################
## HELM Release that need to be deploy                        #
###############################################################
## Create an instance of helm running in the kubernetes cluster
## Add aws-alb-ingress-controller
resource "helm_release" "ingress" {
  name       = "ingress"
  chart      = "aws-alb-ingress-controller"
  repository = "incubator"

  set {
    name  = "autoDiscoverAwsRegion"
    value = "true"
  }
  set {
    name  = "autoDiscoverAwsVpcID"
    value = "true"
  }
  set {
    name  = "clusterName"
    value = local.cluster_name
  }
}


################## Optional ######################################
## Deploying the Grafana/Prometheus monitoring stack             #
## Explanation:                                                  # 
## I think it would be nice to deploy the entire monitoring      #
## stack as the infrastructure gets created without having       #
## to wait for helm deployment, basically its more like          #
## terraform helm deployment into a newly created infrastructure #
##################################################################
# data "helm_repository" "prometheus" {
#   name = "prometheus-community"
#   url = "https://prometheus-community.github.io/helm-charts"
# }
# resource "helm_release" "prometheus" {
#   name       = "prometheus"
#   chart      = "prometheus-community/kube-prometheus-stack"
#   repository = data.helm_repository.prometheus.metadata[0].name

#   set {
#     name  = "grafana.ingress.enable"
#     value = "true"
#   }
#   set {
#     name  = "grafana.ingress.annotations.kubernetes.io/ingress.class"
#     value = "alb"
#   }
#   set {
#     name  = "grafana.ingress.annotations.kubernetes.io/target-type"
#     value = "ip"
#   }
#   set {
#     name  = "grafana.ingress.annotations.kubernetes.io/scheme"
#     value = "internet-facing"
#   }
#   set {
#     name  = "grafana.ingress.annotations.kubernetes.io/success-codes"
#     value = "200,302"
#   }
#   set {
#     name  = "grafana.ingress.hosts"
#     value = ""
#   }
#   set {
#     name  = "grafana.ingress.path"
#     value = "/*"
#   }
# }