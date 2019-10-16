resource "ucloud_instance" "rocketmq_broker"{

  count =var.instance_count

  name="rocketmq_broker_${var.class}=${count.index}"

  availabilit_zone=var.az[count.index % length(var.az)]

  image_id=var.image_id

  instance_type=var.instance_type

  root_password=var.root_password

  charge_type=var.charge_type

  security_group=var.sg_id

  subnet_id=var.subnet_id

  data_disk_size=var.data_volume_size

  provisioner "local-exec"{

    command="sleep 10"

  }
}


resource "ucloud_eip" "rocketmq_broker"{

  count=var.instance_count

  internet_type="bgp"

  charge_mode="traffic"

  charge_type="dynamic"

  bandwidth=200

  tag=var.cluster_tag

}


resource "ucloud_eip_association" "broker_ip"{
  count       = var.instance_count
  eip_id      = ucloud_eip.rocketmq_broker[count.index].id
  resource_id = ucloud_instance.rocketmq_broker[count.index].id
}



locals{

  setup-scrip-path ="${path-module}/setup.sh"

}


resource "null_resource" "setup" {
  count = var.instance_count
  depends_on = [
    ucloud_eip_association.nomad_ip,
  ]
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "root"
      password = var.root_password
      host     = ucloud_eip.rocketmq_broker[count.index].public_ip
    }
  }
}

