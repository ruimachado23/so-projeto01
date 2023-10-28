#!/bin/bash

# Trabalho realizado por:
# Rui de Faria Machado, 113765, P6
# João Manuel Vieira Roldão, 113920, P6

# Initialize variables
regex=""
date=""
r=""
limit=""
dir=""

# Processamento e Validação das opções da linha de comando
while getopts "n:d:s:ral:" opt; do
    case $opt in
        n)
            regex="$OPTARG"
            ;;
        d)
            date="$OPTARG"
            ;;
        s)
            regex="$OPTARG"
            ;;
        r)
            r="-r"
            ;;
        a)
            r=""
            ;;
        l)
            limit="$OPTARG"
            ;;
        \?)
            echo "Opção inválida: -$OPTARG" >&2
            ;;
    esac
done

shift $((OPTIND - 1))

if [ $# -ne 1 ]; then
    echo "Erro: É necessário especificar um e um só diretório."
    exit 1
fi

dir="$1"

if [ -z "$date" ]; then
    date=".*"  # Use a default regex for date, which matches all dates
fi

if [ -z "$regex" ]; then
    regex=".*"  # Use a default regex to match all files
fi

if [ -z "$r" ]; then
    sort_order=""
else
    sort_order="$r"
fi

find "$dir" | \
    awk -v regex="$regex" '$0 ~ regex { print }' | \
    awk -v date="$date" '$0 ~ date { print }' | \
    sort $sort_order | \
    if [ -n "$limit" ]; then head -n "$limit"; else cat; fi
