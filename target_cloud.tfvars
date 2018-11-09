# the region to deploy in the target account. Default Frankfurt. In case of region failure, this parameter should be modified with a healthy region.
region                  = "eu-central-1"
# the file that contains the credentials and different profiles with programmatic keys to connect to AWS environments.
shared_credentials_file = "/.aws/credentials"
# the profile used by terraform that is configured in the file above where the artefacts/services will be deployed.
profile                 = "aws_target_profile"
# account id in the target aws account. This below is specific to target cloud account.
accountId				= "0092898xxxxx"
# the stage name for api gw 
stage_name				= "test"
