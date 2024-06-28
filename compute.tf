# resource "maas_machine" "ob_machine" {
#   for_each = var.machine_map

#   power_type = "amt"
#   power_parameters = jsonencode({
#     power_address = each.value.power_address
#     power_pass    = each.value.power_pass
#   })
#   pxe_mac_address = each.value.pxe_mac_address
# }

resource "maas_instance" "anvil_node" {
  for_each = var.machine_map
  # for_each = maas_machine.ob_machine

  deploy_params {
    distro_series = "ubuntu/jammy"
    #     user_data     = <<EOF
    # #!/bin/bash
    # set -xe
    # sudo snap install maas-anvil --channel=latest/edge/pgbouncer
    # maas-anvil prepare-node-script | bash -x
    # EOF
  }
  allocate_params {
    system_id = each.value.system_id
    # system_id = each.value.id
  }
}
