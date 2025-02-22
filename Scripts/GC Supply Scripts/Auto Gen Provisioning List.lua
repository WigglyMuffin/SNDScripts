--[[
                _           _____              _____                _     _             _               _      _     _   
     /\        | |         / ____|            |  __ \              (_)   (_)           (_)             | |    (_)   | |  
    /  \  _   _| |_ ___   | |  __  ___ _ __   | |__) | __ _____   ___ ___ _  ___  _ __  _ _ __   __ _  | |     _ ___| |_ 
   / /\ \| | | | __/ _ \  | | |_ |/ _ \ '_ \  |  ___/ '__/ _ \ \ / / / __| |/ _ \| '_ \| | '_ \ / _` | | |    | / __| __|
  / ____ \ |_| | || (_) | | |__| |  __/ | | | | |   | | | (_) \ V /| \__ \ | (_) | | | | | | | | (_| | | |____| \__ \ |_ 
 /_/    \_\__,_|\__\___/   \_____|\___|_| |_| |_|   |_|  \___/ \_/ |_|___/_|\___/|_| |_|_|_| |_|\__, | |______|_|___/\__|
                                                                                                 __/ |                   
                                                                                                |___/                    

####################
##    Version     ##
##     1.0.2      ##
####################

-> 1.0.0: Initial release
-> 1.0.1: Duplicate name across worlds fix
-> 1.0.2: Merged Auto Gen Provisioning List script with Generate list of items to gather script

####################################################
##                  Description                   ##
####################################################

https://github.com/WigglyMuffin/SNDScripts

This script will automatically cycle through your characters and generate a list of items needed for GC supply
A list will be generated and output to the SND config folder saved as a file (provisioning_list.lua)
Which will be used to create another file (list_to_gather.txt) to show which items are needed for the rest of the scripts to function

Edit vac_char_list.lua (character_list) for configuring characters if using an external list

####################################################
##                  Requirements                  ##
####################################################

-> AutoRetainer : https://love.puni.sh/ment.json
-> Lifestream : https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
-> Something Need Doing (Expanded Edition) : https://puni.sh/api/repository/croizat
-> Teleporter : In the default first party dalamud repository
-> TextAdvance : https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
-> vnavmesh : https://puni.sh/api/repository/veyn

####################################################
##                    Settings                    ##
##################################################]]

local level_cap = 100                    -- Job level cap, adjust according to your current level cap
local skip_level_capped_jobs = true      -- Options: true = Will skip level capped jobs, false = Will not skip level capped jobs
local min_enabled = true                 -- Options: true = Will store MIN items, false = Will skip MIN items
local btn_enabled = true                 -- Options: true = Will store BTN items, false = Will skip BTN items
local fsh_enabled = true                 -- Options: true = Will store FSH items, false = Will skip FSH items

-- Options: true = Uses the external character list in the same folder, default name being char_list.lua, false = Uses the list you put in this file
local use_external_character_list = true

-- This is where you put your character list if you choose to not use the external one
-- If use_external_character_list is set to true then this list is completely skipped
local character_list = {
    "First Last@Server",
    "First Last@Server"
}

--[[################################################
##                  Script Start                  ##
##################################################]]

char_list = "vac_char_list.lua"
provisioning_list_save_name = "provisioning_list.lua"

snd_config_folder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
vac_config_folder = snd_config_folder .. "\\VAC\\"
load_functions_file_location = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(load_functions_file_location)()
LoadFileCheck()

-- Plugin checker
local required_plugins = {
    AutoRetainer = "4.4.4",
    TeleporterPlugin = "2.0.2.5",
    Lifestream = "2.3.2.8",
    SomethingNeedDoing = "1.75",
    TextAdvance = "3.2.4.4",
    vnavmesh = "0.0.0.54"
}

if not CheckPlugins(required_plugins) then
    return -- Stops script as plugins not available or versions don't match
end

if HasPlugin("YesAlready") then
    PauseYesAlready()
end

LogInfo("[APL] ##############################")
LogInfo("[APL] Starting script...")
LogInfo("[APL] snd_config_folder: " .. snd_config_folder)
LogInfo("[APL] char_list: " .. char_list)
LogInfo("[APL] SNDConf+Char: " .. snd_config_folder .. "" .. char_list)
LogInfo("[APL] provisioning_list_save_name: " .. provisioning_list_save_name)
LogInfo("[APL] SNDConf+PROV: " .. snd_config_folder .. "" .. provisioning_list_save_name)
LogInfo("[APL] ##############################")

local gc_config_folder = vac_config_folder .. "\\GC\\"
EnsureFolderExists(gc_config_folder)

if use_external_character_list then
    local char_data = dofile(snd_config_folder .. char_list)
    character_list = char_data.character_list
end

local provisioning_list = {}

function FindGCItemID(item_name)
    local lists = {
        GC_MIN_List = "GC_MIN_List",
        GC_BTN_List = "GC_BTN_List",
        GC_FSH_List = "GC_FSH_List"
    }

    for list, list_name in pairs(lists) do
        if _G[list][item_name] then
            return _G[list][item_name].ID, list_name
        end
    end

    return 0, "Not found"
end

function SerializeTable(val, name, depth)
    depth = depth or 0
    local result = ""
    local indent = string.rep("  ", depth)

    if name then
        result = result .. indent .. name .. " = "
    end

    if type(val) == "table" then
        result = result .. "{\n"

        for k, v in pairs(val) do
            local key

            if type(k) == "string" then
                key = string.format("[%q]", k)
            else
                key = "[" .. k .. "]"
            end

            result = result .. SerializeTable(v, key, depth + 1) .. ",\n"
        end
        result = result .. indent .. "}"
    elseif type(val) == "string" then
        result = result .. string.format("%q", val)
    elseif type(val) == "number" or type(val) == "boolean" then
        result = result .. tostring(val)
    else
        error("Unsupported data type: " .. type(val))
    end

    return result
end

function GetAndSaveProvisioningToTable()
    for i, char in ipairs(character_list) do
        LogInfo("[APL] Processing char number " .. i)

        if GetCharacterName(true) == char then
            LogInfo("[APL] Already on the right character: " .. char)
        else
            LogInfo("[APL] Logging into: " .. char)

            if not InSanctuary() then
                Teleporter("Limsa Lominsa Lower Decks", "tp")
            end

            RelogCharacter(char)
            Sleep(7.5) -- This is enough time to log out completely and not too long to cut into new logins
            LoginCheck()
        end

        local char_name = GetCharacterName() .. "@" .. FindWorldByID(GetHomeWorld())

        repeat
            Sleep(0.1)
        until IsPlayerAvailable()

        local min_level = GetPlayerJobLevel("MIN")
        local btn_level = GetPlayerJobLevel("BTN")
        local fsh_level = GetPlayerJobLevel("FSH")
        OpenTimers()
        Sleep(1.0)

        function ContainsLetters(input)
            if input:match("%a") then
                return true
            else
                return false
            end
        end

        local Row1ItemName = GetNodeText("ContentsInfoDetail", 101, 5)
        LogInfo("[APL] " .. tostring(Row1ItemName))
        LogInfo("[APL] " .. tostring(ContainsLetters(Row1ItemName)))
        provisioning_list[char_name] = {}

        for i = 101, 99, -1 do
            local ItemName = GetNodeText("ContentsInfoDetail", i, 5)
            if ContainsLetters(ItemName) then
                LogInfo("[APL] " .. ItemName .. " Row text found")
            else
                LogInfo("[APL] Row text not found")
                break
            end
            LogInfo("[APL] Inserting from row")
            local ItemID, ListName = FindGCItemID(ItemName)
            local ItemAmount = GetNodeText("ContentsInfoDetail", i, 2)

            if ListName == "GC_MIN_List" then
                if min_enabled and (min_level < level_cap or (min_level >= level_cap and not skip_level_capped_jobs)) then
                    provisioning_list[char_name]["MIN"] = {}
                    provisioning_list[char_name]["MIN"]["Item"] = ItemName
                    provisioning_list[char_name]["MIN"]["ID"] = ItemID
                    provisioning_list[char_name]["MIN"]["QTY"] = ItemAmount
                end
            elseif ListName == "GC_BTN_List" then
                if btn_enabled and (btn_level < level_cap or (btn_level >= level_cap and not skip_level_capped_jobs)) then
                    provisioning_list[char_name]["BTN"] = {}
                    provisioning_list[char_name]["BTN"]["Item"] = ItemName
                    provisioning_list[char_name]["BTN"]["ID"] = ItemID
                    provisioning_list[char_name]["BTN"]["QTY"] = ItemAmount
                end
            elseif ListName == "GC_FSH_List" then
                if fsh_enabled and (fsh_level < level_cap or (fsh_level >= level_cap and not skip_level_capped_jobs)) then
                    provisioning_list[char_name]["FSH"] = {}
                    provisioning_list[char_name]["FSH"]["Item"] = ItemName
                    provisioning_list[char_name]["FSH"]["ID"] = ItemID
                    provisioning_list[char_name]["FSH"]["QTY"] = ItemAmount
                end
            end
        end

        if not provisioning_list[char_name]["MIN"] and not provisioning_list[char_name]["BTN"] and not provisioning_list[char_name]["FSH"] then
            provisioning_list[char_name] = nil
        else
            local CharHomeWorld = FindWorldByID(GetHomeWorld())
            provisioning_list[char_name]["CharHomeWorld"] = CharHomeWorld
        end

        local provisioning_list_strings = "provisioning_list = " .. SerializeTable(provisioning_list)
        local filepath = gc_config_folder .. provisioning_list_save_name
        local File = io.open(filepath, "w")
        File:write(provisioning_list_strings)
        File:close()
    end
end

-- Generate list of items to gather
function GenerateGCFile()
    provisioning_list_name_to_load = "provisioning_list.lua"

    local gc_config_folder = vac_config_folder .. "\\GC\\"
    dofile(gc_config_folder .. provisioning_list_name_to_load)

    local output_filename = "list_to_gather.txt"
    local output_folder = gc_config_folder

    EnsureFolderExists(output_folder)

    local function combine_items_by_category(provisioning_list)
        local category_totals = {}
        
        local category_names = {
            MIN = "Miner",
            BTN = "Botanist",
            FSH = "Fisher"
        }
        
        for _, data in pairs(provisioning_list) do
            for category, item_data in pairs(data) do
                if type(item_data) == "table" and item_data["Item"] then
                    local item_name = item_data["Item"]
                    local item_qty = tonumber(item_data["QTY"])
                    local category_name = category_names[category] or category
                    
                    if not category_totals[category_name] then
                        category_totals[category_name] = {}
                    end
                    
                    if not category_totals[category_name][item_name] then
                        category_totals[category_name][item_name] = 0
                    end
                    
                    category_totals[category_name][item_name] = category_totals[category_name][item_name] + item_qty
                end
            end
        end
        
        return category_totals
    end

    local function create_character_summary(provisioning_list)
        local summaries = {}
        
        for character_name, data in pairs(provisioning_list) do
            local character_summary = {}
            for category, item_data in pairs(data) do
                if type(item_data) == "table" and item_data["Item"] then
                    table.insert(character_summary, item_data["Item"] .. ": " .. item_data["QTY"])
                end
            end
            summaries[character_name] = character_summary
        end
        
        return summaries
    end

    local function write_to_file(category_totals, character_summaries, filename)
        local file = io.open(filename, "w")
        if not file then
            return
        end
        
        file:write("************************\n")
        file:write("* Provisioning Summary *\n")
        file:write("************************\n\n")

        -- Job ordering
        local job_order = { "Miner", "Botanist", "Fisher" }
        local remaining_categories = {}

        -- Separate order categories and gather remaining ones
        for category in pairs(category_totals) do
            if not table.concat(job_order):find(category) then
                table.insert(remaining_categories, category)
            end
        end

        -- Sort remaining categories a-z
        table.sort(remaining_categories)

        -- Combine ordered categories with the sorted remaining ones
        local sorted_categories = {}
        
        for _, category in ipairs(job_order) do
            if category_totals[category] then
                table.insert(sorted_categories, category)
            end
        end
        
        for _, category in ipairs(remaining_categories) do
            table.insert(sorted_categories, category)
        end

        -- Write categories to file
        for _, category in ipairs(sorted_categories) do
            local items = category_totals[category]
            file:write(category .. "\n")
            file:write(string.rep("=", #category + 4) .. "\n")
            
            -- Sort items a-z
            local sorted_items = {}
            
            for item in pairs(items) do
                table.insert(sorted_items, item)
            end
            table.sort(sorted_items)
            
            for _, item in ipairs(sorted_items) do
                local qty = items[item]
                file:write(item .. ": " .. qty .. "\n")
            end
            file:write("\n")
        end

        file:write("******************************\n")
        file:write("* Per Character Requirements *\n")
        file:write("******************************\n\n")
        
        -- Sort character names a-z
        local sorted_characters = {}
        
        for character_name in pairs(character_summaries) do
            table.insert(sorted_characters, character_name)
        end
        table.sort(sorted_characters)

        for _, character_name in ipairs(sorted_characters) do
            local summary = character_summaries[character_name]
            file:write(character_name .. "\n")
            file:write(string.rep("-", #character_name + 4) .. "\n")
            
            for _, item_line in ipairs(summary) do
                file:write(item_line .. "\n")
            end
            file:write("\n")
        end
        
        file:close()
    end

    local combined_items_by_category = combine_items_by_category(provisioning_list)
    local character_summaries = create_character_summary(provisioning_list)

    write_to_file(combined_items_by_category, character_summaries, output_folder .. output_filename)
end

function Main()
    -- Auto Gen Provisioning List
    GetAndSaveProvisioningToTable()

    -- Generate list of items to gather
    GenerateGCFile()
end

Main()

if HasPlugin("YesAlready") then
    RestoreYesAlready()
end