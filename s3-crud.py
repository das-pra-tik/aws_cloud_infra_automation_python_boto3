import boto3
import pprint

session = boto3.Session(profile_name='aws-cloud', region_name='us-east-1')
sts_client = session.client('sts')
response = sts_client.assume_role(
    RoleArn='arn:aws:iam::502433561161:role/aws-cloud',
    RoleSessionName='python-boto3')

aws_access_key_id = response['Credentials']['AccessKeyId']
aws_secret_access_key = response['Credentials']['SecretAccessKey']
aws_session_token = response['Credentials']['SessionToken']

new_session = boto3.Session(aws_access_key_id=aws_access_key_id,
                            aws_secret_access_key=aws_secret_access_key,
                            aws_session_token=aws_session_token,
                            region_name='us-east-1')

S3_BUCKET = 'valaxy-technologies-docker-kubernetes'

s3_obj = new_session.client('s3')
response = s3_obj.create_bucket(
    ACL='private',
    Bucket={S3_BUCKET}
)
pprint.pprint(response)

with open('ec2_info.csv', 'rb') as f:
    data = f.read()

upload = s3_obj.put_object(
    ACL='private',
    Bucket={S3_BUCKET},
    Body=data,
    Key='ec2_info.csv',
    ServerSideEncryption='AES256',
    StorageClass='STANDARD'
)
pprint.pprint(upload)

"""
delete = s3_obj.delete_object(
    Bucket={S3_BUCKET},
    Key='ec2_info.csv'
)
pprint.pprint(delete)

response = s3_obj.delete_bucket(
    Bucket={S3_BUCKET}
)
"""
