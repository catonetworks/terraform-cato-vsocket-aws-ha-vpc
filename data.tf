# Retrieve Secondary vSocket Virtual Machine serial
data "cato_accountSnapshotSite" "aws-site-secondary" {
  depends_on = [null_resource.sleep_30_seconds]
  id         = cato_socket_site.aws-site.id
}

data "cato_accountSnapshotSite" "aws-site-2" {
  id         = cato_socket_site.aws-site.id
  depends_on = [null_resource.sleep_300_seconds-HA]
}

data "cato_accountSnapshotSite" "aws-site-primary" {
  id = cato_socket_site.aws-site.id
}

## Lookup data from region and VPC
data "aws_ami" "vsocket" {
  most_recent = true
  name_regex  = "^VSOCKET_AWS.*$"
  owners      = ["aws-marketplace"]

  # Exclude App Connector AMIs that share the VSOCKET_AWS name prefix.
  filter {
    name   = "product-code"
    values = ["dvfhly9fuuu67tw59c7lt5t3c"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}