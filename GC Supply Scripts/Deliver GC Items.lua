-- This script assumes you have all the items needed on all characters and delivers them to their gc
-- This is a fully automated script
-- You should use the Yes Already plugin to bypass the capped seals warning or it will break the script

-- ###########
-- # CONFIGS #
-- ###########

local use_external_character_list = true  -- Options: true = uses the external character list in the same folder, default name being char_list.lua, false uses the list you put in this file 
local do_rankups = true -- Automatically attempts to rank up your gc if set to true

-- This is where you put your character list if you choose to not use the external one
-- If use_external_character_list is set to true then this list is completely skipped
local character_list = {
    "First Last@Server",
    "First Last@Server"
}

-- Edit char_list.lua file for configuring characters

multi_char = true

-- #####################################
-- #  DON'T TOUCH ANYTHING BELOW HERE  #
-- # UNLESS YOU KNOW WHAT YOU'RE DOING #
-- #####################################

char_list = "char_list.lua"

snd_config_folder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
load_functions_file_location = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(load_functions_file_location)
LoadFunctions()
LoadFileCheck()

LogInfo("[DGCI] ##############################")
LogInfo("[DGCI] Starting script...")
LogInfo("[DGCI] snd_config_folder: " .. snd_config_folder)
LogInfo("[DGCI] char_list: " .. char_list)
LogInfo("[DGCI] SNDConf+Char: " .. snd_config_folder .. "" .. char_list)
LogInfo("[DGCI] ##############################")

if use_external_character_list then
    local char_data = dofile(snd_config_folder .. char_list)
    character_list = char_data.character_list
end

-- #############
-- # DOL STUFF #
-- #############

function DOL()
    local home = GetCurrentWorld() == GetHomeWorld()
    
    if not home then
        Teleporter(GetHomeWorld(), "li")
        
        repeat
            Sleep(0.1)
        until not LifestreamIsBusy() and IsPlayerAvailable()
        
        -- Wait until the player is on the home world
        repeat
            Sleep(0.1)
            home = GetCurrentWorld() == GetHomeWorld()
        until home
    end
    
    -- Wait until the player is fully available
    repeat
        Sleep(0.1)
    until IsPlayerAvailable()
    
    Teleporter("GC", "li")
    
    repeat
        Sleep(0.1)
    until not LifestreamIsBusy()
    if do_rankups then
        DoGcRankUp()
    end
    OpenGcSupplyWindow(1)
    GcProvisioningDeliver()
    CloseGcSupplyWindow()
end


-- ###############
-- # MAIN SCRIPT #
-- ###############

function Main()
    DOL()
end

if multi_char then
    for _, char in ipairs(character_list) do
        if GetCharacterName(true) == char then
            -- continue, no relogging needed
        else
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
