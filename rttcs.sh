#!/bin/bash

declare -A data_files

function show_help {
    echo "Help: $(basename $0)" 2>&1
    echo '  -d set CSV output filename, example: tweet_data'
    echo '  -o set filepath for data output, example: datasets'
    echo '  -r remove retweets from gathered twitter dataset'
    echo '  -k provide set of search keywords, example: cat,dog,mouse'
    echo '  -a set logical operator for search query as AND, default: OR'
    echo '  -v set verbose mode, enable message printing'
    echo '  -s save generated processing and source files'
    exit 1
}

# twitter api search function that accepts keyword string as search parameters
# configured from -k option array
function search_twitterAPI {
    twarc search "'$1'" --lang en > $2
}

function deselect_retweets {
    cat $1 | jq -c ' . | select(.retweeted_status == null) ' > $2
}

function format_tweets {
    cat $1 | jq -c '. | {tweet_id: .id_str, user_id: .user.id_str, date_created: .created_at, tweet_text: .full_text}' > $2 \
    && sed 's/\\n/\\t/g' $2 | jq -cr ". | [.tweet_id, .user_id, .date_created, .tweet_text] | @csv" > $3
}

function format_hashtags {
    cat $1 | jq -cr '. | {tweet_id: .id_str, hashtag: .entities.hashtags[].text} | [.tweet_id, .hashtag] | @csv' > $2
}

function print_msg {
    [[ ${verbose} == 'true' ]] && echo $1
}

init=$(date +'%s')
delete_processing_files='true'
remove_retweets='false'
output_path=''
output_file='RTTCS_data'
search_op='OR'

# qualify no option provided
[[ ${#} -eq 0 ]] && show_help

optstring=":harsvd:o:k:"

while getopts ${optstring} arg; do
    case "${arg}" in
        a)
            search_op='AND'
            ;;
        v)
            verbose='true'
            ;;
        s)
            delete_processing_files='false'
            ;;
        r)
            remove_retweets='true'
            ;;
        o)
            set -f
            output_path+="/$OPTARG"
            ;;
        d)
            set -f
            output_file="$OPTARG"
            ;;
        k)
            set -f
            IFS=','
            keywords=($OPTARG)
            search_params=${keywords[0]}
            # qualify existence of multiple keyword inputs and build 'OR' set
            # search query from input of keywords array
            [[ ${#keywords[@]} -gt 1 ]] && \
            for ((i = 1 ; i < ${#keywords[@]} ; ++i)); do
                search_params+=" ${search_op} ${keywords[i]}"
            done
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

# filepath naming conventions
data_files[API_DATA]=".${output_path}/_RTTCS_api_output_${init}.jsonl"
data_files[NORETWEET_DATA]=".${output_path}/_RTTCS_noretweet_${init}.jsonl"
data_files[PROCESS_DATA]=".${output_path}/_RTTCS_process_${init}.jsonl"
data_files[OUTPUT_DATA]=".${output_path}/${output_file}_${init}.csv"
data_files[HASHTAG_DATA]=".${output_path}/${output_file}_hashtag_${init}.csv"

print_msg "Searching Twitter API for: ${search_params}"
search_twitterAPI "${search_params}" "${data_files[API_DATA]}" \
&& [[ ${remove_retweets} == 'true' ]] \
&& deselect_retweets "${data_files[API_DATA]}" "${data_files[NORETWEET_DATA]}" \
&& format_tweets "${data_files[NORETWEET_DATA]}" "${data_files[PROCESS_DATA]}" "${data_files[OUTPUT_DATA]}" \
&& format_hashtags "${data_files[NORETWEET_DATA]}" "${data_files[HASHTAG_DATA]}" \
|| format_tweets "${data_files[API_DATA]}" "${data_files[PROCESS_DATA]}" "${data_files[OUTPUT_DATA]}" \
&& format_hashtags "${data_files[API_DATA]}" "${data_files[HASHTAG_DATA]}"

print_msg "File created: ${data_files[OUTPUT_DATA]}"
print_msg "File created: ${data_files[HASHTAG_DATA]}"

[[ ${delete_processing_files} == 'true' ]] \
&& [[ ${remove_retweets} == 'true' ]] \
&& rm ${data_files[API_DATA]} ${data_files[NORETWEET_DATA]} ${data_files[PROCESS_DATA]} \
|| [[ ${delete_processing_files} == 'true' ]] \
&& [[ ${remove_retweets} == 'false' ]] \
&& rm ${data_files[API_DATA]} ${data_files[PROCESS_DATA]}

print_msg "Tweet data extracted and format conversion complete."

exit 0