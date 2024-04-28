import boto3

# Array of all AWS Profiles in scope
AWS_PROFILE = ['763475757927_GLD-RestrictedAdmin', '027549150804_GLD-RestrictedAdmin',
               '677561441012_GLD-RestrictedAdmin', '630514165234_GLD-RestrictedAdmin']

# Get Region names
for profile in AWS_PROFILE:
    PROFILE = profile
    AWS_ACCOUNT = boto3.client('sts').get_caller_identity().get('Account')
    session = boto3.Session(profile_name=PROFILE)
    client_obj = session.client('ec2')

    list_of_all_Regions = []
    all_regions = client_obj.describe_regions()

    for region in all_regions['Regions']:
        list_of_all_Regions.append(region['RegionName'])

    for this_region in list_of_all_Regions:
        AWS_REGION = this_region
        ssm_session = boto3.Session(
            profile_name=PROFILE, region_name=AWS_REGION)
        ssm_client = ssm_session.client('ssm')
        response = ssm_client.describe_instance_information()

# Get SSM Details
        for attr in response['InstanceInformationList']:
            print(
                AWS_ACCOUNT,
                AWS_REGION,
                attr['InstanceId'],
                attr['PingStatus'],
                attr['AgentVersion'],
                attr['IsLatestVersion'],
                attr['PlatformType'],
                attr['PlatformName'],
                attr['IPAddress'],
                attr['ComputerName']
            )
