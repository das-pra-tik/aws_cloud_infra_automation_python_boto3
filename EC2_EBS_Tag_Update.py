import boto3
import os
import sys

aws_profile = 'tf-admin'
LOG_OUTPUT = r"C:\Users\prati\output.log"

# Array of all AWS Profiles in scope
# os.environ['AWS_PROFILE'] = "tf-admin"

with open(LOG_OUTPUT, 'w') as f:
    sys.stdout = f

# Get Region names
    
    for profile in aws_profile:
        PROFILE = profile
        region_session = boto3.Session(profile_name=PROFILE)
        region_client = region_session.client('ec2')

        list_of_all_Regions = []
        all_regions = region_client.describe_regions()
    
        for region in all_regions['Regions']:
            list_of_all_Regions.append(region['RegionName'])

        for each_region in list_of_all_Regions:
            EC2_RESOURCE = boto3.resource('ec2', each_region)

# Filter Out the EC2 instances based on the state - either Running or Stopped
            current_instances = [i for i in EC2_RESOURCE.instances.filter(Filters=[{'Name': 'instance-state-name', 'Values': ['running', 'stopped']}])]
            TAGS = [
                {
                    'Key': 'Department',
                    'Value': 'CIS - AWS Professional Svcs'
                }
            ]

            for instance in current_instances:
                instance.create_tags(Tags=TAGS)
                print(f'Tags successfully added to the instance {instance.id} in {each_region}')

                for volume in instance.volumes.all():
                    volume.create_tags(Tags=TAGS)
                    print(f'Tags successfully added to the volume {volume.id} in {each_region}')

f.close()