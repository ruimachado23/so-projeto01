#!/bin/bash

# Trabalho realizado por:
# Rui de Faria Machado, 113765, P6
# João Manuel Vieira Roldão, 113920, P6

exec &> spacecheck_$(date +%Y%m%d).txt      # guardar o output do script num ficheiro .txt

# Inicializacao de variáveis
regex=""
date=""
limit=""
dir=""
options=""

# Processamento e Validação das opções da linha de comando
while getopts "n:d:s:ral:" opt; do          # ":" após letra indica que necessita de argumento
    case $opt in                            # variável $OPTARG usada para armazenar o argumento
        n)
            regex="$OPTARG"                                 # armazenar valores associados às respetivas variáveis 
            options="$options -$opt \"$OPTARG\""            # guardar a opçao na string options
            ;;                              
        d)
            date="$OPTARG"
            options="$options -$opt \"$OPTARG\""
            ;;
        s)
            regex="$OPTARG"
            options="$options -$opt \"$OPTARG\""
            ;;
        r)
            options="$options -$opt"
            ;;
        a)
            options="$options -$opt"
            ;;
        l)
            limit="$OPTARG"
            options="$options -$opt \"$OPTARG\""
            ;;
        \?)
            echo "Opção inválida: -$OPTARG" >&2     # erro: opcçao inválida
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))       # "deslocar" ou "remover" as opções de linha de comando já processadas
                            # de modo a que o diretório fique guardado na variável $1
if [ $# -ne 1 ]; then
    echo "Erro: É necessário especificar um e um só diretório." # verificar se o utilizar introduziu um diretório
    exit 1
fi

dir="$1"

if [ -z "$date" ]; then
    date=".*"               # se a variável estiver vazia, o script define como ".*",
fi                          # que é uma expressão regular que corresponde a qualquer sequência de caracteres

if [ -z "$regex" ]; then
    regex=".*"              
fi

# manipulacao das flags -r e -a 
if [[ "$options" != *"-r"* ]] && [[ "$options" != *"-a"* ]]; then      # quando ambas as flags nao foram inseridas;           
    sort_order="-k1,1nr"                                               # classifica os dados por ordem decrescente com base na primeira coluna (-k1,1)
elif [[ "$options" == *"-r"* ]] && [[ "$options" != *"-a"* ]]; then    # quando a flag -r foi inserida, mas a -a nao:
    sort_order="-k1,1n"                                                # classifica os dados em ordem crescente com base na primeira coluna (-k1,1) 
elif [[ "$options" != *"-r"* ]] && [[ "$options" == *"-a"* ]]; then    # quando a flag -r nao foi inseridas, mas a -a sim;
    sort_order="-k2,2"                                                 # classifica os dados em ordem crescente com base na segunda coluna (-k2,2)
elif [[ "$options" == *"-r"* ]] && [[ "$options" == *"-a"* ]]; then    # quando ambas as flags foram inseridas:
    sort_order="-k2,2r"                                                # classifica os dados em ordem decrescente com base na segunda coluna (-k2,2).
fi

# Print the options on the first line
echo "SIZE NAME $(date +%Y%m%d) $options $dir"

find "$dir" -type d | \
    while read -r folder; do                                            # loop para encontrar os diretórios
        size=0                                                          # inicializar a variável size
        while IFS= read -r -d $'\0' file; do                            # loop para ver arquivos do diretório
            if [[ -f "$file" && $(basename "$file") =~ $regex ]]; then  # verificaçao de expressao regular (-n)
                if [[ "$date" != ".*" ]]; then                          # verificar se foi introduzida uma data
                    file_date=$(date -r "$file" +%Y%m%d)                # obter a data de modifiçao do ficheiro
                    if [[ "$file_date" -ge "$date" ]]; then
                        file_size=$(du -b "$file" | cut -f1)
                        if [ -n "$file_size" ]; then
                            size=$((size + file_size))                  # adicionar o tamanho do ficheiro ao tamanho total
                        else
                            size="NA"                                   # se nao for possivel obter o tamanho do ficheiro, size = "NA"
                        fi                    fi
                else
                    file_size=$(du -b "$file" | cut -f1)
                    if [ -n "$file_size" ]; then
                        size=$((size + file_size))                      # adicionar o tamanho do ficheiro ao tamanho total
                    else
                        size="NA"                                       # se nao for possivel obter o tamanho do ficheiro, size = "NA"
                    fi                
                fi
            fi  
        done < <(find "$folder" -type f -print0)
        if [ "$size" -gt 0 ]; then
            echo "$size $folder"                                        # print do size e do respetivo diretório
        fi
    done | \
    sort $sort_order | \
    if [ -n "$limit" ]; then                                            # limitar a quantidade de saidas
        head -n "$limit"
    else cat
    fi