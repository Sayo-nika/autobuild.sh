#!/bin/bash

#~  ===================================================
#~ |   Welcome to Sayonika RenPy DDLC Mod Autobuilder  |
#~ |                                                   |
#~ |                    V 2.0.0                        |
#~ |               Licensed under MIT                  |
#~  ===================================================
#~
#~    GitHub: https://github.com/Sayo-nika/autobuild.sh
#~  Bug reports : https://github.com/Sayo-nika/autobuild.sh/issues/new
#~

# Better way to print the shit above
cat "$0" | grep -E '#~' | sed -n 'x;/cat^.*/!g;//!p';

# Case Switches for cross-platform directory scanning
uname="$(uname -a)"
os=
case "$uname" in
    Linux\ *) os=linux ;;
    Darwin\ *) os=darwin ;;
    SunOS\ *) os=sunos ;;
    FreeBSD\ *) os=freebsd ;;
    OpenBSD\ *) os=openbsd ;;
    DragonflyBSD\ *) os=dragonflybsd ;;
    CYGWIN*) os=windows ;;
    MINGW*) os=windows ;;
    MSYS_NT*) os=windows ;;
esac

export installation_dir=
export installation_dir_steam=
case "$os" in 
    linux) 
       # TODO: grab all common installation paths per OS.
       if [ "$(id -u)" -eq 0 ]; then
          echo "! -- Autobuild only works at user accounts, not root!"
          exit 2;
        else
          echo "! -- We only support steam in Linux."
          installation_dir_steam="$HOME/.local/share/Steam/steamapps/common/doki doki literature club"
          installation_dir="$installation_dir_steam"
        fi
       ;;
    windows)
       # Since people uses MSYS or MINGW, we don't need the operands for the UNIX systems.
       installation_dir="$USERPROFILE/Doki Doki Literature Club"
       # Let's assume Steam is installed in C:\
       installation_dir_steam="$USERPROFILE/Steam/steamapps/common/Doki Doki Literature Club"
       ;;
    darwin)
       if [ "$(id -u)" -eq 0 ]; then
          echo "! -- Autobuild only works at user accounts, not root!"
          exit 2;
        else
          installation_dir="$HOME/Library/Application Support/itch/apps/Doki Doki Literature Club"
          installation_dir_steam="$HOME/Library/Application Support/steam/steampps/common/Doki Doki Literature Club"
        fi
       ;;
    *)
      echo "! -- $0 does not support $os."
      exit 1
      ;;
esac

pull_base_remote() {
    # Public S3 Credentials for our filepub bucket.
    # Feel free to replace this with your own.
    mc_endpoint="https://s3-api.us-geo.objectstorage.softlayer.net"
    mc_hmac_key="aa1d6f56b97443c185d7282c22adc4a7"
    mc_hmac_secret="29fc312082d26720ceeec6e89630f6d2fc382a96c7a72b1c"
    mc_alias="sayonika"
    mc_bucket="filepub"
    mc_filename="ddlc_pkg.zip"
    
    printf " ---> Checking if Minio S3 is present to pull DDLC resources.\n"
    
    if [ -z "$(command -v mc)" ]; then
        echo " ---> Minio Client not present. Installing Minio S3 Client"
        wget "https://dl.minio.io/client/mc/release/linux-amd64/mc" -O "$input/build/mc" --quiet && \
        chmod +x mc && \
        export PATH="$input/build:$PATH" && \
        $input/build/mc config host add $mc_alias $mc_endpoint $mc_hmac_key $mc_hmac_secret && \
        $input/build/mc ls $mc_alias;
        $input/build/mc cp "$mc_alias/$mc_bucket/$mc_filename" "$input"/build/
        unzip -o "$input/build/$mc_filename" -d "$input/build/mod/game"
        
    elif [ -f "$input/build/mc" ]; then
        echo "Minio Client present in build. Exporting to PATH."
        export PATH="$input/build:$PATH" && \
        $input/build/mc config host add $mc_alias $mc_endpoint $mc_hmac_key $mc_hmac_secret && \
        $input/build/mc ls $mc_alias;
        $input/build/mc cp "$mc_alias/$mc_bucket/$mc_filename" "$input"/build/        
        unzip -o "$input/build/$mc_filename" -d "$input/build/mod/game"
      else 
        echo " ---> Minio Client exists or Midnight Commander is present."
        echo " ---> Make sure Midnight Commander isn't installed since it causes issues with this script."
        $(command -v mc) config host add $mc_alias $mc_endpoint $mc_hmac_key $mc_hmac_secret && \
        # try if it works
        $(command -v mc) ls "$mc_alias";
        $(command -v mc) cp "$mc_alias/$mc_bucket/$mc_filename" "$input/build/"
        unzip -o "$input/build/$mc_filename" -d "$input/build/mod/game"
    fi
}

pull_ddlc_base() {
   if [ ! -d "$installation_dir_steam" ]; then
      if [ "$os" = "linux" ]; then
        echo "! -- Skipping vanilla installation dir. Pulling from remote now."
        pull_base_remote;
      fi 
      echo "! -- $installation_dir_steam does not exist. Trying your local non-steam installation.";
      if [ !  -d "$installation_dir" ]; then
        echo "! --  $installation_dir does not exist. Pulling from remote instead.";
        pull_base_remote;
      else
        echo " ---> $installation_dir exists. Pulling resources from there."
        cp -vR "$installation_dir/game/audio.rpa" "$input/build";
        cp -vR "$installation_dir/game/images.rpa" "$input/build";
        cp -vR "$installation_dir/game/fonts.rpa" "$input/build";
      fi
    else
        echo " ---> $installation_dir_steam exists. Pulling resources from there."
        cp -vR "$installation_dir_steam/game/audio.rpa" "$input/build";
        cp -vR "$installation_dir_steam/game/images.rpa" "$input/build";
        cp -vR "$installation_dir_steam/game/fonts.rpa" "$input/build";
   fi
}

print_help() {
   echo "$0 [-d <DIRECTORY> | -h]"
   echo ''
   echo 'Builds a mod by creating a build/ folder and compiles releases there.'
   echo 'When no arguments are present, the script starts in interactive mode.'
   echo 'However, for non-interactive usage, the following is accepted as a argument:'
   echo ''
   echo '-d --directory <DIRECTORY>      The Directory of the mod to build.'
   echo '-h --help                       Print this help dialogue.'
}
regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'

case "$1" in 
 -d | --directory)
      if [ -z "$2" ]; then
         echo "! -- Error: $1 requires a argument"
         print_help
         exit 2;
      else
        if [ $(echo $2 | grep $regex >/dev/null 2>&1) ] ||  [ -z "$2" ]; then
          echo "! -- Error: Invalid input. Try again."
          exit 2;
        elif [ ! -d "$2" ]; then
          echo "! -- Error: Directory does not exist. Try a different directory."
          exit 2;
        else
          input="$2";
        fi
      fi
    ;;
 -h | --help)
      print_help
      exit 0;
    ;;
  "")
     read -p  "Enter your mod's Location (use . if you have this script inside your mod folder): " input
    ;;
  -*)
      echo "Invalid option $1"
      print_help
      exit 2;
    ;;
esac
# Really needed Type Checks
while [ $(echo $input | grep $regex >/dev/null 2>&1) ]  ||  [ -z "$input" ] ; do
  echo "! -- Error: Invalid input. Try again."
  read -p  "Enter your mod's Location (use . if you have this script inside your mod folder): " input
done

while [ ! -d "$input" ] ; do
  echo "! -- Error: Directory does not exist. Try a different directory."
  read -p  "Enter your mod's Location (use . if you have this script inside your mod folder): " input
done


if [ "$input" = '.' ]; then
  echo " ---> Building mod in your PWD context."
  echo " ---> Do you know you can also build other mods with this? Just type the absolute path of the mod and enter. Happy Modding!"
 else
  echo " ---> Building Mod in $input"
  echo " ---> If you have this builder script inside your own project folder, make sure you input your folder as ../FOLDERNAME or use '.'."
fi


sleep 3;

if [ -d "$input/build" ]; then
   echo " ---> Looks like this has built before. Checking if files exists"
   if [ -f "$input/build/mc" ] && [ -d "$input/mod" ] &&  [ -d "$input/renpy" ] ; then
      echo " ---> Looks like this has been built before. Rebuilding game instead."
      cp -vRf "$input"/* "$input/build/mod"
      cd "$input/build/renpy" || exit
      ./renpy.sh "../build/mod/" lint && ./renpy.sh launcher distribute "../build/mod/""$1"
      cd ..
    else
      echo " ---> Looks like it's your first time building this mod. Here, I'll make it up to you~!"
      if [ -f "$input/build/renpy-6.99.12.4-sdk.tar.bz2" ]; then
          mkdir -p "$input/build"
          mkdir -p "$input/build/mod"
          pull_ddlc_base
          cp -vRf "$input"/* "$input/build/mod"
          cd "$input/build" || exit
          tar xf renpy-6.99.12.4-sdk.tar.bz2
          rm renpy-6.99.12.4-sdk.tar.bz2
          mv renpy-6.99.12.4-sdk renpy
          rm -rf renpy-6.99.12.4-sdk
          cd "$input/build"
          cd "$input/build/renpy" || exit
          ./renpy.sh "../build/mod/" lint && ./renpy.sh launcher distribute "../build/mod/""$1"
          cd ..
       else
          mkdir -p "$input/build"
          mkdir -p "$input/build/mod"
          cp -vRf "$input"/* "$input/build/mod"
          pull_ddlc_base
          cd "$input" || exit
          wget https://www.renpy.org/dl/6.99.12.4/renpy-6.99.12.4-sdk.tar.bz2
          tar xf renpy-6.99.12.4-sdk.tar.bz2
          rm renpy-6.99.12.4-sdk.tar.bz2
          mv renpy-6.99.12.4-sdk renpy
          rm -rf renpy-6.99.12.4-sdk
          cd build
          cd "build/renpy" || exit
          ./renpy.sh "../build/mod/" lint && ./renpy.sh launcher distribute "../build/mod/""$1"
          cd ..
       fi
    fi
else 
      echo " ---> Looks like it's your first time building this mod. Here, I'll make it up to you~!"
      mkdir -p "$input/build"
      mkdir -p "$input/build/mod"
      cp -vRf "$input"/* "$input/build/mod"
      pull_ddlc_base
      cd "$input" || exit
      wget https://www.renpy.org/dl/6.99.12.4/renpy-6.99.12.4-sdk.tar.bz2
      tar xf renpy-6.99.12.4-sdk.tar.bz2
      rm renpy-6.99.12.4-sdk.tar.bz2
      mv renpy-6.99.12.4-sdk renpy
      rm -rf renpy-6.99.12.4-sdk
      cd build 
      cd build/renpy || exit
      ./renpy.sh "../build/mod/" lint && ./renpy.sh launcher distribute "../build/mod/""$1"
      cd ..
fi

case "$(exit $?)" in 
  0) echo " ---> Build Successfully made. Find it at $input/build/ModXY-dists or similar. Happy modding!" && exit 0;
   ;;
  *) echo "! -- Uh oh, we can't build your mod in $input. If this is a mistake, file a issue. Thank you." && exit 1;
   ;;
esac