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

resource "proxmox_virtual_environment_vm" "dev-vm" {
	vm_id = var.vm_id
	name  = "hb-test-semaphore"
	tags  = ["terraform", "dev", "semaphore"]
	bios  = "ovmf"
	machine   = "q35"
	node_name = "dev-worker-2"
	description = "ABCD"

	agent {
		enabled = true
	}

	clone {
		# Cloned template data
		datastore_id = "cephrbd"
		retries	     = 3
		vm_id        = "1003"
		full         = true
	}

	# Cloud-init
	initialization {
		datastore_id = "cephrbd"

		ip_config {
			ipv4 {
				# address = var.ip_address
        		address = "10.103.52.59/20"
				gateway = "10.103.48.1"
			}
    	}
	}
}