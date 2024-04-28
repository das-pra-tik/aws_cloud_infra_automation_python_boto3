import boto3
import json
import pprint

# AWS_ACCOUNT_ID='502433561161'
# ROLE_NAME='aws-cloud'

session = boto3.Session(profile_name='aws-cloud',region_name='us-east-1')
sts_client = session.client('sts')
response = sts_client.assume_role(
    RoleArn='arn:aws:iam::502433561161:role/aws-cloud',
    RoleSessionName='python-boto3')

aws_access_key_id=response['Credentials']['AccessKeyId']
aws_secret_access_key=response['Credentials']['SecretAccessKey']
aws_session_token=response['Credentials']['SessionToken']

new_session = boto3.Session(aws_access_key_id=aws_access_key_id,
                            aws_secret_access_key=aws_secret_access_key,
                            aws_session_token=aws_session_token,
                            region_name='us-east-1')
ec2_obj = new_session.client('ec2')
for response in ec2_obj.describe_instances()['Reservations']:
    # pprint.pprint(response)
    for each_instance in response['Instances']:
        print(each_instance['InstanceId'],each_instance['PrivateIpAddress'],each_instance['State']['Name'])

print("--------------------------------------------------------------------")
        
s3_obj = new_session.client('s3')
buckets = s3_obj.list_buckets()['Buckets']
s3_count = 0
for each_bucket in buckets:
    print(each_bucket['Name'],each_bucket['CreationDate'])
    s3_count = s3_count + 1
print(f'Total Count of S3 Buckets: {s3_count}')
