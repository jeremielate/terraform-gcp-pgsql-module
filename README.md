# Google Cloud PostgreSQL Terraform module

By default, this module will create a backup enabled regional postgresql 14 database with no public IP.
The maintenance window, where updates can occur, is programmed every Monday at 6 am.
This database will be saved every day and a maximum of 7 backups will be retained.
For security, SSL is required to connect to the database.
It also possible to use the Cloud SQL authentication proxy to connect to the database.
The database will have a random generated suffix appended to the name because
it makes it easier to recreate the database if needed since the name is retained by GCP for some days after deletion.

Followed the [best practices for PostgreSQL](https://cloud.google.com/sql/docs/postgres/best-practices).

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
| Name                                    | Description                                                     | Default    |
| --------------------------------------- | --------------------------------------------------------------- | ---------- |
| `availability_type`                     | Database availability                                           | "REGIONAL" |
| `public`                                | Database public ip enabled                                      | false      |
| `builtin_users`                         | List of builtin sql users allowed to connect to the instance    | []         |
| `iam_users`                             | List of IAM users allowed to connect to the instance            | []         |
| `iam_service_accounts`                  | List of IAM service accounts allowed to connect to the instance | []         |
| `deletion_protection`                   | Protection against accidental deletion                          | true       |
| `vpc_peering_enabled`                   | Create a peering between a VPC and this database                | false      |
| `compute_network_id`                    | VPC network id (used when `vpc_peering_enabled` is true)        | null       |
| `network_prefix_length`                 | Subnet where the private ip for the instance will be allocated  | 16         |
| `backup_enabled`                        | Enable regular backups of the database                          | true       |
| `backup_point_in_time_recovery_enabled` | Point-in-time recovery                                          | false      |
| `backup_start_time`                     | Time of the day when a backup can be started                    | "23:00"    |
| `backup_transaction_log_retention_days` | Transaction log retention days                                  | 7          |
| `backup_retained_backups`               | Retained backup count                                           | 7          |
| `maintenance_window_day`                | Day of the week when a instance maintenance can occur           | 1          |
| `maintenance_window_hour`               | Hour of the day when a instance maintenance can occur           | 6          |
| `maintenance_window_update_track`       | Update track, canary or stable                                  | "stable"   |
| `user_labels`                           | User labels (key/value tags)                                    | {}         |

## Outputs
| Name                                     | Description
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------|
| `name`                                   | Name of the database (formated as db-xxxx)                                                                              |
| `self_link`                              | Unique name reference of the database                                                                                   |
| `connection_name`                        | The connection name of the instance to be used in connection strings. For example, when connecting with Cloud SQL Proxy |
| `public_ip_address`                      | The public IPv4 address assigned                                                                                        |
| `private_ip_address`                     | The first private IPv4 address assigned                                                                                 |
| `user_credentials[].password`            | Builtin user password                                                                                                   |
| `user_credentials[].ssl_cert`            | Builtin user SSL client certificate                                                                                     |
| `user_credentials[].ssl_private_key`     | Builtin user SSL client private key                                                                                     |
| `user_credentials[].ssl_expiration_time` | Builtin user SSL client certificate expiration date                                                                     |
| `settings_version`                       | Database settings version                                                                                               |
| `server_ca_cert.cert`                    | The CA Certificate used to connect to the SQL Instance via SSL                                                          |
| `server_ca_cert.common_name`             | The CN valid for the CA Cert                                                                                            |
| `server_ca_cert.create_time`             | Creation time of the CA Cert                                                                                            |
| `server_ca_cert.expiration_time`         | Expiration time of the CA Cert                                                                                          |
| `server_ca_cert.sha1_fingerprint`        | SHA Fingerprint of the CA Cert                                                                                          |
