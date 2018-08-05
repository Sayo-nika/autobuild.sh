#!/bin/bash

echo " ==================================================="
echo " |  Welcome to Sayonika RenPy DDLC Mod Autobuilder |"
echo " |                                                 |"
echo " |                  V0.0.1b                        |"
echo " |             Licensed under MIT                  |"
echo " ==================================================="
echo ""
echo " GitHub: https://github.com/Sayo-nika/autobuild.sh"
echo " Bug reports : https://github.com/Sayo-nika/autobuild.sh/issues/new"
echo ""

read -p "Root folder name: " DIRECTORY

BASE_DIRECTORY=$(echo "$DIRECTORY" | cut -d "/" -f2)

echo "Building Mod in $DIRECTORY"
echo "If you have this builder script inside your own project folder, make sure you format your Root folder as ../FOLDERNAME."
echo "Thanks, and have a nice day!"
if [[ -f "$BASE_DIRECTORY/build/renpy-6.99.12.4-sdk.tar.bz2" ]]; then
    mkdir -p $BASE_DIRECTORY/build
    mkdir -p $BASE_DIRECTORY/build/mod
    cd .. && cp -vRf $BASE_DIRECTORY/* $BASE_DIRECTORY/build/mod
    cd $BASE_DIRECTORY/build
    tar xf renpy-6.99.12.4-sdk.tar.bz2
    rm renpy-6.99.12.4-sdk.tar.bz2
    mv renpy-6.99.12.4-sdk renpy
    rm -rf renpy-6.99.12.4-sdk
    pull_ddlc_base;
    echo "{\"version\":\"$(printf "local")\"}" >> version
    cd renpy 
    ./renpy.sh "../mod/" lint && ./renpy.sh launcher distribute "../mod/"
else
    mkdir -p build
    cd .. && cp -vRf $BASE_DIRECTORY/* $BASE_DIRECTORY/mod
    cd $BASE_DIRECTORY
    wget https://www.renpy.org/dl/6.99.12.4/renpy-6.99.12.4-sdk.tar.bz2
    tar xf renpy-6.99.12.4-sdk.tar.bz2
    rm renpy-6.99.12.4-sdk.tar.bz2
    mv renpy-6.99.12.4-sdk renpy
    rm -rf renpy-6.99.12.4-sdk
    pull_ddlc_base;
    echo "{\"version\":\"$(printf "local")\"}" >> version
    cd renpy
    ./renpy.sh "../mod/" lint && ./renpy.sh launcher distribute "../mod/"
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
