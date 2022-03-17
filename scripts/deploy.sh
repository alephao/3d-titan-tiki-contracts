#!/usr/bin/env bash

set -u
# import .env
set -o allexport
source .env
set +o allexport

PAYOUT_ADDRESS=$1
URL=$2
MERKLE_ROOT=$3

forge create TitanTiki3D \
  --constructor-args "$PAYOUT_ADDRESS" \
  --constructor-args "$URL" \
  --constructor-args "$MERKLE_ROOT" \
  --rpc-url "$RPC_URL" \
  --private-key "$PRIVATE_KEY" \
  --optimize \
  --force