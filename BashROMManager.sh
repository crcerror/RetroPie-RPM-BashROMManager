# cyperghosts BashROMManager 0.31
#
# 31/01/18 - 0.1 Selectable Files, no release
# 07/02/18 - 0.2 Per System selection, no relase
# 12/02/18 - 0.3 Detect empty directories, no release
# 13/02/18 -0.31 Full console Names in array, Loop function
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


function del_file() {
    # Delete Save games
    # Is Array value already empty? If Yes then return
    [ -z "${file_array[$2-1]}" ] && return

    dialog --yesno "I will delete following file after you choose YES\n\n$1\n" 10 60
    [ $? = 0 ] && rm -f "$1" && file_array[$2-1]="" && options[$2*2-1]=""
}

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

    local cmd=(dialog --backtitle "cyperghosts BashROMManager v0.31" \
                      --title " Systemselection " \
                      --cancel-label "Exit to ES" \
                      --menu "Available systems:" 16 70 16)
    local choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    rom_sysdir="$rom_dir/$choices"
}

# --- MAIN ---
while true
do
    unset options
    folder_select
    [ -z "${rom_sysdir##*/}" ] && echo "Aborting..." && exit

    # Get Console Name
    contains_element "${rom_sysdir##*/}" "${console[@]}"
        [ $? = 0 ] && console_name="${rom_sysdir##*/} - System unknown" 
        [ $? = 1 ] && console_name="${console[idx+1]}"

    # Build file Array and get Array size
        file_array=("$rom_sysdir"/*)
        idx=${#file_array[@]}

    # Building Choices Array for options
    # Means "counter Text counter Text"
    # The test commands hinder to choose directories!
    # A file without '.' is likly a directory
        for (( z=0; z<$idx; z++ ))
        do
            name="${file_array[z]##*/}"
            ext="${name##*.}"
            [ "$ext" != "$name" ] && options+=("$((z+1))" "$ext - $name")
        done

    # Array validity check!
        idx=${#options[@]}
        [ $idx = 0 ] && dialog --title " Error " --infobox "\nLikely just a SubDirectory!\n\nExit to EmulationStation!\n" 7 35 && sleep 3 && exit

    # Build Dialog output of File selection
    while true
    do
        cmd=(dialog --backtitle "cyperghosts BashROMManager v0.31" \
                    --title " Selected Console: $console_name" \
                    --cancel-label "Back to SysSelection" \
                    --menu "Select file to delete:" 17 80 16)
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

        case $choices in
            [1-9999]) del_file "${file_array[choices-1]}" "$choices" ;;
            *) break ;;
        esac
    done
done
