single command app deployment

# with regular EC2 instances
## terraform to deploy
VPC, subnet, IGW, default route, security group, EC2 instance, user-data (init script)
## init script to
set environment variables for instance ROLE (WEB or DB), and DB instance IP  
install git  
git clone code repo and run deploy.sh from the repo
## deploy.sh to
### common
set DB instance IP, username, password
### on WEB instance:
get sample repo from github  
deploy sample app  
update database config with DB instance IP, username, password
### on DB instance:
deploy postgresql  
create user with permission to create DB

# how to
## deploy the application, and all its dependencies
pushd terraform; echo "yes" | terraform apply -input=false -var aws_profile=<AWS_PROFILE_NAME> -var key_name=<SSH_KEY_NAME>  
AWS_PROFILE_NAME should already be configured in your ~/.aws/credentials file  
SSH_KEY_NAME should be present in your AWS EC2 key_pairs  
DB_IP=$(terraform  output -json | jq -r ".db_public_ip | .value | .[0]"); WEB_IP=$(terraform  output -json | jq -r ".web_public_ip | .value | .[0]"); cat ../ansible/inventory.tpl | sed -e 's/##WEB_IP##/'"$WEB_IP"'/' -e 's/##DB_IP##/'"$DB_IP"'/' > ../ansible/inventory  

# problems:
## complex setup for access to private github repo that contains the sample app
Workaround such as tar and scp the sample app to the web server from an admin machine, where the credentials have been manually set up and cached, is possible, but that couples the IAC solution with the admin machine. The credential has to be entered somewhere manually, in AWS codepipeline, or as a Jenkins credentail.

