# Overseer

Overseer is a script designed to improve your Auto Retainer experience. It provides automated backup, intelligent management, and optimisation features for Auto Retainer, ensuring data integrity and enhancing overall efficiency.

## Planned Features

- **Character & Retainer Management**: Streamline data handling for all your characters and retainers.
- **Venture Optimisation**: Dynamically adjust venture types based on retainer levels for maximum efficiency.
  - Venture type and plan management

## Key Features

- **Automated Backups**: Safeguard your Auto Retainer configuration with backup rotation (up to 50 backups).
- **Submersible Optimisation**:
  - Automatic creation and enabling of submersibles
  - Smart part swapping for optimal performance based on submersible rank
  - Route handling and plan management
- **Silent Operation**: Works seamlessly in the background with no interruptions.

## Requirements

Ensure you have the following plugins installed and enabled:

- AutoRetainer
- Deliveroo
- Lifestream
- Something Need Doing (Expanded Edition)
- Teleporter
- TextAdvance
- vnavmesh

## Installation

1. Verify all required plugins are installed and enabled.
2. Download the latest vac_functions file from [SNDScripts](https://github.com/WigglyMuffin/SNDScripts).
3. Place the vac_functions file in your SND config folder.
4. Download the latest Overseer script files (both Overseer and Overseer Launcher) from the [Overseer folder](https://github.com/WigglyMuffin/SNDScripts/tree/main/Scripts/Overseer).
5. Place Overseer and Overseer Launcher inside your SND environment.
6. Set Overseer Launcher as the script to run on AutoRetainer CharacterPostProcess.

## Getting Started

1. Configure the settings in Overseer (see Configuration section) to match your preferences.
2. Let Overseer optimise your Auto Retainer experience automatically upon AutoRetainer starting.

## Configuration

Fine-tune Overseer's behavior by adjusting these parameters in the script's configuration section:

| Setting | Description |
|---------|-------------|
| `venture_limit` | Minimum value of ventures to trigger buying more ventures, requires Deliveroo to be correctly configured by doing GC deliveries |
| `inventory_slot_limit` | Amount of inventory slots remaining before attempting a GC delivery to free up slots |
| `buy_ceruleum` | Will attempt to buy ceruleum fuel based on the settings below, if set to false the characters will never attempt to refuel (buy ceruleum fuel off players) |
| `ceruleum_limit` | Minimum value of ceruleum fuel to trigger buying ceruleum fuel |
| `ceruleum_buy_amount` | Amount of ceruleum fuel to be purchased when ceruleum_limit is triggered |
| `fc_credits_to_keep` | How many credits to always keep, this limit will be ignored when buying FC buffs for GC deliveries |
| `use_fc_buff` | Will attempt to buy and use the seal sweetener buff when doing GC deliveries |
| `ar_collection_name` | Name of the plugin collection which contains the "AutoRetainer" plugin |

Advanced users can also customise submersible builds and retainer venture strategies in their respective sections.

## Backup System

Overseer implements a robust backup system for your Auto Retainer configuration:

- Creates backups automatically
- Maintains a rolling set of up to 50 recent backups
- Ensures you can always revert to a previous stable configuration

## Disclaimer

**IMPORTANT:** Overseer directly modifies the Auto Retainer configuration file. By using Overseer, you acknowledge and accept the following:

1. Overseer's modifications will affect Auto Retainer's behaviour.
2. You are solely responsible for any issues, data loss, or unintended consequences arising from Overseer's use.
3. Auto Retainer and its developers are not liable for any problems caused by Overseer's modifications.
4. It is strongly recommended to manually backup your Auto Retainer configuration before first use of Overseer.
5. Use Overseer at your own risk. We cannot guarantee it won't conflict with Auto Retainer or other software.

By using Overseer, you agree to these terms and accept full responsibility for its use and any consequences thereof.
