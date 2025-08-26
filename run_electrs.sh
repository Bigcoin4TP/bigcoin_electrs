#!/bin/bash
# Script to run electrs container for Bitcoin testnet

docker run -d \
  --name electrs-bigcoin \
  -v "/Users/admin/Library/Application Support/Bigcoin:/root/.bitcoin:ro" \
  -v ./electrs-data:/data \
  -p 60001:60001 \
  -p 30001:3001 \
  --env ELECTRS_ARGS=" --cookie=edricnguyen:Bigcoin@20242028 --db-dir /data --timestamp --network testnet --daemon-rpc-addr 192.168.100.26:16332" \
  thunderbird2299/electrs-bigcoin:latest