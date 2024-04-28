import boto3

aws_profile = 'tf-admin'
session = boto3.Session(profile_name=aws_profile)
def create_iam_user(username):
    iam_client = session.client('iam')
    response = iam_client.create_user(UserName=username)
    print(response)

create_iam_user('374278-boto3-demo')