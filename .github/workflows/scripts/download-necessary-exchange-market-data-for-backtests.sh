#!/bin/bash
MAIN_DATA_DIRECTORY="user_data/data"
# For manual running you can use these
# TIMEFRAME="5m"
# HELPER_TIME_FRAMES="15m 1h 4h 1d"
# TRADING_MODE="spot"
# EXCHANGE="binance"
URL="https://github.com/DigiTuccar/HistoricalDataForTradeBacktest.git"

# ls -la user_data
# ls -la $MAIN_DATA_DIRECTORY

# if [ ! \( -e "${file}" \) ]
# then
#      echo "%ERROR: file ${file} does not exist!" >&2
#      exit 1
# elif [ ! \( -f "${file}" \) ]
# then
#      echo "%ERROR: ${file} is not a file!" >&2
#      exit 2
# elif [ ! \( -r "${file}" \) ]
# then
#      echo "%ERROR: file ${file} is not readable!" >&2
#      exit 3
# elif [ ! \( -s "${file}" \) ]
# then
#      echo "%ERROR: file ${file} is empty!" >&2
#      exit 4
# fi


if [ -L $MAIN_DATA_DIRECTORY ]
    then
        echo "###############################################"
        echo $MAIN_DATA_DIRECTORY exists on your filesystem. We will delete it for Github CI Workflow
        echo "###############################################"
        rm -rf $MAIN_DATA_DIRECTORY
    else
    echo "###############################################"
    echo $MAIN_DATA_DIRECTORY not exists on your filesystem. Necessary to download first
    echo "###############################################"

fi


if [ -d $MAIN_DATA_DIRECTORY ]
    then
        echo "###############################################"
        echo $MAIN_DATA_DIRECTORY exists on your filesystem. We will delete it for Github CI Workflow
        echo "###############################################"
        rm -rf $MAIN_DATA_DIRECTORY
    else
    echo "###############################################"
    echo $MAIN_DATA_DIRECTORY not exists on your filesystem. Necessary to download first
    echo "###############################################"

fi
    git clone --filter=blob:none --no-checkout --depth 1 --sparse $URL $MAIN_DATA_DIRECTORY
    git -C $MAIN_DATA_DIRECTORY sparse-checkout reapply --no-cone
    sudo chown -R $(id -u):$(id -g) $MAIN_DATA_DIRECTORY


echo "Fetching necessary Timeframe Data"

for data_necessary_exchange in ${EXCHANGE[*]}
do
for data_necessary_market_type in ${TRADING_MODE[*]}
do
for data_necessary_timeframe in ${TIMEFRAME[*]}
do
echo
echo "--------------------------------------------------------------------------------------------------------"
echo "# Exchange: $data_necessary_exchange      Market Type: $data_necessary_market_type      Time Frame: $data_necessary_timeframe"
echo "--------------------------------------------------------------------------------------------------------"
echo

# Configure Market Data Directory
EXCHANGE_MARKET_DIRECTORY=$data_necessary_exchange

if [[ $data_necessary_market_type == futures ]]
    then
    EXCHANGE_MARKET_DIRECTORY=$data_necessary_exchange/futures
    else
    EXCHANGE_MARKET_DIRECTORY=$data_necessary_exchange
fi

for pair in `docker-compose run --rm tests freqtrade test-pairlist -c configs/pairlists-$data_necessary_market_type.json -c configs/pairlist-static-$data_necessary_exchange-$data_necessary_market_type-usdt.json -c configs/exampleconfig.json -1 --exchange $data_necessary_exchange -c configs/blacklist-$data_necessary_exchange.json|sed -e 's+/+_+g'`

do

echo $pair
echo $pair*-$data_necessary_timeframe*.feather
echo /$EXCHANGE_MARKET_DIRECTORY/$pair*-$data_necessary_timeframe*.feather >> user_data/data/.git/info/sparse-checkout
#git -C $MAIN_DATA_DIRECTORY sparse-checkout add /$EXCHANGE_MARKET_DIRECTORY/$pair*-$data_necessary_timeframe*.feather

done

done
done
done

echo "Fetching necessary Helper Timeframe Data"
for data_necessary_exchange in ${EXCHANGE[*]}
do
for data_necessary_market_type in ${TRADING_MODE[*]}
do
for data_necessary_timeframe in ${HELPER_TIME_FRAMES[*]}
do
echo
echo "--------------------------------------------------------------------------------------------------------"
echo "# Exchange: $data_necessary_exchange      Market Type: $data_necessary_market_type      Time Frame: $data_necessary_timeframe"
echo "--------------------------------------------------------------------------------------------------------"
echo

EXCHANGE_MARKET_DIRECTORY=$data_necessary_exchange

if [[ $data_necessary_market_type == futures ]]
    then
    EXCHANGE_MARKET_DIRECTORY=$data_necessary_exchange/futures
    else
    EXCHANGE_MARKET_DIRECTORY=$data_necessary_exchange
fi

for pair in `docker-compose run --rm tests freqtrade test-pairlist -c configs/pairlists-$data_necessary_market_type.json -c configs/pairlist-static-$data_necessary_exchange-$data_necessary_market_type-usdt.json -c configs/exampleconfig.json -1 --exchange $data_necessary_exchange -c configs/blacklist-$data_necessary_exchange.json|sed -e 's+/+_+g'`

do

echo $pair
echo $pair*-$data_necessary_timeframe*.feather
echo /$EXCHANGE_MARKET_DIRECTORY/$pair*-$data_necessary_timeframe*.feather >> user_data/data/.git/info/sparse-checkout
#git -C $MAIN_DATA_DIRECTORY sparse-checkout add /$EXCHANGE_MARKET_DIRECTORY/$pair*-$data_necessary_timeframe*.feather

done

done
done
done
git -C $MAIN_DATA_DIRECTORY checkout

echo "---------------------------------------------"
echo "All necessary data fetched"
