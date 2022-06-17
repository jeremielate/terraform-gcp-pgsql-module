# Google Cloud PostgreSQL Terraform module

## Examples

* Private ip Zonal PostgreSQL instance
```terraform
module "database" {
  source = "git::ssh://jeremielate/terraform-gcp-pgsql-module.git"

  name                = "padok"
  tier                = "db-f1-micro"
  region              = "europe-west1"
  public              = false
  compute_network_id  = google_compute_network.network.id
  deletion_protection = false
  backup_enabled      = false

  databases = [
    "test",
  ]

  builtin_users = [
    "test",
  ]
}
```


## Required variables
| Name      | Description                                 |
| --------- | ------------------------------------------- |
| name      | Name of the instance database               |
| region    | Database region location (eg. europe-west1) |
| tier      | Database tier (instance size)               |
| databases | List of sql databases on this instance      |

## Optional variables
| Name      | Description                                 | Default |
| --------- | ------------------------------------------- | ------- |
| availability_type      | Database availability              | ZONAL |
| public      | Database public ip enabled              | false |
| builtin_users      | List of builtin sql users allowed to connect to the instance | [] |
| iam_users      | List of IAM users allowed to connect to the instance | [] |
| iam_service_accounts      | List of IAM service accounts allowed to connect to the instance | [] |
| deletion_protection      | Protection against accidental deletion | true |
| compute_network_id | VPC network id | null |
