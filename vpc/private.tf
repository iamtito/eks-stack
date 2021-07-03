resource "aws_subnet" "private" {
  count  = local.private_count #var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  vpc_id = aws_vpc.vpc[0].id
  # cidr_block                      = var.private_subnets[count.index]
  cidr_block        = var.private_cidrsubnet != [""] ? cidrsubnet(var.private_cidrsubnet, 8, count.index) : element(concat(var.private_subnets, [""]), count.index)
  availability_zone = element(var.availability_zones, count.index)
  # availability_zone               = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  # availability_zone_id            = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null
  assign_ipv6_address_on_creation = var.private_subnet_assign_ipv6_address_on_creation == null ? var.assign_ipv6_address_on_creation : var.private_subnet_assign_ipv6_address_on_creation

  ipv6_cidr_block = var.enable_ipv6 && length(var.private_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.vpc[0].ipv6_cidr_block, 8, var.private_subnet_ipv6_prefixes[count.index]) : null

  tags = merge(
    var.tags,
    var.private_subnet_tags,
    {
      "Name" = format(
        "%s-${var.private_subnet_suffix}-%s",
        var.name,
        element(var.availability_zones, count.index),
      )
    },
  )
}

#################
# Private routes
# There are as many routing tables as the number of NAT gateways
#################
resource "aws_route_table" "private" {
  count = var.enable_private_rt ? 1 : 0 #&& (length(var.private_subnets) > 0 || var.private_cidrsubnet != "") ? length(var.availability_zones) : 0

  vpc_id = aws_vpc.vpc[0].id

  tags = merge(
    var.tags,
    var.private_route_table_tags,
    {
      "Name" = format("%s-${var.private_subnet_suffix}", var.name)
    },
  )
}

resource "aws_route_table_association" "private" {
  #   count          = local.private_count
  count          = var.enable_private_rt && (length(var.private_subnets) > 0 || var.private_cidrsubnet != "") ? length(var.availability_zones) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
  depends_on = [
    aws_subnet.private,
    aws_route_table.private,
  ]
}
