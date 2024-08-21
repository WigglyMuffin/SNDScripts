-- This file needs to be dropped inside %appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\
-- So it should look like this %appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\vac_functions.lua
-- It contains the functions required to make the scripts work

function LoadFileCheck()
	yield("/e Successfully loaded the functions file")
end

-- ###############
-- # TO DO STUFF #
-- ###############

-- Full quest list with both quest IDs and key IDs
-- Dungeon ID list
-- Distance stuff
-- Redo Teleporter()
-- Redo Movement()
-- Redo ZoneCheck()
-- IsQuestNameAccepted() see below
-- IsHuntLogComplete() see below

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
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
    
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

    if GetZoneID() ~= zone_id then
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
    repeat 
         Sleep(0.1)
    until GetCharacterCondition(45) or GetCharacterCondition(51)
    repeat 
        Sleep(0.1)
    until not GetCharacterCondition(45) or not GetCharacterCondition(51)
    repeat
        Sleep(0.1)
    until IsPlayerAvailable()
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
    yield("/echo uh GetNodeTextLookupUpdate fucked up")
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
    yield("/echo Can't find the node text, everything will probably crash now since there's no proper handler yet")
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
function Teleporter(location, tp_kind) -- Teleporter handler
    local lifestream_stopped = false
    local cast_time_buffer = 5 -- Just in case a buffer is required, teleports are 5 seconds long. Slidecasting, ping and fps can affect casts
    local max_retries = 10  -- Teleporter retry amount, will not tp after number has been reached for safety
    local retries = 0
    
    -- Initial check to ensure player can teleport
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26) and not GetCharacterCondition(32) -- 26 is combat, 32 is quest event
    
    -- Try teleport, retry until max_retries is reached
    while retries < max_retries do
        -- Stop lifestream only once per teleport attempt
        if tp_kind == "li" and not lifestream_stopped then
            yield("/lifestream stop")
            lifestream_stopped = true
            Sleep(0.1)
        end
        
        -- Attempt teleport
        if not IsPlayerCasting() then
            yield("/" .. tp_kind .. " " .. location)
            Sleep(2.0) -- Short wait to check if casting starts
            
            -- Check if the player started casting, indicating a successful attempt
            if IsPlayerCasting() then
                Sleep(cast_time_buffer) -- Wait for cast to complete
            end
        end
        
        -- Check if the teleport was successful
        if GetCharacterCondition(45) or GetCharacterCondition(51) then -- 45 is BetweenAreas, 51 is BetweenAreas51
            LogInfo("Teleport successful.")
            break
        end
        
        -- Teleport retry increment
        retries = retries + 1
        LogInfo("Retrying teleport attempt #" .. retries)
        
        -- Reset lifestream_stopped for next retry
        lifestream_stopped = false
    end
    
    -- Teleporter failed handling
    if retries >= max_retries then
        LogInfo("Teleport failed after " .. max_retries .. " attempts.")
        yield("/e Teleport failed after " .. max_retries .. " attempts.")
        yield("/lifestream stop") -- Not always needed but removes lifestream ui
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
            yield("/e Successfully mounted after " .. retries .. " retries.")
            break
        end
        
        -- Increment the retry counter
        retries = retries + 1
    end
    
    -- Check if max retries were reached without success
    if retries >= max_retries then
        yield("/e Failed to mount after max retries (" .. max_retries .. ").")
    end
    
    -- Check player is available and mounted
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and GetCharacterCondition(4)
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
                Sleep(0.5)
                NavToDestination()
                stuck_timer = 0
            end

            Sleep(0.1)
        end
        if GetCharacterCondition(45) then
            break
        end
    end
end


-- Usage: OpenTimers()
--
-- Opens the timers window
function OpenTimers()
    repeat
        yield("/timers")
        Sleep(0.1)
    until IsAddonVisible("ContentsInfo")
    repeat
        yield("/pcall ContentsInfo True 12 1")
        Sleep(0.1)
    until IsAddonVisible("ContentsInfoDetail")
    repeat
        yield("/timers")
        Sleep(0.1)
    until not IsAddonVisible("ContentsInfo")
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
        else
            Echo("Unknown Grand Company ID: " .. tostring(gc_id))
        end
        
        Interact()
        
        repeat
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
    --yield("/at n")
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
            LogInfo("/echo Nothing here, moving on")
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
ZoneList={["128"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="Limsa Lominsa",["PlaceName"]="Limsa Lominsa Upper Decks",["Mount"]=false,["Aetheryte"]="Limsa Lominsa Lower Decks",["Flight"]=false},["129"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="Limsa Lominsa",["PlaceName"]="Limsa Lominsa Lower Decks",["Mount"]=false,["Aetheryte"]="Limsa Lominsa Lower Decks",["Flight"]=false},["130"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Ul'dah",["PlaceName"]="Ul'dah - Steps of Nald",["Mount"]=false,["Aetheryte"]="Ul'dah - Steps of Nald",["Flight"]=false},["131"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Ul'dah",["PlaceName"]="Ul'dah - Steps of Thal",["Mount"]=false,["Aetheryte"]="Ul'dah - Steps of Nald",["Flight"]=false},["132"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="Gridania",["PlaceName"]="New Gridania",["Mount"]=false,["Aetheryte"]="New Gridania",["Flight"]=false},["133"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="Gridania",["PlaceName"]="Old Gridania",["Mount"]=false,["Aetheryte"]="New Gridania",["Flight"]=false},["134"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Middle La Noscea",["Mount"]=true,["Aetheryte"]="Summerford Farms",["Flight"]=false},["135"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Lower La Noscea",["Mount"]=true,["Aetheryte"]="Moraby Drydocks",["Flight"]=false},["136"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Mist",["Mount"]=false,["Aetheryte"]="Limsa Lominsa Lower Decks",["Flight"]=false},["137"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Eastern La Noscea",["Mount"]=true,["Aetheryte"]="Costa del Sol",["Flight"]=false},["138"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Western La Noscea",["Mount"]=true,["Aetheryte"]="Swiftperch",["Flight"]=false},["139"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Upper La Noscea",["Mount"]=true,["Aetheryte"]="Camp Bronze Lake",["Flight"]=false},["140"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Western Thanalan",["Mount"]=true,["Aetheryte"]="Horizon",["Flight"]=false},["141"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Central Thanalan",["Mount"]=true,["Aetheryte"]="Black Brush Station",["Flight"]=false},["142"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Halatali",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["144"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="ゴールドソーサー",["PlaceName"]="The Gold Saucer",["Mount"]=false,["Aetheryte"]="The Gold Saucer",["Flight"]=false},["145"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Eastern Thanalan",["Mount"]=true,["Aetheryte"]="Camp Drybone",["Flight"]=false},["146"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Southern Thanalan",["Mount"]=true,["Aetheryte"]="Little Ala Mhigo",["Flight"]=false},["147"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Northern Thanalan",["Mount"]=true,["Aetheryte"]="Camp Bluefog",["Flight"]=false},["148"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="Central Shroud",["Mount"]=true,["Aetheryte"]="Bentbranch Meadows",["Flight"]=false},["149"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="ウルヴズジェイル",["PlaceName"]="The Feasting Grounds",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["151"]={["PlaceName_Region"]="Mor Dhona",["PlaceName_Zone"]="Mor Dhona",["PlaceName"]="The World of Darkness",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["152"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="East Shroud",["Mount"]=true,["Aetheryte"]="The Hawthorne Hut",["Flight"]=false},["153"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="South Shroud",["Mount"]=true,["Aetheryte"]="Quarrymill",["Flight"]=false},["154"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="North Shroud",["Mount"]=true,["Aetheryte"]="Fallgourd Float",["Flight"]=false},["155"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Coerthas",["PlaceName"]="Coerthas Central Highlands",["Mount"]=true,["Aetheryte"]="Camp Dragonhead",["Flight"]=false},["156"]={["PlaceName_Region"]="Mor Dhona",["PlaceName_Zone"]="Mor Dhona",["PlaceName"]="Mor Dhona",["Mount"]=true,["Aetheryte"]="Revenant's Toll",["Flight"]=false},["159"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="The Wanderer's Palace",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["160"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Pharos Sirius",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["163"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="The Sunken Temple of Qarn",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["167"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="Amdapor Keep",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["170"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Cutter's Cry",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["171"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Coerthas",["PlaceName"]="Dzemael Darkhold",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["172"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Coerthas",["PlaceName"]="Aurum Vale",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["174"]={["PlaceName_Region"]="Mor Dhona",["PlaceName_Zone"]="Mor Dhona",["PlaceName"]="Labyrinth of the Ancients",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["176"]={["PlaceName_Region"]="",["PlaceName_Zone"]="",["PlaceName"]="Mordion Gaol",["Mount"]=false,["Aetheryte"]="Wolves' Den Pier",["Flight"]=false},["177"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="Limsa Lominsa",["PlaceName"]="Mizzenmast Inn",["Mount"]=false,["Aetheryte"]="Limsa Lominsa Lower Decks",["Flight"]=false},["178"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Ul'dah",["PlaceName"]="The Hourglass",["Mount"]=false,["Aetheryte"]="Ul'dah - Steps of Nald",["Flight"]=false},["179"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="Gridania",["PlaceName"]="The Roost",["Mount"]=false,["Aetheryte"]="New Gridania",["Flight"]=false},["180"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Outer La Noscea",["Mount"]=true,["Aetheryte"]="Camp Overlook",["Flight"]=false},["181"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="Limsa Lominsa",["PlaceName"]="Limsa Lominsa",["Mount"]=false,["Aetheryte"]="Limsa Lominsa Lower Decks",["Flight"]=false},["193"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="IC-06 Central Decks",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["194"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="IC-06 Regeneration Grid",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["195"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="IC-06 Main Bridge",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["196"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="The Burning Heart",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["198"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="Limsa Lominsa",["PlaceName"]="Command Room",["Mount"]=false,["Aetheryte"]="Limsa Lominsa Lower Decks",["Flight"]=false},["204"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="Gridania",["PlaceName"]="Seat of the First Bow",["Mount"]=false,["Aetheryte"]="New Gridania",["Flight"]=false},["205"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="Gridania",["PlaceName"]="Lotus Stand",["Mount"]=false,["Aetheryte"]="New Gridania",["Flight"]=false},["210"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Ul'dah",["PlaceName"]="Heart of the Sworn",["Mount"]=false,["Aetheryte"]="Ul'dah - Steps of Nald",["Flight"]=false},["212"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="The Waking Sands",["Mount"]=false,["Aetheryte"]="Horizon",["Flight"]=false},["241"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Upper Aetheroacoustic Exploratory Site",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["242"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Lower Aetheroacoustic Exploratory Site",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["243"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="The Ragnarok",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["244"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Ragnarok Drive Cylinder",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["245"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Ragnarok Central Core",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["246"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="IC-04 Main Bridge",["Mount"]=false,["Aetheryte"]="Ceruleum Processing Plant",["Flight"]=false},["247"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Ragnarok Main Bridge",["Mount"]=false,["Aetheryte"]="Ceruleum Processing Plant",["Flight"]=false},["250"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="ウルヴズジェイル",["PlaceName"]="Wolves' Den Pier",["Mount"]=false,["Aetheryte"]="Wolves' Den Pier",["Flight"]=false},["276"]={["PlaceName_Region"]="",["PlaceName_Zone"]="",["PlaceName"]="Hall of Summoning",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["281"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="The Whorleater",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["282"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Private Cottage - Mist",["Mount"]=false,["Aetheryte"]="Limsa Lominsa Lower Decks",["Flight"]=false},["283"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Private House - Mist",["Mount"]=false,["Aetheryte"]="Limsa Lominsa Lower Decks",["Flight"]=false},["284"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Private Mansion - Mist",["Mount"]=false,["Aetheryte"]="Limsa Lominsa Lower Decks",["Flight"]=false},["286"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Rhotano Sea",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["292"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Bowl of Embers",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["293"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="The Navel",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["294"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Coerthas",["PlaceName"]="The Howling Eye",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["338"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Eorzean Subterrane",["Mount"]=false,["Aetheryte"]="Ceruleum Processing Plant",["Flight"]=false},["340"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="The Lavender Beds",["Mount"]=true,["Aetheryte"]="New Gridania",["Flight"]=false},["341"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="The Goblet",["Mount"]=true,["Aetheryte"]="Ul'dah - Steps of Nald",["Flight"]=false},["342"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="Private Cottage - The Lavender Beds",["Mount"]=false,["Aetheryte"]="New Gridania",["Flight"]=false},["343"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="Private House - The Lavender Beds",["Mount"]=false,["Aetheryte"]="New Gridania",["Flight"]=false},["344"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="Private Mansion - The Lavender Beds",["Mount"]=false,["Aetheryte"]="New Gridania",["Flight"]=false},["345"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Private Cottage - The Goblet",["Mount"]=false,["Aetheryte"]="Ul'dah - Steps of Nald",["Flight"]=false},["346"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Private House - The Goblet",["Mount"]=false,["Aetheryte"]="Ul'dah - Steps of Nald",["Flight"]=false},["347"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Private Mansion - The Goblet",["Mount"]=false,["Aetheryte"]="Ul'dah - Steps of Nald",["Flight"]=false},["348"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Porta Decumana",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["349"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Copperbell Mines",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["350"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="Haukke Manor",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["351"]={["PlaceName_Region"]="Mor Dhona",["PlaceName_Zone"]="Mor Dhona",["PlaceName"]="The Rising Stones",["Mount"]=false,["Aetheryte"]="Revenant's Toll",["Flight"]=false},["353"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="Kugane Ohashi",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["354"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Dancing Plague",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["355"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="Dalamud's Shadow",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["356"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="The Outer Coil",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["357"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="Central Decks",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["358"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="The Holocharts",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["361"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Hullbreaker Isle",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["362"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Brayflox's Longstop",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["363"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="The Lost City of Amdapor",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["364"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="Thornmarch",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["365"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Coerthas",["PlaceName"]="Stone Vigil",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["366"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Coerthas",["PlaceName"]="Griffin Crossing",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["368"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Coerthas",["PlaceName"]="The Weeping Saint",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["369"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Hall of the Bestiarii",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["370"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="Main Bridge",["Mount"]=false,["Aetheryte"]="Ceruleum Processing Plant",["Flight"]=false},["372"]={["PlaceName_Region"]="Mor Dhona",["PlaceName_Zone"]="Mor Dhona",["PlaceName"]="Syrcus Tower",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["373"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="The Tam-Tara Deepcroft",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["374"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="The Striking Tree",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["376"]={["PlaceName_Region"]="Mor Dhona",["PlaceName_Zone"]="ウルヴズジェイル",["PlaceName"]="Carteneau Flats: Borderland Ruins",["Mount"]=true,["Aetheryte"]="",["Flight"]=false},["377"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Coerthas",["PlaceName"]="Akh Afah Amphitheatre",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["384"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Private Chambers - Mist",["Mount"]=false,["Aetheryte"]="Limsa Lominsa Lower Decks",["Flight"]=false},["385"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="Private Chambers - The Lavender Beds",["Mount"]=false,["Aetheryte"]="New Gridania",["Flight"]=false},["386"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Private Chambers - The Goblet",["Mount"]=false,["Aetheryte"]="Ul'dah - Steps of Nald",["Flight"]=false},["387"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Sastasha",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["388"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="ゴールドソーサー",["PlaceName"]="Chocobo Square",["Mount"]=false,["Aetheryte"]="The Gold Saucer",["Flight"]=false},["392"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="Sanctum of the Twelve",["Mount"]=false,["Aetheryte"]="New Gridania",["Flight"]=false},["395"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Coerthas",["PlaceName"]="Intercessory",["Mount"]=false,["Aetheryte"]="Camp Dragonhead",["Flight"]=false},["397"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Coerthas",["PlaceName"]="Coerthas Western Highlands",["Mount"]=true,["Aetheryte"]="Falcon's Nest",["Flight"]=false},["398"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="The Dravanian Forelands",["Mount"]=true,["Aetheryte"]="Tailfeather",["Flight"]=false},["399"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="The Dravanian Hinterlands",["Mount"]=true,["Aetheryte"]="Idyllshire",["Flight"]=false},["400"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="The Churning Mists",["Mount"]=true,["Aetheryte"]="Moghome",["Flight"]=false},["401"]={["PlaceName_Region"]="Abalathia's Spine",["PlaceName_Zone"]="Abalathia's Spine",["PlaceName"]="The Sea of Clouds",["Mount"]=true,["Aetheryte"]="Camp Cloudtop",["Flight"]=false},["402"]={["PlaceName_Region"]="Abalathia's Spine",["PlaceName_Zone"]="Abalathia's Spine",["PlaceName"]="Azys Lla",["Mount"]=true,["Aetheryte"]="Helix",["Flight"]=false},["403"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="Ala Mhigo",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["418"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Ishgard",["PlaceName"]="Foundation",["Mount"]=false,["Aetheryte"]="Foundation",["Flight"]=false},["419"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Ishgard",["PlaceName"]="The Pillars",["Mount"]=false,["Aetheryte"]="Foundation",["Flight"]=false},["420"]={["PlaceName_Region"]="Abalathia's Spine",["PlaceName_Zone"]="Abalathia's Spine",["PlaceName"]="Neverreap",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["423"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Company Workshop - Mist",["Mount"]=false,["Aetheryte"]="Limsa Lominsa Lower Decks",["Flight"]=false},["424"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Company Workshop - The Goblet",["Mount"]=false,["Aetheryte"]="Ul'dah - Steps of Nald",["Flight"]=false},["425"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="Company Workshop - The Lavender Beds",["Mount"]=false,["Aetheryte"]="New Gridania",["Flight"]=false},["426"]={["PlaceName_Region"]="Mor Dhona",["PlaceName_Zone"]="Mor Dhona",["PlaceName"]="The Chrysalis",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["427"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Ishgard",["PlaceName"]="Saint Endalim's Scholasticate",["Mount"]=false,["Aetheryte"]="Foundation",["Flight"]=false},["428"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Ishgard",["PlaceName"]="Seat of the Lord Commander",["Mount"]=false,["Aetheryte"]="Foundation",["Flight"]=false},["429"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Ishgard",["PlaceName"]="Cloud Nine",["Mount"]=false,["Aetheryte"]="Foundation",["Flight"]=false},["430"]={["PlaceName_Region"]="Abalathia's Spine",["PlaceName_Zone"]="Abalathia's Spine",["PlaceName"]="The Fractal Continuum",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["431"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="ウルヴズジェイル",["PlaceName"]="Seal Rock",["Mount"]=true,["Aetheryte"]="",["Flight"]=false},["432"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="Thok ast Thok",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["433"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Ishgard",["PlaceName"]="Fortemps Manor",["Mount"]=false,["Aetheryte"]="Foundation",["Flight"]=false},["434"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Coerthas",["PlaceName"]="Dusk Vigil",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["436"]={["PlaceName_Region"]="Abalathia's Spine",["PlaceName_Zone"]="Abalathia's Spine",["PlaceName"]="The Limitless Blue",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["437"]={["PlaceName_Region"]="Abalathia's Spine",["PlaceName_Zone"]="Abalathia's Spine",["PlaceName"]="Singularity Reactor",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["439"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Ishgard",["PlaceName"]="The Lightfeather Proving Grounds",["Mount"]=false,["Aetheryte"]="Foundation",["Flight"]=false},["440"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Ishgard",["PlaceName"]="Ruling Chamber",["Mount"]=false,["Aetheryte"]="Foundation",["Flight"]=false},["442"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="The Fist of the Father",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["443"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="The Cuff of the Father",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["444"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="The Arm of the Father",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["445"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="The Burden of the Father",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["462"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="Sacrificial Chamber",["Mount"]=false,["Aetheryte"]="Tailfeather",["Flight"]=false},["463"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="Matoya's Cave",["Mount"]=false,["Aetheryte"]="Idyllshire",["Flight"]=false},["478"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Idyllshire",["PlaceName"]="Idyllshire",["Mount"]=true,["Aetheryte"]="Idyllshire",["Flight"]=false},["504"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="The Eighteenth Floor",["Mount"]=false,["Aetheryte"]="Ul'dah - Steps of Nald",["Flight"]=false},["505"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="Alexander",["Mount"]=false,["Aetheryte"]="Idyllshire",["Flight"]=false},["507"]={["PlaceName_Region"]="Abalathia's Spine",["PlaceName_Zone"]="Abalathia's Spine",["PlaceName"]="Central Azys Lla",["Mount"]=false,["Aetheryte"]="Helix",["Flight"]=false},["508"]={["PlaceName_Region"]="Abalathia's Spine",["PlaceName_Zone"]="Abalathia's Spine",["PlaceName"]="Void Ark",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["509"]={["PlaceName_Region"]="Ilsabard",["PlaceName_Zone"]="Thavnair",["PlaceName"]="The Gilded Araya",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["511"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="Saint Mocianne's Arboretum",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["512"]={["PlaceName_Region"]="Abalathia's Spine",["PlaceName_Zone"]="Abalathia's Spine",["PlaceName"]="The Diadem",["Mount"]=true,["Aetheryte"]="",["Flight"]=false},["513"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Ishgard",["PlaceName"]="The Vault",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["517"]={["PlaceName_Region"]="Abalathia's Spine",["PlaceName_Zone"]="Abalathia's Spine",["PlaceName"]="Containment Bay S1T7",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["520"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="The Fist of the Son",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["521"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="The Cuff of the Son",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["522"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="The Arm of the Son",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["523"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="The Burden of the Son",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["534"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="Gridania",["PlaceName"]="Twin Adder Barracks",["Mount"]=false,["Aetheryte"]="New Gridania",["Flight"]=false},["535"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Ul'dah",["PlaceName"]="Flame Barracks",["Mount"]=false,["Aetheryte"]="Ul'dah - Steps of Nald",["Flight"]=false},["536"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="Limsa Lominsa",["PlaceName"]="Maelstrom Barracks",["Mount"]=false,["Aetheryte"]="Limsa Lominsa Lower Decks",["Flight"]=false},["537"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="The Fold",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["554"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="ウルヴズジェイル",["PlaceName"]="The Fields of Glory",["Mount"]=true,["Aetheryte"]="",["Flight"]=false},["556"]={["PlaceName_Region"]="Mor Dhona",["PlaceName_Zone"]="Mor Dhona",["PlaceName"]="The Weeping City of Mhach",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["558"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Coerthas",["PlaceName"]="The Aquapolis",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["559"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Coerthas",["PlaceName"]="Steps of Faith",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["560"]={["PlaceName_Region"]="Abalathia's Spine",["PlaceName_Zone"]="Abalathia's Spine",["PlaceName"]="Aetherochemical Research Facility",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["561"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="The Palace of the Dead",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["567"]={["PlaceName_Region"]="Abalathia's Spine",["PlaceName_Zone"]="Abalathia's Spine",["PlaceName"]="The Parrock",["Mount"]=false,["Aetheryte"]="Ok' Zundu",["Flight"]=false},["568"]={["PlaceName_Region"]="Abalathia's Spine",["PlaceName_Zone"]="Abalathia's Spine",["PlaceName"]="Leofard's Chambers",["Mount"]=false,["Aetheryte"]="Ok' Zundu",["Flight"]=false},["571"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="Haunted Manor",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["573"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Topmast Apartment Lobby",["Mount"]=false,["Aetheryte"]="Limsa Lominsa Lower Decks",["Flight"]=false},["574"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="Lily Hills Apartment Lobby",["Mount"]=false,["Aetheryte"]="New Gridania",["Flight"]=false},["575"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Sultana's Breath Apartment Lobby",["Mount"]=false,["Aetheryte"]="Ul'dah - Steps of Nald",["Flight"]=false},["576"]={["PlaceName_Region"]="Abalathia's Spine",["PlaceName_Zone"]="Abalathia's Spine",["PlaceName"]="Containment Bay P1T6",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["578"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="The Great Gubal Library",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["579"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="ゴールドソーサー",["PlaceName"]="The Battlehall",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["580"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="Eyes of the Creator",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["581"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="Breath of the Creator",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["582"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="Heart of the Creator",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["583"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="Soul of the Creator",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["608"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="Topmast Apartment",["Mount"]=false,["Aetheryte"]="Limsa Lominsa Lower Decks",["Flight"]=false},["609"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="Lily Hills Apartment",["Mount"]=false,["Aetheryte"]="New Gridania",["Flight"]=false},["610"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Sultana's Breath Apartment",["Mount"]=false,["Aetheryte"]="Ul'dah - Steps of Nald",["Flight"]=false},["611"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Ul'dah",["PlaceName"]="Frondale's Home for Friendless Foundlings",["Mount"]=false,["Aetheryte"]="Ul'dah - Steps of Nald",["Flight"]=false},["612"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="The Fringes",["Mount"]=true,["Aetheryte"]="Castrum Oriens",["Flight"]=false},["613"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="The Ruby Sea",["Mount"]=true,["Aetheryte"]="Tamamizu",["Flight"]=false},["614"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="Yanxia",["Mount"]=true,["Aetheryte"]="Namai",["Flight"]=false},["616"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="Shisui of the Violet Tides",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["617"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="Sohm Al",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["620"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="The Peaks",["Mount"]=true,["Aetheryte"]="Ala Gannha",["Flight"]=false},["621"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="The Lochs",["Mount"]=true,["Aetheryte"]="Porta Praetoria",["Flight"]=false},["622"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="The Azim Steppe",["Mount"]=true,["Aetheryte"]="Reunion",["Flight"]=false},["623"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="Bardam's Mettle",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["626"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="The Sirensong Sea",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["627"]={["PlaceName_Region"]="Abalathia's Spine",["PlaceName_Zone"]="Abalathia's Spine",["PlaceName"]="Dun Scaith",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["628"]={["PlaceName_Region"]="Hingashi",["PlaceName_Zone"]="Kugane",["PlaceName"]="Kugane",["Mount"]=false,["Aetheryte"]="Kugane",["Flight"]=false},["629"]={["PlaceName_Region"]="Hingashi",["PlaceName_Zone"]="Kugane",["PlaceName"]="Bokairo Inn",["Mount"]=false,["Aetheryte"]="Kugane",["Flight"]=false},["635"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Rhalgr's Reach",["PlaceName"]="Rhalgr's Reach",["Mount"]=true,["Aetheryte"]="Rhalgr's Reach",["Flight"]=false},["636"]={["PlaceName_Region"]="Mor Dhona",["PlaceName_Zone"]="Mor Dhona",["PlaceName"]="Omega Control",["Mount"]=false,["Aetheryte"]="Revenant's Toll",["Flight"]=false},["637"]={["PlaceName_Region"]="Abalathia's Spine",["PlaceName_Zone"]="Abalathia's Spine",["PlaceName"]="Containment Bay Z1T9",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["639"]={["PlaceName_Region"]="Hingashi",["PlaceName_Zone"]="Kugane",["PlaceName"]="Ruby Bazaar Offices",["Mount"]=false,["Aetheryte"]="Kugane",["Flight"]=false},["641"]={["PlaceName_Region"]="Hingashi",["PlaceName_Zone"]="Kugane",["PlaceName"]="Shirogane",["Mount"]=true,["Aetheryte"]="Kugane",["Flight"]=false},["649"]={["PlaceName_Region"]="Hingashi",["PlaceName_Zone"]="Kugane",["PlaceName"]="Private Cottage - Shirogane",["Mount"]=false,["Aetheryte"]="Kugane",["Flight"]=false},["650"]={["PlaceName_Region"]="Hingashi",["PlaceName_Zone"]="Kugane",["PlaceName"]="Private House - Shirogane",["Mount"]=false,["Aetheryte"]="Kugane",["Flight"]=false},["651"]={["PlaceName_Region"]="Hingashi",["PlaceName_Zone"]="Kugane",["PlaceName"]="Private Mansion - Shirogane",["Mount"]=false,["Aetheryte"]="Kugane",["Flight"]=false},["652"]={["PlaceName_Region"]="Hingashi",["PlaceName_Zone"]="Kugane",["PlaceName"]="Private Chambers - Shirogane",["Mount"]=false,["Aetheryte"]="Kugane",["Flight"]=false},["653"]={["PlaceName_Region"]="Hingashi",["PlaceName_Zone"]="Kugane",["PlaceName"]="Company Workshop - Shirogane",["Mount"]=false,["Aetheryte"]="Kugane",["Flight"]=false},["654"]={["PlaceName_Region"]="Hingashi",["PlaceName_Zone"]="Kugane",["PlaceName"]="Kobai Goten Apartment Lobby",["Mount"]=false,["Aetheryte"]="Kugane",["Flight"]=false},["655"]={["PlaceName_Region"]="Hingashi",["PlaceName_Zone"]="Kugane",["PlaceName"]="Kobai Goten Apartment",["Mount"]=false,["Aetheryte"]="Kugane",["Flight"]=false},["658"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="The Interdimensional Rift",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["660"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="Doma Castle",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["661"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="Castrum Abania",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["662"]={["PlaceName_Region"]="Hingashi",["PlaceName_Zone"]="Kugane",["PlaceName"]="Kugane Castle",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["663"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="The Temple of the Fist",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["674"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="The Blessed Treasury",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["679"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="The Royal Airship Landing",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["680"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="La Noscea",["PlaceName"]="The <Emphasis>Misery</Emphasis>",["Mount"]=false,["Aetheryte"]="Limsa Lominsa Lower Decks",["Flight"]=false},["681"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="The House of the Fierce",["Mount"]=false,["Aetheryte"]="The House of the Fierce",["Flight"]=false},["682"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="The Doman Enclave",["Mount"]=false,["Aetheryte"]="Namai",["Flight"]=false},["683"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="The First Altar of Djanan Qhat",["Mount"]=false,["Aetheryte"]="Castrum Oriens",["Flight"]=false},["691"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="Deltascape V1.0",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["692"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="Deltascape V2.0",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["693"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="Deltascape V3.0",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["694"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="Deltascape V4.0",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["712"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="The Lost Canals of Uznair",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["719"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="Emanation",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["727"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="The Royal Menagerie",["Mount"]=false,["Aetheryte"]="The Ala Mhigan Quarter",["Flight"]=false},["729"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="ウルヴズジェイル",["PlaceName"]="Astragalos",["Mount"]=true,["Aetheryte"]="",["Flight"]=false},["730"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="Transparency",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["731"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="The Drowned City of Skalla",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["732"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Eureka Anemos",["Mount"]=true,["Aetheryte"]="",["Flight"]=false},["733"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="The Binding Coil of Bahamut",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["734"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="The Royal City of Rabanastre",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["735"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="The <Emphasis>Prima Vista</Emphasis> Tiring Room",["Mount"]=false,["Aetheryte"]="Kugane",["Flight"]=false},["736"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="The <Emphasis>Prima Vista</Emphasis> Bridge",["Mount"]=false,["Aetheryte"]="Kugane",["Flight"]=false},["737"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="Royal Palace",["Mount"]=false,["Aetheryte"]="The Ala Mhigan Quarter",["Flight"]=false},["738"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="The Resonatorium",["Mount"]=false,["Aetheryte"]="The Ala Mhigan Quarter",["Flight"]=false},["742"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="Hells' Lid",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["744"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="Kienkan",["Mount"]=false,["Aetheryte"]="Namai",["Flight"]=false},["746"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="The Jade Stoa",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["748"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="Sigmascape V1.0",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["749"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="Sigmascape V2.0",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["750"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="Sigmascape V3.0",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["751"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="Sigmascape V4.0",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["761"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="The Great Hunt",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["763"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Eureka Pagos",["Mount"]=true,["Aetheryte"]="",["Flight"]=false},["764"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="Reisen Temple",["Mount"]=false,["Aetheryte"]="Onokoro",["Flight"]=false},["768"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="The Swallow's Compass",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["769"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="The Burn",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["770"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="Heaven-on-High",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["776"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="The Ridorana Lighthouse",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["777"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Ultimacy",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["778"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="Castrum Fluminis",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["781"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="Reisen Temple Road",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["787"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="The Ridorana Cataract",["Mount"]=false,["Aetheryte"]="Kugane",["Flight"]=false},["791"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="ウルヴズジェイル",["PlaceName"]="Hidden Gorge",["Mount"]=true,["Aetheryte"]="",["Flight"]=false},["792"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="ゴールドソーサー",["PlaceName"]="The Fall of Belah'dia",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["793"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="The Ghimlyt Dark",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["794"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="The Shifting Altars of Uznair",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["795"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Eureka Pyros",["Mount"]=true,["Aetheryte"]="",["Flight"]=false},["796"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Ul'dah",["PlaceName"]="Blue Sky",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["798"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="Psiscape V1.0",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["799"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="Psiscape V2.0",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["810"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="Hells' Kier",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["813"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="Lakeland",["Mount"]=true,["Aetheryte"]="Fort Jobb",["Flight"]=false},["814"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="Kholusia",["Mount"]=true,["Aetheryte"]="Stilltide",["Flight"]=false},["815"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="Amh Araeng",["Mount"]=true,["Aetheryte"]="Mord Souq",["Flight"]=false},["816"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="Il Mheg",["Mount"]=true,["Aetheryte"]="Lydha Lran",["Flight"]=false},["817"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Rak'tika Greatwood",["Mount"]=true,["Aetheryte"]="Slitherbough",["Flight"]=false},["818"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Tempest",["Mount"]=true,["Aetheryte"]="The Ondo Cups",["Flight"]=false},["819"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="The Crystarium",["PlaceName"]="The Crystarium",["Mount"]=false,["Aetheryte"]="The Crystarium",["Flight"]=false},["820"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Eulmore",["PlaceName"]="Eulmore",["Mount"]=false,["Aetheryte"]="Eulmore",["Flight"]=false},["821"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="Dohn Mheg",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["822"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="Mt. Gulg",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["823"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Qitana Ravel",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["824"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="Othard",["PlaceName"]="The Wreath of Snakes",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["826"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="The Orbonne Monastery",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["827"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Eureka Hydatos",["Mount"]=true,["Aetheryte"]="",["Flight"]=false},["829"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="Eorzean Alliance Headquarters",["Mount"]=false,["Aetheryte"]="The Ala Mhigan Quarter",["Flight"]=false},["831"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="ゴールドソーサー",["PlaceName"]="The Manderville Tables",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["836"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="Malikah's Well",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["837"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="Holminster Switch",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["838"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="Amaurot",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["840"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Twinning",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["841"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="Akadaemia Anyder",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["842"]={["PlaceName_Region"]="Mor Dhona",["PlaceName_Zone"]="Mor Dhona",["PlaceName"]="The Syrcus Trench",["Mount"]=false,["Aetheryte"]="Revenant's Toll",["Flight"]=false},["843"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="The Crystarium",["PlaceName"]="The Pendants Personal Suite",["Mount"]=false,["Aetheryte"]="The Crystarium",["Flight"]=false},["844"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="The Crystarium",["PlaceName"]="The Ocular",["Mount"]=false,["Aetheryte"]="The Crystarium",["Flight"]=false},["846"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Crown of the Immaculate",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["847"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Dying Gasp",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["849"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Core",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["850"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Halo",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["851"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Nereus Trench",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["852"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="Atlas Peak",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["859"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Confessional of Toupasa the Elder",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["876"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Nabaath Mines",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["878"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Empty",["Mount"]=false,["Aetheryte"]="Mord Souq",["Flight"]=false},["879"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Dungeons of Lyhe Ghiah",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["882"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Copied Factory",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["884"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Grand Cosmos",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["886"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Ishgard",["PlaceName"]="The Firmament",["Mount"]=false,["Aetheryte"]="Foundation",["Flight"]=false},["887"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="Liminal Space",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["888"]={["PlaceName_Region"]="Othard",["PlaceName_Zone"]="ウルヴズジェイル",["PlaceName"]="Onsal Hakair",["Mount"]=true,["Aetheryte"]="",["Flight"]=false},["889"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="Lyhe Mheg",["Mount"]=false,["Aetheryte"]="Lydha Lran",["Flight"]=false},["893"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="The Imperial Palace",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["895"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="Excavation Tunnels",["Mount"]=false,["Aetheryte"]="Stilltide",["Flight"]=false},["897"]={["PlaceName_Region"]="Gyr Abania",["PlaceName_Zone"]="Gyr Abania",["PlaceName"]="Cinder Drift",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["898"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="Anamnesis Anyder",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["899"]={["PlaceName_Region"]="La Noscea",["PlaceName_Zone"]="ゴールドソーサー",["PlaceName"]="The Falling City of Nym",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["900"]={["PlaceName_Region"]="The High Seas",["PlaceName_Zone"]="",["PlaceName"]="The <Emphasis>Endeavor</Emphasis>",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["902"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Gandof Thunder Plains",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["903"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="Ashfall",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["905"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="Great Glacier",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["911"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Cid's Memory",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["913"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Transmission Control",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["914"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="Trial's Threshold",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["915"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Gangos",["Mount"]=false,["Aetheryte"]="The Doman Enclave",["Flight"]=false},["916"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Heroes' Gauntlet",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["917"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Puppets' Bunker",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["919"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Terncliff",["Mount"]=false,["Aetheryte"]="The Ala Mhigan Quarter",["Flight"]=false},["920"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Bozjan Southern Front",["Mount"]=true,["Aetheryte"]="",["Flight"]=true},["922"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Seat of Sacrifice",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["924"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Shifting Oubliettes of Lyhe Ghiah",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["925"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Terncliff Bay",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["933"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="Matoya's Relict",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["934"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Castrum Marinum Drydocks",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["936"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Delubrum Reginae",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["938"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Paglth'an",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["942"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="Sphere of Naught",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["943"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="Laxan Loft",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["944"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="Bygone Gaol",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["945"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Garden of Nowhere",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["950"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="G-Savior Deck",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["952"]={["PlaceName_Region"]="Ilsabard",["PlaceName_Zone"]="Thavnair",["PlaceName"]="The Tower of Zot",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["955"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="The Last Trace",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["956"]={["PlaceName_Region"]="The Northern Empty",["PlaceName_Zone"]="Labyrinthos",["PlaceName"]="Labyrinthos",["Mount"]=true,["Aetheryte"]="The Archeion",["Flight"]=false},["957"]={["PlaceName_Region"]="Ilsabard",["PlaceName_Zone"]="Thavnair",["PlaceName"]="Thavnair",["Mount"]=true,["Aetheryte"]="Yedlihmad",["Flight"]=false},["958"]={["PlaceName_Region"]="Ilsabard",["PlaceName_Zone"]="Garlemald",["PlaceName"]="Garlemald",["Mount"]=true,["Aetheryte"]="Camp Broken Glass",["Flight"]=false},["959"]={["PlaceName_Region"]="The Sea of Stars",["PlaceName_Zone"]="The Sea of Stars",["PlaceName"]="Mare Lamentorum",["Mount"]=true,["Aetheryte"]="Sinus Lacrimarum",["Flight"]=false},["960"]={["PlaceName_Region"]="The Sea of Stars",["PlaceName_Zone"]="The Sea of Stars",["PlaceName"]="Ultima Thule",["Mount"]=true,["Aetheryte"]="Reah Tahra",["Flight"]=false},["961"]={["PlaceName_Region"]="The World Unsundered",["PlaceName_Zone"]="The World Unsundered",["PlaceName"]="Elpis",["Mount"]=true,["Aetheryte"]="Anagnorisis",["Flight"]=false},["962"]={["PlaceName_Region"]="The Northern Empty",["PlaceName_Zone"]="Old Sharlayan",["PlaceName"]="Old Sharlayan",["Mount"]=false,["Aetheryte"]="Old Sharlayan",["Flight"]=false},["963"]={["PlaceName_Region"]="Ilsabard",["PlaceName_Zone"]="Radz-at-Han",["PlaceName"]="Radz-at-Han",["Mount"]=false,["Aetheryte"]="Radz-at-Han",["Flight"]=false},["966"]={["PlaceName_Region"]="Norvrandt",["PlaceName_Zone"]="Norvrandt",["PlaceName"]="The Tower at Paradigm's Breach",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["968"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Coerthas",["PlaceName"]="Medias Res",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["969"]={["PlaceName_Region"]="Ilsabard",["PlaceName_Zone"]="Thavnair",["PlaceName"]="The Tower of Babil",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["970"]={["PlaceName_Region"]="Ilsabard",["PlaceName_Zone"]="Thavnair",["PlaceName"]="Vanaspati",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["971"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Lemures Headquarters",["Mount"]=false,["Aetheryte"]="Ul'dah - Steps of Nald",["Flight"]=false},["973"]={["PlaceName_Region"]="The Sea of Stars",["PlaceName_Zone"]="The Sea of Stars",["PlaceName"]="The Dead Ends",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["974"]={["PlaceName_Region"]="The World Unsundered",["PlaceName_Zone"]="The World Unsundered",["PlaceName"]="Ktisis Hyperboreia",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["975"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Zadnor",["Mount"]=true,["Aetheryte"]="",["Flight"]=true},["976"]={["PlaceName_Region"]="The Sea of Stars",["PlaceName_Zone"]="The Sea of Stars",["PlaceName"]="Smileton",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["978"]={["PlaceName_Region"]="The Northern Empty",["PlaceName_Zone"]="Labyrinthos",["PlaceName"]="The Aitiascope",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["979"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Ishgard",["PlaceName"]="Empyreum",["Mount"]=true,["Aetheryte"]="Foundation",["Flight"]=false},["980"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Ishgard",["PlaceName"]="Private Cottage - Empyreum",["Mount"]=false,["Aetheryte"]="Foundation",["Flight"]=false},["981"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Ishgard",["PlaceName"]="Private House - Empyreum",["Mount"]=false,["Aetheryte"]="Foundation",["Flight"]=false},["982"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Ishgard",["PlaceName"]="Private Mansion - Empyreum",["Mount"]=false,["Aetheryte"]="Foundation",["Flight"]=false},["983"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Ishgard",["PlaceName"]="Private Chambers - Empyreum",["Mount"]=false,["Aetheryte"]="Foundation",["Flight"]=false},["984"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Ishgard",["PlaceName"]="Company Workshop - Empyreum",["Mount"]=false,["Aetheryte"]="Foundation",["Flight"]=false},["985"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Ishgard",["PlaceName"]="Ingleside Apartment Lobby",["Mount"]=false,["Aetheryte"]="Foundation",["Flight"]=false},["986"]={["PlaceName_Region"]="The Sea of Stars",["PlaceName_Zone"]="The Sea of Stars",["PlaceName"]="The Stigma Dreamscape",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["987"]={["PlaceName_Region"]="The Northern Empty",["PlaceName_Zone"]="Old Sharlayan",["PlaceName"]="Main Hall",["Mount"]=false,["Aetheryte"]="Old Sharlayan",["Flight"]=false},["990"]={["PlaceName_Region"]="The Northern Empty",["PlaceName_Zone"]="Old Sharlayan",["PlaceName"]="Andron",["Mount"]=false,["Aetheryte"]="Old Sharlayan",["Flight"]=false},["992"]={["PlaceName_Region"]="The Sea of Stars",["PlaceName_Zone"]="The Sea of Stars",["PlaceName"]="The Dark Inside",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["994"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="The Phantoms' Feast",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["995"]={["PlaceName_Region"]="The Northern Empty",["PlaceName_Zone"]="Labyrinthos",["PlaceName"]="The Mothercrystal",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["997"]={["PlaceName_Region"]="The Sea of Stars",["PlaceName_Zone"]="The Sea of Stars",["PlaceName"]="The Final Day",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["999"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Ishgard",["PlaceName"]="Ingleside Apartment",["Mount"]=false,["Aetheryte"]="Foundation",["Flight"]=false},["1000"]={["PlaceName_Region"]="The Sea of Stars",["PlaceName_Zone"]="The Sea of Stars",["PlaceName"]="The Excitatron 6000",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1001"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Ishgard",["PlaceName"]="Strategy Room",["Mount"]=false,["Aetheryte"]="Foundation",["Flight"]=false},["1002"]={["PlaceName_Region"]="The World Unsundered",["PlaceName_Zone"]="The World Unsundered",["PlaceName"]="The Gates of Pandæmonium",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1004"]={["PlaceName_Region"]="The World Unsundered",["PlaceName_Zone"]="The World Unsundered",["PlaceName"]="The Stagnant Limbo",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1006"]={["PlaceName_Region"]="The World Unsundered",["PlaceName_Zone"]="The World Unsundered",["PlaceName"]="The Fervid Limbo",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1008"]={["PlaceName_Region"]="The World Unsundered",["PlaceName_Zone"]="The World Unsundered",["PlaceName"]="The Sanguine Limbo",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1010"]={["PlaceName_Region"]="Ilsabard",["PlaceName_Zone"]="Thavnair",["PlaceName"]="Magna Glacies",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1013"]={["PlaceName_Region"]="The Sea of Stars",["PlaceName_Zone"]="The Sea of Stars",["PlaceName"]="Beyond the Stars",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1024"]={["PlaceName_Region"]="Ilsabard",["PlaceName_Zone"]="Thavnair",["PlaceName"]="The Nethergate",["Mount"]=false,["Aetheryte"]="Camp Broken Glass",["Flight"]=false},["1031"]={["PlaceName_Region"]="The World Unsundered",["PlaceName_Zone"]="The World Unsundered",["PlaceName"]="Propylaion",["Mount"]=false,["Aetheryte"]="Anagnorisis",["Flight"]=false},["1032"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="ウルヴズジェイル",["PlaceName"]="The Palaistra",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["1033"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="ウルヴズジェイル",["PlaceName"]="The Volcanic Heart",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["1039"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="The Thousand Maws of Toto-Rak",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["1043"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Castrum Meridianum",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1044"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="The Praetorium",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["1050"]={["PlaceName_Region"]="Ilsabard",["PlaceName_Zone"]="Thavnair",["PlaceName"]="Alzadaal's Legacy",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1052"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="The Porta Decumana",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["1054"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Aglaia",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1055"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Unnamed Island",["Mount"]=true,["Aetheryte"]="Moraby Drydocks",["Flight"]=false},["1057"]={["PlaceName_Region"]="The Northern Empty",["PlaceName_Zone"]="Old Sharlayan",["PlaceName"]="Restricted Archives",["Mount"]=false,["Aetheryte"]="Old Sharlayan",["Flight"]=false},["1061"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="The Omphalos",["Mount"]=false,["Aetheryte"]="Revenant's Toll",["Flight"]=false},["1062"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Coerthas",["PlaceName"]="Snowcloak",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["1063"]={["PlaceName_Region"]="Mor Dhona",["PlaceName_Zone"]="Mor Dhona",["PlaceName"]="The Keeper of the Lake",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["1065"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="The Aery",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["1069"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="The Sil'dihn Subterrane",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1070"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="The Fell Court of Troia",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1071"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Storm's Crown",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1073"]={["PlaceName_Region"]="The Sea of Stars",["PlaceName_Zone"]="The Sea of Stars",["PlaceName"]="Elysion",["Mount"]=false,["Aetheryte"]="Base Omicron",["Flight"]=false},["1075"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="Thanalan",["PlaceName"]="Another Sil'dihn Subterrane",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["1077"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Zero's Domain",["Mount"]=true,["Aetheryte"]="Yedlihmad",["Flight"]=false},["1078"]={["PlaceName_Region"]="Ilsabard",["PlaceName_Zone"]="Radz-at-Han",["PlaceName"]="Meghaduta Guest Chambers",["Mount"]=false,["Aetheryte"]="Radz-at-Han",["Flight"]=false},["1081"]={["PlaceName_Region"]="The World Unsundered",["PlaceName_Zone"]="The World Unsundered",["PlaceName"]="The Caustic Purgatory",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1083"]={["PlaceName_Region"]="The World Unsundered",["PlaceName_Zone"]="The World Unsundered",["PlaceName"]="The Pestilent Purgatory",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1085"]={["PlaceName_Region"]="The World Unsundered",["PlaceName_Zone"]="The World Unsundered",["PlaceName"]="The Hollow Purgatory",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1087"]={["PlaceName_Region"]="The World Unsundered",["PlaceName_Zone"]="The World Unsundered",["PlaceName"]="Stygian Insenescence Cells",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1094"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="Sneaky Hollow",["Mount"]=false,["Aetheryte"]="Bentbranch Meadows",["Flight"]=false},["1095"]={["PlaceName_Region"]="Ilsabard",["PlaceName_Zone"]="Thavnair",["PlaceName"]="Mount Ordeals",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1097"]={["PlaceName_Region"]="Ilsabard",["PlaceName_Zone"]="Thavnair",["PlaceName"]="Lapis Manalis",["Mount"]=false,["Aetheryte"]="Camp Broken Glass",["Flight"]=true},["1098"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="ゴールドソーサー",["PlaceName"]="Sylphstep",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["1099"]={["PlaceName_Region"]="Mor Dhona",["PlaceName_Zone"]="Mor Dhona",["PlaceName"]="Eureka Orthos",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["1111"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="The Antitower",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["1112"]={["PlaceName_Region"]="Dravania",["PlaceName_Zone"]="Dravania",["PlaceName"]="Sohr Khai",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["1113"]={["PlaceName_Region"]="Coerthas",["PlaceName_Zone"]="Coerthas",["PlaceName"]="Xelphatol",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["1114"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="Baelsar's Wall",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["1116"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="ウルヴズジェイル",["PlaceName"]="The Clockwork Castletown",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["1118"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Euphrosyne",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1123"]={["PlaceName_Region"]="The World Unsundered",["PlaceName_Zone"]="The World Unsundered",["PlaceName"]="The Shifting Gymnasion Agonon",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1125"]={["PlaceName_Region"]="Ilsabard",["PlaceName_Zone"]="Thavnair",["PlaceName"]="Khadga",["Mount"]=false,["Aetheryte"]="Yedlihmad",["Flight"]=false},["1126"]={["PlaceName_Region"]="The Northern Empty",["PlaceName_Zone"]="Labyrinthos",["PlaceName"]="The Aetherfont",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1137"]={["PlaceName_Region"]="Hingashi",["PlaceName_Zone"]="Kugane",["PlaceName"]="Mount Rokkon",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1138"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="ウルヴズジェイル",["PlaceName"]="The Red Sands",["Mount"]=false,["Aetheryte"]="",["Flight"]=false},["1140"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="The Voidcast Dais",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1147"]={["PlaceName_Region"]="The Northern Empty",["PlaceName_Zone"]="Labyrinthos",["PlaceName"]="The Aetherial Slough",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1149"]={["PlaceName_Region"]="The Northern Empty",["PlaceName_Zone"]="Labyrinthos",["PlaceName"]="The Dæmons' Nest",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1151"]={["PlaceName_Region"]="The Northern Empty",["PlaceName_Zone"]="Labyrinthos",["PlaceName"]="The Chamber of Fourteen",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1153"]={["PlaceName_Region"]="The Northern Empty",["PlaceName_Zone"]="Labyrinthos",["PlaceName"]="Ascension",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1155"]={["PlaceName_Region"]="Hingashi",["PlaceName_Zone"]="Kugane",["PlaceName"]="Another Mount Rokkon",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1160"]={["PlaceName_Region"]="Ilsabard",["PlaceName_Zone"]="Garlemald",["PlaceName"]="Senatus",["Mount"]=false,["Aetheryte"]="Camp Broken Glass",["Flight"]=true},["1161"]={["PlaceName_Region"]="Ilsabard",["PlaceName_Zone"]="Radz-at-Han",["PlaceName"]="Estinien's Chambers",["Mount"]=false,["Aetheryte"]="Radz-at-Han",["Flight"]=true},["1162"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="The Red Moon",["Mount"]=false,["Aetheryte"]="Sinus Lacrimarum",["Flight"]=true},["1164"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="The Lunar Subterrane",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1165"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="ゴールドソーサー",["PlaceName"]="Blunderville",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1166"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="The Memory of Embers",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1167"]={["PlaceName_Region"]="Yok Tural",["PlaceName_Zone"]="Yok Tural",["PlaceName"]="Ihuykatumu",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1168"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="The Abyssal Fracture",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1170"]={["PlaceName_Region"]="Yok Tural",["PlaceName_Zone"]="Yok Tural",["PlaceName"]="Sunperch",["Mount"]=false,["Aetheryte"]="Tuliyollal",["Flight"]=true},["1171"]={["PlaceName_Region"]="Xak Tural",["PlaceName_Zone"]="Xak Tural",["PlaceName"]="Earthen Sky Hideout",["Mount"]=false,["Aetheryte"]="The Outskirts",["Flight"]=true},["1176"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Aloalo Island",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1178"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Thaleia",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1179"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Another Aloalo Island",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1185"]={["PlaceName_Region"]="Yok Tural",["PlaceName_Zone"]="Tuliyollal",["PlaceName"]="Tuliyollal",["Mount"]=false,["Aetheryte"]="Tuliyollal",["Flight"]=true},["1186"]={["PlaceName_Region"]="Xak Tural",["PlaceName_Zone"]="Solution Nine",["PlaceName"]="Solution Nine",["Mount"]=false,["Aetheryte"]="Solution Nine",["Flight"]=true},["1187"]={["PlaceName_Region"]="Yok Tural",["PlaceName_Zone"]="Yok Tural",["PlaceName"]="Urqopacha",["Mount"]=true,["Aetheryte"]="Wachunpelo",["Flight"]=true},["1188"]={["PlaceName_Region"]="Yok Tural",["PlaceName_Zone"]="Yok Tural",["PlaceName"]="Kozama'uka",["Mount"]=true,["Aetheryte"]="Ok'hanu",["Flight"]=true},["1189"]={["PlaceName_Region"]="Yok Tural",["PlaceName_Zone"]="Yok Tural",["PlaceName"]="Yak T'el",["Mount"]=true,["Aetheryte"]="Iq Br'aax",["Flight"]=true},["1190"]={["PlaceName_Region"]="Xak Tural",["PlaceName_Zone"]="Xak Tural",["PlaceName"]="Shaaloani",["Mount"]=true,["Aetheryte"]="Hhusatahwi",["Flight"]=true},["1191"]={["PlaceName_Region"]="Xak Tural",["PlaceName_Zone"]="Xak Tural",["PlaceName"]="Heritage Found",["Mount"]=true,["Aetheryte"]="Yyasulani Station",["Flight"]=true},["1192"]={["PlaceName_Region"]="Unlost World",["PlaceName_Zone"]="Unlost World",["PlaceName"]="Living Memory",["Mount"]=true,["Aetheryte"]="Leynode Mnemo",["Flight"]=true},["1193"]={["PlaceName_Region"]="Yok Tural",["PlaceName_Zone"]="Yok Tural",["PlaceName"]="Worqor Zormor",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1194"]={["PlaceName_Region"]="Yok Tural",["PlaceName_Zone"]="Yok Tural",["PlaceName"]="The Skydeep Cenote",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1195"]={["PlaceName_Region"]="Yok Tural",["PlaceName_Zone"]="Yok Tural",["PlaceName"]="Worqor Lar Dor",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1197"]={["PlaceName_Region"]="Thanalan",["PlaceName_Zone"]="ゴールドソーサー",["PlaceName"]="Blunderville Square",["Mount"]=false,["Aetheryte"]="The Gold Saucer",["Flight"]=false},["1198"]={["PlaceName_Region"]="Xak Tural",["PlaceName_Zone"]="Xak Tural",["PlaceName"]="Vanguard",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1199"]={["PlaceName_Region"]="Unlost World",["PlaceName_Zone"]="Unlost World",["PlaceName"]="Alexandria",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1200"]={["PlaceName_Region"]="Xak Tural",["PlaceName_Zone"]="Xak Tural",["PlaceName"]="Summit of Everkeep",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1202"]={["PlaceName_Region"]="Unlost World",["PlaceName_Zone"]="Unlost World",["PlaceName"]="Interphos",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1203"]={["PlaceName_Region"]="Xak Tural",["PlaceName_Zone"]="Xak Tural",["PlaceName"]="Tender Valley",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1204"]={["PlaceName_Region"]="Unlost World",["PlaceName_Zone"]="Unlost World",["PlaceName"]="Strayborough",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1205"]={["PlaceName_Region"]="Yok Tural",["PlaceName_Zone"]="Tuliyollal",["PlaceName"]="The For'ard Cabins",["Mount"]=false,["Aetheryte"]="Tuliyollal",["Flight"]=false},["1206"]={["PlaceName_Region"]="The Northern Empty",["PlaceName_Zone"]="Labyrinthos",["PlaceName"]="Main Deck",["Mount"]=false,["Aetheryte"]="Old Sharlayan",["Flight"]=false},["1207"]={["PlaceName_Region"]="Xak Tural",["PlaceName_Zone"]="Xak Tural",["PlaceName"]="The Backroom",["Mount"]=false,["Aetheryte"]="Electrope Strike",["Flight"]=false},["1208"]={["PlaceName_Region"]="Xak Tural",["PlaceName_Zone"]="Xak Tural",["PlaceName"]="Origenics",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1209"]={["PlaceName_Region"]="Yok Tural",["PlaceName_Zone"]="Yok Tural",["PlaceName"]="Cenote Ja Ja Gural",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1222"]={["PlaceName_Region"]="Yok Tural",["PlaceName_Zone"]="Yok Tural",["PlaceName"]="Skydeep Cenote Inner Chamber",["Mount"]=false,["Aetheryte"]="Iq Br'aax",["Flight"]=false},["1223"]={["PlaceName_Region"]="Xak Tural",["PlaceName_Zone"]="Xak Tural",["PlaceName"]="Tritails Training",["Mount"]=false,["Aetheryte"]="Solution Nine",["Flight"]=false},["1224"]={["PlaceName_Region"]="Xak Tural",["PlaceName_Zone"]="Xak Tural",["PlaceName"]="Greenroom",["Mount"]=false,["Aetheryte"]="Solution Nine",["Flight"]=false},["1225"]={["PlaceName_Region"]="Xak Tural",["PlaceName_Zone"]="Xak Tural",["PlaceName"]="Scratching Ring",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1227"]={["PlaceName_Region"]="Xak Tural",["PlaceName_Zone"]="Xak Tural",["PlaceName"]="Lovely Lovering",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1229"]={["PlaceName_Region"]="Xak Tural",["PlaceName_Zone"]="Xak Tural",["PlaceName"]="Blasting Ring",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1231"]={["PlaceName_Region"]="Xak Tural",["PlaceName_Zone"]="Xak Tural",["PlaceName"]="The Thundering",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1233"]={["PlaceName_Region"]="The Black Shroud",["PlaceName_Zone"]="The Black Shroud",["PlaceName"]="Manor Basement",["Mount"]=false,["Aetheryte"]="",["Flight"]=true},["1234"]={["PlaceName_Region"]="???",["PlaceName_Zone"]="",["PlaceName"]="Dreamlike Palace",["Mount"]=false,["Aetheryte"]="",["Flight"]=true}}

-- Usage: FindZoneID("Limsa Lominsa Lower Decks")
--
-- returns the id of the zone you search for, if the search is vague enough it'll return any of the ones that it finds, so try to be specific
function FindZoneID(zone)
    local zone = zone or ZoneList[""..GetZoneID()..""]["PlaceName"]
    local searchLower = zone:lower()
    for id, entry in pairs(ZoneList) do
        local placeName = entry["PlaceName"]
        if placeName then
            if placeName:lower():find(searchLower) then
                return id
            end
        end
    end
    return 0
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
-- ZoneTransitions() not required
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
    if GetCharacterCondition(4) then
        repeat
            yield("/mount")
            Sleep(0.1)
        until not GetCharacterCondition(4)
    end
    
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting()
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

-- Usage: IsHuntLogComplete("Arcanist1") or IsHuntLogComplete("Maelstrom2")
-- Checks if player has the hunt log rank completed
function IsHuntLogComplete()
    -- stuff can go here
    -- check if the entire rank is done
end

-- Usage: GetPlayerJobLevel() // GetPlayerJobLevel("WAR") // GetPlayerJobLevel(11)
-- Returns current player job level, can specify job to check, even id if you really want to be cursed
function GetPlayerJobLevel(job)
    local job = job or GetClassJobId()
    if type(job) == "string" then
        local function findJobXPByAbbreviation(abbreviation)
            for index, job in ipairs(Joblist) do
                if job["Abbreviation"] == abbreviation then
                    return GetLevel(job["ExpArrayIndex"])
                end
            end
            return "Unknown job"
        end
        return findJobXPByAbbreviation(job) or "Unknown job"
    elseif type(job) ~= nil then
        return GetLevel(Joblist[job]["ExpArrayIndex"])
    end
end
