apploader
=========


Designed to automate downloads of apps from the iTunes App Store. Performs an actual click in iTunes.

## Requirements

* Mac OS X. Tested on Mavericks only.
* Safari. Tested with 7.0.4.
* iTunes. Tested with 11.3.
* MouseTools (see http://www.hamsoftengineering.com/codeSharing/MouseTools/MouseTools.html)

## Usage

`./apploader.sh [-d] [-c] -u <itunes-url> [-posX <x>] [-posY <y>]`

```
-u     [arg] URL to process. Required.
-posX        X Position of button in iTunes. Default: 170, Assuming Resolution of 1680x1050
-poxY        Y Position of button in iTunes. Default: 390, Assuming Resolution of 1680x1050
-w           Wait x seconds before try to download the app. Default: 5
-d           Enables debug mode
-c           Decolorize the output
-h           This page
```

## Find mouse position

Using the MouseTools you can easily find out the right position on your system for the click on the download-button in iTunes. Just use:

`./MouseTools -location`
