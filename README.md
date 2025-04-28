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

