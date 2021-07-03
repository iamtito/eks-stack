resource "aws_vpc" "vpc" {
  count                            = var.enable_vpc ? 1 : 0
  cidr_block                       = var.cidr
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  enable_classiclink               = var.enable_classiclink
  enable_classiclink_dns_support   = var.enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(
    var.tags,
    var.vpc_tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}


resource "aws_default_network_acl" "default" {
  count = var.enable_vpc && var.manage_default_network_acl ? 1 : 0

  default_network_acl_id = element(concat(aws_vpc.vpc.*.default_network_acl_id, [""]), 0)

  # The value of subnet_ids should be any subnet IDs that are not set as subnet_ids
  #   for any of the non-default network ACLs
  subnet_ids = compact(flatten([aws_subnet.public.*.id, aws_subnet.private.*.id, ]))

  dynamic "ingress" {
    for_each = var.default_network_acl_ingress
    content {
      action          = ingress.value.action
      cidr_block      = lookup(ingress.value, "cidr_block", null)
      from_port       = ingress.value.from_port
      icmp_code       = lookup(ingress.value, "icmp_code", null)
      icmp_type       = lookup(ingress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(ingress.value, "ipv6_cidr_block", null)
      protocol        = ingress.value.protocol
      rule_no         = ingress.value.rule_no
      to_port         = ingress.value.to_port
    }
  }
  dynamic "egress" {
    for_each = var.default_network_acl_egress
    content {
      action          = egress.value.action
      cidr_block      = lookup(egress.value, "cidr_block", null)
      from_port       = egress.value.from_port
      icmp_code       = lookup(egress.value, "icmp_code", null)
      icmp_type       = lookup(egress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(egress.value, "ipv6_cidr_block", null)
      protocol        = egress.value.protocol
      rule_no         = egress.value.rule_no
      to_port         = egress.value.to_port
    }
  }

  tags = merge(
    var.tags,
    var.default_network_acl_tags,
    {
      "Name" = format("%s ACL", title(var.name))
    },
  )
}

resource "aws_network_acl" "acl" {
  count = var.add_network_acl ? 1 : 0

  vpc_id = local.vpc

  dynamic "ingress" {
    for_each = var.network_acl_ingress
    content {
      action          = ingress.value.action
      cidr_block      = lookup(ingress.value, "cidr_block", null)
      from_port       = ingress.value.from_port
      icmp_code       = lookup(ingress.value, "icmp_code", null)
      icmp_type       = lookup(ingress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(ingress.value, "ipv6_cidr_block", null)
      protocol        = ingress.value.protocol
      rule_no         = ingress.value.rule_no
      to_port         = ingress.value.to_port
    }
  }
  dynamic "egress" {
    for_each = var.network_acl_egress
    content {
      action          = egress.value.action
      cidr_block      = lookup(egress.value, "cidr_block", null)
      from_port       = egress.value.from_port
      icmp_code       = lookup(egress.value, "icmp_code", null)
      icmp_type       = lookup(egress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(egress.value, "ipv6_cidr_block", null)
      protocol        = egress.value.protocol
      rule_no         = egress.value.rule_no
      to_port         = egress.value.to_port
    }
  }

  tags = merge(
    var.tags,
    var.network_acl_tags,
    {
      "Name" = format("%s", var.network_acl_name)
    },
  )
}

######################
## Internet Gateway ##
######################
# Default: True
# An internet gateway is a horizontally scaled, redundant, and highly available VPC component that enables communication between your VPC and the internet.
# https://docs.aws.amazon.com/en_us/console/vpc/internet-gateways
resource "aws_internet_gateway" "igw" {
  count  = var.enable_igw ? 1 : 0
  vpc_id = aws_vpc.vpc[0].id
  tags = merge(
    var.tags,
    var.igw_tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}

# Default: False
# An egress-only internet gateway is for use with IPv6 traffic only. To enable outbound-only internet communication over IPv4, use a NAT gateway instead.
# https://docs.aws.amazon.com/vpc/latest/userguide/egress-only-internet-gateway.html
resource "aws_egress_only_internet_gateway" "egress_igw" {
  count  = var.enable_egress_only_igw && var.enable_ipv6 ? 1 : 0
  vpc_id = aws_vpc.vpc[0].id
  tags = merge(
    var.tags,
    var.igw_tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}

#####################
# DHCP Options Set ##
#####################
# Default: True
# The Dynamic Host Configuration Protocol (DHCP) provides a standard for passing configuration information to hosts on a TCP/IP network
# https://docs.aws.amazon.com/en_us/console/vpc/dhcp-options-sets
resource "aws_vpc_dhcp_options" "dhcp" {
  count = var.enable_dhcp_options ? 1 : 0

  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
    var.dhcp_options_tags,
  )
}

#################################
# DHCP Options Set Association ##
#################################
resource "aws_vpc_dhcp_options_association" "dhcp_associate" {
  count           = var.enable_dhcp_options ? 1 : 0
  vpc_id          = aws_vpc.vpc[0].id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp[0].id
}

####################
## NAT
########
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? local.public_nat_gateways_count : 0

  vpc = true

  tags = merge(
    var.tags,
    var.nat_eip_tags,
    {
      "Name" = format("%s-%s", var.name, element(var.availability_zones, count.index), )
    },
  )
}

resource "aws_nat_gateway" "nat_gw" {
  count = var.enable_nat_gateway ? local.public_nat_gateways_count : 0

  allocation_id = element(local.nat_gateway_ips, var.single_nat_gateway ? 0 : count.index, )
  subnet_id     = element(aws_subnet.public.*.id, var.single_nat_gateway ? 0 : count.index, )

  tags = merge(
    var.tags,
    var.nat_gateway_tags,
    {
      "Name"              = format("%s-%s", var.name, element(var.availability_zones, var.single_nat_gateway ? 0 : count.index), )
      "Availability_Zone" = element(var.availability_zones, count.index)
    },
  )

  depends_on = [aws_internet_gateway.igw]
}


####################
## Security Group
######
resource "aws_default_security_group" "vpc_default_sg" {
  count = var.enable_vpc && var.manage_default_security_group ? 1 : 0

  vpc_id = aws_vpc.vpc[0].id

  dynamic "ingress" {
    for_each = var.default_security_group_ingress
    content {
      self             = lookup(ingress.value, "self", true)
      cidr_blocks      = compact(split(",", lookup(ingress.value, "cidr_blocks", "")))
      ipv6_cidr_blocks = compact(split(",", lookup(ingress.value, "ipv6_cidr_blocks", "")))
      prefix_list_ids  = compact(split(",", lookup(ingress.value, "prefix_list_ids", "")))
      security_groups  = compact(split(",", lookup(ingress.value, "security_groups", "")))
      description      = lookup(ingress.value, "description", null)
      from_port        = lookup(ingress.value, "from_port", 0)
      to_port          = lookup(ingress.value, "to_port", 0)
      protocol         = lookup(ingress.value, "protocol", "-1")
    }
  }

  dynamic "egress" {
    for_each = var.default_security_group_egress
    content {
      self             = lookup(egress.value, "self", null)
      cidr_blocks      = compact(split(",", lookup(egress.value, "cidr_blocks", "")))
      ipv6_cidr_blocks = compact(split(",", lookup(egress.value, "ipv6_cidr_blocks", "")))
      prefix_list_ids  = compact(split(",", lookup(egress.value, "prefix_list_ids", "")))
      security_groups  = compact(split(",", lookup(egress.value, "security_groups", "")))
      description      = lookup(egress.value, "description", null)
      from_port        = lookup(egress.value, "from_port", 0)
      to_port          = lookup(egress.value, "to_port", 0)
      protocol         = lookup(egress.value, "protocol", "-1")
    }
  }

  tags = merge(
    {
      "Name" = format("%s %s VPC", var.name, var.default_security_group_name, )
    },
    var.tags,
    var.default_security_group_tags,
  )
}
