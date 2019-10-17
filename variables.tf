variable "region" {
  default = "cn-bj2"
}

variable "az" {
  default = [
    "cn-bj2-05",
  ]
}

variable "project_id" {
  default = "org-hiny2f"
}

variable "ucloud_pubkey" {}


variable "ucloud_secret" {}

variable "root_password" {}

variable "image_id" {
  default = "uimage-ws0fvn2z"
}
variable "charge_type" {
  default = "dynamic"
}
variable "data_volume_size" {
  default = 500
}
variable "nameSrv_data_volume_size" {
  default = 20
}
variable "cluster_tag" {
  default = "Benchmark"
}
variable "instance_type" {
  default = "o-basic-8"
}

variable "instance_count" {
  default = 3
}

variable "allow_ip" {
  default = "0.0.0.0/0"
}
