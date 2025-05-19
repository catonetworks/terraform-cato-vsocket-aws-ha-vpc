## The following attributes are exported:

output "sg_internal" {
  description = "ID of the internal security group that controls traffic for vSockets"
  value       = aws_security_group.internal_sg.id
}

output "sg_external" {
  description = "ID of the external security group that governs Internet‑facing traffic"
  value       = aws_security_group.external_sg.id
}

output "mgmt_eni_primary_id" {
  description = "Management ENI ID attached to the first vSocket instance"
  value       = aws_network_interface.mgmteni_primary.id
}

output "wan_eni_primary_id" {
  description = "WAN ENI ID for outbound Internet connectivity on the first vSocket"
  value       = aws_network_interface.waneni_primary.id
}

output "lan_eni_primary_id" {
  description = "LAN ENI ID providing internal LAN access to the first vSocket"
  value       = aws_network_interface.laneni_primary.id
}

output "mgmt_eni_secondary_id" {
  description = "Management ENI ID attached to the standby vSocket instance"
  value       = aws_network_interface.mgmteni_secondary.id
}

output "wan_eni_secondary_id" {
  description = "WAN ENI ID for outbound Internet connectivity on the standby vSocket"
  value       = aws_network_interface.waneni_secondary.id
}

output "lan_eni_secondary_id" {
  description = "LAN ENI ID providing internal LAN access to the standby vSocket"
  value       = aws_network_interface.laneni_secondary.id
}

output "mgmteip_primary" {
  description = "Public IP address of the primary management Elastic IP"
  value       = aws_eip.mgmteip_primary.public_ip
}

output "waneip_primary" {
  description = "Public IP address of the primary WAN Elastic IP"
  value       = aws_eip.waneip_primary.public_ip
}

output "mgmteip_secondary" {
  description = "Public IP address of the secondary management Elastic IP"
  value       = aws_eip.mgmteip_secondary.public_ip
}

output "waneip_secondary" {
  description = "Public IP address of the secondary WAN Elastic IP"
  value       = aws_eip.waneip_secondary.public_ip
}

output "mgmt_subnet_id" {
  description = "Subnet ID dedicated to management traffic for vSockets"
  value       = aws_subnet.mgmt_subnet.id
}

output "wan_subnet_id" {
  description = "Subnet ID dedicated to WAN traffic for vSockets"
  value       = aws_subnet.wan_subnet.id
}

output "lan_subnet_primary_id" {
  description = "Primary LAN subnet ID serving internal applications"
  value       = aws_subnet.lan_subnet_primary.id
}

output "lan_subnet_secondary_id" {
  description = "Secondary LAN subnet ID providing HA for internal traffic"
  value       = aws_subnet.lan_subnet_secondary.id
}

output "wan_route_table_id" {
  description = "Route table ID associated with the WAN subnet"
  value       = aws_route_table.wanrt.id
}

output "lan_route_table_id" {
  description = "Route table ID associated with the LAN subnets"
  value       = aws_route_table.lanrt.id
}

output "aws_iam_role_name" {
  description = "Name of the IAM role granting vSocket HA permissions"
  value       = aws_iam_role.cato_ha_role.name
}

output "aws_iam_policy_arn" {
  description = "ARN of the IAM policy attached to the HA role"
  value       = aws_iam_policy.cato_ha_policy.name
}

output "aws_iam_instance_profile_name" {
  description = "Name of the IAM instance profile assigned to vSocket EC2 instances"
  value       = aws_iam_instance_profile.cato_ha_instance_profile.name
}

output "aws_availability_zones_out" {
  description = "List of availability zones used for this deployment"
  value       = data.aws_availability_zones.available
}

output "aws_instance_primary_vsocket_id" {
  description = "Instance ID of the primary vSocket EC2"
  value       = aws_instance.primary_vsocket.id
}

output "aws_instance_secondary_vsocket_id" {
  description = "Instance ID of the secondary vSocket EC2"
  value       = aws_instance.secondary_vsocket.id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID (existing or newly created) attached to the VPC"
  value       = var.internet_gateway_id == null ? aws_internet_gateway.internet_gateway[0].id : var.internet_gateway_id
}

output "vpc_id" {
  description = "VPC ID (existing or newly created) hosting the vSocket resources"
  value       = var.vpc_id == null ? aws_vpc.cato-vpc[0].id : var.vpc_id
}

output "cato_license_site" {
  description = "Metadata for the Cato license and site when a license ID is supplied"
  value = var.license_id == null ? null : {
    id           = cato_license.license[0].id
    license_id   = cato_license.license[0].license_id
    license_info = cato_license.license[0].license_info
    site_id      = cato_license.license[0].site_id
  }
}
