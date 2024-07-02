Prerequisities

You should have the following tools installed in your system:
 - zip
 - pip
 - terraform

Before deploying lambda, run package.sh file.

To deploy, run "terraform apply". This will deploy the infrastructural changes, if this is the first time you are running this command, as well as the latest lambda code.

Connecting to the cluster (MongoDB Compass):
 - configure SSH tunneling (use host IP of the bastion server, "ubuntu" for username and your private key)
 - provide connection string as follows: 