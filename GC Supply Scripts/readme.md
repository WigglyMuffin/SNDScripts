# Using these scripts
1. Configure the `CharList.lua` file to include all of your chosen alt account characters following the format specified inside of the file, place this into your `%appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\` of the user account your alt account is located.
2. Run `Auto gen Provisioning List.lua` on your alt account to generate a `ProvisioningList.lua` file which is used for the later scripts, it will be located with everything it found in `%appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\`, this will be your relevant user account %appdata%.
3. When the above finishes you can run `Generate List of items to gather.lua` to find out what items you need to obtain in an organised list called `List_to_gather.txt`, it will be located in `%appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\`, once again your relevant user account %appdata%.
4. Once you have everything on the account you are trading from, you need to run `Deliver items to alts.lua` in the location the alts are coming to, and run a configured `Collect items from main.lua` on the alt account so they come and pick up all the needed items.
5. Finally, you run `Deliver GC Items.lua` on the alt account when you have picked up all the items from the previous step, and it will go to the Maelstrom GC and turn them in.

## Easy mistakes
Make sure you have `CharList.lua` configured in the following format or some of the scripts will not work.
```
local character_list = {
    "First Last@Server",
    "First Last@Server",
    "First Last@Server",
    "First Last@Server",
    "First Last@Server"
}

local character_list_options = {
    {"First Last@Server", 0, 2},
    {"First Last@Server", 0, 2},
    {"First Last@Server", 0, 2},
    {"First Last@Server", 0, 2},
    {"First Last@Server", 0, 2}
}
```

Also in the script `Deliver to alts.lua` make sure that `SNDAltConfigFolder` near the top is pointing to your alts SND %appdata% config folder in the case that you have your alt running under a different user account.
Or at the very least pointing to a folder that has a copy of the generated `ProvisioningList.lua` from the `Auto Gen Provisioning List.lua` script.

## File and Folder Structure
Make sure you roughly follow this structure for these scripts to work.
`List_to_gather.txt` and `ProvisioningList.lua` will be automatically generated once you run the scripts.
```bash
C:\Users\Main Account\AppData\Roaming\XIVLauncher\pluginConfigs\SomethingNeedDoing\/
└── vac_functions.lua

C:\Users\Alt Account\AppData\Roaming\XIVLauncher\pluginConfigs\SomethingNeedDoing\/
├── Lists/
│   └── List_to_gather.txt
├── CharList.lua
├── ProvisioningList.lua
└── vac_functions.lua
```

## Current problems
Maelstrom the is only GC currently supported, the remaining two have not been tested and there are no plans to add these.

## Planned improvements
It might be worth adding a config file for everything here so you don't have to move around files and everything goes into the same folder.
