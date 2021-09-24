# raw-tweets-to-csv-script

## Description:

Incomplete.
Simple shell script for searching the Twitter API and converting the resulting raw tweet data into a CSV document.

## Usage:

***1. Help:***

See all functionality options:

```sh
bash connect_convert.sh -h
```

***2. Search:***

Provide keyword search parameter for Twitter API:

```sh
bash conect_convert.sh -k elephant
```

The above will retrieve all tweets containing the word elephant.

Multiple keywords can also be provided:

```sh
bash connect_convert.sh -k sun,moon,mars
```

The above will retrieve all tweets that contain either sun, moon, or mars - does not follow 'AND' conditionality, only 'OR'.