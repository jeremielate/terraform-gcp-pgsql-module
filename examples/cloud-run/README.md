# Cloud Run deployment using the database module and Cloud SQL authentication proxy

Since IAM authentication is not enabled on the authentication proxy provided by Cloud Run, it is not possible to use a service account to login from the container.
A simple postgresql user is used to connect to the database instead. 
Also, a private network with a NAT enabled router is created. This allows us to create the database with an private IP allocated.
