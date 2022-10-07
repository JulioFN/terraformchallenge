# Terraform Challenge
A terraform challenge was issued. This is how try to solve it.

# Steps to reproduce
## Section A
Install python3, terraform, Azure CLI and Ansible and run `az login` and `terraform init` on root folder. The Terraform version was 1.3.1, Az Cli 2.40.0, Ansible was Focal Fossa's 2.12.9 and python was 3.8.10 .

Then, apply the terraform file customizing some vars:
```
terraform apply -var "ssh_ip_or_cidr=<your_external_ip>" -var "vm_sku=Standard_B1ms"
```
For the sake of simplicity, I included an id_rsa file and an id_rsa.pub to be used as default. **I don't recommend using those!** Using these can be useful for a quick test but **can be a huge security problem** since anyone can have access to them. This is in part mitigated by having only your ip allowed ssh access in the NSG (ssh_ip_or_cidr var), so you can use it for a quick test. I recommend generating your own and setting them with `-var "key_path=~/.ssh/id_rsa"` and `-var "cert_path=~/.ssh/id_rsa.pub"`

vm_sku is set to a 1 vcpu machine for it to be able to run 3 in a free trial Azure account.

## Section B
To run the playbook that orchestrates a docker container, performs a backup and automates this backup run:
```
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u adminuser -i '<ip_from_one_of_the_vms_deployed>,' --private-key ./id_rsa -e 'pub_key=./id_rsa.pub' postgres-playbook.yml
```

## Section C
A python script was done to check if it can do a http get request in the host provided. If it fails, tries to check if ssh is open. It outputs a list of objects that had errors. You can use this script by running it like:
```
python3 check-health.py
```
This way, it will try to get a list of hosts from local terraform.tfstate. Also, you can specify which hosts you want to check by passing them in a comma separated string, like this:
```
python3 check-health.py 20.124.112.32,20.172.188.7
```
Also, inside the file there is a `human_output` var that can be set to False so the script only outputs the final object containing errors.
# Challenge Description

## Section A - Virtual Machine
### Objectives
- Must use Infrastructure as code for all steps. (Terraform, Ansible or SaltStack) ✔
- Deploy three virtual machines using Terraform. The cloud provider can be anything the candidate prefers. ✔ [Azure was used]
- Install Apache or Nginx. ✔ [Ansible playbook was used]
- Create a load balancer that distributes the load between servers for HTTP. ✔
- Have a dedicated volume where Apache files are stored. ✔
### Bonus Objectives
- Configure Apache or Nginx using both Ansible and SaltStack. [Used only Ansible, mod_rewrite was enabled]
- Prevent the storage to deleted using Terraform. ✔ [Prevent destroy and Azure Lock]
- Only allow port 80 to be available from anywhere and SSH from a specific CIDR. Security groups or VM firewall rules are valid options but must be done with Infrastructure as Code (Terraform or Ansible). ✔ [Terraform and Azure NSG]
- Have a shared storage between all Virtual Machine. ✔
- Create load balancer and VMs using Terraform module. (Your own Modules, non-public modules). ✔
- Enable HTTPS on the servers or the load balancer. A self-signed certificate is good. ❌

## Section B - Containers

### Objectives
- Configure a Postgres docker container. ✔
- Perform a backup on the database.  ✔
- Publish container in public or private container repository. [After talking through emails they said it was enough running somewhere they can test. I chose to run on one of the machines created.] ✔
### Bonus Objectives
- Automatic backup of the database.  ✔

## Section C - Scripting
### Objectives
- Create a script that checks the health of each node. ✔
### Bonus Objectives
-  The script takes an argument where you can set the VM to check individually. ✔
-  Automatically check the health and some kind of communication when something is wrong. ✔