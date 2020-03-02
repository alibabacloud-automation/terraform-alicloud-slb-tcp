provider "alicloud" {
  profile                 = var.profile != "" ? var.profile : null
  shared_credentials_file = var.shared_credentials_file != "" ? var.shared_credentials_file : null
  region                  = var.region != "" ? var.region : null
  skip_region_validation  = var.skip_region_validation
  configuration_source    = "terraform-alicloud-modules/slb-tcp"
}

locals {
  listeners = [
    for obj in var.listeners :
    merge(
      {
        server_group_ids = module.slb.this_slb_virtual_server_group_id
        protocol         = "tcp"
      },
      obj,
    )
  ]
}

// Slb Module
module "slb" {
  source                          = "alibaba/slb/alicloud"
  region                          = var.region
  profile                         = var.profile
  shared_credentials_file         = var.shared_credentials_file
  skip_region_validation          = var.skip_region_validation
  use_existing_slb                = var.use_existing_slb
  existing_slb_id                 = var.existing_slb_id
  create                          = var.create_slb
  name                            = "TF-slb-tcp-module"
  address_type                    = var.address_type
  internet_charge_type            = var.internet_charge_type
  spec                            = var.spec
  bandwidth                       = var.bandwidth
  master_zone_id                  = var.master_zone_id
  slave_zone_id                   = var.slave_zone_id
  virtual_server_group_name       = var.virtual_server_group_name
  servers_of_virtual_server_group = var.servers_of_virtual_server_group
  tags = merge(
    {
      Create = "terraform-alicloud-slb-tcp-module"
    },
    var.tags,
  )
}

module "slb_tcp_listener" {
  source                  = "terraform-alicloud-modules/slb-listener/alicloud"
  create                  = var.create_slb || var.use_existing_slb ? var.create_tcp_listener : false
  profile                 = var.profile
  region                  = var.region
  shared_credentials_file = var.shared_credentials_file
  skip_region_validation  = var.skip_region_validation
  slb                     = module.slb.this_slb_id
  listeners               = local.listeners
  health_check            = var.health_check
  advanced_setting        = var.advanced_setting
}

