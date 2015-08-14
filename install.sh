#!/bin/bash

# This script simply finds your java executable, sets it in your profile,
# and lastly symlinks this script to /usr/bin/java (unless thats where your java already is).
USAGE="
Usage: ./install.sh [OPTION]\n\n

Examples:\n
  ./install.sh --add-cmd --java-cmd /cygdrive/d/jdk/bin/java\n
  ./install.sh --java-cmd /cygdrive/d/jdk/bin/java\n
  ./install.sh --dest /usr/bin/run-java\n\n

Arguments:\n\n

  --add-cmd\t# { 1 (default) or 0 } Adds the JAVA_CMD variable to \$HOME/.javawrapperrc\n
  --java-cmd\t# Expicitly set the java command path.\n
  --dest\t\t# Explicitly set the symlink dest. Default: /usr/bin/java\n
  -h, --help\t# Print this help message and exit.\n
"

ADD_CMD=1
parse_args ()
{
    for ARG in "$@"; do
        case  $ARG in
            '--add-cmd' | '--java-cmd' | '--dest')
                LAST_ARG=$ARG
                ;;
            '-h' | '--help')
                echo -e $USAGE
                exit 0
                ;;
            *)
                case $LAST_ARG in
                    '--java-cmd')
                        JAVA_CMD=$ARG
                        ;;
                    '--dest')
                        WRAPPER_DEST=$ARG
                        ;;
                    '--add-cmd')
                        ADD_CMD=$ARG
                        ;;
                    *)
                        echo "Received unrecognized argument: $ARG"
                        echo -e $USAGE
                        exit 1
                        ;;
                esac
                LAST_ARG=
        esac
    done
}

parse_args $@

RC_FILE="$HOME/.javawrapperrc"
# Import rc file.
if [ -e "$RC_FILE" ]; then
    source "$RC_FILE"
fi


CURRENT_JAVA_CMD="$JAVA_CMD"
JAVA_CMD=${JAVA_CMD:=$(which java)}
WRAPPER_DEST=${WRAPPER_DEST:=/usr/bin/java}
WRAPPER_DEST_DIR=$(dirname "$WRAPPER_DEST")

SCRIPT_DIR=$(readlink -f $(dirname $0))
WRAPPER_LOC="$SCRIPT_DIR/java_wrapper.sh"

# Make sure the wrapper is executable.
chmod +x "$WRAPPER_LOC"

if [ -n "$CURRENT_JAVA_CMD" ]; then
    CURRENT_JAVA_CMD=$(readlink -f "$CURRENT_JAVA_CMD")
fi

if [ -n "$JAVA_CMD" ]; then
    JAVA_CMD=$(readlink -f "$JAVA_CMD")
fi

echo -e "
ADD_CMD:\t\t$ADD_CMD
CURRENT_JAVA_CMD:\t$CURRENT_JAVA_CMD
JAVA_CMD:\t\t$JAVA_CMD
WRAPPER_DEST:\t\t$WRAPPER_DEST
WRAPPER_DEST_DIR:\t$WRAPPER_DEST_DIR
WRAPPER_LOC:\t\t$WRAPPER_LOC
"

if [ ! -x "$JAVA_CMD" ] && [ ! -x "$CURRENT_JAVA_CMD" ]; then
    echo "Java not installed. This is simply a wrapper it doesn't actually provide java!" 1>&2
    exit 1
elif [ "$JAVA_CMD" == "$WRAPPER_DEST" ]; then
    echo "Java is installed in the same place the wrapper should go." 1>&2
    echo "If this is a manually created symlink then remove it. Otherwise you likely don't need this" 1>&2
    exit 1
fi

echo "Symlinking wrapper to bin"
if [ -d "$WRAPPER_DEST_DIR" ]; then
    output=$(ln -s "$WRAPPER_LOC" "$WRAPPER_DEST" 2>&1)
else
    echo "$WRAPPER_DEST_DIR is not a directory. Cannot write to $WRAPPER_DEST" 1>&2
    exit 1
fi

if [ $? -ne 0 ]; then
    echo -e "Error symlinking java_wrapper to bin.\n$output" 1>&2
    exit 1
fi

echo "Link made from: $WRAPPER_LOC ==> $WRAPPER_DEST"
echo "Making sure it's executable"
chmod +x "$WRAPPER_DEST"

if [ $ADD_CMD -eq 1 ]; then
    if [ -n "$CURRENT_JAVA_CMD" ]; then
        echo "JAVA_CMD already set to: $CURRENT_JAVA_CMD"
        exit 0
    fi

    echo "Adding JAVA_CMD to config"

    if [ -w "$RC_FILE" ]; then
        output=$(echo "JAVA_CMD=\"$JAVA_CMD"\" > "$RC_FILE" 2>&1)
    else
        output=$(echo -e "#!/bin/bash\nJAVA_CMD=\"$JAVA_CMD"\" > "$RC_FILE" 2>&1)
        chmod +x "$RC_FILE"
    fi

    if [ $? -ne 0 ]; then
        echo -e "Error adding JAVA_CMD variable to config\n$output" 1>&2
    fi

fi

echo "Installed successfully"
