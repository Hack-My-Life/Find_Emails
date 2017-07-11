#!/bin/bash

# TODO: Set to install based on platform (OSX, Debian, RH)
if ! [ -x "$(which gem)" ]; then
	echo "Gem Not installed"
	# TODO: Install if not found
	exit 1
fi

# GEM already checked. Installing
result=$(gem install nokogiri mechanize anemone)

if [ $? -ne 0 ] ;then
	# TODO: Expand
	echo "Error installing gems."
	exit 1
fi
