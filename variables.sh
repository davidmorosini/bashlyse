#!/bin/bash

# Diretório default de localização dos arquivos de log
LOGS_DIR_DEFAULT=logs/

# arquivo default contendo os regex's a serem buscados
PATTERNS_FILE_DEFAULT=patterns.txt

# Tipos de arquivos a serem buscados pelo regex
FILE_TYPE=log

# Padrão para especificar uma linha única de log
LINE_LOG_PATTERN='$!{ 1{x;d}; H}; ${ H;x;s|\n\([^0-9]\)| \1|g;p}'

# Endpoint do dynamo (Usando o localstack)
ENDPOINT_DYNAMO="http://localhost:4569"
DATABASE="rds_log"

