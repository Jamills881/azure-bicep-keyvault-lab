# Azure Key Vault Lab

## What I Built
Deployed an Azure Key Vault using Bicep to securely store VM credentials, 
eliminating hardcoded passwords from deployment code and templates.

## The Security Problem This Solves
In previous labs VM passwords were passed as plain text parameters. Anyone 
with access to the deployment command or code could see the password. Key Vault 
stores secrets securely and controls access through RBAC role assignments.

## Resources Deployed
- **Azure Key Vault** — Standard SKU with RBAC authorization and soft delete enabled
- **Key Vault Secret** — VM admin password stored securely as a secret
- **Virtual Network** — 10.4.0.0/16 address space
- **Network Security Group** — Allow SSH on port 22, deny RDP on port 3389
- **Public IP Address** — Static Standard SKU
- **Network Interface** — Connected to VNet and NSG
- **Linux Virtual Machine** — Ubuntu 22.04 LTS using password from Key Vault
- **Resource Tags** — environment and owner tags on all resources
- **RBAC Role Assignment** — Key Vault Secrets Officer role assigned for secret access

## Security Features
- **RBAC Authorization** — Access to secrets requires explicit role assignments
- **Soft Delete** — Deleted secrets recoverable for 7 days
- **Audit Logging** — Every secret access is logged including who, when, and where
- **Unique Vault Name** — Generated using uniqueString() to ensure global uniqueness
- **No Hardcoded Passwords** — Secret stored in vault not in deployment code

## What I Learned
- How Azure Key Vault securely stores and manages secrets
- Why Key Vault names must be globally unique and how uniqueString() solves this
- How RBAC controls access to Key Vault secrets independently from resource access
- How soft delete protects against accidental secret deletion
- How Key Vault audit logs track every secret access for security compliance
- Why storing passwords in code is a security risk and how Key Vault eliminates it

## Tools Used
- Azure Bicep
- Azure CLI
- Azure Cloud Shell
- Azure Portal

## How to Deploy
1. Open Azure Cloud Shell
2. Upload main.bicep
3. Run:

az group create --name rg-nwf-kv-lab --location eastus

az deployment group create --name nwf-kv-deploy --resource-group rg-nwf-kv-lab --template-file main.bicep

4. Grant yourself access to view secrets:

az role assignment create --role "Key Vault Secrets Officer" --assignee your-user-id --scope your-keyvault-resource-id

## Note on Screenshots
Screenshots were intentionally omitted from this lab as Key Vault overview pages 
contain sensitive subscription and tenant identifiers. The Bicep code in this 
repository demonstrates the implementation.
