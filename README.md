# RetroPie-RPM-BashROMManager

This will let you delete determinated ROMs of choosen system. You can use your gamepad to delete ROMs, SaveStates, settings.....

As it is usable with your gamepad it can be annoying to click hundreds of files. It's more intended to delete setting files, single ROMs (broken, wrong translated, porn stuff, PD roms, twins....)
Second annoying thing is that RetroPie does not support selection lists via game controller. So you can delete one single file on one run - sorry but not my fault. It's easily addable but well if you already got a keyboard you are faster through CLI or use a full grown file manager like `midnight commander` :)

## How to install

Copy the bashfile just into folder `/home/pi/RetroPie/retropiemenu` from your RetroPie installation.
You "may" change the ROMPath if your have annother default setting as `/home/pi/RetroPie/roms`

## How does this work

I wanted to write this as simple as possible.
All directories from the your ROM-default path will be listed.

So a typcial ROM structure usually can look like this
```
~/RetroPie
|
├── roms
│   ├── amstradcpc
│   ├── arcade
│   │   └── mame2003
│   │       ├── cfg
│   │       ├── ctrlr
│   │       ├── diff
│   │       ├── hi
│   │       ├── inp
│   │       ├── memcard
│   │       ├── nvram
│   │       └── snap
│   ├── atari2600
│   ├── atari7800
│   ├── atarilynx
│   ├── fba
```

This looks awful... isn't it?

So
1. The shortnames atari2600, gb, nes will be displayed as their real names
  + cps1 - Capcom Play System 1
  + nes - Nintendo Entertainment system
  + gb - Nintendo GameBoy
  + atari2600 - Atari 2600.....
2. Empty folder/systems will be ignored and can't be selected
3. If a system contains subfolder the subfolder will also be ignored and can't be selected

# How does it looks now?

**1. You are in the system selection > zxspectrum selected**
![img](https://up.picr.de/31816394et.png)

**2. The zxspectrum system contains one file `gamelist.xml`**
![img](https://up.picr.de/31816395wi.png)

**3. If I want to delete I'm asked if I want to do so**
![img](https://up.picr.de/31816396vt.png)

**4. File is deleted as the folder is now empty zxspectrum will not be listed anymore**
![img](https://up.picr.de/31816397hx.png)
