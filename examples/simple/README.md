# Simple deployment of a public IP enabled database

This example creates a Cloud SQL instance with a database named test and a builtin user test.
Only the host running this code will be able to connect.
A script named `connect.sh` will retrieve the credentials of the created database from the terraform state and use psql to connect.
