--[[
  _  __                       ____              
 | |/ /                      |  _ \             
 | ' / _   _  _ __    ___    | |_) |  ___ __  __
 |  < | | | || '_ \  / _ \   |  _ <  / _ \\ \/ /
 | . \| |_| || |_) || (_) |  | |_) || (_) |>  < 
 |_|\_\\__,_|| .__/  \___/   |____/  \___//_/\_\
             | |                               
             |_|                               

####################
##    Version     ##
##     1.0.0      ##
####################

-> 1.0.0: Initial release

############################################################
##                      Description                       ##
############################################################

This script automates a list of characters moving to a location and picking up items from a specified character
It's supposed to be used in pairs with the post moogle script to automate trading a large quantity of items
Almost everything is configurable and lets you change settings on a per character basis, or you can set overrides that apply to every character no matter what the character setting is

Currently the way it knows when the trades are done is by being traded 1 gil, however this might be changed in the future, or at least made configurable

############################################################
##                   Required Plugins                     ##
############################################################

-> AutoRetainer : https://love.puni.sh/ment.json
-> Teleporter : In the default first party dalamud repository
-> Lifestream : https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
-> TextAdvance : https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
-> Something Need Doing (Expanded Edition) : https://puni.sh/api/repository/croizat
-> Pandora's Box : https://love.puni.sh/ment.json
-> vnavmesh : https://puni.sh/api/repository/veyn

#####################
##    Settings     ##
#####################

Edit vac_char_list.lua file for configuring characters, or utilize the local character list below

These settings will override what you include in the character list, which means if you set a setting here then all characters will use that setting
to use any of the overrides you need to uncomment the line and set it to what you want. uncommenting is just removing the two lines at the start ]]

-- local trading_with_override = "Smol Meow"            -- Name of the character you're trading with, do not include world
-- local destination_server_override = "Sephirot"       -- Server characters need to travel to for collecting items
-- local destination_type_override = 0                  -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
-- local destination_aetheryte_override = "Aleport"     -- Aetheryte that characters need to travel to for collecting items, case insensitive and you can be vague
-- local destination_house_override = 0                 -- Options: 0 = FC, 1 = Personal, 2 = Apartment
-- local do_movement_override = true                    -- Options: true = Paths to chosen character, false = Does nothing and waits for chosen character to come to you
-- local return_home_override = true                    -- Options: true = Returns home from destination, false = Does nothing and logs out
-- local return_location_override = 0                   -- Options: 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc 

-- in case something somehow goes wrong you can set the amount of characters in the list to skip, this goes from the top of the list
-- a good way to know how many chars you actually need to skip is to read the processing echo in chat which lists how many chars it's finished already and which char it's on  ]]
local skip_chars = 0 -- number of characters you'd like to skip

-- Options: true / false
-- If the below options is set to true then it will utilize the external vac_char_list and you need to make sure that is correctly configured
local use_external_character_list = true

-- This is where you put your character list if you choose to not use the external one
-- If use_external_character_list is set to true then this list is completely skipped
-- This list uses the same options as shown in the overrides above

local character_list_kupobox = {
    {
        ["Name"] = "Large Meow@Bismarck", -- the name of the character you're logging in on
        ["Trading With"] = "Smol Meow", -- character you're trading with, without world
        ["Destination Server"] = "Sephirot", -- server you're going to pick up items on
        ["Destination Type"] = 0, -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
        ["Destination Aetheryte"] = "Aleport", -- aetheryte to meet at if ["Destination Type"] is set to 0
        ["Destination House"] = 0, -- Options: 0 = FC, 1 = Personal, 2 = Apartment // Only active if ["Destination Type"] is set to 1 or 2
        ["Do Movement"] = false, -- will move to the character you're trading to, usually this is done by the delivery character
        ["Return Home"] = false, -- will just log out if set to false, otherwise will move to home server and to set location configured by ["Return Location"]
        ["Return Location"] = 0 -- 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc 
    },
    {
        ["Name"] = "Larger Meow@Ravana", -- the name of the character you're logging in on
        ["Trading With"] = "Smol Meow", -- character you're trading with, without world
        ["Destination Server"] = "Sephirot", -- server you're going to pick up items on
        ["Destination Type"] = 0, -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
        ["Destination Aetheryte"] = "Aleport", -- aetheryte to meet at if ["Destination Type"] is set to 0
        ["Destination House"] = 0, -- Options: 0 = FC, 1 = Personal, 2 = Apartment // Only active if ["Destination Type"] is set to 1 or 2
        ["Do Movement"] = false, -- will move to the character you're trading to, usually this is done by the delivery character
        ["Return Home"] = false, -- will just log out if set to false, otherwise will move to home server and to set location configured by ["Return Location"]
        ["Return Location"] = 0 -- 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc 
    },
}

--[[#################################
#  DON'T TOUCH ANYTHING BELOW HERE  #
# UNLESS YOU KNOW WHAT YOU'RE DOING #
#####################################

###################
# FUNCTION LOADER #
#################]]

-- Edit char_list.lua file for configuring characters
char_list = "vac_char_list.lua"

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

LogInfo("[KupoBox] ##############################")
LogInfo("[KupoBox] Starting script...")
LogInfo("[KupoBox] snd_config_folder: " .. snd_config_folder)
LogInfo("[KupoBox] char_list: " .. char_list)
LogInfo("[KupoBox] SNDConf+Char: " .. snd_config_folder .. "" .. char_list)
LogInfo("[KupoBox] ##############################")

if use_external_character_list then
    local char_data = dofile(snd_config_folder .. char_list)
    character_list_kupobox = char_data.character_list_kupobox
end

--[[###########
# MAIN SCRIPT #
#############]]

local function ProcessAltCharacters(character_list_kupobox)
    for i = 1, #character_list_kupobox do
        -- Update alt character name
        local alt_char_name = character_list_kupobox[i]["Name"]

        -- this is just to store the boolean for if we're skipping a char or not
        local skip = false

        -- check if the character is supposed to be skipped
        if i <= skip_chars then
            LogInfo("[KupoBox] Skipping char " .. i .. ": " .. alt_char_name )
            skip = true
        end
        if not skip then
            -- apply overrides if they're needed, otherwise set the settings from the character
            local trading_with = trading_with_override or character_list_kupobox[i]["Trading With"]
            local destination_server = destination_server_override or character_list_kupobox[i]["Destination Server"]
            local destination_type = destination_type_override or character_list_kupobox[i]["Destination Type"]
            local destination_aetheryte = destination_aetheryte_override or character_list_kupobox[i]["Destination Aetheryte"]
            local destination_house = destination_house_override or character_list_kupobox[i]["Destination House"]
            local do_movement = do_movement_override or character_list_kupobox[i]["Do Movement"]
            local return_home = return_home_override or character_list_kupobox[i]["Return Home"]
            local return_location = return_location_override or character_list_kupobox[i]["Return Location"]


            -- Switch characters if required, looks up current character and compares
            if GetCharacterName(true) ~= alt_char_name then
                -- checks if return_location options matches 1 which returns player to Limsa
                if return_location == 1 then
                    if not (ZoneCheck("Limsa Lominsa Lower") or ZoneCheck("Limsa Lominsa Upper")) then
                        Teleporter("Limsa", "tp")
                    end
                end

                RelogCharacter(alt_char_name)
                Sleep(7.5)
                LoginCheck()
            end

            Echo("Picking up items from " .. trading_with .. " on server " .. destination_server)
            LogInfo("[KupoBox] Picking up items from " .. trading_with .. " on server " .. destination_server)

            Echo("Processing " .. i .. "/" .. #character_list_kupobox .. ", current character: " .. alt_char_name)
            LogInfo("[KupoBox] Processing " .. i .. "/" .. #character_list_kupobox .. ", current character: " .. alt_char_name)

            -- Check if alt character on correct server
            if GetCurrentWorld() == World_ID_List[destination_server].ID then
                -- If player is on destination_server then do nothing
                LogInfo("[KupoBox] Already on the right server to trade: " .. destination_server)
            else
                -- If player is not on destination_server then go there
                LogInfo("[KupoBox] On the wrong server, transferring to: " .. destination_server)
                Teleporter(destination_server, "li")
            end

            repeat
                Sleep(0.1)
            until IsPlayerAvailable() and not LifestreamIsBusy()

            -- Alt character destination type, how alt char is travelling to the main
            -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
            if destination_type == 0 then
                local dest_aetheryte_id = FindZoneIDByAetheryte(destination_aetheryte)

                -- If player is not at the destination then tp there
                if GetZoneID() ~= dest_aetheryte_id then
                    Echo("Teleporting to " .. destination_aetheryte .. " to find " .. trading_with)
                    LogInfo("[KupoBox] Teleporting to " .. destination_aetheryte .. " to find " .. trading_with)
                    Teleporter(destination_aetheryte, "tp")
                else
                    Echo("Already in the right zone to meet " .. trading_with)
                end
            end

            -- Requires main added to friend list for access to estate list teleports
            -- Keeping it for future stuff
            if destination_type > 0 then
                Echo("Teleporting to estate to find " .. trading_with)
                LogInfo("[KupoBox] Teleporting to estate to find " .. trading_with)
                EstateTeleport(trading_with, destination_house)
            end

            -- I really don't like the repeat of destination_type checking here, should probably be refactored into stuff above
            -- Handle different destination types
            -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
            if destination_type == 0 or destination_type == 1 then
                -- Waits until main char is present
                LogInfo("[KupoBox] Waiting for " .. trading_with)
                WaitUntilObjectExists(trading_with)
                LogInfo("[KupoBox] Found " .. trading_with)

                -- Paths to main char only if you have do_movement set to true
                if do_movement then
                    -- Path to main char
                    LogInfo("[KupoBox] do_movement is set to true, moving towards " .. trading_with)
                    PathToObject(trading_with, 2.5)
                else
                    LogInfo("[KupoBox] do_movement is set to false, not moving")
                end

                -- Invite main char to party, needs a target
                -- PartyInvite(trading_with)
                -- LogInfo("[KupoBox] Inviting " .. trading_with .. " to party")

            elseif destination_type == 2 then
                -- If destination_type is 2, first go to the estate entrance, then to the main character
                PathToEstateEntrance()
                Interact()

                repeat
                    Sleep(0.1)
                    yield("/pcall SelectYesno true 0")
                until not IsAddonVisible("SelectYesno")

                -- Waits until main char is present
                LogInfo("[KupoBox] Waiting for " .. trading_with)
                WaitUntilObjectExists(trading_with)
                LogInfo("[KupoBox] Found " .. trading_with)

                -- Paths to main char only if you have do_movement set to true
                if do_movement then
                    -- Path to main char
                    LogInfo("[KupoBox] do_movement is set to true, moving towards " .. trading_with)
                    PathToObject(trading_with, 2.5)
                else
                    LogInfo("[KupoBox] do_movement is set to false, not moving")
                end

                -- Invite main char to party, needs a target
                -- PartyInvite(trading_with)
            end

            -- Wait for the gil transfer to complete
            WaitForGilIncrease(1)

            -- Notify when all characters are finished
            if i == #character_list_kupobox then
                Echo("Finished all " .. #character_list_kupobox .. " characters")
                LogInfo("Finished all " .. #character_list_kupobox .. " characters")
            end

            -- Disband party once gil trigger has happened
            -- LogInfo("[KupoBox] Disbanding party")
            -- PartyDisband()

            -- Alt character handling to go home
            -- [2] return_home options: 0 = no, 1 = yes
            -- [3] return_location options: 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc
            if return_home then
                LogInfo("[KupoBox] Returning home")
                if return_location == 1 then
                    ReturnHomeWorld()
                end

                -- Limsa stuff
                if return_location == 1 then
                    if not (ZoneCheck("Limsa Lominsa Lower") or ZoneCheck("Limsa Lominsa Upper")) then
                        LogInfo("[KupoBox] Attempting to go to Limsa")
                        Teleporter("Limsa", "tp")
                    end
                end

                -- Limsa Retainer Bell Stuff
                if return_location == 2 then
                    LogInfo("[KupoBox] Attempting to go to Limsa retainer bell")
                    PathToLimsaBell()
                end

                -- Nearby Retainer Bell Stuff
                if return_location == 3 then
                    LogInfo("[KupoBox] Attempting to go to nearest retainer bell")
                    Movement(GetObjectRawXPos("Summoning Bell"), GetObjectRawYPos("Summoning Bell"), GetObjectRawZPos("Summoning Bell"))
                end

                -- FC Entrance stuff
                if return_location == 4 then
                    LogInfo("[KupoBox] Attempting to go to FC Entrance")
                    Teleporter("Estate Hall (Free Company)", "tp")
                    -- This likely needs some logic on nearest "Entrance" for nearby estates
                    PathToEstateEntrance()
                end
            end
        end
        skip = false
    end
end

ProcessAltCharacters(character_list_kupobox)
LogInfo("[KupoBox] All characters complete, script finished")

if HasPlugin("YesAlready") then
    RestoreYesAlready()
end