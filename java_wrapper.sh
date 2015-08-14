#!/bin/bash
#
# Copyright 2012 Zemian Deng
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# A wrapper script that can run java commands in a CYGWIN environment and convert
# *NIX paths to windows paths.
#
# The "Default parameters" section bellow can be overridden in a profile startup script.
# The all paths should be in cygwin/unix path format
# and this script will auto convert them into Windows path where is needed.
#
# Usage:
#   java_wrapper [java_opts] <java_main_class>
#
# Example:
#   java_wrapper -jar /path/to/MyJar.jar
#   java_wrapper example.Hello
#   java_wrapper org.junit.runner.JUnitCore example.HelloTest
#
# Created by: Zemian Deng 03/09/2012
# Re-purposed/Modified by Michael Chase 08/13/2015

# Import rc file.
if [ -e "$HOME/.javawrapperrc" ]; then
    source "$HOME/.javawrapperrc"
fi


# Default parameters
JAVA_HOME=${JAVA_HOME:=}            # This is the home directory of Java development kit.
RUN_JAVA_OPTS=${RUN_JAVA_OPTS:=}    # Java options (-Xmx512m -XX:MaxPermSize=128m etc)
RUN_JAVA_DEBUG=${RUN_JAVA_DEBUG:=} # If not empty, print the full java command line before executing it.
RUN_JAVA_DRY=${RUN_JAVA_DRY:=}      # If not empty, do not exec Java command, but just print
JAVA_CMD=${JAVA_CMD:=}              # Define where the java executable lives. (overrides JAVA_HOME)


if [ -d "$JAVA_HOME" ]; then
	JAVA_HOME_CMD="$JAVA_HOME/bin/java"
fi

if [ -e "$JAVA_CMD" ]; then
    JAVA_HOME_CMD="$JAVA_CMD"
fi

if [ ! -e "$JAVA_HOME_CMD" ]; then
    echo "No java executable found. Aborting!" 1>&2
    exit 1
fi

ARGS="$@"
# Parse the args and convert the paths to windows paths
# if RUN_JAVA_NO_PARSE is empty.
if [ -z "$RUN_JAVA_NO_PARSE" ]; then
	NEW_ARGS[0]=''
	IDX=0

	for ARG in "$@"; do
        # Make sure this is a unix path
        if [[ $ARG == *"/"* ]]; then
            NEW_ARGS[$IDX]=$(cygpath -mp "$ARG")
        else
            NEW_ARGS[$IDX]="$ARG"
        fi
        let IDX=$IDX+1
	done
	ARGS="${NEW_ARGS[@]}"
fi

# Display full Java command.
if [ -n "$RUN_JAVA_DEBUG" ] || [ -n "$RUN_JAVA_DRY" ]; then
	echo "$JAVA_CMD" $RUN_JAVA_OPTS $ARGS
fi

# Run Java Main class
if [ -z "$RUN_JAVA_DRY" ]; then
	"$JAVA_CMD" $RUN_JAVA_OPTS $ARGS
fi
