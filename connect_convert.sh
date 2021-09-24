#!/bin/bash

function show_help {
    echo "Help: $(basename $0)" 2>&1
    echo '  -r (retweet) allows retweet'
    echo '  -k (keyword) set of search keywords, example: cat,dog,mouse'
    exit 1
}

# twitter api search function that accepts keyword string as search parameters
# configured from -k option array
function search_twitterAPI {
    twarc search "'$1'" --lang en > ./API_output.jsonl
}

# qualify no option provided
if [[ ${#} -eq 0 ]]; then
    show_help
fi

optstring=":hrk:"

while getopts ${optstring} arg; do
    case "${arg}" in
        r)
            # TODO retweet status qualification
            echo "Retweet option selected"
            ;;
        k)
            set -f
            IFS=','
            keywords=($OPTARG)
            search_params=${keywords[0]}
            # qualify existence of multiple keyword inputs and build 'OR' set
            # search query from input of keywords array
            if [[ ${#keywords[@]} -gt 1 ]]; then
                for ((i = 1 ; i < ${#keywords[@]} ; ++i)); do
                    search_params+=" OR ${keywords[i]}"
                done
            fi
            ;;
        h)
            show_help
            ;;
        ?)
            echo "Invalid option: -${OPTARG}"
            show_help
            ;;
    esac
done

echo "Searching Twitter API for: $search_params"
search_twitterAPI "$search_params"
