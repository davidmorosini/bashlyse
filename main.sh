#!/bin/bash

#### REFERENCIAS ####
source ./variables.sh
source ./functions.sh


function Main {
    local patterns_file=$1
    local logs_dir=$2

    local old_ifs=$IFS
    IFS=$'\n'
    # Realiza uma busca no arquivo de padrões desconsiderando todas as linhas com '#'
    array_patterns=( $( cat $patterns_file | fgrep -v \# ) )
    IFS=$old_ifs

    # Recuperando os paths de todos os arquivos 
    # do diretório /logs
    log_files=( $( GetFilesFromDir $logs_dir *.$FILE_TYPE ) )

    for log_file in "${log_files[@]}";
    do 
        echo "> processing file $log_file"        
        echo -e "\t- loading file in memory"
        local file_in_memory=$( cat $log_file | sed -n "$LINE_LOG_PATTERN" )

        # Varre os padrões para disparar a função de análise em paralelo
        # Não foi usado direto no egrep para se ter mais controle
        # dos reultados e poder separar facilmente
        echo -e "\t- start threads"
        for pattern in "${array_patterns[@]}";
        do
            # o arquivo de log está sendo passado por referência
            # Neste caso não utiliza o "$"
            AnalyseLog file_in_memory "$pattern" $log_file "$ENDPOINT_DYNAMO" "$DATABASE" &
        done
        # Aguardando processamento dos subshells disparados acima
        wait
        echo -e "\t- stop threads"
        unset file_in_memory
        echo -e "\t- complete search in file -- $log_file --"
    done
}



# Usa como default as definições contidas e variables.sh
logs_dir=$LOGS_DIR_DEFAULT
patterns_file=$PATTERNS_FILE_DEFAULT

# Caso o usuário insira os parâmetros, os utiliza
[ $# -eq 2 ] && {
    logs_dir=$1
    patterns_file=$2
}


Iniciando captura do datetime para medir a execução
init_time=$( GetTime )

Main $patterns_file $logs_dir

exec_time=$( MeasureTime $init_time )
echo "> Tempo gasto: $exec_time" 
