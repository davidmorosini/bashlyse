#!/bin/bash


function GetTime {
    # retorna a datetime atual em segundos com base 
    # em (1970-01-01 00:00:00 UTC)
    echo $( date +%s )
}


function MeasureTime {
    # Calcula o tempo de execução baseado em um tempo 
    # inicial fornecido pela função acima GetTime
    local init_date=$1
    local final_date=$( GetTime )
    # Calcula o intervalo de tempo observado em segundos
    local tmp_interval=$( expr $final_date - $init_date )
    # Ajustando o timezone
    local resp=$( expr 10800 + $tmp_interval )
    # Formatando a data para o padrão HH:mm:ss
    local time_exec=$( date -d @$resp +%H:%M:%S )
    echo $time_exec
}


function GetFilesFromDir {
    # Recupera o paths de todos os arquivos de um
    # determinado diretório, sem recursividade
    local dir=$1
    local type=$2
    # "type" especifica a busca por arquivos deste tipo
    local files=$( find $dir -maxdepth 1 -name $type )
    echo $files
}


function InsertTable {
    # Realiza a inserção dos dados no DynamoDB
    local endpoint=$1
    local table_name=$2
    local payload=$3
    # o conteúdo está sendo enviado para "quiet" apenas para não poluir a saída
    quiet=$( aws dynamodb put-item --table-name $table_name --item "$payload" --endpoint-url=$endpoint )
}


function CreatePayload {
    # Cria o payload no formato JSON necessário para inserir no dynamo
    local occurrence=$1
    local pattern=$2
    local file_name=$3
    local date=$4

    # Estes campos seguem o arquivo aws/database_configs.json
    buffer="{
        \"occurrence\": {\"S\": \"$occurrence\"},
        \"pattern\": {\"S\": \"$pattern\"},
        \"date\": {\"S\": \"$date\"},
        \"file\": {\"S\": \"$file_name\"}
    }"
    echo $buffer
}


function AnalyseLog {
    # Realiza a análise do log realizando um egrep de um 
    # arquivo em memória

    # "file" recebe a referência de um arquivo, desta forma
    # evitamos sobrecarga da memória 
    local -n file=$1
    local pattern=$2
    local input_file_name=$3
    local endpoint_url=$4
    local database=$5
    # Redireciona a referência do arquivo em memória para 
    # a busca do AWK
    
    local old_ifs=$IFS
    IFS=$'\n'
    local found_pattern=( $( awk "$pattern  {print}" <<< $file ) )
    IFS=$old_ifs
    # Caso o egrep retorne algo, e somente se, criar um arquivo
    # que contenha essas informações
    [ "$found_pattern" ] && {
        for found in "${found_pattern[@]}";
        do
            local line_splited=( $found )
            local datetime="${line_splited[0]} ${line_splited[1]}"
            local payload=$( CreatePayload "$found" "$pattern" "$input_file_name" "$datetime" )

            InsertTable "$endpoint_url" "$database" "$payload"
        done
    }
}


# Não sei se funciona..
function SendMessageSNS {
    # my-topic
    local topic=$1
    # arn:aws:sns:us-west-2:123456789012
    local arn=$2
    local message=$3
    aws sns publish --topic-arn $arn:$topic --message $message
}
