
# get SSH keys into ./keys
# create terraform/terraform.tfvars with the correct values

cd terraform
terraform init
terraform apply -auto-approve
cd ..

cd ansible
python gen_inventory.py ../terraform/terraform.tfstate > inventory
ansible-playbook -i inventory app.yml
cd ..
