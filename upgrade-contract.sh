#!/bin/bash

# CONFIGURA AQUESTS VALORS
OWNER_PEM="../lamevawallet.pem"
PROXY="https://devnet-api.multiversx.com"
CHAIN="D"  # T = testnet, 1 = mainnet
CONTRACT_ADDRESS="erd1qqqqqqqqqqqqqpgqcmel0nnptj98xy4xzrucrls7x54h8s6a8xwstkctyk"  # posa aquí l'adreça del teu contracte

# Ruta al fitxer .wasm generat
WASM_PATH="./output/crowdfunding-sc.wasm"

mxpy contract upgrade $CONTRACT_ADDRESS \
  --bytecode $WASM_PATH \
  --recall-nonce \
  --gas-limit 80000000 \
  --pem $OWNER_PEM \
  --proxy $PROXY \
  --chain $CHAIN \
  --send
