# Log Analyse

---

- Database schema [`DynamoDB`]

```json
    {
        "TableName": "rds_log",
        "KeySchema": [
            { "AttributeName": "occurrence", "KeyType": "HASH" },
            { "AttributeName": "pattern", "KeyType": "RANGE" }
        ],
        "LocalSecondaryIndexes": [
            {
                "IndexName": "IndexDate",
                "KeySchema": [
                    { "AttributeName": "occurrence", "KeyType": "HASH"},  
                    { "AttributeName": "date", "KeyType": "RANGE" }
                ],
                "Projection": {
                    "ProjectionType": "ALL"
                }
            },
            {
                "IndexName": "IndexFile",
                "KeySchema": [
                    { "AttributeName": "occurrence", "KeyType": "HASH"},  
                    { "AttributeName": "file", "KeyType": "RANGE" }
                ],
                "Projection": {
                    "ProjectionType": "ALL"
                }
            }
        ],
        "AttributeDefinitions": [
            { "AttributeName": "occurrence", "AttributeType": "S" },
            { "AttributeName": "pattern", "AttributeType": "S" },
            { "AttributeName": "date", "AttributeType": "S" },
            { "AttributeName": "file", "AttributeType": "S" }
        ],
        "ProvisionedThroughput": {
            "ReadCapacityUnits": 5,
            "WriteCapacityUnits": 5
        }
    }
```

## DEV

- Utilizado o `localstack` para emular o ambiente **aws** localmente. Para instalar em seu ambiente consulte o [repositório no github](https://github.com/localstack/localstack)

- Após instalar, execute o comando abaixo para inicializar o ambiente de LOG do RDS

```bash
    $ make prepare
```

- Crie um arquivo chamado `patterns.txt` e salve todos os `regex` suportados pelo `awk` neste arquivo, **cada linha representa um regex  a ser buscado nos logs**. Abaixo segue exemplo de um arquivo de padrões

```text
    # Esta linha é um comentário
    # awk regex guide => https://www.gnu.org/software/gawk/manual/html_node/Regexp.html

    # Todos os usuários que realizaram um delete que não seja o ops@saturno
    !/ops@saturno/ && /DELETE/

    # Todos os usuários que realizaram um delete e não estão no "domínio" @saturno
    !/@saturno/ && /DELETE/

    # Todos os usuários que realizaram um delete e não tem a "inicial" ops@
    !/ops@/ && /DELETE/
```

- Para executar o script principal execute um dos comandos abaixo, seja utilizando os diretórios default ou indicando o diretório onde os arquivos de log estão localizados e também o diretório do arquivo de padrões.

```bash
    $ make run
    ou
    $ make run [LOGS_DIR] [PATTERNS_FILE]
```

## Infos

- A variável `FILE_TYPE` contida no arquivo `variables.sh` indica o padrão de arquivos a ser buscado, por exemplo `.log`. Para buscar todos os tipos de arquivo, altere para `*`
