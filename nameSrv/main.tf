provider "ucloud" {
  region      = "${var.region}"
  project_id  = var.project_id
  public_key  = var.ucloud_pubkey
  private_key = var.ucloud_secret

}
# create VPC
resource "ucloud_vpc" "default" {
  name = "tf-example-intranet-cluster"
  tag  = "tf-example"

  # vpc network
  cidr_blocks = ["192.168.0.0/16"]
}

# Subnet to VPC
resource "ucloud_subnet" "default" {
  name = "tf-example-intranet-cluster"
  tag  = "tf-example"

  cidr_block = "192.168.1.0/24"

  vpc_id = "${ucloud_vpc.default.id}"
}

resource "ucloud_instance" "broker" {

  count = var.instance_count

  name = "rocketmq_broker_${count.index}"

  availability_zone = var.az[count.index % length(var.az)]

  image_id = var.image_id

  vpc_id = "${ucloud_vpc.default.id}"

  instance_type = var.instance_type

  root_password = var.root_password

  charge_type = var.charge_type

  subnet_id = "${ucloud_subnet.default.id}"

  data_disk_size = var.data_volume_size

  provisioner "local-exec" {

    command = "sleep 10"

  }
}
resource "ucloud_eip" "broker" {

  count = var.instance_count

  internet_type = "bgp"

  charge_mode = "traffic"

  charge_type = "dynamic"

  bandwidth = 200

  tag = var.cluster_tag

}


resource "ucloud_eip_association" "broker_ip" {
  count       = var.instance_count
  eip_id      = ucloud_eip.broker[count.index].id
  resource_id = ucloud_instance.broker[count.index].id
}



locals {

  setup-scrip-path = "setup.sh"

}


resource "null_resource" "setup" {
  count = var.instance_count
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "root"
      password = var.root_password
      host     = ucloud_eip.broker[count.index].public_ip
    }
  }
}
