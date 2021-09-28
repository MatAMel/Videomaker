#!/bin/bash

#Saving second last folder in a variable
BACKUPDIR=$( ls -td -- /mnt/motioneye/Camera2-Door/*/ | sed -n 2p)

cd $BACKUPDIR

#Dividing picture files into folders with 10000 files each named "dir_001" "dir_002" ...
i=0
for f in *; 
do 
    d=dir_$(printf %03d $((i/10000+1))); 
    mkdir -p $d; 
    cp "$f" $d; 
    let i++; 
done

#Accessing each folder and creating a video file of all the pictures and outputting it in the parent folder
n=0
for d in */; 
do
    let n++;
    cd $d
    cat *.jpg | ffmpeg -f image2pipe -framerate 30 -pix_fmt yuv420p -i - ../"${n}"_Output.mp4
    cd ..
done

cd $BACKUPDIR

#Creating a variable with the name of the current folder only
CURRENTFOLDER=${PWD##*/}

#Creating a file to use for concatenating videos in format "file "filename.mp4""
for f in ./*.mp4; do echo "file '$f'" >> mylist.txt; done

#Concatenating videos
ffmpeg -f concat -safe 0 -i mylist.txt -c copy /mnt/motioneye/Camera2-Door-Videos/"$CURRENTFOLDER.mp4"


#Deleting everything made in this script
rm mylist.txt
find . -type f -iname \*.mp4 -delete
find . -maxdepth 1 -mindepth 1 -type d -exec rm -rf '{}' \;
