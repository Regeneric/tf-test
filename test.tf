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

variable "disk_count" {
    type = number
    default = 0
}

variable "disk_size" {
    type = number
    default = 32
}


# Variable Definitions
# Shared storage
variable "user_drives" {
  type = map(string)
  description = "Every user has one shared drive mapped to him"

  default = {
    hbatkiewicz  = "vm-404-disk-1"
    mkasinski    = "vm-404-disk-2"
    wszczepanski = "vm-404-disk-3"
    nmiazek      = "vm-404-disk-4"
  }
}

variable "nodes" {
  type = map(string)

  default = {
    dev-worker-1 = "10.103.11.1"
    dev-worker-2 = "10.103.11.2"
    dev-worker-3 = "10.103.11.3"
  }
}

variable "user_name" {
    type = string
}


resource "proxmox_virtual_environment_vm" "semaphore-dev-vm" {
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

	disk {
		datastore_id 	  = "cephrbd"
		path_in_datastore = var.user_drives["${var.user_name}"]
		interface 		  = "scsi2"
		file_format		  = "raw"
	}

    dynamic "disk" {
        for_each = [ for i in range(0, var.disk_count) : i ]
        content {
            datastore_id = "cephrbd"
            size = var.disk_size
            interface = "scsi${disk.value+3}"
        }
    }

	# Cloud-init
	initialization {
		datastore_id = "cephrbd"

		ip_config {
			ipv4 {
				address = "dhcp"
			}
    	}
	}
}