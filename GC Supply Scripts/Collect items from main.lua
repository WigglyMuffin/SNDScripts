--[[
  _  __                      ____              
 | |/ /                     |  _ \             
 | ' / _   _  _ __    ___   | |_) |  ___ __  __
 |  < | | | || '_ \  / _ \  |  _ <  / _ \\ \/ /
 | . \| |_| || |_) || (_) | | |_) || (_) |>  < 
 |_|\_\\__,_|| .__/  \___/  |____/  \___//_/\_\
             | |                               
             |_|                               
##################################################################
##                     What does this script do?                ##
##################################################################

-- You need to have Auto Retainer know who your characters are otherwise it will not work, to fix you will need to log into each missing character manually

]]

-- ###########
-- # CONFIGS #
-- ###########

-- Edit char_list.lua file for configuring characters

local destination_server = "Louisoix"     -- Server characters need to travel for collecting items
local destination_aetheryte = "Limsa"     -- Aetheryte that characters need to travel to for collecting items, case insensitive and you can be vague
local destination_house = 0               -- Options: 0 = FC, 1 = Personal, 2 = Apartment
local destination_type = 0                -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
local path_home = true                    -- Options: true = Paths home from destination, false = does nothing and logs out
local do_movement = true                  -- Options: true = Paths to chosen character, false = does nothing and waits for chosen character to come to you
local use_external_character_list = true  -- Options: true = uses the external character list in the same folder, default name being char_list.lua, false uses the list you put in this file 

-- Usage: First Last
-- This is your main character name, do not include @Server
local main_char_name = "First Last"

-- This is where you put your character list if you choose to not use the external one
-- If us_external_character_list is set to true then this list is completely skipped
-- Usage: First Last@Server, return_home, return_location
-- return_home options: 0 = no, 1 = yes
-- return_location options: 0 = fc entrance, 1 nearby bell, 2 limsa bell
-- This is where your alts that need items are listed
local character_list_options = {
    {"First Last@Server", 0, 2},
    {"First Last@Server", 0, 2}
}

-- #####################################
-- #  DON'T TOUCH ANYTHING BELOW HERE  #
-- # UNLESS YOU KNOW WHAT YOU'RE DOING #
-- #####################################

-- ###################
-- # FUNCTION LOADER #
-- ###################

-- Edit char_list.lua file for configuring characters
char_list = "char_list.lua"

snd_config_folder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
load_functions_file_location = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(load_functions_file_location)
LoadFunctions()
LoadFileCheck()

LogInfo("[CIFM] ##############################")
LogInfo("[CIFM] Starting script...")
LogInfo("[CIFM] snd_config_folder: " .. snd_config_folder)
LogInfo("[CIFM] char_list: " .. char_list)
LogInfo("[CIFM] SNDConf+Char: " .. snd_config_folder .. "" .. char_list)
LogInfo("[CIFM] ##############################")

if use_external_character_list then
    local char_data = dofile(snd_config_folder .. char_list)
    character_list_options = char_data.character_list_options
end

local alt_char_name = ""

-- ###############
-- # MAIN SCRIPT #
-- ###############

local function ProcessAltCharacters(character_list_options, destination_server, destination_aetheryte, destination_type, destination_house, path_home)
    for i = 1, #character_list_options do
        -- Update alt character name
        local alt_char_name = character_list_options[i][1]
        
        -- Switch characters if required, looks up current character and compares
        if GetCharacterName(true) ~= character_list_options[i][1] then
            if not (ZoneCheck("Limsa Lominsa Lower") or ZoneCheck("Limsa Lominsa Upper")) then
                Teleporter("Limsa", "tp")
            end
            
            RelogCharacter(character_list_options[i][1])
            Sleep(7.5)
            LoginCheck()
        end
        
        Echo("Picking up items from: " .. main_char_name)
        Echo("Processing " .. i .. "/" .. #character_list_options .. ", current character: " .. alt_char_name)
        
        -- Check if alt character on correct server
        -- Teleporter(destination_server, "li")
        yield("/li " .. destination_server)
        
        repeat
            Sleep(0.1)
        until GetCurrentWorld() == WorldIDList[destination_server].ID and IsPlayerAvailable()
        
        -- Alt character destination type, how alt char is travelling to the main
        -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
        if destination_type == 0 then
            dest_aetheryte, dest_aetheryte_fullname = FindZoneIDByAetheryte(destination_aetheryte)
            if dest_aetheryte ~= GetZoneID() then
                Echo("Teleporting to " .. dest_aetheryte_fullname .. " to find " .. main_char_name)
                Teleporter(destination_aetheryte, "tp")
                ZoneTransitions()
            else
                Echo("Already in the right zone to meet "..main_char_name)
            end
        end
        
        -- Requires main added to friend list for access to estate list teleports
        -- Keeping it for future stuff
        if destination_type > 0 then
            Echo("Teleporting to estate to find " .. main_char_name)
            EstateTeleport(main_char_name, destination_house)
        end
        -- I really don't like the repeat of destination_type checking here, should probably be refactored into stuff above
        -- Handle different destination types
        -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
        if destination_type == 0 or destination_type == 1 then
            -- Waits until main char is present
            WaitUntilObjectExists(main_char_name)
            
            -- Paths to main char only if you have do_movement set to true
            if do_movement then
                -- Path to main char
                PathToObject(main_char_name)
            end
            
            -- Invite main char to party, needs a target
            PartyInvite(main_char_name)
            
        elseif destination_type == 2 then
            -- If destination_type is 2, first go to the estate entrance, then to the main character
            PathToEstateEntrance()
            Interact()
            
            repeat
                Sleep(0.1)
                yield("/pcall SelectYesno true 0")
            until not IsAddonVisible("SelectYesno")
            
            -- Waits until main char is present
            WaitUntilObjectExists(main_char_name)
            
            -- Paths to main char only if you have do_movement set to true
            if do_movement then
                -- Path to main char
                PathToObject(main_char_name)
            end
            
            -- Invite main char to party, needs a target
            PartyInvite(main_char_name)
        end
        
        -- Wait for the gil transfer to complete
        WaitForGilIncrease(1)
        
        -- Notify when all characters are finished
        if i == #character_list_options then
            Echo("Finished all " .. #character_list_options .. " characters")
        end
        
        -- Disband party once gil trigger has happened
        PartyDisband()
        
        -- Alt character handling to go home
        if path_home then
            -- [2] return_home options: 0 = no, 1 = yes
            -- [3] return_location options: 0 = fc entrance, 1 nearby bell, 2 limsa bell
            if character_list_options[i][2] == 1 then
                Echo("Attempting to return to " .. GetHomeWorld())
                
                if GetCurrentWorld() ~= GetHomeWorld() then
                    -- Teleporter(GetHomeWorld(), "li")
                    yield("/li")
                end
                
                repeat
                    Sleep(0.1)
                until GetCurrentWorld() == GetHomeWorld() and IsPlayerAvailable()
                
                -- FC Entrance stuff
                if character_list_options[i][3] == 0 then
                    Echo("Attempting to go to FC Entrance")
                    Teleporter("Estate Hall", "tp")
                    ZoneTransitions()
                    -- This likely needs some logic on nearest "Entrance" for nearby estates
                    PathToEstateEntrance()
                end
                
                -- Nearby Retainer Bell Stuff
                if character_list_options[i][3] == 1 then
                    Echo("Attempting to go to nearest retainer bell")
                    Target("Summoning Bell")
                    Movement(GetObjectRawXPos("Summoning Bell"), GetObjectRawYPos("Summoning Bell"), GetObjectRawZPos("Summoning Bell"))
                end
                
                -- Limsa Retainer Bell Stuff
                if character_list_options[i][3] == 2 then
                    Echo("Attempting to go to Limsa retainer bell")
                    PathToLimsaBell()
                end
            end
        end
    end
end

ProcessAltCharacters(character_list_options, destination_server, destination_aetheryte, destination_type, destination_house, path_home)
