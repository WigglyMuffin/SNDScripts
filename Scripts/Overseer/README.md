# Overseer

![Status](https://img.shields.io/badge/status-needs_testing-blue)
![Status](https://img.shields.io/badge/working%3F-probably-aquamarine)

Overseer is a script designed to improve your Auto Retainer experience. It provides automated backup, management and optimisation features for Auto Retainer, ensuring data integrity and enhancing overall efficiency.

The default values inside the configuration can be used straight away, though it is recommended to configure and adjust anything to suit your required needs, see [Configuration](#configuration) section for more info.

There will potentially be bugs and weird things happening, please report any issues you encounter, preferably as an issue in this repo, this should be considered a script in the testing period, while all attempts have been made to ensure things run smoothly, there is no guarantee they will.

## Disclaimer

**IMPORTANT:** Overseer directly modifies the Auto Retainer configuration file. There are periodic backups created aimed to prevent data loss in the event of file corruption. See [Backup](#backup-system) section for more info.

By using Overseer, you acknowledge and accept the following:

1. Overseer's modifications will affect Auto Retainer's behaviour.
2. You are solely responsible for any issues, data loss, or unintended consequences arising from Overseer's use.
3. Auto Retainer and its developers are not liable for any problems caused by Overseer's modifications.
4. It is strongly recommended to manually backup your Auto Retainer configuration before first use of Overseer.
5. Use Overseer at your own risk. We cannot guarantee it won't conflict with Auto Retainer or other software.

By using Overseer, you agree to these terms and accept full responsibility for its use and any consequences thereof.

## Known Issues

- FC Actions will sometimes fail to apply when doing gc turnins, doesn't affect any other functionality or crash the script.

## Planned Features

- **Character & Retainer Management**: Streamline data handling for all your characters and retainers.
- **Venture Optimisation**: Dynamically adjust venture types based on retainer levels for maximum efficiency.
  - Venture type and plan management

## Key Features

- **Automated Backups**: Safeguard your Auto Retainer configuration with backup rotation (up to 50 backups).
- **Submersible Optimisation**:
  - Automatic creation and enabling of submersibles.
  - Part swapping for optimal voyaging based on submersible rank and configuration, there are submersible and inventory checks to ensure you have the parts.
  - Route handling and plan management.
  - Optimal vessel behaviour based on number of unlocked submersibles.
  - Incorrect submersible route and build corrections.
- **Retainer Optimisation**:
  - Plan management.
- **Retainer Scheduling**:
  - Retainer timers to only allow ventures to be run during specific times.
- **FC Management**:
  - GC expert delivery turnins with option for enabling Seal Sweetener I or II buffs.
  - Ceruleum Tank purchasing and topup management.
  - Venture purchasing and topup management.
- **Silent Operation**: Works seamlessly in the background with no interruptions.
- **Shutdown Timers**: Option to shutdown your client after a specified time for auth token renewal.
- **Menu Bailouts**: Additional menu bailouts for when a menu gets stuck.

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
2. Download the latest `vac_function.lua` and `vac_list.lua` files from [SNDScripts](https://github.com/WigglyMuffin/SNDScripts).
3. Place the `vac_function.lua` and `vac_list.lua` files in your SND config folder (`%appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing`). You can place them elsewhere but you will need to adjust the `load_functions_file_location` line of Overseer to point to the correct path.
4. Download the latest Overseer script files (both Overseer and Overseer Launcher) from the [Overseer folder](https://github.com/WigglyMuffin/SNDScripts/tree/main/Scripts/Overseer).
5. Edit Overseer ***OUTSIDE*** of the SND environment to configure the settings, and use the import button to import the script.
6. Import Overseer and Overseer Launcher into your SND environment (`/snd` and import the scripts using the `Import macro from clipboard` button). Make sure you name the imported scripts in SND to match the file name, and ensure the scripts are listed as `Lua`.
7. Optionally though recommended to set Overseer Launcher as the script to run on AutoRetainer CharacterPostProcess, located in SND settings (the `?` icon towards the top middle section of the UI).
8. Make sure you have "Wait on login screen" enabled in your Auto Retainer settings.

## Getting Started

1. Configure the settings in Overseer (see Configuration section) to match your preferences.
2. Start the `Overseer Launcher` script, this will load and start Overseer.
3. Let Overseer optimise your Auto Retainer experience automatically upon AutoRetainer starting.

## Configuration

Fine-tune Overseer's behaviour by adjusting these parameters in the script's configuration section:

| Setting | Description | Values Accepted | Default Value |
|---------|-------------|-----------------|---------------| 
| `disable_gc_delivery` | Disables attempting any kind of gc delivery on falling under either venture or inventory slot limits | `true` or `false` | `false` |
| `venture_limit` | Minimum value of ventures to trigger buying more ventures, requires Deliveroo to be correctly configured by doing GC deliveries | A number between `1` and `9999` | `100` |
| `inventory_slot_limit` | Amount of inventory slots remaining before attempting a GC delivery to free up slots | A number between `1` and `140` | `30` |
| `buy_ceruleum` | Will attempt to buy ceruleum fuel based on the settings below, if set to false the characters will never attempt to refuel (buy ceruleum fuel off players) | `true` or `false` | `false` |
| `ceruleum_limit` | Minimum value of ceruleum fuel to trigger buying ceruleum fuel | A number between `1` and `139860` | `1000` |
| `ceruleum_buy_amount` | Amount of ceruleum fuel to be purchased when ceruleum_limit is triggered | A number between `1` and `139860` | `99999` |
| `fc_credits_to_keep` | How many credits to always keep, this limit will be ignored when buying FC buffs for GC deliveries | A number between `1` and `999999999` | `13000` |
| `use_fc_buff` | Will attempt to buy and use the seal sweetener buff when doing GC deliveries | `true` or `false` | `false` |
| `force_return_subs_that_need_swap` | Will force return submarines to swap parts even if they're already sent out, if set to false it will wait until they're back | `true` or `false` | `false` |

You can also customise submersible builds and retainer venture types in their respective sections.

### Timers Configuration

These settings allow the script to automatically shut down the game after X minutes, good if you want to reset the token every day and have something else start the game again
| Setting | Description | Values Accepted | Default Value |
|---------|-------------|-----------------|---------------| 
| `enable_auto_shutdown` | Enables the auto shutdown feature | `true` or `false` | `false` |
| `shutdown_timer` | How many minutes the script will wait before shutting the client down in minutes, as an example 1440 minutes is a day | A number between `1` and `4320` | `1440` |

If you want to set your retainers to only run between x and x hours of the day you can use these settings to set a schedule of active retainer hours.
This uses your local PC time and in a 24 hour format, therefore adjust the hours and minutes to your requirements.
| Setting | Description | Values Accepted | Default Value |
|---------|-------------|-----------------|---------------|
| `enable_retainer_schedule` | Enables the retainer schedule and to be used with `retainer_active_hours` | `true` or `false` | `false` |

The script includes a configuration table for retainer active hours. Here's an example of how to configure them:

```lua
local retainer_active_hours = {
    start_time = { hour = 17, minute = 00 }, -- 5:00 PM
    end_time = { hour = 2, minute = 05 }     -- 2:05 AM
}
```

### Submersible Configuration

The script includes a configuration table for submersible builds. Here's an explanation of the configuration structure:

```lua
local submersible_build_config = {
    { min_rank = 1, max_rank = 14, build = "SSSS", plan_type = 3, unlock_plan = "31d90475-c6a1-4174-9f66-5ec2e1d01074", point_plan = "6e38ab7a-05c2-40b7-84a1-06f087704371" },
    { min_rank = 15, max_rank = 89, build = "SSUS", plan_type = 3, unlock_plan = "31d90475-c6a1-4174-9f66-5ec2e1d01074", point_plan = "6e38ab7a-05c2-40b7-84a1-06f087704371" },
    { min_rank = 90, max_rank = 120, build = "SSUC", plan_type = 4, unlock_plan = "31d90475-c6a1-4174-9f66-5ec2e1d01074", point_plan = "6e38ab7a-05c2-40b7-84a1-06f087704371" },
}
```

Each entry in the table represents a configuration for a specific rank range and contains:

- `min_rank`: Minimum rank value (inclusive)
- `max_rank`: Maximum rank value (inclusive)
- `build`: String representing the parts the submersibles should use
- `plan_type`: Vessel behavior (0 = Unlock, 1 = Redeploy, 2 = LevelUp, 3 = Unlock, 4 = Use plan)
- `unlock_plan`: GUID corresponding to the unlock plan, this plan uses `plan_type = 3`
- `point_plan`: GUID corresponding to the point plan, this plan uses `plan_type = 4`

Keep in mind that `plan_type` determines which plan is used, for values 0-2 no plan is used and is managed by AutoRetainer, value 3 uses `unlock_plan` and value 4 uses `point_plan` for each submersible. Therefore, if you are levelling a submersible using a plan, you would use `plan_type = 3` with an appropriate `unlock_plan` set, if you are farming you would use `plan_type = 4` with an appropriate `point_plan` set instead.

### Unlock Plans Configuration

Unlock plans are defined in the "Open Voyage Unlockable Planner" of AutoRetainer. Here's an example of how to configure them:

```lua
local unlock_plans = {
    {
        GUID = "579ba94d-4b73-4afe-9be1-999225e24af2",
        Name = "Overseer OJ Unlocker",
        ExcludedRoutes = { 101,100,99,98,97,96,95,93,92,91,90,89,88,80,81,82,83,84,86,85,87,79,78,77,76,75,74,72,71,70,69,68,67,66,65,64,63,62,61,60,59,58,57,56,55,54,29,24,23,22,21,18,17,16,13,12,11,9,8,7,6,4,3,102,103,104,105,48,36,51,50,46,45,44,41,40,35,53 },
        UnlockSubs = true
    },
    {
        GUID = "31d90475-c6a1-4174-9f66-5ec2e1d01074",
        Name = "Overseer Optimal Unlocker",
        ExcludedRoutes = { 3,6,13,22,23,24,29,36,40,41,45,44,46,48,50,51,54,56,58,60,63,64,66,67,68,69,71,80,86,90,92,103,105,107,109,110,112 },
        UnlockSubs = true
    },
    -- Add more unlock plans here as needed
}
```

### Point Plans Configuration

Point plans are defined in the "Open Voyage Route Planner" of AutoRetainer. Here's an example of how to configure them:

```lua
local point_plans = {
    {
        GUID = "6e38ab7a-05c2-40b7-84a1-06f087704371",
        Name = "Overseer OJ",
        Points = {15,10}
    },
    {
        GUID = "04fbb61c-5800-40e6-8c67-2467796bf80e",
        Name = "Overseer JORZ",
        Points = { 10,15,18,26 }
    },
    {
        GUID = "644317d3-34e1-44f3-a950-5fa5bdc8de04",
        Name = "Overseer MROJZ",
        Points = { 13,18,15,10,26 }
    },
    -- Add more point plans here as needed
}
```

Note: You cannot directly copy-paste these configurations. You'll need to manually copy each section to meet the required format.

## Submersible Behaviour

For levelling, all submersibles will follow the `unlock_plan` defined in the configuration, with the following vessel behaviour:
- The first submersible will use "Unlock + Spam one destination" until all four submersibles are unlocked, then switch to "Unlock + Pick max amount of destinations".
- The second, third, and fourth submersibles will use "Unlock + Pick max amount of destinations".
- Once each individual submersible reaches the configured rank value for farming, they will automatically switch to the `point_plan` you have set, while the remaining submersibles continue to level.

## Backup System

Overseer implements a robust backup system for your Auto Retainer configuration:

- Creates backups automatically
- Maintains a rolling set of up to 50 recent backups
- Ensures you can always revert to a previous stable configuration

## Changelog

- **1.5.4**: Updated distance thresholds for object interactions and fixed logging for submersible enabling
- **1.5.3**: Fixed inefficiencies for use_fc_buff option to not teleport more than needed
- **1.5.2**:
  - **New feature**: Automatically disables title screen if simple tweaks is installed.
  - **New feature**: Now automatically changes an AR setting so it waits on the main menu between retainers/submersibles.
  - **Bug fix**: Fixed a potential crash when checking if a character should buy ceruleum
  - **Improvement**: Switched from using a collection to disable AR to using `/xlenableplugin` and `/xldisableplugin` instead.
  - **WIP**: Started initial work on proper retainer support and added configurations that are not functional yet.
- **1.5.1**: Added a setting which allows you to set retainer active hours, so you can run retainers for only X hours a day if preferred. Also some potential improvements to stuck detection with minor code cleanup
- **1.5.0**: Rewrote a couple functions to make overseer work with the updated AutoRetainer config layout
- **1.4.7**: Fixed an issue where it would crash if character had no plot
- **1.4.6**: Added requested logic changes
- **1.4.5**: Some improvements and some fixes. Overseer will now wait 60 seconds after creating a new submersible to mitigate an issue it has with AR.
- **1.4.4**: Adjusted some code which was causing overseer to get stuck for too long when dealing with new submersibles
- **1.4.3**: Fixed an issue which has probably caused overseer to be inconsistent for months now, relating to how it calculates when to do part swaps. Also fixed or optimized many other smaller things. Likely the most stable release yet.
- **1.4.2**: Fixed another bug which could cause overseer to get stuck at the voyage panel
- **1.4.1**: Made a minor adjustment to potentially fix an issue where it causes AR to get stuck on the main menu for some
- **1.4.0**: Added a shutdown timer and made further consistency improvements, should now unstuck in locations where it had a chance to get stuck before. The script now also enables submersibles in enabled fcs that for some reason are disabled, which should also fix when the script fails to enable the submersible right after creation.
- **1.3.9**: Further improved the automatic fixing of submersibles
- **1.3.8**: Fixed a minor mistake causing 1.3.7 to not run for some
- **1.3.7**: Overseer should now automatically fix submersibles that have not been sent out after a part swap
- **1.3.6**: Further consistency improvements
- **1.3.5**: More attempts at fixing inconsistencies
- **1.3.4**: Potential fix to submersibles not being sent out after creation
- **1.3.3**: Fixed a bug caused by the previous update causing it to not part swap at all
- **1.3.2**: A lot of bugfixes
- **1.3.1**: More fixes related to plan assignment and inconsistent finalizing
- **1.3.0**: Added another check to try to remedy inconsistencies in part swapping.
- **1.2.9**: Attempted to further fix inconsistencies with part swapping. Also added a character exclusion list so you can exclude certain characters from submersible processing
- **1.2.8**: Various optimizations and fixed a couple more bugs related to part swapping and submersible vessel behavior
- **1.2.7**: Fixed an issue causing data not to be saved/read properly so the script took the wrong actions
- **1.2.6**: Reverted some optimization due to bugs
- **1.2.5**: Optimized some areas of the script and fixed a bug causing it to rarely fail when accessing the AR config file
- **1.2.4**: Submersible parts should now properly retry if they somehow failed to swap correctly
- **1.2.3**: Fixed the script rarely getting stuck
- **1.2.2**: Even more consistency improvements
- **1.2.1**: Consistency improvements
- **1.2.0**: Fixed a bug causing finalized subs to sometimes not be sent out.
- **1.1.9**: Reworked parts of the script to further address inconsistencies.
- **1.1.8**: Fixed an issue where characters without retainers did not swap parts properly. 
- **1.1.7**: Properly resolved the previous issue.  
- **1.1.6**: Fixed a bug where multi-tasking wouldn't reenable after completing all tasks.  
- **1.1.5**: Ensured multi-tasking is disabled correctly during retainer/submersible processing to prevent premature logout.  
- **1.1.4**: Additional fixes for submersible part swapping.  
- **1.1.3**: Fixed a bug preventing parts from being swapped correctly.  
- **1.1.2**: Potential fix for minor bugs related to submersible part swapping.  
- **1.1.1**: Fixed a logic issue causing submarines set to finalize to stay finalized.  
- **1.1.0**: Resolved a logic issue where parts wouldn’t swap even when they should.  
- **1.0.9**: Fixed a logic issue where the script misinterpreted available parts.  
- **1.0.8**: Changed default behavior to keep submarines on voyages during part swaps; added a toggle (default: off).  
- **1.0.7**: Fixed a bug causing the AR file to save incompletely.  
- **1.0.6**: Added support for retainer bells inside houses, not just workshops.  
- **1.0.5**: Improved part swap logic to ensure required parts are available; fixed loading issues with the entrust list.  
- **1.0.4**: Added better error handling and fixed a typo.  
- **1.0.3**: Simplified folder swapping further.  
- **1.0.2**: Made it easier to swap paths for multiple accounts using the same Windows user; moved backups and character data to the AutoRetainer directory.  
- **1.0.1**: Enhanced backup functionality and adjusted settings for consistency.  
- **1.0.0**: Initial release.
