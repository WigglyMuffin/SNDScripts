# SND Scripts

## Table of Contents
1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Script Categories](#script-categories)
   - [GC Supply Scripts](#gc-supply-scripts)
   - [Job Unlocker](#job-unlocker)
   - [Overseer](#overseer)
   - [Questionable Companion](#questionable-companion)
   - [Retainer Maker](#retainer-maker)
   - [Tools](#tools)
   - [Trading Scripts](#trading-scripts)
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
- Some scripts may require specific plugins, which will be noted in their respective sections.
- Certain scripts require two service accounts to function properly.

## Script Categories

### GC Supply Scripts
![Status](https://img.shields.io/badge/status-working-brightgreen)

Automate the process of leveling DoL jobs through GC turn-ins.

| Script Name | Description | Requirements |
|-------------|-------------|--------------|
| `Auto Gen Provisioning List.lua` | Compiles required GC provision supply items and creates a `list_to_gather.txt` file | - |
| `Trade GC Items.lua` | Facilitates item trading between characters | Use with `Kupo Box GC Edition.lua` |
| `Kupo Box GC Edition.lua` | Facilitates item trading between characters and automates item delivery to GC | Use with `Trade GC Items.lua` |

### Job Unlocker
![Status](https://img.shields.io/badge/status-broken-red)

Automates GC-related tasks including hunt logs, quest unlocks, and FC-related actions. This will be remade at some point, and is not as complete as the other scripts.

### Overseer
![Status](https://img.shields.io/badge/status-needs_testing-blue)
![Status](https://img.shields.io/badge/working%3F-probably-aquamarine)

Manages AutoRetainer tasks, including:
- **Automated Backups**: Safeguard your Auto Retainer configuration with backup rotation (up to 50 backups).
- **Submersible Optimisation**:
  - Automatic creation and enabling of submersibles.
  - Part swapping for optimal voyaging based on submersible rank and configuration, there are submersible and inventory checks to ensure you have the parts.
  - Route handling and plan management.
  - Optimal vessel behaviour based on number of unlocked submersibles.
  - Incorrect submersible route and build corrections.
- **Retainer Optimisation**:
  - Plan management.
- **FC Management**:
  - GC expert delivery turnins with option for enabling Seal Sweetener I or II buffs.
  - Ceruleum Tank purchasing and topup management.
  - Venture purchasing and topup management.
- **Silent Operation**: Works seamlessly in the background with no interruptions.
- **Shutdown Timers**: Option to shutdown your client after a specified time for auth token renewal.
- **Menu Bailouts**: Additional menu bailouts for when a menu gets stuck.

### Questionable Companion
![Status](https://img.shields.io/badge/status-under_development-yellow)

Enhances the Questionable plugin with features like:
- Automatic duty support dungeon queueing
- Solo instance automation
- vnavmesh stuck checking

### Retainer Maker
![Status](https://img.shields.io/badge/status-needs_testing-blue)

Automates the process of creating new retainers. Includes a CharListGen for easy configuration.

### Tools
Utility scripts for various tasks:

| Script Name | Description | Status |
|-------------|-------------|-------------|
| Items for FC Rank 6 | Calculates items needed for FC rank 6 | ![Status](https://img.shields.io/badge/status-working-brightgreen) |
| Mail Opener | Automates mail management | ![Status](https://img.shields.io/badge/status-needs_testing-blue) |
| Pos Finder | Displays and logs current position | ![Status](https://img.shields.io/badge/status-working-brightgreen) |

### Trading Scripts
![Status](https://img.shields.io/badge/status-working-brightgreen)

Facilitates item trading between multiple characters. Requires two service accounts.

| Script Name | Description |
|-------------|-------------|
| Kupo Box | Receives items at configured locations |
| Post Moogle | Sends items from configured locations |

Both include a CharListGen for easy configuration.

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
