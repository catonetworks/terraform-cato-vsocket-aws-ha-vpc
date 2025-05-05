variable "baseurl" {
  description = "Cato Networks API URL"
  type        = string
  default     = "https://api.catonetworks.com/api/v1/graphql2"
}

variable "token" {
  description = "Cato API token"
  type        = string
}

variable "account_id" {
  description = "Cato account ID"
  type        = number
}

## VPC Variables
variable "vpc_id" {
  description = "Specify a VPC ID to use. If not specified, a new VPC will be created."
  type        = string
  default     = null
}

variable "internetGateway" {
  description = "Specify a Internet Gateway ID to use. If not specified, a new Internet Gateway will be created."
  type = string
  default = null
}

variable "vpc_range" {
  type        = string
  description = <<EOT
  	Choose a unique range for your new VPC that does not conflict with the rest of your Wide Area Network.
    The accepted input format is Standard CIDR Notation, e.g. X.X.X.X/X
	EOT
  default = null
}

variable "internet_gateway_id" {
  description = "Specify an Internet Gateway ID to use. If not specified, a new Internet Gateway will be created."
  type        = string
  default     = null
}

variable "wan_eni_secondary_ip" {
  description = "Choose an IP Address within the Public/WAN Subnet. You CANNOT use the first four assignable IP addresses within the subnet as it's reserved for the AWS virtual router interface. The accepted input format is X.X.X.X"
  type        = string
}

variable "site_name" {
  description = "Name of the vsocket site"
  type        = string
}

variable "site_description" {
  description = "Description of the vsocket site"
  type        = string
}

variable "site_type" {
  description = "The type of the site"
  type        = string
  default     = "CLOUD_DC"
  validation {
    condition     = contains(["DATACENTER", "BRANCH", "CLOUD_DC", "HEADQUARTERS"], var.site_type)
    error_message = "The site_type variable must be one of 'DATACENTER','BRANCH','CLOUD_DC','HEADQUARTERS'."
  }
}

variable "site_location" {
  type = object({
    city         = string
    country_code = string
    state_code   = string
    timezone     = string
  })
  # default = {
  #   city         = "New York"
  #   country_code = "US"
  #   state_code   = "US-NY" ## Optional - for coutnries with states
  #   timezone     = "America/New_York"
  # }
}

## VPC Module Variables
variable "region" {
  type = string
}

variable "ingress_cidr_blocks" {
  type        = list(any)
  description = <<EOT
  	Set CIDR to receive traffic from the specified IPv4 CIDR address ranges
	For example x.x.x.x/32 to allow one specific IP address access, 0.0.0.0/0 to allow all IP addresses access, or another CIDR range
    Best practice is to allow a few IPs as possible
    The accepted input format is Standard CIDR Notation, e.g. X.X.X.X/X
	EOT  
}

variable "lan_ingress_cidr_blocks" {
  type        = list(any)
  description = <<EOT
  	Set CIDR to receive traffic from the specified IPv4 CIDR address ranges
	For example x.x.x.x/32 to allow one specific IP address access, 0.0.0.0/0 to allow all IP addresses access, or another CIDR range
    Best practice is to allow a few IPs as possible
    The accepted input format is Standard CIDR Notation, e.g. X.X.X.X/X
	EOT  
}

variable "instance_type" {
  description = "The instance type of the vSocket"
  type        = string
  default     = "c5.xlarge"
  validation {
    condition     = contains(["d2.xlarge", "c3.xlarge", "t3.large", "t3.xlarge", "c4.xlarge", "c5.xlarge", "c5d.xlarge", "c5n.xlarge"], var.instance_type)
    error_message = "The instance_type variable must be one of 'd2.xlarge','c3.xlarge','t3.large','t3.xlarge','c4.xlarge','c5.xlarge','c5d.xlarge','c5n.xlarge'."
  }
}

variable "key_pair" {
  description = "Name of an existing Key Pair for AWS encryption"
  type        = string
}

variable "mgmt_eni_primary_ip" {
  description = "Choose an IP Address within the Management Subnet. You CANNOT use the first four assignable IP addresses within the subnet as it's reserved for the AWS virtual router interface. The accepted input format is X.X.X.X"
  type        = string
}

variable "wan_eni_primary_ip" {
  description = "Choose an IP Address within the Public/WAN Subnet. You CANNOT use the first four assignable IP addresses within the subnet as it's reserved for the AWS virtual router interface. The accepted input format is X.X.X.X"
  type        = string
}

variable "lan_eni_primary_ip" {
  description = "Choose an IP Address within the LAN Subnet for the Primary lan interface. You CANNOT use the first four assignable IP addresses within the subnet as it's reserved for the AWS virtual router interface. The accepted input format is X.X.X.X"
  type        = string
}

variable "mgmt_eni_secondary_ip" {
  description = "Choose an IP Address within the Management Subnet. You CANNOT use the first four assignable IP addresses within the subnet as it's reserved for the AWS virtual router interface. The accepted input format is X.X.X.X"
  type        = string
}

variable "lan_eni_secondary_ip" {
  description = "Choose an IP Address within the LAN Subnet for the Secondary lan interface. You CANNOT use the first four assignable IP addresses within the subnet as it's reserved for the AWS virtual router interface. The accepted input format is X.X.X.X"
  type        = string
}

variable "subnet_range_mgmt" {
  type        = string
  description = <<EOT
    Choose a range within the VPC to use as the Management subnet. This subnet will be used initially to access the public internet and register your vSocket to the Cato Cloud.
    The minimum subnet length to support High Availability is /28.
    The accepted input format is Standard CIDR Notation, e.g. X.X.X.X/X
	EOT
}

variable "subnet_range_wan" {
  type        = string
  description = <<EOT
    Choose a range within the VPC to use as the Public/WAN subnet. This subnet will be used to access the public internet and securely tunnel to the Cato Cloud.
    The minimum subnet length to support High Availability is /28.
    The accepted input format is Standard CIDR Notation, e.g. X.X.X.X/X
	EOT
}

variable "subnet_range_lan_primary" {
  type        = string
  description = <<EOT
    Choose a range within the VPC to use as the Private/LAN subnet. This subnet will host the target LAN interface of the vSocket so resources in the VPC (or AWS Region) can route to the Cato Cloud.
    The minimum subnet length to support High Availability is /29.
    The accepted input format is Standard CIDR Notation, e.g. X.X.X.X/X
	EOT
}

variable "subnet_range_lan_secondary" {
  type        = string
  description = <<EOT
    Choose a range within the VPC to use as the Private/LAN subnet. This subnet will host the target LAN interface of the vSocket so resources in the VPC (or AWS Region) can route to the Cato Cloud.
    The minimum subnet length to support High Availability is /29.
    The accepted input format is Standard CIDR Notation, e.g. X.X.X.X/X
	EOT
}

variable "tags" {
  description = "Tags to be appended to AWS resources"
  type        = map(string)
  default     = {}
}

variable "connection_type" {
  description = "Model of Cato vsocket"
  type        = string
  default     = "SOCKET_AWS1500"
}

variable "ebs_disk_size" {
  description = "Size of disk"
  type        = number
  default     = 32
}

variable "ebs_disk_type" {
  description = "Size of disk"
  type        = string
  default     = "gp2"
}