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
    
    if [ -z "$(command -v mc)" ]; then
      echo "Minio Client not present. Installing Minio S3 Client"
      wget "https://dl.minio.io/client/mc/release/linux-amd64/mc" -O $DIRECTORY/build/mc && \
      chmod +x mc && \
      export PATH="$DIRECTORY/build:$PATH" && \
      $DIRECTORY/build/mc config host add $mc_alias $mc_endpoint $mc_hmac_key $mc_hmac_secret && \
      $DIRECTORY/build/mc ls $mc_alias;
      $DIRECTORY/build/mc cp "$mc_alias/$mc_bucket/$mc_filename" $DIRECTORY/build/
      unzip  $mc_filename -d $DIRECTORY/build/mod/game
    elif [ -f "$DIRECTORY/build/mc" ]; then
      echo "Minio Client present in build. Exporting to PATH."
      export PATH="$DIRECTORY/build:$PATH" && \
      $DIRECTORY/build/mc config host add $mc_alias $mc_endpoint $mc_hmac_key $mc_hmac_secret && \
      $DIRECTORY/build/mc ls $mc_alias;
      $DIRECTORY/build/mc cp "$mc_alias/$mc_bucket/$mc_filename" $DIRECTORY/build/
      unzip  $mc_filename -d $DIRECTORY/build/mod/game
    else 
      echo "Minio Client exists or Midnight Commander is present."
      echo "Make sure Midnight Commander isn't installed since it causes issues with this script."
      $DIRECTORY/build/mc config host add $mc_alias $mc_endpoint $mc_hmac_key $mc_hmac_secret && \
      # try if it works
      $DIRECTORY/build/mc ls $mc_alias;
      $DIRECTORY/build/mc cp "$mc_alias/$mc_bucket/$mc_filename" $DIRECTORY/build/
      unzip  $mc_filename -d $DIRECTORY/build/mod/game
    fi
}

regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'

read -p "Enter your mod's Location (use . if you have this script inside your mod folder): " input

# Really needed Type Checks

while [[ $input =~ $regex || -z $input ]] ; do
  echo "Invalid input. Try again."
  read -p "Enter your mod's Location (use . if you have this script inside your mod folder): " input
done

while [[ ! -d $input ]] ; do
  echo "Directory does not exist. Try a different directory."
  read -p "Enter your mod's Location (use . if you have this script inside your mod folder): " input
done


if [[ $input == '.' ]]; then
  echo "Building mod in your PWD context."
  echo "Do you know you can also build other mods with this? Just type the absolute path of the mod and enter. Happy Modding!"
  DIRECTORY="$(pwd)"
 else
  echo "Building Mod in $DIRECTORY"
  echo "If you have this builder script inside your own project folder, make sure you input your folder as ../FOLDERNAME or use '.'."
  DIRECTORY="$input"
fi


sleep 3;

if [[ -d "$DIRECTORY/build" ]]; then
   echo "Looks like this has built before. Checking if files exists"
   if [[ -f "$DIRECTORY/build/mc" && -d "$DIRECTORY/mod" && -d "$DIRECTORY/renpy" ]] ; then
      echo "Looks like this has been built before. Rebuilding game instead."
      cp -vRf $DIRECTORY/* $DIRECTORY/build/mod
      cd $DIRECTORY/build/renpy
      ./renpy.sh "$DIRECTORY/build/mod/" lint && ./renpy.sh launcher distribute "$DIRECTORY/build/mod/"$1
      cd ..
    else
      echo "Looks like it's your first time building this mod. Here, I'll make it up to you~!"
      if [[ -f "$DIRECTORY/build/renpy-6.99.12.4-sdk.tar.bz2" ]]; then
          mkdir -p $DIRECTORY/build/mod
          cp -vRf $DIRECTORY/* $DIRECTORY/build/mod
          cd $DIRECTORY/build
          tar xf renpy-6.99.12.4-sdk.tar.bz2
          rm renpy-6.99.12.4-sdk.tar.bz2
          mv renpy-6.99.12.4-sdk renpy
          rm -rf renpy-6.99.12.4-sdk
          cd $DIRECTORY/build && pull_ddlc_base;
          cd $DIRECTORY/build/renpy 
          ./renpy.sh "$DIRECTORY/build/mod/" lint && ./renpy.sh launcher distribute "$DIRECTORY/build/mod/"$1
          cd ..
       else
          mkdir -p $DIRECTORY/build
          mkdir -p $DIRECTORY/build/mod
          cp -vRf $DIRECTORY/* $DIRECTORY/build/mod
          cd $DIRECTORY
          wget https://www.renpy.org/dl/6.99.12.4/renpy-6.99.12.4-sdk.tar.bz2
          tar xf renpy-6.99.12.4-sdk.tar.bz2
          rm renpy-6.99.12.4-sdk.tar.bz2
          mv renpy-6.99.12.4-sdk renpy
          rm -rf renpy-6.99.12.4-sdk
          cd $DIRECTORY/build && pull_ddlc_base;
          cd $DIRECTORY/build/renpy
          ./renpy.sh "$DIRECTORY/build/mod/" lint && ./renpy.sh launcher distribute "$DIRECTORY/build/mod/"$1
          cd ..
       fi
    fi
else 
      echo "Looks like it's your first time building this mod. Here, I'll make it up to you~!"
      mkdir -p $DIRECTORY/build
      mkdir -p $DIRECTORY/build/mod
      cp -vRf $DIRECTORY/* $DIRECTORY/build/mod
      cd $DIRECTORY
      wget https://www.renpy.org/dl/6.99.12.4/renpy-6.99.12.4-sdk.tar.bz2
      tar xf renpy-6.99.12.4-sdk.tar.bz2
      rm renpy-6.99.12.4-sdk.tar.bz2
      mv renpy-6.99.12.4-sdk renpy
      rm -rf renpy-6.99.12.4-sdk
      cd $DIRECTORY/build && pull_ddlc_base;
      cd $DIRECTORY/build/renpy
      ./renpy.sh "$DIRECTORY/build/mod/" lint && ./renpy.sh launcher distribute "$DIRECTORY/build/mod/"$1
      cd ..
fi

case $(exit $?) in 
  0) echo "Build Successfully made. Find it at $DIRECTORY/build/ModXY-dists or similar. Happy modding!" && exit 0;
   ;;
  *) echo "Uh oh, we can't build your mod in $DIRECTORY. If this is a mistake, file a issue. Thank you." && exit 1;
   ;;
esac
