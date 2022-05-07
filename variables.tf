variable "region" {
  description = "(Deprecated from version 1.1.0) The region used to launch this module resources."
  type        = string
  default     = ""
}

variable "profile" {
  description = "(Deprecated from version 1.1.0) The profile name as set in the shared credentials file. If not set, it will be sourced from the ALICLOUD_PROFILE environment variable."
  type        = string
  default     = ""
}

variable "shared_credentials_file" {
  description = "(Deprecated from version 1.1.0) This is the path to the shared credentials file. If this is not set and a profile is specified, $HOME/.aliyun/config.json will be used."
  type        = string
  default     = ""
}

variable "skip_region_validation" {
  description = "(Deprecated from version 1.1.0) Skip static validation of region ID. Used by users of alternative AlibabaCloud-like APIs or users w/ access to regions that are not public (yet)."
  type        = bool
  default     = false
}

# Load Balancer Instance variables
variable "create_slb" {
  description = "Whether to create load balancer instance. If setting 'use_existing_slb = true' and 'existing_slb_id', it will be ignored."
  type        = bool
  default     = true
}

variable "use_existing_slb" {
  description = "Whether to use an existing load balancer instance. If true, 'existing_slb_id' should not be empty. Also, you can create a new one by setting 'create = true'."
  type        = bool
  default     = false
}

variable "existing_slb_id" {
  description = "An existing load balancer instance id."
  type        = string
  default     = ""
}

variable "name" {
  description = "The name of a new load balancer."
  type        = string
  default     = ""
}

variable "address_type" {
  description = "The type of address. Choices are 'intranet' and 'internet'. Default to 'internet'."
  type        = string
  default     = "internet"
}

variable "vswitch_id" {
  description = "The vswitch id used to launch load balancer."
  type        = string
  default     = ""
}

variable "internet_charge_type" {
  description = "The charge type of load balancer instance internet network."
  type        = string
  default     = "PayByTraffic"
}

variable "specification" {
  description = "The specification of the SLB instance."
  type        = string
  default     = "slb.s1.small"
}

variable "bandwidth" {
  description = "The load balancer instance bandwidth."
  type        = number
  default     = 10
}

variable "master_zone_id" {
  description = "The primary zone ID of the SLB instance. If not specified, the system will be randomly assigned."
  type        = string
  default     = ""
}

variable "slave_zone_id" {
  description = "The standby zone ID of the SLB instance. If not specified, the system will be randomly assigned."
  type        = string
  default     = ""
}

variable "virtual_server_group_name" {
  description = "The name virtual server group. If not set, the 'name' and adding suffix '-virtual' will return."
  type        = string
  default     = ""
}

variable "servers_of_virtual_server_group" {
  description = "A list of servers attaching to virtual server group, it's supports fields 'server_ids', 'weight'(default to 100), 'port' and 'type'(default to 'ecs')."
  type        = list(map(string))
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

# Listener common variables
variable "create_tcp_listener" {
  description = "Whether to create load balancer listeners."
  type        = bool
  default     = true
}

variable "listeners" {
  description = "List of slb listeners. Each item can set all or part fields of alicloud_slb_listener resource."
  type        = list(map(string))
  default     = []
}

variable "health_check" {
  description = "The slb listener health check settings to use on listeners. It's supports fields 'healthy_threshold','unhealthy_threshold','health_check_timeout', 'health_check', 'health_check_type', 'health_check_connect_port', 'health_check_domain', 'health_check_uri', 'health_check_http_code', 'health_check_method' and 'health_check_interval'"
  type        = map(string)
  default     = {}
}

variable "advanced_setting" {
  description = "The slb listener advanced settings to use on listeners. It's supports fields 'sticky_session', 'sticky_session_type', 'cookie', 'cookie_timeout', 'gzip', 'persistence_timeout', 'acl_status', 'acl_type', 'acl_id', 'idle_timeout' and 'request_timeout'."
  type        = map(string)
  default     = {}
}