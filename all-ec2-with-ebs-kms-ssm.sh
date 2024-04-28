#!/bin/bash

# Specify the AWS Profiles
declare -a AWS_PROFILES=("tf-admin")
BUCKET_NAME="374278-terraform-tfstate"
output_file="ec2_info.csv"

# Write the CSV header to the file
echo "AWS Account #,AWS-Region,ImageId,InstanceId,InstanceName,InstanceStatus,InstanceType,EBSOptimized,TotalVolumeSize,PrivateIP,VPC-id,Subnet-id,KeyPairName,Operating System,SSM Version,Is SSM Latest,KmsKeyId,kmsAlias" > "$output_file"

for PROFILE in "${AWS_PROFILES[@]}";
  do
    for REGION in $(aws ec2 describe-regions --profile $PROFILE --output text --query 'Regions[].RegionName');
      do
        for InstanceId in $(aws ec2 describe-instances --profile $PROFILE --region $REGION --query 'Reservations[].Instances[].InstanceId' --output text | paste -d " "  -s);  
          do
          total=0
          instance_id="$InstanceId"
          volId=$(aws ec2 describe-volumes --profile $PROFILE --region $REGION --filters Name=encrypted,Values=true Name=attachment.status,Values=attached Name=attachment.instance-id,Values="$instance_id" --query 'Volumes[].Attachments[].VolumeId' --output text)  
            for volId in $volId;
              do
                size=$(aws ec2 describe-volumes --volume-ids "$volId" --profile $PROFILE --region $REGION --query 'Volumes[].Size' --output=text)
                kmsId=$(aws ec2 describe-volumes --volume-ids "$volId" --profile $PROFILE --region $REGION --query 'Volumes[].KmsKeyId' --output text)
                kmsAlias=$(aws kms list-aliases --key-id "$kmsId" --profile $PROFILE --region $REGION --query 'Aliases[].AliasName' --output text)
                total=$((total+size))
              done
            ACCOUNT_NUMBER=$(aws sts get-caller-identity --query Account --profile $PROFILE --output text)
            REGION=$REGION
            IMAGE_ID=$(aws ec2 describe-instances --profile $PROFILE --region $REGION --instance-ids "$instance_id" --query 'Reservations[].Instances[].ImageId' --output text)
            INSTANCE_ID=$(aws ec2 describe-instances --profile $PROFILE --region $REGION --instance-ids "$instance_id" --query 'Reservations[].Instances[].InstanceId' --output text)
            INSTANCE_NAME=$(aws ec2 describe-instances --profile $PROFILE --region $REGION --instance-ids "$instance_id" --query 'Reservations[].Instances[].[Tags[?Key==`Name`].Value | [0]]' --output text)
            INSTANCE_STATUS=$(aws ec2 describe-instances --profile $PROFILE --region $REGION --instance-ids "$instance_id" --query 'Reservations[].Instances[].State.Name' --output text)
            INSTANCE_TYPE=$(aws ec2 describe-instances --profile $PROFILE --region $REGION --instance-ids "$instance_id" --query 'Reservations[].Instances[].InstanceType' --output text)
            EBS_OPTIMIZED=$(aws ec2 describe-instances --profile $PROFILE --region $REGION --instance-ids "$instance_id" --query 'Reservations[].Instances[].EbsOptimized' --output text)
            TOTAL_VOL_SIZE=$total
            PRIVATE_IP=$(aws ec2 describe-instances --profile $PROFILE --region $REGION --instance-ids "$instance_id" --query 'Reservations[].Instances[].PrivateIpAddress' --output text)
            VPC_ID=$(aws ec2 describe-instances --profile $PROFILE --region $REGION --instance-ids "$instance_id" --query 'Reservations[].Instances[].VpcId' --output text)
            SUBNET_ID=$(aws ec2 describe-instances --profile $PROFILE --region $REGION --instance-ids "$instance_id" --query 'Reservations[].Instances[].SubnetId' --output text)
            KEYPAIR=$(aws ec2 describe-instances --profile $PROFILE --region $REGION --instance-ids "$instance_id" --query 'Reservations[].Instances[].KeyName' --output text)
            OS=$(aws ec2 describe-instances --profile $PROFILE --region $REGION --instance-ids "$instance_id" --query 'Reservations[].Instances[].PlatformDetails' --output text)
            SSM_VERSION=$(aws ssm describe-instance-information --profile $PROFILE --region $REGION --query 'InstanceInformationList[].AgentVersion' --output text)
            IS_SSM_LATEST=$(aws ssm describe-instance-information --profile $PROFILE --region $REGION --query 'InstanceInformationList[].IsLatestVersion' --output text)
            echo "$ACCOUNT_NUMBER,$REGION,$IMAGE_ID,$INSTANCE_ID,$INSTANCE_NAME,$INSTANCE_STATUS,$INSTANCE_TYPE,$EBS_OPTIMIZED,$TOTAL_VOL_SIZE,$PRIVATE_IP,$VPC_ID,$SUBNET_ID,$KEYPAIR,$OS,$SSM_VERSION,$IS_SSM_LATEST,$kmsId,$kmsAlias" >> "$output_file"
          done
      done
  done
# Send final confirmation after all data is written
echo "Data populated in "$output_file""

aws s3 cp $output_file s3://$BUCKET_NAME/ --profile $PROFILE

if [ $? -eq 0 ]
then
  echo "File uploaded successfully."
else
  echo "File upload failed."
fi
# Lists all instance ID's matching the filter variable in serial text format.
# for InstanceId in $(aws ec2 describe-instances --profile $PROFILE --region $REGION --query 'Reservations[].Instances[].InstanceId' --output text | tr '\n' ' ')
# for InstanceId in $(aws ec2 describe-instances --profile $PROFILE --region $REGION --query 'Reservations[].Instances[].InstanceId' | grep InstanceId | awk '{ print $2 }' | tr -d '",')
# for InstanceId in $(aws ec2 describe-instances --profile $PROFILE --region $REGION --query 'Reservations[].Instances[].InstanceId' --output text | paste -d " "  -s)
# https://stackoverflow.com/questions/64108467/retrieve-all-volume-ids-for-all-instances-that-match-a-tag-using-aws-cli