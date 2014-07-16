apploader
=========

Designed to automate downloads of apps from the iTunes App Store.

## Requirements

* Mac OS X. Tested on Mavericks only.
* Safari. Tested with 7.0.4.
* iTunes. Tested with 11.3.
* MouseTools (see http://www.hamsoftengineering.com/codeSharing/MouseTools/MouseTools.html)

## Usage

`./apploader.sh [-d] [-c] -u <itunes-url> [-posX <x>] [-posY <y>]`

```
-u     [arg] URL to process. Required.
-posX        X Position of button in iTunes. Default: 170, Assuming Resolution from 1680x1050
-poxY        Y Position of button in iTunes. Default: 390, Assuming Resolution from 1680x1050
-d           Enables debug mode
-c           Decolorize the output
-h           This page
```

