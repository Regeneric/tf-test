terraform {
	required_version = ">= 0.13.0"

	required_providers {
		proxmox = {
			source = "bpg/proxmox"
			version = "0.48.1"
		}
	}
}


provider "proxmox" {
endpoint  = "https://10.103.11.1:8006/api2/json"
	api_token = "hbatkiewicz@pve!test=c2111043-95cc-42f9-8bc2-2916319faacd"
	insecure  = true
	ssh {
		agent = true
		username = "root"
	}
}



variable "vm_id" {
    type = string
    default = "999"
}

variable "vm_name" {
    type = string
    default = "tf-vm"
}

variable "hv_node" {
    type = string
    default = "dev-worker-1"
}

variable "tmpl_id" {
    type = string
    default = "1000"
}

variable "vm_count" {
    type = string
    default = "1"
}

resource "proxmox_virtual_environment_vm" "dev-vm" {
	vm_id = var.vm_id
	name  = var.vm_name
    count = var.vm_count
	tags  = ["terraform", "dev", "semaphore"]
	bios  = "ovmf"
	machine   = "q35"
	node_name = var.hv_node
	description = ""

	agent {
		enabled = true
	}

	clone {
		# Cloned template data
		datastore_id = "cephrbd"
		retries	     = 3
		vm_id        = var.tmpl_id
		full         = true
	}

	# Cloud-init
	initialization {
		datastore_id = "cephrbd"

		ip_config {
			ipv4 {
				address = "dhcp"
        		# address = "10.103.52.59/20"
				# gateway = "10.103.48.1"
			}
    	}
	}
}