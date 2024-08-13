-- This script assumes you have all the items needed on all characters and delivers them to their gc
-- This is a fully automated script
-- You should use the Yes Already plugin to bypass the capped seals warning or it will break the script

-- ###########
-- # CONFIGS #
-- ###########

-- Configuration is not required for this file
-- Edit CharList.lua file for configuring characters

-- #####################################
-- #  DON'T TOUCH ANYTHING BELOW HERE  #
-- # UNLESS YOU KNOW WHAT YOU'RE DOING #
-- #####################################

MULTICHAR = true

CharList = "CharList.lua"

SNDConfigFolder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
LoadFunctionsFileLocation = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(LoadFunctionsFileLocation)
LoadFunctions()
LoadFileCheck()

local char_data = dofile(SNDConfigFolder .. CharList)

local character_list = char_data.character_list

-- #############
-- # DOL STUFF #
-- #############

function DOL()
    local home = false
    
    if GetCurrentWorld() == GetHomeWorld() then
        local home = true
    else
        if ZoneCheck(129, "Limsa", "tp") then
            -- stuff could go here
        end
        
        yield("/li")
    end
    
    repeat
        Sleep(0.1)
        if GetCurrentWorld() == GetHomeWorld() then
            if GetCurrentWorld() == 0 and GetHomeWorld() == 0 then
            else
                home = true
            end
        end
    until home
    
    repeat
        Sleep(0.1)
    until IsPlayerAvailable()
    
    if ZoneCheck(129, "Limsa", "tp") then
        -- stuff could go here
    else
        Movement(-89.36, 18.80, 1.78) -- this will need rethinking but it's a failsafe if you are already in limsa since /li Aftcastle will break if you are not near a crystal
    end
    
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
            Sleep(10.0)
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
