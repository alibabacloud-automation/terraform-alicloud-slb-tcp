data "alicloud_slb_zones" "default" {
  available_slb_address_type       = "classic_internet"
  available_slb_address_ip_version = "ipv4"
}

data "alicloud_images" "default" {
  name_regex = "^centos_6"
}

data "alicloud_instance_types" "default" {
  availability_zone = data.alicloud_slb_zones.default.zones.0.id
}

resource "alicloud_slb_acl" "default" {
  name       = var.name
  ip_version = "ipv4"
}

module "vpc" {
  source             = "alibaba/vpc/alicloud"
  create             = true
  vpc_cidr           = "172.16.0.0/12"
  vswitch_cidrs      = ["172.16.0.0/21"]
  availability_zones = [data.alicloud_slb_zones.default.zones.0.id]
}

module "security_group" {
  source = "alibaba/security-group/alicloud"
  vpc_id = module.vpc.this_vpc_id
}

module "ecs_instance" {
  source = "alibaba/ecs-instance/alicloud"

  number_of_instances = 1

  instance_type      = data.alicloud_instance_types.default.instance_types.0.id
  image_id           = data.alicloud_images.default.images.0.id
  vswitch_ids        = module.vpc.this_vswitch_ids
  security_group_ids = [module.security_group.this_security_group_id]
}

module "slb_instance" {
  source = "../.."

  #slb
  create_slb       = true
  use_existing_slb = false

  name                 = var.name
  address_type         = "internet"
  internet_charge_type = "PayByTraffic"
  specification        = var.specification
  bandwidth            = var.bandwidth
  master_zone_id       = data.alicloud_slb_zones.default.zones.0.master_zone_id 
  slave_zone_id        = data.alicloud_slb_zones.default.zones.0.slave_zone_id
  tags                 = var.tags

  #slb_tcp_listener
  create_tcp_listener = false

}

module "slb_tcp" {
  source = "../.."

  #slb
  create_slb       = false
  use_existing_slb = true

  existing_slb_id           = module.slb_instance.this_slb_id
  virtual_server_group_name = var.virtual_server_group_name
  servers_of_virtual_server_group = [
    {
      server_ids = module.ecs_instance.this_instance_id[0]
      port       = var.port
      weight     = var.weight
      type       = "ecs"
  }]

  #slb_tcp_listener
  create_tcp_listener = true

  listeners = [
    {
      backend_port  = "80"
      frontend_port = "80"
      bandwidth     = var.bandwidth
      scheduler     = var.scheduler
    }
  ]
  health_check = {
    health_check              = var.health_check
    healthy_threshold         = var.healthy_threshold
    unhealthy_threshold       = var.unhealthy_threshold
    health_check_timeout      = var.health_check_timeout
    health_check_interval     = var.health_check_interval
    health_check_connect_port = var.health_check_connect_port
    health_check_domain       = var.health_check_domain
    health_check_uri          = var.health_check_uri
    health_check_http_code    = var.health_check_http_code
    health_check_type         = var.health_check_type
    health_check_method       = var.health_check_method
  }
  advanced_setting = {
    sticky_session      = var.sticky_session
    sticky_session_type = var.sticky_session_type
    cookie              = var.cookie
    cookie_timeout      = var.cookie_timeout
    gzip                = var.gzip
    persistence_timeout = var.persistence_timeout
    established_timeout = var.established_timeout
    acl_status          = var.acl_status
    acl_type            = var.acl_type
    acl_id              = alicloud_slb_acl.default.id
    idle_timeout        = var.idle_timeout
    request_timeout     = var.request_timeout
  }

}