# PS Mac Tools

| | |
| ------------- | ------------- |
| ![icon_128x128](https://user-images.githubusercontent.com/84620/198197587-157922d8-abca-41e4-b4ed-a69399bae7f4.png) | The MacOS version of PS Multi Tools.</br>This app simplifies the usage of a collection of tools for Playstation 1, 2, 3, 4 and Portable. |

The first preview build (v0.1 - created on 01/06/2021) contains only the following PS3 tools:
- PS3 Backup Manager with a FAT32 format tool
- PS3 Homebrew Downloader
- Make PS3 ISOs
- Extract PS3 ISOs with option to split into 4GB files
- Split or merge PS3 ISOs
- Patching PS3 ISOs
- PS1 .BIN Merge (Merges multiple .bin files into a single one)

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
| `PS1` | In development - next release |
| `PS2` | In development - next release |
| `PS3` | Last updated on 26/06/2022 |
| `PS4` | In development - next release |
| `PSP` | In development - next release |
| `PSV` | Not plannned for the moment. |

PS Mac Tools uses the following tools from other developers:

| Tool | Created by | Repository |
| --- | --- | --- |
| `sfo` | hippie68 | https://github.com/hippie68/sfo
| `ps3iso-utils` | bucanero | https://github.com/bucanero/ps3iso-utils
| `binmerge` | putnam | https://github.com/putnam/binmerge
| `unar` | The Unarchiver | https://theunarchiver.com/command-line
| `ffplay` | FFmpeg | https://github.com/FFmpeg/FFmpeg
| `gsplit` | GNU | https://github.com/coreutils/coreutils

v1: All tools with the exception of 'ffplay' are re-compiled for ARM64 and x86_64 and bundled to a universal MacOS binary using 'lipo'.
