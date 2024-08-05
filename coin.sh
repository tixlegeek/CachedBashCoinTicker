#!/usr/bin/env bash

# This function makes a request and stores it as cached file.
# cache is emptied on update. This prevent calling the API at each run
cacheRequest(){
  local PREFIX="$1"
  local URL="$2"
  local CACHE_PATH="/tmp/coincache"

  # This is useful so we can delete old cached requests.
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
  # echo $TIMETAG 1>&2
  # Creates and computes cached request filename and path.
  local REQ_="$URL"
  local REQ_HASH=$(echo -n ${REQ_}${TIMETAG} | md5sum | awk '{print $1;}')
  local CACHE_PREFIX="${CACHE_PATH}/${PREFIX}*.cache"
  local CACHE_FILE="${CACHE_PATH}/${PREFIX}${REQ_HASH}.cache"
  # If no expected file exists, we remove old cached requests, and create a new one
  if [ ! -f "$CACHE_FILE" ]; then
    echo "New ${CRYPTO} request" 1>&2
    rm -f ${CACHE_PREFIX}
    curl -s ${REQ_} -o "$CACHE_FILE" || return 1
  else
    echo $CACHE_FILE >&2
  fi
  local RES=$(cat "$CACHE_FILE")
  echo "$RES"
}
cryptoRequest(){
    local CRYPTO="$1"
    cacheRequest "$CRYPTO" "https://min-api.cryptocompare.com/data/price?fsym=${CRYPTO}&tsyms=BTC,USD,EUR"
}

MetalRequest(){
  local PREFIX="$1"
  local METAL_APIKEY=$(cat ./metal_api.key)
  local METAL="https://api.metalpriceapi.com/v1/latest?api_key=${METAL_APIKEY}&base=EUR&currencies=XAU,XAG"
  cacheRequest "$PREFIX" "$METAL"
}
# Set cache timeout (seconds)
export TIMEOUT=120
# XMR data
XMR=$(cryptoRequest "XMR" || exit 1)
[[ $? = 1 ]] && echo "FAIL";
XMRUSD=$(echo $XMR | jq .USD )
XMREUR=$(echo $XMR | jq .EUR )
# BTC data
BTC=$(cryptoRequest "BTC" || exit 1)
[[ $? = 1 ]] && echo "FAIL";
BTCUSD=$(echo $BTC | jq .USD )
BTCEUR=$(echo $BTC | jq .EUR )
# DOG data
DOGE=$(cryptoRequest "DOGE" || exit 1)
[[ $? = 1 ]] && echo "FAIL";
DOGEUSD=$(echo $DOGE | jq .USD )
DOGEEUR=$(echo $DOGE | jq .EUR )
# ETH data
ETH=$(cryptoRequest "ETH" || exit 1)
[[ $? = 1 ]] && echo "FAIL";
ETHUSD=$(echo $ETH | jq .USD )
ETHEUR=$(echo $ETH | jq .EUR )

# METAL data
METAL=$(MetalRequest "METAL" || exit 1)
[[ $? = 1 ]] && echo "FAIL";
# AG
XAG=$(echo $METAL | jq -r '.rates.XAG' )
XAGEUR=$(echo $METAL | jq -r '.rates.EURXAG' )
# AU
XAU=$(echo $METAL | jq -r '.rates.XAU' )
XAUEUR=$(echo $METAL | jq -r '.rates.EURXAU' )
# Convert to EUR/1g
G2OZ=31.1035
XAUgEUR=$(echo  "scale=5; $XAUEUR / $G2OZ" | bc -l)

# Do what you want with prices.
echo -e "₿;\t"$(printf "%.3f" ${BTCEUR/./,})" €;\t $BTCUSD\$"
echo -e "Ɱ;\t"$(printf "%.3f" ${XMREUR/./,})" €;\t $XMRUSD\$"
echo -e "Ð;\t"$(printf "%.3f" ${DOGEEUR/./,})" €;\t $DOGEUSD\$"
echo -e "Ξ;\t"$(printf "%.3f" ${ETHEUR/./,})" €;\t $ETHUSD\$"
echo -e "🜚;\t"$(printf "%.3f" ${XAGEUR/./,})" €;\t -\$"
echo -e "🜛g;\t"$(printf "%.3f" ${XAUgEUR/./,})" €;\t -\$"
