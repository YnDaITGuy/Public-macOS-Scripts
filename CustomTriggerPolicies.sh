#!/bin/bash

currentUser=$(ls -l /dev/console | awk '{print $3}')
OSASCRIPT="/usr/bin/osascript"
JAMF="/usr/local/bin/jamf"
time=$(date +"%r")

##########  ##########

## You can put the notificatio/message on screen to show user what's going on

## This is notification, doesn't show anymore since Monterey, probably osascript PPPC
#"$OSASCRIPT" -e 'display notification  "Downloading Something"'

## This is a message/dialog window, auto close after certain seconds 
#"$OSASCRIPT" -e 'display dialog  "Downloading Something" buttons {"OK"} default button 1 giving up after 4'

## all policies set to "Ongoing" and use "Custom Event" to run
## this policy/script is set to "Enrollment Complete" and "Once For Computer", except the Chrome prompt for default browser, that's Once per computer per user
## set "Restart Options" to "Restart Immediately" force restart if some policies require it. Only automatic if you have $timeout set up.
## sleep is to wait before running the next custom trigger
## take out $timeout if you don't want it to auto close the jamfHelper window. 
## You can use this one line to install Rosetta if you like
# [ $( /usr/bin/arch ) = "arm64" ] && /usr/sbin/softwareupdate --install-rosetta --agree-to-license

########## Policies Start ##########

## Download Rosetta2
"$OSASCRIPT" -e 'display notification  "Downloading Rosetta2"'
"$OSASCRIPT" -e 'display dialog  "Downloading Rosetta2" buttons {"OK"} default button 1 giving up after 4'
"$JAMF" policy -event rosetta

## Trust JSS Ceritifcate if you have SSO set up for Jamf
"$JAMF" policy -event trustJSS

## Download installomator
"$JAMF" policy -event installomator
sleep 3 

## Jamf Protect Detect and Install If Missing (Just In Case) 
"$JAMF" policy -event jamfprotect

## Bootstrap Token (Just In Case) 
"$JAMF" policy -event bootstrap

## Download Google Chrome
"$JAMF" policy -event installchrome

## Download Printer Driver
"$JAMF" policy -event printerdriver

## Prompt Default Browser Message
"$JAMF" policy -event chromedefault
sleep 3

## Setting Up Dock With Web Clip
"$JAMF" policy -event dock

## Download Microsoft Word
"$JAMF" policy -event installword

## Download Microsoft PowerPoint
"$JAMF" policy -event installpowerpoint

## Add Username@Domain.org
"$JAMF" policy -event officelogin

sleep 7
## Double check all policies in case they are stuck or didn't run
"$JAMF" policy


########## Name & Version ##########
macOS=$(sw_vers -productVersion)
chromeAppname="Google Chrome: "
chromeVersion=$(mdls /Applications/Google\ Chrome.app -name kMDItemVersion | awk -F'"' '{print $2}')
wordAppname="Word: "
wordVersion=$(mdls /Applications/Microsoft\ Word.app -name kMDItemVersion | awk -F'"' '{print $2}')
pptAppname="PowerPoint: "
pptVersion=$(mdls /Applications/Microsoft\ PowerPoint.app -name kMDItemVersion | awk -F'"' '{print $2}')


########## jamfHelper ##########
## You can choose other icons but I usually use these 2

## Self Service Icon 
#/Applications/Self Service.app/Contents/Resources/AppIcon.icns
## Finder Icon
#/System/Library/CoreServices/Finder.app/Contents/Resources/Finder.icns

jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
windowType="hud"
icon="/Applications/Self Service.app/Contents/Resources/AppIcon.icns"
title="Download Completed"
timeout="10"
description="Complete At: $time 
macOS $macOS
$chromeAppname $chromeVersion
$wordAppname $wordVersion
$pptAppname $pptVersion"

button1="OK"


userChoice=$("$jamfHelper" \
-windowType "$windowType" \
-lockHUD \
-title "$title" \
-icon "$icon" \
-description "$description" \
-button1 "$button1" \
-defaultButton 1 \
-timeout "$timeout" \
-iconSize 120)

## Display App and Version jamfHelper message, recon, and sync Jamf Protect insights (if you have it)
## It auto close and click OK after 10 seconds base on the $timeout
if [ "$userChoice" == "0" ]; then
    echo $userChoice; $JAMF recon; protectctl checkin --insights;
   
  
# If user selects button2
#elif [ "$userChoice" == "2" ]; then
#   echo "User selected Cancel"
fi

exit 0
