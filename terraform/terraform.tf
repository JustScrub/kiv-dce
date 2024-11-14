terraform {
  required_providers {
    opennebula = {
      source = "OpenNebula/opennebula"
      version = "~> 1.0"
    }
  }
}

provider "opennebula" {
  endpoint      = "${var.one_endpoint}"
  username      = "${var.one_username}"
  password      = "${var.one_password}"
}

# resource "opennebula_image" "os-image" {
#     name = "${var.vm_image_name}"
#     datastore_id = "${var.vm_imagedatastore_id}"
#     persistent = false
#     path = "${var.vm_image_url}"
#     permissions = "600"
# }

resource "opennebula_virtual_machine" "vm_backend" {
  # This will create 1 instance:
  count = var.vm_backend_count
  name = "dce-backend-${count.index + 1}"
  description = "DCE backend #${count.index + 1}"
  cpu = 1
  vcpu = 1
  memory = 1024
  permissions = "600"
  group = "users"

  context = {
    NETWORK  = "YES"
    HOSTNAME = "$NAME"
    SSH_PUBLIC_KEY = file("keys/dce_key.pub")
  }
  os {
    arch = "x86_64"
    boot = "disk0"
  }
  disk {
    image_id = 602 #opennebula_image.os-image.id
    target   = "vda"
    size     = 6000 # 16GB
  }

  graphics {
    listen = "0.0.0.0"
    type   = "vnc"
  }

  nic {
    network_id = var.vm_network_id
  }

  connection {
    type = "ssh"
    user = "root"
    host = "${self.ip}"
    private_key = file("keys/dce_key")
  }

  provisioner "file" {
    source = "provisioning-scripts/"
    destination = "/tmp"
  }
  provisioner "file" {
    source = "keys/dce_key.pub"
    destination = "/tmp/id_dev.pub"
  }

  provisioner "remote-exec" {
    inline = [
      "export INIT_USER=${var.vm_admin_user}",
      "export INIT_PASS=${var.vm_admin_pass}",
      "export INIT_PUBKEY=$(cat /tmp/id_dev.pub)",
      "export INIT_LOG=${var.vm_node_init_log}",
      "export INIT_HOSTNAME=${self.name}",
      "touch ${var.vm_node_init_log}",
      "sh /tmp/init-node.sh",
      "sh /tmp/init-users.sh",
      "reboot"
    ]
  }
}

resource "opennebula_virtual_machine" "vm_frontend" {
  count = 1
  name = "dce-frontend"
  description = "DCE frontend"
  cpu = 1
  vcpu = 1
  memory = 1024
  permissions = "600"
  group = "users"

  context = {
    NETWORK  = "YES"
    HOSTNAME = "$NAME"
    SSH_PUBLIC_KEY = file("keys/dce_key.pub")
  }
  os {
    arch = "x86_64"
    boot = "disk0"
  }
  disk {
    image_id = 602 #opennebula_image.os-image.id
    target   = "vda"
    size     = 6000 # 16GB
  }

  graphics {
    listen = "0.0.0.0"
    type   = "vnc"
  }

  nic {
    network_id = var.vm_network_id
  }

  connection {
    type = "ssh"
    user = "root"
    host = "${self.ip}"
    private_key = file("keys/dce_key")
  }

  provisioner "file" {
    source = "provisioning-scripts/"
    destination = "/tmp"
  }
  provisioner "file" {
    source = "keys/dce_key.pub"
    destination = "/tmp/id_dev.pub"
  }

  provisioner "remote-exec" {
    inline = [
      "export INIT_USER=${var.vm_admin_user}",
      "export INIT_PASS=${var.vm_admin_pass}",
      "export INIT_PUBKEY=$(cat /tmp/id_dev.pub)",
      "export INIT_LOG=${var.vm_node_init_log}",
      "export INIT_HOSTNAME=${self.name}",
      "touch ${var.vm_node_init_log}",
      "sh /tmp/init-node.sh",
      "sh /tmp/init-users.sh",
      "reboot"
    ]
  }
}

#-------OUTPUTS ------------

output "backed-ips" {
  value = "${opennebula_virtual_machine.vm_backend.*.ip}"
}

output "frontend-ips" {
  value = "${opennebula_virtual_machine.vm_frontend.*.ip}"
}