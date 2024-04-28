import boto3
import pprint

session = boto3.Session(profile_name='tf-admin', region_name='us-east-1')
s3_client = session.client('s3')
response = s3_client.list_buckets()['Buckets']
pprint.pprint(response)
for bucket in response:
    pprint.pprint(bucket['Name'])
    pprint.pprint(bucket['CreationDate'])

