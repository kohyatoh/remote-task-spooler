#!/bin/bash

DATE=`date '+%Y%m%d-%H%M%S'`

PORT=22
DIRNAME=$DATE
TRANSPORT_DIR=0
VERBOSE=0

while getopts d:p:tv OPT
do
    case $OPT in
        d)  DIRNAME=$OPTARG
            TRANSPORT_DIR=1
            ;;
        p)  PORT=$OPTARG
            ;;
        t)  TRANSPORT_DIR=1
            ;;
        v)  VERBOSE=1
            ;;
    esac
done

shift $((OPTIND-1))
ADDR=$1
shift


if [ "$ADDR" == "" ]; then
  echo "usage: rtsp.sh [-p PORT] [-d DIR] [-v] ADDRESS COMMAND [ARGS]"
  exit 1
fi

if [ "$VERBOSE" == "1" ]; then
  echo "ADDR=$ADDR"
  echo "PORT=$PORT"
  echo "DIRNAME=$DIRNAME"
  echo "tsp $*"
fi

if [ "$TRANSPORT_DIR" == "1" ]; then
  DIR=rtsp/$DIRNAME
  if ssh -p $PORT $ADDR "test -e $DIR"; then
    echo "ERROR: $DIR already exists."
    exit 1
  fi
  rsync -auz -e "ssh -p $PORT" . $ADDR:$DIR
  ssh -p $PORT $ADDR "cd $DIR; tsp $*"
else
  ssh -p $PORT $ADDR "tsp $*"
fi
