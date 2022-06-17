# Google Cloud PostgreSQL Terraform module

By default, this module will create a backup enabled regional postgresql 14 database with no public IP.
This database will be saved every day and a maximum of 7 backups will be retained.
For security, SSL is required to connect to the database.
It also possible to use the Cloud SQL authentication proxy to connect to the database.

The database will have a random generated suffix appended to the name because
it makes it easier to recreate the database if needed since the name is retained for some days after deletion.


## Examples

### Private IP zonal database instance for testing
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
Other examples, can be found in `/examples`.

## Required variables
| Name        | Description                                 |
| ----------- | ------------------------------------------- |
| `name`      | Name of the instance database               |
| `region`    | Database region location (eg. europe-west1) |
| `tier`      | Database tier (instance size)               |
| `databases` | List of sql databases on this instance      |

## Optional variables
| Name                                    | Description                                                     | Default |
| --------------------------------------- | --------------------------------------------------------------- | ------- |
| `availability_type`                     | Database availability                                           | ZONAL   |
| `public`                                | Database public ip enabled                                      | false   |
| `builtin_users`                         | List of builtin sql users allowed to connect to the instance    | []      |
| `iam_users`                             | List of IAM users allowed to connect to the instance            | []      |
| `iam_service_accounts`                  | List of IAM service accounts allowed to connect to the instance | []      |
| `deletion_protection`                   | Protection against accidental deletion                          | true    |
| `compute_network_id`                    | VPC network id                                                  | null    |
| `network_prefix_length`                 | Subnet where the private ip for the instance will be allocated  | 16      |
| `backup_enabled`                        | Enable regular backups of the database                          | 16      |
| `backup_point_in_time_recovery_enabled` | Enable regular backups of the database                          | 16      |
| `backup_start_time`                     | Time of the day when a backup can be started                    | "23:00" |
| `backup_transaction_log_retention_days` | Transaction log retention days                                  | 7       |
| `backup_retained_backups`               | Retained backup count                                           | 7       |
| `user_labels`                           | User labels (key/value tags)                                    | {}      |
