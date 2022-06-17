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

output "user_passwords" {
  value = { for u in var.builtin_users : u => random_password.db_user[u].result }
}
