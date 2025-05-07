# Changelog

## 0.0.1 (2025-04-28)

### Features
- Initial version of AWS HA VPC module

## 0.0.2 (2025-05-06)
- Update module to make vpc and internet gateway optional resources

## 0.0.5 (2025-05-07)
- Added sleep null resources between primary socket creation and siteAddSecondaryAzureVSocket API to ensure enough time for socket to finish provisioning and upgrading.
- Added outputs for vpc_id and internet_gateway_id