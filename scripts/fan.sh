#!/bin/bash
sensors | awk '
/RPM/ {
  for (i=1;i<=NF;i++)
    if ($i ~ /RPM/) {print $(i-1)" "$i; exit}
}'