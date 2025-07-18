# SND2 needs all functions to be wrapped/rewritten. This is being done in vac_functions. Feel free to contribute via pr (or other means).

# SND Scripts

## Table of Contents
1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Script Categories](#script-categories)
   - [GC Supply Scripts](#gc-supply-scripts)
   - [Job Unlocker](#job-unlocker)
   - [AutoHunt](#autohunt)
   - [Questionable Companion](#questionable-companion)
   - [Retainer Maker](#retainer-maker)
   - [Tools](#tools)
   - [Trading Scripts](#trading-scripts)
   - [Character Cycler](#character-cycler)
   - [Retired Scripts](#retired-scripts)
4. [Planned Changes](#planned-changes)
5. [Installation](#installation)
6. [License](#license)
7. [Third-Party Libraries](#third-party-libraries)

## Introduction
This repository contains a collection of SND scripts designed to automate various tasks. These scripts enhance efficiency and assist with management tasks, particularly for players managing multiple accounts or FCs.

Please note that all our scripts disable the `Yes Already` plugin, that means if you stop a script early, the functionality the plugin provides (your own configured `/pyes` settings) will no longer work until you click the button to enable it again, other plugins share this behaviour and is not exclusive to the scripts we provide.

## Prerequisites
- All scripts require `vac_functions.lua` and `vac_lists.lua` to be placed in your SND config folder.
- Some scripts may require specific plugins and a minimum plugin version, which will be noted in their respective sections. In addition to this the script will not run until it detects you have the required plugins enabled and at the required version, which will be shown in your chat log.
- Certain scripts require two service accounts to function properly, this will be noted in each script.
- Script functionality will break if you have any "auto actions" enabled in plugins such as auto peloton, please ensure you do not have any conflicting settings.
- Some scripts require the following settings to operate properly, and are handled automatically:
  - SND settings:
    - `UseSNDTargeting` set to true
    - `StopMacroIfActionTimeout` set to false
    - `StopMacroIfItemNotFound` set to false
    - `StopMacroIfCantUseItem` set to false
    - `StopMacroIfTargetNotFound` set to false
    - `StopMacroIfAddonNotFound` set to false
    - `StopMacroIfAddonNotVisible` set to false
  - Simple Tweaks settings:
    - `FixTarget` set to true
    - `DisableTitleScreenMovie` set to true
    - `EquipJobCommand` set to true
    - `RecommendEquipCommand` set to true
  - CBT settings:
    - `MaxGCRank` set to false
    - `AutoSnipeQuests` set to true

## Script Categories

### GC Supply Scripts
![Status](https://img.shields.io/badge/status-working_with_old_snd-brightgreen)

Automate the process of leveling DoL jobs through GC turn-ins. Requires two service accounts.

Recommended to not use the Enforce Expert Delivery hack inside CBT plugin.

| Script Name | Description | Requirements |
|-------------|-------------|--------------|
| `Auto Gen Provisioning List.lua` | Compiles required GC provision supply items and creates a `list_to_gather.txt` file | - |
| `Trade GC Items.lua` | Facilitates item trading between characters | Use with `Kupo Box GC Edition.lua` (optional) |
| `Kupo Box GC Edition.lua` | Automates item delivery to GC, including **Expert Delivery**. Can be used **standalone for turn-ins** without requiring `Trade GC Items.lua`. | - |

### Job Unlocker
![Status](https://img.shields.io/badge/status-broken-red)

Automates GC-related tasks including hunt logs, quest unlocks, and FC-related actions. This will be remade at some point, and is not as complete as the other scripts.

### AutoHunt
![Status](https://img.shields.io/badge/status-needs_testing-blue)
![Status](https://img.shields.io/badge/working%3F-probably_with_old_snd-aquamarine)

Does one hunt log of your choice, including dungeon mobs. Currently only tested with GC logs and Marauder 1-5.
It can also unlock GC rank 9 for you.

### Questionable Companion

![Status](https://img.shields.io/badge/status-working_with_old_snd-brightgreen)
![Status](https://img.shields.io/badge/bugs%3F-maybe-yellow)

Enhances the Questionable plugin with features like:
- Automatic duty support dungeon queueing
- Solo instance automation
- Vnavmesh stuck checking
- Death handling
- 
### Tools
Utility scripts for various tasks:

| Script Name | Description | Status |
|-------------|-------------|-------------|
| Items for FC Rank 6 | Calculates items needed for FC rank 6 | ![Status](https://img.shields.io/badge/status-working-brightgreen) |
| Mail Opener | Automates mail management | ![Status](https://img.shields.io/badge/status-needs_testing-blue) |
| Pos Finder | Displays and logs current position | ![Status](https://img.shields.io/badge/status-working-brightgreen) |

### Trading Scripts
![Status](https://img.shields.io/badge/status-working_with_old_snd-brightgreen)

Facilitates item trading between multiple characters. Requires two service accounts.

| Script Name | Description |
|-------------|-------------|
| Kupo Box | Receives items at configured locations |
| Post Moogle | Sends items from configured locations |

Both include a CharListGen for easy configuration.

### Character Cycler
![Status](https://img.shields.io/badge/status-working_with_old_snd-brightgreen)

Cycles toons and runs a script on each. Meant to be used with alts, like doing the hunt log and some such.

### Retired Scripts
![Status](https://img.shields.io/badge/status-retired-lightgrey)

Archive of deprecated scripts. No active support provided.

## Planned Changes
- Rewriting [Job Unlocker](https://github.com/WigglyMuffin/SNDScripts/tree/main/Scripts/Job%20Unlocker) script
- Rewriting [Questionable Companion](https://github.com/WigglyMuffin/SNDScripts/tree/main/Scripts/Questionable%20Companion) script
- Rewriting [Retainer Maker](https://github.com/WigglyMuffin/SNDScripts/tree/main/Scripts/Retainer%20Maker) script
- Changing plugins from Rotation Solver Reborn to Wrath Combo for auto rotations
- Changing plugins from Teleporter to Lifestream for teleports
- Changing plugins from BossMod Reborn to BossMod for duty solving support

## Installation
1. Verify all required plugins are installed and enabled.
2. Download the latest vac_functions and vac_lists files.
3. Place the vac_functions and vac_lists files in your SND config folder (`%appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing`), this location will need to be changed manually in each script if you have a different environment or default location set.
4. Download the latest script files of your choice from their respective locations.
5. Place scripts inside your SND environment (`/snd` and import the scripts).
6. Each script can have a configuration/settings section, ensure that you correctly set it up for your needs.

## License
This project is licensed under the [GNU GPL v3](https://www.gnu.org/licenses/gpl-3.0.en.html).

## Third-Party Libraries
- JSON Library for Lua
  - Source: https://github.com/craigmj/json4lua
  - License: MIT License
  - Full license text included with library code

*Note: The inclusion of MIT-licensed code does not affect the overall GPL v3 licensing of this project.*
