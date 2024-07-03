packer {
  required_version = ">= 1.7.0"
  required_plugins {
    parallels = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/parallels"
    }
    vagrant = {
      version = ">= 1.0.2"
      source  = "github.com/hashicorp/vagrant"
    }
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
  }
}

variable "machine_name" {
  type    = string
  default = ""
}

variable "machine_specs" {
  type = object({
    cpus      = number
    memory    = number
    disk_size = string
  })
  default = {
    cpus      = 2
    memory    = 2048
    disk_size = "65536"
  }
}

variable "boot_command" {
  type    = list(string)
  default = []
}

variable "boot_wait" {
  type    = string
  default = "20s"
}

variable "iso_url" {
  type = string
}

variable "iso_checksum" {
  type = string
}

variable "shutdown_timeout" {
  type    = string
  default = "15m"
}

variable "ssh_username" {
  type    = string
  default = ""
}

variable "addons" {
  type    = list(string)
  default = []
}

variable "create_vagrant_box" {
  type    = bool
  default = false
}

variable "output_directory" {
  type    = string
  default = ""
}

variable "output_vagrant_box" {
  type    = string
  default = ""
}


locals {
  machine_name = var.machine_name == "" ? "Windows 11 ARM64" : var.machine_name
  output_dir         = var.output_directory == "" ? "out" : var.output_directory
  vagrant_output_dir = var.output_vagrant_box == "" ? "${path.root}/box/${local.machine_name}.box" : "${var.output_vagrant_box}"

  boot_command = length(var.boot_command) == 0 ? [
    "<wait>"
  ] : var.boot_command
}

source "parallels-iso" "image" {
  guest_os_type          = "win-11"
  parallels_tools_flavor = "win-arm"
  parallels_tools_mode   = "attach"
  prlctl = [
    ["set", "{{ .Name }}", "--device-add", "cdrom", "--image", "/tmp/unattended.iso", "--connect"],
    ["set", "{{ .Name }}", "--efi-secure-boot", "on"], 
    ["set", "{{ .Name }}", "--tpm", "on"]
  ]
  prlctl_version_file       = ".prlctl_version"
  boot_command              = local.boot_command
  boot_wait                 = var.boot_wait
  cpus                      = var.machine_specs.cpus
  memory                    = var.machine_specs.memory
  disk_size                 = var.machine_specs.disk_size
  iso_checksum              = var.iso_checksum
  iso_url                   = var.iso_url
  output_directory          = local.output_dir
  shutdown_command          = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  shutdown_timeout          = var.shutdown_timeout

  communicator   = "winrm"
  winrm_username = "vagrant"
  winrm_password = "vagrant"
  winrm_port     = 5985
  winrm_timeout  = "30m"
  vm_name                   = local.machine_name
}

build {
  sources = [
    "source.parallels-iso.image"
  ]

  provisioner "ansible" {
    user                   = "vagrant"
    galaxy_file            = "./windows-requirements.yml"
    use_proxy              = false
    playbook_file          = "./playbook.yml"
    extra_arguments = [
      "--extra-vars", "use_proxy=false",
      "--extra-vars", "ansible_connection=winrm",
      "--extra-vars", "ansible_user='vagrant'",
      "--extra-vars", "ansible_password='vagrant'",
      "--extra-vars", "ansible_port='5985'",
      "--extra-vars", "build_username='vagrant'",
    ]
  }

  post-processor "vagrant" {
    compression_level    = 9
    keep_input_artifact  = false
    output               = local.vagrant_output_dir
  }
}