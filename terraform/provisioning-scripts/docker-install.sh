mkdir /tmp/docker-install
cd /tmp/docker-install

# on nuada.kiv.zcu.cz OpenNebula VMs, normal docker installation does not work
# so we need to install docker from .deb packages

wget https://download.docker.com/linux/ubuntu/dists/jammy/pool/stable/amd64/containerd.io_1.7.22-1_amd64.deb
wget https://download.docker.com/linux/ubuntu/dists/jammy/pool/stable/amd64/docker-ce-cli_27.3.1-1~ubuntu.22.04~jammy_amd64.deb 
wget https://download.docker.com/linux/ubuntu/dists/jammy/pool/stable/amd64/docker-ce_27.3.1-1~ubuntu.22.04~jammy_amd64.deb   
wget https://download.docker.com/linux/ubuntu/dists/jammy/pool/stable/amd64/docker-buildx-plugin_0.17.1-1~ubuntu.22.04~jammy_amd64.deb  
wget https://download.docker.com/linux/ubuntu/dists/jammy/pool/stable/amd64/docker-compose-plugin_2.29.7-1~ubuntu.22.04~jammy_amd64.deb 

sudo dpkg -i containerd.io_1.7.22-1_amd64.deb docker-ce-cli_27.3.1-1~ubuntu.22.04~jammy_amd64.deb docker-ce_27.3.1-1~ubuntu.22.04~jammy_amd64.deb docker-buildx-plugin_0.17.1-1~ubuntu.22.04~jammy_amd64.deb docker-compose-plugin_2.29.7-1~ubuntu.22.04~jammy_amd64.deb

sudo systemctl enable docker