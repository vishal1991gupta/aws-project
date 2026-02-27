# EC2 Snapshot Cleanup Lambda

This project implements an AWS Lambda function that automatically deletes EC2 snapshots older than one year. The function runs within a VPC and is triggered daily by Amazon EventBridge.

## Architecture Diagram
┌──────────────────────────────────────────────────────────────────────────────────────┐
│                                   AWS Cloud                                          │
│                                                                                      │
│  ┌─────────────────┐         ┌──────────────┐                                        │
│  │   EventBridge   │───────▶│    Lambda     |                                        │
│  │ (Daily Trigger) │         │   Function   │                                        │
│  └─────────────────┘         └──────┬───────┘                                        │
│                                     │                                                │
│                          ┌──────────┴──────────┐                                     │
│                          │                     │                                     │
│                          ▼                     ▼                                     │
│              ┌─────────────────────┐  ┌─────────────────────┐                        │
│              │   EBS Snapshots     │  │   CloudWatch Logs   │                        │
│              │  (> 1 year old)     │  │    & Metrics        │                        │
│              └─────────────────────┘  └─────────────────────┘                        │
│                                                                                      │
│  ┌──────────────────────────────────────────────────────────────────────────────┐    │
│  │                                   VPC                                        │    │
│  │                                                                              │    │
│  │  ┌──────────────────────────────────────────────────────────────────────┐    │    │
│  │  │                        Private Subnet (us-east-1a)                   │    │    │
│  │  │                                                                      │    │    │
│  │  │  ┌────────────────────────────────────────────────────────────────┐  │    │    │
│  │  │  │                 Lambda Function ENI                            │  │    │    │
│  │  │  └────────────────────────────────────────────────────────────────┘  │    │    │
│  │  │                                                                      │    │    │
│  │  │  ┌────────────────────────────────────────────────────────────────┐  │    │    │
│  │  │  │                 VPC Endpoint (EC2 API)                         │  │    │    │
│  │  │  └────────────────────────────────────────────────────────────────┘  │    │    │
│  │  │                                                                      │    │    │
│  │  └──────────────────────────────────────────────────────────────────────┘    │    │
│  └──────────────────────────────────────────────────────────────────────────────┘    │
│                                                                                      │
│  ┌──────────────────────────────────────────────────────────────────────────────┐    │
│  │                                   IAM Role                                   │    │
│  │                                                                              │    │
│  │  ┌──────────────────────────────────────────────────────────────────────┐    │    │
│  │  │  • EC2: DescribeSnapshots, DeleteSnapshot                            │    │    │
│  │  │  • EC2: CreateNetworkInterface, DescribeNetworkInterfaces            │    │    │
│  │  │  • Logs: CreateLogGroup, CreateLogStream, PutLogEvents               │    │    │
│  │  └──────────────────────────────────────────────────────────────────────┘    │    │
│  └──────────────────────────────────────────────────────────────────────────────┘    │
│                                                                                      │
└──────────────────────────────────────────────────────────────────────────────────────┘




## Prerequisites

- **AWS Account** with appropriate permissions
- **AWS CLI** installed and configured (`aws configure`)
- **Terraform** >= 1.0 installed
- **Git** for version control
- **GitBash** for Git CLI,AWS CLI and terrform CLI
- **Visual Studio** for code edit with HCL, AWS and Python plugin.
- **Python 3.9+** for lambda fuction

## Chosen IaC Tool: Terraform

**Why Terraform?**
- **Declarative Configuration**: Infrastructure defined as code, easy to version and review
- **State Management**: Tracks resource dependencies and manages updates
- **Modularity**: Reusable modules for VPC, IAM, and Lambda components
- **Multi-provider Support**: Can manage resources across multiple cloud providers
- **Plan/Apply Workflow**: Preview changes before applying them
- **Large Community**: Extensive provider support and community modules
- **Integration**: Works seamlessly with version control and CI/CD pipelines


### How to execute the IaC to create the infrastructure (VPC, subnet, IAM role, CloudWatch Event Rule if included). 

Install the terraform and AWS CLI on the git bash:-
https://developer.hashicorp.com/terraform/install
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

confirm by running below commands on git bash:-
    aws --version
    terraform --version

Configure and authenticate terraform to provision infra on AWS.
create an IAM user and save the , region, Access key and secret Key.
    run below command on gitbash and provide the access key and secret key as input
    aws configure

confirm the access by running below command:-
    aws sts get-caller-identity

commit your code from visual studio to Git repository and pull the latest content on your local machine using below command:-
    git pull origin dev

run below 
terraform commands in sequence in order to create the infra on AWS:-
    terraform init
    terraform plan
    terraform apply

## How to deploy the Lambda function code. 

create a lambda fucntion in Python
use data module in terraform and zip the function and upload the function on AWS lambda

How to configure the Lambda function to run within the VPC (subnet IDs, security group IDs). 
You have to mention the vpc_config module when defining the Lambda resource block.

## Assumptions made during the implementation (e.g., AWS region). 
    region = us-east-1
    AZ = us-east-1a
    cidr = 10.0.0.0/16
    1 private subnet
    No NAT Gateway required - Using VPC Endpoint for EC2 API
    Daily execution at midnight UTC (via rate(1 day))

## How you would monitor the Lambda function's execution (e.g., CloudWatch Logs, CloudWatch Metrics). 
    All Lambda execution logs are automatically sent to CloudWatch Logs.
    CloudWatch metrics can be set from the aws console directly based on duration and error.
