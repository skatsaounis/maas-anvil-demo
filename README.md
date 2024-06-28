# PoC for MAAS Anvil

## MAAS CLI login and SSH key injection

```bash
snap install maas
maas login orangebox http://172.27.60.1:5240/MAAS/api/2.0/ "__token__"
maas orangebox sshkeys import lp:skatsaounis
```

## Deploy machines with Terraform

```bash
# Create values.tfvars and fill with machine details
cp values.tfvars.sample values.tfvars
export MAAS_URL="http://172.27.60.1:5240/MAAS"
export MAAS_TOKEN="__token__"
terraform init
./import.sh
terraform plan -var-file=values.tfvars
terraform apply -var-file=values.tfvars -auto-approve
```

## Bootstrap node - node02

```bash
sudo snap install maas-anvil --edge
maas-anvil prepare-node-script | bash -x
newgrp snap_daemon

maas-anvil cluster bootstrap --role database --accept-defaults
juju config pgbouncer pool_mode=transaction

maas-anvil cluster add --name node03.maas -f value
maas-anvil cluster add --name node04.maas -f value
maas-anvil cluster add --name node05.maas -f value
maas-anvil cluster add --name node06.maas -f value
maas-anvil cluster add --name node07.maas -f value
maas-anvil cluster add --name node08.maas -f value
maas-anvil cluster add --name node09.maas -f value
```

## Database nodes - [node03, node04]

```bash
sudo snap install maas-anvil --edge
maas-anvil prepare-node-script | bash -x
newgrp snap_daemon

maas-anvil cluster join --role database --token __token_goes_here__
```

## Region nodes - [node05, node06, node07]

```bash
sudo snap install maas-anvil --edge
maas-anvil prepare-node-script | bash -x
newgrp snap_daemon

maas-anvil cluster join --role haproxy --role region --token __token_goes_here__
```

## Agent nodes - [node08, node09]

```bash
sudo snap install maas-anvil --edge
maas-anvil prepare-node-script | bash -x
newgrp snap_daemon

maas-anvil cluster join --role agent --token __token_goes_here__
```

## Status from node02

```bash
ubuntu@node02:~$ maas-anvil cluster list
┏━━━━━━━━━━━━━┳━━━━━━━━┳━━━━━━━━┳━━━━━━━┳━━━━━━━━━━┳━━━━━━━━━┓
┃ Node        ┃ Status ┃ Region ┃ Agent ┃ Database ┃ HAProxy ┃
┡━━━━━━━━━━━━━╇━━━━━━━━╇━━━━━━━━╇━━━━━━━╇━━━━━━━━━━╇━━━━━━━━━┩
│ node02.maas │   up   │        │       │    x     │         │
│ node03.maas │   up   │        │       │    x     │         │
│ node04.maas │   up   │        │       │    x     │         │
│ node05.maas │   up   │   x    │       │          │    x    │
│ node06.maas │   up   │   x    │       │          │    x    │
│ node07.maas │   up   │   x    │       │          │    x    │
│ node08.maas │   up   │        │   x   │          │         │
│ node09.maas │   up   │        │   x   │          │         │
└─────────────┴────────┴────────┴───────┴──────────┴─────────┘
```

## VIP installation

```bash
ip_address=172.27.61.131
juju deploy containers/keepalived
juju relate haproxy:juju-info keepalived:juju-info
juju config keepalived virtual_ip=$ip_address
```

## Admin user creation

```bash
juju run maas-region/0 create-admin username=root password=root email=admin@maas.io ssh-import=lp:skatsaounis
```

## CLI

```bash
juju ssh maas-region/0
ip_address=172.27.61.131
maas login anvil "http://$ip_address/MAAS/api/2.0/" $(sudo maas apikey --generate --username root)

maas anvil rack-controllers read
maas anvil region-controllers read
maas anvil maas set-config name=network_discovery value=disabled
maas admin ipranges create type=dynamic start_ip=172.27.61.195 end_ip=172.27.61.200 comment='MAAS DHCP'
rack_controllers=$(maas admin rack-controllers read)
primary_rack=$(echo $rack_controllers | jq --raw-output .[0].system_id)
secondary_rack=$(echo $rack_controllers | jq --raw-output .[1].system_id)
maas admin vlan update 0 untagged dhcp_on=True primary_rack=$primary_rack secondary_rack=$secondary_rack
```
