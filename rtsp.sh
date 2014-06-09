#!/bin/bash

DATE=`date '+%Y%m%d-%H%M%S'`

ADDR=
PORT=22
DIRNAME=$DATE
CMD=
ARGS=
VERBOSE=

# parse arguments
while [ "$1" != "" ]; do
  if [ "$CMD" == "" ]; then
    if [ "$1" == "-p" ]; then
      PORT=$2
      shift
    elif [ "$1" == "-d" ]; then
      DIRNAME=$2
      shift
    elif [ "$1" == "-v" ]; then
      VERBOSE=true
    else
      if [ "$ADDR" == "" ]; then
        ADDR=$1
      elif [ "$CMD" == "" ]; then
        CMD=$1
      fi
    fi
  else
    if [ "$ARGS" == "" ]; then
      ARGS="\"$1\""
    else
      ARGS="$ARGS \"$1\""
    fi
  fi
  shift
done

if [ "$CMD" == "" ]; then
  echo "usage: rtsp.sh [-p PORT] [-d DIR] [-v] ADDRESS COMMAND [ARGS]"
  exit 1
fi

if [ "$VERBOSE" != "" ]; then
  echo "ADDR=$ADDR"
  echo "PORT=$PORT"
  echo "DIRNAME=$DIRNAME"
  echo "CMD=$CMD"
  echo "ARGS=$ARGS"
  echo "$CMD $ARGS"
  QUIET_OPT=
else
  QUIET_OPT=-q
fi

TMP_ZIP=/tmp/rtsp-${DATE}.zip
DIR=rtsp/$DIRNAME

# copy and execute
zip -q $TMP_ZIP -r .
scp -P $PORT $TMP_ZIP $ADDR:$TMP_ZIP 1>/dev/null 2>&1
ssh -p $PORT $ADDR 1>/dev/null 2>&1 <<EOF
mkdir -p $DIR;
cd $DIR;
unzip -q -o $TMP_ZIP;
rm -f $TMP_ZIP;
tsp $CMD $ARGS;
EOF
rm -f $TMP_ZIP
