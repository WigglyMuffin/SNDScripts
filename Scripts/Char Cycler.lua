--[[#######################################
##            Character Cycler           ##
##              by Friendly              ##
##                                       ##
##   made with WigglyMuffin functions    ##
###########################################

####################################################
##                  Description                   ##
####################################################

-- This script cycles through characters and runs scripts per char and/or a full cycle
-- Run retainers "without" AR, do quests or turnin on alts, etc. The sky is the limit.
-- Can operate continuously if you put this script's name as cycle_script_name
-- Get vac_char_list.lua and vac_functions.lua from https://github.com/WigglyMuffin/SNDScripts
-- put them in your SND config folder: %appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing (can copy and paste this in Windows)

-- ###########
-- # CONFIGS #
-- #########]]

local use_external_character_list = true -- Options: true = uses the external character list in the same folder, default name being char_list.lua, false uses the list you put in this file
char_script_name = "" -- name of script to run after each character
cycle_script_name = "" -- name of script to run once this script finishes
return_location = "auto" -- where toons go after running script. same as using /li return_location
pause_yesalready = false -- pause YesAlready while script is running

--[[ This is where you put your character list if you choose to NOT use the external one
-- If use_external_character_list is set to true then this list is completely skipped
-- Can start from current toon and go to the end of the list (!!when gameobject is fixed again)
-- Add your toons here or external list like so

local character_list = {
    "Example Character@Server",
    "John Doe@Balmung",
}
]]

    local character_list = {
}

-- #####################################
-- #  DON'T TOUCH ANYTHING BELOW HERE  #
-- # UNLESS YOU KNOW WHAT YOU'RE DOING #
-- #####################################

char_list = "vac_char_list.lua"

snd_config_folder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
vac_config_folder = snd_config_folder .. "\\VAC\\"
load_functions_file_location = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(load_functions_file_location)
LoadFunctions()
LoadFileCheck()

if not CheckPluginsEnabled("AutoRetainer", "TeleporterPlugin", "Lifestream", "PandorasBox", "SomethingNeedDoing", "TextAdvance", "vnavmesh", "YesAlready") then
    return -- Stops script as plugins not available
end

if HasPlugin("YesAlready") and pause_yesalready then
    PauseYesAlready()
end

yield("/ays m d")-- if started during multi
yield("/ays d")
yield("/ays reset")

LogInfo("[CC] ##############################")
LogInfo("[CC] Starting script...")
LogInfo("[CC] snd_config_folder: " .. snd_config_folder)
LogInfo("[CC] char_list: " .. char_list)
LogInfo("[CC] SNDConf+Char: " .. snd_config_folder .. "" .. char_list)
LogInfo("[CC] ##############################")

if use_external_character_list then
    local char_data = dofile(snd_config_folder .. char_list)
    character_list = char_data.character_list
end


function RelogAndDoThing()
        -- Find the index of current character in the list
    local start_index = -1
    for i, char in ipairs(character_list) do
        if GetCharacterName(true) == char then
            start_index = i
            LogInfo("[CC] Starting from character: " .. char .. " at index " .. start_index)
            break
        end
    end
    if start_index == -1 then -- Character not found in the list, start from 1
        if #character_list == 0 then
            LogInfo("[CC] No characters found in your char_list.")
            return
        end
        yield("/ays relog " .. character_list[1])
        Sleep(23.0)
        LoginCheck()
    end
    -- Loop through char_list once starting from current toon
    for i = 0, #character_list - 1 do
        -- Calculate the actual index with wrap-around
        local actual_index = ((start_index + i - 1) % #character_list) + 1
        local char = character_list[actual_index]

        LogInfo("[CC] Processing char number " .. actual_index)

        if GetCharacterName(true) == char then
            LogInfo("[CC] Already on the right character: " .. char)
        else
            LogInfo("[CC] Logging into: " .. char)
            RelogCharacter(char)
            Sleep(7.5) --This is enough time to log out completely and not too long to cut into new logins
            --LoginCheck() --!!replacing with below repeat till gameobject fix
            for j = 1, 500 do
                Sleep(0.5)
                if IsPlayerAvailable() and IsAddonVisible("NamePlate") then
                    break
                end
            end
        end

        --Run the script for the current character
        yield("/at e") --strangely TextAdvance turns off sometimes
        yield("/snd run " .. char_script_name)
        Sleep(1) -- this is needed for the script to start
        Teleporter(return_location, "li")
        Sleep(3)
    end
end

RelogAndDoThing()
Sleep(1) --just in case, may not be needed
if HasPlugin("YesAlready") and pause_yesalready then
    RestoreYesAlready()
end
yield("/snd run "..cycle_script_name)