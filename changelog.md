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

## 0.0.9 (2024-05-15)

### Features
- Fixed typo in readme

## 0.0.11 (2024-05-15)

### Features
- Reduced routes to only have WAN and LAN routes 
