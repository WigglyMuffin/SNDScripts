-- This script assumes you have all the items needed on all characters and delivers them to their gc
-- This is a fully automated script
-- You should use the Yes Already plugin to bypass the capped seals warning or it will break the script

-- ###########
-- # CONFIGS #
-- ###########

local use_external_character_list = true  -- Options: true = uses the external character list in the same folder, default name being CharList.lua, false uses the list you put in this file 

-- This is where you put your character list if you choose to not use the external one
-- If us_external_character_list is set to true then this list is completely skipped
local character_list = {
    "First Last@Server",
    "First Last@Server"
}

-- Edit CharList.lua file for configuring characters

-- #####################################
-- #  DON'T TOUCH ANYTHING BELOW HERE  #
-- # UNLESS YOU KNOW WHAT YOU'RE DOING #
-- #####################################

CharList = "CharList.lua"

SNDConfigFolder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
LoadFunctionsFileLocation = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(LoadFunctionsFileLocation)
LoadFunctions()
LoadFileCheck()
LogInfo("[DGCI] ##############################")
LogInfo("[DGCI] Starting script...")
LogInfo("[DGCI] SNDConfigFolder: " .. SNDConfigFolder)
LogInfo("[DGCI] CharList: " .. CharList)
LogInfo("[DGCI] SNDC+Char: " .. SNDConfigFolder .. "" .. CharList)
LogInfo("[DGCI] ##############################")
if use_external_character_list then
    local char_data = dofile(SNDConfigFolder .. CharList)
    character_list = char_data.character_list
end

MULTICHAR = true

-- #############
-- # DOL STUFF #
-- #############

function DOL()
    local home = GetCurrentWorld() == GetHomeWorld()
    
    if not home then
        if ZoneCheck(129) then
            Teleporter("Limsa", "tp")
        end
        
        yield("/li")
        
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
    
    -- Ensure player is in Limsa
    if ZoneCheck(129) then
        Teleporter("Limsa", "tp")
    end
    
    PathToObject("Aetheryte", 4)
    yield("/li Aftcastle")
    ZoneTransitions()
    Movement(93.00, 40.27, 75.60)
    OpenGcSupplyWindow(1)
    GcProvisioningDeliver()
    CloseGcSupplyWindow()
    LogOut()
end


-- ###############
-- # MAIN SCRIPT #
-- ###############

function Main()
    DOL()
end

if MULTICHAR then
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
