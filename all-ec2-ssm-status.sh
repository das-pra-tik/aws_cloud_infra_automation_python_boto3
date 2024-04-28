#!/bin/bash
# Specify the AWS Profiles
declare -a AWS_PROFILES=("763475757927_GLD-RestrictedAdmin" "027549150804_GLD-RestrictedAdmin" "677561441012_GLD-RestrictedAdmin" "630514165234_GLD-RestrictedAdmin")
# Specify regions in an array
declare -a REGIONS=("us-west-1" "us-west-2" "eu-west-1" "eu-west-2" "ap-northeast-1" "ap-east-1")
# Write the CSV header to the file
echo "AWS Account #, AWS-Region, InstanceId, PingStatus, AgentVersion, IsLatestVersion, PlatformType, PlatformName, IPAddress, ComputerName" > all-ec2-ssm-status.csv

for PROFILE in "${AWS_PROFILES[@]}"
  do
    for REGION in "${REGIONS[@]}"
      do
      ACCOUNT_NUMBER=$(aws sts get-caller-identity --query Account --output text --profile $PROFILE)
      aws ssm describe-instance-information --profile $PROFILE --region $REGION \
        --query "InstanceInformationList[].['$ACCOUNT_NUMBER', '$REGION', InstanceId, PingStatus, AgentVersion, IsLatestVersion, PlatformType, PlatformName, IPAddress, ComputerName]" \
        --output text | tr '\t' ',' >> all-ec2-ssm-status.csv
      done
  done
# Feedback to user
echo "Data saved to all-ec2-ssm-status.csv"