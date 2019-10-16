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
  default = "uimage-cvaw3u33"
}
variable "charge_type" {
  default = "hour"
}
variable "data_volume_size" {
  default = 500
}

variable "cluster_tag" {
  default = "Benchmark"
}
variable "instance_type" {
  default = "o-highmem-4"
}

variable "instance_count" {
  default = 3
}


