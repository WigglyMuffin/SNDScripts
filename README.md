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
4. [Installation](#installation)
5. [License](#license)
6. [Third-Party Libraries](#third-party-libraries)

## Introduction
This repository contains a collection of SND scripts designed to automate various tasks. These scripts enhance efficiency and assist with management tasks, particularly for players managing multiple accounts or FCs.

## Prerequisites
- All scripts require `vac_functions.lua` and `vac_lists.lua` to be placed in your SND config folder.
- Some scripts may require specific plugins, which will be noted in their respective sections.
- Certain scripts require two service accounts to function properly.

## Script Categories

### GC Supply Scripts
Automate the process of leveling DoL jobs through GC turn-ins.

| Script Name | Description | Requirements |
|-------------|-------------|--------------|
| `Auto Gen Provisioning List.lua` | Compiles required GC provision supply items | - |
| `Generate list of items to gather.lua` | Creates a `list_to_gather.txt` file | - |
| `Trade GC items to alts.lua` | Facilitates item trading between characters | Use with `Kupo Box.lua` |
| `Deliver GC Items.lua` | Automates item delivery to GC | Configurable options |

### Job Unlocker
Automates GC-related tasks including hunt logs, quest unlocks, and FC-related actions. This will be remade at some point, and is not as complete as the other scripts.

### Overseer
Manages AutoRetainer tasks, including:
- Submersible management
  - Part swapping
  - Auto unlock and point plans
- Retainer management

### Questionable Companion
Enhances the Questionable plugin with features like:
- Automatic duty support dungeon queueing
- Solo instance automation
- vnavmesh stuck checking

### Retainer Maker
Automates the process of creating new retainers. Includes a CharListGen for easy configuration.

### Tools
Utility scripts for various tasks:

| Script Name | Description |
|-------------|-------------|
| Items for FC Rank 6 | Calculates items needed for FC rank 6 |
| Mail Opener | Automates mail management |
| Pos Finder | Displays and logs current position |

### Trading Scripts
Facilitates item trading between multiple characters. Requires two service accounts.

| Script Name | Description |
|-------------|-------------|
| Kupo Box | Receives items at configured locations |
| Post Moogle | Sends items from configured locations |

Both include a CharListGen for easy configuration.

### Retired Scripts
Archive of deprecated scripts. No active support provided.

## Installation
1. Verify all required plugins are installed and enabled.
2. Download the latest vac_functions and vac_lists files.
3. Place the vac_functions and vac_lists files in your SND config folder.
4. Download the latest script files of your choice from their respective locations.
5. Place scripts inside your SND environment (`/snd` and import the scripts).

## License
This project is licensed under the [GNU GPL v3](https://www.gnu.org/licenses/gpl-3.0.en.html).

## Third-Party Libraries
- JSON Library for Lua
  - Source: https://github.com/craigmj/json4lua
  - License: MIT License
  - Full license text included with library code

*Note: The inclusion of MIT-licensed code does not affect the overall GPL v3 licensing of this project.*
