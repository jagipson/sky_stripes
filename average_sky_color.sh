#!/bin/bash

cp /tmp/sky_stripes{,_old}.png
cp /tmp/sky_stripes.png "/tmp/sky_stripes_$(date +%H%M).png"
wget http://12.52.91.101/axis-cgi/jpg/image.cgi \
  -O /tmp/sky.jpg \
  -o /tmp/sky.log
mogrify -crop 280x200+0+0 /tmp/sky.jpg
read red blue green <<< $(convert /tmp/sky.jpg \
  -modulate 100,200,100 \
  -scale 1x1\! \
  -format '%[fx:int(255*r+.5)] %[fx:int(255*g+.5)] %[fx:int(255*b+.5)]' \
  info:- )
convert $(dirname $0)/StripesBW.png \
  -fill "rgb($red,$blue,$green)" \
  -colorize 70% \
  /tmp/sky_stripes.png 
sync
cat>/tmp/background.xml<<EOF
<background>
<starttime>
<hour>$(date +%H)</hour>
<minute>$(date +%M)</minute>
<second>$(date +%S)</second>
</starttime>

<static>
<duration>10.0</duration>
<file>/tmp/sky_stripes_old.png</file>
</static>

<transition type="overlay">
<duration>590.0</duration>
<from>/tmp/sky_stripes_old.png</from>
<to>/tmp/sky_stripes.png</to>
</transition>

<static>
<duration>3600.0</duration>
<file>/tmp/sky_stripes.png</file>
</static>

<transition type="overlay">
<duration>600.0</duration>
<from>/tmp/sky_stripes.png</from>
<to>/tmp/sky_stripes.png</to>
</transition>

</background>
EOF
# Run this in cron, activate the background using:
gsettings set org.gnome.desktop.background picture-uri file:///tmp/background.xml
