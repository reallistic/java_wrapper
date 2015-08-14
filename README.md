Java Wrapper for Cygwin
============

**This is a simple wrapper that will add a `java` executable in `/usr/bin` in order to interecept java commands and convert any *NIX paths to windows paths for cygwin.**

**This is NOT a helper to install java. You must already have java installed.**

## Installation:
```
user@cygwin-pc ~/workspace
$ git clone https://github.com/reallistic/java_wrapper.git
user@cygwin-pc ~/workspace
$ cd java_wrapper
user@cygwin-pc ~/workspace/java_wrapper
$ ./install.sh -h
Usage: ./install.sh [OPTION]

 Examples:
 ./install.sh --add-cmd 0 --java-cmd /cygdrive/d/jdk/bin/java
 ./install.sh --java-cmd /cygdrive/d/jdk/bin/java
 ./install.sh --dest /usr/bin/run-java

 Arguments:

 --add-cmd      # { 1 (default) or 0 } Adds the JAVA_CMD variable to $HOME/.javawrapperrc
 --java-cmd     # Expicitly set the java command path.
 --dest         # Explicitly set the symlink dest. Default: /usr/bin/java
 -h, --help     # Print this help message and exit.

user@cygwin-pc ~/workspace/java_wrapper
$ ./install.sh
Symlinking wrapper to bin
Link made from: /cygdrive/d/workspace/java_wrapper/java_wrapper.sh ==> /usr/bin/java
Making sure it's executable
Adding JAVA_CMD to config
Installed successfully
```


This script was adapted from:
http://saltnlight5.blogspot.com/2012/08/a-better-java-shell-script-wrapper.html
