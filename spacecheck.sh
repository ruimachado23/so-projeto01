#!/bin/bash

# Trabalho realizado por:
#   Rui de Faria Machado, 113765, P6
#   João Manuel Vieira Roldão, 113920, P6

# Processamento  e Validacao das opcoes da linha de comando
while getopts "n:d:s:ral:" opt; do              # ":" após letra indica que necessita de argumento
    case $opt in                                # variável $OPTARG é usada para armazenar o argumento
        n)
            eval "$opt=\"$OPTARG\""
            ;;
        d)
            eval "$opt=\"$OPTARG\""
            ;;
        s)                                      # fornecido com essas opções.
            eval "$opt=\"$OPTARG\""             # -l é uma opção que requer um argumento, e o valor 
            ;;                                  # associado é armazenado na variável limit.
        r)
            eval "$opt=true"
            ;;
        a)
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

find "$1"                                                           # procura o que existe no diretório especificado
    awk -v regex="$regex" '$2 ~ regex { print }' | \                # filtra os resultados com base em uma expressão regular especificada
                                                                        # filtra consoante a opcao de ordenaçao
    head -n "$limit"                                                # filtra consoante o limite

    if $r 
        sort 
    if $a
        sort -a