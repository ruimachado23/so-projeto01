#!/bin/bash

# Trabalho realizado por:
# Rui de Faria Machado, 113765, P6
# João Manuel Vieira Roldão, 113920, P6

# Inicializacao de variáveis sort
reverse_sort=false      
alphabetical_sort=false

# Processamento das opções sort
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

shift $((OPTIND-1))                                                              # Shift dos argumentos

if [ "$#" -ne 2 ]; then
    echo "Erro: É necessário especificar dois ficheiros do spacecheck."          # Verificação se o número de argumentos é válido
    exit 1
fi

declare -A data1                    # Array associativo para armazenar dados do primeiro arquivo
declare -A data2                    # Array associativo para armazenar dados do segundo arquivo


# Leitura e armazenamento dados dos arquivos nos respetivos arrays associativos data1 e data2
while read -r size path; do
   data1["$path"]=$size
done < <(tail -n +2 "$1")
while read -r size path; do
   data2["$path"]=$size
done < <(tail -n +2 "$2")

# Cruzamento dos dados dos dois arrays associativos
for path in "${!data2[@]}"; do
    if [ -z "${data1[$path]}" ]; then
        data1["$path"]=""
    fi
done

# Header da tabela
echo "SIZE NAME"

# Função para exibir a diferença entre os sizes dos paths
show_difference() {
    local path=$1
    local size1=${data1[$path]}
    local size2=${data2[$path]}

    #Verificação se o path foi removido ou adicionado
    if [ -z "$size1" ] && [ -z "$size2" ]; then
        echo "0 $path"
    elif [ -z "$size1" ]; then
        echo "$size2 $path NEW"
    elif [ -z "$size2" ]; then
        if [ "$size1" -gt 0 ]; then                                 # Para colocar o size negativo, já que o path foi removido
            echo "-$size1 $path REMOVED"
        else
            echo "$size1 $path REMOVED"
        fi
    else
        local diff=$((size2 - size1))                               # Diferença entre os sizes dos paths
        if [ "$diff" -gt 0 ]; then
            echo "$diff $path"
        elif [ "$diff" -lt 0 ]; then
            echo "$diff $path"
        else
            echo "0 $path"
        fi
    fi
}

if [ "$reverse_sort" = true ] && [ "$alphabetical_sort" = true ]; then
    for path in "${!data1[@]}"; do
        show_difference "$path"
    done | sort -r -k2                                              # Ordem reversa do sort alfabeticamente
elif [ "$reverse_sort" = true ] && [ "$alphabetical_sort" = false ]; then
    for path in "${!data1[@]}"; do
        show_difference "$path"
    done | sort -n -k1,1                                            # Ordem reversa por size (menor para o maior)
elif [ "$reverse_sort" = false ] && [ "$alphabetical_sort" = true ]; then
    for path in "${!data1[@]}"; do
        show_difference "$path" 
    done | sort -k2                                                 # Ordem alfabética
elif [ "$reverse_sort" = false ] && [ "$alphabetical_sort" = false ]; then
    for path in "${!data1[@]}"; do
        show_difference "$path"
    done | sort -k1,1nr                                             # Ordem por size (maior para o menor)
fi
