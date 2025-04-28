########## Start AWS VPC and Network Configurations Resources ##########
# # ## VPC resource - Create only if vpc_id is not provided
# locals {
#   # Determine if a new VPC should be created
#   create_vpc = var.vpc_id == null
#   create_igw = var.internet_gateway_id == null
# }
# resource "aws_vpc" "this" {
#   for_each = local.create_vpc ? { "vpc" = true } : {}

#   cidr_block = var.vpc_range
#   tags = {
#     Name = "${var.site_name}-VPC"
#   }
# }
# data "aws_vpc" "existing" {
#   count = var.vpc_id != null ? 1 : 0
#   id    = var.vpc_id
# }

# Lookup data from region and VPC - Always needed for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Subnets
resource "aws_subnet" "mgmt_subnet" {
  # vpc_id            = local.create_vpc ? aws_vpc.this["vpc"].id : var.vpc_id
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_range_mgmt
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.site_name}-MGMT-Subnet"
  }
}

resource "aws_subnet" "wan_subnet" {
  # vpc_id            = local.create_vpc ? aws_vpc.this["vpc"].id : var.vpc_id
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_range_wan
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.site_name}-WAN-Subnet"
  }
}

resource "aws_subnet" "lan_subnet_primary" {
  # vpc_id            = local.create_vpc ? aws_vpc.this["vpc"].id : var.vpc_id
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_range_lan_primary
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.site_name}-LAN-Subnet-Primary"
  }
}

resource "aws_subnet" "lan_subnet_secondary" {
  # vpc_id            = local.create_vpc ? aws_vpc.this["vpc"].id : var.vpc_id
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_range_lan_secondary
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.site_name}-LAN-Subnet-Secondary"
  }
}


# Internal and External Security Groups
resource "aws_security_group" "internal_sg" {
  name        = "${var.site_name}-Internal-SG"
  description = "CATO LAN Security Group - Allow all traffic Inbound"
  # vpc_id            = local.create_vpc ? aws_vpc.this["vpc"].id : var.vpc_id
  vpc_id = var.vpc_id
  ingress = [
    {
      description      = "Allow all traffic Inbound from Ingress CIDR Blocks"
      protocol         = -1
      from_port        = 0
      to_port          = 0
      cidr_blocks      = var.ingress_cidr_blocks
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
  egress = [
    {
      description      = "Allow all traffic Outbound"
      protocol         = -1
      from_port        = 0
      to_port          = 0
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
  tags = {
    name = "${var.site_name}-Internal-SG"
  }
}

resource "aws_security_group" "external_sg" {
  name        = "${var.site_name}-External-SG"
  description = "CATO WAN Security Group - Allow HTTPS In"
  # vpc_id            = local.create_vpc ? aws_vpc.this["vpc"].id : var.vpc_id
  vpc_id = var.vpc_id
  ingress = [
    {
      description      = "Allow HTTPS In"
      protocol         = "tcp"
      from_port        = 443
      to_port          = 443
      cidr_blocks      = var.ingress_cidr_blocks
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "Allow SSH In"
      protocol         = "tcp"
      from_port        = 22
      to_port          = 22
      cidr_blocks      = var.ingress_cidr_blocks
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
  egress = [
    {
      description      = "Allow all traffic Outbound"
      protocol         = -1
      from_port        = 0
      to_port          = 0
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
  tags = {
    name = "${var.site_name}-External-SG"
  }
}

# vSocket Network Interfaces
resource "aws_network_interface" "mgmteni_primary" {
  source_dest_check = "true"
  subnet_id         = aws_subnet.mgmt_subnet.id
  private_ips       = [var.mgmt_eni_primary_ip]
  security_groups   = [aws_security_group.external_sg.id]
  tags = {
    Name = "${var.site_name}-MGMT-INT-Primary"
  }
}

resource "aws_network_interface" "mgmteni_secondary" {
  source_dest_check = "true"
  subnet_id         = aws_subnet.mgmt_subnet.id
  private_ips       = [var.mgmt_eni_secondary_ip]
  security_groups   = [aws_security_group.external_sg.id]
  tags = {
    Name = "${var.site_name}-MGMT-INT-Secondary"
  }
}

resource "aws_network_interface" "waneni_primary" {
  source_dest_check = "true"
  subnet_id         = aws_subnet.wan_subnet.id
  private_ips       = [var.wan_eni_primary_ip]
  security_groups   = [aws_security_group.external_sg.id]
  tags = {
    Name = "${var.site_name}-WAN-INT-Primary"
  }
}

resource "aws_network_interface" "waneni_secondary" {
  source_dest_check = "true"
  subnet_id         = aws_subnet.wan_subnet.id
  private_ips       = [var.wan_eni_secondary_ip]
  security_groups   = [aws_security_group.external_sg.id]
  tags = {
    Name = "${var.site_name}-WAN-INT-Secondary"
  }
}


resource "aws_network_interface" "laneni_primary" {
  source_dest_check = "false"
  subnet_id         = aws_subnet.lan_subnet_primary.id
  private_ips       = [var.lan_eni_primary_ip]
  security_groups   = [aws_security_group.internal_sg.id]
  tags = {
    Name = "${var.site_name}-LAN-INT-Primary"
  }
}

resource "aws_network_interface" "laneni_secondary" {
  source_dest_check = "false"
  subnet_id         = aws_subnet.lan_subnet_secondary.id
  private_ips       = [var.lan_eni_secondary_ip]
  security_groups   = [aws_security_group.internal_sg.id]
  tags = {
    Name = "${var.site_name}-LAN-INT-Secondary"
  }
}

# Elastic IP Addresses
resource "aws_eip" "waneip_primary" {
  tags = {
    Name = "${var.site_name}-WAN-EIP-Primary"
  }
}

resource "aws_eip" "waneip_secondary" {
  tags = {
    Name = "${var.site_name}-WAN-EIP-Secondary"
  }
}

resource "aws_eip" "mgmteip_primary" {
  tags = {
    Name = "${var.site_name}-MGMT-EIP-Primary"
  }
}

resource "aws_eip" "mgmteip_secondary" {
  tags = {
    Name = "${var.site_name}-MGMT-EIP-Secondary"
  }
}

# Elastic IP Addresses Association - Required to properly destroy 
resource "aws_eip_association" "waneip_assoc_primary" {
  network_interface_id = aws_network_interface.waneni_primary.id
  allocation_id        = aws_eip.waneip_primary.id
}

resource "aws_eip_association" "waneip_assoc_secondary" {
  network_interface_id = aws_network_interface.waneni_secondary.id
  allocation_id        = aws_eip.waneip_secondary.id
}

resource "aws_eip_association" "mgmteip_assoc_primary" {
  network_interface_id = aws_network_interface.mgmteni_primary.id
  allocation_id        = aws_eip.mgmteip_primary.id
}

resource "aws_eip_association" "mgmteip_assoc_secondary" {
  network_interface_id = aws_network_interface.mgmteni_secondary.id
  allocation_id        = aws_eip.mgmteip_secondary.id
}

# Routing Tables
resource "aws_route_table" "wanrt" {
  # vpc_id            = local.create_vpc ? aws_vpc.this["vpc"].id : var.vpc_id
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.site_name}-WAN-RT"
  }
}

resource "aws_route_table" "mgmtrt" {
  # vpc_id            = local.create_vpc ? aws_vpc.this["vpc"].id : var.vpc_id
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.site_name}-MGMT-RT"
  }
}

resource "aws_route_table" "lanrt" {
  # vpc_id            = local.create_vpc ? aws_vpc.this["vpc"].id : var.vpc_id
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.site_name}-LAN-RT"
  }
}

# Routes
resource "aws_route" "wan_route" {
  route_table_id         = aws_route_table.wanrt.id
  destination_cidr_block = "0.0.0.0/0"
  # gateway_id             = local.create_igw ? aws_internet_gateway.this["internet_gateway"].id : var.internet_gateway_id
  gateway_id = var.internet_gateway_id
}

resource "aws_route" "mgmt_route" {
  route_table_id         = aws_route_table.mgmtrt.id
  destination_cidr_block = "0.0.0.0/0"
  # gateway_id             = local.create_igw ? aws_internet_gateway.this["internet_gateway"].id : var.internet_gateway_id
  gateway_id = var.internet_gateway_id
}

resource "aws_route" "lan_route" {
  route_table_id         = aws_route_table.lanrt.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.laneni_primary.id
}

# Route Table Associations
resource "aws_route_table_association" "mgmt_subnet_route_table_association" {
  subnet_id      = aws_subnet.mgmt_subnet.id
  route_table_id = aws_route_table.mgmtrt.id
}

resource "aws_route_table_association" "wan_subnet_route_table_association" {
  subnet_id      = aws_subnet.wan_subnet.id
  route_table_id = aws_route_table.wanrt.id
}

resource "aws_route_table_association" "lan_subnet_route_table_association_primary" {
  subnet_id      = aws_subnet.lan_subnet_primary.id
  route_table_id = aws_route_table.lanrt.id
}

resource "aws_route_table_association" "lan_subnet_route_table_association_secondary" {
  subnet_id      = aws_subnet.lan_subnet_secondary.id
  route_table_id = aws_route_table.lanrt.id
}

########## End AWS VPC and Network Configurations Resources ##########

########## Start Cato Site and Vsocket Deployment Resources ##########

module "vsocket-aws-ha" {
  source     = "catonetworks/vsocket-aws-ha/cato"
  token      = var.token
  account_id = var.account_id
  # vpc_id                         = local.create_vpc ? aws_vpc.this["vpc"].id : var.vpc_id
  vpc_id                         = var.vpc_id
  key_pair                       = var.key_pair
  region                         = var.region
  site_name                      = var.site_name
  site_description               = var.site_description
  site_type                      = var.site_type
  native_network_range_primary   = var.subnet_range_lan_primary
  native_network_range_secondary = var.subnet_range_lan_secondary
  mgmt_subnet_id                 = aws_subnet.mgmt_subnet.id
  wan_subnet_id                  = aws_subnet.wan_subnet.id
  lan_local_primary_ip           = var.lan_eni_primary_ip
  lan_local_secondary_ip         = var.lan_eni_secondary_ip
  lan_subnet_primary_id          = aws_subnet.lan_subnet_primary.id
  lan_subnet_secondary_id        = aws_subnet.lan_subnet_secondary.id
  mgmt_eni_primary_id            = aws_network_interface.mgmteni_primary.id
  wan_eni_primary_id             = aws_network_interface.waneni_primary.id
  lan_eni_primary_id             = aws_network_interface.laneni_primary.id
  mgmt_eni_secondary_id          = aws_network_interface.mgmteni_secondary.id
  wan_eni_secondary_id           = aws_network_interface.waneni_secondary.id
  lan_eni_secondary_id           = aws_network_interface.laneni_secondary.id
  lan_route_table_id             = aws_route_table.lanrt.id
  site_location                  = var.site_location
  tags                           = var.tags
}

########## End Cato Site and Vsocket Deployment Resources ##########
