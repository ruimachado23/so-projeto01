#!/bin/bash

# Trabalho realizado por:
# Rui de Faria Machado, 113765, P6
# João Manuel Vieira Roldão, 113920, P6

if [ "$#" -ge 2 ]; then
    echo "Usage: $0 [-r] [-a] <file1> <file2>"          # verificacao se o numero de args é válido
    exit 1
fi

# inicializacao de variaveis
reverse_sort=false      
alphabetical_sort=false

# processamento das opcoes
while getopts "ra" opt; do
    case "$opt" in
        r)
            reverse_sort=true
            ;;
        a)
            alphabetical_sort=true
            ;;
        \?)
            echo "Usage: $0 [-r] [-a] <file1> <file2>"
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

declare -A data1                    # Array associativo para armazenar dados do primeiro arquivo
declare -A data2                    # Array associativo para armazenar dados do segundo arquivo

# Lê e armazena dados do primeiro arquivo no array associativo data1
while read -r size path; do
    data1["$path"]=$size
done < "$1"

# Lê e armazena dados do segundo arquivo no array associativo data2
while read -r size path; do
    data2["$path"]=$size
done < "$2"

# Função para exibir a diferença para um determinado caminho
show_difference() {
    local path=$1
    local size1=${data1[$path]}
    local size2=${data2[$path]}

    if [ -z "$size1" ] && [ -z "$size2" ]; then
        echo "0 $path"                              # sem alteração no tamanho  - size1 e size2 vazios
    elif [ -z "$size1" ]; then
        echo "$size2 $path NEW"                     # diretório/arquivo adicionado - size1 está vazio
    elif [ -z "$size2" ]; then
        echo "$size1 $path REMOVED"                 # diretório/arquivo removido - size2 está vazio
    else
        local diff=$((size2 - size1))
        echo "$diff $path"                          # diferença de tamanho
    fi
}

# manipulacao das opcoes de sort
if [ "$reverse_sort" = true ] && [ "$alphabetical_sort" = true ]; then
    for path in "${!data1[@]}"; do
        show_difference "$path"
    done | sort -r -k2                              # ordem reversa alfabeticamente por caminho
elif [ "$reverse_sort" = true ]; then
    for path in "${!data1[@]}"; do
        show_difference "$path"
    done | sort -r -k1                              # reversa numericamente por diferença de tamanho
elif [ "$alphabetical_sort" = true ]; then
    for path in "${!data1[@]}"; do
        show_difference "$path" 
    done | sort -k2                                 # alfabeticamente por caminho
else
    for path in "${!data1[@]}"; do
        show_difference "$path"
    done | sort -k1                                 # numericamente por diferença de tamanho
fi
