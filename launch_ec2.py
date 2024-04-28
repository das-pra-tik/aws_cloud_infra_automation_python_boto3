import boto3
import os
client = boto3.client('ec2')

response = client.run_instances(ImageId='ami-467ca739',
                     InstanceType='t2.micro',
                     MinCount=1,
                     MaxCount=1)
for instance in response['Instances']:
    print(instance['InstanceId'])