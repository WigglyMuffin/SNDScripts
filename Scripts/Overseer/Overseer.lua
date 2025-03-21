--[[
   ___                                    
  / _ \__   _____ _ __ ___  ___  ___ _ __ 
 | | | \ \ / / _ \ '__/ __|/ _ \/ _ \ '__|
 | |_| |\ V /  __/ |  \__ \  __/  __/ |   
  \___/  \_/ \___|_|  |___/\___|\___|_|   
                                          

####################
##    Version     ##
##     1.6.3      ##
####################

####################################################
##                  Description                   ##
####################################################

https://github.com/WigglyMuffin/SNDScripts

This script manages character, retainer and free company data for AutoRetainer.
It reads current existing data, updates it with new character information, and saves it back, preserving existing values.

Retainers are planned features, they are not currently supported.

####################################################
##                  Requirements                  ##
####################################################

-> AutoRetainer : https://love.puni.sh/ment.json
-> Deliveroo : https://plugins.carvel.li/
-> Lifestream : https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
-> Simple Tweaks Plugin : In the default first party dalamud repository
-> Something Need Doing (Expanded Edition) : https://puni.sh/api/repository/croizat
-> Teleporter : In the default first party dalamud repository
-> TextAdvance : https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
-> vnavmesh : https://puni.sh/api/repository/veyn

####################################################
##                    Settings                    ##
##################################################]]

local disable_gc_delivery = true                 -- Disables attempting any kind of gc delivery on falling under either venture or inventory slot limits
local venture_limit = 100                        -- Minimum value of ventures to trigger buying more ventures, requires Deliveroo to be correctly configured by doing GC deliveries
local inventory_slot_limit = 30                  -- Amount of inventory slots remaining before attempting a GC delivery to free up slots
local buy_ceruleum = false                       -- Will attempt to buy ceruleum fuel based on the settings below, if set to false the characters will never attempt to refuel (buy ceruleum fuel off players)
local ceruleum_limit = 1000                      -- Minimum value of ceruleum fuel to trigger buying ceruleum fuel
local ceruleum_buy_amount = 99999                -- Amount of ceruleum fuel to be purchased when ceruleum_limit is triggered, will buy up to configured amount when the buy is triggered
local fc_credits_to_keep = 13000                 -- How many credits to always keep, this limit will be ignored when buying FC buffs for GC deliveries
local use_fc_buff = false                        -- Will attempt to buy and use the seal sweetener buff when doing GC deliveries
local force_return_subs_that_need_swap = false   -- Will force return submarines to swap parts even if they're already sent out, if set to false it will wait until they're back

-- You can use this setting to have the script automatically shut down the game after X minutes, good if you want to reset the token every day for example
local enable_auto_shutdown = false               -- false to disable, true to enable
local shutdown_timer = 1440                      -- 24 hours in minutes

-- If you want to set your retainers to only run between x and x hours of the day you can use these settings to set a schedule of active retainer hours
-- Uses your computers time, just adjust the hours and minutes to your liking
local enable_retainer_schedule = false
local retainer_active_hours = {
    start_time = {hour = 17, minute = 00}, -- 5:00 PM
    end_time = {hour = 2, minute = 05}     -- 2:05 AM
}

-- Configuration for retainer levels and venture types
-- min_level = minimum level value, starts at 0
-- max_level = maximum level value
-- jobs = Any normal job abbreviation, like BTN, MIN and FSH. Can also use ALL to apply that plan to all jobs 
-- plan_to_use = The name of the plan you want to use, case sensitive. This will check against plans already saved in autoretainer first, so you can create them there and just have overseer use those.
-- !! This configuration is not supported currently !!
-- !! WIP !!
local retainer_level_config = {
    { min_level = 0, max_level = 9, jobs = {"MIN"}, mode = 0, plan_to_use = "Overseer Miner 1-10" },
    { min_level = 0, max_level = 9, jobs = {"BTN"}, mode = 0, plan_to_use = "Overseer Botanist 1-10" },
    { min_level = 10, max_level = 100, jobs = {"BTN", "MIN", "FSH"}, mode = 1, plan_to_use = "Overseer Quick Venture Spam" },
}

-- Overseer default venture plan, inserted and used by the default retainer plan
-- PlanCompleteBehavior:
-- 0:
-- 1:
-- 2:
-- !! This configuration is not supported currently !!
-- !! WIP !!
local retainer_venture_plans = {
    {
        Name = "Overseer Quick Venture Spam",
        List = {
            { ID = 395, Num = 9999 }
        },
        PlanCompleteBehavior = 1
    }
}

-- This option makes overseer attempt corrections on all characters every time it goes to the main menu
-- This means that if overseer finds a sub that isn't sent out it will attempt to send it out again
-- Or for example if a sub has the wrong parts and force return is enabled, it will go to that sub, bring it back, swap the part and send it out again
-- This might cause slowdowns in your submersible rotation if you've got a lot of fcs
local correct_between_characters = false

-- This setting will cause the script to attempt a correction once when the script starts
-- This is the recommended way to use correction since it will not cause any slowdowns later, and will still correct all your characters if you have a lot of submersibles that need changes
-- Only problem with this is that if something somehow goes wrong overseer will not be able to detect it
local correct_once_at_start_of_script = false

-- Configuration of submersible builds
-- min_rank = minimum rank value, starts at 1
-- max_rank = maximum rank value
-- build = parts the submersibles should use
-- plan_type = vessel behaviour. Options: 0 = Unlock, 1 = Redeploy, 2 = LevelUp, 3 = Unlock, 4 = Use plan
-- unlock_plan = GUID corresponding to the unlock_plan below
-- point_plan = GUID corresponding to the point_plan below
local submersible_build_config = {
    {min_rank = 1, max_rank = 14, build = "SSSS", plan_type = 3, unlock_plan = "31d90475-c6a1-4174-9f66-5ec2e1d01074", point_plan = "6e38ab7a-05c2-40b7-84a1-06f087704371"},
    {min_rank = 15, max_rank = 89, build = "SSUS", plan_type = 3, unlock_plan = "31d90475-c6a1-4174-9f66-5ec2e1d01074", point_plan = "6e38ab7a-05c2-40b7-84a1-06f087704371"},
    {min_rank = 90, max_rank = 120, build = "SSUC", plan_type = 4, unlock_plan = "31d90475-c6a1-4174-9f66-5ec2e1d01074", point_plan = "6e38ab7a-05c2-40b7-84a1-06f087704371"},
}

-- Unlock Plans Configuration
-- Input your unlock plan here located in "Open Voyage Unlockable Planner"
-- You cannot directly copy paste so you will need to manually copy paste each section so it meets the format required
-- If you already have submersibles, you should use your current plan otherwise you will waste a lot of time unlocking previous zones
local unlock_plans = {
    {   -- Pinned plan, good enough to unlock OJ but not optimal
        GUID = "579ba94d-4b73-4afe-9be1-999225e24af2",
        Name = "Overseer OJ Unlocker",
        ExcludedRoutes = { 101,100,99,98,97,96,95,93,92,91,90,89,88,80,81,82,83,84,86,85,87,79,78,77,76,75,74,72,71,70,69,68,67,66,65,64,63,62,61,60,59,58,57,56,55,54,29,24,23,22,21,17,16,11,9,6,3,102,103,104,105,48,36,51,50,46,45,44,41,40,35,53,107,108,106,109,110,111,112,113,114 },
        UnlockSubs = true
    },
    {   -- Overseer optimal, unlocks all salvage routes whilst being optimal (recommended)
        GUID = "31d90475-c6a1-4174-9f66-5ec2e1d01074",
        Name = "Overseer Optimal Unlocker",
        ExcludedRoutes = { 3,6,13,22,23,24,29,36,40,41,45,44,46,48,50,51,54,56,58,60,63,64,66,67,68,69,71,80,86,90,92,103,105,107,109,110,112 },
        UnlockSubs = true
    },
    -- Add more unlock plans here as needed
    -- {
    --     GUID = "another-guid-here",
    --     Name = "Another Unlock Plan",
    --     ExcludedRoutes = { 1,2,3,4,5 },
    --     UnlockSubs = true
    -- },
}

-- Point Plans Configuration
-- Input your point plan here located in "Open Voyage Route Planner"
-- You cannot directly copy paste so you will need to manually copy paste each section so it meets the format required
local point_plans = {
    {   -- OJ
        GUID = "6e38ab7a-05c2-40b7-84a1-06f087704371",
        Name = "Overseer OJ",
        Points = { 15,10 }
    },
    {   -- JORZ
        GUID = "04fbb61c-5800-40e6-8c67-2467796bf80e",
        Name = "Overseer JORZ",
        Points = { 10,15,18,26 }
    },
    {   -- MROJZ
        GUID = "644317d3-34e1-44f3-a950-5fa5bdc8de04",
        Name = "Overseer MROJZ",
        Points = { 13,18,15,10,26 }
    },
    -- Add more point plans here as needed
    -- {
    --     GUID = "another-guid-here",
    --     Name = "Another Point Plan",
    --     Points = { 1,2,3,4,5 }
    -- },
}

-- Submersible exclusions
-- Any character you add to this list will be excluded from any submersible actions like plan changing and part changing
local excluded_submersible_character = {
    "EXAMPLE CHARACTER@WORLD",
    "EXAMPLE CHARACTER2@WORLD"
}

--[[
You might want to edit these if you are running multiple accounts on the same windows user with different XIVLauncher config paths.

For example if you want to swap auto_retainer_config_path you'd point it directly like so
auto_retainer_config_path = "C:\\Users\\ff14lowres\\AppData\\Roaming\\XIVLauncher\\pluginConfigs\\AutoRetainer\\DefaultConfig.json"
]]

-- Point this to DefaultConfig.json inside this accounts AutoRetainer config folder
auto_retainer_config_path = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\AutoRetainer\\DefaultConfig.json"

-- Point this to wherever you want to store the data Overseer uses, this is also where backups are stored
overseer_folder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\AutoRetainer\\Overseer\\"

-- If you want to put the vac_functions and vac_lists file into a non default location you want to change this to wherever you put vac_functions
-- Generally this is not something you need to change
load_functions_file_location = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"

--[[################################################
##                  Script Start                  ##
##################################################]]

-- This is here to make sure that when the script gets started, it stops AR fast enough
ARAbortAllTasks()
ARSetMultiModeEnabled(false)

-- Load necessary libraries and set up paths
backup_folder = overseer_folder .. "\\AR Config Backups\\"

LoadFunctions = loadfile(load_functions_file_location)()
LoadFileCheck()
EnsureFolderExists(overseer_folder)
EnsureFolderExists(backup_folder)

-- Load JSON library from vac_functions
local json = CreateJSONLibrary()

-- Enable AutoRetainer just in case it's not enabled
if not HasPlugin("AutoRetainer") then
    yield("/xlenableplugin AutoRetainer")
    repeat
        Sleep(0.5)
    until HasPlugin("AutoRetainer") and type(ARGetInventoryFreeSlotCount()) == "number"
    yield("/ays")
end

-- Plugin checker
local required_plugins = {
    AutoRetainer = "4.4.4",
    Deliveroo = "6.6",
    Lifestream = "2.3.2.8",
    SimpleTweaksPlugin = "1.10.8.0",
    SomethingNeedDoing = "1.75",
    TeleporterPlugin = "2.0.2.5",
    TextAdvance = "3.2.4.4",
    vnavmesh = "0.0.0.54"
}

if not CheckPlugins(required_plugins) then
    return -- Stops script as plugins not available or versions don't match
end

if HasPlugin("YesAlready") then
    PauseYesAlready()
end

if HasPlugin("RotationSolver") then
    yield("/rsr off")
end

if HasPlugin("BossMod") or HasPlugin("BossModReborn") then
    yield("/vbmai off")
end

-- To enable debug logs
local debug = true
local debug_level = 1

LogInfo("Starting overseer...")

-- Globals
overseer_current_character = ""
overseer_char_data = {}
overseer_char_performed_gc_delivery = false
overseer_char_bought_ceruleum = false
overseer_char_processing_subs = false
overseer_char_processing_retainers = false
overseer_char_subs_excluded = false
overseer_inventory_data = {}
overseer_start_time = os.time()

-- Function which logs a lot to the xllog if debug is true 
function LogToInfo(debuglevel, ...)
    if debug and debuglevel <= debug_level then
        local args = {}
        for _, v in ipairs({...}) do
            table.insert(args, tostring(v))
        end
        LogInfo("[Overseer] " .. table.concat(args, " "))
    end
end

-- Function that just returns true or false if the script has passed the configured shutdown limit and needs a restart
local function ShutdownNeeded()
    if enable_auto_shutdown then
        local time_remaining = (overseer_start_time + shutdown_timer * 60) - os.time()
        if time_remaining > 0 then
            LogToInfo(1, "ShutdownNeeded: Time until shutdown: " .. time_remaining .. " seconds")
        else
            LogToInfo(1, "ShutdownNeeded: Shutdown timer expired")
        end
        return time_remaining <= 0
    end
    return false
end

-- Function to gracefully shutdown the game using AR's shutdown feature
local function AutoShutdown()
    ARAbortAllTasks()
    yield("/ays multi d")
    Sleep(0.5)

    while true do
        if IsPlayerAvailable() then
            yield("/shutdown")
            repeat
                Sleep(0.1)
            until IsAddonReady("SelectYesno")
            yield("/callback SelectYesno true 0")
            Sleep(5)
        end

        if IsAddonReady("_TitleLogo") then
            yield("/callback _TitleMenu true 12")
            Sleep(5)
        end

        if IsAddonReady("SelectOk") then
            yield("/callback SelectOk true 0")
            repeat
                Sleep(0.1)
            until IsAddonReady("SelectYesno") or IsPlayerAvailable()

            if not IsPlayerAvailable() and IsAddonReady("SelectYesno") then
                yield("/callback SelectYesno true 0")
            end
            Sleep(3)
        end

        if IsAddonReady("_CharaSelectReturn") then
            yield("/callback _CharaSelectReturn true 19")
            Sleep(5)
        end

        Sleep(1)
    end
end

-- Simple function to force ar to save to file, since for some reason closing/opening the ui does this
local function ForceARSave()
    if HasPlugin("AutoRetainer") then
        yield("/ays")
        yield("/ays")
        Sleep(0.211)
    end
end

-- Helper function to create config backups of DefaultConfig.json
local function CreateConfigBackup()
    local file_name = "DefaultConfig"
    local max_backups = 50
    local timestamp = os.time()
    local backup_interval = 3600 -- Every hour
    local last_backup_file = backup_folder .. "last_backup_timestamp.txt"

    -- Read the last backup timestamp
    local last_backup_timestamp = 0
    local last_backup_handle = io.open(last_backup_file, "r")
    if last_backup_handle then
        last_backup_timestamp = tonumber(last_backup_handle:read("*all")) or 0
        last_backup_handle:close()
    end

    -- Check if it's been at least 1 hour since the last backup
    if (timestamp - last_backup_timestamp) < backup_interval then
        -- Less than an hour since the last backup, do nothing
        return
    end

    -- Update the last backup timestamp
    local last_backup_handle = io.open(last_backup_file, "w")
    if last_backup_handle then
        last_backup_handle:write(tostring(timestamp))
        last_backup_handle:flush()
        last_backup_handle:close()
    end

    -- Create the backup file name with timestamp
    local backup_file = string.format("%s%s_backup_%d.json", backup_folder, file_name, timestamp)

    -- Read the original file to back up
    local source = io.open(auto_retainer_config_path, "rb")
    if not source then
        return
    end
    local content = source:read("*all")
    source:close()

    -- Write the backup file
    local dest = io.open(backup_file, "wb")
    if not dest then
        return
    end
    dest:write(content)
    dest:flush()
    dest:close()

    -- Log the new backup
    local log_file_path = backup_folder .. "backup_log.txt"
    local log_file = io.open(log_file_path, "a")
    if log_file then
        log_file:write(backup_file .. "\n")
        log_file:flush()
        log_file:close()
    end

    -- Read the existing backups from the log file
    local backups = {}
    local log_file_read = io.open(log_file_path, "r")
    if log_file_read then
        for line in log_file_read:lines() do
            table.insert(backups, line)
        end
        log_file_read:close()
    end

    -- Check if we exceed the maximum number of backups
    if #backups > max_backups then
        -- Sort backups by unix timestamp
        table.sort(backups, function(a, b)
            return tonumber(a:match("_(%d+)%.json$")) < tonumber(b:match("_(%d+)%.json$"))
        end)

        -- Delete the oldest backups until we're under the backup limit
        while #backups > max_backups do
            os.remove(backups[1]) -- Delete the oldest backup file
            table.remove(backups, 1) -- Remove from the list
        end

        -- Rewrite the log file without the deleted backups
        local log_file_write = io.open(log_file_path, "w")
        for _, backup in ipairs(backups) do
            log_file_write:write(backup .. "\n")
        end
        log_file_write:flush()
        log_file_write:close()
    end
end

-- Helper function to find part abbreviation
local function FindPartAbbreviation(part_name)
    if not part_name then return "" end
    for _, part in ipairs(Submersible_Part_List) do
        if part.PartName == part_name then
            return part.PartAbbreviation
        end
    end

    -- If no match found, try to infer the abbreviation from the class name
    local class = part_name:match("(%a+)-class")
    if class then
        return string.upper(class:sub(1, 1))
    end

    LogToInfo(1, string.format("FindPartAbbreviation: Unable to find or infer abbreviation for part %s", part_name))
    return "?"  -- Return '?' if no abbreviation can be determined
end

-- Helper function to generate build string
local function GenerateBuildString(part1, part2, part3, part4)
    local parts = {part1, part2, part3, part4}
    local abbrs = {}
    local modified_count = 0

    for i, part_id in ipairs(parts) do
        local part_name = FindItemName(tonumber(part_id))
        if not part_name then
            LogToInfo(1, string.format("GenerateBuildString: Unable to find name for part ID %s", tostring(part_id)))
            abbrs[i] = "?"
        else
            local abbr = FindPartAbbreviation(part_name)
            abbrs[i] = abbr
            if part_name:find("Modified") then
                modified_count = modified_count + 1
            end
        end
    end

    local build_string = table.concat(abbrs)

    if modified_count == 4 then
        -- All parts are modified, add "++" at the end
        build_string = build_string .. "++"
    elseif modified_count > 0 then
        -- Some parts are modified, add "+" after each modified part
        build_string = build_string:gsub("([SUWCY])", "%1+")
    end

    return build_string
end

-- Helper function to validate configuration
local function IsValidConfiguration(config)
    return config.min_rank and config.max_rank and config.build and 
           config.plan_type and config.unlock_plan and config.point_plan
end

-- Helper function to get unlock plan by GUID
local function GetUnlockPlanByGUID(guid)
    if not guid then
        LogToInfo(1, "GetUnlockPlanByGUID: No GUID provided")
        return nil
    end

    -- Ensure unlock_plans exists and is a table
    if not unlock_plans or type(unlock_plans) ~= "table" then
        LogToInfo(1, "GetUnlockPlanByGUID: unlock_plans is not properly initialized")
        return nil
    end

    for _, plan in ipairs(unlock_plans) do
        if plan.GUID == guid then
            LogToInfo(2, string.format("GetUnlockPlanByGUID: Found plan '%s' for GUID %s", plan.Name, guid))
            return plan
        end
    end

    LogToInfo(1, string.format("GetUnlockPlanByGUID: No plan found for GUID %s", guid))
    return nil
end

-- Helper function to get point plan by GUID
local function GetPointPlanByGUID(guid)
    if not guid then
        LogToInfo(1, "GetPointPlanByGUID: No GUID provided")
        return nil
    end

    -- Ensure point_plans exists and is a table
    if not point_plans or type(point_plans) ~= "table" then
        LogToInfo(1, "GetPointPlanByGUID: point_plans is not properly initialized")
        return nil
    end

    for _, plan in ipairs(point_plans) do
        if plan.GUID == guid then
            LogToInfo(2, string.format("GetPointPlanByGUID: Found plan '%s' for GUID %s", plan.Name, guid))
            return plan
        end
    end

    LogToInfo(1, string.format("GetPointPlanByGUID: No plan found for GUID %s", guid))
    return nil
end

-- Helper function to verify plans exist
local function VerifyPlans(config)
    local unlock_plan = GetUnlockPlanByGUID(config.unlock_plan)
    local point_plan = GetPointPlanByGUID(config.point_plan)
    return unlock_plan and point_plan
end

-- Helper function to validate build string format
local function IsValidBuildString(build)
    return build:match("^[SUWCY+]+$") ~= nil
end

-- Helper function to process configuration for rank
local function ProcessConfigurationForRank(config, rank)
    if not IsValidConfiguration(config) then
        LogToInfo(1, "Invalid configuration found - missing required fields")
        return nil
    end

    if not VerifyPlans(config) then
        LogToInfo(1, "Invalid configuration - missing referenced plans")
        return nil
    end

    if not IsValidBuildString(config.build) then
        LogToInfo(1, string.format("Invalid build string format: %s", config.build))
        return nil
    end

    LogToInfo(2, string.format("Found matching config - min: %d, max: %d, build: %s", 
        config.min_rank, config.max_rank, config.build))

    return config
end

-- Helper function to get optimal build for submersible rank
local function GetOptimalBuildForRank(rank)
    -- Input validation
    if not rank or type(rank) ~= "number" then
        LogToInfo(1, "GetOptimalBuildForRank: Invalid rank provided")
        return "", 0, "00000000-0000-0000-0000-000000000000", "00000000-0000-0000-0000-000000000000", 0, 0
    end

    LogToInfo(2, string.format("GetOptimalBuildForRank: Finding optimal build for rank %d", rank))

    -- Find all valid configurations for this rank
    local valid_configs = {}
    for _, config in ipairs(submersible_build_config) do
        if rank >= config.min_rank and rank <= config.max_rank then
            table.insert(valid_configs, config)
        end
    end

    -- Sort valid configs by min_rank in descending order
    -- This ensures we pick the most appropriate config for higher ranks
    table.sort(valid_configs, function(a, b)
        return a.min_rank > b.min_rank
    end)

    -- Take the first (highest min_rank) config that matches
    if #valid_configs > 0 then
        local best_config = valid_configs[1]
        local processed_config = ProcessConfigurationForRank(best_config, rank)
        if processed_config then
            LogToInfo(2, string.format("GetOptimalBuildForRank: Selected config - min_rank: %d, max_rank: %d, build: %s", 
                best_config.min_rank, best_config.max_rank, best_config.build))
            return processed_config.build, 
                   processed_config.plan_type, 
                   processed_config.unlock_plan, 
                   processed_config.point_plan, 
                   processed_config.min_rank, 
                   processed_config.max_rank
        end
    end

    LogToInfo(1, "GetOptimalBuildForRank: No valid configuration found")
    return "", 0, "00000000-0000-0000-0000-000000000000", "00000000-0000-0000-0000-000000000000", 0, 0
end

-- Helper function to check if a character is in the exclusion list
local function InExclusionList(character_name)
    if not character_name then
        return false
    end
    
    for _, excluded_character in ipairs(excluded_submersible_character) do
        if string.lower(excluded_character) == string.lower(character_name) then
            LogToInfo(2, string.format("InExclusionList: Character %s is in exclusion list", character_name))
            return true
        end
    end
    
    LogToInfo(2, string.format("InExclusionList: Character %s is not in exclusion list", character_name))
    return false
end

-- Helper function to calculate guaranteed experience based on route
local function CalculateGuaranteedExp(decoded_points)
    local total_exp = 0
    for _, point in ipairs(decoded_points) do
        if point == 0 then break end -- Stop at the first 0
        for _, zone in ipairs(Submersible_Zone_List) do
            if tonumber(zone.Key) == point then
                total_exp = total_exp + zone.ExpReward
                break
            end
        end
    end
    return math.floor(total_exp)
end

-- Helper function to calculate bonus experience based on route
local function EstimateMaxBonusExp(base_exp)
    -- This is a simplified estimation, because the actual relies on items brought back based on breakpoints
    return base_exp -- Was originally 0.25 of the base_xp, but since we realized that the max possible bonus is 100% we just return the same value and assume based on that. Really doesn't need to be a function anymore.
end

-- Helper function to get optimal venture for retainer level
local function GetOptimalVentureType(level)
    for _, config in ipairs(retainer_level_config) do
        if level >= config.min_level and level <= config.max_level then
            return config.venture_type, config.saved_plan
        end
    end
    return nil, nil  -- Return nil if no matching range found
end

-- Base64 decoding function
local base64_chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

local function DecodeBase64(data)
    data = string.gsub(data, '[^'..base64_chars..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(base64_chars:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- Helper function to decode base64 for submersible points
local function DecodeSubmersiblePoints(base64_string)
    local decoded = DecodeBase64(base64_string)
    local bytes = {string.byte(decoded, 1, 5)}
    return bytes
end

-- Helper function to convert decoded points into route letters
local function DecodePointsToRoute(decoded_points)
    local route = ""
    for _, point in ipairs(decoded_points) do
        if point == 0 then break end -- Stop at the first 0
        for _, zone in ipairs(Submersible_Zone_List) do
            if tonumber(zone.Key) == point then
                route = route .. zone.Letter
                break
            end
        end
    end
    return route
end

-- Helper function to calculate the next submersible rank based on experience gained
local function GetNextSubmersibleRanks(current_rank, current_exp, guaranteed_exp, potential_bonus_exp)
    local total_exp = current_exp + guaranteed_exp + potential_bonus_exp
    local final_rank = current_rank
    local remaining_exp = total_exp

    local current_index = nil
    for i, rank_data in ipairs(Submersible_Rank_List) do
        if rank_data.Level == current_rank then
            current_index = i
            break
        end
    end

    if not current_index then
        LogToInfo(1,"GetNextSubmersibleRanks: Current rank not found in Submersible_Rank_List")
        return 0, 0
    end

    for i = current_index, #Submersible_Rank_List - 1 do
        local next_rank_data = Submersible_Rank_List[i]
        if remaining_exp >= next_rank_data.ExpToNext then
            final_rank = final_rank + 1
            remaining_exp = remaining_exp - next_rank_data.ExpToNext
        else
            break
        end
    end
    -- LogToInfo(1, "GetNextSubmersibleRanks: "..current_rank.." "..current_exp.." "..guaranteed_exp.." "..potential_bonus_exp)
    -- LogToInfo(1, "GetNextSubmersibleRanks: "..final_rank.." "..remaining_exp)
    return final_rank, remaining_exp
end

-- Function to create a default Free Company entry
local function CreateDefaultFreeCompany(server)
    return {
        id = "0",
        name = "",
        server = server,
        rank = 0,
        credits = 0,
        gc_id = 0,
        gc_rank = 0,
        owner = {
            name = "",
            id = ""
        }
    }
end

-- Function to create a default character entry
local function CreateDefaultCharacter(name, server)
    return {
        id = "",
        name = name,
        server = server,
        retainers_enabled = false,
        free_company = CreateDefaultFreeCompany(server),
        ceruleum = 0,
        repair_kits = 0,
        ventures = 0,
        seals = 0,
        gc = "",
        inventory_space = 0,
        venture_coffers = 0,
        gil = 0,
        retainers = {},
        submersibles = {}
    }
end

-- Function to create a default retainer entry
local function CreateDefaultRetainer()
    return {
        id = "",
        name = "",
        enabled = "",
        job = "",
        experience = 0,
        level = 0,
        gil = 0,
        has_venture = false,
        linked_venture_plan = "",
        venture_plan_index = 0,
        ilvl = 0,
        gathering = 0,
        perception = 0,
        entrust_plan = "00000000-0000-0000-0000-000000000000",
        current_venture_type = "",
        optimal_venture_type = "",
        venture_needs_change = false,
        venture_ends_at = 0
    }
end

-- Function to create a default submersible entry
local function CreateDefaultSubmersible(number, has_valid_fc)
    return {
        number = number,
        name = "",
        experience = 0,
        rank = 0,
        rank_after_levelup = 0,
        rank_needed_for_next_swap = 0,
        min_rank_needed_for_next_swap = 0,
        build = "",
        optimal_build = "",
        future_optimal_build = "",
        optimal_plan_type = 0,
        future_optimal_plan_type = 0,
        optimal_plan = "",
        future_optimal_plan = "",
        optimal_plan_name = "",
        future_optimal_plan_name = "",
        build_needs_change = false,
        plan_needs_change = false,
        build_needs_change_after_levelup = false,
        plan_needs_change_after_levelup = false,
        part1 = "",
        part2 = "",
        part3 = "",
        part4 = "",
        current_exp = 0,
        next_level_exp = 0,
        vessel_behavior = 0,
        unlock_mode = 0,
        optimal_unlock_mode = 0,
        enabled = false,
        selected_unlock_plan = "00000000-0000-0000-0000-000000000000",
        selected_point_plan = "00000000-0000-0000-0000-000000000000",
        unlocked = (number == 1 and has_valid_fc),
        decoded_points = {0, 0, 0, 0, 0},
        route = "",
        return_time = 0,
        guaranteed_exp = 0,
        potential_bonus_exp = 0,
        will_level_up = false,
        potential_level_up = false,
        exp_after_levelup = 0,
        points = ""
    }
end

-- Function to update character list and global plans
local function UpdateFromAutoRetainerConfig()
    local file, err = io.open(auto_retainer_config_path, "r")
    if not file then
        Echo("UpdateFromAutoRetainerConfig: Unable to open DefaultConfig.json: " .. tostring(err))
        LogToInfo(1, "UpdateFromAutoRetainerConfig: Unable to open DefaultConfig.json: " .. tostring(err))
        return nil
    end

    local content = file:read("*all")
    file:close()

    -- Remove BOM if present
    if content:sub(1, 3) == string.char(0xEF, 0xBB, 0xBF) then
        content = content:sub(4)
        LogToInfo(1, "UpdateFromAutoRetainerConfig: BOM removed from the content")
    end

    local success, config = pcall(json.decode, content)
    if not success or not config then
        Echo("UpdateFromAutoRetainerConfig: Error parsing JSON: " .. tostring(config))
        LogToInfo(1, "UpdateFromAutoRetainerConfig: Error parsing JSON: " .. tostring(config))
        return nil
    end

    local ar_character_data = {}
    local global_data = {
        saved_plans = {},
        submarine_unlock_plans = {},
        submarine_point_plans = {},
        unoptimal_vessel_configurations = {},
        entrust_plans = {}
    }

    -- Process global plans
    for _, plan in ipairs(config.SavedPlans or {}) do
        table.insert(global_data.saved_plans, {
            name = plan.Name,
            list = plan.List,
            plan_complete_behavior = plan.PlanCompleteBehavior
        })
    end

    for _, plan in ipairs(config.SubmarineUnlockPlans or {}) do
        table.insert(global_data.submarine_unlock_plans, {
            guid = plan.GUID,
            name = plan.Name,
            excluded_routes = plan.ExcludedRoutes,
            unlock_subs = plan.UnlockSubs
        })
    end

    for _, plan in ipairs(config.SubmarinePointPlans or {}) do
        table.insert(global_data.submarine_point_plans, {
            guid = plan.GUID,
            name = plan.Name,
            points = plan.Points
        })
    end

    for _, config in ipairs(config.UnoptimalVesselConfigurations or {}) do
        table.insert(global_data.unoptimal_vessel_configurations, {
            min_rank = config.MinRank,
            max_rank = config.MaxRank,
            configurations = config.Configurations,
            configurations_invert = config.ConfigurationsInvert
        })
    end

    for _, plan in ipairs(config.EntrustPlans or {}) do
        table.insert(global_data.entrust_plans, {
            guid = plan.GUID,
            name = plan.Name,
            list = plan.List
        })
    end

    local fc_data = {}
    -- First pass: Process FCData
    for fcid, fc_info in pairs(config.FCData or {}) do
        local fc_id_str = tostring(fcid)
        fc_data[fc_id_str] = {
            id = fc_id_str,
            name = fc_info.Name or "",
            credits = fc_info.FCPoints or 0,
            gc_id = fc_info.gc_id,
            gc_rank = fc_info.gc_rank,
            holder_chara = tostring(fc_info.HolderChara or 0)
        }
        LogToInfo(2, string.format("UpdateFromAutoRetainerConfig: Processed FC: ID=%s, Name=%s, Holder=%s", fc_id_str, fc_info.Name, fc_data[fc_id_str].holder_chara))
    end

    local function insert_logged_in_player_gc(char)
        if string.lower(char) == string.lower(overseer_current_character) then
            return GetPlayerGC()
        else
            return false
        end
    end

    local function insert_logged_in_player_fc_id(char)
        if string.lower(char) == string.lower(overseer_current_character) then
            return GetFCGCID()
        else
            return false
        end
    end

    local function insert_logged_in_player_fc_rank(char)
        if string.lower(char) == string.lower(overseer_current_character) then
            return GetFCRank()
        else
            return false
        end
    end

    -- Second pass: Process OfflineData
    for _, chara_data in ipairs(config.OfflineData or {}) do
        local chara_key = chara_data.Name .. "@" .. chara_data.World
        local chara = CreateDefaultCharacter(chara_data.Name, chara_data.World)

        chara.id = tostring(chara_data.CID)
        chara.name = chara_data.Name
        chara.server = chara_data.World
        chara.retainers_enabled = chara_data.Enabled or false
        chara.ceruleum = chara_data.Ceruleum or 0
        chara.repair_kits = chara_data.RepairKits or 0
        chara.ventures = chara_data.Ventures or 0
        chara.seals = chara_data.Seals or 0
        chara.gc = insert_logged_in_player_gc(chara_key) or 0
        chara.inventory_space = chara_data.InventorySpace or 0
        chara.venture_coffers = chara_data.VentureCoffers or 0
        chara.gil = chara_data.Gil or 0

        -- Always set the free_company owner to the character's own name and id
        chara.free_company.owner.id = chara.id
        chara.free_company.owner.name = chara.name

        -- Assign FC data based on character's ID matching HolderChara
        local fc_found = false
        for fc_id, fc in pairs(fc_data) do
            if fc.holder_chara == chara.id then
                chara.free_company.id = fc.id
                chara.free_company.name = fc.name
                chara.free_company.credits = fc.credits
                chara.free_company.gc_id = insert_logged_in_player_fc_id(chara_key) or 0
                chara.free_company.gc_rank = insert_logged_in_player_fc_rank(chara_key) or 0
                LogToInfo(2, string.format("UpdateFromAutoRetainerConfig: FC found for character %s: ID=%s, Name=%s", chara.name, fc.id, fc.name))
                fc_found = true
                break
            end
        end

        -- If no FC was found or FC id is "0", ensure default values are set
        if not fc_found or chara.free_company.id == "0" then
            chara.free_company = CreateDefaultFreeCompany(chara.server)
            chara.free_company.owner.id = chara.id
            chara.free_company.owner.name = chara.name
            LogToInfo(2, string.format("UpdateFromAutoRetainerConfig: No FC found for character %s", chara.name))
        end

        local function IsRetainerEnabled(retainer)
            local char_id = tostring(chara_data.CID)
            local selected_retainers = config.SelectedRetainers[char_id]
            if not selected_retainers then return false end
            for _, name in ipairs(selected_retainers) do
                if retainer == name then
                    return true
                end
            end
            return false
        end

        -- Process RetainerData
        chara.retainers = {}
        local additional_data = config.AdditionalData or {}
        for _, retainer in ipairs(chara_data.RetainerData or {}) do
            local retainer_id = tostring(retainer.RetainerID or "")
            local retainer_name = retainer.Name or ""
            local additional_retainer_data = additional_data[retainer_id .. " " .. retainer_name] or {}

            local retainer_entry = CreateDefaultRetainer()
            retainer_entry.id = retainer_id
            retainer_entry.name = retainer_name
            retainer_entry.enabled = IsRetainerEnabled(retainer_name)
            retainer_entry.job = tostring(retainer.Job or 0)
            retainer_entry.experience = retainer.Experience or 0
            retainer_entry.level = retainer.Level or 0
            retainer_entry.gil = retainer.Gil or 0
            retainer_entry.has_venture = retainer.HasVenture or false
            retainer_entry.linked_venture_plan = additional_retainer_data.LinkedVenturePlan or ""
            retainer_entry.venture_plan_index = additional_retainer_data.VenturePlanIndex or 0
            retainer_entry.ilvl = additional_retainer_data.Ilvl or 0
            retainer_entry.gathering = additional_retainer_data.Gathering or 0
            retainer_entry.perception = additional_retainer_data.Perception or 0
            retainer_entry.entrust_plan = additional_retainer_data.EntrustPlan or "00000000-0000-0000-0000-000000000000"
            retainer_entry.venture_ends_at = retainer.VentureEndsAt or 0

            -- Determine optimal venture type and if change is needed
            retainer_entry.current_venture_type = additional_retainer_data.CurrentVentureType or ""
            retainer_entry.optimal_venture_type, retainer_entry.optimal_saved_plan = GetOptimalVentureType(retainer_entry.level)
            retainer_entry.venture_needs_change = (retainer_entry.current_venture_type ~= retainer_entry.optimal_venture_type)

            table.insert(chara.retainers, retainer_entry)

            LogToInfo(2, string.format("UpdateFromAutoRetainerConfig: Processed retainer: %s (ID: %s)", retainer_name, retainer_id))
            LogToInfo(2, string.format("UpdateFromAutoRetainerConfig: Current venture type: %s", retainer_entry.current_venture_type))
            LogToInfo(2, string.format("UpdateFromAutoRetainerConfig: Optimal venture type: %s", retainer_entry.optimal_venture_type))
            LogToInfo(2, string.format("UpdateFromAutoRetainerConfig: Venture needs change: %s", tostring(retainer_entry.venture_needs_change)))
        end

        -- Process OfflineSubmarineData and AdditionalSubmarineData only if character has a valid FC
        chara.submersibles = {}
        local has_valid_fc = chara.free_company.id ~= "0" and chara.free_company.name ~= ""
        if has_valid_fc then
            local num_sub_slots = chara_data.NumSubSlots or 0
            local enabled_submersibles_data = chara_data.EnabledSubs or {}
            for i = 1, 4 do
                local submersible_data = chara_data.OfflineSubmarineData and chara_data.OfflineSubmarineData[i] or {}
                local add_submersible_data = chara_data.AdditionalSubmarineData and chara_data.AdditionalSubmarineData[submersible_data.Name or ("Submersible-" .. i)] or {}

                local function IsSubmersibleEnabled(submersible_name)
                    if not submersible_name or type(submersible_name) ~= "string" then
                        return false
                    end

                    if not enabled_submersibles_data or type(enabled_submersibles_data) ~= "table" then
                        return false
                    end

                    for _, enabled_sub in ipairs(enabled_submersibles_data) do
                        if enabled_sub == submersible_name then
                            return true
                        end
                    end

                    return false
                end

                local function ReturnSubmersiblePoints()
                    if submersible_data.ReturnTime == 0 then
                        return ""
                    else
                        return add_submersible_data.Points or ""
                    end
                end

                -- Function to determine what the best unlock mode to use is
                local function GetOptimalUnlockMode(sub_number, rank)
                    if type(sub_number) ~= "number" or type(rank) ~= "number" or type(num_sub_slots) ~= "number" then
                        return 2
                    end

                    local optimal_build, optimal_plan_type, optimal_unlock_plan_guid, optimal_point_plan_guid = GetOptimalBuildForRank(rank)

                    optimal_plan_type = optimal_plan_type or 0

                    if sub_number == 1 and optimal_plan_type == 3 and num_sub_slots < 4 then
                        return 1
                    end
                    if optimal_plan_type == 3 then
                        local sub_points = ReturnSubmersiblePoints()
                        local sub_points_decoded = DecodeSubmersiblePoints(sub_points) or {0, 0, 0, 0, 0}

                        for _, point in ipairs(sub_points_decoded) do
                            if point > 34 then
                                return 2
                            end
                        end
                    end
                    return 1
                end

                -- Function to check if a plan needs change or not
                local function GetIfPlanNeedsChange(sub_unlock_plan, sub_point_plan, sub_optimal_plan, sub_plan_type)
                    sub_plan_type = tonumber(sub_plan_type) or 0
                    if sub_plan_type == 4 then
                        return (sub_point_plan or "") ~= (sub_optimal_plan or "")
                    else
                        return (sub_unlock_plan or "") ~= (sub_optimal_plan or "")
                    end
                end

                local submersible = CreateDefaultSubmersible(i, has_valid_fc)
                if i == 1 or i <= num_sub_slots then
                    submersible.unlocked = true
                end
                if submersible_data.Name then
                    submersible.name = submersible_data.Name
                    submersible.experience = add_submersible_data.CurrentExp or 0
                    submersible.rank = add_submersible_data.Level or 0
                    submersible.part1 = tostring(add_submersible_data.Part1 or "")
                    submersible.part2 = tostring(add_submersible_data.Part2 or "")
                    submersible.part3 = tostring(add_submersible_data.Part3 or "")
                    submersible.part4 = tostring(add_submersible_data.Part4 or "")
                    submersible.current_exp = math.floor(add_submersible_data.CurrentExp or 0)
                    submersible.next_level_exp = math.floor(add_submersible_data.NextLevelExp or 0)
                    submersible.vessel_behavior = add_submersible_data.VesselBehavior or 0
                    submersible.unlock_mode = add_submersible_data.UnlockMode or 0
                    submersible.optimal_unlock_mode = GetOptimalUnlockMode(submersible.number, submersible.rank)
                    submersible.enabled = IsSubmersibleEnabled(submersible_data.Name)
                    submersible.selected_unlock_plan = add_submersible_data.SelectedUnlockPlan or "00000000-0000-0000-0000-000000000000"
                    submersible.selected_point_plan = add_submersible_data.SelectedPointPlan or "00000000-0000-0000-0000-000000000000"
                    submersible.points = ReturnSubmersiblePoints()
                    submersible.decoded_points = DecodeSubmersiblePoints(submersible.points) or {0, 0, 0, 0, 0}
                    submersible.route = DecodePointsToRoute(submersible.decoded_points)
                    submersible.return_time = submersible_data.ReturnTime

                    -- Calculate guaranteed and potential bonus exp
                    submersible.guaranteed_exp = CalculateGuaranteedExp(submersible.decoded_points)
                    submersible.potential_bonus_exp = EstimateMaxBonusExp(submersible.guaranteed_exp)

                    -- Determine if submersible can level up or potentially level up
                    submersible.will_level_up = (submersible.current_exp + submersible.guaranteed_exp >= submersible.next_level_exp)
                    submersible.potential_level_up = (submersible.current_exp + submersible.guaranteed_exp + submersible.potential_bonus_exp >= submersible.next_level_exp)

                    -- Calculate rank_after_levelup
                    submersible.rank_after_levelup, submersible.exp_after_levelup = GetNextSubmersibleRanks(
                        submersible.rank,
                        submersible.current_exp,
                        submersible.guaranteed_exp,
                        submersible.potential_bonus_exp
                    )
                    -- Generate build string and check for optimal build
                    submersible.build = GenerateBuildString(submersible.part1, submersible.part2, submersible.part3, submersible.part4)

                    -- Determine optimal configurations based on the higher of current rank and rank_after_levelup
                    local optimal_build, optimal_plan_type, optimal_unlock_plan_guid, optimal_point_plan_guid, optimal_min_rank, optimal_max_rank = GetOptimalBuildForRank(submersible.rank)
                    -- Determine future optimals
                    local future_optimal_build, future_optimal_plan_type, future_optimal_unlock_plan_guid, future_optimal_point_plan_guid, future_optimal_min_rank, future_optimal_max_rank = GetOptimalBuildForRank(submersible.rank_after_levelup)

                    submersible.rank_needed_for_next_swap = optimal_max_rank + 1 or 0
                    submersible.min_rank_needed_for_next_swap = optimal_min_rank or 0
                    submersible.optimal_build = optimal_build or ""
                    submersible.optimal_plan_type = optimal_plan_type or 0
                    submersible.build_needs_change = (optimal_build ~= nil and submersible.build ~= optimal_build)

                    -- Determine optimal plan
                    if optimal_plan_type == 3 then
                        local unlock_plan = GetUnlockPlanByGUID(optimal_unlock_plan_guid)
                        submersible.optimal_plan = unlock_plan and unlock_plan.GUID or ""
                        submersible.optimal_plan_name = unlock_plan and unlock_plan.Name or ""
                        submersible.plan_needs_change = GetIfPlanNeedsChange(submersible.selected_unlock_plan, submersible.selected_point_plan, submersible.optimal_plan, submersible.optimal_plan_type)
                    elseif optimal_plan_type == 4 then
                        local point_plan = GetPointPlanByGUID(optimal_point_plan_guid)
                        submersible.optimal_plan = point_plan and point_plan.GUID or ""
                        submersible.optimal_plan_name = point_plan and point_plan.Name or ""
                        submersible.plan_needs_change = GetIfPlanNeedsChange(submersible.selected_unlock_plan, submersible.selected_point_plan, submersible.optimal_plan, submersible.optimal_plan_type)
                    else
                        submersible.optimal_plan = ""
                        submersible.optimal_plan_name = ""
                        submersible.plan_needs_change = false
                    end

                    -- Check if there's a different future optimal build
                    if submersible.rank_after_levelup > submersible.rank then
                        if future_optimal_build ~= submersible.optimal_build then
                            submersible.future_optimal_build = future_optimal_build or ""
                            submersible.future_optimal_plan_type = future_optimal_plan_type or 0
                            submersible.build_needs_change_after_levelup = (future_optimal_build ~= nil and submersible.build ~= future_optimal_build)

                            -- Determine future optimal plan
                            if future_optimal_plan_type == 3 then
                                local future_unlock_plan = GetUnlockPlanByGUID(future_optimal_unlock_plan_guid)
                                submersible.future_optimal_plan = future_unlock_plan and future_unlock_plan.GUID or ""
                                submersible.future_optimal_plan_name = future_unlock_plan and future_unlock_plan.Name or ""
                                submersible.plan_needs_change_after_levelup = GetIfPlanNeedsChange(submersible.selected_unlock_plan, submersible.selected_point_plan, submersible.future_optimal_plan, submersible.future_optimal_plan_type)
                            elseif future_optimal_plan_type == 4 then
                                local future_point_plan = GetPointPlanByGUID(future_optimal_point_plan_guid)
                                submersible.future_optimal_plan = future_point_plan and future_point_plan.GUID or ""
                                submersible.future_optimal_plan_name = future_point_plan and future_point_plan.Name or ""
                                submersible.plan_needs_change_after_levelup = GetIfPlanNeedsChange(submersible.selected_unlock_plan, submersible.selected_point_plan, submersible.future_optimal_plan, submersible.future_optimal_plan_type)
                            else
                                submersible.future_optimal_plan = ""
                                submersible.future_optimal_plan_name = ""
                                submersible.plan_needs_change_after_levelup = false
                            end
                        else
                            -- If future optimal is the same as current optimal, clear future fields
                            submersible.future_optimal_build = ""
                            submersible.future_optimal_plan_type = 0
                            submersible.future_optimal_plan = ""
                            submersible.future_optimal_plan_name = ""
                            submersible.build_needs_change_after_levelup = false
                            submersible.plan_needs_change_after_levelup = false
                        end
                    else
                        -- If no level up, clear future fields
                        submersible.future_optimal_build = ""
                        submersible.future_optimal_plan_type = 0
                        submersible.future_optimal_plan = ""
                        submersible.future_optimal_plan_name = ""
                        submersible.build_needs_change_after_levelup = false
                        submersible.plan_needs_change_after_levelup = false
                    end

                    LogToInfo(2, string.format("UpdateFromAutoRetainerConfig: Processed submersible: %s", submersible.name))
                    LogToInfo(2, string.format("UpdateFromAutoRetainerConfig: Current rank: %d, Potential final rank: %d", submersible.rank, submersible.rank_after_levelup))
                    LogToInfo(2, string.format("UpdateFromAutoRetainerConfig: Current build: %s, Optimal build: %s, Future optimal build: %s", submersible.build, submersible.optimal_build, submersible.future_optimal_build))
                    LogToInfo(2, string.format("UpdateFromAutoRetainerConfig: Current plan type: %d, Future plan type: %d", submersible.optimal_plan_type, submersible.future_optimal_plan_type))
                    LogToInfo(2, string.format("UpdateFromAutoRetainerConfig: Current plan: %s, Future plan: %s", submersible.optimal_plan_name, submersible.future_optimal_plan_name))
                    LogToInfo(2, string.format("UpdateFromAutoRetainerConfig: Build needs change: %s, Plan needs change: %s", tostring(submersible.build_needs_change), tostring(submersible.plan_needs_change)))
                    LogToInfo(2, string.format("UpdateFromAutoRetainerConfig: Build needs change after levelup: %s, Plan needs change after levelup: %s", tostring(submersible.build_needs_change_after_levelup), tostring(submersible.plan_needs_change_after_levelup)))
                end

                table.insert(chara.submersibles, submersible)
            end
        else
            LogToInfo(2, string.format("UpdateFromAutoRetainerConfig: No submersibles created for character %s (No valid FC)", chara.name))
        end

        ar_character_data[chara_key] = chara
    end

    return ar_character_data, global_data
end

-- Function to save character data and global plans to a Lua file
local function SaveCharacterDataToFile(character_data, global_data)
    local file_name = "ar_character_data.lua"
    local file_path = overseer_folder .. file_name
    local file, err = io.open(file_path, "w")

    if not file then
        Echo("SaveCharacterDataToFile: Unable to open file for writing: " .. tostring(err))
        LogToInfo(1, "SaveCharacterDataToFile: Unable to open file for writing: " .. tostring(err))
        return
    end

    file:write("return {\n")

    -- Write global plans
    file:write("  global_plans = {\n")
    file:write("    saved_plans = {\n")
    for _, plan in ipairs(global_data.saved_plans) do
        file:write("      {\n")
        file:write(string.format("        name = \"%s\",\n", plan.name))
        file:write("        list = {\n")
        for _, item in ipairs(plan.list) do
            file:write(string.format("          { id = %d, num = %d },\n", item.ID, item.Num))
        end
        file:write("        },\n")
        file:write(string.format("        plan_complete_behavior = %d,\n", plan.plan_complete_behavior))
        file:write("      },\n")
    end
    file:write("    },\n")

    file:write("    submarine_unlock_plans = {\n")
    for _, plan in ipairs(global_data.submarine_unlock_plans) do
        file:write("      {\n")
        file:write(string.format("        guid = \"%s\",\n", plan.guid))
        file:write(string.format("        name = \"%s\",\n", plan.name))
        file:write("        excluded_routes = {")
        file:write(table.concat(plan.excluded_routes, ", "))
        file:write("},\n")
        file:write(string.format("        unlock_subs = %s,\n", tostring(plan.unlock_subs)))
        file:write("      },\n")
    end
    file:write("    },\n")

    file:write("    submarine_point_plans = {\n")
    for _, plan in ipairs(global_data.submarine_point_plans) do
        file:write("      {\n")
        file:write(string.format("        guid = \"%s\",\n", plan.guid))
        file:write(string.format("        name = \"%s\",\n", plan.name))
        file:write("        points = {")
        file:write(table.concat(plan.points, ", "))
        file:write("},\n")
        file:write("      },\n")
    end

    file:write("      unoptimal_vessel_configurations = {\n")
    for _, config in ipairs(global_data.unoptimal_vessel_configurations) do
        file:write("        {\n")
        file:write(string.format("          min_rank = %d,\n", config.min_rank))
        file:write(string.format("          max_rank = %d,\n", config.max_rank))
        file:write("          configurations = {")
        for i, conf in ipairs(config.configurations) do
            file:write(string.format("\"%s\"", conf))
            if i < #config.configurations then
                file:write(", ")
            end
        end
        file:write("},\n")
        file:write(string.format("          configurations_invert = %s,\n", tostring(config.configurations_invert)))
        file:write("        },\n")
    end
    file:write("      },\n")
    file:write("    },\n")
    file:write("  },\n")

    -- Write character data
    file:write("  characters = {\n")

    -- Sort characters
    local sorted_characters = {}
    for full_name, chara in pairs(character_data) do
        table.insert(sorted_characters, {full_name = full_name, data = chara})
    end
    table.sort(sorted_characters, function(a, b) return a.full_name < b.full_name end)

    -- Write sorted character data
    for _, chara_entry in ipairs(sorted_characters) do
        local full_name = chara_entry.full_name
        local chara = chara_entry.data
        file:write(string.format("    [\"%s\"] = {\n", full_name))
        file:write(string.format("      id = \"%s\",\n", chara.id))
        file:write(string.format("      name = \"%s\",\n", chara.name))
        file:write(string.format("      server = \"%s\",\n", chara.server))
        file:write(string.format("      retainers_enabled = %s,\n", tostring(chara.retainers_enabled)))
        file:write(string.format("      ceruleum = %d,\n", chara.ceruleum))
        file:write(string.format("      repair_kits = %d,\n", chara.repair_kits))
        file:write(string.format("      ventures = %d,\n", chara.ventures))
        file:write(string.format("      seals = %d,\n", chara.seals))
        file:write(string.format("      gc = %d,\n", chara.gc))
        file:write(string.format("      inventory_space = %d,\n", chara.inventory_space))
        file:write(string.format("      venture_coffers = %d,\n", chara.venture_coffers))
        file:write(string.format("      gil = %d,\n", chara.gil))
        file:write("      free_company = {\n")
        file:write(string.format("        id = \"%s\",\n", chara.free_company.id))
        file:write(string.format("        name = \"%s\",\n", chara.free_company.name))
        file:write(string.format("        server = \"%s\",\n", chara.free_company.server))
        file:write(string.format("        rank = %d,\n", chara.free_company.rank))
        file:write(string.format("        credits = %d,\n", chara.free_company.credits))
        file:write(string.format("        gc_id = %d,\n", chara.free_company.gc_id))
        file:write(string.format("        gc_rank = %d,\n", chara.free_company.gc_rank))
        file:write("        owner = {\n")
        file:write(string.format("          name = \"%s\",\n", chara.free_company.owner.name))
        file:write(string.format("          id = \"%s\",\n", chara.free_company.owner.id))
        file:write("        },\n")
        file:write("      },\n")
        file:write("      retainers = {\n")
        for _, retainer in ipairs(chara.retainers) do
            file:write("        {\n")
            file:write(string.format("          id = \"%s\",\n", retainer.id))
            file:write(string.format("          name = \"%s\",\n", retainer.name))
            file:write(string.format("          job = \"%s\",\n", retainer.job))
            file:write(string.format("          enabled = %s,\n", tostring(retainer.enabled)))
            file:write(string.format("          experience = %d,\n", retainer.experience))
            file:write(string.format("          level = %d,\n", retainer.level))
            file:write(string.format("          gil = %d,\n", retainer.gil))
            file:write(string.format("          has_venture = %s,\n", tostring(retainer.has_venture)))
            file:write(string.format("          linked_venture_plan = \"%s\",\n", retainer.linked_venture_plan))
            file:write(string.format("          venture_plan_index = %d,\n", retainer.venture_plan_index))
            file:write(string.format("          ilvl = %d,\n", retainer.ilvl))
            file:write(string.format("          gathering = %d,\n", retainer.gathering))
            file:write(string.format("          perception = %d,\n", retainer.perception))
            file:write(string.format("          entrust_plan = \"%s\",\n", retainer.entrust_plan))
            file:write(string.format("          current_venture_type = \"%s\",\n", retainer.current_venture_type))
            file:write(string.format("          optimal_venture_type = \"%s\",\n", retainer.optimal_venture_type))
            file:write(string.format("          venture_needs_change = %s,\n", tostring(retainer.venture_needs_change)))
            file:write(string.format("          optimal_saved_plan = \"%s\",\n", retainer.optimal_saved_plan))
            file:write(string.format("          venture_ends_at = %d,\n", retainer.venture_ends_at))
            file:write("        },\n")
        end
        file:write("      },\n")
        file:write("      submersibles = {\n")
        for _, submersible in ipairs(chara.submersibles) do
            file:write("        {\n")
            file:write(string.format("          number = %d,\n", submersible.number))
            file:write(string.format("          name = \"%s\",\n", submersible.name))
            file:write(string.format("          experience = %d,\n", submersible.experience))
            file:write(string.format("          rank = %d,\n", submersible.rank))
            file:write(string.format("          rank_after_levelup = %d,\n", submersible.rank_after_levelup))
            file:write(string.format("          rank_needed_for_next_swap = %d,\n", submersible.rank_needed_for_next_swap))
            file:write(string.format("          min_rank_needed_for_next_swap = %d,\n", submersible.min_rank_needed_for_next_swap))
            file:write(string.format("          build = \"%s\",\n", submersible.build))
            file:write(string.format("          optimal_build = \"%s\",\n", submersible.optimal_build))
            file:write(string.format("          future_optimal_build = \"%s\",\n", submersible.future_optimal_build))
            file:write(string.format("          optimal_plan_type = %d,\n", tonumber(submersible.optimal_plan_type)))
            file:write(string.format("          future_optimal_plan_type = %d,\n", submersible.future_optimal_plan_type))
            file:write(string.format("          optimal_plan = \"%s\",\n", submersible.optimal_plan))
            file:write(string.format("          future_optimal_plan = \"%s\",\n", submersible.future_optimal_plan))
            file:write(string.format("          optimal_plan_name = \"%s\",\n", submersible.optimal_plan_name))
            file:write(string.format("          future_optimal_plan_name = \"%s\",\n", submersible.future_optimal_plan_name))
            file:write(string.format("          build_needs_change = %s,\n", tostring(submersible.build_needs_change)))
            file:write(string.format("          plan_needs_change = %s,\n", tostring(submersible.plan_needs_change)))
            file:write(string.format("          build_needs_change_after_levelup = %s,\n", tostring(submersible.build_needs_change_after_levelup)))
            file:write(string.format("          plan_needs_change_after_levelup = %s,\n", tostring(submersible.plan_needs_change_after_levelup)))
            file:write(string.format("          part1 = \"%s\",\n", submersible.part1))
            file:write(string.format("          part2 = \"%s\",\n", submersible.part2))
            file:write(string.format("          part3 = \"%s\",\n", submersible.part3))
            file:write(string.format("          part4 = \"%s\",\n", submersible.part4))
            file:write(string.format("          current_exp = %d,\n", submersible.current_exp))
            file:write(string.format("          next_level_exp = %d,\n", submersible.next_level_exp))
            file:write(string.format("          vessel_behavior = %d,\n", submersible.vessel_behavior))
            file:write(string.format("          unlock_mode = %d,\n", submersible.unlock_mode))
            file:write(string.format("          optimal_unlock_mode = %d,\n", submersible.optimal_unlock_mode))
            file:write(string.format("          enabled = %s,\n", tostring(submersible.enabled)))
            file:write(string.format("          selected_unlock_plan = \"%s\",\n", submersible.selected_unlock_plan))
            file:write(string.format("          selected_point_plan = \"%s\",\n", submersible.selected_point_plan))
            file:write(string.format("          unlocked = %s,\n", tostring(submersible.unlocked)))
            file:write(string.format("          points = \"%s\",\n", submersible.points))
            file:write("          decoded_points = {")
            if submersible.decoded_points and #submersible.decoded_points > 0 then
                for i, byte in ipairs(submersible.decoded_points) do
                    file:write(tostring(byte))
                    if i < #submersible.decoded_points then
                        file:write(", ")
                    end
                end
            end
            file:write("},\n")
            file:write(string.format("          route = \"%s\",\n", submersible.route))
            file:write(string.format("          return_time = %d,\n", submersible.return_time))
            file:write(string.format("          guaranteed_exp = %d,\n", submersible.guaranteed_exp))
            file:write(string.format("          potential_bonus_exp = %d,\n", submersible.potential_bonus_exp))
            file:write(string.format("          will_level_up = %s,\n", tostring(submersible.will_level_up)))
            file:write(string.format("          potential_level_up = %s,\n", tostring(submersible.potential_level_up)))
            file:write(string.format("          exp_after_levelup = %d,\n", submersible.exp_after_levelup))
            file:write("        },\n")
        end
        file:write("      },\n")
        file:write("    },\n")
    end
    file:write("  },\n")
    file:write("}\n")
    file:flush()
    file:close()
    -- Echo("Character data and global plans saved to " .. file_path)
    LogToInfo(2, "SaveCharacterDataToFile: Character data and global plans saved to " .. file_path)
end

-- Loads all overseer data or specific character data
local function LoadOverseerData(character)
    local overseer_data_file = overseer_folder .. "ar_character_data.lua"

    LogToInfo(1, "LoadOverseerData: Attempting to load data")
    local success, overseer_data = pcall(dofile, overseer_data_file)
    if not success then
        LogToInfo(1, "LoadOverseerData: Failed to load overseer data file")
        return nil
    end

    -- If no character is provided, return the entire file
    if not character then
        LogToInfo(1, "LoadOverseerData: Successfully loaded overseer data")
        return overseer_data
    end

    -- try to return data for the specific character
    local character_data = overseer_data.characters[character]
    if character_data then
        LogToInfo(1, "LoadOverseerData: Successfully loaded data for " .. character)
        return character_data
    else
        LogToInfo(1, "LoadOverseerData: No data found for " .. character)
        return nil
    end
end

-- Update the submersible part inventory file
local function UpdateInventoryFile(character)
    if not character then
        Echo("UpdateInventoryFile: No character provided")
        return
    end

    -- Ensure that the character name is not an empty string
    if character == "" then
        Echo("UpdateInventoryFile: Character name is empty")
        return
    end

    local file_path = overseer_folder .. "sub_inventory_data.json"
    local file, err = io.open(file_path, "r")
    local inventory = {}

    -- Read and parse existing file contents
    if file then
        local content = file:read("*all")
        file:close()

        local success, parsed_data = pcall(json.decode, content)
        if success and type(parsed_data) == "table" then
            inventory = parsed_data
        end
    end

    -- Ensure character entry exists in the inventory (initialize if necessary)
    if not inventory[character] then
        inventory[character] = {}
    end

    -- Clear old data for the character to ensure a clean overwrite
    inventory[character] = {}

    -- Update the character's inventory
    for _, part in ipairs(Submersible_Part_List) do
        local partName = part.PartName
        if partName then
            local part_id = FindItemID(partName)
            if part_id then
                local part_count = GetItemCount(part_id, true)
                inventory[character][partName] = part_count or 0
                LogToInfo(2,"UpdateInventoryFile: Updated " .. partName .. " with count " .. tostring(part_count or 0))
            end
        end
    end

    -- Save updated inventory
    file, err = io.open(file_path, "w")  -- Truncate the file and open in write mode
    if not file then
        Echo("UpdateInventoryFile: Unable to write to sub_inventory_data.json: " .. tostring(err))
        LogToInfo(1, "UpdateInventoryFile: Unable to write to sub_inventory_data.json: " .. tostring(err))
        return nil
    else
        LogToInfo(1, "UpdateInventoryFile: Wrote " .. character .. " to sub_inventory_data.json")
    end

    -- Encode and write the updated data
    local success, encoded_data = pcall(json.encode, inventory)
    if not success then
        Echo("UpdateInventoryFile: Error encoding JSON: " .. tostring(encoded_data))
        LogToInfo(1, "UpdateInventoryFile: Error encoding JSON: " .. tostring(encoded_data))
        file:close()
        return nil
    end

    -- Write the encoded data to the file
    file:write(encoded_data)
    file:flush()
    file:close()
end

-- Loads the submersible part inventory file into overseer
local function LoadInventoryFile()
    overseer_inventory_data = nil
    local file_path = overseer_folder .. "sub_inventory_data.json"
    local file, err = io.open(file_path, "r")
    if not file then
        -- Echo("Unable to read sub_inventory_data.json: " .. tostring(err))
        LogToInfo(1, "LoadInventoryFile: Unable to read sub_inventory_data.json: " .. tostring(err))
        return {}
    end

    local content = file:read("*all")
    file:close()

    local success, inventory_data = pcall(json.decode, content)
    if not success then
        Echo("LoadInventoryFile: Error decoding JSON: " .. tostring(inventory_data))
        LogToInfo(1, "LoadInventoryFile: Error decoding JSON: " .. tostring(inventory_data))
        return {}
    end

    Echo("Inventory successfully loaded.")
    return inventory_data
end

local function UpdateAndLoadInventoryFile(update_char)
    if update_char then
        UpdateInventoryFile(overseer_current_character)
    end
    overseer_inventory_data = LoadInventoryFile()
end

-- Function to disable Auto retainer
local function DisableAR()
    if HasPlugin("AutoRetainer") then
        ForceARSave()
        yield("/xldisableplugin AutoRetainer")

        repeat
            Sleep(0.1)
        until not HasPlugin("AutoRetainer")
    end
end

-- Call this every time you want to update the ar_character_data file with new info
local function UpdateOverseerDataFile(update_char_data)
    local ar_character_data, global_data = UpdateFromAutoRetainerConfig()

    if not ar_character_data then
        Sleep(3)
        ar_character_data, global_data = UpdateFromAutoRetainerConfig()

        if not ar_character_data then
            local error_msg = "UpdateOverseerDataFile: Failed to update character list from DefaultConfig.json, retrying"
            Echo(error_msg)
            LogToInfo(1, error_msg)
            return
        end
    end

    SaveCharacterDataToFile(ar_character_data, global_data)

    if update_char_data then
        overseer_char_data = LoadOverseerData(overseer_current_character)
    end
end

-- walks up to the vendor and buys/uses gc seal buff, should only be called when already at the GC
local function UseFCBuff()
    if HasStatus("Seal Sweetener") then
        return true
    end

    if UseFCAction("Seal Sweetener II") then
        LogToInfo(1, "UseFCBuff: Seal Sweetener II successfully used")
        return true
    end

    local fc_gc_id = GetFCGCID()
    -- Coords have 1 for the stopping distance, not part of the xyz pos
    local gc_coords = {
        [1] = { 
            command = "gc maelstrom", 
            coords = { 93.46, 40.28, 71.52, 1 }, 
            location = "Limsa Lominsa Upper Decks",
            teleport_location = "Limsa Lominsa Lower Decks"
        }, -- Maelstrom
        [2] = { 
            command = "gc twin", 
            coords = { -70.24, -0.50, -7.09, 1 }, 
            location = "New Gridania"
        }, -- Twin Adder
        [3] = { 
            command = "gc immortal", 
            coords = { -143.86, 4.11, -104.04, 1 }, 
            location = "Ul'dah - Steps of Nald" 
        } -- Immortal Flames
    }

    local gc_info = gc_coords[fc_gc_id]

    if gc_info then
        local current_zone_id = GetZoneID()
        local dest_zone_id = FindZoneIDByAetheryte(gc_info.location)
        
        if fc_gc_id == 1 then
            local upper_decks_id = FindZoneID("Limsa Lominsa Upper Decks") -- Upper Decks does not have an aetheryte id so have to use FindZoneID()
            
            -- Movement only if in Upper Decks
            if current_zone_id == upper_decks_id then
                Movement(table.unpack(gc_info.coords))
                return
            end
            
            -- Teleport if not in Upper Decks
            local teleport_type = TeleportType(gc_info.command) and "li" or "tp"
            Teleporter(gc_info.command, teleport_type)
            Movement(table.unpack(gc_info.coords))
        else
            -- Normal handling for other GCs
            local teleport_type = TeleportType(gc_info.command) and "li" or "tp"
            
            if current_zone_id ~= dest_zone_id then
                Teleporter(gc_info.command, teleport_type)
                Movement(table.unpack(gc_info.coords))
            else
                Movement(table.unpack(gc_info.coords))
            end
        end
    end

    -- Try buying and using "Seal Sweetener II"
    if BuyFCAction("Seal Sweetener II") then
        if UseFCAction("Seal Sweetener II") then
            return true
        else
            return false, "Failed to use Seal Sweetener II"
        end
    end

    -- Try using "Seal Sweetener" if "Seal Sweetener II" fails
    if UseFCAction("Seal Sweetener") then
        LogToInfo(1, "UseFCBuff: Seal Sweetener successfully used")
        return true
    end

    -- Buy and use "Seal Sweetener" if not already available
    if BuyFCAction("Seal Sweetener") then
        if UseFCAction("Seal Sweetener") then
            return true
        else
            return false, "Failed to use Seal Sweetener"
        end
    else
        return false
    end
end

-- Checks and triggers a gc expert delivery if low on ventures or inventory space
local function PerformGCDelivery()
    ARSetMultiModeEnabled(false)

    if use_fc_buff then
        UseFCBuff()
    end

    yield("/li gc")
    Sleep(1)

    repeat
        Sleep(1)
    until not LifestreamIsBusy()

    repeat
        Sleep(0.1)
    until IsPlayerAvailable()

    GCDeliverooExpertDelivery()
    LogToInfo(1, "PerformGCDelivery: GC run finished")
end

-- Will run after AR has finished processing if a submersible can be created
local function RegisterSubmersible()
    ARSetMultiModeEnabled(false)

    if not IsPlayerAvailable() then
        Echo("Player isn't available, register submersible attempt aborted")
        return
    end

    if GetDistanceToObject("Voyage Control Panel") > 4.5 then
        Target("Voyage Control Panel")
        yield("/lockon")
        yield("/automove")
        repeat
            Sleep(0.1)
        until GetDistanceToObject("Voyage Control Panel") < 4
    end

    repeat
        Target("Voyage Control Panel")
        Sleep(0.1)
        yield("/interact")
        Sleep(0.212)
    until IsAddonReady("SelectString")

    repeat
        yield("/callback SelectString true 1")
        Sleep(0.1)
    until not IsAddonVisible("SelectString")

    repeat
        Sleep(0.1)
    until IsAddonReady("SelectString")

    Sleep(0.5)
    RegisterNewSubmersible()

    repeat
        Sleep(0.1)
    until IsAddonReady("SelectString")

    repeat
        yield("/callback SelectString true -1 0")
        Sleep(0.1)
    until not IsAddonVisible("SelectString")

    repeat
        Sleep(0.1)
    until IsAddonReady("SelectString")

    repeat
        yield("/callback SelectString true -1 0")
        Sleep(0.1)
    until not IsAddonVisible("SelectString")
end

-- Function to return the AR file as json
local function LoadARJson()
    local ar_file, err = io.open(auto_retainer_config_path, "r")
    if not ar_file then
        LogToInfo(1, "LoadARJson: Failed to open file: " .. err)
        return nil
    end

    local ar_file_content = ar_file:read("*a")
    ar_file:close()

    if ar_file_content:sub(1, 3) == string.char(0xEF, 0xBB, 0xBF) then
        ar_file_content = ar_file_content:sub(4)
        LogToInfo(1, "LoadARJson: BOM removed from the ar json file")
    end

    local success, json_data = pcall(json.decode, ar_file_content)
    if not success then
        LogToInfo(1, "LoadARJson: Failed to decode JSON")
        return nil
    end

    return json_data
end

-- Function to write data back into the ar file
local function WriteToARJson(data)
    local encoded_data, err = json.encode(data)
    if not encoded_data then
        LogToInfo(1, "WriteToARJson: Failed to encode data. Error: " .. err)
        return false
    end
    DisableAR()
    local ar_file, open_err = io.open(auto_retainer_config_path, "w")
    if not ar_file then
        LogToInfo(1, "WriteToARJson: Failed to open file for writing. Error: " .. open_err)
        return false
    end

    -- ar_file:write(string.char(0xEF, 0xBB, 0xBF))
    ar_file:write(encoded_data)
    ar_file:flush()
    ar_file:close()

    LogToInfo(1, "WriteToARJson: Successfully wrote data to file.")
    return true
end

-- Function to enable a specific submersible number for a character
local function EnableSubmersible(submersible_number)
    UpdateOverseerDataFile(true)

    local submersible_name
    for _, submersible in ipairs(overseer_char_data.submersibles) do
        if submersible.number == submersible_number then
            submersible_name = submersible.name
            break
        end
    end

    if not submersible_name then
        return LogToInfo(1, "EnableSubmersible: Requested submersible doesn't have a name")
    end

    local ar_data = LoadARJson()
    if not ar_data then
        Echo("Error: EnableSubmersible: Unable to open file")
        return
    end

    local char_cid = overseer_char_data.id
    local character
    for _, char in ipairs(ar_data.OfflineData) do
        if tonumber(char.CID) == tonumber(char_cid) then
            character = char
            break
        end
    end

    if not character then
        Echo("Error: EnableSubmersible: CID not found")
        return
    end

    for _, sub in ipairs(character.EnabledSubs) do
        if sub == submersible_name then
            Echo("EnableSubmersible: Submersible already enabled")
            return
        end
    end

    table.insert(character.EnabledSubs, submersible_name)
    WriteToARJson(ar_data)
    LogToInfo(1, "EnableSubmersible: Successfully enabled " .. tostring(submersible_name))
    Echo("EnableSubmersible: Successfully enabled " .. tostring(submersible_name))
end

-- Function to edit the additional submersible data in ar
local function ModifyAdditionalSubmersibleData(submersible_number, config, config_option)
    CreateConfigBackup()
    UpdateOverseerDataFile(true)

    local submersible = overseer_char_data.submersibles[submersible_number]
    if not submersible or submersible.build == "" then
        Echo("ModifyAdditionalSubmersibleData: No submersible with that number found.")
        return
    end

    local submersible_name, char_cid = submersible.name, overseer_char_data.id
    if not submersible_name or not char_cid then
        Echo("ModifyAdditionalSubmersibleData: No submersible or character data found.")
        return
    end

    local ar_data = LoadARJson()
    if not ar_data then
        Echo("Error: ModifyAdditionalSubmersibleData: Unable to open file")
        return
    end

    for _, character in ipairs(ar_data.OfflineData) do
        if tonumber(character.CID) == tonumber(char_cid) and character.AdditionalSubmarineData and character.AdditionalSubmarineData[submersible_name] then
            local sub_data = character.AdditionalSubmarineData[submersible_name]
            if sub_data[config] then
                sub_data[config] = config_option
                WriteToARJson(ar_data)
                Echo("ModifyAdditionalSubmersibleData: Successfully updated " .. submersible_name .. "." .. config)
                return
            else
                Echo("Error: ModifyAdditionalSubmersibleData: Config option not found")
                return
            end
        end
    end

    Echo("Error: ModifyAdditionalSubmersibleData: Submersible or CID not found")
end

-- Functon to modify return time of submersibles on a character
local function ModifyOfflineReturnTime(submersible_name, return_time)
    CreateConfigBackup()
    UpdateOverseerDataFile(true)

    local char_cid = overseer_char_data.id
    if not char_cid then
        Echo("ModifyOfflineReturnTime: Failed to find character data.")
        return
    end

    if not return_time or not submersible_name then
        Echo("ModifyOfflineReturnTime: No sub name and/or return time provided")
        return
    end

    local ar_data = LoadARJson()
    if not ar_data then
        Echo("Error: ModifyOfflineReturnTime: Unable to open file")
        return
    end

    for _, character in ipairs(ar_data.OfflineData) do
        if tonumber(character.CID) == tonumber(char_cid) then
            for _, sub in ipairs(character.OfflineSubmarineData) do
                if sub.Name == submersible_name then
                    sub.ReturnTime = return_time
                    WriteToARJson(ar_data)
                    Echo("ModifyOfflineReturnTime: Successfully updated ReturnTime for " .. submersible_name)
                    return
                end
            end
        end
    end

    Echo("Error: ModifyOfflineReturnTime: Submersible not found or CID mismatch")
end

-- Function to edit the OfflineData in AR, if CID is not passed it will modify all characters with the same setting, otherwise it will only modify the character with that CID
local function ModifyOfflineData(setting, value, CID)
    CreateConfigBackup()
    local ar_data = LoadARJson()
    if not ar_data then
        Echo("ModifyOfflineData: Unable to open file")
        return
    end

    local ar_json_modified = false

    for _, character in ipairs(ar_data.OfflineData) do
        if CID then
            if character.CID == CID then
                if character[setting] ~= nil then
                    if character[setting] ~= value then
                        character[setting] = value
                        ar_json_modified = true
                    end
                else
                    LogToInfo(1, "ModifyOfflineData: Setting '" .. setting .. "' not found for character " .. tostring(character.Name))
                end
                break
            end
        else
            if character[setting] ~= nil then
                if character[setting] ~= value then
                    character[setting] = value
                    ar_json_modified = true
                end
            else
                LogToInfo(1, "ModifyOfflineData: Setting '" .. setting .. "' not found for character " .. tostring(character.Name))
            end
        end
    end

    if ar_json_modified then
        WriteToARJson(ar_data)
        if not CID then
            LogToInfo(1, "ModifyOfflineData: Successfully updated '" .. setting .. "' to " .. tostring(value) .. " for all characters")
        else
            LogToInfo(1, "ModifyOfflineData: Successfully updated '" .. setting .. "' to " .. tostring(value) .. " for CID: " .. tostring(CID))
        end
        return true
    else
        LogToInfo(1, "ModifyOfflineData: No changes were made.")
        return false
    end
end

-- Function to modify base AR settings in the config
local function ModifyARConfig(setting, value)
    CreateConfigBackup()
    local ar_data = LoadARJson()
    if not ar_data then
        LogToInfo(1, "ModifyARConfig: Invalid setting")
        return false
    end

    if ar_data[setting] == value then
        LogToInfo(1, "ModifyARConfig: No change needed for '" .. setting .. "'")
        return false
    end

    ar_data[setting] = value
    WriteToARJson(ar_data)
    LogToInfo(1, "ModifyARConfig: Updated '" .. setting .. "' to " .. tostring(value))
    return true
end

-- Function to check if retainers are currently within active hours
local function IsWithinRetainerActiveHours()
    local current_time = os.date("*t")
    local current_minutes = current_time.hour * 60 + current_time.min

    local start_minutes = retainer_active_hours.start_time.hour * 60 + retainer_active_hours.start_time.minute
    local end_minutes = retainer_active_hours.end_time.hour * 60 + retainer_active_hours.end_time.minute

    if start_minutes > end_minutes then
        return current_minutes >= start_minutes or current_minutes < end_minutes
    end

    return current_minutes >= start_minutes and current_minutes < end_minutes
end

-- Function to enable or disable retainers if it's inside/outside of active hours
local function EnforceRetainerSchedule()
    if not enable_retainer_schedule then
        return
    end

    if IsWithinRetainerActiveHours() then
        if ModifyOfflineData("Enabled", true) then
            EnableAR()
            ARSetMultiModeEnabled(true)
        end
    else
        if ModifyOfflineData("Enabled", false) then
            EnableAR()
            ARSetMultiModeEnabled(true)
        end
    end
end

-- our own version of ARSubsWaitingToBeProcessed
function SubsWaitingToBeProcessed()
    if DoesObjectExist("Voyage Control Panel") and GetDistanceToObject("Voyage Control Panel") < 4.5 and IsPlayerAvailable() then
        ForceARSave()
    end

    UpdateOverseerDataFile(true)
    local current_time = os.time()

    for _, submersible in ipairs(overseer_char_data.submersibles) do
        if submersible.return_time < current_time and submersible.return_time > 0 and submersible.name ~= "" then
            return true
        end
    end
    return false
end

-- our own version of ARRetainersWaitingToBeProcessed
function RetainersWaitingToBeProcessed()
    if DoesObjectExist("Summoning Bell") and GetDistanceToObject("Summoning Bell") < 4.5 and IsPlayerAvailable() then
        ForceARSave()
    end

    UpdateOverseerDataFile(true)
    local current_time = os.time()

    for _, retainer in ipairs(overseer_char_data.retainers) do
        if retainer.venture_ends_at < current_time and retainer.venture_ends_at > 0 and retainer.name ~= "" and retainer.enabled and overseer_char_data.retainers_enabled then
            return true
        end
    end
    return false
end

-- Function to enable the auto retainer collection
function EnableAR()
    if not HasPlugin("AutoRetainer") then
        yield("/xlenableplugin AutoRetainer")
        repeat
            Sleep(0.5)
        until HasPlugin("AutoRetainer") and type(ARGetInventoryFreeSlotCount()) == "number"
        yield("/ays")
    end
end

-- Function to handle any tasks that need to be done before AR does it's things, like part swapping
local function PreARTasks()
    LogToInfo(1, "PreARTasks running")
    ForceARSave()
    UpdateOverseerDataFile(true)

    for _, submersible in ipairs(overseer_char_data.submersibles) do
        if submersible.name ~= "" then
            -- Enable all disabled character subs 
            if not submersible.enabled then
                EnableSubmersible(submersible.number)
                UpdateOverseerDataFile(true)
            end

            -- Change all needed plans
            if submersible.plan_needs_change then
                local planType = (submersible.optimal_plan_type == 4) and "SelectedPointPlan" or "SelectedUnlockPlan"
                ModifyAdditionalSubmersibleData(submersible.number, planType, submersible.optimal_plan)
                UpdateOverseerDataFile(true)
            end

            -- Change unlock mode and behavior
            if ((submersible.vessel_behavior ~= 0 or (submersible.vessel_behavior == 0 and (not submersible.build_needs_change or (submersible.optimal_build ~= submersible.future_optimal_build and submersible.future_optimal_build ~= "")))) or ((submersible.rank == 1 and submersible.build_needs_change))) and submersible.return_time ~= 1000000000 then
                if (submersible.optimal_unlock_mode ~= submersible.unlock_mode) and submersible.vessel_behavior ~= 4 then
                    ModifyAdditionalSubmersibleData(submersible.number,"UnlockMode", submersible.optimal_unlock_mode)
                end
                if (submersible.vessel_behavior ~= submersible.optimal_plan_type) then
                    ModifyAdditionalSubmersibleData(submersible.number,"VesselBehavior", submersible.optimal_plan_type)
                end
                UpdateOverseerDataFile(true)
            end

            -- Check and set any subs that need a build swap to finalize
            local returns_within_five_minutes = submersible.return_time <= (os.time() + 300)
            local needs_swap_when_it_returns = (submersible.future_optimal_build ~= "" and submersible.future_optimal_build ~= submersible.build and CheckIfWeHaveRequiredParts(submersible.future_optimal_build, submersible) and submersible.rank_after_levelup >= submersible.rank_needed_for_next_swap)
            local needs_swap_at_current_level = submersible.build_needs_change and submersible.vessel_behavior ~= 0 and CheckIfWeHaveRequiredParts(submersible.optimal_build, submersible)
            if returns_within_five_minutes and (needs_swap_when_it_returns or needs_swap_at_current_level) then
                ModifyAdditionalSubmersibleData(submersible.number, "VesselBehavior", 0)
                UpdateOverseerDataFile(true)
            end

            -- Bring back subs if force_return_subs_that_need_swap is enabled and they need a part swap
            if submersible.build_needs_change and force_return_subs_that_need_swap and (submersible.return_time > (os.time() + 600) or not submersible.return_time ~= 0) and not submersible.return_time ~= 1000000000 and CheckIfWeHaveRequiredParts(submersible.optimal_build, submersible) then
                ModifyAdditionalSubmersibleData(submersible.number, "VesselBehavior", 0)
                ModifyOfflineReturnTime(submersible.name, 1000000000)
                UpdateOverseerDataFile(true)
            end
        end
    end

    EnableAR()
end

local function IfAdditionalEntranceExistsPathToIt()
    local entrance = "Entrance to Additional Chambers"
    if DoesObjectExist(entrance) then
        local distance = GetDistanceToObject(entrance)
        if distance > 4.5 then
            Target(entrance)
            yield("/lockon")
            yield("/automove")
            Sleep(1.2)
            while distance > 4 do
                Sleep(0.1)
                distance = GetDistanceToObject(entrance)
            end
            yield("/automove")
            yield("/lockon")
            repeat Sleep(0.1) until not IsMoving()
        end

        repeat
            Target(entrance)
            yield("/interact")
            Sleep(0.213)
        until IsAddonReady("SelectString")

        repeat
            yield("/callback SelectString true 0")
            Sleep(0.1)
        until not IsAddonVisible("SelectString")

        ZoneTransitions()
    end
end

local function HasEnabledRetainers()
    if overseer_char_data.retainers then
        for _, retainer in pairs(overseer_char_data.retainers) do
            if retainer.enabled and retainer.name ~= "" then
                return true
            end
        end
    end
    return false
end

-- Function to handle any tasks that need to be done after subs are finished
local function PostARTasks()
    CreateConfigBackup()
    ForceARSave() -- Initial save
    UpdateOverseerDataFile(true)

    for _, submersible in ipairs(overseer_char_data.submersibles) do
        if submersible.return_time < os.time() and submersible.return_time ~= 0 and submersible.vessel_behavior == 0 then
            local retries = 0
            repeat
                ForceARSave()
                UpdateOverseerDataFile(true)
                Sleep(2)
                retries = retries + 1
            until submersible.return_time == 0 or retries >= 5
        end
    end

    -- Part swapping
    local in_submersible_menu = false
    local swap_done = false
    local last_callback_time = 0

    for _, submersible in ipairs(overseer_char_data.submersibles) do
        if submersible.vessel_behavior == 0 and submersible.name ~= "" and not overseer_char_subs_excluded then
            local needs_swap = submersible.return_time < os.time() or force_return_subs_that_need_swap
            if needs_swap and CheckIfWeHaveRequiredParts(submersible.optimal_build, submersible) and submersible.build_needs_change then
                IfAdditionalEntranceExistsPathToIt()
                if not DoesObjectExist("Voyage Control Panel") then break end

                if not in_submersible_menu then

                    -- Move to the panel panel
                    if GetDistanceToObject("Voyage Control Panel") > 4.5 then
                        Target("Voyage Control Panel")
                        yield("/lockon")
                        yield("/automove")
                        repeat Sleep(0.1) until GetDistanceToObject("Voyage Control Panel") < 4
                    end

                    -- Enter the panel
                    repeat
                        Target("Voyage Control Panel")
                        yield("/interact")
                        Sleep(0.214)
                    until IsAddonReady("SelectString")

                    -- Open Submersible Management and wait for next menu to show up
                    repeat
                        if os.time() - last_callback_time >= 4 then
                            yield("/callback SelectString true 1")
                            last_callback_time = os.time()
                        end
                        Sleep(0.1)
                    until string.find(GetNodeText("SelectString", 3), "Vessels deployed")

                    last_callback_time = 0
                    in_submersible_menu = true
                end

                -- Select vessel we're changing the parts of
                repeat
                    if os.time() - last_callback_time >= 4 then
                        yield("/callback SelectString true " .. (submersible.number - 1))
                        last_callback_time = os.time()
                    end
                    Sleep(0.1)
                until string.find(tostring(GetNodeText("SelectString", 3)):gsub("[\128-\255\0-\31]", ""), submersible.name:gsub("[-]", "%%-"))

                last_callback_time = 0
                Sleep(0.5)

                local node_text = GetNodeText("SelectString",2,1,3)
                if string.find(node_text, "Recall") and force_return_subs_that_need_swap then

                    repeat
                        if IsAddonReady("SelectString") then
                            yield("/callback SelectString true 0")
                            Sleep(0.1)
                        end
                    until not IsAddonVisible("SelectString")

                    repeat
                        Sleep(0.1)
                    until IsAddonReady("AirShipExplorationDetail")

                    local retry_counter = 0
                    local SelectYesno_ready = false

                    repeat
                        if retry_counter == 0 then
                            yield("/callback AirShipExplorationDetail true 0")
                        end

                        if IsAddonReady("SelectYesno") then
                            SelectYesno_ready = true
                        end

                        retry_counter = retry_counter + 1
                        if retry_counter >= 50 then
                            retry_counter = 0
                        end

                        Sleep(0.1)
                    until SelectYesno_ready

                    repeat
                        Sleep(0.1)
                    until IsAddonReady("SelectYesno")

                    repeat
                        yield("/callback SelectYesno true 0")
                        Sleep(0.1)
                    until not IsAddonVisible("SelectYesno")

                    repeat
                        Sleep(0.1)
                    until IsAddonReady("SelectString")

                elseif string.find(node_text, "Recall") and not force_return_subs_that_need_swap then
                    yield("/callback SelectString true 4")

                    repeat
                        Sleep(0.1)
                    until IsAddonReady("SelectString") or IsPlayerAvailable()

                    break
                end

                repeat
                    yield("/callback SelectString true 2")
                until not IsAddonVisible("SelectString")

                repeat
                    Sleep(0.1)
                until IsAddonReady("CompanyCraftSupply")

                local part_retries = 0

                repeat
                    ChangeSubmersibleParts(submersible.optimal_build)
                    Sleep(0.1)
                    part_retries = part_retries + 1
                until GetSubmersibleParts() == submersible.optimal_build or part_retries >= 10

                repeat
                    yield("/callback CompanyCraftSupply true 5")
                    Sleep(0.1)
                until not IsAddonVisible("CompanyCraftSupply")

                repeat
                    Sleep(0.1)
                until IsAddonReady("SelectString")

                repeat
                    yield("/callback SelectString true -1 0")
                    Sleep(0.1)
                until not IsAddonVisible("CompanyCraftSupply")

                repeat
                    Sleep(0.1)
                until IsAddonReady("SelectString")
                swap_done = true

                -- After successful part swap
                ForceARSave() 
                Sleep(2) -- Add delay to ensure save completes
                UpdateOverseerDataFile(true)

                ModifyAdditionalSubmersibleData(submersible.number,"VesselBehavior",submersible.optimal_plan_type)
                ForceARSave()
                Sleep(1)

                if submersible.optimal_plan_type == 4 then
                    ModifyAdditionalSubmersibleData(submersible.number,"SelectedPointPlan",submersible.optimal_plan)
                else
                    ModifyAdditionalSubmersibleData(submersible.number,"SelectedUnlockPlan",submersible.optimal_plan)
                end
                
                ForceARSave()
                Sleep(2)
                UpdateOverseerDataFile(true)
            elseif submersible.return_time < os.time() and not CheckIfWeHaveRequiredParts(submersible.optimal_build, submersible) then
                ModifyAdditionalSubmersibleData(submersible.number,"VesselBehavior",submersible.optimal_plan_type)

                if submersible.optimal_plan_type == 4 then
                    ModifyAdditionalSubmersibleData(submersible.number,"SelectedPointPlan",submersible.optimal_plan)
                else
                    ModifyAdditionalSubmersibleData(submersible.number,"SelectedUnlockPlan",submersible.optimal_plan)
                end
                UpdateOverseerDataFile(true)
            end
        end
    end
    if swap_done then
        ForceARSave()
        Sleep(3) -- Delay after swaps
        UpdateOverseerDataFile(true)
        repeat
            yield("/callback SelectString true -1 0")
            Sleep(0.1)
        until not IsAddonVisible("SelectString")
        repeat
            Sleep(0.1)
        until IsAddonReady("SelectString") or IsPlayerAvailable()
        repeat
            yield("/callback SelectString true -1 0")
            Sleep(0.1)
        until not IsAddonVisible("SelectString") and IsPlayerAvailable()
    end

    -- Check and handle if we need to register any submarines
    local registered_sub = false
    local registered_subs_array = {}
    for _, submersible in ipairs(overseer_char_data.submersibles) do
        if submersible.unlocked and submersible.name == "" and not overseer_char_subs_excluded and CheckIfWeHaveRequiredParts(submersible.optimal_build, submersible, overseer_current_character) then
            IfAdditionalEntranceExistsPathToIt()
            if not DoesObjectExist("Voyage Control Panel") then
                break
            end
            RegisterSubmersible()
            Echo("Waiting 60 seconds for AR to properly save its data, will be made better at a later date")
            ForceARSave()
            Sleep(60)
            ForceARSave()
            Sleep(3)
            UpdateOverseerDataFile(true)
            DisableAR()
            EnableSubmersible(submersible.number)
            UpdateOverseerDataFile(true)
            EnableAR()
            Sleep(10)
            EnableSubmersible(submersible.number)
            table.insert(registered_subs_array, submersible.number)
            registered_sub = true
        end
    end

    -- Apply plan to newly registered subs
    if registered_sub then
        EnableAR()
        ForceARSave()
        DisableAR()
        UpdateOverseerDataFile(true)
        for _, submersible in ipairs(overseer_char_data.submersibles) do
            for _, sub_number in ipairs(registered_subs_array) do
                if sub_number == submersible.number then
                    ModifyAdditionalSubmersibleData(submersible.number,"VesselBehavior",submersible.optimal_plan_type)
                    if submersible.optimal_plan_type == 4 then
                        ModifyAdditionalSubmersibleData(submersible.number,"SelectedPointPlan",submersible.optimal_plan)
                    else
                        ModifyAdditionalSubmersibleData(submersible.number,"SelectedUnlockPlan",submersible.optimal_plan)
                    end
                    UpdateOverseerDataFile(true)
                end
            end
        end
    end

    -- Set any sub that hasn't actually reached the right level back on the right path
    for _, submersible in ipairs(overseer_char_data.submersibles) do
        if submersible.vessel_behavior == 0 and not submersible.build_needs_change and submersible.return_time == 0 and submersible.name ~= "" and not overseer_char_subs_excluded then
            ModifyAdditionalSubmersibleData(submersible.number, "VesselBehavior", submersible.optimal_plan_type)
            UpdateOverseerDataFile(true)
        end
    end

    EnableAR()
    if swap_done or registered_sub then
        ForceARSave()
        Sleep(2)
        ARSetMultiModeEnabled(true)
        repeat
            Sleep(0.1)
        until not IsPlayerAvailable()
        ARSetMultiModeEnabled(false)
        ForceARSave()
        Sleep(2)
        repeat
            Sleep(0.1)
        until IsPlayerAvailable()
    end

    if overseer_char_data.ceruleum and overseer_char_data.ceruleum <= ceruleum_limit and type(overseer_char_data.submersibles) == "table" and overseer_char_data.submersibles[1] and overseer_char_data.submersibles[1].name ~= "" and buy_ceruleum and not overseer_char_bought_ceruleum then
        overseer_char_bought_ceruleum = true
        local function CalculateCeruleumPurchase()
            local ceruleum_price = 100
            if not (overseer_char_data.free_company and overseer_char_data.free_company.credits) then
                return 0
            end

            local available_credits = overseer_char_data.free_company.credits - (fc_credits_to_keep or 0)
            local max_ceruleum_to_buy = math.floor(available_credits / ceruleum_price)
            local amount_to_buy = math.min(ceruleum_buy_amount or 0, max_ceruleum_to_buy)

            return math.max(amount_to_buy, 0)
        end

        local amount_to_buy = CalculateCeruleumPurchase()

        if amount_to_buy > 0 then
            IfAdditionalEntranceExistsPathToIt()
            if DoesObjectExist("Voyage Control Panel") then
                BuyCeruleum(amount_to_buy)
            end
        else
            Echo("Not enough credits to purchase ceruleum without going below the limit.")
        end
    end

    if HasEnabledRetainers() and not overseer_char_performed_gc_delivery and overseer_char_processing_retainers and not disable_gc_delivery then
        overseer_char_performed_gc_delivery = true
        if overseer_char_data.ventures < venture_limit and overseer_char_data.ventures ~= 0  then
            PerformGCDelivery()
        elseif GetInventoryFreeSlotCount() < inventory_slot_limit then
            PerformGCDelivery()
        end
    end

    -- Tap the Voyage Control Panel to refresh AutoRetainer data for submersibles
    if DoesObjectExist"Voyage Control Panel" then
        repeat
            Target("Voyage Control Panel")
            Sleep(0.1)
            yield("/interact")
            Sleep(0.212111)
        until IsAddonReady("SelectString")
    
        repeat
            yield("/callback SelectString true -1 0")
            Sleep(0.1)
        until not IsAddonVisible("SelectString")
    end
end

-- Function to add all listed unlock plans to the autoretainer default config
local function AddUnlockPlansToDefaultConfig()
    UpdateOverseerDataFile(true)

    local ar_data = LoadARJson()
    if not ar_data then
        Echo("Error: AddUnlockPlansToDefaultConfig: Unable to open file")
        return
    end

    ar_data.SubmarineUnlockPlans = ar_data.SubmarineUnlockPlans or {}

    for _, plan in ipairs(unlock_plans) do
        for _, existing_plan in ipairs(ar_data.SubmarineUnlockPlans) do
            if string.lower(existing_plan.GUID) == string.lower(plan.GUID) then
                LogToInfo(1, "AddUnlockPlansToDefaultConfig: Unlock plan with GUID " .. plan.GUID .. " already exists.")
                return
            end
        end

        local new_plan = {
            GUID = plan.GUID,
            Name = plan.Name,
            ExcludedRoutes = plan.ExcludedRoutes,
            UnlockSubs = plan.UnlockSubs,
            EnforceDSSSinglePoint = plan.EnforceDSSSinglePoint or false,
            EnforcePlan = plan.EnforcePlan or false
        }
        table.insert(ar_data.SubmarineUnlockPlans, new_plan)
    end

    local success, write_err = WriteToARJson(ar_data)
    if not success then
        Echo("Error: AddUnlockPlansToDefaultConfig: Error writing updated AR data: " .. write_err)
        return
    end

    Echo("AddUnlockPlansToDefaultConfig: Successfully updated unlock plans")
end

-- Function to add all listed point plans to the autoretainer default config
local function AddPointPlansToDefaultConfig()
    UpdateOverseerDataFile(true)

    local ar_data = LoadARJson()
    if not ar_data then
        Echo("Error: AddPointPlansToDefaultConfig: Unable to open file")
        return
    end

    ar_data.SubmarinePointPlans = ar_data.SubmarinePointPlans or {}

    for _, plan in ipairs(point_plans) do
        for _, existing_plan in ipairs(ar_data.SubmarinePointPlans) do
            if string.lower(existing_plan.GUID) == string.lower(plan.GUID) then
                LogToInfo(1, "AddPointPlansToDefaultConfig: Point plan with GUID " .. plan.GUID .. " already exists.")
                return
            end
        end

        local new_plan = {
            GUID = plan.GUID,
            Name = plan.Name,
            Points = plan.Points
        }
        table.insert(ar_data.SubmarinePointPlans, new_plan)
    end

    local success, write_err = WriteToARJson(ar_data)
    if not success then
        Echo("Error: AddPointPlansToDefaultConfig: Error writing updated AR data: " .. write_err)
        return
    end

    Echo("AddPointPlansToDefaultConfig: Successfully updated point plans")
end

-- Goes through all characters and checks if any of the settings are wrong, then fixes them if they are
local function CheckAndCorrectAllCharacters()
    ARSetMultiModeEnabled(false)
    UpdateOverseerDataFile()
    CreateConfigBackup()
    local overseer_data = LoadOverseerData()
    for character_name, character_data in pairs(overseer_data.characters) do

        LogToInfo(1, "CheckAndCorrectAllCharacters: Checking if " .. character_name .. " needs correcting")
        overseer_char_subs_excluded = InExclusionList(character_name)
        overseer_char_data = character_data
        overseer_current_character = character_name

        if not overseer_char_subs_excluded then
            for _, submersible in ipairs(character_data.submersibles) do
                if submersible.name ~= "" then

                    if not submersible.enabled or (submersible.enabled and submersible.rank == 1 and submersible.return_time == 0) then
                        LogToInfo(1, "CheckAndCorrectAllCharacters: Found a disabled submersible, enabling and correcting submersible "..submersible.number)
                        EnableSubmersible(submersible.number)
                        ModifyAdditionalSubmersibleData(submersible.number, "VesselBehavior", submersible.optimal_plan_type)
                        ModifyAdditionalSubmersibleData(submersible.number, "SelectedUnlockPlan", submersible.optimal_plan)
                        ModifyAdditionalSubmersibleData(submersible.number, "UnlockMode", submersible.optimal_unlock_mode)
                        ModifyOfflineReturnTime(submersible.name, 1000000000)
                    end

                    if submersible.vessel_behavior == 0 then
                        -- Set any sub that hasn't actually reached the right level back on the right path
                        if not submersible.build_needs_change and submersible.return_time >= (os.time() + 300) then
                            LogToInfo(1, "CheckAndCorrectAllCharacters: submersible.rank < submersible.min_rank_needed_for_next_swap and submersible.return_time == 0")
                            ModifyAdditionalSubmersibleData(submersible.number, "VesselBehavior", submersible.optimal_plan_type)
                        end
                        -- Check if a submarine failed a part swap and attempt a new part swap, needs refining but works well enough for now
                        if submersible.return_time == 0 and submersible.build_needs_change then
                            LogToInfo(1, "CheckAndCorrectAllCharacters: submersible.return_time == 0 and submersible.build_needs_change")
                            ModifyOfflineReturnTime(submersible.name, 1000000000)
                        end
                    end

                    -- Force any subs that need a part swap to return and then part swap them if force_return_subs_that_need_swap is enabled
                    if submersible.build_needs_change and force_return_subs_that_need_swap then
                        if CheckIfWeHaveRequiredParts(submersible.optimal_build, submersible, overseer_current_character) then
                            LogToInfo(1, "CheckAndCorrectAllCharacters: Submersible needs part swap, and force return subs is enabled, using fake ready on the sub")
                            ModifyAdditionalSubmersibleData(submersible.number,"VesselBehavior", 0)
                            ModifyOfflineReturnTime(submersible.name, 1000000000)
                        else
                            LogToInfo(1, "CheckAndCorrectAllCharacters: Submersible needs part swap and force return enabled, but required parts are missing")
                        end
                    elseif force_return_subs_that_need_swap and not CheckIfWeHaveRequiredParts(submersible.optimal_build, submersible, overseer_current_character) then
                        LogToInfo(1, "CheckAndCorrectAllCharacters: Force return is enabled but we do not have the correct parts")
                    end

                    -- if submersible is the correct build and not sent out, assume it's somehow wrongly set and fix it
                    if not submersible.build_needs_change and submersible.return_time == 0 then
                        ModifyAdditionalSubmersibleData(submersible.number, "VesselBehavior", submersible.optimal_plan_type)
                        ModifyOfflineReturnTime(submersible.name, 1000000000)
                    end
                end
            end
        end

        overseer_char_data = {}
        overseer_current_character = ""
        overseer_char_subs_excluded = false
    end

    UpdateOverseerDataFile()
    EnableAR()
end

-- Helper function to check if we have all the parts needed for a specific build for a submersible
function CheckIfWeHaveRequiredParts(abbreviation, submersible, character)
    local parts_needed = {}
    local part_counter = 1

    if abbreviation == "" then
        return false
    end

    -- If specific character not provided, set it to the logged in character
    if not character then
        character = GetCharacterName(true)
    end

    local function GetSlotName(part_number)
        if part_number == 1 then
            return "Hull"
        elseif part_number == 2 then
            return "Stern"
        elseif part_number == 3 then
            return "Bow"
        elseif part_number == 4 then
            return "Bridge"
        end
    end

    local i = 1
    while i <= #abbreviation do
        local current_abbr = abbreviation:sub(i, i)
        local next_char = abbreviation:sub(i + 1, i + 1)

        if current_abbr:match("%a") then
            local found = false
            if next_char == "+" then
                current_abbr = current_abbr .. "+"
                i = i + 1
            end

            for _, part in ipairs(Submersible_Part_List) do
                if part.PartAbbreviation == current_abbr and part.SlotName == GetSlotName(part_counter) then
                    local slot_name = part.SlotName
                    table.insert(parts_needed, { PartName = part.PartName, SlotName = slot_name })
                    found = true
                    part_counter = part_counter + 1
                    break
                end
            end

            if not found then
                LogToInfo(1, "CheckIfWeHaveRequiredParts: Invalid abbreviation sequence: " .. current_abbr)
                return false
            end
        end

        i = i + 1
    end

    if #parts_needed ~= 4 then
        LogToInfo(1, "CheckIfWeHaveRequiredParts: Exactly 4 parts must be identified.")
        return false
    end

    local character_parts_inventory = {}
    local found_character = false

    for character_name, parts in pairs(overseer_inventory_data) do
        if character_name == character then
            character_parts_inventory = parts
            found_character = true
            break
        end
    end

    if not found_character then
        LogToInfo(1, "CheckIfWeHaveRequiredParts: Character not found in inventory data: ".. character)
        return false
    end

    for k, part_entry in ipairs(parts_needed) do

        local sub_part_id = tonumber(submersible["part" .. k])
        local item_id = FindItemID(part_entry.PartName)

        if not ((character_parts_inventory[part_entry.PartName] > 0) or (item_id == sub_part_id)) then
            LogToInfo(1, "CheckIfWeHaveRequiredParts: Character ".. character .. " missing part name " .. part_entry.PartName .. " with id " .. sub_part_id .. " for "..abbreviation)
            return false
        end
    end
    LogToInfo(1, "CheckIfWeHaveRequiredParts: Character ".. character .. " has parts for "..abbreviation)
    return true
end

-- Timer to track how long we've been stuck on the voyage panel
VoyagePanelStuckTimer = 0

-- Function to handle unstucking from the voyage panel
local function VoyagePanelUnstucker()
    while IsAddonReady("SelectString") or IsAddonReady("AirShipExplorationResult") do
        Sleep(0.1)
        VoyagePanelStuckTimer = VoyagePanelStuckTimer + 0.1

        -- If stuck on the voyage panel for 2+ seconds
        if VoyagePanelStuckTimer >= 2 then
            -- Recall unstuck
            local node_text = GetNodeText("SelectString",2,1,3)
            if string.find(node_text, "Recall") then
                LogToInfo(1,"VoyagePanelUnstucker: Voyage panel unstucker triggered on recall menu")
                if IsAddonReady("SelectString") then
                    yield("/callback SelectString true -1")
                end
            end
            -- Voyage log unstuck
            if IsAddonReady("AirShipExplorationResult") and not ARIsBusy() then
                LogToInfo(1,"VoyagePanelUnstucker: Voyage panel unstucker triggered on AirShipExplorationResult menu")
                yield("/callback AirShipExplorationResult true -1")
                repeat
                    Sleep(0.1)
                until IsAddonReady("SelectString")
                yield("/callback SelectString true -1")
            end
            VoyagePanelStuckTimer = 0
        end
    end

    VoyagePanelStuckTimer = 0
    Sleep(0.1)
end

local title_screen_unstucker_timer = 0  -- Timer for stuck screen detection

-- Function to handle unstucking from the title screen
-- This is a workaround for the issue where the title screen gets stuck since AR is too fast
local function TitleScreenUnstucker()
    if not IsAddonReady("_CharaSelectTitle") and not IsAddonVisible("SelectOk") and not IsAddonVisible("SelectYesno") and not ARIsBusy() then
        title_screen_unstucker_timer = title_screen_unstucker_timer + 0.1
        if title_screen_unstucker_timer > 2 then
            if IsAddonReady("TitleDCWorldMapBg") then
                yield("/callback TitleDCWorldMap true 17 0")
            end

            yield("/callback _CharaSelectReturn true 19")
            title_screen_unstucker_timer = 0
        end
    else
        title_screen_unstucker_timer = 0
    end

    Sleep(0.215)
end

-- local function TitleScreenUnstucker()
--     if not IsAddonVisible("_TitleLogo") or IsAddonReady("TitleDCWorldMapBg") and not ARIsBusy() then
--         title_screen_unstucker_timer = title_screen_unstucker_timer + 0.1
--         if title_screen_unstucker_timer > 2 then
--             if IsAddonReady("TitleDCWorldMapBg") then
--                 yield("/callback TitleDCWorldMap true 17 0")
--             end

--             if IsAddonReady("_CharaSelectTitle") and not IsAddonVisible("SelectOk") and not IsAddonVisible("SelectYesno") and not ARIsBusy() then
--                 yield("/callback _CharaSelectReturn true 19")
--             end

--             if not IsAddonVisible("_TitleLogo") and not IsAddonVisible("_CharaSelectTitle") then
--                 yield("/send ESCAPE")
--             end

--             title_screen_unstucker_timer = 0
--         end
--     else
--         title_screen_unstucker_timer = 0
--     end

--     Sleep(0.2)
-- end


local function Main()
    ForceARSave()
    DisableAR()
    UpdateOverseerDataFile()
    CreateConfigBackup()
    AddUnlockPlansToDefaultConfig()
    AddPointPlansToDefaultConfig()
    UpdateAndLoadInventoryFile()
    EnforceRetainerSchedule()
    ModifyARConfig("MultiWaitOnLoginScreen", true)
    EnableAR()
    if correct_between_characters or correct_once_at_start_of_script then
        correct_once_at_start_of_script = false
        CheckAndCorrectAllCharacters()
    end

    ARSetMultiModeEnabled(true)
    LogToInfo(1, "Character data and global plans processing complete")
    LogToInfo(1, "All characters processed, starting main loop")

    local ar_finished = false
    local already_in_workshop = false
    local retainer_schedule_counter = 0
    local retainer_schedule_interval = 10 -- only check if the schedule should be updated every 10 loops

    while true do
        ar_finished = false
        already_in_workshop = false

        if IsPlayerAvailable() then
            -- Pause YesAlready since logged in
            if HasPlugin("YesAlready") then
                PauseYesAlready()
            end

            retainer_schedule_counter = 0
            local current_character = GetCharacterName(true)
            overseer_current_character = current_character

            if InExclusionList(current_character) then
                overseer_char_subs_excluded = true
            end

            LogToInfo(1, "Logged into: " .. current_character)
            UpdateAndLoadInventoryFile(true)
            yield("/at e")

            already_in_workshop = DoesObjectExist("Voyage Control Panel")

            if not DoesObjectExist("Entrance to Additional Chambers") and not already_in_workshop then
                ARSetMultiModeEnabled(true)
            end

            repeat Sleep(0.1) until DoesObjectExist("Entrance to Additional Chambers") or already_in_workshop

            ARSetMultiModeEnabled(false)
            ARAbortAllTasks()
            repeat Sleep(0.1) until IsPlayerAvailable()

            if not overseer_char_subs_excluded then
                PreARTasks()
            end

            if not DoesObjectExist("Summoning Bell") and not already_in_workshop then
                IfAdditionalEntranceExistsPathToIt()
            end

            while not ar_finished do
                if GetCharacterCondition(45) or GetCharacterCondition(51) then
                    repeat Sleep(0.1) until IsPlayerAvailable()
                end

                ARSetMultiModeEnabled(true)
                local target = GetTargetName()

                -- Submersible panel
                if target == "Voyage Control Panel" and not overseer_char_subs_excluded then
                    local submersible_waiting_override = 0
                    repeat Sleep(0.1) until not IsPlayerAvailable()

                    LogToInfo(1, "Entered voyage panel")
                    ARSetMultiModeEnabled(false)
                    repeat VoyagePanelUnstucker() until IsPlayerAvailable()

                    repeat
                        Sleep(0.5)
                        submersible_waiting_override = submersible_waiting_override + 1
                    until not SubsWaitingToBeProcessed() or submersible_waiting_override >= 10

                    LogToInfo(1, "Exited panel, running PostARTasks")
                    PostARTasks()
                end

                -- Retainer bell
                if target == "Summoning Bell" then
                    overseer_char_processing_retainers = true
                    local retainer_waiting_override = 0
                    repeat Sleep(0.1) until not IsPlayerAvailable()

                    LogToInfo(1, "In retainer menus")
                    Sleep(0.5)
                    ARSetMultiModeEnabled(false)
                    repeat Sleep(0.1) until IsPlayerAvailable()

                    repeat
                        Sleep(0.5)
                        retainer_waiting_override = retainer_waiting_override + 1
                    until not RetainersWaitingToBeProcessed() or retainer_waiting_override >= 10

                    LogToInfo(1, "Done with retainers, running PostARTasks")
                    PostARTasks()
                    overseer_char_processing_retainers = false
                end

                if GetCharacterCondition(53) then
                    if correct_between_characters then
                        ARAbortAllTasks()
                    end

                    ARSetMultiModeEnabled(false)
                    LogToInfo(1, current_character .. " finished and logged out")
                    ar_finished = true
                else
                    Sleep(0.499)
                end
            end

            already_in_workshop = false
            overseer_char_data = {}
            overseer_current_character = ""
            overseer_char_performed_gc_delivery = false
            overseer_char_bought_ceruleum = false
            overseer_char_processing_subs = false
            overseer_char_processing_retainers = false
            overseer_char_subs_excluded = false

            if correct_between_characters then
                CheckAndCorrectAllCharacters()
                repeat TitleScreenUnstucker() until IsAddonReady("_TitleMenu") -- Compatible with Title Edit
            end

            repeat Sleep(0.01) until not IsPlayerAvailable()
            if ShutdownNeeded() then
                AutoShutdown()
            else
                EnforceRetainerSchedule()
                repeat TitleScreenUnstucker() until IsAddonReady("_TitleMenu") -- Compatible with Title Edit
                ARSetMultiModeEnabled(true)
            end
        end

        if ShutdownNeeded() then
            AutoShutdown()
        end

        if enable_retainer_schedule then
            if retainer_schedule_counter >= retainer_schedule_interval then
                EnforceRetainerSchedule()
                ForceARSave()
                retainer_schedule_counter = 0
            else
                retainer_schedule_counter = retainer_schedule_counter + 1
            end
        end
        -- Restore YesAlready since logged out
        if HasPlugin("YesAlready") then
            RestoreYesAlready()
        end
        TitleScreenUnstucker()
        Sleep(0.8)
    end
end

Main()