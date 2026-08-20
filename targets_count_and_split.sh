#!/bin/bash

INPUT_FILE="targets.txt"
CHUNK_SIZE=1000
OUTPUT_DIR="output_hosts"

mkdir -p "$OUTPUT_DIR"
> all_hosts.tmp  # Clear temporary output

# --- Utility Functions ---

# Check if input is CIDR
is_cidr() {
  [[ "$1" == */* ]]
}

# Convert IP to integer
ip_to_int() {
  local IFS=.
  read -r a b c d <<< "$1"
  echo $(( (a << 24) + (b << 16) + (c << 8) + d ))
}

# Convert integer to IP
int_to_ip() {
  local ip dec=$1
  for _ in {1..4}; do
    ip=$(( dec & 255 ))${ip:+.}$ip
    ((dec >>= 8))
  done
  echo "$ip"
}

# Expand CIDR into usable IPs
expand_cidr() {
  local cidr="$1"
  IFS=/ read -r base_ip prefix <<< "$cidr"
  local ip_start=$(ip_to_int "$base_ip")
  local total_ips=$((2 ** (32 - prefix)))

  local start_offset=0
  local end_offset=$((total_ips - 1))

  # If /32, only one IP; if /31, two usable; else skip network & broadcast
  if (( prefix < 31 )); then
    start_offset=1
    end_offset=$((total_ips - 2))
  fi

  for ((i = start_offset; i <= end_offset; i++)); do
    int_to_ip $((ip_start + i))
  done
}

# --- Main Logic ---

echo "Generating host list..."

while read -r line; do
  [[ -z "$line" || "$line" == \#* ]] && continue

  if is_cidr "$line"; then
    expand_cidr "$line" >> all_hosts.tmp
  else
    echo "$line" >> all_hosts.tmp
  fi
done < "$INPUT_FILE"

total_hosts=$(wc -l < all_hosts.tmp)
file_count=$(( (total_hosts + CHUNK_SIZE - 1) / CHUNK_SIZE ))

echo "Total usable hosts: $total_hosts"
echo "Splitting into $file_count file(s) with up to $CHUNK_SIZE each..."

# Split into chunks
split -l "$CHUNK_SIZE" -d --additional-suffix=.txt all_hosts.tmp "$OUTPUT_DIR/hosts_part_"

# Clean up temp
rm all
 
