################
# Public subnet
################
resource "aws_subnet" "public" {
  #   count = var.create_vpc && length(var.public_subnets) > 0 && (false == var.one_nat_gateway_per_az || length(var.public_subnets) >= length(var.azs)) ? length(var.public_subnets) : 0
  count                           = local.public_count
  vpc_id                          = aws_vpc.vpc[0].id
  cidr_block                      = var.public_cidrsubnet != "" ? cidrsubnet(var.public_cidrsubnet, 8, count.index) : element(concat(var.public_subnets, [""]), count.index)
  availability_zone               = element(var.availability_zones, count.index)
  map_public_ip_on_launch         = var.map_public_ip_on_launch
  assign_ipv6_address_on_creation = var.public_subnet_assign_ipv6_address_on_creation == null ? var.assign_ipv6_address_on_creation : var.public_subnet_assign_ipv6_address_on_creation

  ipv6_cidr_block = var.enable_ipv6 && length(var.public_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.vpc[0].ipv6_cidr_block, 8, var.public_subnet_ipv6_prefixes[count.index]) : null

  tags = merge(
    {
      "Name" = format(
        "%s-${var.public_subnet_suffix}-%s",
        var.name,
        element(var.availability_zones, count.index),
      )
    },
    var.tags,
    var.public_subnet_tags,
  )
  depends_on = [aws_vpc.vpc]
}
########################
# Public Network ACLs
########################
# Default: False
## 
resource "aws_network_acl" "public" {
  count = var.public_dedicated_network_acl && (length(var.public_subnets) > 0 || var.public_cidrsubnet != "") ? 1 : 0

  vpc_id     = aws_vpc.vpc[0].id
  subnet_ids = aws_subnet.public.*.id
  dynamic "egress" {
    for_each = var.public_network_acl_egress
    content {
      action          = lookup(egress.value, "action", null)
      cidr_block      = lookup(egress.value, "cidr_block", null)
      from_port       = lookup(egress.value, "from_port", null)
      icmp_code       = lookup(egress.value, "icmp_code", null)
      icmp_type       = lookup(egress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(egress.value, "ipv6_cidr_block", null)
      protocol        = lookup(egress.value, "protocol", null)
      rule_no         = lookup(egress.value, "rule_no", null)
      to_port         = lookup(egress.value, "to_port", null)
    }
  }
  dynamic "ingress" {
    for_each = var.public_network_acl_ingress
    content {
      action          = lookup(ingress.value, "action", null)
      cidr_block      = lookup(ingress.value, "cidr_block", null)
      from_port       = lookup(ingress.value, "from_port", null)
      icmp_code       = lookup(ingress.value, "icmp_code", null)
      icmp_type       = lookup(ingress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(ingress.value, "ipv6_cidr_block", null)
      protocol        = lookup(ingress.value, "protocol", null)
      rule_no         = lookup(ingress.value, "rule_no", null)
      to_port         = lookup(ingress.value, "to_port", null)
    }
  }
  tags = merge(
    var.tags,
    var.public_network_acl_tags,
    {
      "Name" = format("%s-${var.public_subnet_suffix}", var.name)
    },
  )
  depends_on = [aws_subnet.public]
}

################
# Publiс routes
################
resource "aws_route_table" "public" {
  count  = local.public_subnet ? 1 : 0 #local.public_count
  vpc_id = aws_vpc.vpc[0].id
  tags = merge(
    var.tags,
    var.public_route_table_tags,
    {
      "Name" = format("%s-${var.public_subnet_suffix}", var.name)
    },
  )
}

resource "aws_route" "public_igw" {
  count                  = var.enable_igw && local.public_subnet ? 1 : 0 #length(var.availability_zones) : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
  timeouts {
    create = var.public_igw_timeout
  }
}

resource "aws_route" "public_igw_ipv6" {
  count = var.enable_igw && var.enable_ipv6 && local.public_subnet ? 1 : 0

  route_table_id              = aws_route_table.public[0].id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.igw[0].id
}

resource "aws_route_table_association" "public" {
  count          = local.public_count
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
  depends_on = [
    aws_subnet.public,
    aws_route_table.public,
  ]
}
