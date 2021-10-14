# raw-tweets-to-csv-script

## Description:

Raw tweets to CSV script (RTTCS) is a simple script for searching the Twitter API and converting the resulting raw tweet data into a CSV document.

## Requirements:

- jq
- sed
- twarc

## Usage:

The component of the script that connects and interfaces the Twitter API is achieved through the Twarc library, authentication is achieved through obtaining Twitter Developer credentials from Twitter itself and providing such credentials to Twarc as described in their Documentation (either through the commandline or .twarc). Once credentials has been provided correctly, the script will run as required.

***1. Help:***

See all functionality options:

```sh
bash rttcs.sh -h
```

***2. Search:***

Provide keyword search parameter for Twitter API:

```sh
bash rttcs.sh -k elephant
```

The above will retrieve all tweets containing the word elephant.

Multiple keywords can also be provided:

```sh
bash rttcs.sh -k sun,moon,mars
```

The above will retrieve all tweets that contain either sun, moon, or mars - does not follow 'AND' conditionality, as default is 'OR'. To alter the logical operator of the search query, initiate the AND operator with -a:

```sh
bash rttcs.sh -a -k robot,spaceship
```

The search query will involve 'robot AND spaceship'. By default retweets are not removed from the dataset, therefore, by including the -r option, all retweets will be removed from the Twitter response dataset.

```sh
bash rttcs.sh -rvk dogs,cats
```

In the above example I had included the -v option, this sets the verbosity of the script to 'on', so that script updates are printed to the terminal. Another key option that can be utilised is -s, by providing this option all intermediate processing and raw files gathered and generated throughout the script proccesses are saved, which are in JSONL format, by default they are all deleted on script completion.

```sh
bash rttcs.sh -sk lemon,orange,soda
```

Below both the -o and -d option have been demonstrated, the -o option can be used to manually set the filepath for all generated files, and -d for general naming conventions of the final datasets.

```sh
bash rttcs.sh -ravs -d my_tweet_data -o my_data/twitter_data -k pasta,cheese,tomato
```