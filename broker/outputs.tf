output "Public_ips"{

  value = ucloud_eip.rocket_broker.*.Public_ips

}
