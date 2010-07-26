#!/bin/bash

## FILE: makepkg.sh
#
# create a redistributable archive package
#
# Copyright (C) 2010 Bryan Michael Baldwin
#

## COPYING:
#
# This file is part of GNU+Linux from Source Code
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
## END COPYING

## MAIN: makepkg.sh
#

# declarations;

argc=0		# number of command arguments
argv=()		# array of command arguments
basedir=""	# root path for glfsc
build_order=()	# package names listed in the order they are to be built
current=""	# package name in current operation
index=0		# counter to traverse array index
input=()	# storage for package names to be built
P="${0##*\/}"	# calling program name
scriptdir=""	# path within basedir for build script storage

read -a input	# read in any length of data, parsing each whitespace
		# delimited word as one array member

# index=0
# current=${input[$index]}
# while test "${current}"; do
# 	echo "loop${index}: ${current} - ${index}"
# 	(( index+=1 ))
# 	current=${input[$index]}
# done
#
# echo "echo*: ${input[@]}"
#
## read instruction works - bmb 190410-1819

## TODO
#
# create algorithm to check dependencies of requested packages to be built and
# put them in the correct order
#
# ---BEGIN_PROTO--- makepkg.sh
# > read unsorted whitespace separated list of package names to be built;
#   store data in shell array => $input
#	> foreach package name
#		> check buildscript path for subdir == current package name
#			< if true; cont next
#			> if false; do repository scan
#				< if success; cont next
#				> if fail; blacklist package and dependencies
#		> check subdir path for buildscript + hashsum file
#			< if true; cont next
#			> if false; do repository scan
#				< if success; cont next
#				> if fail; blacklist package and dependencies
#
# ---END_PROTO--- makepkg.sh
#
# ---BEGIN_PROTO--- check_sources.sh
#
# ---END_PROTO--- check_sources.sh
#
# ---BEGIN_PROTO--- [check remote repository for files]
#
# ---END_PROTO--- [check remote repository for files]
#
## END MAIN: makepkg.sh

#
## END FILE: makepkg.sh