# Using these scripts
These scripts are for levelling your DoL jobs on an alt account, they are made for two accounts and are not compatible with a single account.

They are designed to automatically tell you what GC turnins you need for your DoL jobs by giving you an items to gather list, which are then used to distribute from your main account to your alt account using the other provided scripts.
1. Configure the `vac_char_list.lua` file to include all of your chosen alt account characters following the format specified inside of the file, place this into your `%appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\` of the user account your alt account is located.
2. Run `Auto gen Provisioning List.lua` on your alt account to generate a `provisioning_list.lua` file which is used for the later scripts, it will be found with GC related things in `%appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\VAC\GC\`, this will be your relevant user account %appdata%.
3. When the above finishes you can run `Generate List of items to gather.lua` to find out what items you need to obtain in an organised list called `list_to_gather.txt`, it will be located in `%appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\VAC\GC\`, once again your relevant user account %appdata%.
4. Once you have everything on the account you are trading from, you need to run `Trade GC items to alts.lua` in the location the alts are coming to, and run a configured `Kupo Box.lua` on the alt account so they come and pick up all the needed items.
5. Finally, you run `Deliver GC Items.lua` on the alt account when you have picked up all the items from the previous step, and it will go to the Maelstrom GC and turn them in. It has a lot of options like level cap detection and job ignoring.
6. You will need to place the `vac_functions.lua` and `vac_lists.lua` files in `%appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\` of your respective user accounts too, for both your main and alt account. Refer to the file structure tree below for a visual representation.

## Configuring vac_char_list correctly
Make sure you have `vac_char_list.lua` configured in the following format or some of the scripts will not work. 

You can use the provided files found in the `Tools` folder named `Kupo Box CharListGen.lua` and `Post Moogle CharListGen.lua` to assist with creating the correct format lists.

A detailed description is available for each variable inside of the included file. The following lists are for demonstration purposes only, but serve as a reference point as well.

```
local character_list = {
    "First Last@Server",
    "First Last@Server"
}

local character_list_kupobox = {
    {
        ["Name"] = "Large Meow@Sephirot", -- The name of the character you're logging in on
        ["Trading With"] = "Smol Meow", -- Character you're trading with, without world
        ["Destination Server"] = "Sephirot", -- Server you're going to pick up items on
        ["Destination Type"] = 0, -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
        ["Destination Aetheryte"] = "Aleport", -- Aetheryte to meet at if ["Destination Type"] is set to 0
        ["Destination House"] = 0, -- Options: 0 = FC, 1 = Personal, 2 = Apartment // Only active if ["Destination Type"] is set to 1 or 2
        ["Do Movement"] = false, -- Options: true, false // will move to the character you're trading to, usually this is done by the delivery character
        ["Return Home"] = false, -- Options: true, false // will just log out if set to false, otherwise will move to home server and to set location configured by ["Return Location"]
        ["Return Location"] = 0 -- Options: 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc 
    },
    {
        ["Name"] = "Larger Meow@Ravana", -- The name of the character you're logging in on
        ["Trading With"] = "Smol Meow", -- Character you're trading with, without world
        ["Destination Server"] = "Sephirot", -- Server you're going to pick up items on
        ["Destination Type"] = 0, -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
        ["Destination Aetheryte"] = "Aleport", -- Aetheryte to meet at if ["Destination Type"] is set to 0
        ["Destination House"] = 0, -- Options: 0 = FC, 1 = Personal, 2 = Apartment // Only active if ["Destination Type"] is set to 1 or 2
        ["Do Movement"] = false, -- Options: true, false // will move to the character you're trading to, usually this is done by the delivery character
        ["Return Home"] = false, -- Options: true, false // will just log out if set to false, otherwise will move to home server and to set location configured by ["Return Location"]
        ["Return Location"] = 0 -- Options: 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc 
    },
}

local character_list_postmoogle = {
    {
        ["Name"] = "Large Meow@Bismarck", -- The name of the character you're using to trade
        ["Trading With"] = "Smol Meow", -- Character you're trading with, without world
        ["Destination Server"] = "Sephirot", -- Server you're going to meet the recipient
        ["Destination Type"] = 0, -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
        ["Destination Aetheryte"] = "Aleport", -- Aetheryte to meet at if ["Destination Type"] is set to 0
        ["Destination House"] = 0, -- Options: 0 = FC, 1 = Personal, 2 = Apartment // Only active if ["Destination Type"] is set to 1 or 2
        ["Do Movement"] = false, -- Will move to the character you're trading to, usually this is done by the delivery character
        ["Return Home"] = false, -- Will just log out if set to false, otherwise will move to home server and to set location configured by ["Return Location"]. This is always processed after it no longer has any trades left
        ["Return Location"] = 0, -- 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc
        ["Items"] = {  -- This is where you configure what items each character is going to be delivering, the format is {ITEMNAME, AMOUNT}
            --{"Copper", 50}, -- It is not case sensitive, however it needs to be the full name so it doesn't accidentally get the wrong item
            --{"Gold Ore", 10}
        },
    },
    {
        ["Name"] = "Larger Meow@Sephirot", -- The name of the character you're using to trade
        ["Trading With"] = "Smol Meow", -- Character you're trading with, without world
        ["Destination Server"] = "Sephirot",  -- Server you're going to meet the recipient
        ["Destination Type"] = 0, -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
        ["Destination Aetheryte"] = "Aleport", -- Aetheryte to meet at if ["Destination Type"] is set to 0
        ["Destination House"] = 0, -- Options: 0 = FC, 1 = Personal, 2 = Apartment // Only active if ["Destination Type"] is set to 1 or 2
        ["Do Movement"] = false, -- Will move to the character you're trading to, usually this is done by the delivery character
        ["Return Home"] = false, -- Will just log out if set to false, otherwise will move to home server and to set location configured by ["Return Location"]. This is always processed after it no longer has any trades left
        ["Return Location"] = 0, -- 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc
        ["Items"] = {  -- This is where you configure what items each character is going to be delivering, the format is {ITEMNAME, AMOUNT}
            --{"Copper", 50}, -- It is not case sensitive, however it needs to be the full name so it doesn't accidentally get the wrong item
            --{"Gold Ore", 10}
        },
    },
}
```

Make sure the `Trade GC items to alts.lua` file has the `SNDAltConfigFolder` near the top is pointing to your alts SND %appdata% config folder in the case that you have your alt running under a different user account.

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

## Limitations
Maelstrom the is only GC currently supported, the remaining two have not been tested and there are no plans to add these.
