#!/bin/bash

export DB_HOST = ""
export DB_NAME = ""
export DB_NAME = ""
export MYSQL_PASSWORD = "12345"

terraform output -json | jq -r 'to_entries[] | "TF_VAR_" + .key + "=" + (.value.value | tostring)' | while read -r line ; do echo export "$line"; done > env.sh
source env.sh

# another soluiont
# https://stackoverflow.com/questions/69208770/taking-output-of-terraform-to-bash-script-as-input-variable