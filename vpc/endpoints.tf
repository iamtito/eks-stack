######################
# VPC Endpoint for S3
######################
data "aws_vpc_endpoint_service" "s3" {
  count = var.enable_s3_endpoint ? 1 : 0

  service = "s3"
}

resource "aws_vpc_endpoint" "s3" {
  count        = var.enable_s3_endpoint ? 1 : 0
  vpc_id       = aws_vpc.vpc[0].id
  service_name = data.aws_vpc_endpoint_service.s3[0].service_name
  tags = merge(local.vpce_tags,
    {
      "Name"     = "${title(var.name)} Private Subnet S3 Endpoint"
      "Subnet"   = "Private"
      "Endpoint" = "S3"
  })
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count = var.enable_s3_endpoint && var.enable_private_s3_endpoint ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = element(aws_route_table.private.*.id, count.index)
}


resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count = var.enable_s3_endpoint && var.enable_public_s3_endpoint ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = aws_route_table.public[0].id
}

#######################
# VPC Endpoint for SQS
#######################
data "aws_vpc_endpoint_service" "sqs" {
  count   = var.enable_sqs_endpoint ? 1 : 0
  service = "sqs"
}

resource "aws_vpc_endpoint" "sqs" {
  count               = var.enable_sqs_endpoint ? 1 : 0
  vpc_id              = aws_vpc.vpc[0].id
  service_name        = data.aws_vpc_endpoint_service.sqs[0].service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids  = local.sqs_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.sqs_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.sqs_endpoint_private_dns_enabled
  tags = merge(local.vpce_tags,
    {
      "Name"     = "${title(var.name)} Private Subnet SQS Endpoint"
      "Subnet"   = "Private"
      "Endpoint" = "SQS"
  })
}

#########################
# VPC Endpoint for Lambda
#########################
data "aws_vpc_endpoint_service" "lambda" {
  count   = var.enable_lambda_endpoint ? 1 : 0
  service = "lambda"
}
resource "aws_vpc_endpoint" "lambda" {
  count              = var.enable_lambda_endpoint ? 1 : 0
  vpc_id             = aws_vpc.vpc[0].id
  service_name       = data.aws_vpc_endpoint_service.lambda[0].service_name
  vpc_endpoint_type  = "Interface"
  security_group_ids = local.lambda_endpoint_security_group_ids #[aws_default_security_group.vpc_default_sg[0].id] 
  # subnet_ids          = coalescelist(var.lambda_endpoint_subnet_ids, aws_subnet.private.*.id) ## Lambda is not available in us-east-1[d-f]
  subnet_ids          = [aws_subnet.private[0].id, aws_subnet.private[1].id, aws_subnet.private[2].id]
  private_dns_enabled = var.lambda_endpoint_private_dns_enabled
  tags = merge(local.vpce_tags,
    {
      "Name"     = "${title(var.name)} Private Subnet Lambda Endpoint"
      "Subnet"   = "Private"
      "Endpoint" = "Lambda"
  })
}

###################################
# VPC Endpoint for Secrets Manager
###################################
data "aws_vpc_endpoint_service" "secretsmanager" {
  count   = var.enable_secretsmanager_endpoint ? 1 : 0
  service = "secretsmanager"
}

resource "aws_vpc_endpoint" "secretsmanager" {
  count               = var.enable_secretsmanager_endpoint ? 1 : 0
  vpc_id              = aws_vpc.vpc[0].id
  service_name        = data.aws_vpc_endpoint_service.secretsmanager[0].service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids  = local.secretsmanager_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.secretsmanager_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.secretsmanager_endpoint_private_dns_enabled
  tags = merge(local.vpce_tags,
    {
      "Name"     = "${title(var.name)} Private Subnet Secretsmanager Endpoint"
      "Subnet"   = "Private"
      "Endpoint" = "Secretsmanager"
    }
  )
}

#######################
# VPC Endpoint for SSM
#######################
data "aws_vpc_endpoint_service" "ssm" {
  count   = var.enable_ssm_endpoint ? 1 : 0
  service = "ssm"
}

resource "aws_vpc_endpoint" "ssm" {
  count               = var.enable_ssm_endpoint ? 1 : 0
  vpc_id              = aws_vpc.vpc[0].id
  service_name        = data.aws_vpc_endpoint_service.ssm[0].service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids  = local.ssm_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.ssm_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.ssm_endpoint_private_dns_enabled
  tags = merge(local.vpce_tags,
    {
      "Name"     = "${title(var.name)} Private Subnet SSM Endpoint"
      "Subnet"   = "Private"
      "Endpoint" = "SSM"
    }
  )
}

#######################
# VPC Endpoint for API Gateway
#######################
data "aws_vpc_endpoint_service" "apigw" {
  count = var.enable_apigw_endpoint ? 1 : 0

  service = "execute-api"
}

resource "aws_vpc_endpoint" "apigw" {
  count = var.enable_apigw_endpoint ? 1 : 0

  vpc_id            = aws_vpc.vpc[0].id
  service_name      = data.aws_vpc_endpoint_service.apigw[0].service_name
  vpc_endpoint_type = "Interface"

  security_group_ids  = var.apigw_endpoint_security_group_ids
  subnet_ids          = coalescelist(var.apigw_endpoint_subnet_ids, aws_subnet.private.*.id)
  private_dns_enabled = var.apigw_endpoint_private_dns_enabled
  tags                = local.vpce_tags
}
