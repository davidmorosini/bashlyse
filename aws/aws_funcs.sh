#!/bin/bash


function CreateTable {
    local endpoint=$1
    local payload_file=$2
    response=$( aws dynamodb create-table --cli-input-json file://$payload_file --endpoint-url=$endpoint )
    echo $response
}

function ListTables {
    local endpoint=$1
    response=$(  aws dynamodb list-tables --endpoint-url=$endpoint )
    echo $response
}

function DeleteTable {
    local endpoint=$1
    local table_name=$2
    response=$( aws dynamodb delete-table --table-name $table_name --endpoint=$endpoint )
    echo $response
}

function InsertBatch {
    local endpoint=$1
    local payload_file=$2
    response=$( aws dynamodb batch-write-item --request-items file://$payload_file --endpoint-url=$endpoint )
    echo $response
}

function InsertItem {
    local endpoint=$1
    local table_name=$2
    local payload=$3
    response=$( aws dynamodb put-item --table-name $table_name --item "$payload" --endpoint-url=$endpoint )
    echo $response
}

function SelectAll {
    local endpoint=$1
    local table_name=$2
    response=$( aws dynamodb scan --table-name $table_name --endpoint-url=$endpoint )
    echo $response
}



ENDPOINT=http://localhost:4569
TABLE=rds_log
DB_CNF=database_configs.json
INPUT=example_input.json

buffer="{
    \"occurrence\": {\"S\": \"TESTE1\"},
    \"pattern\": {\"S\": \"TESTE1\"},
    \"date\": {\"S\": \"TESTE1\"},
    \"file\": {\"S\": \"TESTE1\"}
}"

# ListTables $ENDPOINT 
# DeleteTable $ENDPOINT $TABLE
# CreateTable $ENDPOINT $DB_CNF
# InsertBatch $ENDPOINT $INPUT
# InsertItem $ENDPOINT $TABLE "$buffer"
SelectAll $ENDPOINT $TABLE

