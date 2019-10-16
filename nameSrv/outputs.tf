output "public_ip" {

  value = ucloud_eip.broker.*.public_ip

}
