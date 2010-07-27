#!/bin/bash

## FILE: mpkg.sh
#
# create a redistributable archive package
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

## INCLUDED FILES
#

test "${GLFSC_BASEDIR__}" || GLFSC_BASEDIR__=/home/k2t0f12d/dev/glfsc
test "${GLFSC_SYSCONFDIR__}" || GLFSC_SYSCONFDIR__=/etc/glfsc.d
source ${GLFSC_BASEDIR__}${GLFSC_SYSCONFDIR__}/glfsc.conf
source ${GLFSC_BASEDIR__}${GLFSC_LIBDIR__}/functions.inc

#
## END INCLUDED FILES

## MAIN: mpkg.sh
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

read -a input

# index=0
# current=${input[$index]}
# while test "${current}"; do
# 	echo "${current} - ${index}"
# 	(( index+=1 ))
# 	current=${input[$index]}
# done
#
# echo "${input[@]}"
#
## TESTED: read instruction works

# TODO: implement parser for command line arguments
argc="${#@}"
argv=( "${@}" )

index=0
current="${argv[$index]}"
while test "${current}"; do
	case "${current}" in

		-b)	((index+=1))
			current="${argv[$index]}"
			basedir="${current}"
			;;

		-d)	((index+=1))
			current="${argv[$index]}"
			scriptdir="${current}"
			;;

		*)	printf "${0##*\/}: unknown argument ${current}\n"
			# TODO: implement show-help
			exit 2
			;;

	esac
	(( index+=1 ))
	current="${argv[$index]}"
done

# clear variable for safe reuse
current=()

# TODO: List of modules required to perform build(s), as follows;
#
#	check_files.sh		verify existance of required files
#	check_digest.sh		verify buildscript consistency
#	check_deps.sh		read buildscript, verify dependencies
#	build_package.sh	completely build a package, including metadata

# TODO: mpkg.sh script
#
# (no use verifying dependencies files before checking the main package
#  since if it cannot be build due to missing files no dependencies are
#  required)
#
# **input contains packages entered by the user for explicit installation
# 1> to create build_order, select one package name from input, and;
#	a) verify existance of required files**	<----------------------.
#  .----------> ;verify file integrity (replacing item b))	       |
#  |		;download missing files from remote URL		       |
#  |		;else add package name to rejects array		       |
#  '--< b) perform local message digest of buildscript and compare     |
#	   the results with the stored hashsum** <---------------------|
#		;else add package name to rejects array		       |
#	c) read buildscript, load depends array and check each <-------|
#	   package name as per a) b) and c)** >>>----------------------'
#		;recursion until all dependency relationships have
#		 been examined
#		;arrange dependency packages names with respect to
#		 estabished build_order and pass back to caller(s)
#		;add names of failed dependency packages to the rejects array
#		;add as explicit package name to the rejects array
#		 if any of its dependencies fail downstream
# **build_order established
# 2> to build all packages, select each package name individually, and;
#	a) read package buildscript
#	b) copy required files, locally or from remote, to build site
#	c) move cwd to build site and execute buildscript build function
#		;ensure $DESTDIR and friends point to chroot directory
#		 for package management
#	d) copy or create build metadata files for package management
#	e) tarball all files for deployment on target systems
#		;also optionally install immediately on local machine

# TODO: mpkg.sh script
#
# (no use verifying dependencies files before checking the main package
#  since if it cannot be build due to missing files no dependencies are
#  required)
#
# **input contains packages entered by the user for explicit installation
# 1> to create build_order, select one package name from input, and;
index=0
current=${input[${index}]}
while test "${current}"; do
	debug "$P: \$current = ${current}\n"
#	a) verify existance of required files**	<----------------------.
	echo "${current}" | \
		${basedir}/bin/check_files.sh -b ${basedir} \
					      -d ${scriptdir}
	this_buildscript=${basedir}${scriptdir}/${current}/buildscript
	this_hashsum=${basedir}${scriptdir}/${current}/hashsum
	if test -f "${this_buildscript}" && \
	   test -r "${this_buildscript}" && ; then
		debug "$P: ${current}: buildscript\n"		
	fi
	(( index+=1 ))
	current=${input[${index}]}
done

# clear variable for safe reuse
current=()



#  .----------> ;verify file integrity (replacing item b))	       |
#  |		;download missing files from remote URL		       |
#  |		;else add package name to rejects array		       |
#  '--< b) perform local message digest of buildscript and compare     |
#	   the results with the stored hashsum** <---------------------|
#		;else add package name to rejects array		       |
#	c) read buildscript, load depends array and check each <-------|
#	   package name as per a) b) and c)** >>>----------------------'
#		;recursion until all dependency relationships have
#		 been examined
#		;arrange dependency packages names with respect to
#		 estabished build_order and pass back to caller(s)
#		;add names of failed dependency packages to the rejects array
#		;add as explicit package name to the rejects array
#		 if any of its dependencies fail downstream
# **build_order established
# 2> to build all packages, select each package name individually, and;
#	a) read package buildscript
#	b) copy required files, locally or from remote, to build site
#	c) move cwd to build site and execute buildscript build function
#		;ensure $DESTDIR and friends point to chroot directory
#		 for package management
#	d) copy or create build metadata files for package management
#	e) tarball all files for deployment on target systems
#		;also optionally install immediately on local machine



exit 0

#
## END MAIN: mpkg.sh

#
## END FILE: mpkg.sh