#!/bin/sh
#  SOURCE: https://github.com/bootmortis/iran-hosted-domains/blob/main/scripts/update_iran_dat.sh

data="/app/bin/iran.dat,https://github.com/bootmortis/iran-hosted-domains/releases/latest/download/iran.dat /app/bin/geosite.dat,https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat /app/bin/geoip.dat,https://github.com/v2fly/geoip/releases/latest/download/geoip.dat"

for item in $data; do

    path=$(echo "$item" | cut -d ',' -f 1)
    url=$(echo "$item" | cut -d ',' -f 2)
    
    echo "Path: $path"
    echo "URL: $url"

    if [ -f "$path" ]; then
        new_checksum=$(curl -L "$url.sha256" | cut -d " " -f 1)
        current_checksum=$(shasum -a 256 "$path" | cut -d " " -f 1)

        # Compare the two checksums
        if [ "$new_checksum" != "$current_checksum" ]; then
            curl -L "$url" -o "$path.temp"
            # Replace the current file with the new file only if the new one is valid
            if [ "$(shasum -a 256 "$path.temp" | cut -d " " -f 1)" == "$new_checksum" ]; then
                mv "$path.temp" "$path"
                echo "$path file updated successfully."
            else
                rm "$path.temp"
                echo "$path file is invalid."
            fi
        else
            echo "$path file is already up to date."
        fi
    else
        curl -L "$url" -o "$path"
        echo "$path file downloaded successfully."
    fi 


done

