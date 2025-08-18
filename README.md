# Infra AWS Terraform/Terragrunt

This repository contains the **infrastructure-as-code** setup for deploying and managing services in AWS and Cloudflare using **Terraform** with **Terragrunt**.

The stack includes:

- **backup** – Backup configuration to make a backup of the DB
- **cloudflare_dns** – DNS records and zones managed in Cloudflare  
- **db** – Database infrastructure(PostgreSQL)
- **eks** – Amazon EKS clusters and related resources  
- **iam_role** – IAM roles and policies for service access  
- **network** – VPC, subnets, routing, and networking components  
- **vm** – EC2 virtual machines and related configurations  

---

## 📂 Repository Structure
```
├── README.md
├── ansible
│   └── inventory
├── dev
│   ├── backup
│   ├── cloudflare_dns
│   ├── db
│   ├── eks
│   ├── iam_role
│   ├── inventory
│   ├── network
│   └── vm
├── inventory.tpl
├── modules
│   ├── backup
│   ├── cloudflare_dns
│   ├── db
│   ├── eks
│   ├── iam_role
│   ├── inventory
│   ├── network
│   └── vm
├── prod
│   ├── backup
│   ├── cloudflare_dns
│   ├── db
│   ├── eks
│   ├── iam_role
│   ├── inventory
│   ├── network
│   └── vm
└── root.hcl
```
