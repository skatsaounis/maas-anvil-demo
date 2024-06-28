variable "machine_map" {
  type = map(object({
    power_address   = string
    power_pass      = string
    pxe_mac_address = string
    system_id       = string
  }))
}
