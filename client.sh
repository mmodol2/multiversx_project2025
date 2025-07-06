#!/bin/bash
# CONFIGURACIÓ
CONTRACT="erd1qqqqqqqqqqqqqpgqwtq6nej9r9afl9k4r7zl2nqyrwpcwrh38xwsmwf4g6"
PEM="../lamevawallet.pem"
PROXY="https://devnet-api.multiversx.com"
CHAIN="D"

# Conversió hex → decimal
hex_to_decimal() {
  local hex_value=$1
  python3 -c "print(int('$hex_value', 16))" 2>/dev/null || echo "0"
}

# Conversió denominació mínima → EGLD
denomination_to_egld() {
  local denomination=$1
  python3 -c "print(f'{$denomination / 10**18:.18f} EGLD')" 2>/dev/null || echo "$denomination"
}

# STATUS: FundingPeriod, Successful, Failed
parse_status() {
  local status=$1
  case $status in
    ""|"00"|"0") echo "FundingPeriod" ;;
    "01"|"1") echo "Successful" ;;
    "02"|"2") echo "Failed" ;;
    *) echo "Desconegut: $status" ;;
  esac
}

# FUNCIONS CONTRACTE
fund() {
  read -p "Quantitat a donar (wei): " amount
  mxpy contract call $CONTRACT \
    --pem $PEM \
    --gas-limit=5000000 \
    --value $amount \
    --function fund \
    --proxy $PROXY \
    --chain $CHAIN \
    --send
}

claim() {
  mxpy contract call $CONTRACT \
    --pem $PEM \
    --gas-limit=5000000 \
    --function claim \
    --proxy $PROXY \
    --chain $CHAIN \
    --send
}

status() {
  hex=$(mxpy contract query $CONTRACT --function status --proxy $PROXY | jq -r '.[0]')
  dec=$(hex_to_decimal "$hex")
  parsed=$(parse_status "$dec")
  echo "Status: $parsed"
}

get_current_funds() {
  hex=$(mxpy contract query $CONTRACT --function getCurrentFunds --proxy $PROXY | jq -r '.[0]')
  dec=$(hex_to_decimal "$hex")
  egld=$(denomination_to_egld "$dec")
  echo "Fons actuals: $egld ($dec wei)"
}

get_target() {
  hex=$(mxpy contract query $CONTRACT --function getTarget --proxy $PROXY | jq -r '.[0]')
  dec=$(hex_to_decimal "$hex")
  egld=$(denomination_to_egld "$dec")
  echo "Target: $egld ($dec wei)"
}

get_deadline() {
  hex=$(mxpy contract query $CONTRACT --function getDeadline --proxy $PROXY | jq -r '.[0]')
  dec=$(hex_to_decimal "$hex")
  date=$(date -d "@$dec" "+%d/%m/%Y %H:%M:%S" 2>/dev/null || date -r "$dec")
  echo "Deadline: $date ($dec)"
}

get_deposit() {
  read -p "Address donant: " donor
  hex=$(mxpy contract query $CONTRACT --function getDeposit --arguments $donor --proxy $PROXY | jq -r '.[0]')
  dec=$(hex_to_decimal "$hex")
  egld=$(denomination_to_egld "$dec")
  echo "Donació de $donor: $egld ($dec wei)"
}

# NOU: assignar tots els límits
set_limits() {
  read -p "Mínim per tx (wei): " min_tx
  read -p "Màxim per wallet (wei): " max_wallet
  read -p "Màxim total projecte (wei): " max_total

  mxpy contract call $CONTRACT \
    --function setLimits \
    --arguments $min_tx $max_wallet $max_total \
    --gas-limit 60000000 \
    --pem $PEM \
    --proxy $PROXY \
    --chain $CHAIN \
    --send
}

# NOU: consultar tots els límits
get_limits() {
  echo "== Límits del contracte =="
  # min per tx
  min_hex=$(mxpy contract query $CONTRACT --function getMinPerTx --proxy $PROXY | jq -r '.[0]')
  min_dec=$(hex_to_decimal "$min_hex")
  min_egld=$(denomination_to_egld "$min_dec")
  echo "Mín per tx: $min_egld ($min_dec wei)"
  # max per wallet
  max_wallet_hex=$(mxpy contract query $CONTRACT --function getMaxPerWallet --proxy $PROXY | jq -r '.[0]')
  max_wallet_dec=$(hex_to_decimal "$max_wallet_hex")
  max_wallet_egld=$(denomination_to_egld "$max_wallet_dec")
  echo "Màx per wallet: $max_wallet_egld ($max_wallet_dec wei)"
  # max total
  max_total_hex=$(mxpy contract query $CONTRACT --function getMaxTotal --proxy $PROXY | jq -r '.[0]')
  max_total_dec=$(hex_to_decimal "$max_total_hex")
  max_total_egld=$(denomination_to_egld "$max_total_dec")
  echo "Màx total projecte: $max_total_egld ($max_total_dec wei)"
}

# MENU INTERACTIU
while true; do
  echo ""
  echo "==== Crowdfunding SC Menu ===="
  echo "1) Donar (fund)"
  echo "2) Reclamar (claim)"
  echo "3) Status"
  echo "4) Fons actuals"
  echo "5) Target"
  echo "6) Deadline"
  echo "7) Donació d'una address"
  echo "8) Assignar límits globals (min, max_wallet, max_total)"
  echo "9) Consultar límits globals"
  echo "0) Sortir"
  echo "=============================="
  read -p "Opció: " op
  case $op in
    1) fund ;;
    2) claim ;;
    3) status ;;
    4) get_current_funds ;;
    5) get_target ;;
    6) get_deadline ;;
    7) get_deposit ;;
    8) set_limits ;;
    9) get_limits ;;
    0) echo "Sortint..."; break ;;
    *) echo "Opció no vàlida." ;;
  esac
done
