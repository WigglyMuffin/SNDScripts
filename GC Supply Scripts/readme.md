# Using these scripts
1. Run `Auto gen Provisioning List.lua` on your alt account to generate a ProvisioningList file which is used for the later scripts, places a file with everything it gathered in `%appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\`
2. When the above finishes you can run `Generate List of items to gather.lua` to find out what you need to gather in a slightly messy list called `List_to_gather.txt` which places itself in `%appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\`
3. Once you have everything on the account you're trading from you run `Deliver items to alts.lua` in the location the alts are coming to, and run a properly configured `Improved tony.lua` on the alt account so they come and pick up all the needed items
4. Finally you just run `Deliver GC Items.lua` on the alt account when you're picked up all the items from the previous step and it'll go to the GC and deliver all the items

## Easy mistakes
Make sure you have a file called CharList.lua which is configured in the following format or some of the scripts won't work
```
chars = {
    "EXAMPLE EXAMPLE@WORLD",
    "EXAMPLE EXAMPLE@WORLD",
    "EXAMPLE EXAMPLE@WORLD",
    "EXAMPLE EXAMPLE@WORLD",
    "EXAMPLE EXAMPLE@WORLD"
}
```

Also in the script `Deliver to alts.lua` make sure that `SNDAltConfigFolder` near the top is pointing to your alts SND config folder in the case that you have your alt running under a different user account.
Or at the very least pointing to a folder that has a copy of the generated `ProvisioningList.lua` from the `Auto Gen Provisioning List.lua` script

## Current problems
I'm pretty sure the only GC that works right now is maelstrom

## Planned improvements
It might be worth adding a config file for everything here so you don't have to move around files and everything goes into the same folder
