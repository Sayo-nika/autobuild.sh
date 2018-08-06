#!/bin/bash

# Copyright 2018(c) The Sayonika Project Authors
# Licensed under MIT.

echo " ==================================================="
echo "|   Welcome to Sayonika RenPy DDLC Mod Autobuilder  |"
echo "|                                                   |"
echo "|                    V0.0.1b                        |"
echo "|               Licensed under MIT                  |"
echo " ==================================================="
echo ""
echo " GitHub: https://github.com/Sayo-nika/autobuild.sh"
echo " Bug reports : https://github.com/Sayo-nika/autobuild.sh/issues/new"
echo ""

regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'

read -p "Enter your mod's Location: " input

# Really needed Type Checks

while [[ $input =~ $regex || -z $input ]] ; do
  echo "Invalid input. Try again."
  read -p "Enter your mod's Location: " input
done

while [[ ! -d $input ]] ; do
  echo "Directory does not exist. Try a different directory."
  read -p "Enter your mod's Location: " input
done

DIRECTORY="$input"

echo "Building Mod in $DIRECTORY"
echo "If you have this builder script inside your own project folder, make sure you input your folder as ../FOLDERNAME or use '.'."
echo "Thanks, and have a nice day!"

sleep 3;

if [[ -d "$DIRECTORY/build" ]]; then
   echo "Build directory exists. I'm not assuming  the files exist so checking right now."
   if [[ -f "$DIRECTORY/build/mc" && -d "$DIRECTORY/mod" && -d "$DIRECTORY/renpy" ]] ; then
      echo "Looks like this has been built before. Rebuilding game instead."
      cp -vRf $DIRECTORY/* $DIRECTORY/mod$1
      cd $DIRECTORY/build/renpy
      ./renpy.sh "$DIRECTORY/build/mod/" lint$1 && ./renpy.sh launcher distribute "$DIRECTORY/build/mod/"$1
      cd ..
    else
      echo "Looks like it's your first time building this mod. Sit back and watch the fireworks."
      if [[ -f "$DIRECTORY/build/renpy-6.99.12.4-sdk.tar.bz2" ]]; then
          mkdir -p $DIRECTORY/build/mod
          cp -vRf $DIRECTORY/* $DIRECTORY/build/mod$1
          cd $DIRECTORY/build
          tar xf renpy-6.99.12.4-sdk.tar.bz2
          rm renpy-6.99.12.4-sdk.tar.bz2
          mv renpy-6.99.12.4-sdk renpy
          rm -rf renpy-6.99.12.4-sdk
          pull_ddlc_base;
          cd $DIRECTORY/build/renpy 
          ./renpy.sh "$DIRECTORY/build/mod/" lint$1 && ./renpy.sh launcher distribute "$DIRECTORY/build/mod/"$1
          cd ..
       else
          mkdir -p $DIRECTORY/build$1
          cp -vRf $DIRECTORY/* $DIRECTORY/mod$1
          cd $DIRECTORY
          wget https://www.renpy.org/dl/6.99.12.4/renpy-6.99.12.4-sdk.tar.bz2$1
          tar xf renpy-6.99.12.4-sdk.tar.bz2
          rm renpy-6.99.12.4-sdk.tar.bz2
          mv renpy-6.99.12.4-sdk renpy
          rm -rf renpy-6.99.12.4-sdk
          pull_ddlc_base;
          cd $DIRECTORY/build/renpy
          ./renpy.sh "$DIRECTORY/build/mod/" lint$1 && ./renpy.sh launcher distribute "$DIRECTORY/build/mod/"$1
          cd ..
       fi
    fi
fi

case $(exit $?) in 
  0) echo "Build Successfully made. Find it at $DIRECTORY/build/ModXY-dists or similar. Happy modding!" && exit 0;
   ;;
  1) echo "Uh oh, we can't build your mod in $DIRECTORY. If this is a mistake, file a issue. Thank you." && exit 1;
   ;;
  *) echo "We had a error we don't know. Exiting." && exit 1;
   ;;
esac

# This pulls from the Sayonika-maintained S3 Storage for the DDLC base content.
# It only contains the RPAs required to build a mod.

pull_ddlc_base() {
    mc_endpoint="https://s3-api.us-geo.objectstorage.softlayer.net"
    mc_hmac_key="aa1d6f56b97443c185d7282c22adc4a7"
    mc_hmac_secret="29fc312082d26720ceeec6e89630f6d2fc382a96c7a72b1c"
    mc_alias="sayonika"
    mc_bucket="filepub"
    mc_filename="ddlc_pkg.zip"
    
    echo "Checking if Minio S3 is present to pull DDLC resources."
    
    if ! [-z "$(command -v mc)"]; then
      echo "Minio Client exists or Midnight Commander is present."
      echo "Make sure Midnight Commander isn't installed since it causes issues with this script."
      mc config host add $mc_alias $mc_endpoint $mc_hmac_key $mc_hmac_secret && \
      # try if it works
      mc ls $mc_alias;
    else 
      echo "Minio Client not present. Installing Minio S3 Client"
      wget "https://dl.minio.io/client/mc/release/linux-amd64/mc" && \
      chmod +x mc && \
      export PATH="$DIRECTORY/build:$PATH" && \
      mc config host add $mc_alias $mc_endpoint $mc_hmac_key $mc_hmac_secret && \
      mc ls $mc_alias;
    fi
}
