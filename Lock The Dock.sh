#!/bin/sh

currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )

## true = lock, false = unlock
sudo -u "$currentUser" defaults write com.apple.Dock contents-immutable -bool true

killall Dock
