variable "profile" {
  default = "default"
}
variable "region" {
  default = "cn-hangzhou"
}
variable "zone_id" {
  default = "cn-hangzhou-h"
}
variable "name" {
  default = "terraform_test_001"
}
provider "alicloud" {
  region  = var.region
  profile = var.profile
}

#############################################################
# Data sources to get VPC, vswitch and default security group details
#############################################################

data "alicloud_vpcs" "default" {
  is_default = true
}

resource "alicloud_vpc" "default" {
  count = length(data.alicloud_vpcs.default.ids) > 0 ? 0 : 1
  vpc_name = var.name
  cidr_block = "172.16.0.0/12"
}

data "alicloud_security_groups" "default" {
  name_regex = "default"
  vpc_id     = data.alicloud_vpcs.default.ids.0
}

resource "alicloud_security_group" "default" {
  count = length(data.alicloud_security_groups.default.ids) > 0 ? 0 : 1
  name        = "tf_test_foo"
  description = "foo"
  vpc_id       = length(data.alicloud_vpcs.default.ids) > 0 ? data.alicloud_vpcs.default.ids.0 : concat(alicloud_vpc.default.*.id, [""])[0]
}


data "alicloud_vswitches" "default" {
  is_default = true
  zone_id    = var.zone_id
}

// If there is no default vswitch, create one.
resource "alicloud_vswitch" "default" {
  count             = length(data.alicloud_vswitches.default.ids) > 0 ? 0 : 1
  availability_zone = var.zone_id
  vpc_id            = data.alicloud_vpcs.default.ids.0
  cidr_block        = cidrsubnet(data.alicloud_vpcs.default.vpcs.0.cidr_block, 4, 15)
}

// ECS Module
module "ecs_instance" {
  source                      = "alibaba/ecs-instance/alicloud//modules/x86-architecture-general-purpose"
  profile                     = var.profile
  region                      = var.region
  number_of_instances         = 2
  instance_type_family        = "ecs.g6"
  vswitch_id                  = length(data.alicloud_vswitches.default.ids) > 0 ? data.alicloud_vswitches.default.ids.0 : concat(alicloud_vswitch.default.*.id, [""])[0]
  security_group_ids          = length(data.alicloud_security_groups.default.ids) > 0 ? data.alicloud_security_groups.default.ids : alicloud_security_group.default.*.id
  associate_public_ip_address = true
  internet_max_bandwidth_out  = 10
}

module "slb_tcp" {
  source              = "../../"
  profile             = var.profile
  region              = var.region
  create_slb          = true
  create_tcp_listener = true
  specification       = "slb.s2.small"
  servers_of_virtual_server_group = [
    {
      server_ids = join(",", module.ecs_instance.this_instance_id)
      port       = "80"
      weight     = "100"
      type       = "ecs"
    },
  ]
  listeners = [
    {
      backend_port      = "90"
      frontend_port     = "90"
      bandwidth         = "-1"
      scheduler         = "wrr"
      healthy_threshold = "4"
      gzip              = "false"
    }
  ]
  health_check = {
    healthy_threshold         = "3"
    unhealthy_threshold       = "3"
    health_check_timeout      = "5"
    health_check_interval     = "2"
    health_check              = "on"
    health_check_connect_port = "80"
    health_check_uri          = "/"
    health_check_http_code    = "http_2xx"
  }
  advanced_setting = {
    sticky_session      = "on"
    sticky_session_type = "insert"
    cookie              = "testslblistenercookie"
    cookie_timeout      = "86400"
    gzip                = "false"
  }
}
