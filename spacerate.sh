#!/bin/bash

# Trabalho realizado por:
#   Rui de Faria Machado, 113765, P6
#   João Manuel Vieira Roldão, 113920, P6

# Processamento  e Validacao das opcoes da linha de comando
while getopts "n:d:s:ral:" opt; do              # ":" após letra indica que necessita de argumento
    case $opt in                                # variável $OPTARG é usada para armazenar o argumento
        n|d|s)                                  # fornecido com essas opções.
            eval "$opt=\"$OPTARG\""             # -l é uma opção que requer um argumento, e o valor 
            ;;                                  # associado é armazenado na variável limit.
        r|a)
            eval "$opt=true"
            ;;
        l)
            limit="$OPTARG"                     
            ;;
        \?)
            echo "Opção inválida: -$OPTARG" >&2 # erro, printado no terminal
            ;;
    esac
done

shift $((OPTIND - 1))       # "deslocar" ou remover as opções de linha de comando já processadas
                            # de modo a que o diretório fique guardado na variável $1

if [ $# -ne 1 ]; then
    echo "Erro: É necessário especificar um e um só diretório."     #verifica se o utilizar introduziu um diretório
fi

find "$1" -type f -printf "%s %p\n" | \                             
    awk -v regex="$n" '$2 ~ regex { print }' | \
    sort $a | \
    head -n "$limit"

