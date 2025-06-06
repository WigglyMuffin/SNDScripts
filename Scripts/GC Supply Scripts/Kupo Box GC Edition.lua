--[[
  _  __                   ____               ____  ____   _____    _ _ _   _             
 | |/ /   _ _ __   ___   | __ )  _____  __  / ___|/ ___| | ____|__| (_) |_(_) ___  _ __  
 | ' / | | | '_ \ / _ \  |  _ \ / _ \ \/ / | |  _| |     |  _| / _` | | __| |/ _ \| '_ \ 
 | . \ |_| | |_) | (_) | | |_) | (_) >  <  | |_| | |___  | |__| (_| | | |_| | (_) | | | |
 |_|\_\__,_| .__/ \___/  |____/ \___/_/\_\  \____|\____| |_____\__,_|_|\__|_|\___/|_| |_|
           |_|                                                                           

####################
##    Version     ##
##     1.2.2      ##
####################

-> 1.0.0: Initial release
-> 1.0.1: GC Edition of Kupo Box tailored for GC Supply Script series
-> 1.0.2: Movement distance fix for trading distance
-> 1.0.3: Added checks to do_rankups and expert_delivery
-> 1.1.0: 
   - Option to do turnins only without trade added
   - Refactored how skip characters are processed
   - Added toggle to enable AR multi mode at end of script
-> 1.2.0: Refactored return_location, will now accept aetheryte locations as well as Lifestream options
-> 1.2.1: Refactored destination_type and destination_house
-> 1.2.2: Fixed incorrect name used for TeleportType()

####################################################
##                  Description                   ##
####################################################

https://github.com/WigglyMuffin/SNDScripts

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
-> vnavmesh : https://puni.sh/api/repository/veyn
-> Dropbox : https://puni.sh/api/repository/kawaii
    -> Recommended settings in dropbox are 4 frames delay between trades and 1500ms trade open command throttle. (Ctrl + left click to specify exact values).
    -> You need to enable "Enable auto-accept trades." under the dropbox settings for receiving items.
    -> Dropbox UI is required to be visible and on the "Item Trade Queue" tab for trading functionality to operate for giving items.

Optional plugins:
-> Deliveroo : https://plugins.carvel.li/
    -> Only required if expert_delivery is set to true

####################################################
##                    Settings                    ##
####################################################

Edit vac_char_list.lua file for configuring characters (character_list), these are the characters you want to do turnins on

The settings below will be used on all characters set in the character_list
You only need to set these here and you do not need to use the character_list_kupobox, or the CharListGen for Kupo Box ]]

local trading_with = "Smol Meow"            -- Name of the character you are trading with, do not include world
local destination_server = "Sephirot"       -- Server characters need to travel to for collecting items
local destination_type = 0                  -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
local destination_aetheryte = "Aleport"     -- Aetheryte that characters need to travel to for collecting items, case insensitive and you can be vague
local destination_house = 0                 -- Options: 0 = FC, 1 = Personal, 2 = Apartment
local do_movement = true                    -- Options: true = Paths to chosen character, false = Does nothing and waits for chosen character to come to you
local return_home = true                    -- Options: true = Returns home from destination, false = Does nothing and logs out
local return_location = ""                  -- Set the return location for each character after tasks are complete, leave empty for no return location (will log out instead)
                                            -- Compatible with most Lifestream options too, such as "auto", "gc", "island" etc.

-- Options: true = invites character you are trading with to party for trading, false = uses distance based proximity check for trading
-- Setting this to false will result in faster trades (marginally) but is less safe, recommended to set to true
local party_invite = true

-- In case something goes wrong, you can set the amount of characters in the list to skip, this goes from the top of the list
-- A good way to know how many chars you need to skip is to read the processing echo in chat which lists how many chars have finished already and which char is currently being processed
local skip_chars = 0 -- Number of characters you want to skip

-- Options: true = Automatically attempts to rank up your GC, false = Do nothing
-- Requires the "Enforce Expert Delivery" option to be disabled in CBT plugin otherwise rank ups will not work properly
local do_rankups = true

-- Options: true = Will start Deliveroo expert delivery after GC supply turnins, false = Do nothing
-- Requires Deliveroo plugin to be installed and will run expert deliveries after GC turnins
-- Deliveroo needs to be setup properly beforehand
-- Will check if your character has the rank to do expert deliveries, so even if your character does not have the rank leaving it set to true is safe
-- Expert Delivery rank check will be skipped if CBT "Enforce Expert Delivery" option is enabled
local expert_delivery = false

-- Options: true = Will do GC supply turnins only and not trade, false = Will trade for items and then do GC supply turnins
-- Useful if you have a surplus of items on your characters and do not wish to trade for items each day
local turnins_only = false

-- Options: true = Will enable AR multi mode at end of script, false = Do nothing
local do_ays_multi = false

-- Options: true = Uses the external character list (char_list.lua), false = Uses the list you put in this file (character_list)
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
local required_plugins = {
    AutoRetainer = "4.4.4",
    TeleporterPlugin = "2.0.2.5",
    Lifestream = "2.3.2.8",
    SomethingNeedDoing = "1.75",
    TextAdvance = "3.2.4.4",
    vnavmesh = "0.0.0.54"
}

if expert_delivery then
    required_plugins.Deliveroo = "6.6"
end

if not CheckPlugins(required_plugins) then
    return -- Stops script as plugins not available or versions don't match
end

-- CBT plugin check for "Enforce Expert Delivery" option
if HasPlugin("Automaton") and (do_rankups or expert_delivery) then
    Echo('Ensure you have the "Enforce Expert Delivery" option disabled in CBT plugin.')
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

-- Deliver GC Items
local function DOL()
    local home_world = GetCurrentWorld() == GetHomeWorld()

    -- Return to home for seals from turnins
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

-- Kupo
local function ProcessAltCharacters(character_list, turnins_only)
    for i = 1, #character_list do
        -- Update alt character name
        local alt_char_name = character_list[i]

        -- check if the character is supposed to be skipped
        if i <= skip_chars then
            LogInfo("[KupoBox] Skipping char " .. i .. ": " .. alt_char_name )
        else
            -- Switch characters if required, looks up current character and compares
            if GetCharacterName(true) ~= alt_char_name then
                RelogCharacter(alt_char_name)
                Sleep(7.5)
                LoginCheck()
            end

            -- Skips trading if turnins_only set to true
            if not turnins_only then
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
                        PathToObject(trading_with, 3.0)
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
                    until IsAddonReady("SelectYesno")
                    
                    yield("/callback SelectYesno true 0")
                    
                    repeat
                        Sleep(0.1)
                    until not IsAddonVisible("SelectYesno")

                    -- Waits until main char is present
                    LogInfo("[KupoBox] Waiting for " .. trading_with)
                    WaitUntilObjectExists(trading_with)
                    LogInfo("[KupoBox] Found " .. trading_with)

                    -- Paths to main char only if you have do_movement set to true
                    if do_movement then
                        -- Path to main char
                        LogInfo("[KupoBox] do_movement is set to true, moving towards " .. trading_with)
                        PathToObject(trading_with, 3.0)
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
                if party_invite and IsInParty() then
                    LogInfo("[KupoBox] Disbanding party")
                    PartyDisband()
                    Sleep(0.1)
                end
            end

            -- Deliver GC supply items
            DOL()

            -- Deliveroo expert delivery
            if expert_delivery and CanExpertDelivery() then
                GCDeliverooExpertDelivery()
            end

            -- Alt character handling to go home
            if return_home then
                LogInfo("[KupoBox] Returning home")
                ReturnHomeWorld()

                if return_location and return_location ~= "" then
                    LogInfo(string.format("[KupoBox] Attempting to go to %s", return_location))
                    -- Use "li" for lifestream stuff, otherwise use "tp"
                    local teleport_type = TeleportType(return_location) and "li" or "tp"
                    Teleporter(return_location, teleport_type)
                end
            end
        end
    end
end

ProcessAltCharacters(character_list, turnins_only)
LogInfo("[KupoBox] All characters complete, script finished")

if do_ays_multi then
    yield("/ays m")
end

if HasPlugin("YesAlready") then
    RestoreYesAlready()
end