## The following attributes are exported:
output "sg_internal" { value = aws_security_group.internal_sg.id }
output "sg_external_mgmt" { value = aws_security_group.external_sg_mgmt }
output "sg_external_wan" { value = aws_security_group.external_sg_wan }
output "mgmt_eni_primary_id" { value = aws_network_interface.mgmteni_primary.id }
output "wan_eni_primary_id" { value = aws_network_interface.waneni_primary.id }
output "lan_eni_primary_id" { value = aws_network_interface.laneni_primary.id }
output "mgmt_eni_secondary_id" { value = aws_network_interface.mgmteni_secondary.id }
output "wan_eni_secondary_id" { value = aws_network_interface.waneni_secondary.id }
output "lan_eni_secondary_id" { value = aws_network_interface.laneni_secondary.id }
output "mgmteip_primary" { value = aws_eip.mgmteip_primary.public_ip }
output "waneip_primary" { value = aws_eip.waneip_primary.public_ip }
output "mgmteip_secondary" { value = aws_eip.mgmteip_secondary.public_ip }
output "waneip_secondary" { value = aws_eip.waneip_secondary.public_ip }
output "mgmt_subnet_id" { value = aws_subnet.mgmt_subnet.id }
output "wan_subnet_id" { value = aws_subnet.wan_subnet.id }
output "lan_subnet_primary_id" { value = aws_subnet.lan_subnet_primary.id }
output "lan_subnet_secondary_id" { value = aws_subnet.lan_subnet_secondary.id }
output "mgmt_route_table_id" { value = aws_route_table.mgmtrt.id }
output "wan_route_table_id" { value = aws_route_table.wanrt.id }
output "lan_route_table_id" { value = aws_route_table.lanrt.id }
output "aws_iam_role_name" { value = aws_iam_role.cato_ha_role.name }
output "aws_iam_policy_arn" { value = aws_iam_policy.cato_ha_policy.name }
output "aws_iam_instance_profile_name" { value = aws_iam_instance_profile.cato_ha_instance_profile.name }
output "aws_availability_zones_out" { value = data.aws_availability_zones.available }
output "aws_instance_primary_vsocket_id" { value = aws_instance.primary_vsocket.id }
output "aws_instance_secondary_vsocket_id" { value = aws_instance.secondary_vsocket.id }
output "internet_gateway_id" { value = var.internet_gateway_id == null ? aws_internet_gateway.internet_gateway[0].id : var.internet_gateway_id }
output "vpc_id" { value = var.vpc_id == null ? aws_vpc.cato-vpc[0].id : var.vpc_id }
output "cato_license_site" {
  value = var.license_id == null ? null : {
    id           = cato_license.license[0].id
    license_id   = cato_license.license[0].license_id
    license_info = cato_license.license[0].license_info
    site_id      = cato_license.license[0].site_id
  }
}