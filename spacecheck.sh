#!/bin/bash

# Trabalho realizado por:
# Rui de Faria Machado, 113765, P6
# João Manuel Vieira Roldão, 113920, P6

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
    echo "Erro: É necessário especificar um e um só diretório." #verificar se o utilizar introduziu um diretório
    exit 1
fi

dir="$1"

if [ -z "$date" ]; then
    date=".*"               # se a variável estiver vazia, o script define como ".*",
fi                          # que é uma expressão regular que corresponde a qualquer sequência de caracteres

if [ -z "$regex" ]; then
    regex=".*"              
fi

if [[ "$options" != *"-r"* ]] && [[ "$options" != *"-a"* ]]; then
    sort_order="-k1,1nr"
elif [[ "$options" == *"-r"* ]] && [[ "$options" != *"-a"* ]]; then
    sort_order="-k1,1n"
elif [[ "$options" != *"-r"* ]] && [[ "$options" == *"-a"* ]]; then
    sort_order="-k2,2"
elif [[ "$options" == *"-r"* ]] && [[ "$options" == *"-a"* ]]; then
    sort_order="-k2,2r"
fi

# Print the options on the first line
echo "SIZE NAME $(date +%Y%m%d) $options $dir"

find "$dir" -type d | \
    while read -r folder; do
        size=0
        while IFS= read -r -d $'\0' file; do
            if [[ -f "$file" && $(basename "$file") =~ $regex ]]; then
                if [[ "$date" != ".*" ]]; then
                    file_date=$(date -r "$file" +%Y%m%d)  # Get the modification date of the file
                    if [[ "$file_date" -ge "$date" ]]; then
                        size=$((size + $(du -b "$file" | cut -f1)))
                    fi
                else
                    size=$((size + $(du -b "$file" | cut -f1)))
                fi
            fi
        done < <(find "$folder" -type f -print0)
        if [ "$size" -gt 0 ]; then
            echo "$size $folder"
        fi
    done | \
    sort $sort_order | \
    if [ -n "$limit" ]; then head -n "$limit"; else cat; fi
