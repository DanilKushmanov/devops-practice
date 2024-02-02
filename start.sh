#!/bin/bash
cd ./terraform
terraform plan -out plan
terraform apply "plan"
sleep 30
cd ../ansible
sudo ansible-playbook main.yaml
