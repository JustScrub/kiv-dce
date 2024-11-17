# KIV/DCE Semestral Project

## Assignment

Implement an architecture with a configurable number of backends and one load balancer (e.g. NGINX). Use Terraform, Ansible, and Docker for the implementation, and use the university's OpenNebula instance on nuada.zcu.cz as the cloud service. Implement both the backend and the load balancer as containers that can be built and published in a repository on GitHub (see GitHub Actions).

## Solution

### Backends

Backend application is a simple python Flask app listening on port 7777 inside a docker container. When a GET request arrives, the application responds with a HTML encoded message inlcuding the backend's IP address (the host, not the container) and the accessed URL. The app and its Dockerfile have been taken from https://github.com/lvthillo/python-flask-docker and modified.

### Load Balancer

The load balancer application is a containerized NGINX server configured to serve as a reverse proxy for all requested paths. The actual upstream servers need to be specified on container creation by binding a config including those backends to the container's `/etc/nginx/conf.d/backend-upstream.conf` file. The container exposes port 80.

Note that this implementation is obsolete, since the reverse proxy configuration can also be mounted to the default NGINX image, so no new image needs to be built. The above implementation is done just to satisfy the assignment

### Automatic Image Creation

In the project's `.github/workflows` directory, there's a pipeline specification enabling the maintainers to build and publish the backend and load balancer images. The pipeline is triggered manually (`workflow_dispatch` event) or by pushing to the `release` branch. The steps in the pipeline are:

1. Checkout the repository to the pipeline's virtual machine
1. Login to the GitHub registry
1. Set names of the images: kiv-dce_bakcend and kiv-dce_load-balancer as environment variables
1. Build and push the backend image to the GitHub registry using the docker/build-push-action GitHub action
1. Build and push the load balancer image to the GitHub registry using the docker/build-push-action GitHub action
1. Generate attestation for both of the images

The resulting images can then be pulled from `ghcr.io/<username>/<repo-name>_backend:latest` and  `ghcr.io/<username>/<repo-name>_load-balancer:latest`, where `<username>` is your GitHub username in lowercase and `<repo-name>` is the name of the repository, as shown in the URL. For this repo, it would be:

- ghcr.io/justscrub/kiv-dce_load-balancer:latest
- ghcr.io/justscrub/kiv-dce_backend:latest

### Terraform

The terraform directory includes files necessary to initialize a terraform project. But before initialization, there are some steps to be done before-hand. 

First, in the root directory of the repository (at the same level as this README), create a `keys` directory. Generate SSH keys to the directory using e.g. ssh-keygen. **THE KEY FILE NAMES MUST BE** `dce_key` (private) and `dce_key.pub` (public)!! These will be used to SSH into your VMs (and are used by ansible). Try not to push the keys to a public repository (the top-level .gitignore should handle that). Then, go to the terraform directory, remove the `.template` suffix from `terraform.tfvars.template` and fill the values, including admin password (needs to be uncomented by deleting the hash character '#'). 
- one_username = login to your OpenNebula account
- one_password = valid authorization token generated in OpenNebula
- one_endpoint = the URL to your OpenNebula RPC interface
- vm_admin_pass = password of the admin account on your VMs ('nodeadm' by default)
- vm_backend_count = number of backend instances to spin up

There are more variables defined in the `variables.tf` file. You can look into those as well and if you wish, override their default values in the `terraform.tfvars` file.

The `provisioning-scripts` directory includes bash scripts that initialize the VMs: the admin user is created, your generated public key is added to the authorized keys of the VM and SSH root login is disabled. Also, docker is installed.

To deploy, run `terraform init` and then `terraform apply` from the terraform directory. Applying may fail, in that case, just rerun the command.

### Ansible

Once the VMs are deployed, they need to be provisioned using Ansible. 

First, Ansible needs to know the IPs of your backends and of your load balancer. The `ansible/gen_inventory.py` python script can be used to extract the addresses (Terraform stores them in a `terraform.tfstate` JSON file) and print the contents of a 'inventory' file to standard output. The script also adds the hosts to known_hosts of your SSH installation, because Ansible requires it. Run `python3 gen_inventory.py > inventory` from the ansible directory to extract the IPs and add them to known hosts. You can optionally copy the load balancer's IP address to the backends group to make it one of the backends.

After the inventory is created, you can run `ansible-playbook -i inventory app.yml` to provision the VMs.

Ansible downloads the UFW firewall and allows traffic on all necessary ports. Then proceeds to run the backend app / load balancer inside a docker container. The backend container is pulled from the GitHub container repository and run, with the 7777 (container) port mapped to host's 8080 port and the host's IP included in an environment variable. As for the load balancer, the NGINX upstream config is generated from the list of backend IPs and the load balancer container is run, binding the generated config to the container and publishing port 80.

### Done

As such, the project should be ready. You can now access the load balancer at `http://<load-balancer-ip>:80/<path>`. 