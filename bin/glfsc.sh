#!/bin/bash

## FILE: glfsc.sh
#
# Primary user interface for GNU+Linux from Source Code
#
# This program will lay the foundations and install the base GLFSC system.
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

## INCLUDE FILES
#

# Read default variable settings that control the behavior of GLFSC at runtime.
# All other variable settings will override those defined in this file.
# try localpath
GLFSC_DIR=${PWD}
source $GLFSC_DIR/etc/glfsc.d/defaults.conf
if [[ $? -eq 0 ]]; then
        echo "debug: ${0##*\/}: loaded defaults.conf"
fi

# Read all user customized setting that control the behavior of GLFSC at
# runtime. These settings override thosee defined in the file defaults.conf.
# Settings specified on the command line will override those defined in this
# file.
source $GLFSC_DIR/etc/glfsc.d/glfsc.conf

# Import package versions as a one dimensional array of values where
# each value is a package name and version number separated by a semi-colon.
# For each version number, patch numbers are separated by a hyphen "-" in
# the cases of packages that employ single file patches with consequative
# numbering like the Bourne Again Shell.
source $GLFSC_DIR/etc/glfsc.d/versions

#
## END INCLUDE FILES

## MAIN: glfsc.sh
#

# declarations;

ARGC=0	        # number of command arguments
ARGV=()	        # array of command arguments
CURRENT=""      # single member focus
INDEX=0	        # counter to traverse array index
P="${0##*\/}"   # capture progam invocation (without path)

ARGC="${#@}"    # capture number of command arguments
ARGV=("${@}")   # capture command arguments as an array

INDEX=0
CURRENT=${ARGV[$INDEX]}
while test "${CURRENT}"; do
        case "${CURRENT}" in

                -a | --biarch)
                        GLFSC_BIARCH=TRUE
                        ;;

                -b | --bindir)
                        (( INDEX+=1 ))
                        GLFSC_BIN="${ARGV[$INDEX]})"
                        ;;

                -c | --sysconfdir)
                        (( INDEX+=1 ))
                        GLFSC_ETC="${ARGV[$INDEX]})"
                        ;;

                -g | --group)
                        (( INDEX+=1 ))
                        GLFSC_GROUP="${ARGV[$INDEX]})"
                        ;;

                -l | --libdir)
                        (( INDEX+=1 ))
                        GLFSC_LIB="${ARGV[$INDEX]})"
                        ;;

                -R | --scriptdir)
                        (( INDEX+=1 ))
                        GLFSC_SCRIPTS="${ARGV[$INDEX]})"
                        ;;

                -s | --sourcedir)
                        (( INDEX+=1 ))
                        GLFSC_SRC="${ARGV[$INDEX]})"
                        ;;

                -r | --root)
                        (( INDEX+=1 ))
                        GLFSC_SYSROOT="${ARGV[$INDEX]}"
                        ;;

                -t | --target)
                        (( INDEX+=1 ))
                        GLFSC_TARGET="${ARGV[$INDEX]}"
                        ;;

                -T | --toolsdir)
                        (( INDEX+=1 ))
                        GLFSC_TOOLS="${ARGV[$INDEX]}"
                        ;;

                -u | --user)
                        (( INDEX+=1 ))
                        GLFSC_USER="${ARGV[$INDEX]}"
                        ;;

                -C | --config-site)
                        (( INDEX+=1 ))
                        CONFIG_SITE="${ARGV[$INDEX]}"
                        ;;

                -S | --config-shell)
                        (( INDEX+=1 ))
                        CONFIG_SHELL="${ARGV[$INDEX]}"
                        ;;

                -L | --locale)
                        (( INDEX+=1 ))
                        LC_ALL="${ARGV[$INDEX]}"
                        ;;

                -F | --ld-flags)
                        (( INDEX+=1 ))
                        LDFLAGS="${ARGV[$INDEX]}"
                        ;;

                -z | --timezone)
                        (( INDEX+=1 ))
                        TZ="${ARGV[$INDEX]}"
                        ;;

        esac
        (( INDEX+=1 ))
	CURRENT="${ARGV[$INDEX]}"
done

#TODO: write code to proof test variable assignments
GLFSC_VARS=( '$GLFSC_BIARCH'
'$GLFSC_BIN'
'$GLFSC_ETC'
'$GLFSC_GROUP'
'$GLFSC_LIB'
'$GLFSC_SCRIPTS'
'$GLFSC_SRC'
'$GLFSC_SYSROOT'
'$GLFSC_TARGET'
'$GLFSC_TOOLS'
'$GLFSC_USER'
'$CONFIG_SITE'
'$CONFIG_SHELL'
'$LC_ALL'
'$LDFLAGS'
'$TZ' )

INDEX=0
CURRENT="${GLFSC_VARS[$INDEX]}"
while test "${CURRENT}"; do
       echo "${CURRENT} =" $( eval echo "${CURRENT}" )
	(( INDEX+=1 ))
	CURRENT="${GLFSC_VARS[$INDEX]}"
done

echo "debug: $P: early exit"
exit 0
#Variable assignment works correctly - bmb 1280110356

# make glfsc build group if it doesn't already exist
egrep -e "${GLFSC_GROUP}" /etc/group &>/dev/null
if [[ $? -eq 0 ]]; then
        echo "debug: $P: group ${GLFSC_GROUP} exists"
else
        GID_MIN=1000 GID_MAX=9999 groupadd ${GLFSC_GROUP}
	if [[ $? -eq 0 ]]; then
                echo "debug: $P: made user group ${GLFSC_GROUP}"
        else
                echo "error: $P: failed to make group ${GLFSC_GROUP}"
		exit 1
        fi
fi

# make glfsc build user if it doesn't already exist
id "^${GLFSC_USER}" &>/dev/null
if [[ $? -eq 0 ]]; then
        echo "debug: $P: user ${GLFSC_USER} exists"
else
        useradd -s /bin/bash -g ${GLFSC_GROUP} -m -k /dev/null ${GLFSC_USER}
        if [[ $? -eq 0 ]]; then
                echo "debug: $P: made user ${GLFSC_USER}"
        else
                echo "error: $P: failed to make user ${GLFSC_USER}"
		exit 1
        fi
fi

# make sysroot if it does not already exist
if test -d ${GLFSC_SYSROOT}; then
        echo "debug: $P: directory ${GLFSC_SYSROOT} exists"
else
        install -dv -o ${GLFSC_USER} -g ${GLFSC_GROUP} -m 0755 ${GLFSC_SYSROOT}
        if [[ $? -eq 0 ]]; then
                echo "debug: $P: made directory ${GLFSC_SYSROOT}"
        else
                echo "error: $P: failed to make directory ${GLFSC_SYSROOT}"
		exit 1
	fi
fi

# make necessary directories under GLFSC_SYSROOT
if test -d ${GLFSC_SYSROOT}${GLFSC_TOOLS}; then
        echo "debug: $P: directory ${GLFSC_SYSROOT}${GLFSC_TOOLS} exists"
else
        install -dv -o ${GLFSC_USER} -g ${GLFSC_GROUP} -m 0755 \
                                                 ${GLFSC_SYSROOT}${GLFSC_TOOLS}
        if [[ $? -eq 0 ]]; then
                echo "debug: $P: made directory ${GLFSC_SYSROOT}${GLFSC_TOOLS}"
        else
                echo -n "error: $P: failed to make directory "
                echo "${GLFSC_SYSROOT}${GLFSC_TOOLS}"
                exit 1
        fi
fi
if test -d ${GLFSC_SYSROOT}${GLFSC_SCRIPTS}; then
        echo "debug: $P: directory ${GLFSC_SYSROOT}${GLFSC_SCRIPTS} exists"
else
        install -dv -o ${GLFSC_USER} -g ${GLFSC_GROUP} -m 0755 \
                                               ${GLFSC_SYSROOT}${GLFSC_SCRIPTS}
        if [[ $? -eq 0 ]]; then
                echo -n "debug: $P: made directory "
                echo "${GLFSC_SYSROOT}${GLFSC_SCRIPTS}"
	else
                echo -n "error: $P: failed to make directory "
		echo "${GLFSC_SYSROOT}${GLFSC_SCRIPTS}"
		exit 1
	fi
fi
if test -d ${GLFSC_SYSROOT}${GLFSC_BIN}; then
        echo "debug: $P: directory ${GLFSC_SYSROOT}${GLFSC_BIN} exists"
else
        install -dv -o ${GLFSC_USER} -g ${GLFSC_GROUP} -m 0755 \
                                               ${GLFSC_SYSROOT}${GLFSC_BIN}
        if [[ $? -eq 0 ]]; then
                echo -n "debug: $P: made directory "
                echo "${GLFSC_SYSROOT}${GLFSC_BIN}"
	else
                echo -n "error: $P: failed to make directory "
		echo "${GLFSC_SYSROOT}${GLFSC_BIN}"
		exit 1
	fi
fi
if test -d ${GLFSC_SYSROOT}${GLFSC_ETC}; then
        echo "debug: $P: directory ${GLFSC_SYSROOT}${GLFSC_ETC} exists"
else
        install -dv -o ${GLFSC_USER} -g ${GLFSC_GROUP} -m 0755 \
                                               ${GLFSC_SYSROOT}${GLFSC_ETC}
        if [[ $? -eq 0 ]]; then
                echo -n "debug: $P: made directory "
                echo "${GLFSC_SYSROOT}${GLFSC_ETC}"
	else
                echo -n "error: $P: failed to make directory "
		echo "${GLFSC_SYSROOT}${GLFSC_ETC}"
		exit 1
	fi
fi
if test -d ${GLFSC_SYSROOT}${GLFSC_LIB}; then
        echo "debug: $P: directory ${GLFSC_SYSROOT}${GLFSC_LIB} exists"
else
        install -dv -o ${GLFSC_USER} -g ${GLFSC_GROUP} -m 0755 \
                                               ${GLFSC_SYSROOT}${GLFSC_LIB}
        if [[ $? -eq 0 ]]; then
                echo -n "debug: $P: made directory "
                echo "${GLFSC_SYSROOT}${GLFSC_LIB}"
	else
                echo -n "error: $P: failed to make directory "
		echo "${GLFSC_SYSROOT}${GLFSC_LIB}"
		exit 1
	fi
fi
if test -d ${GLFSC_SYSROOT}${GLFSC_SRC}; then
        echo "debug: $P: directory ${GLFSC_SYSROOT}${GLFSC_SRC} exists"
else
        install -dv -o ${GLFSC_USER} -g ${GLFSC_GROUP} -m 0755 \
                                               ${GLFSC_SYSROOT}${GLFSC_SRC}
        if [[ $? -eq 0 ]]; then
                echo -n "debug: $P: made directory "
                echo "${GLFSC_SYSROOT}${GLFSC_SRC}"
	else
                echo -n "error: $P: failed to make directory "
		echo "${GLFSC_SYSROOT}${GLFSC_SRC}"
		exit 1
	fi
fi

# link temptools directory to host /tools
if test -h ${GLFSC_TOOLS}; then
        echo "debug: $P: symlink to temporary toolchain path exists"
else
        link -sv ${GLFSC_SYSROOT}${GLFSC_TOOLS} ${GLFSC_TOOLS}
        if [[ $? -eq 0 ]]; then
                echo -n "debug: $P: made symlink to temporary toolchain path "
                echo "${GLFSC_SYSROOT}${GLFSC_TOOLS}"
        else
                echo -n "error: $P: failed to make symlink to "
		echo "temporary toolchain path ${GLFSC_SYSROOT}${GLFSC_TOOLS}"
		exit 1
        fi
fi

# copy files to GLFSC_SYSROOT

# build temporary toolchain

# chroot to sysroot

# build basesystem

#
## END MAIN: glfsc.sh

#
## END FILE: glfsc.sh
