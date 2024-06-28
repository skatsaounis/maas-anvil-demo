terraform {
  required_providers {
    maas = {
      source  = "maas/maas"
      version = "~>2.0"
    }
  }
}

provider "maas" {
  api_version = "2.0"
}
