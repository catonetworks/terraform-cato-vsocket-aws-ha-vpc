# CATO VSOCKET AWS HA VPC Terraform module

Terraform module which deploys into an existing VPC, creates the required subnets, network interfaces, security groups, route tables, an AWS Socket HA Site in the Cato Management Application (CMA), and deploys a primary and secondary virtual socket VM instance in AWS and configures them as HA.

## Usage

```hcl
// Create VPC and IGW
resource "aws_vpc" "cato-vpc" {
  cidr_block = var.vpc_range
  tags = {
    Name = "${var.site_name}-VPC"
  }
}

# Internet Gateway - Create only if vpc_id is not provided
resource "aws_internet_gateway" "internet_gateway" {
  tags = {
    Name = "${var.site_name}-IGW2"
  }
  vpc_id = aws_vpc.cato-vpc.id
}

// Use data source to look up site_location 
data "cato_siteLocation" "ny" {
  filters = [{
    field = "city"
    search = "New York"
    operation = "startsWith"
  },
  {
    field = "state_name"
    search = "New York"
    operation = "exact"
  },
 {
    field = "country_name"
    search = "United"
    operation = "contains"
  }]
}

module "vsocket-aws-ha" {
  depends_on = [ aws_vpc.cato-vpc, aws_internet_gateway.internet_gateway ]
  source                     = "catonetworks/vsocket-aws-ha-vnet/cato"
  token                      = var.cato_token_base
  account_id                 = var.account_id_base
  vpc_id                     = aws_vpc.cato-vpc.id
  internet_gateway_id        = aws_internet_gateway.internet_gateway.id
  key_pair                   = "Your key pair"
  region                     = "eu-north-1"
  site_name                  = "Your-Cato-site-name-here"
  site_description           = "Your Cato site Description here"
  site_type                  = "CLOUD_DC"
  subnet_range_mgmt          = "10.32.1.0/24"
  subnet_range_wan           = "10.32.2.0/24"
  subnet_range_lan_primary   = "10.32.3.0/24"
  subnet_range_lan_secondary = "10.32.4.0/24"
  mgmt_eni_primary_ip        = "10.32.1.5"
  mgmt_eni_secondary_ip      = "10.32.1.6"
  wan_eni_primary_ip         = "10.32.2.5"
  wan_eni_secondary_ip       = "10.32.2.6"
  lan_eni_primary_ip         = "10.32.3.5"
  lan_eni_secondary_ip       = "10.32.4.5"
  ingress_cidr_blocks        = ["0.0.0.0/0"]
  site_location              = {
    city = data.cato_siteLocation.ny.locations[0].city
    country_code = data.cato_siteLocation.ny.locations[0].country_code
    state_code = data.cato_siteLocation.ny.locations[0].state_code
    timezone = data.cato_siteLocation.ny.locations[0].timezone[0]
  }
  tags = {
    Test                     = "Test tag"
    Test2                    = "Test2 tag"
  }
}
```

## Site Location Reference

For more information on site_location syntax, use the [Cato CLI](https://github.com/catonetworks/cato-cli) to lookup values.

```bash
$ pip3 install catocli
$ export CATO_TOKEN="your-api-token-here"
$ export CATO_ACCOUNT_ID="your-account-id"
$ catocli query siteLocation -h
$ catocli query siteLocation '{"filters":[{"search": "San Diego","field":"city","operation":"exact"}]}' -p
```

## Authors

Module is maintained by [Cato Networks](https://github.com/catonetworks) with help from [these awesome contributors](https://github.com/catonetworks/terraform-cato-vsocket-aws-ha-vpc/graphs/contributors).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/catonetworks/terraform-cato-vsocket-aws-ha-vpc/tree/master/LICENSE) for full details.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vsocket-aws-ha"></a> [vsocket-aws-ha](#module\_vsocket-aws-ha) | catonetworks/vsocket-aws-ha/cato | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eip.mgmteip_primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip.mgmteip_secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip.waneip_primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip.waneip_secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.mgmteip_assoc_primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_eip_association.mgmteip_assoc_secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_eip_association.waneip_assoc_primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_eip_association.waneip_assoc_secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_network_interface.laneni_primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_network_interface.laneni_secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_network_interface.mgmteni_primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_network_interface.mgmteni_secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_network_interface.waneni_primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_network_interface.waneni_secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_route.lan_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.mgmt_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.wan_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.lanrt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.mgmtrt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.wanrt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.lan_subnet_route_table_association_primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.lan_subnet_route_table_association_secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.mgmt_subnet_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.wan_subnet_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.external_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.internal_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.lan_subnet_primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.lan_subnet_secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.mgmt_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.wan_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | Cato account ID | `number` | n/a | yes |
| <a name="input_baseurl"></a> [baseurl](#input\_baseurl) | Cato Networks API URL | `string` | `"https://api.catonetworks.com/api/v1/graphql2"` | no |
| <a name="input_ingress_cidr_blocks"></a> [ingress\_cidr\_blocks](#input\_ingress\_cidr\_blocks) | Set CIDR to receive traffic from the specified IPv4 CIDR address ranges<br/>	For example x.x.x.x/32 to allow one specific IP address access, 0.0.0.0/0 to allow all IP addresses access, or another CIDR range<br/>    Best practice is to allow a few IPs as possible<br/>    The accepted input format is Standard CIDR Notation, e.g. X.X.X.X/X | `list(any)` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type of the vSocket | `string` | `"c5.xlarge"` | no |
| <a name="input_internet_gateway_id"></a> [internet\_gateway\_id](#input\_internet\_gateway\_id) | Specify an Internet Gateway ID to use. If not specified, a new Internet Gateway will be created. | `string` | `null` | no |
| <a name="input_key_pair"></a> [key\_pair](#input\_key\_pair) | Name of an existing Key Pair for AWS encryption | `string` | n/a | yes |
| <a name="input_lan_eni_primary_ip"></a> [lan\_eni\_primary\_ip](#input\_lan\_eni\_primary\_ip) | Choose an IP Address within the LAN Subnet for the Primary lan interface. You CANNOT use the first four assignable IP addresses within the subnet as it's reserved for the AWS virtual router interface. The accepted input format is X.X.X.X | `string` | n/a | yes |
| <a name="input_lan_eni_secondary_ip"></a> [lan\_eni\_secondary\_ip](#input\_lan\_eni\_secondary\_ip) | Choose an IP Address within the LAN Subnet for the Secondary lan interface. You CANNOT use the first four assignable IP addresses within the subnet as it's reserved for the AWS virtual router interface. The accepted input format is X.X.X.X | `string` | n/a | yes |
| <a name="input_mgmt_eni_primary_ip"></a> [mgmt\_eni\_primary\_ip](#input\_mgmt\_eni\_primary\_ip) | Choose an IP Address within the Management Subnet. You CANNOT use the first four assignable IP addresses within the subnet as it's reserved for the AWS virtual router interface. The accepted input format is X.X.X.X | `string` | n/a | yes |
| <a name="input_mgmt_eni_secondary_ip"></a> [mgmt\_eni\_secondary\_ip](#input\_mgmt\_eni\_secondary\_ip) | Choose an IP Address within the Management Subnet. You CANNOT use the first four assignable IP addresses within the subnet as it's reserved for the AWS virtual router interface. The accepted input format is X.X.X.X | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | # VPC Module Variables | `string` | n/a | yes |
| <a name="input_site_description"></a> [site\_description](#input\_site\_description) | Description of the vsocket site | `string` | n/a | yes |
| <a name="input_site_location"></a> [site\_location](#input\_site\_location) | n/a | <pre>object({<br/>    city         = string<br/>    country_code = string<br/>    state_code   = string<br/>    timezone     = string<br/>  })</pre> | n/a | yes |
| <a name="input_site_name"></a> [site\_name](#input\_site\_name) | Name of the vsocket site | `string` | n/a | yes |
| <a name="input_site_type"></a> [site\_type](#input\_site\_type) | The type of the site | `string` | `"CLOUD_DC"` | no |
| <a name="input_subnet_range_lan_primary"></a> [subnet\_range\_lan\_primary](#input\_subnet\_range\_lan\_primary) | Choose a range within the VPC to use as the Private/LAN subnet. This subnet will host the target LAN interface of the vSocket so resources in the VPC (or AWS Region) can route to the Cato Cloud.<br/>    The minimum subnet length to support High Availability is /29.<br/>    The accepted input format is Standard CIDR Notation, e.g. X.X.X.X/X | `string` | n/a | yes |
| <a name="input_subnet_range_lan_secondary"></a> [subnet\_range\_lan\_secondary](#input\_subnet\_range\_lan\_secondary) | Choose a range within the VPC to use as the Private/LAN subnet. This subnet will host the target LAN interface of the vSocket so resources in the VPC (or AWS Region) can route to the Cato Cloud.<br/>    The minimum subnet length to support High Availability is /29.<br/>    The accepted input format is Standard CIDR Notation, e.g. X.X.X.X/X | `string` | n/a | yes |
| <a name="input_subnet_range_mgmt"></a> [subnet\_range\_mgmt](#input\_subnet\_range\_mgmt) | Choose a range within the VPC to use as the Management subnet. This subnet will be used initially to access the public internet and register your vSocket to the Cato Cloud.<br/>    The minimum subnet length to support High Availability is /28.<br/>    The accepted input format is Standard CIDR Notation, e.g. X.X.X.X/X | `string` | n/a | yes |
| <a name="input_subnet_range_wan"></a> [subnet\_range\_wan](#input\_subnet\_range\_wan) | Choose a range within the VPC to use as the Public/WAN subnet. This subnet will be used to access the public internet and securely tunnel to the Cato Cloud.<br/>    The minimum subnet length to support High Availability is /28.<br/>    The accepted input format is Standard CIDR Notation, e.g. X.X.X.X/X | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be appended to AWS resources | `map(string)` | `{}` | no |
| <a name="input_token"></a> [token](#input\_token) | Cato API token | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Specify a VPC ID to use. If not specified, a new VPC will be created. | `string` | `null` | no |
| <a name="input_wan_eni_primary_ip"></a> [wan\_eni\_primary\_ip](#input\_wan\_eni\_primary\_ip) | Choose an IP Address within the Public/WAN Subnet. You CANNOT use the first four assignable IP addresses within the subnet as it's reserved for the AWS virtual router interface. The accepted input format is X.X.X.X | `string` | n/a | yes |
| <a name="input_wan_eni_secondary_ip"></a> [wan\_eni\_secondary\_ip](#input\_wan\_eni\_secondary\_ip) | Choose an IP Address within the Public/WAN Subnet. You CANNOT use the first four assignable IP addresses within the subnet as it's reserved for the AWS virtual router interface. The accepted input format is X.X.X.X | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_availability_zones"></a> [aws\_availability\_zones](#output\_aws\_availability\_zones) | n/a |
| <a name="output_aws_iam_instance_profile_name"></a> [aws\_iam\_instance\_profile\_name](#output\_aws\_iam\_instance\_profile\_name) | n/a |
| <a name="output_aws_iam_policy_arn"></a> [aws\_iam\_policy\_arn](#output\_aws\_iam\_policy\_arn) | n/a |
| <a name="output_aws_iam_role_name"></a> [aws\_iam\_role\_name](#output\_aws\_iam\_role\_name) | n/a |
| <a name="output_aws_instance_id"></a> [aws\_instance\_id](#output\_aws\_instance\_id) | n/a |
| <a name="output_aws_instance_vSocket_Secondary_id"></a> [aws\_instance\_vSocket\_Secondary\_id](#output\_aws\_instance\_vSocket\_Secondary\_id) | n/a |
| <a name="output_cato_account_snapshot_site_secondary_id"></a> [cato\_account\_snapshot\_site\_secondary\_id](#output\_cato\_account\_snapshot\_site\_secondary\_id) | n/a |
| <a name="output_lan_eni_primary_id"></a> [lan\_eni\_primary\_id](#output\_lan\_eni\_primary\_id) | n/a |
| <a name="output_lan_eni_secondary_id"></a> [lan\_eni\_secondary\_id](#output\_lan\_eni\_secondary\_id) | n/a |
| <a name="output_lan_route_table_id"></a> [lan\_route\_table\_id](#output\_lan\_route\_table\_id) | n/a |
| <a name="output_lan_subnet_primary_id"></a> [lan\_subnet\_primary\_id](#output\_lan\_subnet\_primary\_id) | n/a |
| <a name="output_lan_subnet_secondary_id"></a> [lan\_subnet\_secondary\_id](#output\_lan\_subnet\_secondary\_id) | n/a |
| <a name="output_mgmt_eni_primary_id"></a> [mgmt\_eni\_primary\_id](#output\_mgmt\_eni\_primary\_id) | n/a |
| <a name="output_mgmt_eni_secondary_id"></a> [mgmt\_eni\_secondary\_id](#output\_mgmt\_eni\_secondary\_id) | n/a |
| <a name="output_mgmt_route_table_id"></a> [mgmt\_route\_table\_id](#output\_mgmt\_route\_table\_id) | output "vpc\_id" { value = local.create\_vpc ? aws\_vpc.this["vpc"].id : var.vpc\_id } |
| <a name="output_mgmt_subnet_id"></a> [mgmt\_subnet\_id](#output\_mgmt\_subnet\_id) | n/a |
| <a name="output_mgmteip_primary"></a> [mgmteip\_primary](#output\_mgmteip\_primary) | n/a |
| <a name="output_mgmteip_secondary"></a> [mgmteip\_secondary](#output\_mgmteip\_secondary) | n/a |
| <a name="output_secondary_socket_site_serial"></a> [secondary\_socket\_site\_serial](#output\_secondary\_socket\_site\_serial) | n/a |
| <a name="output_sg_external"></a> [sg\_external](#output\_sg\_external) | n/a |
| <a name="output_sg_internal"></a> [sg\_internal](#output\_sg\_internal) | # The following attributes are exported: output "internet\_gateway\_id" { value = local.create\_igw ? aws\_internet\_gateway.this["internet\_gateway"].id : var.internet\_gateway\_id } |
| <a name="output_socket_site_id"></a> [socket\_site\_id](#output\_socket\_site\_id) | n/a |
| <a name="output_socket_site_serial"></a> [socket\_site\_serial](#output\_socket\_site\_serial) | n/a |
| <a name="output_wan_eni_primary_id"></a> [wan\_eni\_primary\_id](#output\_wan\_eni\_primary\_id) | n/a |
| <a name="output_wan_eni_secondary_id"></a> [wan\_eni\_secondary\_id](#output\_wan\_eni\_secondary\_id) | n/a |
| <a name="output_wan_route_table_id"></a> [wan\_route\_table\_id](#output\_wan\_route\_table\_id) | n/a |
| <a name="output_wan_subnet_id"></a> [wan\_subnet\_id](#output\_wan\_subnet\_id) | n/a |
| <a name="output_waneip_primary"></a> [waneip\_primary](#output\_waneip\_primary) | n/a |
| <a name="output_waneip_secondary"></a> [waneip\_secondary](#output\_waneip\_secondary) | n/a |
<!-- END_TF_DOCS -->