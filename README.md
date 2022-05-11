# DEPRECATED

## No, seriously.  This shit's old.

sky_stripes
===========

Gnome 3 wallpaper based on the current sky color

The shell script does the following:

* Backup the current background.
* Grabs a pic from a local webcam. You should change the URL for a webcam that
  is local to you
* Crops off the part of the webcam pic that is NOT the sky. This way
  everything that remains is part of the sky.
* Calculates the average sky color
* Colorizes the black & white png using the sky color
* Creates a Gnome background XML file to gradually transition the previous
  background to the new one.
* Tells Gnome to use the new XML file and images
