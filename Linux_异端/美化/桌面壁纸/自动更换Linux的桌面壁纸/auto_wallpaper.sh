#!/bin/bash

# Intro: How to use this script
if [ $# -ne 1 ]
then
  echo "Usage: $0 <dir_path> <wait_second>"
  exit 1
fi

# About: wait_second
wait_second=$2
echo "You want wait: $wait_second second"

# About: Directory Path
dir_path_1=$1
echo "Directory is: $dir_path_1"
echo "--- --- ---"

## How many file in the Directory Path
dir_path_1_file_count=`ls $dir_path_1 | wc -l`
echo "File Count: $dir_path_1_file_count"

## Put all file in a line
dir_path_1_file_list=`ls $dir_path_1`

## set Count
loop_count=1

## Loop: identified each file
for p in $dir_path_1_file_list
do
  echo "+++++++++++++++++++"

  loop_count=$(($loop_count+1))
  echo "Current is: $loop_count"

  ### File direct path is:
  file_direct_path=$dir_path_1$p

  echo "The File is: $file_direct_path"

  ### Now Change Wallpaper
  gconftool-2 -s /desktop/gnome/background/picture_filename -t string "$file_direct_path" -s /desktop/gnome/background/picture_options wallpaper

  ### wait
  #sleep $((60*$wait_second))
  sleep 5

done
