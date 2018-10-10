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
clone sample app repo
deploy sample app
### on DB instance:
deploy postgresql
create user with permission to create DB
