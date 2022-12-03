# PS Mac Tools

| | |
| ------------- | ------------- |
| ![icon_128x128](https://user-images.githubusercontent.com/84620/198197587-157922d8-abca-41e4-b4ed-a69399bae7f4.png) | The MacOS version of PS Multi Tools.</br>This app simplifies the usage of a collection of tools for Playstation 1, 2, 3, 4 and Portable. |

The first beta of v1 contains the following tools:

PS1
- Backup Manager (Read only atm)
- Convert .bin/.cue files to a single .iso file
- Merge multiple .bin files into a single one
- Homebrew Downloader

PS2

- Backup Manager (Read only atm)
- Burn your .iso files with the correct settings (not implemented yet)
- Convert to .iso game to an OPL compatible game and copy to an external drive
- Pack and Extract PAK files (not implemented yet)
- Homebrew Downloader

PS3
- PS3 Backup Manager with a FAT32 format tool
- PS3 Homebrew Downloader
- Make PS3 ISOs
- Extract PS3 ISOs with option to split into 4GB files
- Split or merge PS3 ISOs
- Patching PS3 ISOs
- PS1 .BIN Merge (Merges multiple .bin files into a single one)

PS4
- Backup Manager (Read only atm)

PSP
- Backup Manager (Read only atm)
- Convert .iso files to .cso
- Convert .ELF to .PBP
- Homebrew Downloader (not implemented yet)

| Update status | Last updated on |
| --- | --- |
| `Tools` | 01/06/2021 |
| `Homebrew urls` | 26/06/2022 |
| `Bugfixes or code updates` | 26/06/2022 |

Runs on MacOS Monterey or higher.</br>
You can build the code in XCode or download the latest release.

If you download the latest release you maybe need to add an exception when you open the app:</br>
https://support.apple.com/en-gb/guide/mac-help/mh40616/mac

Supported consoles and future update plans:
| Console support | Comments |
| --- | --- |
| `PS1` | v1 BETA+ - Last updated on 03/12/2022 |
| `PS2` | v1 BETA+ - Last updated on 03/12/2022 |
| `PSX-DESR` | In development - next release |
| `PS3` | v1 BETA+ - Last updated on 03/12/2022 |
| `PS4` | v1 BETA+ - Last updated on 03/12/2022 |
| `PSP` | v1 BETA+ - Last updated on 03/12/2022 |
| `PSV` | Not plannned atm. |

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

v1: All tools with the exception of 'ffplay' are re-compiled for ARM64 and x86_64 and bundled to a universal MacOS binary using 'lipo'.
