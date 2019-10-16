resource "ucloud_instance" "rocket_nameSrv"{

  count=var.instance_count

  name="rocket_nameSrv_${var.class}=${count.index}"

  availabilit_zone=var.az[count.index % length(var.az)]

  images_id=var.images_id

  root_password=var.root_password

  charge_type =var.charge_type

  security_group=var.sg_id

  subnet_id=var.subnet_id

  data_disk_size=var.data_volume_size


  provisioner "local-exec"{

    command="sleep 10"
  }

}



resource "ucloud_eip" "rocket_nameSrv"{

  count=var.instance_count

  instance_type = "bgp"

  charge_mode="traffic"

  charge_type="dynamic"

  bandwidth=200

  tag=var.cluster_tag

}


resource "ucloud_eip_association" "nameSrv_ip"{

  count=var.instance_count

  eip_id=ucloud_eip.roketmq_nameSrv[count.index].id

  resource_id=ucloud_instance.rocket_nameSrv[count.index].id

}


locals {

  setup-script-path="${path-module}/setup.sh"

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
      host     = ucloud_eip.rocketmq_nameSrv[count.index].public_ip
    }
  }
}
