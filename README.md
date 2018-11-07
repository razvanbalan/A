Concordia project
This repo contains the necessary source code for deploying the infrastructure in different AWS accounts. This is useful for different scenarios:
1. Disaster recovery
2. Initial deployment  

The tools that are used are:
- Terraform
- AWS CLI

Steps to install AWS CLI on the right corner up Windows 64 bit version installer.

https://aws.amazon.com/cli/?tag=duckduckgo-d-20

Check the installation using the command:   
aws s3 ls  

Not working, run: 
aws configure

This command will require programatic keys to be introduced.
Warning: These keys will never leave the local computer where the aws cli is installed and will never be pushed to Git repos.  
How to get programatic keys?Follow this guide(start from minute 3:30 https://www.youtube.com/watch?v=vO88HHM9oY4)
The default region used is Frankfurt eu-central-1.



Terraform installation  

https://www.terraform.io/intro/getting-started/install.html

There are two main commands provided by terraform: plan and apply. You can visualize the changes using the first command and you can apply the changes using the second one. There is another powerful command destroy that will destroy the insfrastructure defined in the main terraform file.  
Once you have terraform up & running please proceed with the next steps.  


Where do I get the main file?
https://bitbucket.endava.com/projects/MYI/repos/concordia/browse/terraform
The repository contains the following files:
main.tf  
This file contains the necessary infrastructure software and virtualized that will be created in the destination AWS account. The output of the file will write at the console all the endpoints exposed by the virtualized infrastructure deployed in the target AWS account.
endava_cloud.tfvars
This file contains the destination AWS account details. Please see the file comments that provides all the necessary details.  
vars.tf  
This file contains the variables needed by the virtualized infrastructure to be configured. Please see the inline description. There are different configurations that can be passed when running the terraform apply command and will override the default ones. If no default value is provided, then a prompt will need the value to be captured from console.  

Note: To deploy different artefacts like AWS Lambda functions or database structures, the artefacts needs to be generated upfront running the terraform commands. This can be extended using a CI pipeline that generates all the artefacts needed and can be downloaded from S3.  This example provides a simple example on using the artefacts already generated.  

What command should I run to make the magic happend?

