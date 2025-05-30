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
