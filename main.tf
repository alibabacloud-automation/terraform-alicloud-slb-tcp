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
  source = "alibaba/slb/alicloud"

  create           = var.create_slb
  use_existing_slb = var.use_existing_slb

  existing_slb_id                 = var.existing_slb_id
  name                            = var.name
  address_type                    = var.address_type
  internet_charge_type            = var.internet_charge_type
  spec                            = var.specification
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
  source = "terraform-alicloud-modules/slb-listener/alicloud"
  create = var.create_slb || var.use_existing_slb ? var.create_tcp_listener : false

  slb              = module.slb.this_slb_id
  listeners        = local.listeners
  health_check     = var.health_check
  advanced_setting = var.advanced_setting
}