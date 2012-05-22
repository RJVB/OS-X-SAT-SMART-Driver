#!/bin/sh

# runDoxygen.sh
# Created by René J.V. Bertin on 20110302.


#  Build the doxygen documentation for the project and load the docset into Xcode.

#  Use the following to adjust the value of the $DOXYGEN_PATH User-Defined Setting:
#    Binary install location: /Applications/Productivity/Doxygen.app/Contents/Resources/doxygen
#    Source build install location: /usr/local/bin/doxygen

#  If the config file doesn't exist, run 'doxygen -g $SOURCE_ROOT/doxygen.config' to 
#   a get default file.

if [ "${DOXYGEN_PATH}" = "" ] ;then
	DOXYGEN_PATH="/usr/local/bin/doxygen"
fi

# NB: the XCode project lives in its own subdirectory of the project's true root directory
ROOT="${SOURCE_ROOT}/.."

if ! [ -f $ROOT/Resources/doxygen.config ] 
then 
  echo doxygen config file does not exist
  $DOXYGEN_PATH -g $ROOT/Resources/doxygen.config
fi

#  Append the proper input/output directories and docset info to the config file.
#  This works even though values are assigned higher up in the file. Easier than sed.

cp $ROOT/Resources/doxygen.config $TEMP_DIR/doxygen.config

echo "INPUT = $ROOT" >> $TEMP_DIR/doxygen.config

OUTPUT_DIRECTORY="$ROOT/SATSMARTDriver.docset"
echo "OUTPUT_DIRECTORY = $OUTPUT_DIRECTORY" >> $TEMP_DIR/doxygen.config
# set in doxygen.config
# echo "DOCSET_BUNDLE_ID       = org.dungeon.SATSMARTDriver" >> $TEMP_DIR/doxygen.config

echo "GENERATE_DOCSET        = YES" >> $TEMP_DIR/doxygen.config

# add the standard compiler tags to the defined tokens:
echo "PREDEFINED += __APPLE_CC__ __GNUC__ __MACH__" >> $TEMP_DIR/doxygen.config

#  Run doxygen on the updated config file.
#  Note: doxygen creates a Makefile that does most of the heavy lifting.

$DOXYGEN_PATH $TEMP_DIR/doxygen.config

#  make will invoke docsetutil. Take a look at the Makefile to see how this is done.

make -C $OUTPUT_DIRECTORY/html install

#  Construct a temporary applescript file to tell Xcode to load a docset.

rm -f $TEMP_DIR/loadDocSet.scpt

echo "tell application \"Xcode\"" >> $TEMP_DIR/loadDocSet.scpt
echo "load documentation set with path \"/Users/$USER/Library/Developer/Shared/Documentation/DocSets/\"" 
     >> $TEMP_DIR/loadDocSet.scpt
echo "end tell" >> $TEMP_DIR/loadDocSet.scpt

#  Run the load-docset applescript command.

osascript $TEMP_DIR/loadDocSet.scpt

exit 0