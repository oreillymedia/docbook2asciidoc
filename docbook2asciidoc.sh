#!/bin/sh

REQUIRED_BASH_VERSION=3.0.0

if [[ $BASH_VERSION < $REQUIRED_BASH_VERSION ]]; then
  echo "You must use Bash version 3 or newer to run this script"
  exit
fi

DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

convert() 
{
  CMD="find $SCAN_DIR -name \*.$EXT"
  if [ $RECURSE == "0" ]; then
    CMD="$CMD -maxdepth 1"
  fi
  xmls=`eval $CMD`

  mkdir -p $OUT_DIR

  for xml in $xmls
  do
    output_filename=${xml/.$EXT/.$OEXT}
    echo "Processing $xml -> $output_filename"    
    CMD="java -jar $DIR/saxon9he.jar -s $xml -o $output_filename $DIR/d2a.xsl"
    $CMD
  done
}

usage()
{
cat << EOF
usage: $0 options

This script allows primitive batching of docbook to asciidoc conversion

OPTIONS:
   -s      Source directory to scan for files, by default the working directory
   -x      Extension of files to convert, by default 'xml'
   -o      Output extension, by default 'asciidoc'
   -r      Enable recusive scanning, by default the scan is not recursive
   -h      Shows this message
EOF
}

SCAN_DIR=`pwd`
RECURSE="0"
EXT="xml"
OEXT="asciidoc"
OUT_DIR="output"

while getopts “hrx:o:s:” OPTION

do
     case $OPTION in
         s)
             SCAN_DIR=$OPTARG
             ;;
         h)
             usage
             exit
             ;;
         r)
             RECURSE="1"
             ;;
         x)
             EXT=$OPTARG
             ;;
         o)
             OEXT=$OPTARG
             ;;
         [?])
             usage
             exit
             ;;
     esac
done

convert
