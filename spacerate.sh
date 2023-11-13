#!/bin/bash

# Trabalho realizado por:
# Rui de Faria Machado, 113765, P6
# João Manuel Vieira Roldão, 113920, P6

# inicialização de variáveis sort
reverse_sort=false      
alphabetical_sort=false

# processamento das opções de sort
while getopts "ra" opt; do
    case "$opt" in
        r)
            reverse_sort=true
            ;;
        a)
            alphabetical_sort=true
            ;;
        \?)
            echo "Opção inválida." >&2                                           # verificar se a opção é valida
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))                                                              # "deslocar" ou "remover" as opções de linha de comando já processadas

if [ "$#" -ne 2 ]; then
    echo "Erro: É necessário especificar dois ficheiros output do spacecheck."   # verificar se o utilizador introduziu exatamente dois outputs do spacecheck 
    exit 1
fi

declare -A data1                    # array associativo para armazenar dados do primeiro output
declare -A data2                    # array associativo para armazenar dados do segundo output


# leitura e armazenamento dados dos ficheiros nos respetivos arrays associativos data1 e data2
while read -r size path; do
   data1["$path"]=$size             # guardar no array data1 uma key "path" para um valor "size", respetivo
done < <(tail -n +2 "$1")           # ignorar a primeira linha (cabeçalho)
while read -r size path; do         # guardar no array data2 uma key "path" para um valor "size", respetivo
   data2["$path"]=$size             # ignorar a primeira linha (cabeçalho)
done < <(tail -n +2 "$2")

# cruzamento dos dados dos dois arrays associativos
for path in "${!data2[@]}"; do              # para cada path do data2
    if [ -z "${data1[$path]}" ]; then       # se o data1 não tiver esse path como key no array
        data1["$path"]=""                   # cria uma com size="" (vazio)
    fi                                      # desta forma, conseguimos verificar path que foram adicionados
done

# cabeçalho do output
echo "SIZE NAME"

# função para exibir a diferença entre os sizes dos paths
show_difference() {
    # inicialização de variáveis
    local path=$1
    local size1=${data1[$path]}
    local size2=${data2[$path]}

    # verificação se o path foi removido ou adicionado
    if [ -z "$size1" ] && [ -z "$size2" ]; then                     # verifica se os dois sizes estão vazios
        echo "0 $path"                                              # size igual a zero
    elif [ -z "$size1" ]; then                                      # verifica se o size1 está vazio
        echo "$size2 $path NEW"                                     # é um novo path que está no data2 e não no data1
    elif [ -z "$size2" ]; then                                      # verifica se o size2 está vazio
        if [ "$size1" -gt 0 ]; then
            echo "-$size1 $path REMOVED"                            # path removido, então size fica menor que zero
        else
            echo "$size1 $path REMOVED"                             # path removido
        fi
    else
        local diff=$((size2 - size1))                               # diferença entre os sizes dos paths que estão nos ficheiros
        echo "$diff $path"                                          # print da diferença e do path
    fi
}

# manipulação da função show_difference() de acordo com as variáveis sort 
if [ "$reverse_sort" = true ] && [ "$alphabetical_sort" = true ]; then
    for path in "${!data1[@]}"; do
        show_difference "$path"
    done | sort -r -k2                                              # ordem reversa do sort alfabeticamente
elif [ "$reverse_sort" = true ] && [ "$alphabetical_sort" = false ]; then
    for path in "${!data1[@]}"; do
        show_difference "$path"
    done | sort -n -k1,1                                            # ordem reversa por size (menor para o maior)
elif [ "$reverse_sort" = false ] && [ "$alphabetical_sort" = true ]; then
    for path in "${!data1[@]}"; do
        show_difference "$path" 
    done | sort -k2                                                 # ordem alfabética
elif [ "$reverse_sort" = false ] && [ "$alphabetical_sort" = false ]; then
    for path in "${!data1[@]}"; do
        show_difference "$path"
    done | sort -k1,1nr                                             # ordem por size (maior para o menor)
fi
