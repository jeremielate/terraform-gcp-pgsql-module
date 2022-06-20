#!/bin/bash -eu

_terraform_output=$(terraform output --json)

_ssl_cert=$(mktemp)
_ssl_key=$(mktemp)
trap "rm -f $_ssl_cert $_ssl_key" EXIT

jq -r '.db_user_test_certificate.value.ssl_cert' <<<$_terraform_output > $_ssl_cert
jq -r '.db_user_test_certificate.value.ssl_private_key' <<<$_terraform_output > $_ssl_key
_conn_str=$(jq -r '.db_connection_string.value' <<<$_terraform_output)
PGDATABASE="${_conn_str}&sslcert=${_ssl_cert}&sslkey=${_ssl_key}"
psql --dbname $PGDATABASE
