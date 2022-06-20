output "name" {
  value = google_sql_database_instance.db.name
}

output "self_link" {
  value = google_sql_database_instance.db.self_link
}

output "connection_name" {
  value = google_sql_database_instance.db.connection_name
}

output "public_ip_address" {
  value = google_sql_database_instance.db.public_ip_address
}

output "private_ip_address" {
  value = google_sql_database_instance.db.private_ip_address
}

output "user_credentials" {
  value = { for u in var.builtin_users : u => {
    password            = random_password.db_user[u].result,
    ssl_cert            = try(google_sql_ssl_cert.db_user[u].cert, null),
    ssl_private_key     = try(google_sql_ssl_cert.db_user[u].private_key, null),
    ssl_expiration_time = try(google_sql_ssl_cert.db_user[u].expiration_time, null),
    }
  }
}

output "settings_version" {
  value = google_sql_database_instance.db.settings[0].version
}

output "server_ca_cert" {
  value = {
    cert             = google_sql_database_instance.db.server_ca_cert[0].cert,
    common_name      = google_sql_database_instance.db.server_ca_cert[0].common_name,
    create_time      = google_sql_database_instance.db.server_ca_cert[0].create_time,
    expiration_time  = google_sql_database_instance.db.server_ca_cert[0].expiration_time,
    sha1_fingerprint = google_sql_database_instance.db.server_ca_cert[0].sha1_fingerprint,
  }
}
