###################
# Flow Log
###################

#####################
# Flow Log S3
#####################
resource "aws_flow_log" "s3_flow_log" {
  count                = local.create_flow_log_s3 ? 1 : 0
  log_destination      = aws_s3_bucket.s3[0].arn
  log_destination_type = var.flow_log_destination_type
  traffic_type         = var.flow_log_traffic_type
  vpc_id               = aws_vpc.vpc[0].id #local.vpc
  tags = merge(var.tags, var.vpc_flow_log_tags,
    {
      "Name" = format("%s", lower("aws.vpc.${var.name}.flow-logs"))
  }, )
}
resource "aws_s3_bucket" "s3" {
  count         = local.create_flow_log_s3 ? 1 : 0
  bucket        = lower("aws.vpc.${var.name}.flow-logs")
  acl           = "private"
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  policy = data.aws_iam_policy_document.flow_log_s3.json

  tags = merge(var.tags, var.vpc_flow_log_tags, {
    "Name" = format("%s", lower("aws.vpc.${var.name}.flow-logs"))
  }, )

  # depends_on = [aws_flow_log.flow_log]
}
#####################
# Flow Log CloudWatch
#####################
resource "aws_flow_log" "cw_flow_log" {
  count                    = local.create_flow_log_cloudwatch_log_group ? 1 : 0
  log_destination_type     = var.flow_log_destination_type
  log_destination          = local.flow_log_destination_arn
  log_format               = var.flow_log_log_format
  iam_role_arn             = local.flow_log_iam_role_arn
  traffic_type             = var.flow_log_traffic_type
  vpc_id                   = aws_vpc.vpc[0].id
  max_aggregation_interval = var.flow_log_max_aggregation_interval

  tags = merge(var.tags, var.vpc_flow_log_tags,
    {
      "Name" = format("%s", lower("aws.vpc.${var.name}.flow-logs"))
  }, )
}

resource "aws_cloudwatch_log_group" "flow_log" {
  count             = local.create_flow_log_cloudwatch_log_group ? 1 : 0
  name              = "${var.flow_log_cloudwatch_log_group_name_prefix}${aws_vpc.vpc[0].id}"
  retention_in_days = var.flow_log_cloudwatch_log_group_retention_in_days
  kms_key_id        = var.flow_log_cloudwatch_log_group_kms_key_id

  tags = merge(var.tags, var.vpc_flow_log_tags)
}

#########################
# Flow Log CloudWatch IAM
#########################
resource "aws_iam_role" "vpc_flow_log_cloudwatch" {
  count = local.create_flow_log_cloudwatch_iam_role ? 1 : 0

  name_prefix          = "vpc-flow-log-role-"
  assume_role_policy   = data.aws_iam_policy_document.flow_log_cloudwatch_assume_role[0].json
  permissions_boundary = var.vpc_flow_log_permissions_boundary

  tags = merge(var.tags, var.vpc_flow_log_tags)
}

resource "aws_iam_role_policy_attachment" "vpc_flow_log_cloudwatch" {
  count = local.create_flow_log_cloudwatch_iam_role ? 1 : 0

  role       = aws_iam_role.vpc_flow_log_cloudwatch[0].name
  policy_arn = aws_iam_policy.vpc_flow_log_cloudwatch[0].arn
}

resource "aws_iam_policy" "vpc_flow_log_cloudwatch" {
  count = local.create_flow_log_cloudwatch_iam_role ? 1 : 0

  name_prefix = "vpc-flow-log-to-cloudwatch-"
  policy      = data.aws_iam_policy_document.vpc_flow_log_cloudwatch[0].json
}
