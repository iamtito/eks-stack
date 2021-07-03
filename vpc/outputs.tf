output "vpc_id" {
  description = "The ID of the VPC"
  value       = concat(aws_vpc.vpc.*.id, [""])[0]
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = concat(aws_vpc.vpc.*.arn, [""])[0]
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = concat(aws_vpc.vpc.*.cidr_block, [""])[0]
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = concat(aws_vpc.vpc.*.default_security_group_id, [""])[0]
}

output "default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = concat(aws_vpc.vpc.*.default_network_acl_id, [""])[0]
}

output "default_route_table_id" {
  description = "The ID of the default route table"
  value       = concat(aws_vpc.vpc.*.default_route_table_id, [""])[0]
}

output "vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within VPC"
  value       = concat(aws_vpc.vpc.*.instance_tenancy, [""])[0]
}

output "vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  value       = concat(aws_vpc.vpc.*.enable_dns_support, [""])[0]
}

output "vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  value       = concat(aws_vpc.vpc.*.enable_dns_hostnames, [""])[0]
}

output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = concat(aws_vpc.vpc.*.main_route_table_id, [""])[0]
}

output "vpc_ipv6_association_id" {
  description = "The association ID for the IPv6 CIDR block"
  value       = concat(aws_vpc.vpc.*.ipv6_association_id, [""])[0]
}

output "vpc_ipv6_cidr_block" {
  description = "The IPv6 CIDR block"
  value       = concat(aws_vpc.vpc.*.ipv6_cidr_block, [""])[0]
}

output "vpc_owner_id" {
  description = "The ID of the AWS account that owns the VPC"
  value       = concat(aws_vpc.vpc.*.owner_id, [""])[0]
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private.*.id
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = aws_subnet.private.*.arn
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = aws_subnet.private.*.cidr_block
}

output "private_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of private subnets in an IPv6 enabled VPC"
  value       = aws_subnet.private.*.ipv6_cidr_block
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public.*.id
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = aws_subnet.public.*.arn
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = aws_subnet.public.*.cidr_block
}

output "public_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of public subnets in an IPv6 enabled VPC"
  value       = aws_subnet.public.*.ipv6_cidr_block
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = aws_route_table.public.*.id
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = aws_route_table.private.*.id
}

output "public_internet_gateway_route_id" {
  description = "ID of the internet gateway route."
  value       = concat(aws_route.public_igw.*.id, [""])[0]
}

output "public_internet_gateway_ipv6_route_id" {
  description = "ID of the IPv6 internet gateway route."
  value       = concat(aws_route.public_igw_ipv6.*.id, [""])[0]
}

# output "private_nat_gateway_route_ids" {
#   description = "List of IDs of the private nat gateway route."
#   value       = aws_route.private_nat_gateway.*.id
# }

# output "private_ipv6_egress_route_ids" {
#   description = "List of IDs of the ipv6 egress route."
#   value       = aws_route.private_ipv6_egress.*.id
# }

output "private_route_table_association_ids" {
  description = "List of IDs of the private route table association"
  value       = aws_route_table_association.private.*.id
}

output "public_route_table_association_ids" {
  description = "List of IDs of the public route table association"
  value       = aws_route_table_association.public.*.id
}

output "nat_ids" {
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
  value       = aws_eip.nat.*.id
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = aws_eip.nat.*.public_ip
}

output "natgw_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.nat_gw.*.id
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = concat(aws_internet_gateway.igw.*.id, [""])[0]
}

output "igw_arn" {
  description = "The ARN of the Internet Gateway"
  value       = concat(aws_internet_gateway.igw.*.arn, [""])[0]
}

output "egress_only_internet_gateway_id" {
  description = "The ID of the egress only Internet Gateway"
  value       = concat(aws_egress_only_internet_gateway.egress_igw.*.id, [""])[0]
}

output "public_network_acl_id" {
  description = "ID of the public network ACL"
  value       = concat(aws_network_acl.public.*.id, [""])[0]
}

output "public_network_acl_arn" {
  description = "ARN of the public network ACL"
  value       = concat(aws_network_acl.public.*.arn, [""])[0]
}

output "vpc_endpoint_s3_id" {
  description = "The ID of VPC endpoint for S3"
  value       = concat(aws_vpc_endpoint.s3.*.id, [""])[0]
}

output "vpc_endpoint_s3_pl_id" {
  description = "The prefix list for the S3 VPC endpoint."
  value       = concat(aws_vpc_endpoint.s3.*.prefix_list_id, [""])[0]
}

output "vpc_endpoint_secretsmanager_id" {
  description = "The ID of VPC endpoint for secretsmanager"
  value       = concat(aws_vpc_endpoint.secretsmanager.*.id, [""])[0]
}

output "vpc_endpoint_secretsmanager_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for secretsmanager."
  value       = flatten(aws_vpc_endpoint.secretsmanager.*.network_interface_ids)
}

output "vpc_endpoint_secretsmanager_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for secretsmanager."
  value       = flatten(aws_vpc_endpoint.secretsmanager.*.dns_entry)
}

output "vpc_endpoint_ssm_id" {
  description = "The ID of VPC endpoint for SSM"
  value       = concat(aws_vpc_endpoint.ssm.*.id, [""])[0]
}

output "vpc_endpoint_ssm_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for SSM."
  value       = flatten(aws_vpc_endpoint.ssm.*.network_interface_ids)
}

output "vpc_endpoint_ssm_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for SSM."
  value       = flatten(aws_vpc_endpoint.ssm.*.dns_entry)
}

output "vpc_endpoint_apigw_id" {
  description = "The ID of VPC endpoint for APIGW"
  value       = concat(aws_vpc_endpoint.apigw.*.id, [""])[0]
}

output "vpc_endpoint_apigw_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for APIGW."
  value       = flatten(aws_vpc_endpoint.apigw.*.network_interface_ids)
}

output "vpc_endpoint_apigw_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for APIGW."
  value       = flatten(aws_vpc_endpoint.apigw.*.dns_entry)
}

output "vpc_endpoint_sqs_id" {
  description = "The ID of VPC endpoint for SQS"
  value       = concat(aws_vpc_endpoint.sqs.*.id, [""])[0]
}

output "vpc_endpoint_sqs_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for SQS."
  value       = flatten(aws_vpc_endpoint.sqs.*.network_interface_ids)
}

output "vpc_endpoint_sqs_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for SQS."
  value       = flatten(aws_vpc_endpoint.sqs.*.dns_entry)
}

output "vpc_cw_flow_log_id" {
  description = "The ID of the Cloudwatch Flow Log resource"
  value       = concat(aws_flow_log.cw_flow_log.*.id, [""])[0]
}

output "vpc_s3_flow_log_id" {
  description = "The ID of the S3 Flow Log resource"
  value       = concat(aws_flow_log.s3_flow_log.*.id, [""])[0]
}

output "vpc_flow_log_destination_arn" {
  description = "The ARN of the destination for VPC Flow Logs"
  value       = local.flow_log_destination_arn
}

output "vpc_flow_log_bucket_arn" {
  description = "The ARN of the destination for VPC Flow Logs"
  value       = concat(aws_s3_bucket.s3.*.arn, [""])[0]
}

output "vpc_flow_log_destination_type" {
  description = "The type of the destination for VPC Flow Logs"
  value       = var.flow_log_destination_type
}

output "vpc_flow_log_cloudwatch_iam_role_arn" {
  description = "The ARN of the IAM role used when pushing logs to Cloudwatch log group"
  value       = local.flow_log_iam_role_arn
}

output "availability_zones" {
  description = "A list of availability zones specified as argument to this module"
  value       = var.availability_zones
}

output "name" {
  description = "The name of the VPC specified as argument to this module"
  value       = var.name
}