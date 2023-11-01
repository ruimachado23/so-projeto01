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
min_size=""

# Processamento e Validação das opções da linha de comando
while getopts "n:d:s:ral:" opt; do
    case $opt in
        n)
            regex="$OPTARG"
            options="$options -$opt \"$OPTARG\""
            ;;
        d)
            date="$OPTARG"
            options="$options -$opt \"$OPTARG\""
            ;;
        s)
            min_size="$OPTARG"
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
            echo "Opção inválida: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))       # "deslocar" ou "remover" as opções de linha de comando já processadas
                            # de modo a que o diretório fique guardado na variável $1
if [ $# -ne 1 ]; then
    echo "Erro: É necessário especificar um e um só diretório." # verificar se o utilizador introduziu um diretório
    exit 1
fi

dir="$1"

if [ -z "$date" ]; then
    date=".*"               # se a variável estiver vazia, o script define como ".*",
fi                          # que é uma expressão regular que corresponde a qualquer sequência de caracteres

if [ -z "$regex" ]; then
    regex=".*"
fi

if [ -z "$min_size" ]; then
    min_size=0              # se a variável estiver vazia, o script define como 0
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
    while read -r folder; do
        size=0
        while IFS= read -r -d $'\0' file; do
            if [[ -f "$file" && $(basename "$file") =~ $regex ]]; then
                if [[ "$date" != ".*" ]]; then
                    file_date=$(date -r "$file" +%Y%m%d)
                    if [[ "$file_date" -ge "$date" ]]; then
                        file_size=$(du -b "$file" 2>/dev/null | cut -f1)
                        if [ -n "$file_size" ]; then
                            if [ "$file_size" -ge "$min_size" ]; then
                                size=$((size + file_size))
                            fi
                        else
                            size="NA"  # Não foi possível determinar o tamanho do arquivo
                        fi
                    fi
                else
                    file_size=$(du -b "$file" 2>/dev/null | cut -f1)
                    if [ -n "$file_size" ]; then
                        if [ "$file_size" -ge "$min_size" ]; then
                            size=$((size + file_size))
                        fi
                    else
                        size="NA"  # Não foi possível determinar o tamanho do arquivo
                    fi
                fi
            fi
        done < <(find "$folder" -type f -print0)
        echo "$size $folder"
    done | \
    sort $sort_order | \
    if [ -n "$limit" ]; then
        head -n "$limit"
    else cat
    fi
