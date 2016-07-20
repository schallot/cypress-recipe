#!/bin/bash
secrets_file="$1"
/bin/sed -i "s/[a-f0-9]\{32,128\}/$(hexdump -n 64 -e '/1 "%02x"' -e '/64 "\n"' /dev/urandom)/" "$secrets_file"