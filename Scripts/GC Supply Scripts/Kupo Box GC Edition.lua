--[[
  _  __                   ____               _____  _____   ______    _ _ _   _             
 | |/ /                  |  _ \             / ____|/ ____| |  ____|  | (_) | (_)            
 | ' /_   _ _ __   ___   | |_) | _____  __ | |  __| |      | |__   __| |_| |_ _  ___  _ __  
 |  <| | | | '_ \ / _ \  |  _ < / _ \ \/ / | | |_ | |      |  __| / _` | | __| |/ _ \| '_ \ 
 | . \ |_| | |_) | (_) | | |_) | (_) >  <  | |__| | |____  | |___| (_| | | |_| | (_) | | | |
 |_|\_\__,_| .__/ \___/  |____/ \___/_/\_\  \_____|\_____| |______\__,_|_|\__|_|\___/|_| |_|
           | |                                                                              
           |_|                                                                              
####################
##    Version     ##
##     1.0.1      ##
####################

-> 1.0.0: Initial release
-> 1.0.1: GC Edition of Kupo Box tailored for GC Supply Script series

####################################################
##                  Description                   ##
####################################################

This is the GC Edition of Kupo Box script and it automates a list of characters picking up items from a specified character
It is to be used with the GC Supply Scripts series only, it is not compatible with any other script

Edit vac_char_list.lua (character_list) for configuring characters if using an external list

####################################################
##                  Requirements                  ##
####################################################

-> AutoRetainer : https://love.puni.sh/ment.json
-> Teleporter : In the default first party dalamud repository
-> Lifestream : https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
-> TextAdvance : https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
-> Something Need Doing (Expanded Edition) : https://puni.sh/api/repository/croizat
-> Pandora's Box : https://love.puni.sh/ment.json
-> vnavmesh : https://puni.sh/api/repository/veyn
-> Dropbox : https://puni.sh/api/repository/kawaii
    -> Recommended settings in dropbox are 4 frames delay between trades and 1500ms trade open command throttle. (Ctrl + left click to specify exact values).
    -> You NEED to enable "Enable auto-accept trades." under the dropbox settings.

Optional plugins:
-> Deliveroo : https://plugins.carvel.li/
    -> Only required if expert_delivery is set to true

#####################
##    Settings     ##
#####################

Edit vac_char_list.lua file for configuring characters that this script uses (character_list), these are the characters you want to do turnins on

The settings below will be used on all characters set in the character_list
You only need to set these here and you do not need to use the character_list_kupobox, or the CharListGen for Kupo Box ]]

local trading_with = "Smol Meow"            -- Name of the character you are trading with, do not include world
local destination_server = "Sephirot"       -- Server characters need to travel to for collecting items
local destination_type = 0                  -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
local destination_aetheryte = "Aleport"     -- Aetheryte that characters need to travel to for collecting items, case insensitive and you can be vague
local destination_house = 0                 -- Options: 0 = FC, 1 = Personal, 2 = Apartment
local do_movement = true                    -- Options: true = Paths to chosen character, false = Does nothing and waits for chosen character to come to you
local return_home = true                    -- Options: true = Returns home from destination, false = Does nothing and logs out
local return_location = 0                   -- Options: 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc 

-- Options: true = invites character you are trading with to party for trading, false = uses distance based proximity check for trading
-- Setting this to false will result in faster trades (marginally) but is less safe, recommended to set to true
local party_invite = true

-- In case something goes wrong, you can set the amount of characters in the list to skip, this goes from the top of the list
-- A good way to know how many chars you need to skip is to read the processing echo in chat which lists how many chars have finished already and which char is currently being processed ]]
local skip_chars = 0 -- number of characters you'd like to skip

-- Options: true = will start Deliveroo expert delivery after GC supply turnins, false = do nothing
-- Requires Deliveroo plugin to be installed and will enable expert deliveries to be run after GC turnins
-- Probably requires you to have set Deliveroo up beforehand
local expert_delivery = false

local use_external_character_list = true -- Options: true = uses the external character list in the same folder, default name being char_list.lua, false uses the list you put in this file

-- This is where you put your character list if you choose to not use the external one
-- If use_external_character_list is set to true then this list is completely skipped
local character_list = {
    "First Last@Server",
    "First Last@Server"
}

--[[################################################
##                  Script Start                  ##
##################################################]]

-- Edit char_list.lua file (character_list) for configuring characters
char_list = "vac_char_list.lua"

snd_config_folder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
vac_config_folder = snd_config_folder .. "\\VAC\\"
load_functions_file_location = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(load_functions_file_location)()
LoadFileCheck()

if use_external_character_list then
    local char_data = dofile(snd_config_folder .. char_list)
    character_list = char_data.character_list
end

-- Plugin checker
local required_plugins = {"AutoRetainer", "TeleporterPlugin", "Lifestream", "PandorasBox", "SomethingNeedDoing", "TextAdvance", "vnavmesh"}

if expert_delivery then
    table.insert(required_plugins, "Deliveroo")
end

if not CheckPluginsEnabled(unpack(required_plugins)) then
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

local function DOL()
    local home_world = GetCurrentWorld() == GetHomeWorld()

    if not home_world then
        Teleporter(FindWorldByID(GetHomeWorld()), "li")
        Sleep(1.0)

        repeat
            Sleep(0.1)
        until not LifestreamIsBusy() and IsPlayerAvailable()

        -- Wait until the player is on the home world
        repeat
            Sleep(0.1)
            home_world = GetCurrentWorld() == GetHomeWorld()
        until home_world
    end

    -- Wait until the player is fully available
    repeat
        Sleep(0.1)
    until IsPlayerAvailable()

    Teleporter("gc", "li")

    repeat
        Sleep(0.1)
    until not LifestreamIsBusy()

    if do_rankups then
        local rankups_done = false
        while not rankups_done do
            local can_rankup = CanGCRankUp()
            if can_rankup then
                DoGcRankUp()
            else
                rankups_done = true
            end
        end
    end

    OpenGcSupplyWindow(1)
    GcProvisioningDeliver()
    CloseGcSupplyWindow()
end

local function ProcessAltCharacters(character_list)
    for i = 1, #character_list do
        -- Update alt character name
        local alt_char_name = character_list[i]

        -- this is just to store the boolean for if we're skipping a char or not
        local skip = false

        -- check if the character is supposed to be skipped
        if i <= skip_chars then
            LogInfo("[KupoBox] Skipping char " .. i .. ": " .. alt_char_name )
            skip = true
        end
        if not skip then
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

            Echo("Processing " .. i .. "/" .. #character_list .. ", current character: " .. alt_char_name)
            LogInfo("[KupoBox] Processing " .. i .. "/" .. #character_list .. ", current character: " .. alt_char_name)

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
                    PathToObject(trading_with, 3.5)
                else
                    LogInfo("[KupoBox] do_movement is set to false, not moving")
                end

                -- Invite main char to party, needs a target
                if party_invite then
                    PartyInvite(trading_with)
                    LogInfo("[KupoBox] Inviting " .. trading_with .. " to party")
                end

            elseif destination_type == 2 then
                -- If destination_type is 2, first go to the estate entrance, then to the main character
                PathToObject("Entrance")
                Target("Entrance")
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
                    PathToObject(trading_with, 3.5)
                else
                    LogInfo("[KupoBox] do_movement is set to false, not moving")
                end

                -- Invite main char to party, needs a target
                if party_invite then
                    PartyInvite(trading_with)
                    LogInfo("[KupoBox] Inviting " .. trading_with .. " to party")
                end
            end

            -- Wait for the gil transfer to complete
            WaitForGilIncrease(1)

            -- Notify when all characters are finished
            if i == #character_list then
                Echo("Finished all " .. #character_list .. " characters")
                LogInfo("Finished all " .. #character_list .. " characters")
            end

            -- Disband party once gil trigger has happened
            if party_invite then
                LogInfo("[KupoBox] Disbanding party")
                PartyDisband()
            end

            DOL()

            -- Deliveroo expert delivery
            if expert_delivery then
                GCDeliverooExpertDelivery()
            end

            -- Alt character handling to go home
            -- [2] return_home options: 0 = no, 1 = yes
            -- [3] return_location options: 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc
            if return_home then
                LogInfo("[KupoBox] Returning home")
                ReturnHomeWorld()

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
                    PathToObject("Summoning Bell")
                end

                -- FC Entrance stuff
                if return_location == 4 then
                    LogInfo("[KupoBox] Attempting to go to FC Entrance")
                    Teleporter("Estate Hall (Free Company)", "tp")
                    PathToObject("Entrance")
                end
            end
        end
        skip = false
    end
end

ProcessAltCharacters(character_list)
LogInfo("[KupoBox] All characters complete, script finished")

if HasPlugin("YesAlready") then
    RestoreYesAlready()
end
