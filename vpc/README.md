### USAGE

```
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
    source = "../vpc/"
    name = "eks-vpc"
    cidr = "10.32.0.0/16"
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
```

### Module Diagram

![vpc](vpc.png)
