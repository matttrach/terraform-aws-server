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
  category     = "basic"
  example      = "basic"
  email        = "terraform-ci@suse.com"
  project_name = "tf-${substr(md5(join("-", [local.category, local.example, md5(local.identifier)])), 0, 5)}-${local.identifier}"
  image        = "sles-15"
  subnet       = module.access.subnets[keys(module.access.subnets)[0]]
}

resource "random_pet" "server" {
  keepers = {
    # regenerate the pet name when the identifier changes
    identifier = local.identifier
  }
  length = 1
}

module "access" {
  source                     = "rancher/access/aws"
  version                    = "v3.0.2"
  vpc_name                   = "${local.project_name}-vpc"
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
  image_type          = local.image
  server_name         = "${local.project_name}-${random_pet.server.id}"
  server_type         = "small"
  subnet_name         = keys(module.access.subnets)[0]
  private_ip          = cidrhost(local.subnet.cidrs.ipv4, 5)
  security_group_name = module.access.security_group.tags_all.Name
}
