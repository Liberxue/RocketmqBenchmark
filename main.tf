
provider "ucloud" {
  region      = "${var.region}"
  project_id  = var.project_id
  public_key  = var.ucloud_pubkey
  private_key = var.ucloud_secret

}
# create VPC
resource "ucloud_vpc" "default" {
  name = "mq-benchmark-cluster"
  tag  = "mq-benchmark"

  # vpc network
  cidr_blocks = ["192.168.0.0/16"]
}

# Subnet to VPC
resource "ucloud_subnet" "default" {
  name = "mq-benchmark-cluster"
  tag  = "mq-benchmark"

  cidr_block = "192.168.1.0/24"

  vpc_id = "${ucloud_vpc.default.id}"
}

resource ucloud_security_group rocketmq_sg {
  rules {
    port_range = "22"
    protocol   = "tcp"
    cidr_block = var.allow_ip
    policy     = "accept"
  }

  rules {
    port_range = "9876"
    protocol   = "tcp"
    cidr_block = var.allow_ip
    policy     = "accept"
  }

  rules {
    port_range = "20000-50000"
    protocol   = "tcp"
    cidr_block = var.allow_ip
    policy     = "accept"
  }
}
# Rocketmq nameSrv
resource "ucloud_instance" "namesrv" {

  count = var.instance_count

  name = "rocketmq_nameSrv_${count.index}"

  availability_zone = var.az[count.index % length(var.az)]

  image_id = var.image_id

  vpc_id = "${ucloud_vpc.default.id}"

  instance_type = var.instance_type

  root_password = var.root_password

  charge_type = var.charge_type

  subnet_id = "${ucloud_subnet.default.id}"

  security_group = ucloud_security_group.rocketmq_sg.id

  provisioner "local-exec" {

    command = "sleep 10"

  }
}
# Create cloud disk
resource "ucloud_disk" "namesrv" {

  availability_zone = var.az[count.index % length(var.az)]

  count = var.instance_count

  name = "rocketmq_nameSrv_${count.index}"

  disk_type = "rssd_data_disk"

  disk_size = var.nameSrv_data_volume_size
}

# attach cloud disk to instance
resource "ucloud_disk_attachment" "namesrv" {
  count       = var.instance_count
  availability_zone = var.az[count.index % length(var.az)]
  disk_id           = ucloud_disk.namesrv[count.index].id
  instance_id       = ucloud_instance.namesrv[count.index].id
}

resource "ucloud_eip" "namesrv" {

  count = var.instance_count

  internet_type = "bgp"

  charge_mode = "traffic"

  charge_type = "dynamic"

  bandwidth = 200

  tag = var.cluster_tag

}


resource "ucloud_eip_association" "namesrvIP" {
  count       = var.instance_count
  eip_id      = ucloud_eip.namesrv[count.index].id
  resource_id = ucloud_instance.namesrv[count.index].id
}

resource "null_resource" "setup_namesvr" {
  count = var.instance_count
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "root"
      password = var.root_password
      host     = ucloud_eip.namesrv[count.index].public_ip
    }
    inline = [
      file("setup.sh"),
      file("startName.sh")
    ]
  }
}



# Rocketmq broker
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

  security_group = ucloud_security_group.rocketmq_sg.id

  provisioner "local-exec" {

    command = "sleep 10"

  }
}

# Create cloud disk
resource "ucloud_disk" "broker" {

  availability_zone = var.az[count.index % length(var.az)]

  count = var.instance_count

  name = "rocketmq_broker_${count.index}"

  disk_type = "rssd_data_disk"

  disk_size = var.data_volume_size
}

# attach cloud disk to instance
resource "ucloud_disk_attachment" "broker" {
  count       = var.instance_count
  availability_zone = var.az[count.index % length(var.az)]
  disk_id           = ucloud_disk.broker[count.index].id
  instance_id       =ucloud_instance.broker[count.index].id
}

resource "ucloud_eip" "broker" {

  count = var.instance_count

  internet_type = "bgp"

  charge_mode = "traffic"

  charge_type = "dynamic"

  bandwidth = 200

  tag = var.cluster_tag

}


resource "ucloud_eip_association" "brokerIP" {
  count       = var.instance_count
  eip_id      = ucloud_eip.broker[count.index].id
  resource_id = ucloud_instance.broker[count.index].id
}



# create broker conf

data "template_file" "make_broker_config" {
  count    = var.instance_count
  template = file("make_broker_config.sh")
  vars = {
    index     = count.index
    nameSrv0  = ucloud_instance.namesrv.*.private_ip[0]
    nameSrv1  = ucloud_instance.namesrv.*.private_ip[1]
    nameSrv2  = ucloud_instance.namesrv.*.private_ip[2]
    broker0   = ucloud_instance.broker.*.private_ip[0]
    broker1   = ucloud_instance.broker.*.private_ip[1]
    broker2   = ucloud_instance.broker.*.private_ip[2]
    broker_ip = ucloud_instance.broker.*.private_ip[count.index]
  }
}



resource "null_resource" "setup_broker" {
  count = var.instance_count
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "root"
      password = var.root_password
      host     = ucloud_eip.broker[count.index].public_ip
    }
    inline = [
      file("setup.sh"),
      data.template_file.make_broker_config.*.rendered[count.index],
      file("startBroker.sh"),
    ]
  }
}


