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

read -p "Enter your mod's Location: " DIRECTORY

echo "Building Mod in $DIRECTORY"
echo "If you have this builder script inside your own project folder, make sure you input your folder as ../FOLDERNAME or use '.'."
echo "Thanks, and have a nice day!"

sleep 3;

if [[ ! -f "$DIRECTORY/build/renpy-6.99.12.4-sdk.tar.bz2" ]]; then
    mkdir -p $DIRECTORY/build
    mkdir -p $DIRECTORY/build/mod
    cp -vRf $DIRECTORY/* $DIRECTORY/build/mod
    cd $DIRECTORY/build
    tar xf renpy-6.99.12.4-sdk.tar.bz2
    rm renpy-6.99.12.4-sdk.tar.bz2
    mv renpy-6.99.12.4-sdk renpy
    rm -rf renpy-6.99.12.4-sdk
    pull_ddlc_base;
    cd $DIRECTORY/build/renpy 
    ./renpy.sh "$DIRECTORY/build/mod/" lint && ./renpy.sh launcher distribute "$DIRECTORY/build/mod/"
    cd ..
else
    mkdir -p build
    cp -vRf $DIRECTORY/* $DIRECTORY/mod
    cd $DIRECTORY
    wget https://www.renpy.org/dl/6.99.12.4/renpy-6.99.12.4-sdk.tar.bz2
    tar xf renpy-6.99.12.4-sdk.tar.bz2
    rm renpy-6.99.12.4-sdk.tar.bz2
    mv renpy-6.99.12.4-sdk renpy
    rm -rf renpy-6.99.12.4-sdk
    pull_ddlc_base;
    cd $DIRECTORY/build/renpy
    ./renpy.sh "$DIRECTORY/build/mod/" lint && ./renpy.sh launcher distribute "$DIRECTORY/build/mod/"
    cd ..
fi

if ! [ exit != 0 ]; then
   echo "Build Successfully made. Find it at $DIRECTORY/build/$DIRECTORY-dists or similar. Happy modding!"
   exit 0;
else 
   echo "Uh oh, we can't build your mod in $DIRECTORY. If this is a mistake, file a issue. Thank you."
   exit 1;
fi

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
