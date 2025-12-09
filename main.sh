#!/usr/bin/env bash

# Clears The Screen And Displays My Beautiful Ascii Art :)

clear
cat << "EOF"
#    :'######::'##::: ##::::'###::::'########:::'######:::'#######::'########::'########:
#    '##... ##: ###:: ##:::'## ##::: ##.... ##:'##... ##:'##.... ##: ##.... ##:... ##..::
#     ##:::..:: ####: ##::'##:. ##:: ##:::: ##: ##:::..:: ##:::: ##: ##:::: ##:::: ##::::
#    . ######:: ## ## ##:'##:::. ##: ########::. ######:: ##:::: ##: ########::::: ##::::
#    :..... ##: ##. ####: #########: ##.....::::..... ##: ##:::: ##: ##.. ##:::::: ##::::
#    '##::: ##: ##:. ###: ##.... ##: ##::::::::'##::: ##: ##:::: ##: ##::. ##::::: ##::::
#    . ######:: ##::. ##: ##:::: ##: ##::::::::. ######::. #######:: ##:::. ##:::: ##::::
#    :......:::..::::..::..:::::..::..::::::::::......::::.......:::..:::::..:::::..:::::                                                                                                                                                                                                                                                       
#                                                                                               
#                             github : erfanmousaviam-dev
#                  
#         If you liked the install script I could use your star on the project :)                                                                                                                                                                                                                                                                                                        
EOF
sleep 3
clear

set -e

DIR="$(pwd)"

echo "Step 1: Removing duplicates across all subdirectories..."
fdupes -rdN "$DIR"

# Function to organize files

organize_file() {
    
    file="$1"

    # Skip if already in Images/ or Videos/
    
    if [[ "$file" == */Images/* || "$file" == */Videos/* ]]; then
        return
    fi

    # Get modification date
    
    datetime=$(stat -c "%y" "$file" | cut -d' ' -f1)
    year=$(echo $datetime | cut -d'-' -f1)
    month=$(echo $datetime | cut -d'-' -f2)

    # File extension and type
    
    ext="${file##*.}"
    ext_lc=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

    if [[ "$ext_lc" =~ ^(jpg|jpeg|png|gif|heic)$ ]]; then
        base="$DIR/Images/$year/$month"
    elif [[ "$ext_lc" =~ ^(mp4|mkv|avi|mov)$ ]]; then
        base="$DIR/Videos/$year/$month"
    else
        return
    fi

    mkdir -p "$base"

    filename=$(basename "$file")
    dest="$base/$filename"

    # If destination file exists, skip moving to avoid overwrite
    
    if [[ ! -e "$dest" ]]; then
        mv "$file" "$dest"
    else
        
        # If content is identical, delete the source
        
        if cmp -s "$file" "$dest"; then
            rm "$file"
        else
            
            # If not identical, rename and move
            
            suffix=1
            while [[ -e "$base/${filename%.*}_$suffix.${filename##*.}" ]]; do
                ((suffix++))
            done
            mv "$file" "$base/${filename%.*}_$suffix.${filename##*.}"
        fi
    fi
}

export -f organize_file
export DIR

echo "Step 2: Organizing images and videos recursively..."
find "$DIR" -type f -regextype posix-extended -iregex '.*\.(jpg|jpeg|png|gif|heic|mp4|mkv|avi|mov)' -exec bash -c 'organize_file "$0"' {} \;

echo "Step 3: Final cleanup of duplicates (in newly organized folders)..."
fdupes -rdN "$DIR"

echo "All the images and videos are clean and oraganized."