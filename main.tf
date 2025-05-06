########## Start AWS VPC and Network Configurations Resources ##########

// Create VPC
resource "aws_vpc" "cato-vpc" {
  count = var.vpc_id==null ? 1 : 0
  cidr_block = var.vpc_range
  tags = {
    Name = "${var.site_name}-VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  count = var.internetGateway==null ? 1 : 0
  tags = {
    Name = "${var.site_name}-IGW2"
  }
  vpc_id = var.vpc_id==null ? aws_vpc.cato-vpc[0].id : var.vpc_id
}

# Lookup data from region and VPC - Always needed for availability zones
data "aws_availability_zones" "available_zones" {
  state = "available"
}

# Subnets
resource "aws_subnet" "mgmt_subnet" {
  vpc_id = var.vpc_id==null ? aws_vpc.cato-vpc[0].id : var.vpc_id
  cidr_block        = var.subnet_range_mgmt
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.site_name}-MGMT-Subnet"
  }
}

resource "aws_subnet" "wan_subnet" {
  vpc_id = var.vpc_id==null ? aws_vpc.cato-vpc[0].id : var.vpc_id
  cidr_block        = var.subnet_range_wan
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.site_name}-WAN-Subnet"
  }
}

resource "aws_subnet" "lan_subnet_primary" {
  vpc_id = var.vpc_id==null ? aws_vpc.cato-vpc[0].id : var.vpc_id
  cidr_block        = var.subnet_range_lan_primary
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.site_name}-LAN-Subnet-Primary"
  }
}

resource "aws_subnet" "lan_subnet_secondary" {
  vpc_id = var.vpc_id==null ? aws_vpc.cato-vpc[0].id : var.vpc_id
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
  vpc_id = var.vpc_id==null ? aws_vpc.cato-vpc[0].id : var.vpc_id
  ingress = [
    {
      description      = "Allow all traffic Inbound from Ingress CIDR Blocks"
      protocol         = -1
      from_port        = 0
      to_port          = 0
      cidr_blocks      = var.lan_ingress_cidr_blocks
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

resource "aws_security_group" "external_sg_mgmt" {
  name        = "${var.site_name}-External-SG-MGMT"
  description = "CATO MGMT Security Group - Allow HTTPS In"
  vpc_id = var.vpc_id==null ? aws_vpc.cato-vpc[0].id : var.vpc_id
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
    name = "${var.site_name}-External-SG-MGMT"
  }
}

resource "aws_security_group" "external_sg_wan" {
  name        = "${var.site_name}-External-SG-WAN"
  description = "CATO WAN Security Group - Allow all out, none in"
  vpc_id = var.vpc_id==null ? aws_vpc.cato-vpc[0].id : var.vpc_id
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
    name = "${var.site_name}-External-SG-WAN"
  }
}

# vSocket Network Interfaces
resource "aws_network_interface" "mgmteni_primary" {
  source_dest_check = "true"
  subnet_id         = aws_subnet.mgmt_subnet.id
  private_ips       = [var.mgmt_eni_primary_ip]
  security_groups   = [aws_security_group.external_sg_mgmt.id]
  tags = {
    Name = "${var.site_name}-MGMT-INT-Primary"
  }
}

resource "aws_network_interface" "mgmteni_secondary" {
  source_dest_check = "true"
  subnet_id         = aws_subnet.mgmt_subnet.id
  private_ips       = [var.mgmt_eni_secondary_ip]
  security_groups   = [aws_security_group.external_sg_mgmt.id]
  tags = {
    Name = "${var.site_name}-MGMT-INT-Secondary"
  }
}

resource "aws_network_interface" "waneni_primary" {
  source_dest_check = "true"
  subnet_id         = aws_subnet.wan_subnet.id
  private_ips       = [var.wan_eni_primary_ip]
  security_groups   = [aws_security_group.external_sg_wan.id]
  tags = {
    Name = "${var.site_name}-WAN-INT-Primary"
  }
}

resource "aws_network_interface" "waneni_secondary" {
  source_dest_check = "true"
  subnet_id         = aws_subnet.wan_subnet.id
  private_ips       = [var.wan_eni_secondary_ip]
  security_groups   = [aws_security_group.external_sg_wan.id]
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
  vpc_id = var.vpc_id==null ? aws_vpc.cato-vpc[0].id : var.vpc_id
  tags = {
    Name = "${var.site_name}-WAN-RT"
  }
}

resource "aws_route_table" "mgmtrt" {
  vpc_id = var.vpc_id==null ? aws_vpc.cato-vpc[0].id : var.vpc_id
  tags = {
    Name = "${var.site_name}-MGMT-RT"
  }
}

resource "aws_route_table" "lanrt" {
  vpc_id = var.vpc_id==null ? aws_vpc.cato-vpc[0].id : var.vpc_id
  tags = {
    Name = "${var.site_name}-LAN-RT"
  }
}

# Routes
resource "aws_route" "wan_route" {
  route_table_id         = aws_route_table.wanrt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = var.internetGateway==null ? aws_internet_gateway.internet_gateway[0].id : var.internetGateway
}

resource "aws_route" "mgmt_route" {
  route_table_id         = aws_route_table.mgmtrt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = var.internetGateway==null ? aws_internet_gateway.internet_gateway[0].id : var.internetGateway
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

resource "cato_socket_site" "aws-site" {
  connection_type = var.connection_type
  description     = var.site_description
  name            = var.site_name
  native_range = {
    native_network_range = var.subnet_range_lan_primary
    local_ip             = var.lan_eni_primary_ip
  }
  site_location = var.site_location
  site_type     = var.site_type
}

data "cato_accountSnapshotSite" "aws-site" {
  id = cato_socket_site.aws-site.id
}

# AWS HA IAM role configuration
resource "aws_iam_role" "cato_ha_role" {
  name        = "Cato-HA-Role"
  description = "To allow vSocket HA route management"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "cato_ha_policy" {
  name = "Cato-HA-Role-Policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateRoute",
          "ec2:DescribeRouteTables",
          "ec2:ReplaceRoute"
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cato_ha_attach" {
  role       = aws_iam_role.cato_ha_role.name
  policy_arn = aws_iam_policy.cato_ha_policy.arn
}

resource "aws_iam_instance_profile" "cato_ha_instance_profile" {
  name = "Cato-HA-Role"
  role = aws_iam_role.cato_ha_role.name
}

## Lookup data from region and VPC
data "aws_ami" "vsocket" {
  most_recent = true
  name_regex  = "VSOCKET_AWS"
  owners      = ["aws-marketplace"]
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Create Primary vSocket Virtual Machine
resource "aws_instance" "primary_vsocket" {
  tenancy              = "default"
  ami                  = data.aws_ami.vsocket.id
  key_name             = var.key_pair
  instance_type        = var.instance_type
  user_data            = base64encode(local.primary_serial[0])
  iam_instance_profile = aws_iam_instance_profile.cato_ha_instance_profile.name
  # Network Interfaces
  # MGMTENI
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.mgmteni_primary.id
  }
  # WANENI
  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.waneni_primary.id
  }
  # LANENI
  network_interface {
    device_index         = 2
    network_interface_id = aws_network_interface.laneni_primary.id
  }
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = var.ebs_disk_size
    volume_type = var.ebs_disk_type
  }
  tags = merge(var.tags, {
    Name = "${var.site_name}-vSocket-Primary"
  })
}

# To allow socket to upgrade so secondary socket can be added
resource "null_resource" "sleep_300_seconds" {
  provisioner "local-exec" {
    command = "sleep 300"
  }
  depends_on = [ aws_instance.primary_vsocket ]
}

#################################################################################
# Add secondary socket to site via API until socket_site resource is updated to natively support
resource "null_resource" "configure_secondary_aws_vsocket" {
  depends_on = [null_resource.sleep_300_seconds]

  provisioner "local-exec" {
    command = <<EOF
      # Execute the GraphQL mutation to get add the secondary vSocket
      response=$(curl -k -X POST \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -H "x-API-Key: ${var.token}" \
        "${var.baseurl}" \
        --data '{
          "query": "mutation siteAddSecondaryAwsVSocket($accountId: ID!, $addSecondaryAwsVSocketInput: AddSecondaryAwsVSocketInput!) { site(accountId: $accountId) { addSecondaryAwsVSocket(input: $addSecondaryAwsVSocketInput) { id } } }",
          "variables": {
            "accountId": "${var.account_id}",
            "addSecondaryAwsVSocketInput": {
              "eniIpAddress": "${var.lan_eni_secondary_ip}",
              "eniIpSubnet": "${var.subnet_range_lan_secondary}",
               "routeTableId": "${aws_route_table.lanrt.id}",
              "site": {
                "by": "ID",
                "input": "${cato_socket_site.aws-site.id}"
              }
            }
          },
          "operationName": "siteAddSecondaryAwsVSocket"
        }' )
    EOF
  }

  triggers = {
    account_id = var.account_id
    site_id    = cato_socket_site.aws-site.id
  }
}

# Retrieve Secondary vSocket Virtual Machine serial
data "cato_accountSnapshotSite" "aws-site-secondary" {
  depends_on = [ null_resource.configure_secondary_aws_vsocket ]
  id = cato_socket_site.aws-site.id
}

locals {
  primary_serial = [for s in data.cato_accountSnapshotSite.aws-site.info.sockets : s.serial if s.is_primary == true]
}

# Sleep to allow Secondary vSocket serial retrieval
resource "null_resource" "sleep_30_seconds" {
  provisioner "local-exec" {
    command = "sleep 30"
  }
  depends_on = [ data.cato_accountSnapshotSite.aws-site-secondary ]
}

locals {
  secondary_serial = [for s in data.cato_accountSnapshotSite.aws-site-secondary.info.sockets : s.serial if s.is_primary == false]
  depends_on = [null_resource.configure_secondary_aws_vsocket]
}

## vSocket Instance
resource "aws_instance" "vsocket_secondary" {
  tenancy              = "default"
  ami                  = data.aws_ami.vsocket.id
  key_name             = var.key_pair
  instance_type        = var.instance_type
  user_data            = base64encode(local.secondary_serial[0])
  iam_instance_profile = aws_iam_instance_profile.cato_ha_instance_profile.name
  # Network Interfaces
  # MGMTENI
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.mgmteni_secondary.id
  }
  # WANENI
  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.waneni_secondary.id
  }
  # LANENI
  network_interface {
    device_index         = 2
    network_interface_id = aws_network_interface.laneni_secondary.id
  }
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = var.ebs_disk_size
    volume_type = var.ebs_disk_type
  }
  tags = merge(var.tags, {
    Name = "${var.site_name}-vSocket-Secondary"
  })
  depends_on = [null_resource.sleep_30_seconds]
}

# To allow sockets to configure HA
resource "null_resource" "sleep_300_seconds-HA" {
  provisioner "local-exec" {
    command = "sleep 300"
  }
  depends_on = [ aws_instance.vsocket_secondary ]
}

data "cato_accountSnapshotSite" "aws-site-2" {
  id = cato_socket_site.aws-site.id
  depends_on = [ null_resource.sleep_300_seconds-HA ]
}

########## End Cato Site and Vsocket Deployment Resources ##########

