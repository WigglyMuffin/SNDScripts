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

--#############
--# FUNCTIONS #
--#############
-- aka move this to functions file after

-- Usage: PathToChar("First Last")
-- Finds specified character and paths to it
function PathToChar(path_char_name)
    Movement(GetObjectRawXPos(path_char_name), GetObjectRawYPos(path_char_name), GetObjectRawZPos(path_char_name))
end

-- Finds where your estate entrance is and paths to it
-- I think this will break though since there will be multiple entrances around a housing area
-- So maybe needs nearest logic
function PathToEstateEntrance()
    Movement(GetObjectRawXPos("Entrance"), GetObjectRawYPos("Entrance"), GetObjectRawZPos("Entrance"))
end

-- Paths to Limsa bell
function PathToLimsaBell()
    if ZoneCheck(129, "Limsa", "tp") then
        -- stuff could go here
    else
        Movement(-123.72, 18.00, 20.55)
    end
end

-- Usage: WaitForGilIncrease(1)
-- Obtains current gil and waits for specified gil to be traded
-- Acts as the trigger before moving on
function WaitForGilIncrease(gil_increase_amount)
    -- Gil variable store before trade
    local previous_gil = GetGil()
    
    while true do
        Sleep(1.0) -- Wait for 1 second between checks
        
        local current_gil = GetGil()
        if current_gil > previous_gil and (current_gil - previous_gil) == gil_increase_amount then
            Echo(gil_increase_amount .. "Gil successfully traded")
            break -- Exit the loop when the gil increase is detected
        end
        
        previous_gil = current_gil -- Update gil amount for the next check
    end
end

-- Usage: PartyInvite("First Last")
-- Will target and invite player to a party, and retrying if the invite timeout happens
-- Probably think of a way to invite without needing a placeholder aka <t>
function PartyInvite(player_invite_name)
    local invite_timeout = 305 -- 300 Seconds is the invite timeout, adding 5 seconds for good measure
    local start_time = os.time() -- Stores the invite time
    
    while not IsInParty() do
        repeat
            Sleep(0.1)
        until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
        
        Target(player_invite_name)
        yield("/invite")
        
        -- Wait for the target player to accept the invite or the timeout to expire
        while not IsInParty() do
            Sleep(0.1)
            
            -- Check if the invite has expired
            if os.time() - start_time >= invite_timeout then
                Echo("Invite expired. Reinviting " .. player_invite_name)
                start_time = os.time() -- Reset the start time for the new invite
                break -- Break the loop to resend the invite
            end
        end
    end
    -- stuff could go here
end

-- Usage: PartyDisband()
-- Will check if player is in party and disband party
function PartyDisband()
    if IsInParty() then
        repeat
            Sleep(0.1)
        until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
        
        yield("/partycmd disband")
        
        repeat
            Sleep(0.1)
            yield("/pcall SelectYesno true 0")
        until not IsAddonVisible("SelectYesno")
    end
end

-- Usage: EstateTeleport("First Last", 0)
-- Options: 0 = Free Company, 1 = Personal, 2 = Apartment
-- Opens estate list of added friend and teleports to specified location
-- ZoneTransitions() not required
function EstateTeleport(estate_char_name, estate_type)
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
    
    yield("/estatelist " .. estate_char_name)
    
    repeat
        Sleep(0.1)
        yield("/pcall TeleportHousingFriend true " .. estate_type)
    until not IsAddonVisible("TeleportHousingFriend")
    
    ZoneTransitions()
end

--###############
--# MAIN SCRIPT #
--###############

local function processAltCharacters(altCharList, destination_server, destination_zone, destination_zone_id, destination_type, destination_house)
    for i = 1, #alt_char_name_list do
        -- Update alt character name
        local alt_char_name = alt_char_name_list[i][1]
        
        Echo("Picking up items from " .. main_char_name)
        Echo("Processing " .. i .. "/" .. #alt_char_name_list)
        
        -- Switch characters if required, looks up current character and compares
        if GetCharacterName(true) ~= alt_char_name_list[i][1] then
            yield("/ays relog " .. alt_char_name_list[i][1])
            Sleep(2.0)
            LoginCheck()
        end
        
        -- Not sure if this is needed twice, needs testing
        yield("/echo Processing Tony " .. i .. "/" .. #alt_char_name_list)
        
        -- Check if alt character on correct server
        yield("/li " .. destination_server)
        repeat
            Sleep(0.1)
        until GetCurrentWorld() == WorldIDList[destination_server].ID
        
        repeat
            Sleep(0.1)
        until IsPlayerAvailable()
        
        -- Alt character destination type, how alt is getting to the main
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
        
        -- Storing the current gil of alt character to be used later
        local previous_gil = GetGil()
        
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
                    Sleep(2.0)
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