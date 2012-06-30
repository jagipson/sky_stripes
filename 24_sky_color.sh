#!/bin/bash

hive=${XDG_RUNTIME_DIR:-/tmp/$USER}/24_sky
conf=$(dirname "$0")/config.txt
log=${hive}/fetch.log

mkdir -p "$hive"
:>"$log"

cp "$hive"/background{,_old}.png

# array of URLs
mapfile -n 24 -t cameras24 < "$conf"
mapfile -n 24 -t -s 24 crop24 < "$conf"

for ((lcv=0; lcv<24; lcv++)); do
  ( # Do in background
  # Init rgb to magenta to show errors
  red=255
  blue=255
  green=0
  wget "${cameras24[$lcv]}" \
    -O "${hive}/${lcv}.in" \
    -a "$log" \
    --timeout=5 
  cp -f "${hive}/${lcv}.in" "${hive}/${lcv}.img"
  mogrify -crop "${crop24[$lcv]:-'100%x100%+0+0'}" "${hive}/${lcv}.img" 
  rgb=$(convert "${hive}/${lcv}.img" \
    -modulate 100,200,100 \
    -scale 1x1\! \
    -format '%[fx:int(255*r+.5)] %[fx:int(255*g+.5)] %[fx:int(255*b+.5)]' \
    info:- ) 
  read red blue green <<<"$rgb"
  convert -size 80x1080 "xc:rgb($red,$blue,$green)" ${hive}/strip${lcv}.png
  ) &
done
wait # wait for web fetches and strip creation
# Combine strips

cp "${hive}/strip0.png" "${hive}/background.png"
for ((lcv=1; lcv<23; lcv++)); do
 convert "${hive}/background.png" "${hive}/strip${lcv}.png" +append "${hive}/background.png" 
done

sync
cat>${hive}/background.xml<<EOF
<background>
<starttime>
<hour>$(date +%H)</hour>
<minute>$(date +%M)</minute>
<second>$(date +%S)</second>
</starttime>

<static>
<duration>10.0</duration>
<file>${hive}/background_old.png</file>
</static>

<transition>
<duration>590.0</duration>
<from>${hive}/background_old.png</from>
<to>${hive}/background.png</to>
</transition>

<static>
<duration>3600.0</duration>
<file>${hive}/background.png</file>
</static>

<transition>
<duration>600.0</duration>
<from>${hive}/background.png</from>
<to>${hive}/background.png</to>
</transition>

</background>
EOF
# Run this in cron, activate the background using:
gsettings set org.gnome.desktop.background picture-uri file://${hive}/background.xml
