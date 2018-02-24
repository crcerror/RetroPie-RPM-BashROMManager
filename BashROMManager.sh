#!/bin/bash
# cyperghosts BashROMManager 0.81
#
# 31/01/18 - 0.10 Selectable Files, no release
# 07/02/18 - 0.20 Per System selection, no relase
# 12/02/18 - 0.30 Detect empty directories, no release
# 13/02/18 - 0.31 Full console Names in array, Loop function
# 15/02/18 - 0.50 Multiple selection possible
# 16/02/18 - 0.51 SubDirectories not selectable, some cosmetic effects
# 17/02/18 - 0.61 Added FAST FORWORD button, some correction in comments
# 18/02/18 - 0.77 FAST FORWARD regards entry list and calculates jumps
# 21/02/18 - Merged cleanup code by @meleu
# 21/02/18 - 0.79 Bug with idx resolved. Some Code cleanup
# 22/02/18 - 0.80 Improved function use @meleu thx
# 24/02/18 - 0.81 I'm okay: Please wait message...

# This will let you delete files in specific ROM folders
# This script is best called into RetroPie Menu
# Into the menu choose 'BashROMManager'
#
# by cyperghost for retropie.org.uk

# Enter ROM Directory it will be sanitized
rom_dir="/home/pi/RetroPie/roms"
[[ -z "${rom_dir##*/}" ]] && rom_dir="${rom_dir%?}"
[[ ! -d "$rom_dir" ]] && dialog --msgbox "Invalid Path!\n$rom_dir" 0 0 && exit 1

# Folder Array
folder_array=("$rom_dir"/*/)
folder_array=("${folder_array[@]%?}")
folder_array=("${folder_array[@]##*/}")

# Console Array
console=("3do" "Panasonic 3DO" "atari2600" "Atari 2600" "atari5200" "Atari 5200" "atarijaguar" "Atari Jaguar" "coleco" "ColecoVision" \             "dreamcast" "Sega Dreamcast" "famicom" "Nintendo Famicom" "intellivision" "IntelliVision" "markiii" "Sega Mark III" \
         "mastersystem" "Sega Master System" "megadrive" "Sega MegaDrive" "segacd" "Sega MegaCD" "n64" "Nintendo 64" \
         "neogeo" "SNK Neo-Geo AES" "nes" "Nintendo Entertainment System" "nintendobsx" "Nintendo Satelliview" \
         "pcengine" "NEC PC-Engine" "pcenginecd" "NEC PC_EnigneCD" "psx" "Sony Playstation" "saturn" "Sega Saturn" \
         "sega32x" "Sega 32X" "sfc" "Nintendo Super Famicom" "snes" "Super Nintendo Entertainment System" "tg16" "TurboGrafx 16" \
         "tg16cd" "TurboGrafx 16CD" "cps1" "Capcom Play System I" "cps2" "Capcom Play System II" "cps3" "Capcom Play System III")

# Search array for entry
# Value 0 if match is in entry! Otherwise return 1 for system not found (use for debugging)
# idx contains Array position and is set via caller function!
function contains_element () {
    local e
    local match="$1"
    local idx=0
    shift
    for e; do
        if [[ "$e" == "$match" ]]; then
            echo "$idx"
            return 0
        fi
        idx=$((idx+1))
    done
    return 1
}
# Build List Array
# idx needed to create System name from ${console[]}
function folder_select() {
    local i
    local options

    for i in "${folder_array[@]}"; do
       if [[ -z "$(find "$rom_dir/$i" -type d -empty)" ]]; then 
            array_idx="$(contains_element "$i" "${console[@]}")"
            [[ -z $array_idx ]] && options+=("$i" "System unknown") || options+=("$i" "${console[array_idx+1]}")
        fi
    done

    local cmd=(dialog --backtitle "cyperghosts BashROMManager v0.81" \
                      --title " Systemselection " \
                      --ok-label "Select System" \
                      --cancel-label "Exit to ES" \
                      --menu "There are $((${#options[@]}/2)) systems available:" 16 70 16)
    local choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

    rom_sysdir="$rom_dir/$choices"
}

# --- MAIN Functions ---

# Delete ROM-files
function del_files() {
    local e
    for e in "${del_array[@]}"; do
        dialog --yesno "I will delete following file after you choose YES\n\n$e\n" 10 60
        [[ $? == 0 ]] && rm -f "$e"
    done
}


# This actives/deactives entry in file selection list
# If a file is located it will be set to del_array and the entry will be faded out in list
# If entry is already faded out, the filename will be rebuild and entry will removed from del_arry
# IF removes file from entry and sets to file to del_arraypart, ELSE branch REBUILDS entries 
#
# --- Terrible coded ---
#
# Sleep is for debouncing
function toggle_entry() {

    [[ "${options[choices*2-1]}" == "SUBDIRECTORY - not selectable!" ]] && return

    if [[ "${options[choices*2-1]}" ]]; then 
        del_array+=("${file_array[choices-1]}")
        options[choices*2-1]=""
    else
        file_name="${file_array[choices-1]##*/}"
        extension="${file_name##*.}"
        options[choices*2-1]="$extension - $file_name"
        array_idx="$(contains_element "${file_array[choices-1]}" "${del_array[@]}")"
        unset del_array[array_idx]
        del_array=("${del_array[@]}")
    fi

    sleep 0.1
}

# --- MAIN Programm --

# Initialise
echo "Please wait while initializing the BashROMManager ..."
folderselect=1 #Needed to select system in first run

while true; do
    # Save some space and empty arrays on loop
    unset options
    unset del_array

    # Run System Selection on first run
    [[ "$folderselect" == 1 ]] && folder_select
    [[ -z "${rom_sysdir##*/}" ]] && echo "Aborting..." && exit

    # Get Console Name
    array_idx="$(contains_element "${rom_sysdir##*/}" "${console[@]}")"
    [[ -z $array_idx ]] && console_name="${rom_sysdir##*/} - System unknown" || console_name="${console[array_idx+1]}"

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
        [[ "$extension" != "$file_name" ]] && options+=("$((z+1))" "$extension - $file_name")
        [[ "$extension" == "$file_name" ]] && options+=("$((z+1))" "SUBDIRECTORY - not selectable!")
    done

    choices=1 #Revert some small errors
  
    # Build Dialog output of File selection
    while true
    do
        old_choice=$choices
        cmd=(dialog --backtitle "cyperghosts BashROMManager v0.81" \
                    --default-item "$choices" \
                    --title " Selected Console: $console_name " \
                    --ok-label "Select items" \
                    --cancel-label "Return" \
                    --help-button  --help-label "Erase ${#del_array[@]} items" \
                    --extra-button --extra-label "Fast Forward" \
                    --menu "There are $idx files available select them and add to delete queue" 17 80 16)
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

        status=$?
        [[ $status == 3 ]] && choices="F" # Extra Button
        [[ $status == 2 ]] && choices="E" # Help Button
        [[ $status == 1 ]] && choices="B" # Cancel Button

        case $choices in
            [1-9999]*)
                toggle_entry
                ;;
            E)
                folderselect=0
                [[ ${#del_array[@]} == 0 ]] && dialog --msgbox "Please select files to delete" 0 0
                del_files
                break
                ;;
            B)
                folderselect=1
                break
                ;;
            F)
                choices=${idx%?}
                choices=($((old_choice+choices+1)))
                [[ $choices -gt $idx ]] && choices=$idx
                [[ $old_choice -eq $idx ]] && choices=1
                ;;
            *)
                exit 1
                ;;
        esac
    done
done
