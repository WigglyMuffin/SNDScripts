-- Description can go here

-- ###########
-- # CONFIGS #
-- ###########

local use_external_character_list = true  -- Options: true = uses the external character list in the same folder, default name being CharList.lua, false = use the list you put in this file 

MULTICHAR = true                          -- Options: true = cycles through character list, false = single character

-- This is where you put your character list if you choose to not use the external one
-- If us_external_character_list is set to true then this list is completely skipped
-- Usage: First Last@Server, return_home, return_location
-- return_home options: 0 = no, 1 = yes
-- return_location options: 0 = fc entrance, 1 nearby bell, 2 limsa bell
-- This is where your alts that need items are listed
local character_list = {
    "First Last@Server",
    "First Last@Server"
}

-- More config stuff can go here

-- #####################################
-- #  DON'T TOUCH ANYTHING BELOW HERE  #
-- # UNLESS YOU KNOW WHAT YOU'RE DOING #
-- #####################################

-- Edit CharList.lua file for configuring characters
CharList = "CharList.lua"

SNDConfigFolder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
LoadFunctionsFileLocation = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(LoadFunctionsFileLocation)
LoadFunctions()
LoadFileCheck()
LogInfo("[JU] ##############################")
LogInfo("[JU] Starting script...")
LogInfo("[JU] SNDConfigFolder: " .. SNDConfigFolder)
LogInfo("[JU] CharList: " .. CharList)
LogInfo("[JU] SNDC+Char: " .. SNDConfigFolder .. "" .. CharList)
LogInfo("[JU] ##############################")

if use_external_character_list then
    local char_data = dofile(SNDConfigFolder .. CharList)
    character_list = char_data.character_list
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
    if TEMPLATE1 then
        Temp1()
        Temp2()
        Temp3()
    elseif TEMPLATE2 then
        Temp4()
        Temp5()
        Temp6()
    end
    
    if TEMPLATE3 then
        Temp7()
        Temp8()
        Temp9()
    end
end

if MULTICHAR then
    for _, char in ipairs(character_list) do
        if GetCharacterName(true) == char then
            -- continue, no relogging needed
        else
            ZoneCheck(129, "Limsa", "tp")
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