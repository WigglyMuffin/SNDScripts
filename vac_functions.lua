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
-- Full zone ID list
-- Maybe convert job IDs to csv
-- Dungeon ID list
-- Distance stuff
-- Redo Teleporter()
-- Redo Movement()
-- Redo ZoneCheck()
-- IsQuestNameAccepted() see below
-- IsHuntLogComplete() see below
-- Add to GetPlayerJob() to include job xp IDs
-- GetPlayerJobLevel() see below

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

-- Usage: ZoneCheck(129) or ZoneCheck(129, "Limsa", "tp")
-- This will need updating once we have an idea on what to do with matching zones IDs to zone names
-- Checks player against zone, and optionally teleports if player not in zone
-- TP location and TP kind not required
-- ZoneTransitions() not required
function ZoneCheck(zone_id, location, tp_kind)
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26) and not GetCharacterCondition(32)

    if GetZoneID() ~= zone_id then
        if location and tp_kind then
            Teleporter(location, tp_kind)
            ZoneTransitions()
        end
        return true -- Returns true, and once teleport has happened if teleport args were passed
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
    if GetTargetHP() > 0 and dist_to_target <= radius then
        if GetCharacterCondition(4) then
            repeat
                yield("/mount")
                Sleep(0.1)
            until not GetCharacterCondition(4)
        end
        
        yield("/rotation manual")
        
        repeat
            if not PathIsRunning() then
                yield("/vnavmesh movetarget")
            end
            yield('/ac "Auto-attack"')
            Sleep(0.1)
        until (GetDistanceToTarget() <= 2 and IsTargetInCombat() and GetCharacterCondition(26)) or GetTargetHP() <= 0
        
        yield("/vnavmesh stop")
    end
    
    repeat
        Sleep(0.1)
    until GetTargetHP() == 0 or not GetTargetHP()
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
        
        Sleep(0.1)
        
        if IsAddonReady("SelectYesno") then
            repeat
                yield("/pcall SelectYesno true 0")
                Sleep(0.1)  
            until not IsAddonVisible("SelectYesno")
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

Zones={["129"]="Limsa Lominsa Lower Decks",["130"]="Ul'dah - Steps of Nald",["131"]="Ul'dah - Steps of Thal",["132"]="New Gridania",["133"]="Old Gridania",["134"]="Middle La Noscea",["135"]="Lower La Noscea",["136"]="Mist",["137"]="Eastern La Noscea",["138"]="Western La Noscea",["139"]="Upper La Noscea",["140"]="Western Thanalan",["141"]="Central Thanalan",["142"]="Halatali",["143"]="",["144"]="The Gold Saucer",["145"]="Eastern Thanalan",["146"]="Southern Thanalan",["147"]="Northern Thanalan",["148"]="Central Shroud",["149"]="The Feasting Grounds",["150"]="",["151"]="The World of Darkness",["152"]="East Shroud",["153"]="South Shroud",["154"]="North Shroud",["155"]="Coerthas Central Highlands",["156"]="Mor Dhona",["157"]="",["158"]="",["159"]="The Wanderer's Palace",["160"]="Pharos Sirius",["161"]="",["162"]="Halatali",["163"]="The Sunken Temple of Qarn",["164"]="",["166"]="",["167"]="Amdapor Keep",["168"]="",["169"]="",["170"]="Cutter's Cry",["171"]="Dzemael Darkhold",["172"]="Aurum Vale",["174"]="Labyrinth of the Ancients",["175"]="",["176"]="Mordion Gaol",["177"]="Mizzenmast Inn",["178"]="The Hourglass",["179"]="The Roost",["180"]="Outer La Noscea",["181"]="Limsa Lominsa",["182"]="Ul'dah - Steps of Nald",["183"]="New Gridania",["184"]="",["185"]="",["186"]="",["187"]="",["188"]="The Wanderer's Palace",["189"]="Amdapor Keep",["190"]="Central Shroud",["191"]="East Shroud",["192"]="South Shroud",["193"]="IC-06 Central Decks",["194"]="IC-06 Regeneration Grid",["195"]="IC-06 Main Bridge",["196"]="The Burning Heart",["197"]="",["198"]="Command Room",["199"]="",["200"]="",["201"]="",["202"]="",["203"]="",["204"]="Seat of the First Bow",["205"]="Lotus Stand",["206"]="",["207"]="",["208"]="",["209"]="",["210"]="Heart of the Sworn",["211"]="",["212"]="The Waking Sands",["213"]="",["214"]="Middle La Noscea",["215"]="Western Thanalan",["216"]="Central Thanalan",["217"]="",["218"]="",["219"]="Central Shroud",["220"]="South Shroud",["221"]="Upper La Noscea",["222"]="Lower La Noscea",["223"]="Coerthas Central Highlands",["224"]="",["225"]="Central Shroud",["226"]="Central Shroud",["227"]="Central Shroud",["228"]="North Shroud",["229"]="South Shroud",["230"]="Central Shroud",["231"]="South Shroud",["232"]="South Shroud",["233"]="Central Shroud",["234"]="East Shroud",["235"]="South Shroud",["236"]="South Shroud",["237"]="Central Shroud",["238"]="Old Gridania",["239"]="Central Shroud",["240"]="North Shroud",["241"]="Upper Aetheroacoustic Exploratory Site",["242"]="Lower Aetheroacoustic Exploratory Site",["243"]="The Ragnarok",["244"]="Ragnarok Drive Cylinder",["245"]="Ragnarok Central Core",["246"]="IC-04 Main Bridge",["247"]="Ragnarok Main Bridge",["248"]="Central Thanalan",["249"]="Lower La Noscea",["250"]="Wolves' Den Pier",["251"]="Ul'dah - Steps of Nald",["252"]="Middle La Noscea",["253"]="Central Thanalan",["254"]="Ul'dah - Steps of Nald",["255"]="Western Thanalan",["256"]="Eastern Thanalan",["257"]="Eastern Thanalan",["258"]="Central Thanalan",["259"]="Ul'dah - Steps of Nald",["260"]="Southern Thanalan",["261"]="Southern Thanalan",["262"]="Lower La Noscea",["263"]="Western La Noscea",["264"]="Lower La Noscea",["265"]="Lower La Noscea",["266"]="Eastern Thanalan",["267"]="Western Thanalan",["268"]="Eastern Thanalan",["269"]="Western Thanalan",["270"]="Central Thanalan",["271"]="Central Thanalan",["272"]="Middle La Noscea",["273"]="Western Thanalan",["274"]="Ul'dah - Steps of Nald",["275"]="Eastern Thanalan",["276"]="Hall of Summoning",["277"]="East Shroud",["278"]="Western Thanalan",["279"]="Lower La Noscea",["280"]="Western La Noscea",["281"]="The Whorleater",["282"]="Private Cottage - Mist",["283"]="Private House - Mist",["284"]="Private Mansion - Mist",["285"]="Middle La Noscea",["286"]="Rhotano Sea",["287"]="Lower La Noscea",["288"]="Rhotano Sea",["289"]="East Shroud",["290"]="East Shroud",["291"]="South Shroud",["292"]="Bowl of Embers",["293"]="The Navel",["294"]="The Howling Eye",["295"]="Bowl of Embers",["296"]="The Navel",["297"]="The Howling Eye",["298"]="Coerthas Central Highlands",["299"]="Mor Dhona",["300"]="Mor Dhona",["301"]="Coerthas Central Highlands",["302"]="Coerthas Central Highlands",["303"]="East Shroud",["304"]="Coerthas Central Highlands",["305"]="Mor Dhona",["306"]="Southern Thanalan",["307"]="Lower La Noscea",["308"]="Mor Dhona",["309"]="Mor Dhona",["310"]="Eastern La Noscea",["311"]="Eastern La Noscea",["312"]="Southern Thanalan",["313"]="Coerthas Central Highlands",["314"]="Central Thanalan",["315"]="Mor Dhona",["316"]="Coerthas Central Highlands",["317"]="South Shroud",["318"]="Southern Thanalan",["319"]="Central Shroud",["320"]="Central Shroud",["321"]="North Shroud",["322"]="Coerthas Central Highlands",["323"]="Southern Thanalan",["324"]="North Shroud",["325"]="Outer La Noscea",["326"]="Mor Dhona",["327"]="Eastern La Noscea",["328"]="Upper La Noscea",["329"]="The Wanderer's Palace",["330"]="Western La Noscea",["331"]="The Howling Eye",["332"]="",["333"]="",["334"]="",["335"]="Mor Dhona",["336"]="",["337"]="",["338"]="Eorzean Subterrane",["339"]="Mist",["340"]="The Lavender Beds",["341"]="The Goblet",["342"]="Private Cottage - The Lavender Beds",["343"]="Private House - The Lavender Beds",["344"]="Private Mansion - The Lavender Beds",["345"]="Private Cottage - The Goblet",["346"]="Private House - The Goblet",["347"]="Private Mansion - The Goblet",["348"]="Porta Decumana",["349"]="Copperbell Mines",["350"]="Haukke Manor",["351"]="The Rising Stones",["352"]="",["353"]="Kugane Ohashi",["354"]="The Dancing Plague",["355"]="Dalamud's Shadow",["356"]="The Outer Coil",["357"]="Central Decks",["358"]="The Holocharts",["359"]="The Whorleater",["360"]="Halatali",["361"]="Hullbreaker Isle",["362"]="Brayflox's Longstop",["363"]="The Lost City of Amdapor",["364"]="Thornmarch",["365"]="Stone Vigil",["366"]="Griffin Crossing",["367"]="The Sunken Temple of Qarn",["368"]="The Weeping Saint",["369"]="Hall of the Bestiarii",["370"]="Main Bridge",["371"]="",["372"]="Syrcus Tower",["373"]="The Tam-Tara Deepcroft",["374"]="The Striking Tree",["375"]="The Striking Tree",["376"]="Carteneau Flats: Borderland Ruins",["377"]="Akh Afah Amphitheatre",["378"]="Akh Afah Amphitheatre",["379"]="Mor Dhona",["380"]="Dalamud's Shadow",["381"]="The Outer Coil",["382"]="Central Decks",["383"]="The Holocharts",["384"]="Private Chambers - Mist",["385"]="Private Chambers - The Lavender Beds",["386"]="Private Chambers - The Goblet",["387"]="Sastasha",["388"]="Chocobo Square",["389"]="Chocobo Square",["390"]="Chocobo Square",["391"]="Chocobo Square",["392"]="Sanctum of the Twelve",["393"]="Sanctum of the Twelve",["394"]="South Shroud",["395"]="Intercessory",["396"]="Amdapor Keep",["397"]="Coerthas Western Highlands",["398"]="The Dravanian Forelands",["399"]="The Dravanian Hinterlands",["400"]="The Churning Mists",["401"]="The Sea of Clouds",["402"]="Azys Lla",["403"]="Ala Mhigo",["404"]="Limsa Lominsa Lower Decks",["405"]="Western La Noscea",["406"]="Western La Noscea",["407"]="Rhotano Sea",["408"]="Eastern La Noscea",["409"]="Limsa Lominsa Upper Decks",["410"]="Northern Thanalan",["411"]="Eastern La Noscea",["412"]="Upper La Noscea",["413"]="Western La Noscea",["414"]="Eastern La Noscea",["415"]="Lower La Noscea",["416"]="",["417"]="Chocobo Square",["418"]="Foundation",["419"]="The Pillars",["420"]="Neverreap",["421"]="",["422"]="",["423"]="Company Workshop - Mist",["424"]="Company Workshop - The Goblet",["425"]="Company Workshop - The Lavender Beds",["426"]="The Chrysalis",["427"]="Saint Endalim's Scholasticate",["428"]="Seat of the Lord Commander",["429"]="Cloud Nine",["430"]="The Fractal Continuum",["431"]="Seal Rock",["432"]="Thok ast Thok",["433"]="Fortemps Manor",["434"]="Dusk Vigil",["435"]="",["436"]="The Limitless Blue",["437"]="Singularity Reactor",["438"]="",["439"]="The Lightfeather Proving Grounds",["440"]="Ruling Chamber",["441"]="",["442"]="The Fist of the Father",["443"]="The Cuff of the Father",["444"]="The Arm of the Father",["445"]="The Burden of the Father",["446"]="Thok ast Thok",["447"]="The Limitless Blue",["448"]="Singularity Reactor",["449"]="The Fist of the Father",["450"]="The Cuff of the Father",["451"]="The Arm of the Father",["452"]="The Burden of the Father",["453"]="Western La Noscea",["454"]="Upper La Noscea",["455"]="The Sea of Clouds",["456"]="Ruling Chamber",["457"]="Akh Afah Amphitheatre",["458"]="Foundation",["459"]="Azys Lla",["460"]="Halatali",["461"]="The Sea of Clouds",["462"]="Sacrificial Chamber",["463"]="Matoya's Cave",["464"]="The Dravanian Forelands",["465"]="Eastern Thanalan",["466"]="Upper La Noscea",["467"]="Coerthas Western Highlands",["468"]="Coerthas Central Highlands",["469"]="Coerthas Central Highlands",["470"]="Coerthas Western Highlands",["471"]="Eastern La Noscea",["472"]="Coerthas Western Highlands",["473"]="South Shroud",["474"]="Limsa Lominsa Upper Decks",["475"]="Coerthas Central Highlands",["476"]="The Dravanian Hinterlands",["477"]="Coerthas Western Highlands",["478"]="Idyllshire",["479"]="Coerthas Western Highlands",["480"]="Mor Dhona",["481"]="The Dravanian Forelands",["482"]="The Dravanian Forelands",["483"]="Northern Thanalan",["484"]="Lower La Noscea",["485"]="The Dravanian Hinterlands",["486"]="Outer La Noscea",["487"]="Coerthas Central Highlands",["488"]="Coerthas Central Highlands",["489"]="Coerthas Western Highlands",["490"]="Hullbreaker Isle",["491"]="Southern Thanalan",["492"]="The Sea of Clouds",["493"]="Coerthas Western Highlands",["494"]="Eastern Thanalan",["495"]="Lower La Noscea",["496"]="Coerthas Central Highlands",["497"]="Coerthas Western Highlands",["498"]="Coerthas Western Highlands",["499"]="The Pillars",["500"]="Coerthas Central Highlands",["501"]="The Churning Mists",["502"]="Carteneau Flats: Borderland Ruins",["503"]="The Dravanian Hinterlands",["504"]="The Eighteenth Floor",["505"]="Alexander",["506"]="Chocobo Square",["507"]="Central Azys Lla",["508"]="Void Ark",["509"]="The Gilded Araya",["510"]="Pharos Sirius",["511"]="Saint Mocianne's Arboretum",["512"]="The Diadem",["513"]="The Vault",["514"]="The Diadem",["515"]="The Diadem",["516"]="",["517"]="Containment Bay S1T7",["518"]="",["519"]="The Lost City of Amdapor",["520"]="The Fist of the Son",["521"]="The Cuff of the Son",["522"]="The Arm of the Son",["523"]="The Burden of the Son",["524"]="Containment Bay S1T7",["525"]="",["526"]="",["527"]="",["528"]="",["529"]="The Fist of the Son",["530"]="The Cuff of the Son",["531"]="The Arm of the Son",["532"]="The Burden of the Son",["533"]="Coerthas Central Highlands",["534"]="Twin Adder Barracks",["535"]="Flame Barracks",["536"]="Maelstrom Barracks",["537"]="The Fold",["538"]="The Fold",["539"]="The Fold",["540"]="The Fold",["541"]="The Fold",["542"]="The Fold",["543"]="The Fold",["544"]="The Fold",["545"]="The Fold",["546"]="The Fold",["547"]="The Fold",["548"]="The Fold",["549"]="The Fold",["550"]="The Fold",["551"]="The Fold",["552"]="Western La Noscea",["553"]="Alexander",["554"]="The Fields of Glory",["555"]="",["556"]="The Weeping City of Mhach",["557"]="Hullbreaker Isle",["558"]="The Aquapolis",["559"]="Steps of Faith",["560"]="Aetherochemical Research Facility",["561"]="The Palace of the Dead",["562"]="The Palace of the Dead",["563"]="The Palace of the Dead",["564"]="The Palace of the Dead",["565"]="The Palace of the Dead",["566"]="Steps of Faith",["567"]="The Parrock",["568"]="Leofard's Chambers",["569"]="Steps of Faith",["570"]="The Palace of the Dead",["571"]="Haunted Manor",["572"]="",["573"]="Topmast Apartment Lobby",["574"]="Lily Hills Apartment Lobby",["575"]="Sultana's Breath Apartment Lobby",["576"]="Containment Bay P1T6",["577"]="Containment Bay P1T6",["578"]="The Great Gubal Library",["579"]="The Battlehall",["580"]="Eyes of the Creator",["581"]="Breath of the Creator",["582"]="Heart of the Creator",["583"]="Soul of the Creator",["584"]="Eyes of the Creator",["585"]="Breath of the Creator",["586"]="Heart of the Creator",["587"]="Soul of the Creator",["588"]="Heart of the Creator",["589"]="Chocobo Square",["590"]="Chocobo Square",["591"]="Chocobo Square",["592"]="Bowl of Embers",["593"]="The Palace of the Dead",["594"]="The Palace of the Dead",["595"]="The Palace of the Dead",["596"]="The Palace of the Dead",["597"]="The Palace of the Dead",["598"]="The Palace of the Dead",["599"]="The Palace of the Dead",["600"]="The Palace of the Dead",["601"]="The Palace of the Dead",["602"]="The Palace of the Dead",["603"]="The Palace of the Dead",["604"]="The Palace of the Dead",["605"]="The Palace of the Dead",["606"]="The Palace of the Dead",["607"]="The Palace of the Dead",["608"]="Topmast Apartment",["609"]="Lily Hills Apartment",["610"]="Sultana's Breath Apartment",["611"]="Frondale's Home for Friendless Foundlings",["612"]="The Fringes",["613"]="The Ruby Sea",["614"]="Yanxia",["615"]="",["616"]="Shisui of the Violet Tides",["617"]="Sohm Al",["618"]="",["619"]="",["620"]="The Peaks",["621"]="The Lochs",["622"]="The Azim Steppe",["623"]="Bardam's Mettle",["624"]="The Diadem",["625"]="The Diadem",["626"]="The Sirensong Sea",["627"]="Dun Scaith",["628"]="Kugane",["629"]="Bokairo Inn",["630"]="",["631"]="",["632"]="",["633"]="Carteneau Flats: Borderland Ruins",["634"]="Yanxia",["635"]="Rhalgr's Reach",["636"]="Omega Control",["637"]="Containment Bay Z1T9",["638"]="Containment Bay Z1T9",["639"]="Ruby Bazaar Offices",["640"]="The Fringes",["641"]="Shirogane",["642"]="",["643"]="",["644"]="",["645"]="",["646"]="",["647"]="The Fringes",["648"]="The Fringes",["649"]="Private Cottage - Shirogane",["650"]="Private House - Shirogane",["651"]="Private Mansion - Shirogane",["652"]="Private Chambers - Shirogane",["653"]="Company Workshop - Shirogane",["654"]="Kobai Goten Apartment Lobby",["655"]="Kobai Goten Apartment",["656"]="The Diadem",["657"]="The Ruby Sea",["658"]="The Interdimensional Rift",["659"]="Rhalgr's Reach",["660"]="Doma Castle",["661"]="Castrum Abania",["662"]="Kugane Castle",["663"]="The Temple of the Fist",["664"]="Kugane",["665"]="Kugane",["666"]="Ul'dah - Steps of Thal",["667"]="Kugane",["668"]="Eastern Thanalan",["669"]="Southern Thanalan",["670"]="The Fringes",["671"]="The Fringes",["672"]="Mor Dhona",["673"]="Sohm Al",["674"]="The Blessed Treasury",["675"]="Western La Noscea",["676"]="The Great Gubal Library",["677"]="The Blessed Treasury",["678"]="The Fringes",["679"]="The Royal Airship Landing",["680"]="The <Emphasis>Misery</Emphasis>",["681"]="The House of the Fierce",["682"]="The Doman Enclave",["683"]="The First Altar of Djanan Qhat",["684"]="The Lochs",["685"]="Yanxia",["686"]="The Lochs",["687"]="The Lochs",["688"]="The Azim Steppe",["689"]="Ala Mhigo",["690"]="The Interdimensional Rift",["691"]="Deltascape V1.0",["692"]="Deltascape V2.0",["693"]="Deltascape V3.0",["694"]="Deltascape V4.0",["695"]="Deltascape V1.0",["696"]="Deltascape V2.0",["697"]="Deltascape V3.0",["698"]="Deltascape V4.0",["699"]="Coerthas Central Highlands",["700"]="Foundation",["701"]="Seal Rock",["702"]="Aetherochemical Research Facility",["703"]="The Fringes",["704"]="Dalamud's Shadow",["705"]="Ul'dah - Steps of Thal",["706"]="Ul'dah - Steps of Thal",["707"]="The Weeping City of Mhach",["708"]="Rhotano Sea",["709"]="Coerthas Western Highlands",["710"]="Kugane",["711"]="The Ruby Sea",["712"]="The Lost Canals of Uznair",["713"]="The Azim Steppe",["714"]="Bardam's Mettle",["715"]="The Churning Mists",["716"]="The Peaks",["717"]="Wolves' Den Pier",["718"]="The Azim Steppe",["719"]="Emanation",["720"]="Emanation",["721"]="Amdapor Keep",["722"]="The Lost City of Amdapor",["723"]="The Azim Steppe",["724"]="The Interdimensional Rift",["725"]="The Lost Canals of Uznair",["726"]="The Ruby Sea",["727"]="The Royal Menagerie",["728"]="Mordion Gaol",["729"]="Astragalos",["730"]="Transparency",["731"]="The Drowned City of Skalla",["732"]="Eureka Anemos",["733"]="The Binding Coil of Bahamut",["734"]="The Royal City of Rabanastre",["735"]="The <Emphasis>Prima Vista</Emphasis> Tiring Room",["736"]="The <Emphasis>Prima Vista</Emphasis> Bridge",["737"]="Royal Palace",["738"]="The Resonatorium",["739"]="The Doman Enclave",["740"]="The Royal Menagerie",["741"]="Sanctum of the Twelve",["742"]="Hells' Lid",["743"]="The Fractal Continuum",["744"]="Kienkan",["745"]="",["746"]="The Jade Stoa",["747"]="",["748"]="Sigmascape V1.0",["749"]="Sigmascape V2.0",["750"]="Sigmascape V3.0",["751"]="Sigmascape V4.0",["752"]="Sigmascape V1.0",["753"]="Sigmascape V2.0",["754"]="Sigmascape V3.0",["755"]="Sigmascape V4.0",["756"]="The Interdimensional Rift",["757"]="The Ruby Sea",["758"]="The Jade Stoa",["759"]="The Doman Enclave",["760"]="The Fringes",["761"]="The Great Hunt",["762"]="The Great Hunt",["763"]="Eureka Pagos",["764"]="Reisen Temple",["765"]="",["766"]="",["767"]="",["768"]="The Swallow's Compass",["769"]="The Burn",["770"]="Heaven-on-High",["771"]="Heaven-on-High",["772"]="Heaven-on-High",["773"]="Heaven-on-High",["774"]="Heaven-on-High",["775"]="Heaven-on-High",["776"]="The Ridorana Lighthouse",["777"]="Ultimacy",["778"]="Castrum Fluminis",["779"]="Castrum Fluminis",["780"]="Heaven-on-High",["781"]="Reisen Temple Road",["782"]="Heaven-on-High",["783"]="Heaven-on-High",["784"]="Heaven-on-High",["785"]="Heaven-on-High",["786"]="Castrum Fluminis",["787"]="The Ridorana Cataract",["788"]="Saint Mocianne's Arboretum",["789"]="The Burn",["790"]="Ul'dah - Steps of Nald",["791"]="Hidden Gorge",["792"]="The Fall of Belah'dia",["793"]="The Ghimlyt Dark",["794"]="The Shifting Altars of Uznair",["795"]="Eureka Pyros",["796"]="Blue Sky",["797"]="The Azim Steppe",["798"]="Psiscape V1.0",["799"]="Psiscape V2.0",["800"]="The Interdimensional Rift",["801"]="The Interdimensional Rift",["802"]="Psiscape V1.0",["803"]="Psiscape V2.0",["804"]="The Interdimensional Rift",["805"]="The Interdimensional Rift",["806"]="Kugane Ohashi",["807"]="The Interdimensional Rift",["808"]="The Interdimensional Rift",["809"]="Haunted Manor",["810"]="Hells' Kier",["811"]="Hells' Kier",["812"]="The Interdimensional Rift",["813"]="Lakeland",["814"]="Kholusia",["815"]="Amh Araeng",["816"]="Il Mheg",["817"]="The Rak'tika Greatwood",["818"]="The Tempest",["819"]="The Crystarium",["820"]="Eulmore",["821"]="Dohn Mheg",["822"]="Mt. Gulg",["823"]="The Qitana Ravel",["824"]="The Wreath of Snakes",["825"]="The Wreath of Snakes",["826"]="The Orbonne Monastery",["827"]="Eureka Hydatos",["828"]="The <Emphasis>Prima Vista</Emphasis> Tiring Room",["829"]="Eorzean Alliance Headquarters",["830"]="The Ghimlyt Dark",["831"]="The Manderville Tables",["832"]="The Gold Saucer",["833"]="The Howling Eye",["834"]="The Howling Eye",["835"]="",["836"]="Malikah's Well",["837"]="Holminster Switch",["838"]="Amaurot",["839"]="East Shroud",["840"]="The Twinning",["841"]="Akadaemia Anyder",["842"]="The Syrcus Trench",["843"]="The Pendants Personal Suite",["844"]="The Ocular",["845"]="The Dancing Plague",["846"]="The Crown of the Immaculate",["847"]="The Dying Gasp",["848"]="The Crown of the Immaculate",["849"]="The Core",["850"]="The Halo",["851"]="The Nereus Trench",["852"]="Atlas Peak",["853"]="The Core",["854"]="The Halo",["855"]="The Nereus Trench",["856"]="Atlas Peak",["857"]="The Core",["858"]="The Dancing Plague",["859"]="The Confessional of Toupasa the Elder",["860"]="Amh Araeng",["861"]="Lakeland",["862"]="Lakeland",["863"]="Eulmore",["864"]="Kholusia",["865"]="Old Gridania",["866"]="Coerthas Western Highlands",["867"]="Eastern La Noscea",["868"]="The Peaks",["869"]="Il Mheg",["870"]="Kholusia",["871"]="The Rak'tika Greatwood",["872"]="Amh Araeng",["873"]="The Dancing Plague",["874"]="The Rak'tika Greatwood",["875"]="The Rak'tika Greatwood",["876"]="The Nabaath Mines",["877"]="Lakeland",["878"]="The Empty",["879"]="The Dungeons of Lyhe Ghiah",["880"]="The Crown of the Immaculate",["881"]="The Dying Gasp",["882"]="The Copied Factory",["883"]="",["884"]="The Grand Cosmos",["885"]="The Dying Gasp",["886"]="The Firmament",["887"]="Liminal Space",["888"]="Onsal Hakair",["889"]="Lyhe Mheg",["890"]="Lyhe Mheg",["891"]="Lyhe Mheg",["892"]="Lyhe Mheg",["893"]="The Imperial Palace",["894"]="Lyhe Mheg",["895"]="Excavation Tunnels",["896"]="The Copied Factory",["897"]="Cinder Drift",["898"]="Anamnesis Anyder",["899"]="The Falling City of Nym",["900"]="The <Emphasis>Endeavor</Emphasis>",["901"]="The Diadem",["902"]="The Gandof Thunder Plains",["903"]="Ashfall",["904"]="The Halo",["905"]="Great Glacier",["906"]="The Gandof Thunder Plains",["907"]="Ashfall",["908"]="The Halo",["909"]="Great Glacier",["910"]="",["911"]="Cid's Memory",["912"]="Cinder Drift",["913"]="Transmission Control",["914"]="Trial's Threshold",["915"]="Gangos",["916"]="The Heroes' Gauntlet",["917"]="The Puppets' Bunker",["918"]="Anamnesis Anyder",["919"]="Terncliff",["920"]="Bozjan Southern Front",["921"]="Frondale's Home for Friendless Foundlings",["922"]="The Seat of Sacrifice",["923"]="The Seat of Sacrifice",["924"]="The Shifting Oubliettes of Lyhe Ghiah",["925"]="Terncliff Bay",["926"]="Terncliff Bay",["927"]="",["928"]="The Puppets' Bunker",["929"]="The Diadem",["930"]="",["931"]="The Seat of Sacrifice",["932"]="The Tempest",["933"]="Matoya's Relict",["934"]="Castrum Marinum Drydocks",["935"]="Castrum Marinum Drydocks",["936"]="Delubrum Reginae",["937"]="Delubrum Reginae",["938"]="Paglth'an",["939"]="The Diadem",["940"]="The Battlehall",["941"]="The Battlehall",["942"]="Sphere of Naught",["943"]="Laxan Loft",["944"]="Bygone Gaol",["945"]="The Garden of Nowhere",["946"]="Sphere of Naught",["947"]="Laxan Loft",["948"]="Bygone Gaol",["949"]="The Garden of Nowhere",["950"]="G-Savior Deck",["951"]="G-Savior Deck",["952"]="The Tower of Zot",["953"]="",["954"]="The Navel",["955"]="The Last Trace",["956"]="Labyrinthos",["957"]="Thavnair",["958"]="Garlemald",["959"]="Mare Lamentorum",["960"]="Ultima Thule",["961"]="Elpis",["962"]="Old Sharlayan",["963"]="Radz-at-Han",["964"]="The Last Trace",["965"]="The Empty",["966"]="The Tower at Paradigm's Breach",["967"]="Castrum Marinum Drydocks",["968"]="Medias Res",["969"]="The Tower of Babil",["970"]="Vanaspati",["971"]="Lemures Headquarters",["972"]="",["973"]="The Dead Ends",["974"]="Ktisis Hyperboreia",["975"]="Zadnor",["976"]="Smileton",["977"]="Carteneau Flats: Borderland Ruins",["978"]="The Aitiascope",["979"]="Empyreum",["980"]="Private Cottage - Empyreum",["981"]="Private House - Empyreum",["982"]="Private Mansion - Empyreum",["983"]="Private Chambers - Empyreum",["984"]="Company Workshop - Empyreum",["985"]="Ingleside Apartment Lobby",["986"]="The Stigma Dreamscape",["987"]="Main Hall",["988"]="",["989"]="",["990"]="Andron",["991"]="G-Savior Deck",["992"]="The Dark Inside",["993"]="The Dark Inside",["994"]="The Phantoms' Feast",["995"]="The Mothercrystal",["996"]="The Mothercrystal",["997"]="The Final Day",["998"]="The Final Day",["999"]="Ingleside Apartment",["1000"]="The Excitatron 6000",["1001"]="Strategy Room",["1002"]="The Gates of Pandæmonium",["1003"]="The Gates of Pandæmonium",["1004"]="The Stagnant Limbo",["1005"]="The Stagnant Limbo",["1006"]="The Fervid Limbo",["1007"]="The Fervid Limbo",["1008"]="The Sanguine Limbo",["1009"]="The Sanguine Limbo",["1010"]="Magna Glacies",["1011"]="Garlemald",["1012"]="Magna Glacies",["1013"]="Beyond the Stars",["1014"]="Elpis",["1015"]="Central Shroud",["1016"]="Sastasha",["1017"]="The Swallow's Compass",["1018"]="The Vault",["1019"]="The Peaks",["1020"]="Cutter's Cry",["1021"]="Dusk Vigil",["1022"]="Saint Mocianne's Arboretum",["1023"]="The Dravanian Forelands",["1024"]="The Nethergate",["1025"]="The Gates of Pandæmonium",["1026"]="Beyond the Stars",["1027"]="Ultima Thule",["1028"]="The Dark Inside",["1029"]="The Final Day",["1030"]="The Mothercrystal",["1031"]="Propylaion",["1032"]="The Palaistra",["1033"]="The Volcanic Heart",["1034"]="Cloud Nine",["1035"]="",["1036"]="Sastasha",["1037"]="The Tam-Tara Deepcroft",["1038"]="Copperbell Mines",["1039"]="The Thousand Maws of Toto-Rak",["1040"]="Haukke Manor",["1041"]="Brayflox's Longstop",["1042"]="Stone Vigil",["1043"]="Castrum Meridianum",["1044"]="The Praetorium",["1045"]="Bowl of Embers",["1046"]="The Navel",["1047"]="The Howling Eye",["1048"]="Porta Decumana",["1049"]="Western Thanalan",["1050"]="Alzadaal's Legacy",["1051"]="The Tower of Babil",["1052"]="The Porta Decumana",["1053"]="The Porta Decumana",["1054"]="Aglaia",["1055"]="Unnamed Island",["1056"]="Alzadaal's Legacy",["1057"]="Restricted Archives",["1058"]="The Palaistra",["1059"]="The Volcanic Heart",["1060"]="Cloud Nine",["1061"]="The Omphalos",["1062"]="Snowcloak",["1063"]="The Keeper of the Lake",["1064"]="Sohm Al",["1065"]="The Aery",["1066"]="The Vault",["1067"]="Thornmarch",["1068"]="Steps of Faith",["1069"]="The Sil'dihn Subterrane",["1070"]="The Fell Court of Troia",["1071"]="Storm's Crown",["1072"]="Storm's Crown",["1073"]="Elysion",["1074"]="",["1075"]="Another Sil'dihn Subterrane",["1076"]="Another Sil'dihn Subterrane",["1077"]="Zero's Domain",["1078"]="Meghaduta Guest Chambers",["1079"]="The Aitiascope",["1080"]="",["1081"]="The Caustic Purgatory",["1082"]="The Caustic Purgatory",["1083"]="The Pestilent Purgatory",["1084"]="The Pestilent Purgatory",["1085"]="The Hollow Purgatory",["1086"]="The Hollow Purgatory",["1087"]="Stygian Insenescence Cells",["1088"]="Stygian Insenescence Cells",["1089"]="The Fell Court of Troia",["1090"]="",["1091"]="The Fell Court of Troia",["1092"]="Storm's Crown",["1093"]="Stygian Insenescence Cells",["1094"]="Sneaky Hollow",["1095"]="Mount Ordeals",["1096"]="Mount Ordeals",["1097"]="Lapis Manalis",["1098"]="Sylphstep",["1099"]="Eureka Orthos",["1100"]="Eureka Orthos",["1101"]="Eureka Orthos",["1102"]="Eureka Orthos",["1103"]="Eureka Orthos",["1104"]="Eureka Orthos",["1105"]="Eureka Orthos",["1106"]="Eureka Orthos",["1107"]="Eureka Orthos",["1108"]="Eureka Orthos",["1109"]="The Great Gubal Library",["1110"]="Aetherochemical Research Facility",["1111"]="The Antitower",["1112"]="Sohr Khai",["1113"]="Xelphatol",["1114"]="Baelsar's Wall",["1115"]="The Tower of Babil",["1116"]="The Clockwork Castletown",["1117"]="The Clockwork Castletown",["1118"]="Euphrosyne",["1119"]="Lapis Manalis",["1120"]="Garlemald",["1121"]="",["1122"]="The Interdimensional Rift",["1123"]="The Shifting Gymnasion Agonon",["1124"]="Eureka Orthos",["1125"]="Khadga",["1126"]="The Aetherfont",["1127"]="",["1128"]="",["1129"]="",["1130"]="",["1131"]="",["1132"]="",["1133"]="",["1134"]="",["1135"]="",["1136"]="The Gilded Araya",["1137"]="Mount Rokkon",["1138"]="The Red Sands",["1139"]="The Red Sands",["1140"]="The Voidcast Dais",["1141"]="The Voidcast Dais",["1142"]="The Sirensong Sea",["1143"]="Bardam's Mettle",["1144"]="Doma Castle",["1145"]="Castrum Abania",["1146"]="Ala Mhigo",["1147"]="The Aetherial Slough",["1148"]="The Aetherial Slough",["1149"]="The Dæmons' Nest",["1150"]="The Dæmons' Nest",["1151"]="The Chamber of Fourteen",["1152"]="The Chamber of Fourteen",["1153"]="Ascension",["1154"]="Ascension",["1155"]="Another Mount Rokkon",["1156"]="Another Mount Rokkon",["1157"]="",["1158"]="The Dæmons' Nest",["1159"]="The Voidcast Dais",["1160"]="Senatus",["1161"]="Estinien's Chambers",["1162"]="The Red Moon",["1163"]="The <Emphasis>Endeavor</Emphasis>",["1164"]="The Lunar Subterrane",["1165"]="Blunderville",["1166"]="The Memory of Embers",["1167"]="Ihuykatumu",["1168"]="The Abyssal Fracture",["1169"]="The Abyssal Fracture",["1170"]="Sunperch",["1171"]="Earthen Sky Hideout",["1172"]="The Drowned City of Skalla",["1173"]="The Burn",["1174"]="The Ghimlyt Dark",["1175"]="",["1176"]="Aloalo Island",["1177"]="The Aetherfont",["1178"]="Thaleia",["1179"]="Another Aloalo Island",["1180"]="Another Aloalo Island",["1181"]="The Abyssal Fracture",["1182"]="Thaleia",["1183"]="The Gilded Araya",["1184"]="The Lunar Subterrane",["1185"]="Tuliyollal",["1186"]="Solution Nine",["1187"]="Urqopacha",["1188"]="Kozama'uka",["1189"]="Yak T'el",["1190"]="Shaaloani",["1191"]="Heritage Found",["1192"]="Living Memory",["1193"]="Worqor Zormor",["1194"]="The Skydeep Cenote",["1195"]="Worqor Lar Dor",["1196"]="Worqor Lar Dor",["1197"]="Blunderville Square",["1198"]="Vanguard",["1199"]="Alexandria",["1200"]="Summit of Everkeep",["1201"]="Summit of Everkeep",["1202"]="Interphos",["1203"]="Tender Valley",["1204"]="Strayborough",["1205"]="The For'ard Cabins",["1206"]="Main Deck",["1207"]="The Backroom",["1208"]="Origenics",["1209"]="Cenote Ja Ja Gural",["1210"]="Sunperch",["1211"]="Yak T'el",["1212"]="Yak T'el",["1213"]="Solution Nine",["1214"]="The Sea of Clouds",["1215"]="Brayflox's Longstop",["1216"]="Bardam's Mettle",["1217"]="Ala Mhigo",["1218"]="Khadga",["1219"]="Vanguard",["1220"]="Summit of Everkeep",["1221"]="Interphos",["1222"]="Skydeep Cenote Inner Chamber",["1223"]="Tritails Training",["1224"]="Greenroom",["1225"]="Scratching Ring",["1226"]="Scratching Ring",["1227"]="Lovely Lovering",["1228"]="Lovely Lovering",["1229"]="Blasting Ring",["1230"]="Blasting Ring",["1231"]="The Thundering",["1232"]="The Thundering",["1233"]="Manor Basement",["1234"]="Dreamlike Palace",["1235"]="Central Thanalan",["1236"]="Southern Thanalan",["1237"]="",["1238"]="",["1239"]="",["1240"]="",["1241"]=""}

-- Usage: FindZoneID("Limsa Lominsa Lower Decks")
--
-- case sensitive, returns the id of the zone you search for
function FindZoneID(zone)
    for key, value in pairs(Zones) do
        if value == zone then
            return key
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

-- NEEDS excel browser adding
-- Usage: GetPlayerJob()
-- Returns the current player job abbreviation
function GetPlayerJob()
    -- Mapping for GetClassJobId()
    local job_names = {
        [0]  = "ADV", -- Adventurer
        [1]  = "GLA", -- Gladiator
        [2]  = "PGL", -- Pugilist
        [3]  = "MRD", -- Marauder
        [4]  = "LNC", -- Lancer
        [5]  = "ARC", -- Archer
        [6]  = "CNJ", -- Conjurer
        [7]  = "THM", -- Thaumaturge
        [8]  = "CRP", -- Carpenter
        [9]  = "BSM", -- Blacksmith
        [10] = "ARM", -- Armorer
        [11] = "GSM", -- Goldsmith
        [12] = "LTW", -- Leatherworker
        [13] = "WVR", -- Weaver
        [14] = "ALC", -- Alchemist
        [15] = "CUL", -- Culinarian
        [16] = "MIN", -- Miner
        [17] = "BTN", -- Botanist
        [18] = "FSH", -- Fisher
        [19] = "PLD", -- Paladin
        [20] = "MNK", -- Monk
        [21] = "WAR", -- Warrior
        [22] = "DRG", -- Dragoon
        [23] = "BRD", -- Bard
        [24] = "WHM", -- White Mage
        [25] = "BLM", -- Black Mage
        [26] = "ACN", -- Arcanist
        [27] = "SMN", -- Summoner
        [28] = "SCH", -- Scholar
        [29] = "ROG", -- Rogue
        [30] = "NIN", -- Ninja
        [31] = "MCH", -- Machinist
        [32] = "DRK", -- Dark Knight
        [33] = "AST", -- Astrologian
        [34] = "SAM", -- Samurai
        [35] = "RDM", -- Red Mage
        [36] = "BLU", -- Blue Mage
        [37] = "GNB", -- Gunbreaker
        [38] = "DNC", -- Dancer
        [39] = "RPR", -- Reaper
        [40] = "SGE", -- Sage
        [41] = "VPR", -- Viper
        [42] = "PCT"  -- Pictomancer
    }
    
    -- Find and return job ID
    local job_id = GetClassJobId()
    return job_names[job_id] or "Unknown job"
end

-- Usage: DoAction("Heavy Shot")
-- Uses specified action
function DoAction(action_name)
    yield('/ac "' .. action_name .. '"')
end

-- Usage: DoGeneralAction("Jump")
-- Uses specified general action
function DoGeneralAction(general_action_name)
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

-- Usage: GetPlayerJobLevel() or GetPlayerJobLevel("WAR")
-- Returns current player job level, can specify job to check
function GetPlayerJobLevel()
    -- stuff can go here
    -- check what player job is from classjob xp ID
    -- hook it with GetPlayerJob() for the actual jobs
    -- do when have actual classjob list from csv
end