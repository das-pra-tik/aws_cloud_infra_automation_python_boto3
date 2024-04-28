import boto3

# Array of all AWS Profiles in scope

aws_profile = ['763475757927_GLD-RestrictedAdmin',
               '027549150804_GLD-RestrictedAdmin',
               '677561441012_GLD-RestrictedAdmin',
               '630514165234_GLD-RestrictedAdmin']

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
        AWS_REGION = each_region
        ec2_session = boto3.Session(
            profile_name=PROFILE, region_name=AWS_REGION)
        ec2_client = ec2_session.client('ec2')
        response = ec2_client.describe_instances()

# Get Instance Details

        for instance in response['Reservations']:
            for attr in instance['Instances']:
                if 'KeyName' not in attr:
                    attr['KeyName'] = 'None'
                else:
                    attr['KeyName'] = attr['KeyName']
                for name in attr['Tags']:
                    if name['Key'] == 'Name':
                        print(
                            instance['OwnerId'],
                            AWS_REGION,
                            name['Value'],
                            attr['InstanceId'],
                            attr['EbsOptimized'],
                            attr['InstanceType'],
                            attr['PlatformDetails'],
                            attr['PrivateIpAddress'],
                            attr['VpcId'],
                            attr['SubnetId'],
                            attr['State']['Name'],
                            attr['Placement']['AvailabilityZone'],
                            attr['KeyName']
                        )
