provider "aws" {
  default_tags {
    tags = {
      Id    = local.identifier
      Owner = local.email
    }
  }
}

locals {
  identifier   = var.identifier # this is a random unique string that can be used to identify resources in the cloud provider
  category     = "os"
  example      = "slemicro55"
  email        = "terraform-ci@suse.com"
  project_name = "tf-${substr(md5(join("-", [local.category, local.example, md5(local.identifier)])), 0, 5)}-${local.identifier}"
  username     = lower(substr("tf-${local.identifier}", 0, 32))
  image        = "sle-micro-55" # BYOS = Bring Your Own Subscription, only use this if you have a subscription with SUSE or plan to get one directly rather than going through AWS
  ip           = chomp(data.http.myip.response_body)
  ssh_key      = var.key
  ssh_key_name = var.key_name
}

data "http" "myip" {
  url = "https://ipinfo.io/ip"
  retry {
    attempts     = 2
    min_delay_ms = 1000
  }
}


resource "random_pet" "server" {
  keepers = {
    # regenerate the pet name when the identifier changes
    identifier = local.identifier
  }
  length = 1
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "access" {
  source                     = "rancher/access/aws"
  version                    = "v3.0.1"
  vpc_name                   = "${local.project_name}-vpc"
  vpc_public                 = true
  security_group_name        = "${local.project_name}-sg"
  security_group_type        = "project"
  load_balancer_use_strategy = "skip"
}

module "this" {
  depends_on = [
    module.access,
  ]
  source = "../../../" # change this to "rancher/server/aws" per https://registry.terraform.io/modules/rancher/server/aws/latest
  # version = "v1.1.1" # when using this example you will need to set the version
  image_type                 = local.image
  server_name                = "${local.project_name}-${random_pet.server.id}"
  server_type                = "small"
  subnet_name                = keys(module.access.subnets)[0]
  security_group_name        = module.access.security_group.tags_all.Name
  direct_access_use_strategy = "ssh"  # either the subnet needs to be public or you must add an eip
  cloudinit_use_strategy     = "skip" # this version of SLE Micro doesn't support cloud-init
  server_access_addresses = {         # you must include ssh access here to enable setup
    "runner" = {
      port      = 22
      protocol  = "tcp"
      ip_family = "ipv4"
      cidrs     = ["${local.ip}/32"]
    }
  }
  server_user = {
    user                     = local.username
    aws_keypair_use_strategy = "select"
    ssh_key_name             = local.ssh_key_name
    public_ssh_key           = local.ssh_key
    user_workfolder          = "/home/${local.username}"
    timeout                  = 5
  }
}
