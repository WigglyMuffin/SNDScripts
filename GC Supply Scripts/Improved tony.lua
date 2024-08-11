-- stuff could go here

--###################
--# FUNCTION LOADER #
--###################

SNDConfigFolder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
LoadFunctionsFileLocation = SNDConfigFolder .. "vac_functions.lua"
LoadFunctions = loadfile(LoadFunctionsFileLocation)
LoadFunctions()
LoadFileCheck()

--###########
--# CONFIGS #
--###########

local destination_server = "Louisoix"     -- Server characters need to travel for collecting items
local destination_zone = "Limsa Lominsa"  -- Zone characters need to travel for collecting items
local destination_zone_id = 129           -- Zone ID characters need to travel for collecting items, just match it to the zone above, can be found using GetZoneID()
local destination_house = 0               -- Options: 0 = FC, 1 = Personal, 2 = Apartment
local destination_type = 0                -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
local path_home = true                    -- Options: true = Paths home from destination, false = does nothing and logs out

-- Usage: First Last
-- This is your main character name
local main_char_name = "First Last"

-- This is a placeholder for alt character names, you do not set this and will be overwritten later
local alt_char_name = "First Last"

-- Usage: First Last@Server, return_home, return_location
-- return_home options: 0 = no, 1 = yes
-- return_location options: 0 = fc entrance, 1 nearby bell, 2 limsa bell
-- This is where your alts that need items are listed
local alt_char_name_list = {
    --{"First Last@Server", 0, 2},
    --{"First Last@Server", 0, 2},
    --{"First Last@Server", 0, 2},
    --{"First Last@Server", 0, 2},
    --{"First Last@Server", 0, 2}
}

--###############
--# MAIN SCRIPT #
--###############

local function processAltCharacters(alt_char_name_list, destination_server, destination_zone, destination_zone_id, destination_type, destination_house, path_home)
    for i = 1, #alt_char_name_list do
        -- Update alt character name
        local alt_char_name = alt_char_name_list[i][1]
        
        -- Switch characters if required, looks up current character and compares
        if GetCharacterName(true) ~= alt_char_name_list[i][1] then
            RelogCharacter(alt_char_name_list[i][1])
            Sleep(2.0)
            LoginCheck()
        end
        
        Echo("Picking up items from: " .. main_char_name)
        Echo("Processing " .. i .. "/" .. #alt_char_name_list .. ", current character: " .. alt_char_name)
        
        -- Check if alt character on correct server
        -- Teleporter(destination_server, "li")
        yield("/li " .. destination_server)
        
        repeat
            Sleep(0.1)
        until GetCurrentWorld() == WorldIDList[destination_server].ID and IsPlayerAvailable()
        
        -- Alt character destination type, how alt char is travelling to the main
        -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
        if destination_type == 0 then
            Echo("Teleporting to " .. destination_zone .. " to find " .. main_char_name)
            
            if destination_zone_id ~= GetZoneID() then
                Teleporter(destination_zone, "tp")
                ZoneTransitions()
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
            -- Path to main char
            PathToChar(main_char_name)
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
            
            -- Path to main char
            PathToChar(main_char_name)
            -- Invite main char to party, needs a target
            PartyInvite(main_char_name)
        end
        
        -- Wait for the gil transfer to complete
        WaitForGilIncrease(1)
        -- Disband party once gil trigger has happened
        PartyDisband()
        
        -- Alt character handling to go home
        if path_home then
            -- [2] return_home options: 0 = no, 1 = yes
            -- [3] return_location options: 0 = fc entrance, 1 nearby bell, 2 limsa bell
            if alt_char_name_list[i][2] == 1 then
                Echo("Attempting to return to " .. GetHomeWorld())
                
                -- GetCurrentWorld() == 0 and GetHomeWorld() == 0
                if GetCurrentWorld() ~= GetHomeWorld() then
                    -- Teleporter(GetHomeWorld(), "li")
                    yield("/li")
                end
                
                repeat
                    Sleep(0.1)
                until GetCurrentWorld() == GetHomeWorld() and IsPlayerAvailable()
                
                -- FC Entrance stuff
                if alt_char_name_list[i][3] == 0 then
                    Echo("Attempting to go to FC Entrance")
                    Teleporter("Estate Hall", "tp")
                    ZoneTransitions()
                    -- This likely needs some logic on nearest "Entrance" for nearby estates
                    PathToEstateEntrance()
                end
                
                -- Nearby Retainer Bell Stuff
                if alt_char_name_list[i][3] == 1 then
                    Echo("Attempting to go to nearest retainer bell")
                    Target("Summoning Bell")
                    Movement(GetObjectRawXPos("Summoning Bell"), GetObjectRawYPos("Summoning Bell"), GetObjectRawZPos("Summoning Bell"))
                end
                
                -- Limsa Retainer Bell Stuff
                if alt_char_name_list[i][3] == 2 then
                    Echo("Attempting to go to Limsa retainer bell")
                    PathToLimsaBell()
                end
            end
        end
    end
end

processAltCharacters(alt_char_name_list, destination_server, destination_zone, destination_zone_id, destination_type, destination_house, path_home)