#!/bin/sh

# get rid of macports - libiconv
echo $PATH
export PATH=`echo $PATH | sed 's/:/\n/g' | grep -v '/opt/local' | xargs | tr ' ' ':'`
echo $PATH

# some folder names
BASE_DIR="$( cd "$( dirname "$0" )" > /dev/null 2>&1 && pwd )"
echo "base directory is ${BASE_DIR}"
SCRIPT_DIR="${BASE_DIR}/build"
echo "script directory is ${SCRIPT_DIR}"
TEST_DIR="${BASE_DIR}/test"
echo "test directory is ${TEST_DIR}"
WORKING_DIR="$( pwd )"
echo "working directory is ${WORKING_DIR}"
TOOL_DIR="$WORKING_DIR/tool"
echo "tool directory is ${TOOL_DIR}"
OUT_DIR="$WORKING_DIR/out"
echo "output directory is ${OUT_DIR}"

# load functions
. $SCRIPT_DIR/functions.sh

echoSection "run tests"
$TEST_DIR/test.sh "$SCRIPT_DIR" "$TEST_DIR" "$WORKING_DIR" "$OUT_DIR" > "$WORKING_DIR/test.log" 2>&1
checkStatus $? "test"
echo "tests executed successfully"
