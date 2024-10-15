# Overseer

Overseer is a script designed to improve your Auto Retainer experience. It provides automated backup, management and optimisation features for Auto Retainer, ensuring data integrity and enhancing overall efficiency.

There will potentially be bugs and weird things happening, please report any issues you encounter, this should be considered a script in the testing period, while all attempts have been made to ensure things run smoothly, there is no guarantee they will.

## Disclaimer

**IMPORTANT:** Overseer directly modifies the Auto Retainer configuration file. But it does keep constant backups for you to restore if anything happens. See [Backup](#backup-system) section for more info

By using Overseer, you acknowledge and accept the following:

1. Overseer's modifications will affect Auto Retainer's behaviour.
2. You are solely responsible for any issues, data loss, or unintended consequences arising from Overseer's use.
3. Auto Retainer and its developers are not liable for any problems caused by Overseer's modifications.
4. It is strongly recommended to manually backup your Auto Retainer configuration before first use of Overseer.
5. Use Overseer at your own risk. We cannot guarantee it won't conflict with Auto Retainer or other software.

By using Overseer, you agree to these terms and accept full responsibility for its use and any consequences thereof.

## Planned Features

- **Character & Retainer Management**: Streamline data handling for all your characters and retainers.
- **Venture Optimisation**: Dynamically adjust venture types based on retainer levels for maximum efficiency.
  - Venture type and plan management

## Key Features

- **Automated Backups**: Safeguard your Auto Retainer configuration with backup rotation (up to 50 backups).
- **Submersible Optimisation**:
  - Automatic creation and enabling of submersibles
  - Part swapping for optimal voyaging based on submersible rank and configuration
  - Route handling and plan management
  - Optimal vessel behaviour based on number of unlocked submersibles
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

Also please only use the retainer bell inside the workshop and not one placed inside the main house, it will interfere with how the plugin works for now.

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

Fine-tune Overseer's behaviour by adjusting these parameters in the script's configuration section:

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
| `force_return_subs_that_need_swap` | Will force return submarines to swap parts even if they're already sent out, if set to false it will wait until they're back |

You can also customise submersible builds and retainer venture types in their respective sections.

### Submersible Configuration

The script includes a configuration table for submersible builds. Here's an explanation of the configuration structure:

```lua
local submersible_build_config = {
    {min_rank = 1, max_rank = 14, build = "SSSS", plan_type = 3, unlock_plan = "31d90475-c6a1-4174-9f66-5ec2e1d01074", point_plan = "6e38ab7a-05c2-40b7-84a1-06f087704371"},
    {min_rank = 15, max_rank = 89, build = "SSUS", plan_type = 3, unlock_plan = "31d90475-c6a1-4174-9f66-5ec2e1d01074", point_plan = "6e38ab7a-05c2-40b7-84a1-06f087704371"},
    {min_rank = 90, max_rank = 120, build = "SSUC", plan_type = 4, unlock_plan = "31d90475-c6a1-4174-9f66-5ec2e1d01074", point_plan = "6e38ab7a-05c2-40b7-84a1-06f087704371"},
}
```

Each entry in the table represents a configuration for a specific rank range and contains:

- `min_rank`: Minimum rank value (inclusive)
- `max_rank`: Maximum rank value (inclusive)
- `build`: String representing the parts the submersibles should use
- `plan_type`: Vessel behavior (0 = Unlock, 1 = Redeploy, 2 = LevelUp, 3 = Unlock, 4 = Use plan)
- `unlock_plan`: GUID corresponding to the unlock plan
- `point_plan`: GUID corresponding to the point plan

### Unlock Plans Configuration

Unlock plans are defined in the "Open Voyage Unlockable Planner". Here's an example of how to configure them:

```lua
local unlock_plans = {
    {
        GUID = "579ba94d-4b73-4afe-9be1-999225e24af2",
        Name = "Overseer OJ Unlocker",
        ExcludedRoutes = {101,100,99,98,97,96,95,93,92,91,90,89,88,80,81,82,83,84,86,85,87,79,78,77,76,75,74,72,71,70,69,68,67,66,65,64,63,62,61,60,59,58,57,56,55,54,29,24,23,22,21,18,17,16,13,12,11,9,8,7,6,4,3,102,103,104,105,48,36,51,50,46,45,44,41,40,35,53},
        UnlockSubs = true
    },
    {
        GUID = "31d90475-c6a1-4174-9f66-5ec2e1d01074",
        Name = "Overseer Optimal Unlocker",
        ExcludedRoutes = {3,6,13,22,23,24,29,36,40,41,45,44,46,48,50,51,54,56,58,60,63,64,66,67,68,69,71,80,86,90,92,103,105,107,109,110,112},
        UnlockSubs = true
    },
    -- Add more unlock plans here as needed
}
```

### Point Plans Configuration

Point plans are defined in the "Open Voyage Route Planner". Here's an example of how to configure them:

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
        Points = {10,15,18,26}
    },
    {
        GUID = "644317d3-34e1-44f3-a950-5fa5bdc8de04",
        Name = "Overseer MROJZ",
        Points = {13,18,15,10,26}
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

By using Overseer, you agree to these terms and accept full responsibility for its use and any consequences thereof.

## Backup System

Overseer implements a robust backup system for your Auto Retainer configuration:

- Creates backups automatically
- Maintains a rolling set of up to 50 recent backups
- Ensures you can always revert to a previous stable configuration
