-- This file needs to be dropped inside %appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\
-- So it should look like this %appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\vac_functions.lua
-- It contains the functions required to make the scripts work

function LoadFileCheck()
	Echo("Successfully loaded the functions file")
end

-- ###############
-- # TO DO STUFF #
-- ###############

-- Full quest list with both quest IDs and key IDs
-- Dungeon ID list
-- Distance stuff
-- Redo Teleporter()
-- Redo Movement()
-- IsQuestNameAccepted() see below
-- IsHuntLogComplete() see below
-- Add Lifestream ipc now that it's in SND

-- #####################################
-- #####################################
-- #####################################
-- #####################################

-- InteractAndWait()
--
-- Interacts with the current target and waits until the player is available again before proceeding
function InteractAndWait()
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
    
    Dismount()
    yield("/interact")
    
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
end

-- Usage: LoginCheck()
-- Waits until player NamePlate is visible and player is ready
function LoginCheck()
    repeat
        Sleep(0.1)
    until IsAddonVisible("NamePlate") and IsPlayerAvailable()
end

-- Usage: VNavChecker()
-- Waits until player no longer has a nav path running
-- Very likely getting removed
function VNavChecker() --Movement checker, does nothing if moving
    repeat
        Sleep(0.1)
    until not PathIsRunning() and IsPlayerAvailable()
end

-- Interact()
--
-- Just interacts with the current target
function Interact()
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26) and not IsMoving() or GetCharacterCondition(32)
    
    Dismount()
    yield("/interact")
end

-- Usage: IsInParty()
-- Checks if player is in a party, returns true if in party, returns false if not in party
function IsInParty()
    return GetPartyMemberName(0) ~= nil and GetPartyMemberName(0) ~= ""
end

-- Usage: ZoneCheck("Limsa Lominsa Lower Decks")
--
-- Checks if you're currently in the provided zone
function ZoneCheck(zone_name)
    local zone_id = FindZoneID(zone_name)
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26) and not GetCharacterCondition(32)

    if GetZoneID() == zone_id then
        return true -- Returns true if zone matches
    else
        return false -- Returns false if zone doesn't match
    end
end

-- Usage: Echo("meow")
--
-- prints provided text into chat
function Echo(text)
    yield("/echo " .. text)
end

-- Usage: Sleep(0.1) or Sleep("0.1")
--
-- replaces yield wait spam, halts the script for X seconds 
function Sleep(time)
    yield("/wait " .. tostring(time))
end

-- Usage: ZoneTransitions()
--
-- Zone transition checker, does nothing if changing zones
function ZoneTransitions()
    -- Check if player is in transition between zones
    while not (GetCharacterCondition(45) or GetCharacterCondition(51)) do
        Sleep(0.1)
    end
    
    -- Wait until player no longer in transition between zones
    while GetCharacterCondition(45) or GetCharacterCondition(51) do
        Sleep(0.1)
    end
    
    -- Check if player is available
    while not IsPlayerAvailable() or IsPlayerCasting() or GetCharacterCondition(26) or GetCharacterCondition(32) do
        Sleep(0.1)
    end
end


-- Usage: QuestNPC("SelectYesno"|"CutSceneSelectString", true, 0)
--
-- NPC interaction handler, only supports one dialogue option for now. DialogueOption optional.
function QuestNPC(DialogueType, DialogueConfirm, DialogueOption)
    while not GetCharacterCondition(32) do
        yield("/interact")
        Sleep(0.1)
    end
    if DialogueConfirm then
        repeat 
            Sleep(0.1)
        until IsAddonVisible(DialogueType)
        if DialogueOption == nil then
            repeat
                yield("/pcall " .. DialogueType .. " true 0")
                Sleep(0.1)
            until not IsAddonVisible(DialogueType)
        else
            repeat
                yield("/pcall " .. DialogueType .. " true " .. DialogueOption)
                Sleep(0.1)
            until not IsAddonVisible(DialogueType)
        end
    end
    repeat
        Sleep(0.1)
    until IsPlayerAvailable()
end

-- Usage: QuestNPCSingle("SelectYesno"|"CutSceneSelectString", true, 0)
--
-- NPC interaction handler. dialogue_option optional.
function QuestNPCSingle(dialogue_type, dialogue_confirm, dialogue_option)
    while not GetCharacterCondition(32) do
        yield("/interact")
        Sleep(0.5)
    end
    if dialogue_confirm then
        repeat 
            Sleep(0.1)
        until IsAddonReady(dialogue_type)
        Sleep(0.5)
        if dialogue_option == nil then
            yield("/pcall " .. dialogue_type .. " true 0")
            Sleep(0.5)
        else
            yield("/pcall " .. dialogue_type .. " true " .. dialogue_option)
            Sleep(0.5)
        end
    end
end

-- Usage: TargetNearestEnemy("Heckler Imp", 20)
-- 
-- Targets the nearest enemy of the name you supply, within the radius
function TargetNearestEnemy(target_name, radius)
    local smallest_distance = 10000000000000.0
    local closest_target
    local objectKind = 0 -- Set objectkind to 0 so GetNearbyObjectNames pulls everything nearby
    local radius = radius or 0
    local nearby_objects = GetNearbyObjectNames(radius^2,objectKind) -- Pull all nearby objects/enemies into a list
    if nearby_objects.Count > 0 then -- Starts a loop if there's more than 0 nearby objects
      for i = 0, nearby_objects.Count - 1 do  -- loops until no more objects 
        yield("/target "..nearby_objects[i])
        if not GetTargetName() or nearby_objects[i] ~= GetTargetName() then -- If target name is nil, skip it
        elseif GetDistanceToTarget() < smallest_distance and GetTargetName() == target_name then -- if object matches the target_name and the distance to target is smaller than the current smallest_distance, proceed
          smallest_distance = GetDistanceToTarget()
          closest_target = GetTargetName()
        end
      end
      ClearTarget()
      if closest_target then yield("/target "..closest_target) end -- after the loop ends it targets the closest enemy
    end
    return closest_target
end

-- Usage: FindAndKillTarget("Heckler Imp", 20)
-- 
-- Utilizes TargetNearestEnemy() to find and kill the provided target within the radius
function FindAndKillTarget(target_name, radius)
    TargetNearestEnemy(target_name, radius)
    local dist_to_target = GetDistanceToTarget()
    local auto_attack_triggered = false
    
    while GetTargetHP() > 0 and dist_to_target <= radius do
        if GetCharacterCondition(4) then
            repeat
                Dismount()
                Sleep(0.1)
            until not GetCharacterCondition(4)
        end
        
        yield("/rotation manual")
        
        repeat
            if not (GetDistanceToTarget() <= 2) and not PathIsRunning() then  
                yield("/vnavmesh movetarget")
            end
            
            if GetDistanceToTarget() <= 2 and not auto_attack_triggered then
                DoAction("Auto-attack")
                
                if IsTargetInCombat() and GetCharacterCondition(26) then
                    auto_attack_triggered = true
                end
            end
            
            Sleep(0.1)
        until GetTargetHP() <= 0
        
        yield("/vnavmesh stop")
    end
    Sleep(0.5)
    if GetCharacterCondition(26) then
        yield("/rotation auto")
        repeat
            Sleep(0.1)
        until not GetCharacterCondition(26)
    end
end

-- Usage: GetNodeTextLookupUpdate("_ToDolist",16,3,4) // GetNodeTextLookupUpdate("_ToDolist",16,3)
--
-- function that's honestly nothing but tragic, is only called by Questchecker and Nodescanner, could be called manually.
function GetNodeTextLookupUpdate(get_node_text_type, get_node_text_location, get_node_text_location_1, get_node_text_location_2)
    bypass = "next task"
    if get_node_text_location_2 == nil then 
        LogInfo("GetNodeTextLookupUpdate: "..get_node_text_type.." "..get_node_text_location.." "..get_node_text_location_1)
        get_node_text = GetNodeText(get_node_text_type, get_node_text_location, get_node_text_location_1)
        if get_node_text == get_node_text_location_1 then
            return bypass
        else
            return get_node_text
        end
    --- i hate
    else
        LogInfo("GetNodeTextLookupUpdate2: "..get_node_text_type.." "..get_node_text_location.." "..get_node_text_location_1.." "..get_node_text_location_2)
        get_node_text = GetNodeText(get_node_text_type, get_node_text_location, get_node_text_location_1, get_node_text_location_2)
        if get_node_text == get_node_text_location_2 then
            return bypass
        else
            return get_node_text
        end
    --- this function
    end
    Echo("GetNodeTextLookupUpdate went wrong somewhere")
end

-- Usage: QuestChecker(ArcanistEnemies[3], 50, "_ToDoList", "Slay little ladybugs.")
--
-- This is used to find the provided target in the _ToDolist node and kill them until no more targets are needed
function QuestChecker(target_name, target_distance, get_node_text_type, get_node_text_match)
    local get_node_text_location, get_node_text_location_1, get_node_text_location_2 = NodeScanner(get_node_text_type, get_node_text_match)
    local function extractTask(text)
        local task = string.match(text, "^(.-)%s%d+/%d+$")
        return task or text
    end
    while true do
        updated_node_text = GetNodeTextLookupUpdate(get_node_text_type, get_node_text_location, get_node_text_location_1, get_node_text_location_2)
        LogInfo("[JU] updated_node_text: "..updated_node_text)
        LogInfo("[JU] Extract: "..extractTask(updated_node_text))
        local last_char = string.sub(updated_node_text, -1)
        LogInfo("[JU] last char: "..updated_node_text)
        Sleep(2.0)
        if updated_node_text == get_node_text_match or not string.match(last_char, "%d") then
            break
        end
        FindAndKillTarget(target_name, target_distance)
    end
    -- checks if player in combat before ending rotation solver
    if not GetCharacterCondition(26) then
        yield("/rotation off")
    end
end

-- Usage: NodeScanner("_ToDoList", "Slay wild dodos.")
--
-- scans provided node type for node that has provided text and returns minimum 2 but up to 3 variables with the location which you can use with GetNodeText()
--
-- this will fail if the node is too nested and scanning deeper than i am currently is just not a good idea i think
function NodeScanner(get_node_text_type, get_node_text_match)
    node_type_count = tonumber(GetNodeListCount(get_node_text_type))
    local function extractTask(text)
        local task = string.match(text, "^(.-)%s*%d*/%d*$")
        return task or text
    end
    for location = 0, node_type_count do
        for sub_node = 0, 60 do
            Sleep(0.0001)
            local node_check = GetNodeText(get_node_text_type, location, sub_node)
            local clean_node_text = extractTask(node_check)
            if clean_node_text == nil then
            else 
                --LogInfo(tostring(clean_node_text))
            end
            if clean_node_text == get_node_text_match then
                return location, sub_node
            end
        end
    end
    -- deeper scan
    for location = 0, node_type_count do
        for sub_node = 0, 60 do
            for sub_node2 = 0, 20 do
                Sleep(0.0001)
                local node_check = GetNodeText(get_node_text_type, location, sub_node, sub_node2)
                local clean_node_text = extractTask(node_check)
                if clean_node_text == nil then
                else 
                    --LogInfo(tostring(clean_node_text))
                end
                if clean_node_text == get_node_text_match then
                    return location, sub_node, sub_node2
                end
            end
        end
    end
    Echo("Can't find the node text, everything will probably crash now since there's no proper handler yet")
    return
end

-- Usage: SpecialUiCheck("MonsterNote", true)
--
-- Closes or opens supported ui's, true is close and false or leaving it empty is open. Probably will be changed into individual functions like i've already done for some
-- or probably will be deprecated
function SpecialUiCheck(get_node_text_type, close_ui, extra)
    -- hunting log checks
    if get_node_text_type == "MonsterNote" then
        if close_ui() then
            OpenGCHuntLog(extra)
        else
            CloseGCHuntLog()
        end
    else
        return
    end
end

-- Usage: OpenHuntLog(9, 0), Defaults to rank 0 if empty
-- Valid classes: 0 = GLA, 1 = PGL, 2 = MRD, 3 = LNC, 4 = ARC, 5 = ROG, 6 = CNJ, 7 = THM, 8 = ACN, 9 = GC
-- Valid ranks/pages: 0-4 for jobs, 0-2 for GC
-- Valid show: 0 = show all, 1 = show complete, 2 = show incomplete
-- The first variable is the class to open, the second is the rank to open
function OpenHuntLog(class, rank, show)
    local defaultshow = 2
    local defaultrank = 0 --
    local defaultclass = 9 -- this is the gc log
    rank = rank or defaultrank
    class = class or defaultclass
    show = show or defaultshow
    -- 1 Maelstrom
    -- 2 Twin adders
    -- 3 Immortal flames
    repeat
        yield("/huntinglog")
        Sleep(0.5)
    until IsAddonReady("MonsterNote")
    local gc_id = GetPlayerGC()
    if class == 9 then
        yield("/pcall MonsterNote false 3 9 "..tostring(gc_id))
    else 
        yield("/pcall MonsterNote false 0 "..tostring(class))
    end
    Sleep(0.3)
    yield("/pcall MonsterNote false 1 "..rank)
    Sleep(0.3)
    yield("/pcall MonsterNote false 2 "..show)
end

-- Usage: CloseHuntLog()  
-- Closes the Hunting Log if open
function CloseHuntLog()
    repeat
        yield("/huntinglog")
        Sleep(0.5)
    until not IsAddonVisible("MonsterNote")
end

-- Usage: HuntLogCheck("Amalj'aa Hunter", 9, 0)
-- Valid classes: 0 = GLA, 1 = PGL, 2 = MRD, 3 = LNC, 4 = ARC, 5 = ROG, 6 = CNJ, 7 = THM, 8 = ACN, 9 = GC
-- Valid ranks/pages: 0-4 for jobs, 0-2 for GC
-- Opens and checks current progress and returns a true if finished or a false if not
function HuntLogCheck(target_name,class,rank)
    OpenHuntLog(class,rank, 2)
    local node_text = ""
    local function CheckTargetAmountNeeded(sub_node)
        local target_amount = tostring(GetNodeText("MonsterNote", 2, sub_node, 3))
        local first_number = tonumber(target_amount:sub(1, 1))
        local last_number = tonumber(target_amount:sub(-1))
        if first_number == last_number then
            return 0
        else
            return last_number - first_number
        end
    end
    local function FindTargetNode()
        for sub_node = 5, 60 do
            Sleep(0.001)
            node_text = tostring(GetNodeText("MonsterNote", 2, sub_node, 4))
            if node_text == target_name then
                return sub_node
            end
        end
    end
    local target_amount_needed_node = FindTargetNode()
    if not target_amount_needed_node then
        LogInfo("Couldn't find "..target_name.." in hunting log, likely already finished")
        return false, 0
    else
        LogInfo("Found "..target_name.." in hunting log, time to hunt")
        local target_amount_needed = CheckTargetAmountNeeded(target_amount_needed_node)
        if target_amount_needed == 0 then
            CloseHuntLog()
            return false, target_amount_needed
        else
            CloseHuntLog()
            return true, target_amount_needed
        end
    end
end
-- Usage: DoHuntLog("Amalj'aa Hunter", 40, 9, 0)
-- Valid classes: 0 = GLA, 1 = PGL, 2 = MRD, 3 = LNC, 4 = ARC, 5 = ROG, 6 = CNJ, 7 = THM, 8 = ACN, 9 = GC
-- Valid ranks/pages: 0-4 for jobs, 0-2 for GC
-- Opens and checks current progress of Hunting Log for automated killing
function DoHuntLog(target_name, target_distance, class, rank)
    local finished = false
    local TargetsLeft, AmountLeft = HuntLogCheck(target_name,class,rank)
    if AmountLeft > 0 and TargetsLeft then
        while not finished do 
            TargetsLeft, AmountLeft = HuntLogCheck(target_name,class,rank)
            if AmountLeft == 0 then
                finished = true
            else
                FindAndKillTarget(target_name, target_distance)
            end
            Sleep(3)
        end
        if not GetCharacterCondition(26) then
            yield("/rotation off")
        end
    end
end

-- Usage: Teleporter("Limsa", "tp") or Teleporter("gc", "li")  
-- add support for item tp Teleporter("Vesper", "item")  
-- likely rewriting teleporter to have own version of lifestream with locations, coords and nav/tp handling
-- add trade detection to initiate /busy and remove after successful tp
-- maybe add random delays between retries
-- function Teleporter(location, tp_kind) -- Teleporter handler
    -- local lifestream_stopped = false
    -- local cast_time_buffer = 5 -- Just in case a buffer is required, teleports are 5 seconds long. Slidecasting, ping and fps can affect casts
    -- local max_retries = 10  -- Teleporter retry amount, will not tp after number has been reached for safety
    -- local retries = 0
    
    -- -- Initial check to ensure player can teleport
    -- repeat
        -- Sleep(0.1)
    -- until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26) and not GetCharacterCondition(32) -- 26 is combat, 32 is quest event
    
    -- -- Try teleport, retry until max_retries is reached
    -- while retries < max_retries do
        -- -- Stop lifestream only once per teleport attempt
        -- if FindZoneIDByAetheryte(location) == GetZoneID() and not tp_kind == "li" then
            -- LogInfo("Already in the right zone")
            -- break
        -- end
        
        -- if tp_kind == "li" and not lifestream_stopped then
            -- yield("/lifestream stop")
            -- lifestream_stopped = true
            -- Sleep(0.1)
        -- end
        
        -- -- Attempt teleport
        -- if not IsPlayerCasting() then
            -- yield("/" .. tp_kind .. " " .. location)
            -- Sleep(2.0) -- Wait to check if casting starts
            
            -- -- Check if the player started casting
            -- if IsPlayerCasting() then
                -- Sleep(cast_time_buffer) -- Wait for cast to complete
            -- end
        -- end

        -- -- pause when lifestream is running and only break out of the loop when it's done
        -- if LifestreamIsBusy() then
            -- repeat
                -- Sleep(0.1)
            -- until not LifestreamIsBusy() and IsPlayerAvailable()
            -- break
        -- end

        -- -- Check if the teleport was successful
        -- if GetCharacterCondition(45) or GetCharacterCondition(51) then -- 45 is BetweenAreas, 51 is BetweenAreas51
            -- LogInfo("Teleport successful.")
            -- break
        -- end
        
        -- -- Teleport retry increment
        -- retries = retries + 1
        -- LogInfo("Retrying teleport attempt #" .. retries)
        
        -- -- Reset lifestream_stopped for next retry
        -- lifestream_stopped = false
    -- end
    
    -- -- Teleporter failed handling
    -- if retries >= max_retries then
        -- local attempt_word = (max_retries == 1) and "attempt" or "attempts"
        -- LogInfo("Teleport failed after " .. max_retries .. " " .. attempt_word .. ".")
        -- Echo("Teleport failed after " .. max_retries .. " " .. attempt_word .. ".")
        -- yield("/lifestream stop") -- Not always needed but removes lifestream ui
    -- end
-- end

-- New Teleport needs testing
-- Usage: Teleporter("Limsa", "tp") or Teleporter("gc", "li") or Teleporter("Vesper", "item")
-- Options: location = teleport location, tp_kind = tp, li, item
function Teleporter(location, tp_kind) -- Teleporter handler
    local cast_time_buffer = 5 -- Teleports are 5 seconds long, include buffer time
    local max_retries = 10 -- Max retries for teleport
    local retries = 0
    local cast_check_interval = 0.1 -- Interval to check if casting started
    
    -- Helper function to check if teleport was successful
    local function is_teleport_successful()
        return GetCharacterCondition(45) or GetCharacterCondition(51)
    end

    -- Check if player is available and not casting or in combat/event, else a teleport cannot happen
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26) and not GetCharacterCondition(32)

    -- Teleport attempt loop
    while retries < max_retries do
        -- Pass lifestream stop if "li" teleport is used
        if tp_kind == "li" then
            yield("/lifestream stop")
            Sleep(0.1)
        end

        -- If already in the specified zone, no need to teleport
        if FindZoneIDByAetheryte(location) == GetZoneID() then
            LogInfo("Already in the right zone")
            return true
        end
        
        -- Attempt teleport
        if tp_kind == "item" then
            UseItemTeleport(location) -- Use item to teleport
        else
            yield("/" .. tp_kind .. " " .. location)
        end
        
        -- Check if casting started
        local cast_started = false
        for i = 1, 20 do -- Check 20 times, with cast_check_interval delay
            if IsPlayerCasting() then
                cast_started = true
                break
            end
            Sleep(cast_check_interval)
        end
        
        -- Check if casting started and wait for it to finish
        if cast_started then
            Sleep(cast_time_buffer)
        end
        
        -- Checks if player is between zones
        ZoneTransitions()
        
        -- If lifestream is busy, wait for it to finish
        if tp_kind == "li" and LifestreamIsBusy() then
            repeat
                Sleep(0.1)
            until not LifestreamIsBusy()
        end

        -- Increment retries if teleport failed
        retries = retries + 1
        local retry_word = (max_retries == 1) and "retry" or "retries"
        LogInfo("Retrying teleport attempt #" .. max_retries .. " " .. retry_word .. ".")
    end
    
    -- If retries exhausted, handle failure
    if retries >= max_retries then
        local attempt_word = (max_retries == 1) and "attempt" or "attempts"
        LogInfo("Teleport failed after " .. max_retries .. " " .. attempt_word .. ".")
        Echo("Teleport failed after " .. max_retries .. " " .. attempt_word .. ".")
        yield("/lifestream stop") -- Stop lifestream and clear lifestream ui
        return false
    end
end

-- NEEDS doing
-- Hook it up with the item list
function UseItemTeleport(location)
    -- TP items mapped
    local teleport_items = {
        ["Immortal Flames"] = "Immortal Flames Aetheryte Ticket",
        ["Maelstrom"] = "Maelstrom Aetheryte Ticket",
        ["Twin Adder"] = "Twin Adder Aetheryte Ticket",
        ["Firmament"] = "Firmament Aetheryte Ticket",
        ["Vesper Bay"] = "Vesper Bay Aetheryte Ticket"
    }
    
    local item = teleport_items[location]
    
    if item then
        -- Don't know how to do this yet
        yield("/item_teleport " .. item)
    else
        LogInfo("No teleport item found for location: " .. location)
        Echo("No teleport item found for location: " .. location)
    end
end

-- stores if the mount message in Mount() has been sent already or not
local mount_message = false
-- Usage: Mount("SDS Fenrir") 
--
-- Will use Company Chocobo if left empty
function Mount(mount_name)
    local max_retries = 10   -- Maximum number of retries
    local retry_interval = 1.0 -- Time interval between retries in seconds
    local retries = 0        -- Counter for the number of retries

    -- Check if the player has unlocked mounts by checking the quest completion
    if not (IsQuestComplete(66236) or IsQuestComplete(66237) or IsQuestComplete(66238)) then
        if not mount_message then
            Echo('You do not have a mount unlocked, please consider completing the "My Little Chocobo" quest.')
        else
            mount_message = true
        end
        return
    end

    if TerritorySupportsMounting() then -- Check if territory is mountable using the snd function

        -- Return if the player is already mounted
        if GetCharacterCondition(4) then
            return
        end

        -- Initial check to ensure the player can mount
        repeat
            Sleep(0.1)
        until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)

        -- Retry loop for mounting with a max retry limit (set above)
        while retries < max_retries do
            -- Attempt to mount using the chosen mount or Mount Roulette if none
            if mount_name == nil then
                yield('/mount "Company Chocobo"')
            else
                yield('/mount "' .. mount_name .. '"')
            end

            -- Wait for the retry interval
            Sleep(retry_interval)

            -- Exit loop if the player mounted
            if GetCharacterCondition(4) then
                local attempt_word = (retries == 1) and "retry" or "retries"
                Echo("Successfully mounted after " .. retries .. " " .. attempt_word .. ".")
                break
            end

            -- Increment the retry counter
            retries = retries + 1
        end

        -- Check if max retries were reached without success
        if retries >= max_retries then
            local attempt_word = (max_retries == 1) and "retry" or "retries"
            Echo("Failed to mount after " .. max_retries .. " " .. attempt_word .. ".")
        end

        -- Check player is available and mounted
        repeat
            Sleep(0.1)
        until IsPlayerAvailable() and GetCharacterCondition(4)
    else
        Echo("Not possible to mount here")
        return
    end
end

-- Usage: LogOut()
function LogOut()
    repeat
        yield("/logout")
        Sleep(0.1)
    until IsAddonVisible("SelectYesno")
    
    repeat
        yield("/pcall SelectYesno true 4")
        Sleep(0.1)
    until not IsAddonVisible("SelectYesno")
end

-- Usage: Movement(674.92, 19.37, 436.02) // Movement(674.92, 19.37, 436.02, 15)  
-- the first three are x y z coordinates and the last one is how far away it's allowed to stop from the target
-- deals with vnav movement, kind of has some stuck checks but it's probably not as reliable as it can be, you do not have to include range
function Movement(x_position, y_position, z_position, range)
    local range = range or 2.4494898 -- 2, 2.4494898, 2.8284272, 3.464101 = 4, 6, 8, 12
    local max_retries = 100
    local stuck_check_interval = 0.1
    local stuck_threshold_seconds = 3
    local min_progress_distance = 1
    local min_distance_for_mounting = 20

    local function floor_position(pos)
        return math.floor(pos + 0.49999999999999994)
    end

    local x_position_floored = floor_position(x_position)
    local y_position_floored = floor_position(y_position)
    local z_position_floored = floor_position(z_position)

    local function IsWithinRange(xpos, ypos, zpos)
        return math.abs(xpos - x_position_floored) <= range and
               math.abs(ypos - y_position_floored) <= range and
               math.abs(zpos - z_position_floored) <= range
    end

    local function GetDistanceToTarget(xpos, ypos, zpos)
        return math.sqrt(
            (xpos - x_position_floored)^2 +
            (ypos - y_position_floored)^2 +
            (zpos - z_position_floored)^2
        )
    end

    local function NavToDestination()
        NavReload()
        
        repeat
            Sleep(0.1)
        until NavIsReady()

        local retries = 0
        repeat
            Sleep(0.1)
            local xpos = floor_position(GetPlayerRawXPos())
            local ypos = floor_position(GetPlayerRawYPos())
            local zpos = floor_position(GetPlayerRawZPos())
            local distance_to_target = GetDistanceToTarget(xpos, ypos, zpos)

            if distance_to_target > min_distance_for_mounting and TerritorySupportsMounting() then
                repeat
                    Mount()
                    Sleep(0.1)
                until GetCharacterCondition(4)
            end
            
            yield("/vnav moveto " .. x_position .. " " .. y_position .. " " .. z_position)
            retries = retries + 1
        until PathIsRunning() or retries >= max_retries

        Sleep(0.1)
    end

    NavToDestination()

    local stuck_timer = 0
    local previous_distance_to_target = nil
    while true do
        if not GetCharacterCondition(45) then
            local xpos = floor_position(GetPlayerRawXPos())
            local ypos = floor_position(GetPlayerRawYPos())
            local zpos = floor_position(GetPlayerRawZPos())
            Sleep(0.1)
            
            local current_distance_to_target = GetDistanceToTarget(xpos, ypos, zpos)

            if IsWithinRange(xpos, ypos, zpos) and not GetCharacterCondition(45) then
                yield("/vnav stop")
                break
            end

            if previous_distance_to_target and not GetCharacterCondition(45) then
                if current_distance_to_target >= previous_distance_to_target - min_progress_distance then
                    stuck_timer = stuck_timer + stuck_check_interval
                else
                    stuck_timer = 0
                end
            end
            previous_distance_to_target = current_distance_to_target

            if stuck_timer >= stuck_threshold_seconds and not GetCharacterCondition(45) then
                DoGeneralAction("Jump")
                Sleep(0.1)
                DoGeneralAction("Jump")
                NavReload()
                
                repeat
                    Sleep(0.1)
                until NavIsReady()
                
                NavToDestination()
                stuck_timer = 0
            end

            Sleep(0.05)
        end
        if GetCharacterCondition(45) then
            break
        end
    end
end


-- Usage: OpenTimers()
-- this should probably be renamed to open gc timers
-- Opens the timers window
function OpenTimers()
    local last_trigger_time = os.time()
    local retry_interval = 5  -- x seconds interval between retries

    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerOccupied()
    yield("/timers")
    repeat
        local current_time = os.time()
        if current_time - last_trigger_time >= retry_interval then  -- Activate once every x seconds
            yield("/timers")
            last_trigger_time = current_time  -- Store the last trigger time
        end
        Sleep(0.1)
    until IsAddonReady("ContentsInfo")

    last_trigger_time = 0 -- Reset the trigger time

    repeat
        local current_time = os.time()
        if current_time - last_trigger_time >= retry_interval then -- Activate once every x seconds
            yield("/pcall ContentsInfo True 12 1")
            last_trigger_time = current_time  -- Store the last trigger time
        end
        Sleep(0.1)
    until IsAddonReady("ContentsInfoDetail")
end

-- Usage: MarketBoardChecker()
--
-- just checks if the marketboard is open and keeps the script stopped until it's closed
function MarketBoardChecker()
    local ItemSearchWasVisible = false
    repeat
        Sleep(0.1)
        if IsAddonVisible("ItemSearch") then
            ItemSearchWasVisible = true
        end
    until ItemSearchWasVisible
    
    repeat
        Sleep(0.1)
    until not IsAddonVisible("ItemSearch")
end

-- Usage: BuyFromStore(1, 15) <--- buys 15 of X item
--
-- number_in_list is which item you're buying from the list, top item is 1, 2 is below that, 3 is below that etc...  
-- only works for the "Store" addon window, i'd be careful calling it anywhere else
function BuyFromStore(number_in_list, amount)
    -- compensates for the top being 0
    number_in_list = number_in_list - 1
    attempts = 0
    repeat
        attempts = attempts + 1
        Sleep(0.1)
    until (IsAddonReady("Shop") or attempts >= 100)
    -- attempts above 50 is about 5 seconds
    if attempts >= 100 then
        Echo("Waited too long, store window not found, moving on")
    end
    if IsAddonReady("Shop") and number_in_list and amount then
        yield("/pcall Shop True 0 "..number_in_list.." "..amount)
        repeat
            Sleep(0.1)
        until IsAddonReady("SelectYesno")
        yield("/pcall SelectYesno true 0")
        Sleep(0.5)
    end
end

-- Usage: CloseStore()  
-- Function used to close store windows
function CloseStore()
    if IsAddonVisible("Shop") then
        yield("/pcall Shop True -1")
    end
    
    repeat
        Sleep(0.1)
    until not IsAddonVisible("Shop")
    
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
end

-- Usage: Target("Storm Quartermaster")  
-- TODO: target checking for consistency and speed
function Target(target)
    repeat
        yield('/target "' .. target .. '"')
        Sleep(0.1)
    until string.lower(GetTargetName()) == string.lower(target)
end


-- Usage: GcRankUp()  
-- 
-- Checks if you can rank up in your current gc, then it'll attempt to rank you up
function DoGcRankUp()
    yield("/at e")
    local gc_id = GetPlayerGC()
    local gc_rank_9_mission_complete = false
    local gc_rank_8_mission_complete = false
    local can_rankup, next_rank = CanGCRankUp()
    
    local gc_officer_names = {
        [1] = "Storm Personnel Officer",
        [2] = "Serpent Personnel Officer",
        [3] = "Flame Personnel Officer"
    }

    local function OpenAndAttemptRankup()
        local gc_target = gc_officer_names[gc_id]
        if gc_target then
            -- Target the correct GC officer
            Target(gc_target)
            yield("/lockon")
        else
            return
        end
        repeat
            yield("/pint")
            Sleep(0.1)
        until IsAddonReady("SelectString")
        yield("/pcall SelectString true 1")
        repeat
            Sleep(0.1)
        until IsAddonReady("GrandCompanyRankUp")
        yield("/pcall GrandCompanyRankUp true 0")
    end

    if gc_id == 1 then -- checks if gc is maelstrom and checks if the quests are done
        gc_rank_8_mission_complete = IsQuestComplete(66664)
        gc_rank_9_mission_complete = IsQuestComplete(66667)

    elseif gc_id == 2 then -- checks if gc is twin adder and checks if the quests are done
        gc_rank_8_mission_complete = IsQuestComplete(66665)
        gc_rank_9_mission_complete = IsQuestComplete(66668)

    elseif gc_id == 3 then -- checks if gc is immortal flames and checks if the quests are done
        gc_rank_8_mission_complete = IsQuestComplete(66666)
        gc_rank_9_mission_complete = IsQuestComplete(66669)
    end

    if can_rankup then
        if next_rank == 5 then
            local log_rank_1_complete = IsHuntLogComplete(9, 0)
            if log_rank_1_complete then
                OpenAndAttemptRankup()
            else
                Echo("You need to finish GC hunting log 1 to rank up more")
                return
            end
        elseif next_rank == 8 then
            if not gc_rank_8_mission_complete then
                Echo('You need to finish the quest "Shadows Uncast" to rank up more')
            else
                OpenAndAttemptRankup()
            end
            return
        elseif next_rank == 9 then
            local log_rank_2_complete = IsHuntLogComplete(9, 1)
            if log_rank_2_complete and gc_rank_9_mission_complete then
                OpenAndAttemptRankup()
            else
                if not log_rank_2_complete then
                    Echo("You need to finish GC hunting log 2 to rank up more")
                end
                if not gc_rank_9_mission_complete then
                    Echo('You need to finish the quest "Gilding The Bilious" to rank up more')
                end
            end
            return
        else
            OpenAndAttemptRankup()
        end
    end
    Sleep(1)
    repeat
        Sleep(0.1)
    until IsPlayerAvailable()
end

-- Usage: can_rankup, next_rank = CanGCRankUp()
--
-- returns true and the next rank if you can rank up, returns false if you can't 
function CanGCRankUp()
    local gc_rank = 0
    local gc_id = GetPlayerGC()
    local current_seals = 0
    local gc_ranks = {
        [1] = 0,
        [2] = 2000,
        [3] = 3000,
        [4] = 4000,
        [5] = 5000,
        [6] = 6000,
        [7] = 7000,
        [8] = 8000,
        [9] = 9000,
        [10] = 10000
    }
    if gc_id == 1 then -- checks if gc is maelstrom and adds seal amount to current_seals
        current_seals = GetItemCount(20)
        gc_rank = GetMaelstromGCRank()

    elseif gc_id == 2 then -- checks if gc is twin adder and adds seal amount to current_seals
        current_seals = GetItemCount(21)
        gc_rank = GetAddersGCRank()

    elseif gc_id == 3 then -- checks if gc is immortal flames and adds seal amount to current_seals
        current_seals = GetItemCount(22)
        gc_rank = GetFlamesGCRank()
    end
    local next_rank = gc_rank + 1 -- adds one so we know which gc rank we're attempting to rank up to
    Echo(gc_ranks[next_rank])
    if current_seals > gc_ranks[next_rank] and next_rank < 10 then -- excludes rank 10 and above as we don't handle that atm
        return true, next_rank
    else
        return false, next_rank
    end
end

-- Usage: OpenGcSupplyWindow(1)  
-- Supply tab is 0 // Provisioning tab is 1 // Expert Delivery is 2  
-- Anything above or below those numbers will not work 
--
-- All it does is open the gc supply window to whatever tab you want, or changes to a tab if it's already open
function OpenGcSupplyWindow(tab)
    -- swaps tabs if the gc supply list is already open
    if IsAddonVisible("GrandCompanySupplyList") then
        if (tab <= 0 or tab >= 3) then
            Echo("Invalid tab number")
        else
            yield("/pcall GrandCompanySupplyList true 0 " .. tab)
        end
    elseif not IsAddonVisible("GrandCompanySupplyList") then
        -- Mapping for GetPlayerGC()
        local gc_officer_names = {
            [1] = "Storm Personnel Officer",
            [2] = "Serpent Personnel Officer",
            [3] = "Flame Personnel Officer"
        }
        
        local gc_id = GetPlayerGC()
        local gc_target = gc_officer_names[gc_id]
        
        if gc_target then
            -- Target the correct GC officer
            Target(gc_target)
            yield("/lockon")
        else
            Echo("Unknown Grand Company ID: " .. tostring(gc_id))
            return
        end

        
        repeat
            yield("/pint")
            Sleep(0.1)
        until IsAddonReady("SelectString")
        yield("/pcall SelectString true 0")
        repeat
            Sleep(0.1)
        until IsAddonReady("GrandCompanySupplyList")
        yield("/pcall GrandCompanySupplyList true 0 " .. tab)
    end
end

-- Usage: CloseGcSupplyWindow()  
-- literally just closes the gc supply window  
-- probably is due some small consistency changes but it should be fine where it is now
function CloseGcSupplyWindow()
    attempt_counter = 0
    ::tryagain::
    if IsAddonVisible("GrandCompanySupplyList") then
        yield("/pcall GrandCompanySupplyList true -1")
        repeat
            Sleep(0.1)
        until IsAddonReady("SelectString")
        yield("/pcall SelectString true -1")
    end
    if IsAddonReady("SelectString") then
        yield("/pcall SelectString true -1")
    end
    repeat
        attempt_counter = attempt_counter + 1
        Sleep(0.1)
    until not IsAddonVisible("GrandCompanySupplyList") and not IsAddonVisible("SelectString") or attempt_counter >= 50
    if attempt_counter >= 50 then
        Echo("Window still open, trying again")
        goto tryagain
    end
end

-- Usage: GcProvisioningDeliver()
--
-- Attempts to deliver everything under the provisioning window, skipping over what it can't
function GcProvisioningDeliver()
    Sleep(0.5)
    PauseYesAlready()
    
    for i = 4, 2, -1 do
        repeat
            Sleep(0.1)
        until IsAddonReady("GrandCompanySupplyList")
        local item_name = GetNodeText("GrandCompanySupplyList", 6, i, 10)
        local item_qty = tonumber(GetNodeText("GrandCompanySupplyList", 6, i, 6))
        local item_requested_amount = tonumber(GetNodeText("GrandCompanySupplyList", 6, i, 9))
        
        if ContainsLetters(item_name) and item_qty >= item_requested_amount then
            -- continue
        else
            LogInfo("Nothing here, moving on")
            goto skip
        end
        
        local row_to_call = i - 2
        yield("/pcall GrandCompanySupplyList true 1 "..row_to_call)
        local err_counter_request = 0
        local err_counter_supply = 0
        
        repeat
            err_counter_request = err_counter_request+1
            Sleep(0.1)
        until IsAddonReady("GrandCompanySupplyReward") or err_counter_request >= 70
        
        if err_counter_request >= 70 then
            LogInfo("Something might have gone wrong")
            err_counter_request = 0
        else
            yield("/pcall GrandCompanySupplyReward true 0")
        end
        
        Sleep(0.2)
        
        -- Wait for either SelectYesno or GrandCompanySupplyList
        local wait_time = 0
        local max_wait_time = 2.0 -- Max wait time
        
        while wait_time < max_wait_time do
            if IsAddonReady("SelectYesno") then
                -- SelectYesno appeared before GrandCompanySupplyList
                local attempt_count = 0
                local max_attempts = 10
                
                repeat
                    yield("/pcall SelectYesno true 0")
                    Sleep(0.05)
                    
                    if IsAddonVisible("SelectYesno") then
                        attempt_count = attempt_count + 1
                    else
                        break
                    end
                until not IsAddonVisible("SelectYesno") or attempt_count >= max_attempts
                break
            elseif IsAddonReady("GrandCompanySupplyList") then
                -- GrandCompanySupplyList appeared first instead, SelectYesno was skipped
                break
            end
            
            Sleep(0.1)
            wait_time = wait_time + 0.1
        end
        
        repeat
            err_counter_supply = err_counter_supply+1
            Sleep(0.1)
        until IsAddonReady("GrandCompanySupplyList") or err_counter_supply >= 50
        
        err_counter_supply = 0
        ::skip::
    end
    
    RestoreYesAlready()
end

-- This is just a list holding the ids for all worlds
WorldIDList={["Cerberus"]={ID=80},["Louisoix"]={ID=83},["Moogle"]={ID=71},["Omega"]={ID=39},["Phantom"]={ID=401},["Ragnarok"]={ID=97},["Sagittarius"]={ID=400},["Spriggan"]={ID=85},["Alpha"]={ID=402},["Lich"]={ID=36},["Odin"]={ID=66},["Phoenix"]={ID=56},["Raiden"]={ID=403},["Shiva"]={ID=67},["Twintania"]={ID=33},["Zodiark"]={ID=42},["Adamantoise"]={ID=73},["Cactuar"]={ID=79},["Faerie"]={ID=54},["Gilgamesh"]={ID=63},["Jenova"]={ID=40},["Midgardsormr"]={ID=65},["Sargatanas"]={ID=99},["Siren"]={ID=57},["Balmung"]={ID=91},["Brynhildr"]={ID=34},["Coeurl"]={ID=74},["Diabolos"]={ID=62},["Goblin"]={ID=81},["Malboro"]={ID=75},["Mateus"]={ID=37},["Zalera"]={ID=41},["Cuchulainn"]={ID=408},["Golem"]={ID=411},["Halicarnassus"]={ID=406},["Kraken"]={ID=409},["Maduin"]={ID=407},["Marilith"]={ID=404},["Rafflesia"]={ID=410},["Seraph"]={ID=405},["Behemoth"]={ID=78},["Excalibur"]={ID=93},["Exodus"]={ID=53},["Famfrit"]={ID=35},["Hyperion"]={ID=95},["Lamia"]={ID=55},["Leviathan"]={ID=64},["Ultros"]={ID=77},["Bismarck"]={ID=22},["Ravana"]={ID=21},["Sephirot"]={ID=86},["Sophia"]={ID=87},["Zurvan"]={ID=88},["Aegis"]={ID=90},["Atomos"]={ID=68},["Carbuncle"]={ID=45},["Garuda"]={ID=58},["Gungnir"]={ID=94},["Kujata"]={ID=49},["Tonberry"]={ID=72},["Typhon"]={ID=50},["Alexander"]={ID=43},["Bahamut"]={ID=69},["Durandal"]={ID=92},["Fenrir"]={ID=46},["Ifrit"]={ID=59},["Ridill"]={ID=98},["Tiamat"]={ID=76},["Ultima"]={ID=51},["Anima"]={ID=44},["Asura"]={ID=23},["Chocobo"]={ID=70},["Hades"]={ID=47},["Ixion"]={ID=48},["Masamune"]={ID=96},["Pandaemonium"]={ID=28},["Titan"]={ID=61},["Belias"]={ID=24},["Mandragora"]={ID=82},["Ramuh"]={ID=60},["Shinryu"]={ID=29},["Unicorn"]={ID=30},["Valefor"]={ID=52},["Yojimbo"]={ID=31},["Zeromus"]={ID=32}}

-- Usage: FindWorldByID(11) // FindWorldByID(GetHomeWorld())
-- 
-- Looks through the WorldIDList for the world name with X id and returns the name
function FindWorldByID(searchID)
    for name, data in pairs(WorldIDList) do
      if data.ID == searchID then
        return name, data
      end
    end
    return nil, nil
end

DatacentersWithWorlds={["Chaos"]={"Cerberus","Louisoix","Moogle","Omega","Phantom","Ragnarok","Sagittarius","Spriggan"},["Light"]={"Alpha","Lich","Odin","Phoenix","Raiden","Shiva","Twintania","Zodiark"},["Aether"]={"Adamantoise","Cactuar","Faerie","Gilgamesh","Jenova","Midgardsormr","Sargatanas","Siren"},["Crystal"]={"Balmung","Brynhildr","Coeurl","Diabolos","Goblin","Malboro","Mateus","Zalera"},["Dynamis"]={"Cuchulainn","Golem","Halicarnassus","Kraken","Maduin","Marilith","Rafflesia","Seraph"},["Primal"]={"Behemoth","Excalibur","Exodus","Famfrit","Hyperion","Lamia","Leviathan","Ultros"},["Materia"]={"Bismarck","Ravana","Sephirot","Sophia","Zurvan"},["Elemental"]={"Aegis","Atomos","Carbuncle","Garuda","Gungnir","Kujata","Tonberry","Typhon"},["Gaia"]={"Alexander","Bahamut","Durandal","Fenrir","Ifrit","Ridill","Tiamat","Ultima"},["Mana"]={"Anima","Asura","Chocobo","Hades","Ixion","Masamune","Pandaemonium","Titan"},["Meteor"]={"Belias","Mandragora","Ramuh","Shinryu","Unicorn","Valefor","Yojimbo","Zeromus"}}

-- Usage: FindDCWorldIsOn("Cerbeus") Will return Chaos
-- 
-- Looks through the DatacentersWithWorlds table and returns the datacenter a world is on
function FindDCWorldIsOn(worldName)
    for datacenter, worlds in pairs(DatacentersWithWorlds) do
        for _, world in ipairs(worlds) do
            if world == worldName then
                return datacenter
            end
        end
    end
    return nil
end

-- A list of all zones and sorted by id with some extra info
ZoneList={["128"]={["Region"]="La Noscea",["Zone"]="Limsa Lominsa Upper Decks",["Mount"]=false,["Aetherytes"]={}},["129"]={["Region"]="La Noscea",["Zone"]="Limsa Lominsa Lower Decks",["Mount"]=false,["Aetherytes"]={"Limsa Lominsa Lower Decks"}},["130"]={["Region"]="Thanalan",["Zone"]="Ul'dah - Steps of Nald",["Mount"]=false,["Aetherytes"]={"Ul'dah - Steps of Nald"}},["131"]={["Region"]="Thanalan",["Zone"]="Ul'dah - Steps of Thal",["Mount"]=false,["Aetherytes"]={}},["132"]={["Region"]="The Black Shroud",["Zone"]="New Gridania",["Mount"]=false,["Aetherytes"]={"New Gridania"}},["133"]={["Region"]="The Black Shroud",["Zone"]="Old Gridania",["Mount"]=false,["Aetherytes"]={}},["134"]={["Region"]="La Noscea",["Zone"]="Middle La Noscea",["Mount"]=true,["Aetherytes"]={"Summerford Farms"}},["135"]={["Region"]="La Noscea",["Zone"]="Lower La Noscea",["Mount"]=true,["Aetherytes"]={"Moraby Drydocks"}},["136"]={["Region"]="La Noscea",["Zone"]="Mist",["Mount"]=false,["Aetherytes"]={}},["137"]={["Region"]="La Noscea",["Zone"]="Eastern La Noscea",["Mount"]=true,["Aetherytes"]={"Costa del Sol","Wineport"}},["138"]={["Region"]="La Noscea",["Zone"]="Western La Noscea",["Mount"]=true,["Aetherytes"]={"Swiftperch","Aleport"}},["139"]={["Region"]="La Noscea",["Zone"]="Upper La Noscea",["Mount"]=true,["Aetherytes"]={"Camp Bronze Lake"}},["140"]={["Region"]="Thanalan",["Zone"]="Western Thanalan",["Mount"]=true,["Aetherytes"]={"Horizon"}},["141"]={["Region"]="Thanalan",["Zone"]="Central Thanalan",["Mount"]=true,["Aetherytes"]={"Black Brush Station"}},["142"]={["Region"]="Thanalan",["Zone"]="Halatali",["Mount"]=false,["Aetherytes"]={}},["144"]={["Region"]="Thanalan",["Zone"]="The Gold Saucer",["Mount"]=false,["Aetherytes"]={"The Gold Saucer"}},["145"]={["Region"]="Thanalan",["Zone"]="Eastern Thanalan",["Mount"]=true,["Aetherytes"]={"Camp Drybone"}},["146"]={["Region"]="Thanalan",["Zone"]="Southern Thanalan",["Mount"]=true,["Aetherytes"]={"Little Ala Mhigo","Forgotten Springs"}},["147"]={["Region"]="Thanalan",["Zone"]="Northern Thanalan",["Mount"]=true,["Aetherytes"]={"Camp Bluefog","Ceruleum Processing Plant"}},["148"]={["Region"]="The Black Shroud",["Zone"]="Central Shroud",["Mount"]=true,["Aetherytes"]={"Bentbranch Meadows"}},["149"]={["Region"]="La Noscea",["Zone"]="The Feasting Grounds",["Mount"]=false,["Aetherytes"]={}},["151"]={["Region"]="Mor Dhona",["Zone"]="The World of Darkness",["Mount"]=false,["Aetherytes"]={}},["152"]={["Region"]="The Black Shroud",["Zone"]="East Shroud",["Mount"]=true,["Aetherytes"]={"The Hawthorne Hut"}},["153"]={["Region"]="The Black Shroud",["Zone"]="South Shroud",["Mount"]=true,["Aetherytes"]={"Quarrymill","Camp Tranquil"}},["154"]={["Region"]="The Black Shroud",["Zone"]="North Shroud",["Mount"]=true,["Aetherytes"]={"Fallgourd Float"}},["155"]={["Region"]="Coerthas",["Zone"]="Coerthas Central Highlands",["Mount"]=true,["Aetherytes"]={"Camp Dragonhead"}},["156"]={["Region"]="Mor Dhona",["Zone"]="Mor Dhona",["Mount"]=true,["Aetherytes"]={"Revenant's Toll"}},["159"]={["Region"]="La Noscea",["Zone"]="The Wanderer's Palace",["Mount"]=false,["Aetherytes"]={}},["160"]={["Region"]="La Noscea",["Zone"]="Pharos Sirius",["Mount"]=false,["Aetherytes"]={}},["163"]={["Region"]="Thanalan",["Zone"]="The Sunken Temple of Qarn",["Mount"]=false,["Aetherytes"]={}},["167"]={["Region"]="The Black Shroud",["Zone"]="Amdapor Keep",["Mount"]=false,["Aetherytes"]={}},["170"]={["Region"]="Thanalan",["Zone"]="Cutter's Cry",["Mount"]=false,["Aetherytes"]={}},["171"]={["Region"]="Coerthas",["Zone"]="Dzemael Darkhold",["Mount"]=false,["Aetherytes"]={}},["172"]={["Region"]="Coerthas",["Zone"]="Aurum Vale",["Mount"]=false,["Aetherytes"]={}},["174"]={["Region"]="Mor Dhona",["Zone"]="Labyrinth of the Ancients",["Mount"]=false,["Aetherytes"]={}},["176"]={["Region"]="",["Zone"]="Mordion Gaol",["Mount"]=false,["Aetherytes"]={}},["177"]={["Region"]="La Noscea",["Zone"]="Mizzenmast Inn",["Mount"]=false,["Aetherytes"]={}},["178"]={["Region"]="Thanalan",["Zone"]="The Hourglass",["Mount"]=false,["Aetherytes"]={}},["179"]={["Region"]="The Black Shroud",["Zone"]="The Roost",["Mount"]=false,["Aetherytes"]={}},["180"]={["Region"]="La Noscea",["Zone"]="Outer La Noscea",["Mount"]=true,["Aetherytes"]={"Camp Overlook"}},["181"]={["Region"]="La Noscea",["Zone"]="Limsa Lominsa",["Mount"]=false,["Aetherytes"]={}},["193"]={["Region"]="Thanalan",["Zone"]="IC-06 Central Decks",["Mount"]=false,["Aetherytes"]={}},["194"]={["Region"]="Thanalan",["Zone"]="IC-06 Regeneration Grid",["Mount"]=false,["Aetherytes"]={}},["195"]={["Region"]="Thanalan",["Zone"]="IC-06 Main Bridge",["Mount"]=false,["Aetherytes"]={}},["196"]={["Region"]="Thanalan",["Zone"]="The Burning Heart",["Mount"]=false,["Aetherytes"]={}},["198"]={["Region"]="La Noscea",["Zone"]="Command Room",["Mount"]=false,["Aetherytes"]={}},["204"]={["Region"]="The Black Shroud",["Zone"]="Seat of the First Bow",["Mount"]=false,["Aetherytes"]={}},["205"]={["Region"]="The Black Shroud",["Zone"]="Lotus Stand",["Mount"]=false,["Aetherytes"]={}},["210"]={["Region"]="Thanalan",["Zone"]="Heart of the Sworn",["Mount"]=false,["Aetherytes"]={}},["212"]={["Region"]="Thanalan",["Zone"]="The Waking Sands",["Mount"]=false,["Aetherytes"]={}},["241"]={["Region"]="La Noscea",["Zone"]="Upper Aetheroacoustic Exploratory Site",["Mount"]=false,["Aetherytes"]={}},["242"]={["Region"]="La Noscea",["Zone"]="Lower Aetheroacoustic Exploratory Site",["Mount"]=false,["Aetherytes"]={}},["243"]={["Region"]="La Noscea",["Zone"]="The Ragnarok",["Mount"]=false,["Aetherytes"]={}},["244"]={["Region"]="La Noscea",["Zone"]="Ragnarok Drive Cylinder",["Mount"]=false,["Aetherytes"]={}},["245"]={["Region"]="La Noscea",["Zone"]="Ragnarok Central Core",["Mount"]=false,["Aetherytes"]={}},["246"]={["Region"]="Thanalan",["Zone"]="IC-04 Main Bridge",["Mount"]=false,["Aetherytes"]={}},["247"]={["Region"]="La Noscea",["Zone"]="Ragnarok Main Bridge",["Mount"]=false,["Aetherytes"]={}},["250"]={["Region"]="La Noscea",["Zone"]="Wolves' Den Pier",["Mount"]=false,["Aetherytes"]={"Wolves' Den Pier"}},["276"]={["Region"]="",["Zone"]="Hall of Summoning",["Mount"]=false,["Aetherytes"]={}},["281"]={["Region"]="La Noscea",["Zone"]="The Whorleater",["Mount"]=false,["Aetherytes"]={}},["282"]={["Region"]="La Noscea",["Zone"]="Private Cottage - Mist",["Mount"]=false,["Aetherytes"]={}},["283"]={["Region"]="La Noscea",["Zone"]="Private House - Mist",["Mount"]=false,["Aetherytes"]={}},["284"]={["Region"]="La Noscea",["Zone"]="Private Mansion - Mist",["Mount"]=false,["Aetherytes"]={}},["286"]={["Region"]="La Noscea",["Zone"]="Rhotano Sea",["Mount"]=false,["Aetherytes"]={}},["292"]={["Region"]="Thanalan",["Zone"]="Bowl of Embers",["Mount"]=false,["Aetherytes"]={}},["293"]={["Region"]="La Noscea",["Zone"]="The Navel",["Mount"]=false,["Aetherytes"]={}},["294"]={["Region"]="Coerthas",["Zone"]="The Howling Eye",["Mount"]=false,["Aetherytes"]={}},["338"]={["Region"]="Thanalan",["Zone"]="Eorzean Subterrane",["Mount"]=false,["Aetherytes"]={}},["340"]={["Region"]="The Black Shroud",["Zone"]="The Lavender Beds",["Mount"]=true,["Aetherytes"]={"Estate Hall (Free Company)","Estate Hall (Private)"}},["341"]={["Region"]="Thanalan",["Zone"]="The Goblet",["Mount"]=true,["Aetherytes"]={"Estate Hall (Free Company)","Estate Hall (Private)"}},["342"]={["Region"]="The Black Shroud",["Zone"]="Private Cottage - The Lavender Beds",["Mount"]=false,["Aetherytes"]={}},["343"]={["Region"]="The Black Shroud",["Zone"]="Private House - The Lavender Beds",["Mount"]=false,["Aetherytes"]={}},["344"]={["Region"]="The Black Shroud",["Zone"]="Private Mansion - The Lavender Beds",["Mount"]=false,["Aetherytes"]={}},["345"]={["Region"]="Thanalan",["Zone"]="Private Cottage - The Goblet",["Mount"]=false,["Aetherytes"]={}},["346"]={["Region"]="Thanalan",["Zone"]="Private House - The Goblet",["Mount"]=false,["Aetherytes"]={}},["347"]={["Region"]="Thanalan",["Zone"]="Private Mansion - The Goblet",["Mount"]=false,["Aetherytes"]={}},["348"]={["Region"]="Thanalan",["Zone"]="Porta Decumana",["Mount"]=false,["Aetherytes"]={}},["349"]={["Region"]="Thanalan",["Zone"]="Copperbell Mines",["Mount"]=false,["Aetherytes"]={}},["350"]={["Region"]="The Black Shroud",["Zone"]="Haukke Manor",["Mount"]=false,["Aetherytes"]={}},["351"]={["Region"]="Mor Dhona",["Zone"]="The Rising Stones",["Mount"]=false,["Aetherytes"]={}},["353"]={["Region"]="Othard",["Zone"]="Kugane Ohashi",["Mount"]=false,["Aetherytes"]={}},["354"]={["Region"]="Norvrandt",["Zone"]="The Dancing Plague",["Mount"]=false,["Aetherytes"]={}},["355"]={["Region"]="The Black Shroud",["Zone"]="Dalamud's Shadow",["Mount"]=false,["Aetherytes"]={}},["356"]={["Region"]="The Black Shroud",["Zone"]="The Outer Coil",["Mount"]=false,["Aetherytes"]={}},["357"]={["Region"]="The Black Shroud",["Zone"]="Central Decks",["Mount"]=false,["Aetherytes"]={}},["358"]={["Region"]="The Black Shroud",["Zone"]="The Holocharts",["Mount"]=false,["Aetherytes"]={}},["361"]={["Region"]="La Noscea",["Zone"]="Hullbreaker Isle",["Mount"]=false,["Aetherytes"]={}},["362"]={["Region"]="La Noscea",["Zone"]="Brayflox's Longstop",["Mount"]=false,["Aetherytes"]={}},["363"]={["Region"]="The Black Shroud",["Zone"]="The Lost City of Amdapor",["Mount"]=false,["Aetherytes"]={}},["364"]={["Region"]="The Black Shroud",["Zone"]="Thornmarch",["Mount"]=false,["Aetherytes"]={}},["365"]={["Region"]="Coerthas",["Zone"]="Stone Vigil",["Mount"]=false,["Aetherytes"]={}},["366"]={["Region"]="Coerthas",["Zone"]="Griffin Crossing",["Mount"]=false,["Aetherytes"]={}},["368"]={["Region"]="Coerthas",["Zone"]="The Weeping Saint",["Mount"]=false,["Aetherytes"]={}},["369"]={["Region"]="Thanalan",["Zone"]="Hall of the Bestiarii",["Mount"]=false,["Aetherytes"]={}},["370"]={["Region"]="The Black Shroud",["Zone"]="Main Bridge",["Mount"]=false,["Aetherytes"]={}},["372"]={["Region"]="Mor Dhona",["Zone"]="Syrcus Tower",["Mount"]=false,["Aetherytes"]={}},["373"]={["Region"]="The Black Shroud",["Zone"]="The Tam-Tara Deepcroft",["Mount"]=false,["Aetherytes"]={}},["374"]={["Region"]="The Black Shroud",["Zone"]="The Striking Tree",["Mount"]=false,["Aetherytes"]={}},["376"]={["Region"]="Mor Dhona",["Zone"]="Carteneau Flats: Borderland Ruins",["Mount"]=true,["Aetherytes"]={}},["377"]={["Region"]="Coerthas",["Zone"]="Akh Afah Amphitheatre",["Mount"]=false,["Aetherytes"]={}},["384"]={["Region"]="La Noscea",["Zone"]="Private Chambers - Mist",["Mount"]=false,["Aetherytes"]={}},["385"]={["Region"]="The Black Shroud",["Zone"]="Private Chambers - The Lavender Beds",["Mount"]=false,["Aetherytes"]={}},["386"]={["Region"]="Thanalan",["Zone"]="Private Chambers - The Goblet",["Mount"]=false,["Aetherytes"]={}},["387"]={["Region"]="La Noscea",["Zone"]="Sastasha",["Mount"]=false,["Aetherytes"]={}},["388"]={["Region"]="Thanalan",["Zone"]="Chocobo Square",["Mount"]=false,["Aetherytes"]={}},["392"]={["Region"]="The Black Shroud",["Zone"]="Sanctum of the Twelve",["Mount"]=false,["Aetherytes"]={}},["395"]={["Region"]="Coerthas",["Zone"]="Intercessory",["Mount"]=false,["Aetherytes"]={}},["397"]={["Region"]="Coerthas",["Zone"]="Coerthas Western Highlands",["Mount"]=true,["Aetherytes"]={"Falcon's Nest"}},["398"]={["Region"]="Dravania",["Zone"]="The Dravanian Forelands",["Mount"]=true,["Aetherytes"]={"Tailfeather","Anyx Trine"}},["399"]={["Region"]="Dravania",["Zone"]="The Dravanian Hinterlands",["Mount"]=true,["Aetherytes"]={}},["400"]={["Region"]="Dravania",["Zone"]="The Churning Mists",["Mount"]=true,["Aetherytes"]={"Moghome","Zenith"}},["401"]={["Region"]="Abalathia's Spine",["Zone"]="The Sea of Clouds",["Mount"]=true,["Aetherytes"]={"Camp Cloudtop","Ok' Zundu"}},["402"]={["Region"]="Abalathia's Spine",["Zone"]="Azys Lla",["Mount"]=true,["Aetherytes"]={"Helix"}},["403"]={["Region"]="Gyr Abania",["Zone"]="Ala Mhigo",["Mount"]=false,["Aetherytes"]={}},["418"]={["Region"]="Coerthas",["Zone"]="Foundation",["Mount"]=false,["Aetherytes"]={"Foundation"}},["419"]={["Region"]="Coerthas",["Zone"]="The Pillars",["Mount"]=false,["Aetherytes"]={}},["420"]={["Region"]="Abalathia's Spine",["Zone"]="Neverreap",["Mount"]=false,["Aetherytes"]={}},["423"]={["Region"]="La Noscea",["Zone"]="Company Workshop - Mist",["Mount"]=false,["Aetherytes"]={}},["424"]={["Region"]="Thanalan",["Zone"]="Company Workshop - The Goblet",["Mount"]=false,["Aetherytes"]={}},["425"]={["Region"]="The Black Shroud",["Zone"]="Company Workshop - The Lavender Beds",["Mount"]=false,["Aetherytes"]={}},["426"]={["Region"]="Mor Dhona",["Zone"]="The Chrysalis",["Mount"]=false,["Aetherytes"]={}},["427"]={["Region"]="Coerthas",["Zone"]="Saint Endalim's Scholasticate",["Mount"]=false,["Aetherytes"]={}},["428"]={["Region"]="Coerthas",["Zone"]="Seat of the Lord Commander",["Mount"]=false,["Aetherytes"]={}},["429"]={["Region"]="Coerthas",["Zone"]="Cloud Nine",["Mount"]=false,["Aetherytes"]={}},["430"]={["Region"]="Abalathia's Spine",["Zone"]="The Fractal Continuum",["Mount"]=false,["Aetherytes"]={}},["431"]={["Region"]="La Noscea",["Zone"]="Seal Rock",["Mount"]=true,["Aetherytes"]={}},["432"]={["Region"]="Dravania",["Zone"]="Thok ast Thok",["Mount"]=false,["Aetherytes"]={}},["433"]={["Region"]="Coerthas",["Zone"]="Fortemps Manor",["Mount"]=false,["Aetherytes"]={}},["434"]={["Region"]="Coerthas",["Zone"]="Dusk Vigil",["Mount"]=false,["Aetherytes"]={}},["436"]={["Region"]="Abalathia's Spine",["Zone"]="The Limitless Blue",["Mount"]=false,["Aetherytes"]={}},["437"]={["Region"]="Abalathia's Spine",["Zone"]="Singularity Reactor",["Mount"]=false,["Aetherytes"]={}},["439"]={["Region"]="Coerthas",["Zone"]="The Lightfeather Proving Grounds",["Mount"]=false,["Aetherytes"]={}},["440"]={["Region"]="Coerthas",["Zone"]="Ruling Chamber",["Mount"]=false,["Aetherytes"]={}},["442"]={["Region"]="Dravania",["Zone"]="The Fist of the Father",["Mount"]=false,["Aetherytes"]={}},["443"]={["Region"]="Dravania",["Zone"]="The Cuff of the Father",["Mount"]=false,["Aetherytes"]={}},["444"]={["Region"]="Dravania",["Zone"]="The Arm of the Father",["Mount"]=false,["Aetherytes"]={}},["445"]={["Region"]="Dravania",["Zone"]="The Burden of the Father",["Mount"]=false,["Aetherytes"]={}},["462"]={["Region"]="Dravania",["Zone"]="Sacrificial Chamber",["Mount"]=false,["Aetherytes"]={}},["463"]={["Region"]="Dravania",["Zone"]="Matoya's Cave",["Mount"]=false,["Aetherytes"]={}},["478"]={["Region"]="Dravania",["Zone"]="Idyllshire",["Mount"]=true,["Aetherytes"]={"Idyllshire"}},["504"]={["Region"]="Thanalan",["Zone"]="The Eighteenth Floor",["Mount"]=false,["Aetherytes"]={}},["505"]={["Region"]="Dravania",["Zone"]="Alexander",["Mount"]=false,["Aetherytes"]={}},["507"]={["Region"]="Abalathia's Spine",["Zone"]="Central Azys Lla",["Mount"]=false,["Aetherytes"]={}},["508"]={["Region"]="Abalathia's Spine",["Zone"]="Void Ark",["Mount"]=false,["Aetherytes"]={}},["509"]={["Region"]="Ilsabard",["Zone"]="The Gilded Araya",["Mount"]=false,["Aetherytes"]={}},["511"]={["Region"]="Dravania",["Zone"]="Saint Mocianne's Arboretum",["Mount"]=false,["Aetherytes"]={}},["512"]={["Region"]="Abalathia's Spine",["Zone"]="The Diadem",["Mount"]=true,["Aetherytes"]={}},["513"]={["Region"]="Coerthas",["Zone"]="The Vault",["Mount"]=false,["Aetherytes"]={}},["517"]={["Region"]="Abalathia's Spine",["Zone"]="Containment Bay S1T7",["Mount"]=false,["Aetherytes"]={}},["520"]={["Region"]="Dravania",["Zone"]="The Fist of the Son",["Mount"]=false,["Aetherytes"]={}},["521"]={["Region"]="Dravania",["Zone"]="The Cuff of the Son",["Mount"]=false,["Aetherytes"]={}},["522"]={["Region"]="Dravania",["Zone"]="The Arm of the Son",["Mount"]=false,["Aetherytes"]={}},["523"]={["Region"]="Dravania",["Zone"]="The Burden of the Son",["Mount"]=false,["Aetherytes"]={}},["534"]={["Region"]="The Black Shroud",["Zone"]="Twin Adder Barracks",["Mount"]=false,["Aetherytes"]={}},["535"]={["Region"]="Thanalan",["Zone"]="Flame Barracks",["Mount"]=false,["Aetherytes"]={}},["536"]={["Region"]="La Noscea",["Zone"]="Maelstrom Barracks",["Mount"]=false,["Aetherytes"]={}},["537"]={["Region"]="La Noscea",["Zone"]="The Fold",["Mount"]=false,["Aetherytes"]={}},["554"]={["Region"]="Coerthas",["Zone"]="The Fields of Glory",["Mount"]=true,["Aetherytes"]={}},["556"]={["Region"]="Mor Dhona",["Zone"]="The Weeping City of Mhach",["Mount"]=false,["Aetherytes"]={}},["558"]={["Region"]="Coerthas",["Zone"]="The Aquapolis",["Mount"]=false,["Aetherytes"]={}},["559"]={["Region"]="Coerthas",["Zone"]="Steps of Faith",["Mount"]=false,["Aetherytes"]={}},["560"]={["Region"]="Abalathia's Spine",["Zone"]="Aetherochemical Research Facility",["Mount"]=false,["Aetherytes"]={}},["561"]={["Region"]="The Black Shroud",["Zone"]="The Palace of the Dead",["Mount"]=false,["Aetherytes"]={}},["567"]={["Region"]="Abalathia's Spine",["Zone"]="The Parrock",["Mount"]=false,["Aetherytes"]={}},["568"]={["Region"]="Abalathia's Spine",["Zone"]="Leofard's Chambers",["Mount"]=false,["Aetherytes"]={}},["571"]={["Region"]="The Black Shroud",["Zone"]="Haunted Manor",["Mount"]=false,["Aetherytes"]={}},["573"]={["Region"]="La Noscea",["Zone"]="Topmast Apartment Lobby",["Mount"]=false,["Aetherytes"]={}},["574"]={["Region"]="The Black Shroud",["Zone"]="Lily Hills Apartment Lobby",["Mount"]=false,["Aetherytes"]={}},["575"]={["Region"]="Thanalan",["Zone"]="Sultana's Breath Apartment Lobby",["Mount"]=false,["Aetherytes"]={}},["576"]={["Region"]="Abalathia's Spine",["Zone"]="Containment Bay P1T6",["Mount"]=false,["Aetherytes"]={}},["578"]={["Region"]="Dravania",["Zone"]="The Great Gubal Library",["Mount"]=false,["Aetherytes"]={}},["579"]={["Region"]="Thanalan",["Zone"]="The Battlehall",["Mount"]=false,["Aetherytes"]={}},["580"]={["Region"]="Dravania",["Zone"]="Eyes of the Creator",["Mount"]=false,["Aetherytes"]={}},["581"]={["Region"]="Dravania",["Zone"]="Breath of the Creator",["Mount"]=false,["Aetherytes"]={}},["582"]={["Region"]="Dravania",["Zone"]="Heart of the Creator",["Mount"]=false,["Aetherytes"]={}},["583"]={["Region"]="Dravania",["Zone"]="Soul of the Creator",["Mount"]=false,["Aetherytes"]={}},["608"]={["Region"]="La Noscea",["Zone"]="Topmast Apartment",["Mount"]=false,["Aetherytes"]={}},["609"]={["Region"]="The Black Shroud",["Zone"]="Lily Hills Apartment",["Mount"]=false,["Aetherytes"]={}},["610"]={["Region"]="Thanalan",["Zone"]="Sultana's Breath Apartment",["Mount"]=false,["Aetherytes"]={}},["611"]={["Region"]="Thanalan",["Zone"]="Frondale's Home for Friendless Foundlings",["Mount"]=false,["Aetherytes"]={}},["612"]={["Region"]="Gyr Abania",["Zone"]="The Fringes",["Mount"]=true,["Aetherytes"]={"Castrum Oriens","The Peering Stones"}},["613"]={["Region"]="Othard",["Zone"]="The Ruby Sea",["Mount"]=true,["Aetherytes"]={"Tamamizu","Onokoro"}},["614"]={["Region"]="Othard",["Zone"]="Yanxia",["Mount"]=true,["Aetherytes"]={"Namai","The House of the Fierce"}},["616"]={["Region"]="Othard",["Zone"]="Shisui of the Violet Tides",["Mount"]=false,["Aetherytes"]={}},["617"]={["Region"]="Dravania",["Zone"]="Sohm Al",["Mount"]=false,["Aetherytes"]={}},["620"]={["Region"]="Gyr Abania",["Zone"]="The Peaks",["Mount"]=true,["Aetherytes"]={"Ala Gannha","Ala Ghiri"}},["621"]={["Region"]="Gyr Abania",["Zone"]="The Lochs",["Mount"]=true,["Aetherytes"]={"Porta Praetoria","The Ala Mhigan Quarter"}},["622"]={["Region"]="Othard",["Zone"]="The Azim Steppe",["Mount"]=true,["Aetherytes"]={"Reunion","The Dawn Throne","Dhoro Iloh"}},["623"]={["Region"]="Othard",["Zone"]="Bardam's Mettle",["Mount"]=false,["Aetherytes"]={}},["626"]={["Region"]="La Noscea",["Zone"]="The Sirensong Sea",["Mount"]=false,["Aetherytes"]={}},["627"]={["Region"]="Abalathia's Spine",["Zone"]="Dun Scaith",["Mount"]=false,["Aetherytes"]={}},["628"]={["Region"]="Hingashi",["Zone"]="Kugane",["Mount"]=false,["Aetherytes"]={"Kugane"}},["629"]={["Region"]="Hingashi",["Zone"]="Bokairo Inn",["Mount"]=false,["Aetherytes"]={}},["635"]={["Region"]="Gyr Abania",["Zone"]="Rhalgr's Reach",["Mount"]=true,["Aetherytes"]={"Rhalgr's Reach"}},["636"]={["Region"]="Mor Dhona",["Zone"]="Omega Control",["Mount"]=false,["Aetherytes"]={}},["637"]={["Region"]="Abalathia's Spine",["Zone"]="Containment Bay Z1T9",["Mount"]=false,["Aetherytes"]={}},["639"]={["Region"]="Hingashi",["Zone"]="Ruby Bazaar Offices",["Mount"]=false,["Aetherytes"]={}},["641"]={["Region"]="Hingashi",["Zone"]="Shirogane",["Mount"]=true,["Aetherytes"]={"Estate Hall (Free Company)","Estate Hall (Private)"}},["649"]={["Region"]="Hingashi",["Zone"]="Private Cottage - Shirogane",["Mount"]=false,["Aetherytes"]={}},["650"]={["Region"]="Hingashi",["Zone"]="Private House - Shirogane",["Mount"]=false,["Aetherytes"]={}},["651"]={["Region"]="Hingashi",["Zone"]="Private Mansion - Shirogane",["Mount"]=false,["Aetherytes"]={}},["652"]={["Region"]="Hingashi",["Zone"]="Private Chambers - Shirogane",["Mount"]=false,["Aetherytes"]={}},["653"]={["Region"]="Hingashi",["Zone"]="Company Workshop - Shirogane",["Mount"]=false,["Aetherytes"]={}},["654"]={["Region"]="Hingashi",["Zone"]="Kobai Goten Apartment Lobby",["Mount"]=false,["Aetherytes"]={}},["655"]={["Region"]="Hingashi",["Zone"]="Kobai Goten Apartment",["Mount"]=false,["Aetherytes"]={}},["658"]={["Region"]="Gyr Abania",["Zone"]="The Interdimensional Rift",["Mount"]=false,["Aetherytes"]={}},["660"]={["Region"]="Othard",["Zone"]="Doma Castle",["Mount"]=false,["Aetherytes"]={}},["661"]={["Region"]="Gyr Abania",["Zone"]="Castrum Abania",["Mount"]=false,["Aetherytes"]={}},["662"]={["Region"]="Hingashi",["Zone"]="Kugane Castle",["Mount"]=false,["Aetherytes"]={}},["663"]={["Region"]="Gyr Abania",["Zone"]="The Temple of the Fist",["Mount"]=false,["Aetherytes"]={}},["674"]={["Region"]="Othard",["Zone"]="The Blessed Treasury",["Mount"]=false,["Aetherytes"]={}},["679"]={["Region"]="Gyr Abania",["Zone"]="The Royal Airship Landing",["Mount"]=false,["Aetherytes"]={}},["680"]={["Region"]="La Noscea",["Zone"]="The <Emphasis>Misery</Emphasis>",["Mount"]=false,["Aetherytes"]={}},["681"]={["Region"]="Othard",["Zone"]="The House of the Fierce",["Mount"]=false,["Aetherytes"]={}},["682"]={["Region"]="Othard",["Zone"]="The Doman Enclave",["Mount"]=false,["Aetherytes"]={}},["683"]={["Region"]="Gyr Abania",["Zone"]="The First Altar of Djanan Qhat",["Mount"]=false,["Aetherytes"]={}},["691"]={["Region"]="Gyr Abania",["Zone"]="Deltascape V1.0",["Mount"]=false,["Aetherytes"]={}},["692"]={["Region"]="Gyr Abania",["Zone"]="Deltascape V2.0",["Mount"]=false,["Aetherytes"]={}},["693"]={["Region"]="Gyr Abania",["Zone"]="Deltascape V3.0",["Mount"]=false,["Aetherytes"]={}},["694"]={["Region"]="Gyr Abania",["Zone"]="Deltascape V4.0",["Mount"]=false,["Aetherytes"]={}},["712"]={["Region"]="???",["Zone"]="The Lost Canals of Uznair",["Mount"]=false,["Aetherytes"]={}},["719"]={["Region"]="Gyr Abania",["Zone"]="Emanation",["Mount"]=false,["Aetherytes"]={}},["727"]={["Region"]="Gyr Abania",["Zone"]="The Royal Menagerie",["Mount"]=false,["Aetherytes"]={}},["729"]={["Region"]="Dravania",["Zone"]="Astragalos",["Mount"]=true,["Aetherytes"]={}},["730"]={["Region"]="Gyr Abania",["Zone"]="Transparency",["Mount"]=false,["Aetherytes"]={}},["731"]={["Region"]="Gyr Abania",["Zone"]="The Drowned City of Skalla",["Mount"]=false,["Aetherytes"]={}},["732"]={["Region"]="???",["Zone"]="Eureka Anemos",["Mount"]=true,["Aetherytes"]={}},["733"]={["Region"]="???",["Zone"]="The Binding Coil of Bahamut",["Mount"]=false,["Aetherytes"]={}},["734"]={["Region"]="???",["Zone"]="The Royal City of Rabanastre",["Mount"]=false,["Aetherytes"]={}},["735"]={["Region"]="???",["Zone"]="The <Emphasis>Prima Vista</Emphasis> Tiring Room",["Mount"]=false,["Aetherytes"]={}},["736"]={["Region"]="???",["Zone"]="The <Emphasis>Prima Vista</Emphasis> Bridge",["Mount"]=false,["Aetherytes"]={}},["737"]={["Region"]="Gyr Abania",["Zone"]="Royal Palace",["Mount"]=false,["Aetherytes"]={}},["738"]={["Region"]="Gyr Abania",["Zone"]="The Resonatorium",["Mount"]=false,["Aetherytes"]={}},["742"]={["Region"]="Othard",["Zone"]="Hells' Lid",["Mount"]=false,["Aetherytes"]={}},["744"]={["Region"]="Othard",["Zone"]="Kienkan",["Mount"]=false,["Aetherytes"]={}},["746"]={["Region"]="Othard",["Zone"]="The Jade Stoa",["Mount"]=false,["Aetherytes"]={}},["748"]={["Region"]="Gyr Abania",["Zone"]="Sigmascape V1.0",["Mount"]=false,["Aetherytes"]={}},["749"]={["Region"]="Gyr Abania",["Zone"]="Sigmascape V2.0",["Mount"]=false,["Aetherytes"]={}},["750"]={["Region"]="Gyr Abania",["Zone"]="Sigmascape V3.0",["Mount"]=false,["Aetherytes"]={}},["751"]={["Region"]="Gyr Abania",["Zone"]="Sigmascape V4.0",["Mount"]=false,["Aetherytes"]={}},["761"]={["Region"]="Othard",["Zone"]="The Great Hunt",["Mount"]=false,["Aetherytes"]={}},["763"]={["Region"]="???",["Zone"]="Eureka Pagos",["Mount"]=true,["Aetherytes"]={}},["764"]={["Region"]="Othard",["Zone"]="Reisen Temple",["Mount"]=false,["Aetherytes"]={}},["768"]={["Region"]="Othard",["Zone"]="The Swallow's Compass",["Mount"]=false,["Aetherytes"]={}},["769"]={["Region"]="Othard",["Zone"]="The Burn",["Mount"]=false,["Aetherytes"]={}},["770"]={["Region"]="Othard",["Zone"]="Heaven-on-High",["Mount"]=false,["Aetherytes"]={}},["776"]={["Region"]="???",["Zone"]="The Ridorana Lighthouse",["Mount"]=false,["Aetherytes"]={}},["777"]={["Region"]="???",["Zone"]="Ultimacy",["Mount"]=false,["Aetherytes"]={}},["778"]={["Region"]="Othard",["Zone"]="Castrum Fluminis",["Mount"]=false,["Aetherytes"]={}},["781"]={["Region"]="Othard",["Zone"]="Reisen Temple Road",["Mount"]=false,["Aetherytes"]={}},["787"]={["Region"]="???",["Zone"]="The Ridorana Cataract",["Mount"]=false,["Aetherytes"]={}},["791"]={["Region"]="Thanalan",["Zone"]="Hidden Gorge",["Mount"]=true,["Aetherytes"]={}},["792"]={["Region"]="Thanalan",["Zone"]="The Fall of Belah'dia",["Mount"]=false,["Aetherytes"]={}},["793"]={["Region"]="Gyr Abania",["Zone"]="The Ghimlyt Dark",["Mount"]=false,["Aetherytes"]={}},["794"]={["Region"]="???",["Zone"]="The Shifting Altars of Uznair",["Mount"]=false,["Aetherytes"]={}},["795"]={["Region"]="???",["Zone"]="Eureka Pyros",["Mount"]=true,["Aetherytes"]={}},["796"]={["Region"]="Thanalan",["Zone"]="Blue Sky",["Mount"]=false,["Aetherytes"]={}},["798"]={["Region"]="Gyr Abania",["Zone"]="Psiscape V1.0",["Mount"]=false,["Aetherytes"]={}},["799"]={["Region"]="Gyr Abania",["Zone"]="Psiscape V2.0",["Mount"]=false,["Aetherytes"]={}},["810"]={["Region"]="Othard",["Zone"]="Hells' Kier",["Mount"]=false,["Aetherytes"]={}},["813"]={["Region"]="Norvrandt",["Zone"]="Lakeland",["Mount"]=true,["Aetherytes"]={"Fort Jobb","The Ostall Imperative"}},["814"]={["Region"]="Norvrandt",["Zone"]="Kholusia",["Mount"]=true,["Aetherytes"]={"Stilltide","Wright","Tomra"}},["815"]={["Region"]="Norvrandt",["Zone"]="Amh Araeng",["Mount"]=true,["Aetherytes"]={"Mord Souq","Twine","The Inn at Journey's Head"}},["816"]={["Region"]="Norvrandt",["Zone"]="Il Mheg",["Mount"]=true,["Aetherytes"]={"Lydha Lran","Pla Enni","Wolekdorf"}},["817"]={["Region"]="Norvrandt",["Zone"]="The Rak'tika Greatwood",["Mount"]=true,["Aetherytes"]={"Slitherbough","Fanow"}},["818"]={["Region"]="Norvrandt",["Zone"]="The Tempest",["Mount"]=true,["Aetherytes"]={"The Ondo Cups","The Macarenses Angle"}},["819"]={["Region"]="Norvrandt",["Zone"]="The Crystarium",["Mount"]=false,["Aetherytes"]={"The Crystarium"}},["820"]={["Region"]="Norvrandt",["Zone"]="Eulmore",["Mount"]=false,["Aetherytes"]={"Eulmore"}},["821"]={["Region"]="Norvrandt",["Zone"]="Dohn Mheg",["Mount"]=false,["Aetherytes"]={}},["822"]={["Region"]="Norvrandt",["Zone"]="Mt. Gulg",["Mount"]=false,["Aetherytes"]={}},["823"]={["Region"]="Norvrandt",["Zone"]="The Qitana Ravel",["Mount"]=false,["Aetherytes"]={}},["824"]={["Region"]="Othard",["Zone"]="The Wreath of Snakes",["Mount"]=false,["Aetherytes"]={}},["826"]={["Region"]="???",["Zone"]="The Orbonne Monastery",["Mount"]=false,["Aetherytes"]={}},["827"]={["Region"]="???",["Zone"]="Eureka Hydatos",["Mount"]=true,["Aetherytes"]={}},["829"]={["Region"]="Gyr Abania",["Zone"]="Eorzean Alliance Headquarters",["Mount"]=false,["Aetherytes"]={}},["831"]={["Region"]="Thanalan",["Zone"]="The Manderville Tables",["Mount"]=false,["Aetherytes"]={}},["836"]={["Region"]="Norvrandt",["Zone"]="Malikah's Well",["Mount"]=false,["Aetherytes"]={}},["837"]={["Region"]="Norvrandt",["Zone"]="Holminster Switch",["Mount"]=false,["Aetherytes"]={}},["838"]={["Region"]="Norvrandt",["Zone"]="Amaurot",["Mount"]=false,["Aetherytes"]={}},["840"]={["Region"]="Norvrandt",["Zone"]="The Twinning",["Mount"]=false,["Aetherytes"]={}},["841"]={["Region"]="Norvrandt",["Zone"]="Akadaemia Anyder",["Mount"]=false,["Aetherytes"]={}},["842"]={["Region"]="Mor Dhona",["Zone"]="The Syrcus Trench",["Mount"]=false,["Aetherytes"]={}},["843"]={["Region"]="Norvrandt",["Zone"]="The Pendants Personal Suite",["Mount"]=false,["Aetherytes"]={}},["844"]={["Region"]="Norvrandt",["Zone"]="The Ocular",["Mount"]=false,["Aetherytes"]={}},["846"]={["Region"]="Norvrandt",["Zone"]="The Crown of the Immaculate",["Mount"]=false,["Aetherytes"]={}},["847"]={["Region"]="Norvrandt",["Zone"]="The Dying Gasp",["Mount"]=false,["Aetherytes"]={}},["849"]={["Region"]="Norvrandt",["Zone"]="The Core",["Mount"]=false,["Aetherytes"]={}},["850"]={["Region"]="Norvrandt",["Zone"]="The Halo",["Mount"]=false,["Aetherytes"]={}},["851"]={["Region"]="Norvrandt",["Zone"]="The Nereus Trench",["Mount"]=false,["Aetherytes"]={}},["852"]={["Region"]="Norvrandt",["Zone"]="Atlas Peak",["Mount"]=false,["Aetherytes"]={}},["859"]={["Region"]="Norvrandt",["Zone"]="The Confessional of Toupasa the Elder",["Mount"]=false,["Aetherytes"]={}},["876"]={["Region"]="Norvrandt",["Zone"]="The Nabaath Mines",["Mount"]=false,["Aetherytes"]={}},["878"]={["Region"]="Norvrandt",["Zone"]="The Empty",["Mount"]=false,["Aetherytes"]={}},["879"]={["Region"]="Norvrandt",["Zone"]="The Dungeons of Lyhe Ghiah",["Mount"]=false,["Aetherytes"]={}},["882"]={["Region"]="Norvrandt",["Zone"]="The Copied Factory",["Mount"]=false,["Aetherytes"]={}},["884"]={["Region"]="Norvrandt",["Zone"]="The Grand Cosmos",["Mount"]=false,["Aetherytes"]={}},["886"]={["Region"]="Coerthas",["Zone"]="The Firmament",["Mount"]=false,["Aetherytes"]={}},["887"]={["Region"]="Dravania",["Zone"]="Liminal Space",["Mount"]=false,["Aetherytes"]={}},["888"]={["Region"]="Othard",["Zone"]="Onsal Hakair",["Mount"]=true,["Aetherytes"]={}},["889"]={["Region"]="Norvrandt",["Zone"]="Lyhe Mheg",["Mount"]=false,["Aetherytes"]={}},["893"]={["Region"]="???",["Zone"]="The Imperial Palace",["Mount"]=false,["Aetherytes"]={}},["895"]={["Region"]="Norvrandt",["Zone"]="Excavation Tunnels",["Mount"]=false,["Aetherytes"]={}},["897"]={["Region"]="Gyr Abania",["Zone"]="Cinder Drift",["Mount"]=false,["Aetherytes"]={}},["898"]={["Region"]="Norvrandt",["Zone"]="Anamnesis Anyder",["Mount"]=false,["Aetherytes"]={}},["899"]={["Region"]="La Noscea",["Zone"]="The Falling City of Nym",["Mount"]=false,["Aetherytes"]={}},["900"]={["Region"]="The High Seas",["Zone"]="The <Emphasis>Endeavor</Emphasis>",["Mount"]=false,["Aetherytes"]={}},["902"]={["Region"]="Norvrandt",["Zone"]="The Gandof Thunder Plains",["Mount"]=false,["Aetherytes"]={}},["903"]={["Region"]="Norvrandt",["Zone"]="Ashfall",["Mount"]=false,["Aetherytes"]={}},["905"]={["Region"]="Norvrandt",["Zone"]="Great Glacier",["Mount"]=false,["Aetherytes"]={}},["911"]={["Region"]="???",["Zone"]="Cid's Memory",["Mount"]=false,["Aetherytes"]={}},["913"]={["Region"]="???",["Zone"]="Transmission Control",["Mount"]=false,["Aetherytes"]={}},["914"]={["Region"]="Norvrandt",["Zone"]="Trial's Threshold",["Mount"]=false,["Aetherytes"]={}},["915"]={["Region"]="???",["Zone"]="Gangos",["Mount"]=false,["Aetherytes"]={}},["916"]={["Region"]="Norvrandt",["Zone"]="The Heroes' Gauntlet",["Mount"]=false,["Aetherytes"]={}},["917"]={["Region"]="Norvrandt",["Zone"]="The Puppets' Bunker",["Mount"]=false,["Aetherytes"]={}},["919"]={["Region"]="???",["Zone"]="Terncliff",["Mount"]=false,["Aetherytes"]={}},["920"]={["Region"]="???",["Zone"]="Bozjan Southern Front",["Mount"]=true,["Aetherytes"]={}},["922"]={["Region"]="Norvrandt",["Zone"]="The Seat of Sacrifice",["Mount"]=false,["Aetherytes"]={}},["924"]={["Region"]="Norvrandt",["Zone"]="The Shifting Oubliettes of Lyhe Ghiah",["Mount"]=false,["Aetherytes"]={}},["925"]={["Region"]="???",["Zone"]="Terncliff Bay",["Mount"]=false,["Aetherytes"]={}},["933"]={["Region"]="Dravania",["Zone"]="Matoya's Relict",["Mount"]=false,["Aetherytes"]={}},["934"]={["Region"]="Thanalan",["Zone"]="Castrum Marinum Drydocks",["Mount"]=false,["Aetherytes"]={}},["936"]={["Region"]="???",["Zone"]="Delubrum Reginae",["Mount"]=false,["Aetherytes"]={}},["938"]={["Region"]="Thanalan",["Zone"]="Paglth'an",["Mount"]=false,["Aetherytes"]={}},["942"]={["Region"]="Norvrandt",["Zone"]="Sphere of Naught",["Mount"]=false,["Aetherytes"]={}},["943"]={["Region"]="Norvrandt",["Zone"]="Laxan Loft",["Mount"]=false,["Aetherytes"]={}},["944"]={["Region"]="Norvrandt",["Zone"]="Bygone Gaol",["Mount"]=false,["Aetherytes"]={}},["945"]={["Region"]="Norvrandt",["Zone"]="The Garden of Nowhere",["Mount"]=false,["Aetherytes"]={}},["950"]={["Region"]="???",["Zone"]="G-Savior Deck",["Mount"]=false,["Aetherytes"]={}},["952"]={["Region"]="Ilsabard",["Zone"]="The Tower of Zot",["Mount"]=false,["Aetherytes"]={}},["955"]={["Region"]="???",["Zone"]="The Last Trace",["Mount"]=false,["Aetherytes"]={}},["956"]={["Region"]="The Northern Empty",["Zone"]="Labyrinthos",["Mount"]=true,["Aetherytes"]={"The Archeion","Sharlayan Hamlet","Aporia"}},["957"]={["Region"]="Ilsabard",["Zone"]="Thavnair",["Mount"]=true,["Aetherytes"]={"Yedlihmad","The Great Work","Palaka's Stand"}},["958"]={["Region"]="Ilsabard",["Zone"]="Garlemald",["Mount"]=true,["Aetherytes"]={"Camp Broken Glass","Tertium"}},["959"]={["Region"]="The Sea of Stars",["Zone"]="Mare Lamentorum",["Mount"]=true,["Aetherytes"]={"Sinus Lacrimarum","Bestways Burrow"}},["960"]={["Region"]="The Sea of Stars",["Zone"]="Ultima Thule",["Mount"]=true,["Aetherytes"]={"Reah Tahra","Abode of the Ea","Base Omicron"}},["961"]={["Region"]="The World Unsundered",["Zone"]="Elpis",["Mount"]=true,["Aetherytes"]={"Anagnorisis","The Twelve Wonders","Poieten Oikos"}},["962"]={["Region"]="The Northern Empty",["Zone"]="Old Sharlayan",["Mount"]=false,["Aetherytes"]={"Old Sharlayan"}},["963"]={["Region"]="Ilsabard",["Zone"]="Radz-at-Han",["Mount"]=false,["Aetherytes"]={"Radz-at-Han"}},["966"]={["Region"]="Norvrandt",["Zone"]="The Tower at Paradigm's Breach",["Mount"]=false,["Aetherytes"]={}},["968"]={["Region"]="Coerthas",["Zone"]="Medias Res",["Mount"]=false,["Aetherytes"]={}},["969"]={["Region"]="Ilsabard",["Zone"]="The Tower of Babil",["Mount"]=false,["Aetherytes"]={}},["970"]={["Region"]="Ilsabard",["Zone"]="Vanaspati",["Mount"]=false,["Aetherytes"]={}},["971"]={["Region"]="Thanalan",["Zone"]="Lemures Headquarters",["Mount"]=false,["Aetherytes"]={}},["973"]={["Region"]="The Sea of Stars",["Zone"]="The Dead Ends",["Mount"]=false,["Aetherytes"]={}},["974"]={["Region"]="The World Unsundered",["Zone"]="Ktisis Hyperboreia",["Mount"]=false,["Aetherytes"]={}},["975"]={["Region"]="???",["Zone"]="Zadnor",["Mount"]=true,["Aetherytes"]={}},["976"]={["Region"]="The Sea of Stars",["Zone"]="Smileton",["Mount"]=false,["Aetherytes"]={}},["978"]={["Region"]="The Northern Empty",["Zone"]="The Aitiascope",["Mount"]=false,["Aetherytes"]={}},["979"]={["Region"]="Coerthas",["Zone"]="Empyreum",["Mount"]=true,["Aetherytes"]={"Estate Hall (Free Company)","Estate Hall (Private)"}},["980"]={["Region"]="Coerthas",["Zone"]="Private Cottage - Empyreum",["Mount"]=false,["Aetherytes"]={}},["981"]={["Region"]="Coerthas",["Zone"]="Private House - Empyreum",["Mount"]=false,["Aetherytes"]={}},["982"]={["Region"]="Coerthas",["Zone"]="Private Mansion - Empyreum",["Mount"]=false,["Aetherytes"]={}},["983"]={["Region"]="Coerthas",["Zone"]="Private Chambers - Empyreum",["Mount"]=false,["Aetherytes"]={}},["984"]={["Region"]="Coerthas",["Zone"]="Company Workshop - Empyreum",["Mount"]=false,["Aetherytes"]={}},["985"]={["Region"]="Coerthas",["Zone"]="Ingleside Apartment Lobby",["Mount"]=false,["Aetherytes"]={}},["986"]={["Region"]="The Sea of Stars",["Zone"]="The Stigma Dreamscape",["Mount"]=false,["Aetherytes"]={}},["987"]={["Region"]="The Northern Empty",["Zone"]="Main Hall",["Mount"]=false,["Aetherytes"]={}},["990"]={["Region"]="The Northern Empty",["Zone"]="Andron",["Mount"]=false,["Aetherytes"]={}},["992"]={["Region"]="The Sea of Stars",["Zone"]="The Dark Inside",["Mount"]=false,["Aetherytes"]={}},["994"]={["Region"]="The Black Shroud",["Zone"]="The Phantoms' Feast",["Mount"]=false,["Aetherytes"]={}},["995"]={["Region"]="The Northern Empty",["Zone"]="The Mothercrystal",["Mount"]=false,["Aetherytes"]={}},["997"]={["Region"]="The Sea of Stars",["Zone"]="The Final Day",["Mount"]=false,["Aetherytes"]={}},["999"]={["Region"]="Coerthas",["Zone"]="Ingleside Apartment",["Mount"]=false,["Aetherytes"]={}},["1000"]={["Region"]="The Sea of Stars",["Zone"]="The Excitatron 6000",["Mount"]=false,["Aetherytes"]={}},["1001"]={["Region"]="Coerthas",["Zone"]="Strategy Room",["Mount"]=false,["Aetherytes"]={}},["1002"]={["Region"]="The World Unsundered",["Zone"]="The Gates of Pandæmonium",["Mount"]=false,["Aetherytes"]={}},["1004"]={["Region"]="The World Unsundered",["Zone"]="The Stagnant Limbo",["Mount"]=false,["Aetherytes"]={}},["1006"]={["Region"]="The World Unsundered",["Zone"]="The Fervid Limbo",["Mount"]=false,["Aetherytes"]={}},["1008"]={["Region"]="The World Unsundered",["Zone"]="The Sanguine Limbo",["Mount"]=false,["Aetherytes"]={}},["1010"]={["Region"]="Ilsabard",["Zone"]="Magna Glacies",["Mount"]=false,["Aetherytes"]={}},["1013"]={["Region"]="The Sea of Stars",["Zone"]="Beyond the Stars",["Mount"]=false,["Aetherytes"]={}},["1024"]={["Region"]="Ilsabard",["Zone"]="The Nethergate",["Mount"]=false,["Aetherytes"]={}},["1031"]={["Region"]="The World Unsundered",["Zone"]="Propylaion",["Mount"]=false,["Aetherytes"]={}},["1032"]={["Region"]="???",["Zone"]="The Palaistra",["Mount"]=false,["Aetherytes"]={}},["1033"]={["Region"]="???",["Zone"]="The Volcanic Heart",["Mount"]=false,["Aetherytes"]={}},["1039"]={["Region"]="The Black Shroud",["Zone"]="The Thousand Maws of Toto-Rak",["Mount"]=false,["Aetherytes"]={}},["1043"]={["Region"]="Thanalan",["Zone"]="Castrum Meridianum",["Mount"]=false,["Aetherytes"]={}},["1044"]={["Region"]="Thanalan",["Zone"]="The Praetorium",["Mount"]=false,["Aetherytes"]={}},["1050"]={["Region"]="Ilsabard",["Zone"]="Alzadaal's Legacy",["Mount"]=false,["Aetherytes"]={}},["1052"]={["Region"]="Thanalan",["Zone"]="The Porta Decumana",["Mount"]=false,["Aetherytes"]={}},["1054"]={["Region"]="???",["Zone"]="Aglaia",["Mount"]=false,["Aetherytes"]={}},["1055"]={["Region"]="???",["Zone"]="Unnamed Island",["Mount"]=true,["Aetherytes"]={}},["1057"]={["Region"]="The Northern Empty",["Zone"]="Restricted Archives",["Mount"]=false,["Aetherytes"]={}},["1061"]={["Region"]="???",["Zone"]="The Omphalos",["Mount"]=false,["Aetherytes"]={}},["1062"]={["Region"]="Coerthas",["Zone"]="Snowcloak",["Mount"]=false,["Aetherytes"]={}},["1063"]={["Region"]="Mor Dhona",["Zone"]="The Keeper of the Lake",["Mount"]=false,["Aetherytes"]={}},["1065"]={["Region"]="Dravania",["Zone"]="The Aery",["Mount"]=false,["Aetherytes"]={}},["1069"]={["Region"]="Thanalan",["Zone"]="The Sil'dihn Subterrane",["Mount"]=false,["Aetherytes"]={}},["1070"]={["Region"]="???",["Zone"]="The Fell Court of Troia",["Mount"]=false,["Aetherytes"]={}},["1071"]={["Region"]="???",["Zone"]="Storm's Crown",["Mount"]=false,["Aetherytes"]={}},["1073"]={["Region"]="The Sea of Stars",["Zone"]="Elysion",["Mount"]=false,["Aetherytes"]={}},["1075"]={["Region"]="Thanalan",["Zone"]="Another Sil'dihn Subterrane",["Mount"]=false,["Aetherytes"]={}},["1077"]={["Region"]="???",["Zone"]="Zero's Domain",["Mount"]=true,["Aetherytes"]={}},["1078"]={["Region"]="Ilsabard",["Zone"]="Meghaduta Guest Chambers",["Mount"]=false,["Aetherytes"]={}},["1081"]={["Region"]="The World Unsundered",["Zone"]="The Caustic Purgatory",["Mount"]=false,["Aetherytes"]={}},["1083"]={["Region"]="The World Unsundered",["Zone"]="The Pestilent Purgatory",["Mount"]=false,["Aetherytes"]={}},["1085"]={["Region"]="The World Unsundered",["Zone"]="The Hollow Purgatory",["Mount"]=false,["Aetherytes"]={}},["1087"]={["Region"]="The World Unsundered",["Zone"]="Stygian Insenescence Cells",["Mount"]=false,["Aetherytes"]={}},["1094"]={["Region"]="The Black Shroud",["Zone"]="Sneaky Hollow",["Mount"]=false,["Aetherytes"]={}},["1095"]={["Region"]="Ilsabard",["Zone"]="Mount Ordeals",["Mount"]=false,["Aetherytes"]={}},["1097"]={["Region"]="Ilsabard",["Zone"]="Lapis Manalis",["Mount"]=false,["Aetherytes"]={}},["1098"]={["Region"]="The Black Shroud",["Zone"]="Sylphstep",["Mount"]=false,["Aetherytes"]={}},["1099"]={["Region"]="Mor Dhona",["Zone"]="Eureka Orthos",["Mount"]=false,["Aetherytes"]={}},["1111"]={["Region"]="Dravania",["Zone"]="The Antitower",["Mount"]=false,["Aetherytes"]={}},["1112"]={["Region"]="Dravania",["Zone"]="Sohr Khai",["Mount"]=false,["Aetherytes"]={}},["1113"]={["Region"]="Coerthas",["Zone"]="Xelphatol",["Mount"]=false,["Aetherytes"]={}},["1114"]={["Region"]="The Black Shroud",["Zone"]="Baelsar's Wall",["Mount"]=false,["Aetherytes"]={}},["1116"]={["Region"]="???",["Zone"]="The Clockwork Castletown",["Mount"]=false,["Aetherytes"]={}},["1118"]={["Region"]="???",["Zone"]="Euphrosyne",["Mount"]=false,["Aetherytes"]={}},["1123"]={["Region"]="The World Unsundered",["Zone"]="The Shifting Gymnasion Agonon",["Mount"]=false,["Aetherytes"]={}},["1125"]={["Region"]="Ilsabard",["Zone"]="Khadga",["Mount"]=false,["Aetherytes"]={}},["1126"]={["Region"]="The Northern Empty",["Zone"]="The Aetherfont",["Mount"]=false,["Aetherytes"]={}},["1137"]={["Region"]="Hingashi",["Zone"]="Mount Rokkon",["Mount"]=false,["Aetherytes"]={}},["1138"]={["Region"]="???",["Zone"]="The Red Sands",["Mount"]=false,["Aetherytes"]={}},["1140"]={["Region"]="???",["Zone"]="The Voidcast Dais",["Mount"]=false,["Aetherytes"]={}},["1147"]={["Region"]="The Northern Empty",["Zone"]="The Aetherial Slough",["Mount"]=false,["Aetherytes"]={}},["1149"]={["Region"]="The Northern Empty",["Zone"]="The Dæmons' Nest",["Mount"]=false,["Aetherytes"]={}},["1151"]={["Region"]="The Northern Empty",["Zone"]="The Chamber of Fourteen",["Mount"]=false,["Aetherytes"]={}},["1153"]={["Region"]="The Northern Empty",["Zone"]="Ascension",["Mount"]=false,["Aetherytes"]={}},["1155"]={["Region"]="Hingashi",["Zone"]="Another Mount Rokkon",["Mount"]=false,["Aetherytes"]={}},["1160"]={["Region"]="Ilsabard",["Zone"]="Senatus",["Mount"]=false,["Aetherytes"]={}},["1161"]={["Region"]="Ilsabard",["Zone"]="Estinien's Chambers",["Mount"]=false,["Aetherytes"]={}},["1162"]={["Region"]="???",["Zone"]="The Red Moon",["Mount"]=false,["Aetherytes"]={}},["1164"]={["Region"]="???",["Zone"]="The Lunar Subterrane",["Mount"]=false,["Aetherytes"]={}},["1165"]={["Region"]="Thanalan",["Zone"]="Blunderville",["Mount"]=false,["Aetherytes"]={}},["1166"]={["Region"]="???",["Zone"]="The Memory of Embers",["Mount"]=false,["Aetherytes"]={}},["1167"]={["Region"]="Yok Tural",["Zone"]="Ihuykatumu",["Mount"]=false,["Aetherytes"]={}},["1168"]={["Region"]="???",["Zone"]="The Abyssal Fracture",["Mount"]=false,["Aetherytes"]={}},["1170"]={["Region"]="Yok Tural",["Zone"]="Sunperch",["Mount"]=false,["Aetherytes"]={}},["1171"]={["Region"]="Xak Tural",["Zone"]="Earthen Sky Hideout",["Mount"]=false,["Aetherytes"]={}},["1176"]={["Region"]="???",["Zone"]="Aloalo Island",["Mount"]=false,["Aetherytes"]={}},["1178"]={["Region"]="???",["Zone"]="Thaleia",["Mount"]=false,["Aetherytes"]={}},["1179"]={["Region"]="???",["Zone"]="Another Aloalo Island",["Mount"]=false,["Aetherytes"]={}},["1185"]={["Region"]="Yok Tural",["Zone"]="Tuliyollal",["Mount"]=false,["Aetherytes"]={"Tuliyollal"}},["1186"]={["Region"]="Xak Tural",["Zone"]="Solution Nine",["Mount"]=false,["Aetherytes"]={"Solution Nine"}},["1187"]={["Region"]="Yok Tural",["Zone"]="Urqopacha",["Mount"]=true,["Aetherytes"]={"Wachunpelo","Worlar's Echo"}},["1188"]={["Region"]="Yok Tural",["Zone"]="Kozama'uka",["Mount"]=true,["Aetherytes"]={"Ok'hanu","Many Fires","Earthenshire"}},["1189"]={["Region"]="Yok Tural",["Zone"]="Yak T'el",["Mount"]=true,["Aetherytes"]={"Iq Br'aax","Mamook"}},["1190"]={["Region"]="Xak Tural",["Zone"]="Shaaloani",["Mount"]=true,["Aetherytes"]={"Hhusatahwi","Sheshenewezi Springs","Mehwahhetsoan"}},["1191"]={["Region"]="Xak Tural",["Zone"]="Heritage Found",["Mount"]=true,["Aetherytes"]={"Yyasulani Station","The Outskirts","Electrope Strike"}},["1192"]={["Region"]="Unlost World",["Zone"]="Living Memory",["Mount"]=true,["Aetherytes"]={"Leynode Mnemo","Leynode Pyro","Leynode Aero"}},["1193"]={["Region"]="Yok Tural",["Zone"]="Worqor Zormor",["Mount"]=false,["Aetherytes"]={}},["1194"]={["Region"]="Yok Tural",["Zone"]="The Skydeep Cenote",["Mount"]=false,["Aetherytes"]={}},["1195"]={["Region"]="Yok Tural",["Zone"]="Worqor Lar Dor",["Mount"]=false,["Aetherytes"]={}},["1197"]={["Region"]="Thanalan",["Zone"]="Blunderville Square",["Mount"]=false,["Aetherytes"]={}},["1198"]={["Region"]="Xak Tural",["Zone"]="Vanguard",["Mount"]=false,["Aetherytes"]={}},["1199"]={["Region"]="Unlost World",["Zone"]="Alexandria",["Mount"]=false,["Aetherytes"]={}},["1200"]={["Region"]="Xak Tural",["Zone"]="Summit of Everkeep",["Mount"]=false,["Aetherytes"]={}},["1202"]={["Region"]="Unlost World",["Zone"]="Interphos",["Mount"]=false,["Aetherytes"]={}},["1203"]={["Region"]="Xak Tural",["Zone"]="Tender Valley",["Mount"]=false,["Aetherytes"]={}},["1204"]={["Region"]="Unlost World",["Zone"]="Strayborough",["Mount"]=false,["Aetherytes"]={}},["1205"]={["Region"]="Yok Tural",["Zone"]="The For'ard Cabins",["Mount"]=false,["Aetherytes"]={}},["1206"]={["Region"]="The Northern Empty",["Zone"]="Main Deck",["Mount"]=false,["Aetherytes"]={}},["1207"]={["Region"]="Xak Tural",["Zone"]="The Backroom",["Mount"]=false,["Aetherytes"]={}},["1208"]={["Region"]="Xak Tural",["Zone"]="Origenics",["Mount"]=false,["Aetherytes"]={}},["1209"]={["Region"]="Yok Tural",["Zone"]="Cenote Ja Ja Gural",["Mount"]=false,["Aetherytes"]={}},["1222"]={["Region"]="Yok Tural",["Zone"]="Skydeep Cenote Inner Chamber",["Mount"]=false,["Aetherytes"]={}},["1223"]={["Region"]="Xak Tural",["Zone"]="Tritails Training",["Mount"]=false,["Aetherytes"]={}},["1224"]={["Region"]="Xak Tural",["Zone"]="Greenroom",["Mount"]=false,["Aetherytes"]={}},["1225"]={["Region"]="Xak Tural",["Zone"]="Scratching Ring",["Mount"]=false,["Aetherytes"]={}},["1227"]={["Region"]="Xak Tural",["Zone"]="Lovely Lovering",["Mount"]=false,["Aetherytes"]={}},["1229"]={["Region"]="Xak Tural",["Zone"]="Blasting Ring",["Mount"]=false,["Aetherytes"]={}},["1231"]={["Region"]="Xak Tural",["Zone"]="The Thundering",["Mount"]=false,["Aetherytes"]={}},["1233"]={["Region"]="The Black Shroud",["Zone"]="Manor Basement",["Mount"]=false,["Aetherytes"]={}},["1234"]={["Region"]="???",["Zone"]="Dreamlike Palace",["Mount"]=false,["Aetherytes"]={}}}
-- Usage: FindZoneID("Limsa Lominsa Lower Decks")
--
-- returns the id of the zone you search for, if the search is vague enough it'll return any of the ones that it finds, so try to be specific
function FindZoneID(zone)
    zone = zone or ZoneList["" .. GetZoneID() .. ""]["Zone"]
    
    -- Check if zone is string
    if type(zone) ~= "string" then
        return nil -- return 0
    end
    
    local searchLower = zone:lower()
    
    for id, entry in pairs(ZoneList) do
        local placeName = entry["Zone"]
        if placeName and placeName:lower():find(searchLower) then
            return tonumber(id)
        end
    end
    
    return nil -- return 0
end

-- Usage: FindZoneIDByAetheryte("Limsa Lominsa Lower Decks")
--
-- returns the id of the zone of the aetheryte you search for, if the search is vague enough it'll return any of the ones that it finds, so try to be specific
function FindZoneIDByAetheryte(targetAetheryte)
    local lowerTarget = targetAetheryte:lower()
    for key, value in pairs(ZoneList) do
        for _, aetheryte in ipairs(value["Aetherytes"]) do
            if aetheryte:lower():find(lowerTarget, 1, true) then
                return key, aetheryte
            end
        end
    end
    return 0, "Not found"
end


-- Usage: ContainsLetters("meow")  
-- 
-- Will return if whatever you provide it has letters or not
function ContainsLetters(input)
    if input:match("%a") then
        return true
    else
        return false
    end
end

-- Usage: Distance(-96.71, 18.60, 0.50, -88.33, 18.60, -10.48) or anything that gives you an x y z pos value
-- Used to calculate the distance between two sets of x y z coordinates
-- Euclidean Distance
function Distance(x1, y1, z1, x2, y2, z2)
    local dx = x2 - x1
    local dy = y2 - y1
    local dz = z2 - z1
    return math.sqrt(dx^2 + dy^2 + dz^2)
end

-- Usage: DistanceName("First Last", "First Last") or DistanceName("Aetheryte", "Retainer Bell")
-- Used to calculate the distance between two object names
-- Euclidean Distance
function DistanceName(distance_char_name1, distance_char_name2)
    local x1 = GetObjectRawXPos(distance_char_name1)
    local y1 = GetObjectRawYPos(distance_char_name1)
    local z1 = GetObjectRawZPos(distance_char_name1)
    
    local x2 = GetObjectRawXPos(distance_char_name2)
    local y2 = GetObjectRawYPos(distance_char_name2)
    local z2 = GetObjectRawZPos(distance_char_name2)
    
    local dx = x2 - x1
    local dy = y2 - y1
    local dz = z2 - z1
    return math.sqrt(dx^2 + dy^2 + dz^2)
end

-- Usage: PathToObject("First Last") or PathToObject("Aetheryte", 2)
-- Finds specified object and paths to it
-- Optionally can include a range value to stop once distance between character and target has been reached
function PathToObject(path_object_name, range)
    if range == nil then
        Movement(GetObjectRawXPos(path_object_name), GetObjectRawYPos(path_object_name), GetObjectRawZPos(path_object_name))
    else
        Movement(GetObjectRawXPos(path_object_name), GetObjectRawYPos(path_object_name), GetObjectRawZPos(path_object_name), range)
    end
    
    repeat
        Sleep(0.1)
    until not PathIsRunning()
end

-- Finds where your estate entrance is and paths to it
-- I think this will break though since there will be multiple entrances around a housing area
-- So maybe needs nearest logic
function PathToEstateEntrance()
    Movement(GetObjectRawXPos("Entrance"), GetObjectRawYPos("Entrance"), GetObjectRawZPos("Entrance"), 4)
end

-- Paths to Limsa bell
function PathToLimsaBell()
    if ZoneCheck("Limsa Lominsa Lower Decks") then
        --Movement(-123.72, 18.00, 20.55)
        Movement(GetObjectRawXPos("Summoning Bell"), GetObjectRawYPos("Summoning Bell"), GetObjectRawZPos("Summoning Bell"))
    else
        Teleporter("Limsa Lominsa", "tp")
        --Movement(-123.72, 18.00, 20.55)
        Movement(GetObjectRawXPos("Summoning Bell"), GetObjectRawYPos("Summoning Bell"), GetObjectRawZPos("Summoning Bell"))
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
            Echo(gil_increase_amount .. " Gil successfully traded")
            break -- Exit the loop when the gil increase is detected
        end
        
        previous_gil = current_gil -- Update gil amount for the next check
    end
end

-- Usage: PartyInvite("First Last")
-- Will target and invite player to a party, and retrying if the invite timeout happens
-- Can only be used if target is in range
function PartyInvite(party_invite_name)
    local invite_timeout = 305 -- 300 Seconds is the invite timeout, adding 5 seconds for good measure
    local start_time = os.time() -- Stores the invite time
    
    while not IsInParty() do
        repeat
            Sleep(0.1)
        until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
        
        Target(party_invite_name)
        yield("/invite")
        
        -- Wait for the target player to accept the invite or the timeout to expire
        while not IsInParty() do
            Sleep(0.1)
            
            -- Check if the invite has expired
            if os.time() - start_time >= invite_timeout then
                Echo("Invite expired. Reinviting " .. party_invite_name)
                start_time = os.time() -- Reset the start time for the new invite
                break -- Break the loop to resend the invite
            end
        end
    end
    -- stuff could go here
end

-- Usage: PartyInviteMenu("First", "First Last")
-- Will invite player to a party through the social menu, and retrying if the invite timeout happens
-- Can be used from anywhere
-- Semi broken at the moment
function PartyInviteMenu(party_invite_menu_first, party_invite_menu_full)
    local invite_timeout = 305 -- 300 Seconds is the invite timeout, adding 5 seconds for good measure
    local start_time = os.time() -- Stores the invite time
    
    while not IsInParty() do
        repeat
            Sleep(0.1)
        until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
        
        repeat
            yield('/search first "' .. party_invite_menu_first .. '" en jp de fr')
            Sleep(0.5)
        until IsAddonVisible("SocialList")
        
        -- Probably needs the node scanner here to match the name, otherwise it will invite whoever was previously searched, will probably mess up for multiple matches too
        
        repeat
            yield('/pcall SocialList true 1 0 "' .. party_invite_menu_full .. '"')
            Sleep(0.5)
        until IsAddonVisible("ContextMenu")
        
        repeat
            yield("/pcall ContextMenu true 0 3 0")
            Sleep(0.1)
        until not IsAddonVisible("ContextMenu")
        
        repeat
            yield("/pcall Social true -1")
            Sleep(0.1)
        until not IsAddonVisible("Social")
        
        -- Wait for the target player to accept the invite or the timeout to expire
        while not IsInParty() do
            Sleep(0.1)
            
            -- Check if the invite has expired
            if os.time() - start_time >= invite_timeout then
                Echo("Invite expired. Reinviting " .. party_invite_menu_full)
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
            yield("/pcall SelectYesno true 0")
            Sleep(0.1)
        until not IsAddonVisible("SelectYesno")
    end
end

-- Usage: PartyAccept()
-- Will accept party invite if not in party
-- NEEDS a name arg
function PartyAccept()
    if not IsInParty() then
        repeat
            Sleep(0.1)
        until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
        
        repeat
            yield("/pcall SelectYesno true 0")
            Sleep(0.1)
        until not IsAddonVisible("SelectYesno")
    end
end

-- Usage: PartyLeave()
-- Will leave party if in a party
function PartyLeave()
    if IsInParty() then
        repeat
            Sleep(0.1)
        until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
        yield("/partycmd leave")
        repeat
            Sleep(0.1)
        until IsAddonVisible("SelectYesno")
        repeat
            yield("/pcall SelectYesno true 0")
            Sleep(0.1)
        until not IsAddonVisible("SelectYesno")
    end
end
-- Usage: EstateTeleport("First Last", 0)
-- Options: 0 = Free Company, 1 = Personal, 2 = Apartment
-- Opens estate list of added friend and teleports to specified location
-- ZoneTransitions() not required to be called after
function EstateTeleport(estate_char_name, estate_type)
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
    
    yield("/estatelist " .. estate_char_name)
    
    repeat
        yield("/pcall TeleportHousingFriend true " .. estate_type)
        Sleep(0.1)
    until not IsAddonVisible("TeleportHousingFriend")
    
    ZoneTransitions()
end

-- Usage: RelogCharacter("First Last@Server")
-- Relogs specified character, should be followed with a LoginCheck()
-- Requires @Server else it will not work
-- Requires Auto Retainer plugin
function RelogCharacter(relog_char_name)
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
    
    yield("/ays relog " .. relog_char_name)
end

-- Usage: EquipRecommendedGear()
-- Equips recommended gear if any available
function EquipRecommendedGear()
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
    
    repeat
        yield("/character")
        Sleep(0.1)
    until IsAddonVisible("Character")
    
    repeat
        yield("/pcall Character true 12")
        Sleep(0.1)
    until IsAddonVisible("RecommendEquip")
    
    repeat
        yield("/character")
        Sleep(0.1)
    until not IsAddonVisible("Character")
    
    repeat
        yield("/pcall RecommendEquip true 0")
        Sleep(0.1)
    until not IsAddonVisible("RecommendEquip")
end

-- Usage: WaitUntilObjectExists("First Last") or WaitUntilObjectExists("Aetheryte")
-- Checks if specified object exists near to your character
function WaitUntilObjectExists(object_name)
    repeat
        Sleep(0.1)
    until DoesObjectExist(object_name)
end

-- Usage: GetRandomNumber(1.5, 3.5) or GetRandomNumber(2, 4)
-- Allows for variance in values such as differing Sleep() wait times
function GetRandomNumber(min, max)
    -- Reseed the random number
    math.randomseed(os.time() + os.clock() * 100000)
    
    -- Generate and return a random number from the min and max values
    return min + (max - min) * math.random()
end

-- Usage: GetPlayerPos()
-- Finds and returns player x, y, z pos
function GetPlayerPos()
    -- Find and format player pos
    local x, y, z = GetPlayerRawXPos(), GetPlayerRawYPos(), GetPlayerRawZPos()
    local pos = string.format("%.2f, %.2f, %.2f", x, y, z)
    
    return pos
end

-- Joblist for use in various functions
Joblist={[0]={["Name"]="Adventurer",["Abbreviation"]="ADV",["Category"]="Disciple of War",["ExpArrayIndex"]=-1},[1]={["Name"]="Gladiator",["Abbreviation"]="GLA",["Category"]="Disciple of War",["ExpArrayIndex"]=1},[2]={["Name"]="Pugilist",["Abbreviation"]="PGL",["Category"]="Disciple of War",["ExpArrayIndex"]=0},[3]={["Name"]="Marauder",["Abbreviation"]="MRD",["Category"]="Disciple of War",["ExpArrayIndex"]=2},[4]={["Name"]="Lancer",["Abbreviation"]="LNC",["Category"]="Disciple of War",["ExpArrayIndex"]=4},[5]={["Name"]="Archer",["Abbreviation"]="ARC",["Category"]="Disciple of War",["ExpArrayIndex"]=3},[6]={["Name"]="Conjurer",["Abbreviation"]="CNJ",["Category"]="Disciple of Magic",["ExpArrayIndex"]=6},[7]={["Name"]="Thaumaturge",["Abbreviation"]="THM",["Category"]="Disciple of Magic",["ExpArrayIndex"]=5},[8]={["Name"]="Carpenter",["Abbreviation"]="CRP",["Category"]="Disciple of the Hand",["ExpArrayIndex"]=7},[9]={["Name"]="Blacksmith",["Abbreviation"]="BSM",["Category"]="Disciple of the Hand",["ExpArrayIndex"]=8},[10]={["Name"]="Armorer",["Abbreviation"]="ARM",["Category"]="Disciple of the Hand",["ExpArrayIndex"]=9},[11]={["Name"]="Goldsmith",["Abbreviation"]="GSM",["Category"]="Disciple of the Hand",["ExpArrayIndex"]=10},[12]={["Name"]="Leatherworker",["Abbreviation"]="LTW",["Category"]="Disciple of the Hand",["ExpArrayIndex"]=11},[13]={["Name"]="Weaver",["Abbreviation"]="WVR",["Category"]="Disciple of the Hand",["ExpArrayIndex"]=12},[14]={["Name"]="Alchemist",["Abbreviation"]="ALC",["Category"]="Disciple of the Hand",["ExpArrayIndex"]=13},[15]={["Name"]="Culinarian",["Abbreviation"]="CUL",["Category"]="Disciple of the Hand",["ExpArrayIndex"]=14},[16]={["Name"]="Miner",["Abbreviation"]="MIN",["Category"]="Disciple of the Land",["ExpArrayIndex"]=15},[17]={["Name"]="Botanist",["Abbreviation"]="BTN",["Category"]="Disciple of the Land",["ExpArrayIndex"]=16},[18]={["Name"]="Fisher",["Abbreviation"]="FSH",["Category"]="Disciple of the Land",["ExpArrayIndex"]=17},[19]={["Name"]="Paladin",["Abbreviation"]="PLD",["Category"]="Disciple of War",["ExpArrayIndex"]=1},[20]={["Name"]="Monk",["Abbreviation"]="MNK",["Category"]="Disciple of War",["ExpArrayIndex"]=0},[21]={["Name"]="Warrior",["Abbreviation"]="WAR",["Category"]="Disciple of War",["ExpArrayIndex"]=2},[22]={["Name"]="Dragoon",["Abbreviation"]="DRG",["Category"]="Disciple of War",["ExpArrayIndex"]=4},[23]={["Name"]="Bard",["Abbreviation"]="BRD",["Category"]="Disciple of War",["ExpArrayIndex"]=3},[24]={["Name"]="White Mage",["Abbreviation"]="WHM",["Category"]="Disciple of Magic",["ExpArrayIndex"]=6},[25]={["Name"]="Black Mage",["Abbreviation"]="BLM",["Category"]="Disciple of Magic",["ExpArrayIndex"]=5},[26]={["Name"]="Arcanist",["Abbreviation"]="ACN",["Category"]="Disciple of Magic",["ExpArrayIndex"]=18},[27]={["Name"]="Summoner",["Abbreviation"]="SMN",["Category"]="Disciple of Magic",["ExpArrayIndex"]=18},[28]={["Name"]="Scholar",["Abbreviation"]="SCH",["Category"]="Disciple of Magic",["ExpArrayIndex"]=18},[29]={["Name"]="Rogue",["Abbreviation"]="ROG",["Category"]="Disciple of War",["ExpArrayIndex"]=19},[30]={["Name"]="Ninja",["Abbreviation"]="NIN",["Category"]="Disciple of War",["ExpArrayIndex"]=19},[31]={["Name"]="Machinist",["Abbreviation"]="MCH",["Category"]="Disciple of War",["ExpArrayIndex"]=20},[32]={["Name"]="Dark Knight",["Abbreviation"]="DRK",["Category"]="Disciple of War",["ExpArrayIndex"]=21},[33]={["Name"]="Astrologian",["Abbreviation"]="AST",["Category"]="Disciple of Magic",["ExpArrayIndex"]=22},[34]={["Name"]="Samurai",["Abbreviation"]="SAM",["Category"]="Disciple of War",["ExpArrayIndex"]=23},[35]={["Name"]="Red Mage",["Abbreviation"]="RDM",["Category"]="Disciple of Magic",["ExpArrayIndex"]=24},[36]={["Name"]="Blue Mage",["Abbreviation"]="BLU",["Category"]="Disciple of Magic",["ExpArrayIndex"]=25},[37]={["Name"]="Gunbreaker",["Abbreviation"]="GNB",["Category"]="Disciple of War",["ExpArrayIndex"]=26},[38]={["Name"]="Dancer",["Abbreviation"]="DNC",["Category"]="Disciple of War",["ExpArrayIndex"]=27},[39]={["Name"]="Reaper",["Abbreviation"]="RPR",["Category"]="Disciple of War",["ExpArrayIndex"]=28},[40]={["Name"]="Sage",["Abbreviation"]="SGE",["Category"]="Disciple of Magic",["ExpArrayIndex"]=29},[41]={["Name"]="Viper",["Abbreviation"]="VPR",["Category"]="Disciple of War",["ExpArrayIndex"]=30},[42]={["Name"]="Pictomancer",["Abbreviation"]="PCT",["Category"]="Disciple of Magic",["ExpArrayIndex"]=31}}


-- Usage: GetPlayerJob() 
-- Returns the current player job abbreviation
function GetPlayerJob()
    -- Mapping for GetClassJobId()
    -- Find and return job ID
    local job_id = GetClassJobId()
    return Joblist[job_id]["Abbreviation"] or "Unknown job"
end

-- Usage: DoAction("Heavy Shot")
-- Uses specified action
function DoAction(action_name)
    if GetCharacterCondition(4) then
        repeat
            Dismount()
            Sleep(0.1)
        until not GetCharacterCondition(4)
    end
    
    yield('/ac "' .. action_name .. '"')
end

-- Usage: DoGeneralAction("Jump")
-- Uses specified general action
function DoGeneralAction(general_action_name)
    if GetCharacterCondition(4) then
        repeat
            Dismount()
            Sleep(0.1)
        until not GetCharacterCondition(4)
    end
    
    yield('/gaction "' .. general_action_name .. '"')
end

-- Usage: DoTargetLockon()
-- Locks on to current target
function DoTargetLockon(target_lockon_name)
    yield("/lockon")
end

-- NEEDS excel browser adding
-- Usage: IsQuestDone("Hallo Halatali")
-- Checks if you have completed the specified quest
function IsQuestDone(quest_done_name)
    -- Look up the quest by name
    local quest = QuestNameList[quest_done_name]

    -- Check if the quest exists
    if quest then
        return IsQuestComplete(quest.quest_key)
    end
end

-- NEEDS excel browser adding
-- Usage: DoQuest("Hallo Halatali")
-- Checks if you have completed the specified quest and starts if you have not
function DoQuest(quest_do_name)
    -- Look up the quest by name
    local quest = QuestNameList[quest_do_name]
    
    -- If the quest not found, echo and return false
    if not quest then
        Echo('Quest "' .. quest_do_name .. '" not found.')
        return false
    end
    
    -- Check if the quest is already completed
    if IsQuestComplete(quest.quest_key) then
        Echo('You have already completed the "' .. quest_do_name .. '" quest.')
        return true
    end
    
    -- Start the quest
    yield("/qst next " .. quest.quest_id)
    Sleep(0.5)
    yield("/qst start")
    
    -- Wait until the quest is complete, with condition checking since some NPCs talk too long
    repeat
        Sleep(0.1)
    until IsQuestComplete(quest.quest_key) and IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26) and not GetCharacterCondition(32)
    
    Sleep(0.5)
    
    return true
end

-- Usage: IsPlayerLowerThanLevel(100)
-- Checks if player level lower than specified amount, returns true if so
function IsPlayerLowerThanLevel(player_lower_level)
    if GetLevel() < player_lower_level then
        return true
    end
end

-- Usage: IsPlayerHigherThanLevel(1)
-- Checks if player level higher than specified amount, returns true if so
function IsPlayerHigherThanLevel(player_higher_level)
    if GetLevel() > player_higher_level then
        return true
    end
end

-- NEEDS some kind of translation so you can just do "Sastasha" than needing to do 1
-- NEEDS fixing as character with fewer dungeons have different duty_finder_number
-- Usage: DutyFinderQueue for "Sastasha"
-- Options: 0-9 for duty tab, 1-999 for duty number
-- Automatically queues for specified duty, waits until player has exited duty
function DutyFinderQueue(duty_finder_tab_number, duty_finder_number)
    -- Open duty finder
    repeat
        yield("/dutyfinder")
        Sleep(0.1)
    until IsAddonVisible("ContentsFinder")
    
    -- Pick the duty tab
    repeat
        yield("/pcall ContentsFinder true 1 " .. duty_finder_tab_number)
        Sleep(0.1)
    until IsAddonVisible("JournalDetail")
    
    -- Clear the duty selection
    repeat
        yield("/pcall ContentsFinder true 12 1")
        Sleep(0.1)
    until IsAddonVisible("ContentsFinder")
    
    -- Pick the duty
    repeat
        yield("/pcall ContentsFinder true 3 " .. duty_finder_number)
        Sleep(0.1)
    until IsAddonVisible("ContentsFinder")
    
    -- Take note of current ZoneID to know when duty is over later
    Sleep(0.1)
    local current_zone_id = GetZoneID()
    
    -- Queue the duty
    repeat
        yield("/pcall ContentsFinder true 12 0")
        Sleep(0.1)
    until IsAddonVisible("ContentsFinderConfirm")
    
    -- Accept the duty
    repeat
        yield("/pcall ContentsFinderConfirm true 8")
        Sleep(0.1)
    until not IsAddonVisible("ContentsFinderConfirm")
    
    -- Compare ZoneID to know when duty is over
    Sleep(5.0)
    if GetZoneID() ~= current_zone_id then
        repeat
            ZoneCheck(GetZoneID())
            Sleep(0.1)
        until current_zone_id == GetZoneID()
    end
end

-- NEEDS some kind of translation so you can just do "Sastasha" than needing to do 1
-- NEEDS fixing as character with fewer dungeons have different duty_finder_number
-- Usage: DutyFinderQueue(5) for "The Aurum Vale" OpenRegularDuty(5)
-- Options: 0-9 for duty tab, 1-999 for duty number
-- Automatically queues for specified duty, waits until player has exited duty

-- will return to this later

-- function DutyFinderQueue(duty_finder_number, duty_finder_name)
    -- -- Open duty finder
    -- repeat
        -- yield("/dutyfinder")
        -- Sleep(0.1)
    -- until IsAddonVisible("ContentsFinder")
    
    -- -- Clear the duty selection
    -- repeat
        -- yield("/pcall ContentsFinder true 12 1")
        -- Sleep(0.1)
    -- until IsAddonVisible("ContentsFinder")
    
    -- -- Pick the duty
    -- repeat
        -- OpenRegularDuty(duty_finder_number)
        -- Sleep(0.1)
    -- until IsAddonVisible("ContentsFinder")
    
    -- -- Take note of current ZoneID to know when duty is over later
    -- Sleep(0.1)
    -- local current_zone_id = GetZoneID()
    
    -- -- Queue the duty
    -- repeat
        -- yield("/pcall ContentsFinder true 12 0")
        -- Sleep(0.1)
    -- until IsAddonVisible("ContentsFinderConfirm")
    
    -- -- Accept the duty
    -- repeat
        -- yield("/pcall ContentsFinderConfirm true 8")
        -- Sleep(0.1)
    -- until not IsAddonVisible("ContentsFinderConfirm")
    
    -- -- Compare ZoneID to know when duty is over
    -- Sleep(5.0)
    -- if GetZoneID() ~= current_zone_id then
        -- repeat
            -- ZoneCheck(GetZoneID())
            -- Sleep(0.1)
        -- until current_zone_id == GetZoneID()
    -- end
-- end

-- NEEDS loot rules and language fixing
-- Usage: DutyFinderSettings(0, 1, 2, 6) or DutyFinderSettings(0, 1)
-- Options: 0-8 for duty settings
-- 0 = Join Party in progress
-- 1 = Unrestricted Party
-- 2 = Level Sync (Requires Unrestricted Party)
-- 3 = Minimum IL
-- 4 = Silence Echo
-- 5 = Explorer Mode
-- 6 = Limited Leveling Roulette
-- 7 = Loot Rules (Normal, Greed Only, Lootmaster)
-- 8 = Language (Jp, En, De, Fr)
-- Automatically sets specified duty finder settings
function DutyFinderSettings(...)
    local duty_finder_settings = {...}

    -- Open duty finder
    repeat
        yield("/dutyfinder")
        Sleep(0.1)
    until IsAddonVisible("ContentsFinder")
    
    -- Open duty finder settings
    repeat
        yield("/pcall ContentsFinder true 15")
        Sleep(0.1)
    until IsAddonVisible("ContentsFinderSetting")

    -- Loop through each setting and apply it
    for _, setting_number in ipairs(duty_finder_settings) do
        repeat
            yield("/pcall ContentsFinderSetting true 1 " .. setting_number .. " 1")
            Sleep(0.1)
        until IsAddonVisible("ContentsFinderSetting")
    end
    
    -- Close duty finder settings
    repeat
        yield("/pcall ContentsFinderSetting true 0")
        Sleep(0.1)
    until not IsAddonVisible("ContentsFinderSetting")
end

-- NEEDS loot rules and language fixing
-- Usage: DutyFinderSettingsClear()
-- Clear duty finder settings
function DutyFinderSettingsClear()
    -- Open duty finder
    repeat
        yield("/dutyfinder")
        Sleep(0.1)
    until IsAddonVisible("ContentsFinder")
    
    -- Open duty finder settings
    repeat
        yield("/pcall ContentsFinder true 15")
        Sleep(0.1)
    until IsAddonVisible("ContentsFinderSetting")

    -- Iterate through all settings (0-8) and clear them
    for setting_number = 0, 8 do
        repeat
            yield("/pcall ContentsFinderSetting true 1 " .. setting_number .. " 0")
            Sleep(0.1)
        until IsAddonVisible("ContentsFinderSetting")
    end
    
    -- Close duty finder settings
    repeat
        yield("/pcall ContentsFinderSetting true 0")
        Sleep(0.1)
    until not IsAddonVisible("ContentsFinderSetting")
end

-- Usage: Dismount()
-- Checks if player is mounted, dismounts if true
function Dismount()
    if TerritorySupportsMounting() then
        if GetCharacterCondition(4) then
            repeat
                yield("/mount")
                Sleep(0.1)
            until not GetCharacterCondition(4)
        end

        repeat
            Sleep(0.1)
        until IsPlayerAvailable() and not IsPlayerCasting() 
    else
        -- do nothing
    end
end

-- Usage: DropboxSetAll() or DropboxSetAll(123456)
-- Sets all items in Dropbox plugin to max values
-- Optionally can include a numerical value to set gil transfer amount
function DropboxSetAll(dropbox_gil)
    local gil = 999999999

    if dropbox_gil then
        gil = dropbox_gil
    else
        gil = 999999999
    end
    
    for id = 1, 60000 do
        if id == 1 then
            -- Set gil to gil cap or specified gil amount
            DropboxSetItemQuantity(id, false, gil)
        elseif id < 2 or id > 19 then -- Excludes Shards, Crystals and Clusters
            -- Set all item ID except 2-19
            DropboxSetItemQuantity(id, false, 139860) -- NQ
            DropboxSetItemQuantity(id, true, 139860)  -- HQ
        end
        
        Sleep(0.0001)
    end
end

-- Usage: DropboxClearAll()
-- Clears all items in Dropbox plugin
function DropboxClearAll()
    for id = 1, 60000 do
        DropboxSetItemQuantity(id, false, 0) -- NQ
        DropboxSetItemQuantity(id, true, 0)  -- HQ
    end
    
    Sleep(0.0001)
end

-- Usage: IsQuestNameAccepted()
-- Checks if quest name is accepted
-- NEEDS doing
function IsQuestNameAccepted()
    -- stuff can go here
    -- check IsQuestDone() for example
    -- do when have actual quest list from csv
end

-- Usage: IsHuntLogComplete(9, 0) or IsHuntLogComplete(0, 1)
-- Checks if player has the hunt log rank completed
-- Valid jobs: 0 = GLA, 1 = PGL, 2 = MRD, 3 = LNC, 4 = ARC, 5 = ROG, 6 = CNJ, 7 = THM, 8 = ACN, 9 = GC
-- Valid ranks/pages: 0-4 for jobs, 0-2 for GC
function IsHuntLogComplete(class, rank)
    OpenHuntLog(class, rank)
    local rank_text = GetNodeText("MonsterNote", 33, rank, 3)
    local left_num, right_num = rank_text:match("([^/]+)/([^/]+)")
    if left_num == right_num then
        CloseHuntLog()
        return true
    else
        CloseHuntLog()
        return false
    end
end

-- Usage: GetPlayerJobLevel() // GetPlayerJobLevel("WAR") // GetPlayerJobLevel(11)
-- Returns current player job level, can specify job to check, even id if you really want to be cursed
function GetPlayerJobLevel(job)
    local job = job or GetClassJobId()
    if type(job) == "string" then
        local function findJobXPByAbbreviation(abbreviation)
            for index, job in ipairs(Joblist) do
                if job["Abbreviation"] == abbreviation then
                    return tonumber(GetLevel(job["ExpArrayIndex"]))
                end
            end
            return "Unknown job"
        end
        return findJobXPByAbbreviation(job) or "Unknown job"
    elseif type(job) ~= nil then
        return tonumber(GetLevel(Joblist[job]["ExpArrayIndex"]))
    end
end

-- Usage: ReturnHomeWorld()
-- Checks if player is not on home world and returns Home
-- ZoneTransitions() not required to be called after
function ReturnHomeWorld()
    Echo("Attempting to return to " .. GetHomeWorld())
    
    if GetCurrentWorld() ~= GetHomeWorld() then
        Teleporter(GetHomeWorld(), "li")
    end
    
    repeat
        Sleep(0.1)
    until GetCurrentWorld() == GetHomeWorld() and IsPlayerAvailable()
end