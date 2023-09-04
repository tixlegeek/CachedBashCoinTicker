#!/usr/bin/env bash

# This function makes a request and stores it as cached file.
# cache is emptied on update. This prevent calling the API at each run
cacheRequest(){
  local CRYPTO="$1"
  local CACHE_PATH="/tmp/cypto"

  # This is useful so we can delete old cached requests.
  local PREFIX=${CRYPTO}"_"
  if [ ! -d "$CACHE_PATH" ]; then
    mkdir -p $CACHE_PATH || exit 1
  fi

  # This is what reseeds the cached filename. Each 2 minute, the name of the expected
  # file changes, so we regenerate it. You can tweak this like:
  #
  # TIMEOUT=3600 -> reload every hour
  # TIMEOUT=60 -> reload every minute
  if [ -z $TIMEOUT ]; then
    TIMEOUT=120
  fi
  local TIMETAG=$(( $(date "+%s") / ${TIMEOUT} ))
  #echo $TIMETAG 1>&2
  # Creates and computes cached request filename and path.
  local REQ_="https://min-api.cryptocompare.com/data/price?fsym=${CRYPTO}&tsyms=BTC,USD,EUR"
  local REQ_HASH=$(echo -n ${REQ_}${TIMETAG} | md5sum | awk '{print $1;}')
  local CACHE_PREFIX="${CACHE_PATH}/${PREFIX}*.cache"
  local CACHE_FILE="${CACHE_PATH}/${PREFIX}${REQ_HASH}.cache"

  # If no expected file exists, we remove old cached requests, and create a new one
  if [ ! -f "$CACHE_FILE" ]; then
    echo "New ${CRYPTO} request" 1>&2

    rm -f ${CACHE_PREFIX}
    curl -s ${REQ_} -o "$CACHE_FILE" || return 1
  fi
  local RES=$(cat "$CACHE_FILE")
  echo "$RES"
}

# Set cache timeout (seconds)
export TIMEOUT=120
# XMR data
XMR=$(cacheRequest "XMR" || exit 1)
XMRUSD=$(echo $XMR | jq .USD )
XMREUR=$(echo $XMR | jq .EUR )
# BTC data
BTC=$(cacheRequest "BTC" || exit 1)
BTCUSD=$(echo $BTC | jq .USD )
BTCEUR=$(echo $BTC | jq .EUR )
# DOG data
DOGE=$(cacheRequest "DOGE" || exit 1)
DOGEUSD=$(echo $DOGE | jq .USD )
DOGEEUR=$(echo $DOGE | jq .EUR )
# ETH data
ETH=$(cacheRequest "ETH" || exit 1)
ETHUSD=$(echo $ETH | jq .USD )
ETHEUR=$(echo $ETH | jq .EUR )

# Do what you want with prices.
echo -e "₿;\t$BTCEUR €;\t $BTCUSD\$"
echo -e "Ɱ;\t$XMREUR €;\t $XMRUSD\$"
echo -e "Ð;\t$DOGEEUR €;\t $DOGEUSD\$"
echo -e "Ξ;\t$ETHEUR €;\t $ETHUSD\$"
