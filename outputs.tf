output "ip_addresses" {
  #   value = {
  #     for k, instance in maas_instance.anvil_node : k => "ssh ubuntu@${tolist(instance.ip_addresses)[0]}"
  #   }
  #   value = tolist(maas_instance.anvil_node.*.ip_addresses)[0]
  value = [for k, v in maas_instance.anvil_node : tolist(v.ip_addresses)[0]]
}
