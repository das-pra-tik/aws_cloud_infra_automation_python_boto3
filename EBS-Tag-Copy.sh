#!/bin/bash

# Declaring Variables
instanceID="i-02491da65eeee1843"
declare -a OLD_VOL_IDs=("vol-06d451dafec206eb8" "vol-0050e42d1c3340889" "vol-01505eab426cfd21b")
declare -a VOL_SIZEs=(25 35 45)
VOL_TYPE="gp3"
KMS_KEY_ID="18e5b602-3d02-4b3b-9773-38a604adf51b"

# Specify the AWS Profiles and Region
AWS_PROFILE='tf-admin'
REGION='us-east-1'
AZ='us-east-1a'

length=${#OLD_VOL_IDs[@]}

for (( j=0; j<length; j++ ));
    do
        declare -a DRIVE_MAP=([0]='xvdf' [1]='xvdg' [2]='xvdh')   
        # Creating the EBS Volume
        aws ec2 create-volume --volume-type $VOL_TYPE --size ${VOL_SIZEs[$j]} --availability-zone $AZ --profile $AWS_PROFILE --region $REGION --encrypted --kms-key-id $KMS_KEY_ID --tag-specification "ResourceType=volume,Tags=[{Key=Index,Value=$j}]"
        # Storing the value of Volume ID in variable volumeID
        volumeID=`aws ec2 describe-volumes  --query "Volumes[*].VolumeId" --profile $AWS_PROFILE --region $REGION --filters "Name=tag:Index,Values=$j" | sed -n 2p | tr -d \"`
        # Copying tags from old volume to new Volume
        aws ec2 describe-tags --filters Name=resource-id,Values=${OLD_VOL_IDs[$j]} --query 'Tags[].{Key:Key,Value:Value}' --profile $AWS_PROFILE --region $REGION > tags.json
        aws ec2 create-tags --resources $volumeID --tags file://tags.json --profile $AWS_PROFILE --region $REGION
        aws ec2 delete-tags --resources $volumeID --tags Key=Index --profile $AWS_PROFILE --region $REGION
        # Attaching the EBS Volume to the instance
        aws ec2 attach-volume --device ${DRIVE_MAP[$j]} --instance-id $instanceID --volume-id $volumeID --profile $AWS_PROFILE --region $REGION
    done

# Feedback to user
echo "All EBS Volumes created and Tags copied"

