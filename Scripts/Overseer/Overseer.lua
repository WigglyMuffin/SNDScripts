--[[
     ___                               
    / _ \__   _____ _ __ ___  ___  ___ _ __ 
   | | | \ \ / / _ \ '__/ __|/ _ \/ _ \ '__|
   | |_| |\ V /  __/ |  \__ \  __/  __/ |   
    \___/  \_/ \___|_|  |___/\___|\___|_|   
                  
####################
##    Version     ##
##     1.0.1      ##
####################

-> 1.0.1: Improved the backup functionality and adjusted a few things for consistency
-> 1.0.0: Initial release

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
-> Something Need Doing (Expanded Edition) : https://puni.sh/api/repository/croizat
-> Teleporter : In the default first party dalamud repository
-> TextAdvance : https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
-> vnavmesh : https://puni.sh/api/repository/veyn

####################################################
##                    Settings                    ##
##################################################]]

local venture_limit = 100                   -- Minimum value of ventures to trigger buying more ventures, requires Deliveroo to be correctly configured by doing GC deliveries
local inventory_slot_limit = 30             -- Amount of inventory slots remaining before attempting a GC delivery to free up slots
local buy_ceruleum = false                  -- Will attempt to buy ceruleum fuel based on the settings below, if set to false the characters will never attempt to refuel (buy ceruleum fuel off players)
local ceruleum_limit = 100                  -- Minimum value of ceruleum fuel to trigger buying ceruleum fuel
local ceruleum_buy_amount = 999             -- Amount of ceruleum fuel to be purchased when ceruleum_limit is triggered
local fc_credits_to_keep = 10000            -- How many credits to always keep, this limit will be ignored when buying FC buffs for GC deliveries
local use_fc_buff = false                   -- Will attempt to buy and use the seal sweetener buff when doing GC deliveries
local ar_collection_name = "AutoRetainer"   -- Name of the plugin collection which contains the "AutoRetainer" plugin

-- Configuration for retainer levels and venture types
-- min_level = minimum level value, starts at 0
-- max_level = maximum level value
-- venture_type = venture type the retainers should use. Options: "exploration" = Targeted Exploration, "quick" = Quick Exploration
-- saved_plan = GUID corresponding to the saved_plan below
-- !! Retainers not supported currently !!
local retainer_level_config = {
    {min_level = 0, max_level = 10, venture_type = "exploration", saved_plan = "00000000-0000-0000-0000-000000000000"},
    {min_level = 11, max_level = 100, venture_type = "quick", saved_plan = "00000000-0000-0000-0000-000000000000"},
}

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
local unlock_plans = {
    {   -- Pinned plan, good enough to unlock OJ but not optimal
        GUID = "579ba94d-4b73-4afe-9be1-999225e24af2",
        Name = "Overseer OJ Unlocker",
        ExcludedRoutes = {101,100,99,98,97,96,95,93,92,91,90,89,88,80,81,82,83,84,86,85,87,79,78,77,76,75,74,72,71,70,69,68,67,66,65,64,63,62,61,60,59,58,57,56,55,54,29,24,23,22,21,18,17,16,13,12,11,9,8,7,6,4,3,102,103,104,105,48,36,51,50,46,45,44,41,40,35,53},
        UnlockSubs = true
    },
    {   -- Overseer optimal, unlocks all salvage routes whilst being optimal (recommended)
        GUID = "31d90475-c6a1-4174-9f66-5ec2e1d01074",
        Name = "Overseer Optimal Unlocker",
        ExcludedRoutes = {3,6,13,22,23,24,29,36,40,41,45,44,46,48,50,51,54,56,58,60,63,64,66,67,68,69,71,80,86,90,92,103,105,107,109,110,112},
        UnlockSubs = true
    },
    -- Add more unlock plans here as needed
    -- {
    --     GUID = "another-guid-here",
    --     Name = "Another Unlock Plan",
    --     ExcludedRoutes = {1,2,3,4,5},
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
        Points = {15,10}
    },
    {   -- JORZ
        GUID = "04fbb61c-5800-40e6-8c67-2467796bf80e",
        Name = "Overseer JORZ",
        Points = {10,15,18,26}
    },
    {   -- MROJZ
        GUID = "644317d3-34e1-44f3-a950-5fa5bdc8de04",
        Name = "Overseer MROJZ",
        Points = {13,18,15,10,26}
    },
    -- Add more point plans here as needed
    -- {
    --     GUID = "another-guid-here",
    --     Name = "Another Point Plan",
    --     Points = {1,2,3,4,5}
    -- },
}

--[[################################################
##                  Script Start                  ##
##################################################]]

-- Load necessary libraries and set up paths
snd_config_folder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
vac_config_folder = snd_config_folder .. "\\VAC\\"
load_functions_file_location = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
auto_retainer_config_path = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\AutoRetainer\\DefaultConfig.json"
backup_folder = vac_config_folder .. "\\Overseer\\AR Config Backups\\"

LoadFunctions = loadfile(load_functions_file_location)()
LoadFileCheck()
EnsureFolderExists(vac_config_folder)
EnsureFolderExists(backup_folder)

-- Load JSON library from vac_functions
local json = CreateJSONLibrary()

if not CheckPluginsEnabled("AutoRetainer", "Deliveroo", "Lifestream", "SomethingNeedDoing", "TeleporterPlugin", "TextAdvance", "vnavmesh") then
    return -- Stops script as plugins not available
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

LogInfo("[Overseer] ##############################")
LogInfo("[Overseer] Starting script...")
LogInfo("[Overseer] snd_config_folder: " .. snd_config_folder)
LogInfo("[Overseer] ##############################")

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
    dest:close()

    -- Log the new backup
    local log_file_path = backup_folder .. "backup_log.txt"
    local log_file = io.open(log_file_path, "a")
    if log_file then
        log_file:write(backup_file .. "\n")
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

    LogInfo(string.format("[Overseer] Warning: Unable to find or infer abbreviation for part %s", part_name))
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
            LogInfo(string.format("[Overseer] Warning: Unable to find name for part ID %s", tostring(part_id)))
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

-- Helper function to get optimal build for submersible rank
local function GetOptimalBuildForRank(rank)
    for _, config in ipairs(submersible_build_config) do
        if rank >= config.min_rank and rank <= config.max_rank then
            return config.build, config.plan_type, config.unlock_plan, config.point_plan
        end
    end
    return nil, nil, nil, nil  -- Return nil for all values if no matching range found
end

-- Helper function to get unlock plan by GUID
local function GetUnlockPlanByGUID(guid)
    for _, plan in ipairs(unlock_plans) do
        if plan.GUID == guid then
            return plan
        end
    end
    return nil
end

-- Helper function to get point plan by GUID
local function GetPointPlanByGUID(guid)
    for _, plan in ipairs(point_plans) do
        if plan.GUID == guid then
            return plan
        end
    end
    return nil
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
    return math.floor(base_exp * 0.25)
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

    for i, rank_data in ipairs(Submersible_Rank_List) do
        if rank_data.Level == current_rank then
            while i < #Submersible_Rank_List do
                local next_rank_data = Submersible_Rank_List[i + 1]
                if remaining_exp >= next_rank_data.ExpToNext then
                    final_rank = next_rank_data.Level
                    remaining_exp = remaining_exp - next_rank_data.ExpToNext
                    i = i + 1
                else
                    break
                end
            end
            break
        end
    end

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
        venture_needs_change = false
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
        can_level_up = false,
        potential_level_up = false,
        exp_after_levelup = 0,
        points = ""
    }
end

-- Function to update character list and global plans
local function UpdateFromAutoRetainerConfig()
    local file, err = io.open(auto_retainer_config_path, "r")
    if not file then
        Echo("[Overseer] Error: Unable to open DefaultConfig.json: " .. tostring(err))
        LogInfo("[Overseer] Error: Unable to open DefaultConfig.json: " .. tostring(err))
        return nil
    end

    local content = file:read("*all")
    file:close()

    -- Remove BOM if present
    if content:sub(1, 3) == string.char(0xEF, 0xBB, 0xBF) then
        content = content:sub(4)
        LogInfo("[Overseer] BOM removed from the content")
    end

    local success, config = pcall(json.decode, content)
    if not success or not config then
        Echo("[Overseer] Error parsing JSON: " .. tostring(config))
        LogInfo("[Overseer] Error parsing JSON: " .. tostring(config))
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
        LogInfo(string.format("[Overseer] Processed FC: ID=%s, Name=%s, Holder=%s", fc_id_str, fc_info.Name, fc_data[fc_id_str].holder_chara))
    end

    local function insert_logged_in_player_gc(char)
        if string.lower(char) == string.lower(GetCharacterName(true)) then
            return GetPlayerGC()
        else
            return false
        end
    end

    local function insert_logged_in_player_fc_id(char)
        if string.lower(char) == string.lower(GetCharacterName(true)) then
            return GetFCGCID()
        else
            return false
        end
    end

    local function insert_logged_in_player_fc_rank(char)
        if string.lower(char) == string.lower(GetCharacterName(true)) then
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
                LogInfo(string.format("[Overseer] FC found for character %s: ID=%s, Name=%s", chara.name, fc.id, fc.name))
                fc_found = true
                break
            end
        end

        -- If no FC was found or FC id is "0", ensure default values are set
        if not fc_found or chara.free_company.id == "0" then
            chara.free_company = CreateDefaultFreeCompany(chara.server)
            chara.free_company.owner.id = chara.id
            chara.free_company.owner.name = chara.name
            LogInfo(string.format("[Overseer] No FC found for character %s", chara.name))
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

            -- Determine optimal venture type and if change is needed
            retainer_entry.current_venture_type = additional_retainer_data.CurrentVentureType or ""
            retainer_entry.optimal_venture_type, retainer_entry.optimal_saved_plan = GetOptimalVentureType(retainer_entry.level)
            retainer_entry.venture_needs_change = (retainer_entry.current_venture_type ~= retainer_entry.optimal_venture_type)

            table.insert(chara.retainers, retainer_entry)

            LogInfo(string.format("[Overseer] Processed retainer: %s (ID: %s)", retainer_name, retainer_id))
            LogInfo(string.format("[Overseer] Current venture type: %s", retainer_entry.current_venture_type))
            LogInfo(string.format("[Overseer] Optimal venture type: %s", retainer_entry.optimal_venture_type))
            LogInfo(string.format("[Overseer] Venture needs change: %s", tostring(retainer_entry.venture_needs_change)))
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
                    for _, enabled_sub in ipairs(enabled_submersibles_data) do
                        if enabled_sub == submersible_name then
                            return true -- Submersible is enabled
                        end
                    end
                    return false -- Submersible is not enabled
                end

                -- Function to determine what the best unlock mode to use is
                local function GetOptimalUnlockMode(sub_number, rank)
                    local optimal_build, optimal_plan_type, optimal_unlock_plan_guid, optimal_point_plan_guid = GetOptimalBuildForRank(rank)
                    if sub_number == 1 and optimal_plan_type == 3 and num_sub_slots < 4 then
                        return 1
                    else
                        return 2
                    end
                end

                -- Function to check if a plan needs change or not
                local function GetIfPlanNedsChange(sub_unlock_plan, sub_point_plan, sub_optimal_plan, sub_plan_type)
                    if sub_plan_type == 4 then
                        return (sub_point_plan ~= sub_optimal_plan)
                    else
                        return (sub_unlock_plan ~= sub_optimal_plan)
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
                    submersible.points = add_submersible_data.Points or ""
                    submersible.decoded_points = DecodeSubmersiblePoints(submersible.points) or {0, 0, 0, 0, 0}
                    submersible.route = DecodePointsToRoute(submersible.decoded_points)
                    submersible.return_time = submersible_data.ReturnTime

                    -- Calculate guaranteed and potential bonus exp
                    submersible.guaranteed_exp = CalculateGuaranteedExp(submersible.decoded_points)
                    submersible.potential_bonus_exp = EstimateMaxBonusExp(submersible.guaranteed_exp)

                    -- Determine if submersible can level up or potentially level up
                    submersible.can_level_up = (submersible.current_exp + submersible.guaranteed_exp >= submersible.next_level_exp)
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
                    local optimal_build, optimal_plan_type, optimal_unlock_plan_guid, optimal_point_plan_guid = GetOptimalBuildForRank(submersible.rank)

                    submersible.optimal_build = optimal_build or ""
                    submersible.optimal_plan_type = optimal_plan_type or 0
                    submersible.build_needs_change = (optimal_build ~= nil and submersible.build ~= optimal_build)

                    -- Determine optimal plan
                    if optimal_plan_type == 3 then
                        local unlock_plan = GetUnlockPlanByGUID(optimal_unlock_plan_guid)
                        submersible.optimal_plan = unlock_plan and unlock_plan.GUID or ""
                        submersible.optimal_plan_name = unlock_plan and unlock_plan.Name or ""
                        submersible.plan_needs_change = GetIfPlanNedsChange(submersible.selected_unlock_plan, submersible.selected_point_plan, submersible.optimal_plan, submersible.optimal_plan_type)
                    elseif optimal_plan_type == 4 then
                        local point_plan = GetPointPlanByGUID(optimal_point_plan_guid)
                        submersible.optimal_plan = point_plan and point_plan.GUID or ""
                        submersible.optimal_plan_name = point_plan and point_plan.Name or ""
                        submersible.plan_needs_change = GetIfPlanNedsChange(submersible.selected_unlock_plan, submersible.selected_point_plan, submersible.optimal_plan, submersible.optimal_plan_type)
                    else
                        submersible.optimal_plan = ""
                        submersible.optimal_plan_name = ""
                        submersible.plan_needs_change = false
                    end

                    -- Check if there's a different future optimal build
                    if submersible.rank_after_levelup > submersible.rank then
                        local future_optimal_build, future_optimal_plan_type, future_optimal_unlock_plan_guid, future_optimal_point_plan_guid = GetOptimalBuildForRank(submersible.rank_after_levelup)
                        if future_optimal_build ~= submersible.optimal_build then
                            submersible.future_optimal_build = future_optimal_build or ""
                            submersible.future_optimal_plan_type = future_optimal_plan_type or 0
                            submersible.build_needs_change_after_levelup = (future_optimal_build ~= nil and submersible.build ~= future_optimal_build)

                            -- Determine future optimal plan
                            if future_optimal_plan_type == 3 then
                                local future_unlock_plan = GetUnlockPlanByGUID(future_optimal_unlock_plan_guid)
                                submersible.future_optimal_plan = future_unlock_plan and future_unlock_plan.GUID or ""
                                submersible.future_optimal_plan_name = future_unlock_plan and future_unlock_plan.Name or ""
                                submersible.plan_needs_change_after_levelup = GetIfPlanNedsChange(submersible.selected_unlock_plan, submersible.selected_point_plan, submersible.future_optimal_plan, submersible.future_optimal_plan_type)
                            elseif future_optimal_plan_type == 4 then
                                local future_point_plan = GetPointPlanByGUID(future_optimal_point_plan_guid)
                                submersible.future_optimal_plan = future_point_plan and future_point_plan.GUID or ""
                                submersible.future_optimal_plan_name = future_point_plan and future_point_plan.Name or ""
                                submersible.plan_needs_change_after_levelup = GetIfPlanNedsChange(submersible.selected_unlock_plan, submersible.selected_point_plan, submersible.future_optimal_plan, submersible.future_optimal_plan_type)
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

                    submersible.build_needs_change_after_levelup = (future_optimal_build ~= nil and submersible.build ~= future_optimal_build)
                    
                    LogInfo(string.format("[Overseer] Processed submersible: %s", submersible.name))
                    LogInfo(string.format("[Overseer] Current rank: %d, Potential final rank: %d", submersible.rank, submersible.rank_after_levelup))
                    LogInfo(string.format("[Overseer] Current build: %s, Optimal build: %s, Future optimal build: %s", submersible.build, submersible.optimal_build, submersible.future_optimal_build))
                    LogInfo(string.format("[Overseer] Current plan type: %d, Future plan type: %d", submersible.optimal_plan_type, submersible.future_optimal_plan_type))
                    LogInfo(string.format("[Overseer] Current plan: %s, Future plan: %s", submersible.optimal_plan_name, submersible.future_optimal_plan_name))
                    LogInfo(string.format("[Overseer] Build needs change: %s, Plan needs change: %s", tostring(submersible.build_needs_change), tostring(submersible.plan_needs_change)))
                    LogInfo(string.format("[Overseer] Build needs change after levelup: %s, Plan needs change after levelup: %s", tostring(submersible.build_needs_change_after_levelup), tostring(submersible.plan_needs_change_after_levelup)))
                end

                table.insert(chara.submersibles, submersible)
            end
        else
            LogInfo(string.format("[Overseer] No submersibles created for character %s (No valid FC)", chara.name))
        end

        ar_character_data[chara_key] = chara
    end

    return ar_character_data, global_data
end

-- Function to save character data and global plans to a Lua file
local function SaveCharacterDataToFile(character_data, global_data)
    local file_name = "ar_character_data.lua"
    local file_path = snd_config_folder .. file_name
    local file, err = io.open(file_path, "w")

    if not file then
        Echo("[Overseer] Error: Unable to open file for writing: " .. tostring(err))
        LogInfo("[Overseer] Error: Unable to open file for writing: " .. tostring(err))
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

    file:write("    entrust_plans = {\n")
    for _, plan in ipairs(global_data.entrust_plans) do
        file:write("      {\n")
        file:write(string.format("        guid = \"%s\",\n", plan.guid))
        file:write(string.format("        name = \"%s\",\n", plan.name))
        file:write("        list = {\n")
        for _, item in ipairs(plan.list) do
            file:write(string.format("          { id = %d, num = %d },\n", item.ID, item.Num))
        end
        file:write("        },\n")
        file:write("      },\n")
    end
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
            file:write(string.format("          can_level_up = %s,\n", tostring(submersible.can_level_up)))
            file:write(string.format("          potential_level_up = %s,\n", tostring(submersible.potential_level_up)))
            file:write(string.format("          exp_after_levelup = %d,\n", submersible.exp_after_levelup))
            file:write("        },\n")
        end
        file:write("      },\n")
        file:write("    },\n")
    end
    file:write("  },\n")
    file:write("}\n")
    file:close()
    -- Echo("[Overseer] Character data and global plans saved to " .. file_path)
    LogInfo("[Overseer] Character data and global plans saved to " .. file_path)
end

-- Call this every time you want to update the ar_character_data file with new info
local function UpdateOverseerDataFile()
    local ar_character_data, global_data = UpdateFromAutoRetainerConfig()
    if not ar_character_data then
        local error_msg = "[Overseer] Error: Failed to update character list from DefaultConfig.json"
        Echo(error_msg)
        LogInfo(error_msg)
        return
    end
    SaveCharacterDataToFile(ar_character_data, global_data)
end

-- Load specific character data and return it
local function LoadOverseerCharacterData(character)
    LogInfo("[Overseer] Attempting to load data for " .. character)
    local overseer_data_file = snd_config_folder .. "ar_character_data.lua"

    -- Safely load the data using pcall to catch errors from dofile
    local success, overseer_data = pcall(dofile, overseer_data_file)
    if not success then
        LogInfo("[Overseer] Error: Failed to load overseer data file")
        return nil
    end

    local character_data = overseer_data.characters[character]
    if character_data then
        LogInfo("[Overseer] Successfully loaded data for " .. character)
        return character_data
    else
        LogInfo("[Overseer] Error: No data found for " .. character)
        return nil
    end
end

-- walks up to the vendor and buys/uses gc seal buff, should only be called when already at the GC
-- yeah this is a function of all time
local function UseFCBuff()
    UpdateOverseerDataFile()
    local char_data = LoadOverseerCharacterData(GetCharacterName(true))
    -- Attempt to use "Seal Sweetener II"
    if UseFCAction("Seal Sweetener II") then
        return true
    end

    local fc_gc_id = char_data.free_company.gc_id
    if fc_gc_id == 1 then
        yield("/li gc 1")
        Sleep(1)
        repeat
            Sleep(1)
        until not LifestreamIsBusy()
        Movement(93.46, 40.28, 71.52, 1)    -- Maelstrom
    elseif fc_gc_id == 2 then
        yield("/li gc 2")
        Sleep(1)
        repeat
            Sleep(1)
        until not LifestreamIsBusy()
        Movement(-70.24, -0.50, -7.09, 1)   -- Twin Adder
    elseif fc_gc_id == 3 then
        yield("/li gc 3")
        Sleep(1)
        repeat
            Sleep(1)
        until not LifestreamIsBusy()
        Movement(-143.86, 4.11, -104.04, 1) -- Immortal Flames
    end

    -- Try to buy "Seal Sweetener II" and use it
    local buy_action_II_success, buy_action_II_msg = BuyFCAction("Seal Sweetener II")
    if buy_action_II_success then
        if UseFCAction("Seal Sweetener II") then
            return true
        else
            return false, "Failed to use Seal Sweetener II"
        end
    elseif buy_action_II_msg == "Missing rank requirement" then
        -- If missing rank requirement, try to buy and use "Seal Sweetener"
        local buy_action_I_success, buy_action_I_msg = BuyFCAction("Seal Sweetener")
        if buy_action_I_success then
            if UseFCAction("Seal Sweetener") then
                return true
            else
                return false, "Failed to use Seal Sweetener"
            end
        else
            return false, "Failed to buy Seal Sweetener"
        end
    else
        return false, "Failed to buy Seal Sweetener II"
    end

    return true
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
    GCDeliverooExpertDelivery() -- Call a function from vac_functions
    LogInfo("[Overseer] GC run finished, resuming multi")
    ARSetMultiModeEnabled(true)
    Teleporter("li","fc")
end

-- Simple function to force ar to save to file, since for some reason closing/opening the ui does this
local function ForceARSave()
    yield("/ays")
    Sleep(0.1)
    yield("/ays")
    Sleep(0.5) -- Some extra time to save, just in case
end

-- Will run after AR has finished processing if a submersible can be created
local function RegisterSubmersible()
    ARSetMultiModeEnabled(false)
    if not IsPlayerAvailable() then
        Echo("Player isn't available, register submersible attempt")
        return
    end

    PathToObject("Voyage Control Panel", 2) -- Move to the Voyage Control Panel
    Target("Voyage Control Panel")
    Sleep(0.5)
    yield("/lockon")
    Sleep(0.5)
    yield("/interact")
    repeat
        Sleep(0.1)
    until IsAddonReady("SelectString")
    yield("/callback SelectString true 1")
    repeat
        Sleep(0.1)
    until IsAddonReady("SelectString")
    RegisterNewSubmersible() -- calls the function from vac_functions
    repeat
        Sleep(0.1)
    until IsAddonReady("SelectString")
    yield("/callback SelectString true -1 0")
    repeat
        Sleep(0.1)
    until IsAddonReady("SelectString")
    yield("/callback SelectString true -1 0")
end

-- Function to enable a specific submersible number for a character
local function EnableSubmersible(submersible_number)
    UpdateOverseerDataFile()
    local char_data = LoadOverseerCharacterData(GetCharacterName(true))

    local function append_submersible_to_cid(file_path, target_cid, submersible_name)
        local file = io.open(file_path, "r")
        if not file then
            return nil, "Unable to open file"
        end
        local cid_pattern = '"CID": ' .. target_cid .. ','
        local lines = {}
        local modified = false
        local enabled_subs_started = false
        local duplicate_found = false

        for line in file:lines() do
            table.insert(lines, line)

            if line:find(cid_pattern, 1, true) then
                for sub_line in file:lines() do
                    table.insert(lines, sub_line)

                    if sub_line:find('"EnabledSubs":', 1, true) then
                        enabled_subs_started = true
                    end

                    if enabled_subs_started then

                        if sub_line:find('"' .. submersible_name .. '"', 1, true) then
                            duplicate_found = true
                            break
                        end

                        if sub_line:find("%[%s*%]") then
                            lines[#lines] = '      "EnabledSubs": [\n        "' .. submersible_name .. '"\n      ],'
                            modified = true
                        elseif sub_line:find("]", 1, true) then
                            local last_line = lines[#lines]
                            local last_sub_line = lines[#lines - 1]

                            if not last_line:find("%[") then
                                last_sub_line = last_sub_line:gsub("%s*$", ",")
                                lines[#lines - 1] = last_sub_line
                                lines[#lines] = '        "' .. submersible_name .. '"\n      ],'
                            end
                            modified = true
                        end
                    end

                    if modified and sub_line:find("]", 1, true) then
                        enabled_subs_started = false
                        break
                    end
                end
            end
        end
        file:close()

        if duplicate_found then
            return nil, "Submersible already enabled."
        elseif modified then
            local out_file = io.open(file_path, "w")
            for _, modified_line in ipairs(lines) do
                out_file:write(modified_line .. "\n")
            end
            out_file:close()
            return true, "Successfully enabled submersible."
        end
        return nil, "CID not found or no modification made"
    end

    local submersible_name = ""
    for _, submersible in ipairs(char_data.submersibles) do
        if submersible.number == submersible_number then
            submersible_name = submersible.name
        end
    end
    if submersible_name ~= "" then
        local cid_to_find = char_data.id
        local success, msg = append_submersible_to_cid(auto_retainer_config_path, cid_to_find, submersible_name)
        if success then
            Echo(msg)
        else
            Echo("Error: " .. msg)
        end
    else
        LogInfo("[Overseer] Requested submersible doesn't have a name, not appending")
        return
    end
end

-- Function to disable a specific submersible number for a character
local function DisableSubmersible(submersible_number)
    UpdateOverseerDataFile()
    local char_data = LoadOverseerCharacterData(GetCharacterName(true))

    local function remove_submersible_from_cid(file_path, target_cid, submersible_name)
        local file = io.open(file_path, "r")
        if not file then
            return nil, "Unable to open file"
        end
        local cid_pattern = '"CID": ' .. target_cid .. ','
        local lines = {}
        local enabled_subs_started = false
        local sub_found = false

        for line in file:lines() do
            table.insert(lines, line)

            if line:find(cid_pattern, 1, true) then

                for sub_line in file:lines() do
                    table.insert(lines, sub_line)

                    if sub_line:find('"EnabledSubs":', 1, true) then
                        enabled_subs_started = true
                    end

                    if enabled_subs_started then

                        if sub_line:find('"' .. submersible_name .. '"', 1, true) then
                            sub_found = true
                            table.remove(lines, #lines)
                        end

                        if sub_line:find("]", 1, true) then
                            if sub_found then

                                if lines[#lines - 1]:find("%[") and not lines[#lines - 1]:find(",") then
                                    lines[#lines -1] = '      "EnabledSubs": [],'
                                    table.remove(lines, #lines)
                                else
                                    local prev_line = lines[#lines - 1]
                                    lines[#lines - 1] = prev_line:gsub(",%s*$", "")
                                end
                            end
                            enabled_subs_started = false
                            break
                        end
                    end
                end
            end
        end
        file:close()

        if sub_found then
            local out_file = io.open(file_path, "w")
            for _, modified_line in ipairs(lines) do
                out_file:write(modified_line .. "\n")
            end
            out_file:close()
            return true, "Successfully disabled submersible."
        end
        return nil, "Submersible not found or no modification made"
    end

    local submersible_name = ""
    for _, submersible in ipairs(char_data.submersibles) do
        if submersible.number == submersible_number then
            submersible_name = submersible.name
        end
    end
    if submersible_name ~= "" then
        local cid_to_find = char_data.id
        local success, msg = remove_submersible_from_cid(auto_retainer_config_path, cid_to_find, submersible_name)
        if success then
            Echo(msg)
        else
            Echo("Error: " .. msg)
        end
    else
        LogInfo("[Overseer] Requested submersible doesn't have a name, not removing")
        return
    end
end

-- Function to Set specific unlock mode for a submersible
local function ModifyAdditionalSubmersibleData(submersible_number, config, config_option)
    UpdateOverseerDataFile()
    local char_data = LoadOverseerCharacterData(GetCharacterName(true))

    local function update_config_in_additional_data(file_path, target_cid, submersible_name, config, config_option)
        local file = io.open(file_path, "r")
        if not file then
            return nil, "Unable to open file"
        end

        local cid_pattern = '"CID": ' .. target_cid .. ','
        local lines = {}
        local modified = false
        local additional_data_started = false
        local in_submersible_data = false
        local config_found = false

        for line in file:lines() do
            table.insert(lines, line)

            if line:find(cid_pattern, 1, true) then
                additional_data_started = true
            end

            if additional_data_started then

                if line:find('"Ceruleum":', 1, true) then
                    break 
                end

                if line:find('"AdditionalSubmarineData":', 1, true) then

                    while true do
                        line = file:read()

                        if not line then break end

                        if line:find('"' .. submersible_name .. '"', 1, true) then
                            in_submersible_data = true
                        end

                        if in_submersible_data then

                            if line:find('"' .. config .. '":') then
                                config_found = true
                                line = line:gsub('"' .. config .. '": "%s*[^"]-%s*"', '"' .. config .. '": "' .. config_option .. '"')
                                line = line:gsub('"' .. config .. '": %s*(%d+)', '"' .. config .. '": ' .. config_option) -- Update for numeric values
                                modified = true
                            end
                        end

                        table.insert(lines, line)

                        if line:find("}", 1, true) then
                            if in_submersible_data then
                                in_submersible_data = false
                            elseif line:find('"AdditionalSubmarineData":') then
                                break
                            end
                        end
                    end
                end
            end
        end
        file:close()

        if modified and config_found then
            local out_file = io.open(file_path, "w")
            for _, modified_line in ipairs(lines) do
                out_file:write(modified_line .. "\n")
            end
            out_file:close()
            return true, config .. " updated successfully."
        end
        return nil, "Submersible not found or no modification made."
    end
    

    if char_data.submersibles[submersible_number].build == "" then
        Echo("No submersible with that number found.")
        return
    end

    local submersible_name = ""
    for _, submersible in ipairs(char_data.submersibles) do
        if submersible.number == submersible_number then
            submersible_name = submersible.name
            break
        end
    end

    if submersible_name == "" then
        Echo("No submersible found with the given number.")
        return
    end

    local cid_to_find = char_data.id
    local success, msg = update_config_in_additional_data(auto_retainer_config_path, cid_to_find, submersible_name, config, config_option)

    if success then
        Echo(msg)
    else
        Echo("Error: " .. msg)
    end
end

-- Function to handle any tasks that need to be done before AR does it's things, like part swapping
local function PreARTasks()
    UpdateOverseerDataFile()
    local char_data = LoadOverseerCharacterData(GetCharacterName(true))

    --[[
    Enable all disabled character subs
    ]]
    for _, submersible in ipairs(char_data.submersibles) do -- Enable all disabled subs
        if not submersible.enabled and submersible.name ~= "" then
            if HasPlugin("AutoRetainer") then
                ManageCollection(ar_collection_name, false)
                Sleep(1.0)
                repeat
                    Sleep(0.1)
                until not HasPlugin("AutoRetainer")
            end
            EnableSubmersible(submersible.number)
        end
        UpdateOverseerDataFile()
        char_data = LoadOverseerCharacterData(GetCharacterName(true))
    end

    --[[
    Change all needed plans
    ]]
    for _, submersible in ipairs(char_data.submersibles) do
        if (submersible.plan_needs_change or submersible.vessel_behavior ~= submersible.optimal_plan_type or submersible.optimal_unlock_mode ~= submersible.unlock_mode) and submersible.name ~= "" then
            if HasPlugin("AutoRetainer") then
                ManageCollection(ar_collection_name, false)
                Sleep(1.0)
                repeat
                    Sleep(0.1)
                until not HasPlugin("AutoRetainer")
            end
            ModifyAdditionalSubmersibleData(submersible.number,"VesselBehavior",submersible.optimal_plan_type)
            ModifyAdditionalSubmersibleData(submersible.number,"UnlockMode", submersible.optimal_unlock_mode)
            if submersible.optimal_plan_type == 4 then
                ModifyAdditionalSubmersibleData(submersible.number,"SelectedPointPlan",submersible.optimal_plan)
            else
                ModifyAdditionalSubmersibleData(submersible.number,"SelectedUnlockPlan",submersible.optimal_plan)
            end
        end
        UpdateOverseerDataFile()
        char_data = LoadOverseerCharacterData(GetCharacterName(true))
    end

    --[[
    Check and set any subs that need a build swap to finalize
    ]]
    for _, submersible in ipairs(char_data.submersibles) do
        if (submersible.future_optimal_build ~= "" or submersible.build ~= submersible.optimal_build) and submersible.name ~= "" and submersible.vessel_behavior ~= 0 then
            if HasPlugin("AutoRetainer") then
                ManageCollection(ar_collection_name, false)
                Sleep(1.0)
                repeat
                    Sleep(0.1)
                until not HasPlugin("AutoRetainer")
            end
            ModifyAdditionalSubmersibleData(submersible.number,"VesselBehavior", 0)
        end
        UpdateOverseerDataFile()
        char_data = LoadOverseerCharacterData(GetCharacterName(true))
    end

    -- Enable AR again if it was disabled
    if not HasPlugin("AutoRetainer") then
        ManageCollection(ar_collection_name, true)
        Sleep(1.0)
        repeat
            Sleep(0.5)
        until HasPlugin("AutoRetainer") and type(ARGetInventoryFreeSlotCount()) == "number"
        yield("/ays")
    end
    ARSetMultiModeEnabled(true)
end

-- Function to handle any tasks that need to be done after AR is finished
local function PostARTasks()
    -- Wait until the player is available before updating any data, to try to ensure the data is properly saved so we can use it.
    repeat
        Sleep(0.1)
    until IsPlayerAvailable()

    -- variables
    local overseer_need_ceruleum = false
    local overseer_need_expert_delivery = false

    -- Try to force a save and load the character data
    ForceARSave()
    UpdateOverseerDataFile()
    CreateConfigBackup()
    local char_data = LoadOverseerCharacterData(GetCharacterName(true))

    -- Check if we need to buy ceruleum
    if not overseer_need_ceruleum and buy_ceruleum then
        LogInfo(char_data.ceruleum)
        if char_data.ceruleum <= ceruleum_limit then
            LogInfo("[Overseer] Setting overseer_need_ceruleum variable to true")
            overseer_need_ceruleum = true
        end
    end

    -- Check if we even have any retainers
    if char_data.retainers and char_data.retainers[1] and char_data.retainers[1].name then
        -- Check if we need to perform a GC delivery based on venture or inventory limits
        if char_data.ventures < venture_limit then
            LogInfo("[Overseer] Under Venture limit, disabling Multi and doing a GC run")
            overseer_need_expert_delivery = true
        elseif GetInventoryFreeSlotCount() < inventory_slot_limit then
            LogInfo("[Overseer] Under Inventory limit, disabling Multi and doing a GC run")
            overseer_need_expert_delivery = true
        end
    end

    -- Check and handle if we need to register any submarines
    for _, submersible in ipairs(char_data.submersibles) do
        if submersible.unlocked and submersible.name == "" then
            RegisterSubmersible()
            ForceARSave()
            Sleep(2)
            UpdateOverseerDataFile()
            char_data = LoadOverseerCharacterData(GetCharacterName(true))
            if HasPlugin("AutoRetainer") then
                ManageCollection(ar_collection_name, false)
            end
            Sleep(1.0)
            repeat
                Sleep(0.5)
            until not HasPlugin("AutoRetainer")
            for _, submersible in ipairs(char_data.submersibles) do
                if not submersible.enabled and submersible.name ~= "" then
                    EnableSubmersible(submersible.number)
                    ModifyAdditionalSubmersibleData(submersible.number,"VesselBehavior",submersible.optimal_plan_type)
                    if submersible.optimal_plan_type == 4 then
                        ModifyAdditionalSubmersibleData(submersible.number,"SelectedPointPlan",submersible.optimal_plan)
                    else
                        ModifyAdditionalSubmersibleData(submersible.number,"SelectedUnlockPlan",submersible.optimal_plan)
                    end
                end
            end
            UpdateOverseerDataFile()
            char_data = LoadOverseerCharacterData(GetCharacterName(true))
            break
        end
    end

    -- Check and handle if we need to swap builds of a submarine
    local in_submersible_menu = false
    local swap_done = false
    for _, submersible in ipairs(char_data.submersibles) do
        if submersible.build ~= submersible.optimal_build and submersible.name ~= "" then
            if not in_submersible_menu then
                PathToObject("Voyage Control Panel", 2) -- Move to the Voyage Control Panel
                Target("Voyage Control Panel")
                Sleep(0.5)
                yield("/lockon")
                Sleep(1)
                yield("/interact")
                repeat
                    Sleep(0.1)
                until IsAddonReady("SelectString")
                yield("/callback SelectString true 1")
                repeat
                    Sleep(0.1)
                until IsAddonReady("SelectString")
                in_submersible_menu = true
            end
            yield("/callback SelectString true "..(submersible.number - 1))
            repeat
                Sleep(0.1)
            until IsAddonReady("SelectString")
            local node_text = GetNodeText("SelectString",2,1,3)
            if string.find(node_text, "Recall") then -- Handling if a sub is somehow not done when this is called
                yield("/callback SelectString true 0")
                repeat
                    Sleep(0.1)
                until IsAddonReady("AirShipExplorationDetail")
                yield("/callback AirShipExplorationDetail true 0")
                repeat
                    Sleep(0.1)
                until IsAddonReady("SelectYesno")
                yield("/callback SelectYesno true 0")
                repeat
                    Sleep(0.1)
                until IsAddonReady("SelectString")
                Sleep(0.5)
            end
            if HasPlugin("AutoRetainer") then
                ManageCollection(ar_collection_name, false)
                Sleep(1.0)
                repeat
                    Sleep(0.5)
                until not HasPlugin("AutoRetainer")
            end
            yield("/callback SelectString true 2")
            repeat
                Sleep(0.1)
            until IsAddonReady("CompanyCraftSupply")
            ChangeSubmersibleParts(submersible.optimal_build)
            yield("/callback CompanyCraftSupply true 5")
            repeat
                Sleep(0.1)
            until IsAddonReady("SelectString")
            yield("/callback SelectString true -1 0")
            repeat
                Sleep(0.1)
            until IsAddonReady("SelectString")
            swap_done = true
            ModifyAdditionalSubmersibleData(submersible.number,"VesselBehavior",submersible.optimal_plan_type)
            if submersible.optimal_plan_type == 4 then
                ModifyAdditionalSubmersibleData(submersible.number,"SelectedPointPlan",submersible.optimal_plan)
            else
                ModifyAdditionalSubmersibleData(submersible.number,"SelectedUnlockPlan",submersible.optimal_plan)
            end
        end
        UpdateOverseerDataFile()
        char_data = LoadOverseerCharacterData(GetCharacterName(true))
    end
    if swap_done then
        yield("/callback SelectString true -1 0")
        repeat
            Sleep(0.1)
        until IsAddonReady("SelectString") or IsPlayerAvailable()
        yield("/callback SelectString true -1 0")
        repeat
            Sleep(0.1)
        until IsAddonReady("SelectString") or IsPlayerAvailable()
    end

    -- Reenable AutoRetainer if it's disabled
    if not HasPlugin("AutoRetainer") then
        ManageCollection(ar_collection_name, true)
        Sleep(1.0)
        repeat
            Sleep(0.5)
        until HasPlugin("AutoRetainer") and type(ARGetInventoryFreeSlotCount()) == "number"
        yield("/ays")
    end

    -- Handle any subs we might have modified
    if ARSubsWaitingToBeProcessed() then
        ARSetMultiModeEnabled(true)
        repeat
            Sleep(1.0)
        until not ARSubsWaitingToBeProcessed()
        ARSetMultiModeEnabled(false)
        repeat
            Sleep(0.1)
        until IsPlayerAvailable()
    end

    -- Run this if we need ceruleum
    if overseer_need_ceruleum then
        local function CalculateCeruleumPurchase()
            local ceruleum_price = 100

            local available_credits = char_data.free_company.credits - fc_credits_to_keep
            local max_ceruleum_to_buy = math.floor(available_credits / ceruleum_price)
            local amount_to_buy = math.min(ceruleum_buy_amount, max_ceruleum_to_buy)

            return amount_to_buy
        end

        local amount_to_buy = CalculateCeruleumPurchase()

        if amount_to_buy > 0 then
            BuyCeruleum(amount_to_buy)
        else
            Echo("Not enough credits to purchase ceruleum without going below the limit.")
        end
    end

    -- Run this if we need to do an expert delivery
    if overseer_need_expert_delivery then
        LogInfo("Attempting GC Expert Delivery")
        PerformGCDelivery()
    end

end

-- Function to add all listed unlock plans to the autoretainer default config
local function AddUnlockPlansToDefaultConfig()
    UpdateOverseerDataFile()

    local function load_existing_plans(file_path)
        local file = io.open(file_path, "r")
        if not file then
            return nil, "Unable to open file"
        end

        local content = file:read("*a")

        -- Remove BOM if present
        if content:sub(1, 3) == string.char(0xEF, 0xBB, 0xBF) then
            content = content:sub(4)
            LogInfo("[Overseer] BOM removed from the content")
        end

        file:close()

        local data, pos, err = json.decode(content, 1)
        if err then
            return nil, "Error parsing JSON: " .. err
        end

        return data.SubmarineUnlockPlans or {}
    end

    local function append_unlock_plan(file_path, plan)
        local existing_plans, err = load_existing_plans(file_path)
        if err then
            return nil, err
        end

        for _, existing_plan in ipairs(existing_plans) do
            if existing_plan.GUID == plan.GUID then
                return nil, "Unlock plan already exists."
            end
        end

        if HasPlugin("AutoRetainer") then
            ManageCollection(ar_collection_name, false)
        end
        Sleep(1.0)

        local file = io.open(file_path, "r")
        if not file then
            return nil, "Unable to open file"
        end

        local lines = {}
        local modified = false
        local plans_started = false
        local read_too_far = false

        for line in file:lines() do
            table.insert(lines, line)

            if line:find('"HideAirships":', 1, true) then
                read_too_far = true
            end

            if line:find('"SubmarineUnlockPlans":', 1, true) and not read_too_far then
                plans_started = true
                if line:find("%[%s*%]") then
                    lines[#lines] = '  "SubmarineUnlockPlans": [\n' ..
                        string.format('    {\n      "GUID": "%s",\n      "Name": "%s",\n      "ExcludedRoutes": [\n        %s\n      ],\n      "UnlockSubs": %s\n    }',
                            plan.GUID, plan.Name,
                            table.concat(plan.ExcludedRoutes, ', \n        '),
                            tostring(plan.UnlockSubs):lower()) .. '\n  ],'
                    modified = true
                end
            elseif plans_started and line:find("}", 1, true) and not read_too_far then

                for i = #lines, 1, -1 do
                    if lines[i]:find("}", 1, true) then
                        table.insert(lines, i, "    },")
                        table.insert(lines, i + 1,
                            string.format('    {\n      "GUID": "%s",\n      "Name": "%s",\n      "ExcludedRoutes": [\n        %s\n      ],\n      "UnlockSubs": %s',
                                plan.GUID, plan.Name,
                                table.concat(plan.ExcludedRoutes, ', \n        '),
                                tostring(plan.UnlockSubs):lower()))
                        modified = true
                        break
                    end
                end

                if modified then
                    lines[#lines - 1] = lines[#lines - 1]:gsub(",%s*}", "}")
                end
                plans_started = false
            end
        end

        file:close()

        if modified then
            local out_file = io.open(file_path, "w")
            for _, modified_line in ipairs(lines) do
                out_file:write(modified_line .. "\n")
            end
            out_file:close()
            return true, "Successfully added unlock plan."
        end

        return nil, "No modification made."
    end

    for _, plan in ipairs(unlock_plans) do
        local success, msg = append_unlock_plan(auto_retainer_config_path, plan)
        if success then
            Echo(msg)
        else
            LogInfo("Error: " .. msg)
        end
    end
end

local function AddPointPlansToDefaultConfig()
    UpdateOverseerDataFile()

    local function load_existing_plans(file_path)
        local file = io.open(file_path, "r")
        if not file then
            return nil, "Unable to open file"
        end

        local content = file:read("*a")

        -- Remove BOM if present
        if content:sub(1, 3) == string.char(0xEF, 0xBB, 0xBF) then
            content = content:sub(4)
            LogInfo("[Overseer] BOM removed from the content")
        end

        file:close()

        local data, pos, err = json.decode(content, 1)
        if err then
            return nil, "Error parsing JSON: " .. err
        end

        return data.SubmarinePointPlans or {}
    end

    local function append_point_plan(file_path, plan)
        local existing_plans, err = load_existing_plans(file_path)
        if err then
            return nil, err
        end

        for _, existing_plan in ipairs(existing_plans) do
            if existing_plan.GUID == plan.GUID then
                return nil, "Point plan already exists."
            end
        end

        if HasPlugin("AutoRetainer") then
            ManageCollection(ar_collection_name, false)
        end
        Sleep(1.0)

        local file = io.open(file_path, "r")
        if not file then
            return nil, "Unable to open file"
        end

        local lines = {}
        local modified = false
        local plans_started = false
        local read_too_far = false

        for line in file:lines() do
            table.insert(lines, line)

            if line:find('"MultiMinInventorySlots":', 1, true) then
                read_too_far = true
            end

            if line:find('"SubmarinePointPlans":', 1, true) and not read_too_far then
                plans_started = true
                if line:find("%[%s*%]") then
                    lines[#lines] = '  "SubmarinePointPlans": [\n' ..
                        string.format('    {\n      "GUID": "%s",\n      "Name": "%s",\n      "Points": [\n        %s\n      ]\n    }',
                            plan.GUID, plan.Name,
                            table.concat(plan.Points, ', \n        ')) .. '\n  ],'
                    modified = true
                end
            elseif plans_started and line:find("}", 1, true) and not read_too_far then

                for i = #lines, 1, -1 do
                    if lines[i]:find("}", 1, true) then
                        table.insert(lines, i, "    },")
                        table.insert(lines, i + 1,
                            string.format('    {\n      "GUID": "%s",\n      "Name": "%s",\n      "Points": [\n        %s\n      ]',
                            plan.GUID, plan.Name,
                            table.concat(plan.Points, ', \n        ')))
                        modified = true
                        break
                    end
                end

                if modified then
                    lines[#lines - 1] = lines[#lines - 1]:gsub(",%s*}", "}")
                end
                plans_started = false
            end
        end

        file:close()

        if modified then
            local out_file = io.open(file_path, "w")
            for _, modified_line in ipairs(lines) do
                out_file:write(modified_line .. "\n")
            end
            out_file:close()
            return true, "Successfully added point plan."
        end

        return nil, "No modification made."
    end

    for _, plan in ipairs(point_plans) do
        local success, msg = append_point_plan(auto_retainer_config_path, plan)
        if success then
            Echo(msg)
        else
            LogInfo("Error: " .. msg)
        end
    end
end

-- This needs to be cleaned up and the variables need to be done in a better way, but it's an early draft
local function Main()
    UpdateOverseerDataFile()
    CreateConfigBackup()
    AddUnlockPlansToDefaultConfig()
    AddPointPlansToDefaultConfig()
    Echo("[Overseer] Character data and global plans processing complete")
    LogInfo("[Overseer] All characters processed, starting main loop")

    -- Main overseer loop

    while true do
        if IsPlayerAvailable() and GetCharacterName() then
            yield("/at e") -- Enable textadvance

            LogInfo("[Overseer] Logged into character " .. GetCharacterName(true))

            -- Load the character's saved data
            LogInfo("[Overseer] Loading character data")

            -- Perform pre AR tasks
            PreARTasks()

            -- Loops until AR is done with all it's tasks
            local ar_finished = false
            local likely_waiting_for_part_swap = false
            while not ar_finished do
                if not IsPlayerAvailable() then
                    repeat
                        Sleep(0.1)
                    until IsPlayerAvailable()
                end
                UpdateOverseerDataFile()
                local char_data = LoadOverseerCharacterData(GetCharacterName(true))

                if not ARRetainersWaitingToBeProcessed() then
                    for _, submersible in ipairs(char_data.submersibles) do
                        if submersible.build ~= submersible.optimal_build and submersible.name ~= "" and submersible.return_time == 0 then
                            likely_waiting_for_part_swap = true
                        end
                    end
                end
                if (not ARAnyWaitingToBeProcessed() and not ARIsBusy()) or (not ARRetainersWaitingToBeProcessed() and not ARIsBusy() and ARSubsWaitingToBeProcessed() and likely_waiting_for_part_swap) then -- Needs better handling
                    ARSetMultiModeEnabled(false) -- Disable multi so we can safely check tasks
                    ar_finished = true
                end
                Sleep(1.0)
            end

            -- Run overseer post AutoRetainer tasks
            PostARTasks()

            if not ARGetMultiModeEnabled() then
                ARSetMultiModeEnabled(true)
            end

            repeat
                Sleep(1.0)
            until not IsPlayerAvailable() or not GetCharacterName()
        end

        -- Sleep and check again in case player is unavailable
        Sleep(1.0)
    end
end

--This is the old main function, for testing only
-- local function Main()
--     CreateConfigBackup()
--     Echo("[Overseer] Character data and global plans processing complete")
--     LogInfo("[Overseer] All characters and global plans processed, script finished")
-- end
-- Run the main function
Main()

if HasPlugin("YesAlready") then
    RestoreYesAlready()
end