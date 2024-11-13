variable "one_endpoint"  {
    description = "Open Nebula endpoint URL"
    default = "https://your-opennebula-server/RPC2"
}
variable "one_username"  {
    description = "Open Nebula username"
}
variable "one_password"  {
    description = "Open Nebula login token"
}
variable "vm_ssh_pubkey_path" {
    description = "SSH public key used for login as root into the VM instance"
    default = "keys/id_dev.pub"
}
variable "vm_admin_user" {
    description = "Username of the admin user"
    default = "nodeadm"
  
}
variable "vm_admin_pass" {
    description = "Username of the admin user"
  
}
variable "vm_node_init_log" {
    description = "Node initialization log file"
    default = "/var/log/node-init.log"
}
variable "vm_network_id" {
    description = "ID of the virtual network to attach to the virtual machine"
    default = 3 # => "vlan173"
}
variable "vm_backend_count" {
    description = "Number of instances to create"
    type = number
    default = 1
}
# variable "vm_imagedatastore_id" {
#     description = "Open Nebula datastore ID"
#     default = 109 # => "nuada_ssd"
# }
# variable "vm_image_name" {
#     description = "VM OS image name"
# }
# variable "vm_image_url"  {
#     description = "VM OS image URL"
# }
