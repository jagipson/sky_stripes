#!/bin/bash

cp /tmp/sky_stripes{,_old}.png
wget 'http://media.lintvnews.com/BTI/KXAN02.jpg?1338982842187' \
  -O /tmp/sky.jpg \
  -o /tmp/sky.log
mogrify -crop 800x225+0+0 /tmp/sky.jpg
read red blue green <<< $(convert /tmp/sky.jpg \
  -modulate 100,200,100 \
  -scale 1x1\! \
  -format '%[fx:int(255*r+.5)] %[fx:int(255*g+.5)] %[fx:int(255*b+.5)]' \
  info:- )
convert $(dirname $0)/StripesBW.png \
  -fill "rgb($red,$blue,$green)" \
  -colorize 70% \
  /tmp/sky_stripes.png 

cat>/tmp/background.xml<<EOF
<background>
  <starttime>
    <hour>$(date +%H)</hour>
    <minute>$(date +%M)</minute>
    <second>$(date +%S)</second>
  </starttime>
  <static>
    <duration>1.0</duration>
    <file>/tmp/sky_stripes_old.png</file>
  </static>
  <transition>
    <duration>600.0</duration>
    <from>/tmp/sky_stripes_old.png</from>
    <to>/tmp/sky_stripes.png</to>
  </transition>
  <static>
    <duration>100000.0</duration>
    <file>/tmp/sky_stripes.png</file>
  </static>
</background>
EOF
# Run this in cron, activate the background using:
gsettings set org.gnome.desktop.background picture-uri file:///tmp/background.xml
