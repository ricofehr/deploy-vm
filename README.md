# deploy-vm

Vm with useful packages and softwares for deploy applications: azcli, awscli, ansible, terraform, kubectl, helm, podman

## Local install

```
$ git submodule update --init --recursive
$ vagrant up
```

## Azure Deployment

Deploy to azure
- a resource group
- a dedicated vnet
- 2 subnets : one for the deploy VM and one for the bastion VM
- 1 Azure Virtual Machine
- Security group to allow only inbound SSH for OWN_IP

(Optional) Prepare a .tfenv file with service principal data
```
#!/bin/sh

export ARM_CLIENT_ID="XXXXXXXXXXXXXXXXXXXXXXXXX"
export ARM_CLIENT_SECRET="XXXXXXXXXXXXXXXXXXXXXXX"
export ARM_TENANT_ID="XXXXXXXXXXXXXXXXXXXXXX"
export ARM_SUBSCRIPTION_ID="XXXXXXXXXXXXXXXXXXXXXXX"
```

Run with arguments (replace OWN_IP, PREFIX_NAME and SSH_USERNAME with your values)
```
$ ./deploy-to-azure -i $OWN_IP -p $PREFIX_NAME -s $SSH_USERNAME
```

