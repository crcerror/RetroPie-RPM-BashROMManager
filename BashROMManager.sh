#!/bin/bash
# cyperghosts BashROMManager 0.50
#
# 31/01/18 - 0.1 Selectable Files, no release
# 07/02/18 - 0.2 Per System selection, no relase
# 12/02/18 - 0.3 Detect empty directories, no release
# 13/02/18 -0.31 Full console Names in array, Loop function
# 15/02/18 - 0.5 Multiple selection possible
#
# This will let you delete files in specific ROM folders
# This script is best called into RetroPie Menu
# Into the menu choose 'BashROMManager'
#
# by cyperghost for retropie.org.uk

# Enter ROM Directory it will be sanitized
    rom_dir="/home/pi/RetroPie/roms"
    [ -z "${rom_dir##*/}" ] && rom_dir="${rom_dir%?}"

# Folder Array
    folder_array=("$rom_dir"/*/)
    folder_array=("${folder_array[@]%?}")
    folder_array=("${folder_array[@]##*/}")

# Console Array

    console=("3do" "Panasonic 3DO" "atari2600" "Atari 2600" "atari5200" "Atari 5200" "atarijaguar" "Atari Jaguar" "coleco" "ColecoVision" \
             "dreamcast" "Sega Dreamcast" "famicom" "Nintendo Famicom" "intellivision" "IntelliVision" "markiii" "Sega Mark III" \
             "mastersystem" "Sega Master System" "megadrive" "Sega MegaDrive" "segacd" "Sega MegaCD" "n64" "Nintendo 64" \
             "neogeo" "SNK Neo-Geo AES" "nes" "Nintendo Entertainment System" "nintendobsx" "Nintendo Satelliview" \
             "pcengine" "NEC PC-Engine" "pcenginecd" "NEC PC_EnigneCD" "psx" "Sony Playstation" "saturn" "Sega Saturn" \
             "sega32x" "Sega 32X" "sfc" "Nintendo Super Famicom" "snes" "Super Nintendo Entertainment System" "tg16" "TurboGrafx 16" \
             "tg16cd" "TurboGrafx 16CD" "cps1" "Capcom Play System I" "cps2" "Capcom Play System II" "cps3" "Capcom Play System III")


function contains_element () {
    # Search array for entry
    # Value 1 if match is in entry! Otherwise return 0 for system not found
    # idx contains Array position!
    local e
    local match="$1"
    idx=0
    shift
        for e; do [[ "$e" == "$match" ]] && return 1; idx=$((idx+1)); done
    return 0
}

function folder_select() {
    # Build List Array
    # idx needed to create System name from ${console[]}
    local i
    local options

    for i in "${folder_array[@]}"
    do
       if [ -z "$(find "$rom_dir/$i" -type d -empty)" ]; then 
            contains_element "$i" "${console[@]}"
            [ $? = 0 ] && options+=("$i" "System unknown")
            [ $? = 1 ] && options+=("$i" "${console[idx+1]}")
        fi
    done

    local cmd=(dialog --backtitle "cyperghosts BashROMManager v0.50" \
                      --title " Systemselection " \
                      --cancel-label "Exit to ES" \
                      --menu "Available systems:" 16 70 16)
    local choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    rom_sysdir="$rom_dir/$choices"
}

# --- MAIN Functions ---

function del_files() {
    # Delete ROM-files
    local e
    for e in "${del_array[@]}"; do
        dialog --yesno "I will delete following file after you choose YES\n\n$e\n" 10 60
        [ $? = 0 ] && echo "$e" && sleep 1
    done
}

function toggle_entry() {
    # This actives/deactives entry in file selection list
    # If a file is located it will be set to del_array and the entry will be faded out in list
    # If an entry is already faded out, the filename will be rebuild and entry will removed from del_arry
    # IF part REBUILDS entries, ELSE removes file from entry and sets to file to del_array
    #
    # --- Terrible coded ---
    #
    # Sleep is for debouncing

    if [[ "${options[choices*2-1]}" ]]; then 
        del_array+=("${file_array[choices-1]}")
        options[choices*2-1]=""
    else
        file_name="${file_array[choices-1]##*/}"
        extension="${file_name##*.}"
        options[choices*2-1]="$extension - $file_name"
        contains_element "${file_array[choices-1]}" "${del_array[@]}"
        unset del_array[idx]
        del_array=("${del_array[@]}")
    fi

   sleep 0.1
}

# --- MAIN Programm --

folderselect=1 #Needed to select system in first run

while true
do
    # Save some space and empty arrays on loop
    unset options
    unset del_array

    # Run System Selection on first run
    [ $folderselect = 1 ] && folder_select
    [ -z "${rom_sysdir##*/}" ] && echo "Aborting..." && exit


    # Get Console Name
    contains_element "${rom_sysdir##*/}" "${console[@]}"
        [ $? = 0 ] && console_name="${rom_sysdir##*/} - System unknown" 
        [ $? = 1 ] && console_name="${console[idx+1]}"

    # Build file Array for path $rom_sysdir and get Array size
        file_array=("$rom_sysdir"/*)
        idx=${#file_array[@]}

    # Building Choices Array for options
    # Means "counter Text counter Text"
    # The test commands hinder to choose directories!
    # A file without '.' is likely a directory
        for (( z=0; z<$idx; z++ ))
        do
            file_name="${file_array[z]##*/}"
            extension="${file_name##*.}"
            [ "$extension" != "$file_name" ] && options+=("$((z+1))" "$extension - $file_name")
        done

    # Array validity check!
        [ ${#options[@]} = 0 ] && dialog --title " Error " --infobox "\nLikely just a SubDirectory!\n\nExit to EmulationStation!\n" 7 35 && sleep 3 && exit

    # Build Dialog output of File selection
    while true
    do
        cmd=(dialog --backtitle "cyperghosts BashROMManager v0.50" \
                    --default-item "$choices"
                    --title " Selected Console: $console_name" \
                    --ok-label "Select Item"
                    --cancel-label "Back to SysSelection" \
                    --extra-button --extra-label "Delete ${#del_array[@]} items in queue"
                    --menu "Select files you want to add to delete queue" 17 80 16)
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

        status=$?
        [ $status = 3 ] && choices="E"
        [ $status = 1 ] && choices="B"

        case $choices in
           [1-9999]*) toggle_entry
                      ;;
                   E) folderselect=0
                      [ ${#del_array[@]} = 0 ] && dialog --msgbox "Please select files to delete" 0 0
                      del_files; break
                      ;;
                   B) folderselect=1; break
                      ;;
                   *) exit 1
                      ;;
        esac
    done
done
