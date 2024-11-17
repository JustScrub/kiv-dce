# do not run this script, it is just a reference

# get SSH keys into ./keys
# create terraform/terraform.tfvars with the correct values
# install terraform and ansible (requires sshpass)

cd terraform
terraform init
terraform apply -auto-approve
cd ..

cd ansible
python gen_inventory.py ../terraform/terraform.tfstate > inventory
ansible-playbook -i inventory app.yml
cd ..
