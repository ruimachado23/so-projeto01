#!/bin/bash

# Trabalho realizado por:
# Rui de Faria Machado, 113765, P6
# João Manuel Vieira Roldão, 113920, P6

exec &> spacecheck_$(date +%Y%m%d).txt      # guardar o output do script num ficheiro .txt

# inicialização de variáveis
regex=""
provited_date=""
limit=""
dir=""
options=""
min_size=""

parse_date() {
    input_date="$1"
    # Use awk to extract the month, day, and time
    month=$(echo "$input_date" | awk '{print $1}')
    day=$(echo "$input_date" | awk '{print $2}')
    time=$(echo "$input_date" | awk '{print $3}')
    # Construct a date in the format "MMM DD HH:MM YYYY"
    formatted_date="$month $day $time $(date +%Y)"
    # Use date to convert the formatted date into seconds since the epoch
    date -d "$formatted_date" +%s
}

# processamento e validação das opções da linha de comando
while getopts "n:d:s:ral:" opt; do                                  # ":" após letra indica que necessita de argumento
    case $opt in
        n)
            regex="$OPTARG"                                         # $OPTARG é usada para armazenar o argumento
            options="$options -$opt \"$OPTARG\""                    # adicionar a variável à string options
            ;;
        d)
            provited_date="$OPTARG"
            options="$options -$opt \"$OPTARG\""

            if [[ -n "$provited_date" ]]; then
                converted_date=$(parse_date "$provited_date")
                da=1
                dc=0
            else
                echo "Erro: Data em formato inválido --> \"MMM DD HH:MM\"" >&2
                exit 1
            fi
            ;;
        s)
            min_size="$OPTARG"
            options="$options -$opt \"$OPTARG\""
            ;;
        r)
            options="$options -$opt"                                # não existe argumento para armazenar    
            ;;
        a)
            options="$options -$opt"                                # não existe argumento para armazenar    
            ;;
        l)
            limit="$OPTARG"
            options="$options -$opt \"$OPTARG\""
            ;;
        \?)
            echo "Opção inválida: -$OPTARG" >&2                     # validação da opção 
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))       # "deslocar" ou "remover" as opções de linha de comando já processadas
                            # de modo a que o diretório fique guardado na variável $1
if [ $# -ne 1 ]; then
    echo "Erro: É necessário especificar um e um só diretório."     # verificar se o utilizador introduziu um e um só diretório
    exit 1
fi

dir="$1"                    # passar o diretório para a variável "dir"

if [ -z "$provited_date" ]; then
    converted_date=".*"               # se a variável estiver vazia, o script define como ".*",
fi                          # corresponde a qualquer sequência de caracteres

if [ -z "$regex" ]; then
    regex=".*"
fi

if [ -z "$min_size" ]; then
    min_size=0              # se a variável estiver vazia, o script define como 0
fi

# manipulação das flags -r e -a
if [[ "$options" != *"-r"* ]] && [[ "$options" != *"-a"* ]]; then      # quando ambas as flags não foram inseridas:
    sort_order="-k1,1nr"                                               # classifica os dados por ordem decrescente com base na primeira coluna (-k1,1).
elif [[ "$options" == *"-r"* ]] && [[ "$options" != *"-a"* ]]; then    # quando a flag "-r" foi inserida, mas a "-a" não:
    sort_order="-k1,1n"                                                # classifica os dados em ordem crescente com base na primeira coluna (-k1,1).
elif [[ "$options" != *"-r"* ]] && [[ "$options" == *"-a"* ]]; then    # quando a flag "-r" não foi inseridas, mas a "-a" sim:
    sort_order="-k2,2"                                                 # classifica os dados em ordem crescente com base na segunda coluna (-k2,2).
elif [[ "$options" == *"-r"* ]] && [[ "$options" == *"-a"* ]]; then    # quando ambas as flags foram inseridas:
    sort_order="-k2,2r"                                                # classifica os dados em ordem decrescente com base na segunda coluna (-k2,2).
fi

# print do cabeçalho
echo "SIZE NAME $(date +%Y%m%d)$options $dir"

# pesquisa do diretório, atendendo critérios
find "$dir" -type d | \
    while read -r folder; do
        size=0
        while IFS= read -r -d $'\0' file; do
            if [[ -f "$file" && $(basename "$file") =~ $regex ]]; then      # manipulação de acordo com a flag "-n" (name)
                if [[ "$converted_date" != ".*" ]]; then                              # manipulação de acordo com a flag "-d" (date)
                    file_date=$(date -r "$file" +%s)                        # quando é introduzida data
                    if [[ "$file_date" -ge "$converted_date" ]]; then
                        file_size=$(du -b "$file" 2>/dev/null | cut -f1)    
                        if [ -n "$file_size" ]; then
                            if [ "$file_size" -ge "$min_size" ]; then       # manipulação de acordo com a flag "-s" (size)
                                size=$((size + file_size))
                            fi
                        else
                            size="NA"                                       # não foi possível determinar o tamanho do arquivo
                        fi
                    fi
                else                                                        # quando não é introduzida data
                    file_size=$(du -b "$file" 2>/dev/null | cut -f1)
                    if [ -n "$file_size" ]; then
                        if [ "$file_size" -ge "$min_size" ]; then
                            size=$((size + file_size))
                        fi
                    else
                        size="NA"                                           # não foi possível determinar o tamanho do arquivo
                    fi
                fi
            fi
        done < <(find "$folder" -type f -print0)
        echo "$size $folder"                                                # print do size e do folder
    done | \
    # manipulação de acordo com as flags de sort "-r" e "-a" (reverse e alphabetical, respetivamente) 
    sort $sort_order | \
    if [ -n "$limit" ]; then                                                # manipulação de acordo com a flag "-l" (limit)
        head -n "$limit"
    else cat
    fi
