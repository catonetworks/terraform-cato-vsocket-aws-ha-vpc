# Changelog

## 0.0.1 (2025-04-28)

### Features
- Initial version of AWS HA VPC module

## 0.0.2 (2025-05-06)
- Update module to make vpc and internet gateway optional resources

## 0.0.5 (2025-05-07)
- Added sleep null resources between primary socket creation and siteAddSecondaryAzureVSocket API to ensure enough time for socket to finish provisioning and upgrading.
- Added outputs for vpc_id and internet_gateway_id

## 0.0.6 (2024-05-07)

### Features
- Added optional license resource and inputs used for commercial site deployments

## 0.0.8 (2024-05-13)

### Features
- Updating iam role name creation to be unique with site name, filtering out invalid characters
- Renamed resources and outputs to align with standard

## 0.0.9 (2024-05-13)

### Features
- Fixed typp in readme

## 0.1.0 (2025-05-20)

### Features
 - Adjusted Security Groups to be in-line with ProServ recommendations.
 - Removed Mgmt Security Group (Unneeded)
 - Enhanced Tagging to Tagable resources. 
 - Removed Mgmt RouteTable (Unneeded)
 - Simplified Outputs 

 - Prepared Module for Use in TGW HA Module 
   - Added subnets for secondary mgmt (Separate AZ) 
   - Added subnets for secondary wan (Separate AZ)
   - Adjusted Route Table Association to accomodate new Subnets
   - Changed Native Network Range to use var "native_network_range" 
   - Added additional outputs 
     - mgmt_subnet_primary_id 
     - mgmt_subnet_secondary_id
     - wan_subnet_primary_id
     - wan_subnet_secondary_id
    - Added additional required variables 
      - native_network_range
      - subnet_range_mgmt_primary
      - subnet_range_mgmt_secondary
      - subnet_range_wan_primary
      - subnet_range_wan_secondary
 - Updated ChangeLog
 - Updated Readme 

 ## 0.1.1 (2025-05-20)

 ### Features
  - Updated README.md to fix errors 

## 0.1.2 (2025-05-30)

### Features
- Adjusted EBS Disk type from GP2 to GP3 


## 0.1.3 (2025-06-27)
This release focuses on adding new networking features, simplifying configuration, improving stability, and refactoring the codebase for long-term maintenance.

### New Features
* **Added Support for Routed Networks:** Introduced a new `routed_networks` variable. This allows you to define a map of network names and CIDR ranges that should be routed through the Cato site, which are configured via the new `cato_network_range` resource.
* **Automatic Site Location:** The `site_location` is now automatically derived from the configured AWS `region`, simplifying site creation. As a result, the `site_location` variable is now optional.
* **Simplified Native Network Configuration:** To reduce user input, the `native_network_range` variable has been removed. Its value is now automatically inferred from the `subnet_range_lan_primary`.
### Bug Fixes
* **Fix Routed Network Creation Order:** Resolved a race condition by adding an explicit `depends_on` block to the new routed network resources. This ensures the Cato site is fully provisioned before attempting to add networks, preventing potential API errors.
### Housekeeping & Refactoring
* **Modernize Resource Triggers:** Replaced the legacy `null_resource` with the modern `terraform_data` resource for configuring the secondary vSocket. The `local-exec` provisioner was also refactored to use a separate `templatefile` for the API payload, significantly improving code readability and maintenance.
* **Code Cleanup:** Removed several unused variables (`ingress_cidr_blocks`), data sources (`aws_ami`, `aws_availability_zones`), and `locals` as identified by `tflint`.
* **Updated Default EBS Volume Type:** The default `ebs_disk_type` for the vSocket instances has been changed from `gp2` to the more modern and cost-effective `gp3`.
* **Updated Dependency Versions:** Raised the minimum required versions for Terraform (`>= 1.5`), the AWS provider (`>= 5.98.0`), and the Cato provider (`>= 0.0.27`) to ensure compatibility with new features and best practices.

## 0.1.4 (2025-07-16)

### Features
 - Update site_location to latest revision 
 - version lock cato provider to version 0.0.30

## 0.1.5 (2025-08-01)

### Features
 - Updated to use latest provider version 
  - Adjusted routed_networks call to include interface_index 
 - Version Lock to Provider version 0.0.38 or greater

## 0.1.6 (2026-02-18)
  - Reverted to provider version 0.0.57 to address local_ip and gateway api param issue in state

## 0.1.7 (2026-02-24)

### Features
- Added variables for security group ingress and egress for internal and external

## 0.1.8 (2026-03-12)

### Features
- Updated disk to be encrypted and updated network interfaces to use new convention of primary and aws_network_interface_attachment
