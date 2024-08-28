-- Description can go here

-- ###########
-- # CONFIGS #
-- ###########

local use_external_character_list = true  -- Options: true = uses the external character list in the same folder, default name being char_list.lua, false = use the list you put in this file 

local multi_char = false                  -- Options: true = cycles through character list, false = single character

-- This is where you put your character list if you choose to not use the external one
-- If use_external_character_list is set to true then this list is completely skipped
-- Usage: First Last@Server
local character_list = {
    "First Last@Server",
    "First Last@Server"
}

-- More config stuff can go here

-- #####################################
-- #  DON'T TOUCH ANYTHING BELOW HERE  #
-- # UNLESS YOU KNOW WHAT YOU'RE DOING #
-- #####################################

-- Edit char_list.lua file for configuring characters
char_list = "vac_char_list.lua"

snd_config_folder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
vac_config_folder = snd_config_folder .. "\\VAC\\"
load_functions_file_location = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(load_functions_file_location)
LoadFunctions()
LoadFileCheck()

CheckPluginsEnabled("SomethingNeedDoing")

LogInfo("[TEMP] ##############################")
LogInfo("[TEMP] Starting script...")
LogInfo("[TEMP] snd_config_folder: " .. snd_config_folder)
LogInfo("[TEMP] char_list: " .. char_list)
LogInfo("[TEMP] SNDConf+Char: " .. snd_config_folder .. "" .. char_list)
LogInfo("[TEMP] ##############################")

if use_external_character_list then
    local char_data = dofile(snd_config_folder .. char_list)
    character_list_options = char_data.character_list_options
end

-- More variables etc can go here

-- ############
-- # TEMPLATE #
-- ############

-- Stuff can go here

-- ###############
-- # MAIN SCRIPT #
-- ###############

function Main()
    -- stuff can go here
end

if multi_char then
    for _, char in ipairs(character_list) do
        if GetCharacterName(true) == char then
            -- continue, no relogging needed
        else
            if not (ZoneCheck("Limsa Lominsa Lower") or ZoneCheck("Limsa Lominsa Upper")) then
                Teleporter("Limsa", "tp")
            end
            
            RelogCharacter(char)
            Sleep(7.5)
            LoginCheck()
        end
        
        repeat
            Sleep(0.1)
        until IsPlayerAvailable()
        
        Main()
    end
else
    Main()
end