# PS Mac Tools

<p align="center"><img src="https://github.com/SvenGDK/PS-Multi-Tools/assets/84620/5f1e04c6-9d72-429c-85a5-b7090864c6e9" width="128" height="128"> </br>
The macOS version of PS Multi Tools.</br>Contains tools & backup manager for PS1, PS2, PS3, PS4, PS5 & PSP.</p>

<details>
<summary>Requirements</summary>

### macOS
- macOS 12.0 or higher
- Homebrew with following packages :
  - 'wget' (Used for mirroring directories from FTP)
  - 'jdk11' (Used for sending .jar payloads)
  - 'netcat' (Used to dump self files - more stable than macOS's 'nc')
  - 'pv' (Used to track the progress of SELF files dumping -> not working yet)

</details>

<details>
  <summary>v1.5 contains following tools</summary>
  
#### PS1
- Backup Manager (Read games only)
- Convert .bin/.cue files to a single .iso file
- Merge multiple .bin files into a single one
- Homebrew Downloads

#### PS2
- Backup Manager (Read games only)
- Burn .iso files to CD/DVD discs
- Convert an .iso game to an OPL compatible game and copy to an external drive
- Pack and Extract PAK files (not implemented yet)
- Homebrew Downloads

#### PS3
- Backup Manager with a FAT32 format tool
- Homebrew Downloads
- Make PS3 ISOs
- Extract PS3 ISOs with option to split into 4GB files
- Split or merge PS3 ISOs
- Patching PS3 ISOs
- PS1 .BIN Merge (Merges multiple .bin files into a single one)

#### PS4
- Backup Manager (Read games only)

#### PS5
- Backup Manager for Games & Apps
- Payload Sender (ELF, BIN & JAR -> requires jdk11)
- FTP Browser
- FTP Grabber/Dumper
- PKG Merger
- Param & Manifest JSON Editor
- Blu Ray disc burner
- Downloads & other useful resources

#### PSP
- Backup Manager (Read games only)
- Convert .iso files to .cso
- Convert .ELF to .PBP
- Homebrew Downloads (not implemented yet)

</details>

Runs on macOS 12.0+</br>
You can build the code in XCode or download the latest release.

You will need to add an exception when opening the app for the first time :</br>
https://support.apple.com/en-gb/guide/mac-help/mh40616/mac

PS Mac Tools uses the following tools from other developers:

| Tool | Created by | Repository |
| --- | --- | --- |
| `sfo` | hippie68 | https://github.com/hippie68/sfo
| `ps3iso-utils` | bucanero | https://github.com/bucanero/ps3iso-utils
| `binmerge` | putnam | https://github.com/putnam/binmerge
| `unar` | The Unarchiver | https://theunarchiver.com/command-line
| `ffplay` | FFmpeg | https://github.com/FFmpeg/FFmpeg
| `gsplit` | GNU | https://github.com/coreutils/coreutils
| `iso2opl` | arcadenea | https://github.com/arcadenea/iso2opl
| `PAKerUtility` | SP193, El_isra | https://github.com/israpps/PAKerUtility
| `elf2pbp` | ? | https://github.com/PSP-Archive/elf2pbp
| `esr_patcher` |  | https://github.com/edo9300/esr-disc-patcher-cli
| `ps3mca-ps1` |  | https://github.com/israpps/PAKerUtility
| `psexe2rom` | MottZilla, Alex Free | https://github.com/alex-free/psexe2rom
| `pkg_merge` | Tustin, aldo-o | https://github.com/aldo-o/pkg-merge

All tools with the exception of 'ffplay' are re-compiled for ARM64 and x86_64 and bundled to a universal MacOS binary using 'lipo'.
