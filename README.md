<!-- ABOUT THE PROJECT -->
## About The Project

This repo contains an example Terraform configuration that deploys Application Load Balancer, two EC2 instances and a MySQL database (using RDS) in an Amazon Web Services account.

## Quick start

Configure your [AWS access 
keys](http://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) as 
environment variables:

```
export AWS_ACCESS_KEY_ID=(your access key id)
export AWS_SECRET_ACCESS_KEY=(your secret access key)
```

Configure the database credentials as environment variables:

```
export TF_VAR_db_username=(desired database username)
export TF_VAR_db_password=(desired database password)
```

Deploy the code:

```
terraform init
terraform apply
```

Clean up when you're done:

```
terraform destroy
```


## Future Tasks

1. Manage TF State in a S3 Bucket (use remote state with versioning).
2. Refactor main.tf using modules and export more values as variables in corresponding folders.
3. Manage credentials (aws credentials, db credentials) using AWS Secrets manager, for example.
4. Make the blog post from the task (blog post about Linux namespaces) appear instead of "hello-world" post on startup.
5. Finish task about OPTIMIZE-ing all of the db tables.
6. Find and implement better networking solutions and practices - separate vpc, public and private subnets, etc. 
7. Automate the flow using GitHub Actions.
