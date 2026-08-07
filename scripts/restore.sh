#!/usr/bin/env bash

set -e

setxkbmap \
  -layout "us,ua,ru" \
  -option "grp:win_space_toggle" \
  -option "grp:alt_shift_toggle" \
  -option "terminate:ctrl_alt_bksp"

echo "Restored us, ua, ru layouts."