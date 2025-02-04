# GC Supply Scripts

These scripts are for levelling your DoL jobs on an alt account, they require two accounts and are not compatible with a single account.

They are designed to automatically tell you what GC turnins you need for your DoL jobs by giving you an items to gather list, which are then used to distribute from your main account to your alt account using the provided scripts.

It is also assumed you have all 3 city states unlocked.

## Known Issues

- Multiple DoL jobs selected can incorrectly include the items required at max level.

## Key Features

- **Dual-Account Compatibility**: The scripts are designed to work with two accounts, allowing you to level your Disciple of the Land (DoL) jobs on an alt account by distributing items from your main account.
- **Automated Item List Generation**: The scripts automatically generate a list of items needed for Grand Company (GC) turn-ins, which you can gather on your main account and distribute to your alt account.
- **Seamless Item Distribution**: The scripts facilitate the transfer of items from your main account to your alt account using the provided scripts, ensuring a smooth and efficient process.
- **Automatic Turn-In**: Once the items are distributed, each alt character will automatically turn in the provisioning items at their respective Grand Company.
- **Optional Expert Delivery**: If you have the Deliveroo plugin installed and set `expert_delivery` to true, you can further enhance the delivery process.

## Requirements

Ensure you have the following plugins installed and enabled:

- AutoRetainer : https://love.puni.sh/ment.json
- Dropbox : https://puni.sh/api/repository/kawaii
    - Recommended settings in dropbox are 4 frames delay between trades and 1500ms trade open command throttle. (Ctrl + left click to specify exact values).
    - You NEED to enable "Enable auto-accept trades." under the dropbox settings.
- Lifestream : https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
- Something Need Doing (Expanded Edition)
- Teleporter : In the default first party dalamud repository
- TextAdvance : https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
- vnavmesh : https://puni.sh/api/repository/veyn

Optional plugins:
- Deliveroo : https://plugins.carvel.li/
    - Only required if expert_delivery is set to true

## Installation

1. Verify all required plugins are installed and enabled.
2. Download the latest vac_functions and vac_lists files from [SNDScripts](https://github.com/WigglyMuffin/SNDScripts).
3. Place the vac_functions and vac_lists files in your SND config folder (`%appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing`) of both accounts. You can place them elsewhere but you will need to adjust the `load_functions_file_location` line of each script to point to the correct path.
4. Download the latest GC Supply script files (Auto Gen Provisioning List, Trade GC Items and Kupo Box GC Edition) from the [GC Supply Scripts folder](https://github.com/WigglyMuffin/SNDScripts/tree/main/Scripts/GC%20Supply%20Scripts).
5. Import the scripts into your SND environment (`/snd` and import the scripts). Optionally name the imported scripts in SND to match the file name.

## Getting Started

1. Configure the `character_list` inside the `vac_char_list.lua` file to include all of your chosen alt account characters following the format specified inside of the file, place this into your `%appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\` of the user account your alt account is located.
2. Run `Auto gen Provisioning List.lua` on your alt account to generate a `provisioning_list.lua` file which is used for the later scripts, it will be found with GC related things in `%appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\VAC\GC\`, this will be your relevant user account %appdata%.
3. Once this script has finished, another file called `list_to_gather.txt` will be generated located in `%appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\VAC\GC\`, once again your relevant user account %appdata%. This contains the items you need to gather on your main account.
4. When you have all the items on the account you are trading from, you need to run `Trade GC Items.lua` in the location the alts are coming to, and run a configured `Kupo Box GC Edition.lua` on the alt account so they come and pick up all the needed items.
5. Each alt character will turn the provisioning items in automatically at their respective GC after picking them up from the main account

## Configuration

### vac_char_list Configuration
Make sure you have `vac_char_list.lua` configured in the following format or some of the scripts will not work. 

Note that you can also use the `character_list` inside of `Auto Gen Provisioning List.lua` and `Kupo Box GC Edition.lua` instead of using the external list.

The following lists are for demonstration purposes only, but serve as a reference point as well.

```
local character_list = {
    "First Last@Server",
    "First Last@Server"
}
```

Make sure the `Trade GC Items.lua` file has the `SNDAltConfigFolder` near the top is pointing to your alts SND %appdata% config folder in the case that you have your alt running under a different user account.

## File and Folder Structure
Make sure you roughly follow this file tree structure for these scripts to work. If you run from a single %appdata% then it would be closer to the alt account file tree.
`list_to_gather.txt` and `provisioning_list.lua` will be automatically generated once you run the scripts.
```bash
C:\Users\Main Account\AppData\Roaming\XIVLauncher\pluginConfigs\SomethingNeedDoing\
├── vac_char_list.lua
├── vac_functions.lua
└── vac_lists.lua

C:\Users\Alt Account\AppData\Roaming\XIVLauncher\pluginConfigs\SomethingNeedDoing\
├── VAC
│   └── GC
│       ├── list_to_gather.txt
│       └── provisioning_list.lua
├── vac_char_list.lua
├── vac_functions.lua
└── vac_lists.lua
```