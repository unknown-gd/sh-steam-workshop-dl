#!/bin/sh

steam_appid=4000
steamcmd_dir="./steamcmd"
fastgmad_dir="./fastgmad"

if [ ! -d $steamcmd_dir ]; then
    rm -rf $steamcmd_dir
    mkdir -p $steamcmd_dir
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxf - -C $steamcmd_dir
fi

if [ ! -d $fastgmad_dir ]; then
    wget https://github.com/WilliamVenner/fastgmad/releases/latest/download/fastgmad_linux.zip

    if [ -f "fastgmad_linux.zip" ]; then
        rm -rf $fastgmad_dir
        unzip fastgmad_linux.zip -d $fastgmad_dir
        rm -rf fastgmad_linux.zip
    fi
fi

steamcmd_executable="$steamcmd_dir/steamcmd.sh"
fastgmad_executable="$fastgmad_dir/fastgmad"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <id1> <id2> ..."
    exit 1
fi

install_dir=$(pwd)
steam_args=""

for item_id in "$@"; do
    steam_args="$steam_args +workshop_download_item $steam_appid $item_id validate"
done

eval "$steamcmd_executable +force_install_dir $install_dir +login anonymous $steam_args +quit"

install_dir="$install_dir/steamapps/workshop/content/$steam_appid"
downloads_dir="$HOME/Downloads/steam-workshop/$steam_appid"
mkdir -p "$downloads_dir"

for item_id in "$@"; do
    download_dir="$install_dir/$item_id"
    if [ -d $download_dir ]; then
        item_dir="$downloads_dir/$item_id"

        if [ -d $item_dir ]; then
            rm -rf "$item_dir"
        fi

        mv -f "$install_dir/$item_id" "$downloads_dir"

        for gma_path in $item_dir/*; do
            if [ -f "$gma_path" ]; then
                eval "$fastgmad_executable extract -file $gma_path -out $item_dir/$(basename $gma_path .gma)"
            fi
        done
    else
        echo "Failed to download item $item_id, skipping..."
    fi
done

