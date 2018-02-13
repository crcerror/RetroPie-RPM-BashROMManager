# RetroPie-RPM-BashROMManager

This will let you delete determinated ROMs of choosen system. You can use your gamepad to delete ROMs, SaveStates, settings.....

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

![img](https://up.picr.de/31816394et.png)
![img](https://up.picr.de/31816395wi.png)
![img](https://up.picr.de/31816396vt.png)
![img](https://up.picr.de/31816397hx.png)
