-- Maximize any window on a Mac
--
-- Copyright (c) 2014 nico lindemann
-- Licensed under MIT: https://raw.githubusercontent.com/nicolindemann/apploader/master/LICENSE
--
-- Usage:
--  osascript maximizer.scpt APP-ID

on run argv
    
  set Dimentions to (do shell script "system_profiler SPDisplaysDataType | grep Resolution | awk '{print $2, $4}'")
  set displayWidth to word 1 of Dimentions
  set displayHeight to word 2 of Dimentions
  set appName to item 1 of argv
  
  tell application appName
    set windowBounds to bounds of window 1
    set bounds of window 1 to {0, 0, displayWidth, displayHeight}
  end tell
  
end run
