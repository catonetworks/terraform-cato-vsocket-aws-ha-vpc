########## Start AWS VPC and Network Configurations Resources ##########
// Create VPC
resource "aws_vpc" "cato-vpc" {
  count      = var.vpc_id == null ? 1 : 0
  cidr_block = var.vpc_range
  tags = merge(var.tags, {
    Name = "${var.site_name}-VPC"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  count = var.internet_gateway_id == null ? 1 : 0
  tags = merge(var.tags, {
    Name = "${var.site_name}-IGW"
  })
  vpc_id = var.vpc_id == null ? aws_vpc.cato-vpc[0].id : var.vpc_id
}

# Subnets
resource "aws_subnet" "mgmt_subnet_primary" {
  vpc_id            = var.vpc_id == null ? aws_vpc.cato-vpc[0].id : var.vpc_id
  cidr_block        = var.subnet_range_mgmt_primary
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = merge(var.tags, {
    Name = "${var.site_name}-MGMT-Subnet"
  })
}

resource "aws_subnet" "mgmt_subnet_secondary" {
  vpc_id            = var.vpc_id == null ? aws_vpc.cato-vpc[0].id : var.vpc_id
  cidr_block        = var.subnet_range_mgmt_secondary
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = merge(var.tags, {
    Name = "${var.site_name}-MGMT-Subnet"
  })
}

resource "aws_subnet" "wan_subnet_primary" {
  vpc_id            = var.vpc_id == null ? aws_vpc.cato-vpc[0].id : var.vpc_id
  cidr_block        = var.subnet_range_wan_primary
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = merge(var.tags, {
    Name = "${var.site_name}-WAN-Subnet"
  })
}

resource "aws_subnet" "wan_subnet_secondary" {
  vpc_id            = var.vpc_id == null ? aws_vpc.cato-vpc[0].id : var.vpc_id
  cidr_block        = var.subnet_range_wan_secondary
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = merge(var.tags, {
    Name = "${var.site_name}-WAN-Subnet"
  })
}

resource "aws_subnet" "lan_subnet_primary" {
  vpc_id            = var.vpc_id == null ? aws_vpc.cato-vpc[0].id : var.vpc_id
  cidr_block        = var.subnet_range_lan_primary
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = merge(var.tags, {
    Name = "${var.site_name}-LAN-Subnet-Primary"
  })
}

resource "aws_subnet" "lan_subnet_secondary" {
  vpc_id            = var.vpc_id == null ? aws_vpc.cato-vpc[0].id : var.vpc_id
  cidr_block        = var.subnet_range_lan_secondary
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = merge(var.tags, {
    Name = "${var.site_name}-LAN-Subnet-Secondary"
  })
}

# Internal and External Security Groups
resource "aws_security_group" "internal_sg" {
  name        = "${var.site_name}-Cato-Internal-SG"
  description = "CATO LAN Security Group - Allow all traffic Inbound"
  vpc_id      = var.vpc_id == null ? aws_vpc.cato-vpc[0].id : var.vpc_id
  egress = var.internal_sg_egress
  ingress = var.internal_sg_ingress
  tags = merge(var.tags, {
    name = "${var.site_name}-Cato-Internal-SG"
  })
}

resource "aws_security_group" "external_sg" {
  name        = "${var.site_name}-Cato-External-SG"
  description = "CATO WAN Security Group"
  vpc_id      = var.vpc_id == null ? aws_vpc.cato-vpc[0].id : var.vpc_id
  ingress     = var.external_sg_ingress
  egress = var.external_sg_egress
  tags = merge(var.tags, {
    name = "${var.site_name}-Cato-External-SG"
  })
}


# vSocket Network Interfaces
resource "aws_network_interface" "mgmteni_primary" {
  source_dest_check = "true"
  subnet_id         = aws_subnet.mgmt_subnet_primary.id
  private_ips       = [var.mgmt_eni_primary_ip]
  security_groups   = [aws_security_group.external_sg.id]
  tags = merge(var.tags, {
  Name = "${var.site_name}-MGMT-INT-Primary" })
}

resource "aws_network_interface" "mgmteni_secondary" {
  source_dest_check = "true"
  subnet_id         = aws_subnet.mgmt_subnet_secondary.id
  private_ips       = [var.mgmt_eni_secondary_ip]
  security_groups   = [aws_security_group.external_sg.id]
  tags = merge(var.tags, {
    Name = "${var.site_name}-MGMT-INT-Secondary"
  })
}

resource "aws_network_interface" "waneni_primary" {
  source_dest_check = "true"
  subnet_id         = aws_subnet.wan_subnet_primary.id
  private_ips       = [var.wan_eni_primary_ip]
  security_groups   = [aws_security_group.external_sg.id]
  tags = merge(var.tags, {
    Name = "${var.site_name}-WAN-INT-Primary"
  })
}

resource "aws_network_interface" "waneni_secondary" {
  source_dest_check = "true"
  subnet_id         = aws_subnet.wan_subnet_secondary.id
  private_ips       = [var.wan_eni_secondary_ip]
  security_groups   = [aws_security_group.external_sg.id]
  tags = merge(var.tags, {
    Name = "${var.site_name}-WAN-INT-Secondary"
  })
}

resource "aws_network_interface" "laneni_primary" {
  source_dest_check = "false"
  subnet_id         = aws_subnet.lan_subnet_primary.id
  private_ips       = [var.lan_eni_primary_ip]
  security_groups   = [aws_security_group.internal_sg.id]
  tags = merge(var.tags, {
    Name = "${var.site_name}-LAN-INT-Primary"
  })
}

resource "aws_network_interface" "laneni_secondary" {
  source_dest_check = "false"
  subnet_id         = aws_subnet.lan_subnet_secondary.id
  private_ips       = [var.lan_eni_secondary_ip]
  security_groups   = [aws_security_group.internal_sg.id]
  tags = merge(var.tags, {
    Name = "${var.site_name}-LAN-INT-Secondary"
  })
}

# Elastic IP Addresses
resource "aws_eip" "waneip_primary" {
  tags = merge(var.tags, {
    Name = "${var.site_name}-WAN-EIP-Primary"
  })
}

resource "aws_eip" "waneip_secondary" {
  tags = merge(var.tags, {
    Name = "${var.site_name}-WAN-EIP-Secondary"
  })
}

resource "aws_eip" "mgmteip_primary" {
  tags = merge(var.tags, {
    Name = "${var.site_name}-MGMT-EIP-Primary"
  })
}

resource "aws_eip" "mgmteip_secondary" {
  tags = merge(var.tags, {
    Name = "${var.site_name}-MGMT-EIP-Secondary"
  })
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
  vpc_id = var.vpc_id == null ? aws_vpc.cato-vpc[0].id : var.vpc_id
  tags = merge(var.tags, {
    Name = "${var.site_name}-WAN-RT"
  })
}

resource "aws_route_table" "lanrt" {
  vpc_id = var.vpc_id == null ? aws_vpc.cato-vpc[0].id : var.vpc_id
  tags = merge(var.tags, {
    Name = "${var.site_name}-LAN-RT"
  })
}

# Routes
resource "aws_route" "wan_route" {
  route_table_id         = aws_route_table.wanrt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id == null ? aws_internet_gateway.internet_gateway[0].id : var.internet_gateway_id
}

resource "aws_route" "lan_route" {
  route_table_id         = aws_route_table.lanrt.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.laneni_primary.id
}

# Route Table Associations
resource "aws_route_table_association" "mgmt_subnet_primary_route_table_association" {
  subnet_id      = aws_subnet.mgmt_subnet_primary.id
  route_table_id = aws_route_table.wanrt.id
}

resource "aws_route_table_association" "mgmt_subnet_secondary_route_table_association" {
  subnet_id      = aws_subnet.mgmt_subnet_secondary.id
  route_table_id = aws_route_table.wanrt.id
}

resource "aws_route_table_association" "wan_subnet_primary_route_table_association" {
  subnet_id      = aws_subnet.wan_subnet_primary.id
  route_table_id = aws_route_table.wanrt.id
}

resource "aws_route_table_association" "wan_subnet_secondary_route_table_association" {
  subnet_id      = aws_subnet.wan_subnet_secondary.id
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
    native_network_range = var.subnet_range_lan_primary #Native_network_Range is inferred by the Socket Lan Subnet Primary
    local_ip             = var.lan_eni_primary_ip
  }
  site_location = local.cur_site_location
  site_type     = var.site_type
}


resource "cato_network_range" "routedNetworks" {
  for_each        = var.routed_networks
  site_id         = cato_socket_site.aws-site.id
  name            = each.key # The name is the key from the map item.
  range_type      = "Routed"
  subnet          = each.value.subnet # The subnet is the value from the map item.
  interface_index = each.value.interface_index
  depends_on      = [data.cato_accountSnapshotSite.aws-site-2]
}

# AWS HA IAM role configuration
resource "aws_iam_role" "cato_ha_role" {
  name        = "Cato-HA-Role-${local.sanitized_name}"
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
  tags = merge(var.tags, {
    Name = "Cato-HA-Role-${local.sanitized_name}"
  })
}

resource "aws_iam_policy" "cato_ha_policy" {
  name = "Cato-HA-Role-Policy-${local.sanitized_name}"
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
  tags = merge(var.tags, {
    Name = "Cato-HA-Role-Policy-${local.sanitized_name}"
  })
}

resource "aws_iam_role_policy_attachment" "cato_ha_attach" {
  role       = aws_iam_role.cato_ha_role.name
  policy_arn = aws_iam_policy.cato_ha_policy.arn
}

resource "aws_iam_instance_profile" "cato_ha_instance_profile" {
  name = "Cato-HA-Role-${local.sanitized_name}"
  role = aws_iam_role.cato_ha_role.name
  tags = merge(var.tags, {
    Name = "Cato-HA-Role-${local.sanitized_name}"
  })
}

# Create Primary vSocket Virtual Machine
resource "aws_instance" "primary_vsocket" {
  tenancy              = "default"
  ami                  = data.aws_ami.vsocket.id
  key_name             = var.key_pair
  instance_type        = var.instance_type
  user_data_base64     = base64encode(local.primary_serial[0])
  iam_instance_profile = aws_iam_instance_profile.cato_ha_instance_profile.name
  # Network Interfaces
  # MGMTENI
  primary_network_interface {
    network_interface_id = aws_network_interface.mgmteni_primary.id
  }
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = var.ebs_disk_size
    volume_type = var.ebs_disk_type
    encrypted   = true
  }
  tags = merge(var.tags, {
    Name = "${var.site_name}-vSocket-Primary"
  })
   
  lifecycle {
    ignore_changes = [ami]
  }
}

# WANENI
resource "aws_network_interface_attachment" "wan-primary-int" {
  instance_id          = aws_instance.primary_vsocket.id
  network_interface_id = aws_network_interface.waneni_primary.id
  device_index         = 1
}

# LANENI
resource "aws_network_interface_attachment" "lan-primary-int" {
  instance_id          = aws_instance.primary_vsocket.id
  network_interface_id = aws_network_interface.laneni_primary.id
  device_index         = 2
}

resource "null_resource" "primary_reboot_once" {
  # Only runs on creation, not subsequent applies
  triggers = {
    instance_id = aws_instance.primary_vsocket.id
  }
  provisioner "local-exec" {
    command = "sleep 15 && aws ec2 reboot-instances --instance-ids ${aws_instance.primary_vsocket.id} --region ${var.region}"
  }
  depends_on = [aws_instance.primary_vsocket, aws_network_interface_attachment.wan-primary-int, aws_network_interface_attachment.lan-primary-int]
}

resource "null_resource" "sleep_500_seconds" {
  triggers = {
    instance_id = aws_instance.primary_vsocket.id
  }

  provisioner "local-exec" {
    command = "sleep 500"
  }

  depends_on = [
    null_resource.primary_reboot_once
  ]
}

resource "terraform_data" "configure_secondary_aws_vsocket" {
  depends_on = [null_resource.sleep_500_seconds]

  # The `input` block serves as the trigger for this resource.
  # If any of these values change, Terraform will replace the resource,
  # causing the provisioner to run again. This is the modern replacement
  # for the `triggers` argument in null_resource.
  input = {
    account_id     = var.account_id
    site_id        = cato_socket_site.aws-site.id
    eni_ip_address = var.lan_eni_secondary_ip
    eni_ip_subnet  = var.subnet_range_lan_secondary
    route_table_id = aws_route_table.lanrt.id
  }

  provisioner "local-exec" {
    # The command is now cleaner. It calls the curl command and uses the
    # templatefile() function to dynamically generate the JSON payload from
    # an external template file. This avoids the large, hard-to-read heredoc.
    command = templatefile("${path.module}/templates/secondary_socket_payload.json.tftpl", {
      account_id     = self.input.account_id,
      site_id        = self.input.site_id,
      eni_ip_address = self.input.eni_ip_address,
      eni_ip_subnet  = self.input.eni_ip_subnet,
      route_table_id = self.input.route_table_id
      api_token      = var.token
      baseurl        = var.baseurl
    })
  }
}

# Sleep to allow Secondary vSocket serial retrieval
resource "null_resource" "sleep_30_seconds" {
  provisioner "local-exec" {
    command = "sleep 30"
  }
  depends_on = [terraform_data.configure_secondary_aws_vsocket]
}

## vSocket Instance
resource "aws_instance" "secondary_vsocket" {
  tenancy              = "default"
  ami                  = data.aws_ami.vsocket.id
  key_name             = var.key_pair
  instance_type        = var.instance_type
  user_data_base64     = base64encode(local.secondary_serial[0])
  iam_instance_profile = aws_iam_instance_profile.cato_ha_instance_profile.name
  # Network Interfaces
  # MGMTENI
  primary_network_interface {
    network_interface_id = aws_network_interface.mgmteni_secondary.id
  }
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = var.ebs_disk_size
    volume_type = var.ebs_disk_type
    encrypted   = true
  }
  tags = merge(var.tags, {
    Name = "${var.site_name}-vSocket-Secondary"
  })
   
  lifecycle {
    ignore_changes = [ami]
  }
  depends_on = [null_resource.sleep_30_seconds]
}

# WANENI
resource "aws_network_interface_attachment" "wan-secondary-int" {
  instance_id          = aws_instance.secondary_vsocket.id
  network_interface_id = aws_network_interface.waneni_secondary.id
  device_index         = 1
}

# LANENI
resource "aws_network_interface_attachment" "lan-secondary-int" {
  instance_id          = aws_instance.secondary_vsocket.id
  network_interface_id = aws_network_interface.laneni_secondary.id
  device_index         = 2
}

resource "null_resource" "secondary_reboot_once" {
  # Only runs on creation, not subsequent applies
  triggers = {
    instance_id = aws_instance.secondary_vsocket.id
  }
  provisioner "local-exec" {
    command = "sleep 15 && aws ec2 reboot-instances --instance-ids ${aws_instance.secondary_vsocket.id} --region ${var.region}"
  }
  depends_on = [aws_instance.secondary_vsocket, aws_network_interface_attachment.wan-secondary-int, aws_network_interface_attachment.lan-secondary-int]
}

resource "null_resource" "sleep_300_seconds-HA" {
  triggers = {
    instance_id = aws_instance.secondary_vsocket.id
  }

  provisioner "local-exec" {
    command = "sleep 300"
  }

  depends_on = [
    null_resource.secondary_reboot_once
  ]
}

resource "cato_license" "license" {
  depends_on = [aws_instance.secondary_vsocket]
  count      = var.license_id == null ? 0 : 1
  site_id    = cato_socket_site.aws-site.id
  license_id = var.license_id
  bw         = var.license_bw == null ? null : var.license_bw
}

########## End Cato Site and Vsocket Deployment Resources ##########

