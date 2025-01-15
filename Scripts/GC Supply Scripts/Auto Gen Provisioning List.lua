--[[
####################
##    Version     ##
##     1.0.1      ##
####################

-> 1.0.0: Initial release
-> 1.0.1: Duplicate name across worlds fix

####################################################
##                  Description                   ##
####################################################

-- This script will rotate through your characters and generate a list of items needed for gc supply and output that file to the snd config folder
-- This file can then be used in other scripts to automate other tasks

-- ###########
-- # CONFIGS #
-- #########]]

local use_external_character_list = true -- Options: true = uses the external character list in the same folder, default name being char_list.lua, false uses the list you put in this file
local level_cap = 100                    -- Job level cap, adjust according to your current level cap
local skip_level_capped_jobs = true      -- Options: true = will skip level capped jobs, false = will not skip level capped jobs
local min_enabled = true                 -- Options: true = will store MIN items, false = will skip MIN items
local btn_enabled = true                 -- Options: true = will store BTN items, false = will skip BTN items
local fsh_enabled = true                 -- Options: true = will store FSH items, false = will skip FSH items

-- This is where you put your character list if you choose to not use the external one
-- If use_external_character_list is set to true then this list is completely skipped
local character_list = {
    "First Last@Server",
    "First Last@Server"
}

-- Edit char_list.lua file for configuring characters

-- #####################################
-- #  DON'T TOUCH ANYTHING BELOW HERE  #
-- # UNLESS YOU KNOW WHAT YOU'RE DOING #
-- #####################################

char_list = "vac_char_list.lua"
provisioning_list_save_name = "provisioning_list.lua"

snd_config_folder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
vac_config_folder = snd_config_folder .. "\\VAC\\"
load_functions_file_location = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(load_functions_file_location)
LoadFunctions()
LoadFileCheck()

if not CheckPluginsEnabled("AutoRetainer", "TeleporterPlugin", "Lifestream", "PandorasBox", "SomethingNeedDoing", "TextAdvance", "vnavmesh") then
    return -- Stops script as plugins not available
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

function Main()
    GetAndSaveProvisioningToTable()
end

Main()

if HasPlugin("YesAlready") then
    RestoreYesAlready()
end