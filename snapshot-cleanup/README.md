# EC2 Snapshot Cleanup Lambda

This project implements an AWS Lambda function that automatically deletes EC2 snapshots older than one year. The function runs within a VPC and is triggered daily by Amazon EventBridge.

## Architecture Diagram
┌─────────────────────────────────────────────────────────────────────┐
│ AWS Cloud │
│ │
│ ┌─────────────────┐ ┌──────────────┐ │
│ │ EventBridge │────▶│ Lambda │ │
│ │ (Daily Trigger)│ │ Function │ │
│ └─────────────────┘ └──────┬───────┘ │
│ │ │
│ ┌─────────────┴─────────────┐ │
│ │ │ │
│ ▼ ▼ │
│ ┌─────────────────────┐ ┌─────────────────────┐ │
│ │ EC2 API │ │ CloudWatch │ │
│ │ (List/Delete) │ │ Logs & Metrics │ │
│ └──────────┬──────────┘ └─────────────────────┘ │
│ │ │
│ ▼ │
│ ┌─────────────────────┐ │
│ │ EBS Snapshots │ │
│ │ (> 1 year old) │ │
│ └─────────────────────┘ │
│ │
│ ┌────────────────────────────────────────────────────────────┐ │
│ │ VPC │ │
│ │ ┌────────────────────────────────────────────────────┐ │ │
│ │ │ Private Subnet (AZ-a) │ │ │
│ │ │ ┌─────────────────────────────────────────┐ │ │ │
│ │ │ │ Lambda Function ENI │ │ │ │
│ │ │ └─────────────────────────────────────────┘ │ │ │
│ │ └────────────────────────────────────────────────────┘ │ │
│ │ │ │
│ │ ┌────────────────────────────────────────────────────┐ │ │
│ │ │ Private Subnet (AZ-b) │ │ │
│ │ │ ┌─────────────────────────────────────────┐ │ │ │
│ │ │ │ Lambda Function ENI │ │ │ │
│ │ │ └─────────────────────────────────────────┘ │ │ │
│ │ └────────────────────────────────────────────────────┘ │ │
│ │ │ │
│ │ ┌────────────────────────────────────────────────────┐ │ │
│ │ │ VPC Endpoints │ │ │
│ │ │ ┌─────────────────────────────────────────┐ │ │ │
│ │ │ │ • EC2 Interface Endpoint │ │ │ │
│ │ │ │ • EC2 Messages Endpoint │ │ │ │
│ │ │ │ • S3 Gateway Endpoint │ │ │ │
│ │ │ └─────────────────────────────────────────┘ │ │ │
│ │ └────────────────────────────────────────────────────┘ │ │
│ └────────────────────────────────────────────────────────────┘ │
│ │
│ ┌────────────────────────────────────────────────────────────┐ │
│ │ IAM Role │ │
│ │ ┌────────────────────────────────────────────────────┐ │ │
│ │ │ • EC2: DescribeSnapshots, DeleteSnapshot │ │ │
│ │ │ • EC2: Network Interface management │ │ │
│ │ │ • CloudWatch Logs: CreateLogGroup, PutLogEvents │ │ │
│ │ │ • X-Ray: PutTraceSegments (optional) │ │ │
│ │ └────────────────────────────────────────────────────┘ │ │
│ └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘


## Chosen IaC Tool: Terraform

**Why Terraform?**
- **Declarative Configuration**: Infrastructure defined as code, easy to version and review
- **State Management**: Tracks resource dependencies and manages updates
- **Modularity**: Reusable modules for VPC, IAM, and Lambda components
- **Multi-provider Support**: Can manage resources across multiple cloud providers
- **Plan/Apply Workflow**: Preview changes before applying them
- **Large Community**: Extensive provider support and community modules
- **Integration**: Works seamlessly with version control and CI/CD pipelines

## Prerequisites

- **AWS Account** with appropriate permissions
- **AWS CLI** installed and configured (`aws configure`)
- **Terraform** >= 1.0 installed
- **Git** for version control (optional)
- **Python 3.11+** for local testing (optional)

## Deployment Instructions

### 1. Clone or Create Project Structure

```bash
mkdir snapshot-cleanup
cd snapshot-cleanup
# Create the directory structure and files as shown above