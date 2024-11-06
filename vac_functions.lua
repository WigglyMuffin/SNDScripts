--[[ 
This file needs to be dropped inside %appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\
So it should look like this %appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\vac_functions.lua
It contains the functions required to make the scripts work

####################
##    Version     ##
##     1.0.3      ##
####################

-> 1.0.3: vac_lists should now load from the same directory as vac_functions no matter where you put it
-> 1.0.2: Minor adjustments to adress inconsistencies
-> 1.0.1: Updated UseFCAction()
-> 1.0.0: Initial release

#################
## TO DO STUFF ##
#################

EatFood() function
UseItem() function
Closest aetheryte to player and distance calculations
Add flight to Movement() function
Refactor Teleporter() function
Add fate related functions
Convert over to /callback from /pcall
Add error handling for nil/"" and convert lowercase or tostring/tonumber etc

#####################################
#####################################
#####################################
###################################]]

function LoadFileCheck()
    LogInfo("[VAC] Successfully loaded the vac functions file")
end
local function GetScriptDirectory()
    local info = debug.getinfo(2, "S")
    local path = info.source:sub(2)
    return path:match("(.*[\\/])") or "./"
end
local vac_script_directory = GetScriptDirectory()
-- this part just loads all the lists into memory to use with various functions
local vac_lists = dofile(vac_script_directory .. "vac_lists.lua")
DC_With_Worlds = vac_lists.DC_With_Worlds
Item_List = vac_lists.Item_List
Job_List = vac_lists.Job_List
Quest_List = vac_lists.Quest_List
World_ID_List = vac_lists.World_ID_List
Zone_List = vac_lists.Zone_List
GC_MIN_List = vac_lists.GC_MIN_List
GC_BTN_List = vac_lists.GC_BTN_List
GC_FSH_List = vac_lists.GC_FSH_List
Fate_List = vac_lists.Fate_List
Submersible_Part_List = vac_lists.Submersible_Part_List
Submersible_Rank_List = vac_lists.Submersible_Rank_List
Submersible_Zone_List = vac_lists.Submersible_Zone_List

-- Usage: EnsureFolderExists("\\path\\to\\your\\folder")
--
-- Call this to check if a folder exists at the path you provide, if it doesn't it'll create it
function EnsureFolderExists(folder_path)
    -- Try to create a temporary file in the folder
    local temp_file_path = folder_path .. "\\.temp_file"
    local file = io.open(temp_file_path, "w")

    -- If the file couldn't be opened, the folder doesn't exist
    if not file then
        -- Folder doesn't exist, create it silently
        io.popen('mkdir "' .. folder_path .. '"'):close()
    else
        -- Folder exists, close and remove the temporary file
        file:close()
        os.remove(temp_file_path)
    end
end


-- InteractAndWait()
--
-- Interacts with the current target and waits until the player is available again before proceeding
function InteractAndWait()
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)

    Dismount()
    Sleep(0.5)
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
    Sleep(0.5)
    yield("/interact")

    repeat
        Sleep(0.1)
    until not IsPlayerCasting()
end

-- Usage: AttuneAetheryte()
-- Attunes with the Aetheryte, exits out of menus if already attuned
function AttuneAetheryte()
    -- Wait until the player is ready to interact
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26) and not IsMoving() and not (GetCharacterCondition(45) or GetCharacterCondition(51))

    -- Target and interact with the Aetheryte
    Target("Aetheryte")
    Sleep(0.1)
    Interact()

    -- If the player is already attuned, exit the menu
    if (GetCharacterCondition(31) or GetCharacterCondition(32)) and IsAddonVisible("SelectString") then
        repeat
            Sleep(0.1)
        until IsAddonVisible("SelectString")

        Sleep(0.5)
        yield("/pcall SelectString true 3")

        -- Wait until the menu is no longer visible
        repeat
            Sleep(0.1)
        until not IsAddonVisible("SelectString")
    end

    -- Wait until player is available
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not (GetCharacterCondition(31) or GetCharacterCondition(32))
    
    Sleep(1.0)
end

-- Usage: IsInParty()
-- Checks if player is in a party, returns true if in party, returns false if not in party
function IsInParty()
    return GetPartyMemberName(0) ~= nil and GetPartyMemberName(0) ~= "" and not GetCharacterCondition(45)
end

-- Usage: ZoneCheck("Limsa Lominsa Lower Decks")
--
-- Checks if you're currently in the provided zone, you can supply zone name or aetheryte name
function ZoneCheck(zone_name)
    local zone_id = FindZoneID(zone_name)
    if zone_id == nil then
        zone_id = FindZoneIDByAetheryte(zone_name)
    end
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26) and not GetCharacterCondition(32)

    if GetZoneID() == zone_id then
        return true  -- Returns true if zone matches
    else
        return false -- Returns false if zone doesn't match
    end
end

-- Usage: Echo("meow")
--
-- prints provided text into chat
function Echo(text)
    yield("/echo " .. tostring(text))
end

-- Usage: Sleep(0.1) or Sleep("0.1")
--
-- replaces yield wait spam, halts the script for X seconds
function Sleep(time)
    yield("/wait " .. tostring(time))
end

-- Usage: ZoneTransitions()
-- Zone transition checker, used if you need to path between two zones and waits until player is available
function ZoneTransitions()
    -- Wait for a zone transition to complete
    repeat
        Sleep(0.1)
    until (GetCharacterCondition(45) or GetCharacterCondition(51))

    -- Once zone change has happened, wait until the conditions turn false
    repeat
        Sleep(0.1)
    until not (GetCharacterCondition(45) and GetCharacterCondition(51)) and IsPlayerAvailable()
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
                Sleep(0.1)
            until IsAddonVisible(DialogueType)

            yield("/pcall " .. DialogueType .. " true 0")

            repeat
                Sleep(0.1)
            until not IsAddonVisible(DialogueType)
        else
            repeat
                Sleep(0.1)
            until IsAddonVisible(DialogueType)

            yield("/pcall " .. DialogueType .. " true " .. DialogueOption)

            repeat
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

-- Usage: FindNearestObject("Heckler Imp")
--
-- Returns the XYZ coordinates of the nearest object with that name
function FindNearestObject(object_name)
    local object_x_pos = GetObjectRawXPos(object_name)
    local object_y_pos = GetObjectRawYPos(object_name)
    local object_z_pos = GetObjectRawZPos(object_name)

    if object_x_pos == 0.0 and object_y_pos == 0.0 and object_z_pos == 0.0 then
        return nil, nil, nil
    else
        return object_x_pos, object_y_pos, object_z_pos
    end
end

-- Usage: TargetNearestEnemy("Heckler Imp", 20)
--
-- Targets the nearest enemy of the name you supply, within the radius
function TargetNearestEnemy(target_name, radius)
    local smallest_distance = 10000000000000.0
    local closest_target
    local objectKind = 0                                                                             -- Set objectkind to 0 so GetNearbyObjectNames pulls everything nearby
    local radius = radius or 0
    local nearby_objects = GetNearbyObjectNames(radius ^ 2, objectKind)                              -- Pull all nearby objects/enemies into a list
    if nearby_objects.Count > 0 then                                                                 -- Starts a loop if there's more than 0 nearby objects
        for i = 0, nearby_objects.Count - 1 do                                                       -- loops until no more objects
            yield("/target " .. nearby_objects[i])
            if not GetTargetName() or nearby_objects[i] ~= GetTargetName() then                      -- If target name is nil, skip it
            elseif GetDistanceToTarget() < smallest_distance and GetTargetName() == target_name then -- if object matches the target_name and the distance to target is smaller than the current smallest_distance, proceed
                smallest_distance = GetDistanceToTarget()
                closest_target = GetTargetName()
            end
        end
        ClearTarget()
        if closest_target then yield("/target " .. closest_target) end -- after the loop ends it targets the closest enemy
    end
    return closest_target
end

-- Usage: FindDistanceToObject("Goblin")
--
-- Returns the distance from the player to an object
function FindDistanceToObject(object_name)
    local object_x_pos = GetObjectRawXPos(object_name)
    local object_y_pos = GetObjectRawYPos(object_name)
    local object_z_pos = GetObjectRawZPos(object_name)

    local function floor_position(pos)
        return math.floor(pos + 0.5)
    end

    local object_x_position_floored = floor_position(object_x_pos)
    local object_y_position_floored = floor_position(object_y_pos)
    local object_z_position_floored = floor_position(object_z_pos)

    local xpos = floor_position(GetPlayerRawXPos())
    local ypos = floor_position(GetPlayerRawYPos())
    local zpos = floor_position(GetPlayerRawZPos())

    local function DistanceToTarget(xpos, ypos, zpos)
        return math.sqrt(
            (xpos - object_x_position_floored) ^ 2 +
            (ypos - object_y_position_floored) ^ 2 +
            (zpos - object_z_position_floored) ^ 2
        )
    end

    local distance_to_object = DistanceToTarget(xpos, ypos, zpos)

    return distance_to_object
end

-- Usage: FindDistanceToPos(x, y, z)
--
-- Returns the distance from the player to a position
function FindDistanceToPos(pos_x, pos_y, pos_z)
    local function floor_position(pos)
        return math.floor(pos + 0.5)
    end

    local object_x_position_floored = floor_position(pos_x)
    local object_y_position_floored = floor_position(pos_y)
    local object_z_position_floored = floor_position(pos_z)

    local xpos = floor_position(GetPlayerRawXPos())
    local ypos = floor_position(GetPlayerRawYPos())
    local zpos = floor_position(GetPlayerRawZPos())

    local function DistanceToTarget(xpos, ypos, zpos)
        return math.sqrt(
            (xpos - object_x_position_floored) ^ 2 +
            (ypos - object_y_position_floored) ^ 2 +
            (zpos - object_z_position_floored) ^ 2
        )
    end

    local distance_to_object = DistanceToTarget(xpos, ypos, zpos)

    return distance_to_object
end

-- Usage: FindAndKillTarget("Heckler Imp", 20)
--
-- Uses TargetNearestEnemy() to find and kill the provided target within the specified target_radius
function FindAndKillTarget(target_name, target_radius)
    local target_radius = target_radius or 100
    local auto_attack_triggered = false
    local target_x_pos, target_y_pos, target_z_pos = FindNearestObject(target_name)
    
    if target_x_pos == nil then
        return
    end
    
    local distance_to_target = FindDistanceToPos(target_x_pos, target_y_pos, target_z_pos)
    if distance_to_target > target_radius then
        return
    end
    
    -- Determine the attack range based on the current job
    local current_job = GetPlayerJob()
    local attack_range = 3.5
    if current_job == "ARC" or current_job == "BRD" or current_job == "MCH" or current_job == "DNC" then
        attack_range = 10
    end
    
    Movement(target_x_pos, target_y_pos, target_z_pos, attack_range)
    TargetNearestEnemy(target_name, target_radius)
    local dist_to_target = GetDistanceToTarget()
    
    while GetTargetHP() > 0 and dist_to_target <= target_radius do
        if GetCharacterCondition(4) then
            repeat
                Dismount()
                Sleep(0.1)
            until not GetCharacterCondition(4)
        end
        
        yield("/rotation manual")
        
        repeat
            if (GetDistanceToTarget() <= attack_range) and PathIsRunning() then
                yield("/vnav stop")
            end
            
            if not (GetDistanceToTarget() <= attack_range) and not PathIsRunning() then
                if not auto_attack_triggered then
                    yield("/vnavmesh movetarget")
                    Sleep(0.1)
                end
            end
            
            if GetDistanceToTarget() <= attack_range and not auto_attack_triggered then
                DoAction("Auto-attack")
                Sleep(0.1)
                if IsTargetInCombat() and GetCharacterCondition(26) then
                    auto_attack_triggered = true
                end
            end
            
            Sleep(0.05)
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
        LogInfo("[VAC] GetNodeTextLookupUpdate: " .. get_node_text_type .. " " .. get_node_text_location .. " " .. get_node_text_location_1)
            get_node_text = GetNodeText(get_node_text_type, get_node_text_location, get_node_text_location_1)
        if get_node_text == get_node_text_location_1 then
            return bypass
        else
            return get_node_text
        end
        --- i hate
    else
        LogInfo("[VAC] GetNodeTextLookupUpdate2: " .. get_node_text_type .. " " .. get_node_text_location .. " " .. get_node_text_location_1 .. " " .. get_node_text_location_2)
        get_node_text = GetNodeText(get_node_text_type, get_node_text_location, get_node_text_location_1,get_node_text_location_2)
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
        LogInfo("[VAC] updated_node_text: " .. updated_node_text)
        LogInfo("[VAC] Extract: " .. extractTask(updated_node_text))
        local last_char = string.sub(updated_node_text, -1)
        LogInfo("[VAC] last char: " .. updated_node_text)
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
                --LogInfo([VAC] tostring(clean_node_text))
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
                    --LogInfo([VAC] tostring(clean_node_text))
                end
                if clean_node_text == get_node_text_match then
                    return location, sub_node, sub_node2
                end
            end
        end
    end
end

-- Usage: OpenHuntLog(9, 0), Defaults to rank 0 if empty
-- Valid classes: 0 = GLA, 1 = PGL, 2 = MRD, 3 = LNC, 4 = ARC, 5 = ROG, 6 = CNJ, 7 = THM, 8 = ACN, 9 = GC
-- Valid ranks/pages: 0-4 for jobs, 0-2 for GC
-- Valid show: 0 = show all, 1 = show complete, 2 = show incomplete
-- The first variable is the class to open, the second is the rank to open
function OpenHuntLog(class, rank, show)
    local defaultshow = 2
    local defaultrank = 0  --
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
        yield("/pcall MonsterNote false 3 9 " .. tostring(gc_id))
    else
        yield("/pcall MonsterNote false 0 " .. tostring(class))
    end

    Sleep(0.3)
    yield("/pcall MonsterNote false 1 " .. rank)
    Sleep(0.3)
    yield("/pcall MonsterNote false 2 " .. show)
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
function HuntLogCheck(target_name, class, rank)
    OpenHuntLog(class, rank, 2)
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
        LogInfo("[VAC] Couldn't find " .. target_name .. " in hunting log, likely already finished")
        return false, 0
    else
        LogInfo("[VAC] Found " .. target_name .. " in hunting log, time to hunt")
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
    local TargetsLeft, AmountLeft = HuntLogCheck(target_name, class, rank)

    if AmountLeft > 0 and TargetsLeft then
        while not finished do
            if AmountLeft > 0 then
                repeat
                    FindAndKillTarget(target_name, target_distance)
                    AmountLeft = AmountLeft - 1
                    Sleep(3)
                until AmountLeft == 0
            end
            TargetsLeft, AmountLeft = HuntLogCheck(target_name, class, rank)
            if AmountLeft == 0 then
                finished = true
            end
        end

        if not GetCharacterCondition(26) then
            yield("/rotation off")
        end
    end
end

-- Usage: Teleporter("Limsa", "tp") or Teleporter("gc", "li") or Teleporter("Vesper", "item")
-- Options: location = teleport location, tp_kind = tp, li, item
-- Will teleport player to specified location
function Teleporter(location, tp_kind) -- Teleporter handler
    tp_kind = string.lower(tp_kind)
    local cast_time_buffer = 5         -- Just in case a buffer is required, teleports are 5 seconds long. Slidecasting, ping and fps can affect casts
    local max_retries = 10             -- Teleporter retry amount, will not tp after number has been reached for safety
    local retries = 0

    -- Initial check to ensure player can teleport
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26) and not GetCharacterCondition(32) -- 26 is combat, 32 is quest event

    -- Try teleport, retry until max_retries is reached
    if tp_kind == "tp" then
        while retries < max_retries do
            -- Stop lifestream only once per teleport attempt
            if FindZoneIDByAetheryte(location) == GetZoneID() then
                LogInfo("[VAC] Already in the right zone")
                break
            end

            -- Attempt teleport
            if not IsPlayerCasting() then
                yield("/tp " .. location)
                Sleep(2.0) -- Wait to check if casting starts

                -- Check if the player started casting
                if IsPlayerCasting() then
                    Sleep(cast_time_buffer) -- Wait for cast to complete
                end
            end

            -- Check if the teleport was successful
            if GetCharacterCondition(45) or GetCharacterCondition(51) then -- 45 is BetweenAreas, 51 is BetweenAreas51
                LogInfo("[VAC] Teleport successful.")
                break
            end

            -- Teleport retry increment
            retries = retries + 1
            LogInfo("[VAC] Retrying teleport, attempt #" .. retries)
        end

        -- Teleporter failed handling
        if retries >= max_retries then
            local attempt_word = (max_retries == 1) and "attempt" or "attempts"
            LogInfo("[VAC] Teleport failed after " .. max_retries .. " " .. attempt_word .. ".")
            Echo("Teleport failed after " .. max_retries .. " " .. attempt_word .. ".")
        end
    elseif tp_kind == "li" then
        while retries < max_retries do
            if not IsPlayerCasting() then
                yield("/li " .. location)
                Sleep(2.0) -- give lifestream some time to start
            end

            if LifestreamIsBusy() then
                repeat
                    Sleep(0.1)
                until not LifestreamIsBusy() and IsPlayerAvailable()
                break
            end
            retries = retries + 1
            LogInfo("[VAC] Retrying lifestream, attempt #" .. retries)
        end
        -- Reset lifestream_stopped for next retry
        if retries >= max_retries then
            local attempt_word = (max_retries == 1) and "attempt" or "attempts"
            LogInfo("[VAC] Lifestream failed after " .. max_retries .. " " .. attempt_word .. ".")
            Echo("Lifestream failed after " .. max_retries .. " " .. attempt_word .. ".")
            yield("/lifestream stop") -- Not always needed but removes lifestream ui
        end
    else
        Echo('Invalid option "' .. tp_kind .. '", valid options are li and tp')
    end
    
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting()
end

-- Usage: UseItemTeleport("Maelstrom")
-- Will use specified teleport location item for teleporting
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
        yield("/item " .. item)
    else
        LogInfo("[VAC] No teleport item found for: " .. location)
        Echo("No teleport item found for: " .. location)
    end
end

-- Usage: Mount("SDS Fenrir")
-- Attempts to use specified mount if player has mounts unlocked
-- Will use "Company Chocobo" if left empty
-- Stores if the locked mount message in Mount() has been sent already or not
local mount_message = false
function Mount(mount_name)
    local max_retries = 10     -- Maximum number of retries
    local retry_interval = 1.0 -- Time interval between retries in seconds
    local retries = 0          -- Counter for the number of retries

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
-- Logs the player out of the game, checks if player is in sanctuary
function LogOut()
    yield("/logout")

    local select_option
    -- If the player is not in a sanctuary, they need to wait 20 seconds
    if not InSanctuary() then
        select_option = 4
        -- Start the 20 second countdown
        for i = 1, 200 do
            Sleep(0.1)
        end
    else
        select_option = 0 -- Immediate logout in sanctuary
    end

    -- Wait for "SelectYesno" to become visible
    repeat
        Sleep(0.1)
    until IsAddonVisible("SelectYesno")

    -- Confirm the logout selection
    yield("/pcall SelectYesno true " .. select_option)

    -- Wait until "SelectYesno" is no longer visible
    repeat
        Sleep(0.1)
    until not IsAddonVisible("SelectYesno")
end

-- Usage: Movement(674.92, 19.37, 436.02) // Movement(674.92, 19.37, 436.02, 15)
-- Moves player to specified x y z coordinates with optional distance value to stop movement when player is within specified distance
-- Will automatically mount, unstuck the player if player is stuck and stop within 2.5 distance of the destination
function Movement(x_position, y_position, z_position, range)
    -- Wait until player doesn't have 45 or 51 conditions for zone changing
    repeat
        Sleep(0.1)
    until not (GetCharacterCondition(45) and GetCharacterCondition(51))

    range = range or 3.5                 -- Default stopping range if not provided
    local max_retries = 10               -- Max number of retries to start moving
    local stuck_check_interval = 0.50    -- Interval in seconds to check if stuck
    local stuck_threshold_seconds = 4.0  -- Time before considering the player stuck
    local min_progress_distance = 0.1    -- Minimum distance considered progress
    local min_distance_for_mounting = 15 -- Distance threshold for deciding to mount

    -- Function to calculate the squared distance to the target
    local function GetSquaredDistanceToTarget(xpos, ypos, zpos)
        local dx = xpos - x_position
        local dy = ypos - y_position
        local dz = zpos - z_position
        return dx * dx + dy * dy + dz * dz
    end

    -- Function to check if the current position is within the target range (using squared distance)
    local function IsWithinRange(xpos, ypos, zpos)
        -- Check if the squared distance is less than or equal to the squared range plus buffer
        return GetSquaredDistanceToTarget(xpos, ypos, zpos) <= (range) * (range)
    end

    -- Initiate movement towards the destination using vnavmesh
    local function NavToDestination()
        NavReload() -- Reload vnavmesh to ensure it's ready

        -- Wait until vnavmesh is ready
        if not NavIsReady() then
            repeat
                Sleep(0.05)
            until NavIsReady()
        end

        local retries = 0 -- Initialize retry counter

        repeat
            -- Get player's current position
            local xpos = GetPlayerRawXPos()
            local ypos = GetPlayerRawYPos()
            local zpos = GetPlayerRawZPos()

            -- Calculate squared distance to target
            local squared_distance_to_target = GetSquaredDistanceToTarget(xpos, ypos, zpos)

            -- Check if the player should mount based on distance and conditions
            if squared_distance_to_target > min_distance_for_mounting * min_distance_for_mounting and TerritorySupportsMounting() and (IsQuestComplete(66236) or IsQuestComplete(66237) or IsQuestComplete(66238)) then
                -- Attempt to mount until successful
                repeat
                    Mount()
                    Sleep(0.1)
                until GetCharacterCondition(4) and IsPlayerAvailable()
            end

            -- Start moving towards the destination
            yield("/vnav moveto " .. x_position .. " " .. y_position .. " " .. z_position)
            retries = retries + 1
            Sleep(0.05)
        until PathIsRunning() or retries >= max_retries -- Stop if path is running or max retries reached

        Sleep(0.05)
    end

    NavToDestination() -- Call the function to start navigating to the destination

    local stuck_timer = 0 -- Timer to track how long the player has been stuck
    local previous_squared_distance_to_target = nil -- Store the previous squared distance to target
    local previous_relative_position = nil -- Store player's previous position relative to the target

    while true do
        -- Check if the player is teleporting or in a loading state
        if GetCharacterCondition(45) or GetCharacterCondition(51) then
            yield("/vnav stop") -- Temporarily stop navmesh

            -- Wait for teleporting or loading to finish
            repeat
                Sleep(0.1)
            until not GetCharacterCondition(45) and not GetCharacterCondition(51)

            -- Resume navmesh after conditions clear
            --NavToDestination()
            return
        end

        -- Get player's current position
        local xpos = GetPlayerRawXPos()
        local ypos = GetPlayerRawYPos()
        local zpos = GetPlayerRawZPos()
        Sleep(0.05)

        -- Calculate the current squared distance to the target
        local current_squared_distance_to_target = GetSquaredDistanceToTarget(xpos, ypos, zpos)

        -- If the player is within the target range, stop movement once the player is within range
        if IsWithinRange(xpos, ypos, zpos) then
            yield("/vnav stop")
            break
        end

        -- Stuck check logic NEEDS /vnav rebuild adding if movement has not happened on first call
        if previous_squared_distance_to_target and previous_relative_position then
            local dx = xpos - previous_relative_position.x
            local dy = ypos - previous_relative_position.y
            local dz = zpos - previous_relative_position.z
            local squared_distance_traveled = dx * dx + dy * dy + dz * dz

            -- If the player is not making sufficient progress, increase the stuck timer
            if current_squared_distance_to_target >= previous_squared_distance_to_target - min_progress_distance * min_progress_distance and 
               squared_distance_traveled < min_progress_distance * min_progress_distance then
                stuck_timer = stuck_timer + stuck_check_interval
            else
                stuck_timer = math.max(0, stuck_timer - stuck_check_interval / 2)
            end
        end

        -- If the stuck timer exceeds the threshold, attempt to get unstuck
        if stuck_timer >= stuck_threshold_seconds then
            DoGeneralAction("Jump")
            Sleep(0.1)
            NavReload()
            NavToDestination()
            stuck_timer = 0
        end

        -- Update previous distance and position
        previous_squared_distance_to_target = current_squared_distance_to_target
        previous_relative_position = { x = xpos, y = ypos, z = zpos }

        Sleep(0.05)
    end
end

-- Usage: OpenTimers()
-- this should probably be renamed to open gc timers
-- Opens the timers window
function OpenTimers()
    local last_trigger_time = os.time()
    local retry_interval = 5 -- x seconds interval between retries

    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerOccupied()

    yield("/timers")

    repeat
        local current_time = os.time()

        if current_time - last_trigger_time >= retry_interval then -- Activate once every x seconds
            yield("/timers")
            last_trigger_time = current_time                       -- Store the last trigger time
        end

        Sleep(0.1)
    until IsAddonReady("ContentsInfo")

    last_trigger_time = 0 -- Reset the trigger time

    repeat
        local current_time = os.time()
        if current_time - last_trigger_time >= retry_interval then -- Activate once every x seconds
            yield("/pcall ContentsInfo True 12 1")
            last_trigger_time = current_time                       -- Store the last trigger time
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
    local attempts = 0

    repeat
        attempts = attempts + 1
        Sleep(0.1)
    until (IsAddonReady("Shop") or attempts >= 100)

    -- attempts above 50 is about 5 seconds
    if attempts >= 100 then
        Echo("Waited too long, store window not found, moving on")
    end

    if IsAddonReady("Shop") and number_in_list and amount then
        yield("/pcall Shop True 0 " .. number_in_list .. " " .. amount)
        repeat
            Sleep(0.1)
        until IsAddonReady("SelectYesno")

        yield("/pcall SelectYesno true 0")
        Sleep(0.5)
        if IsAddonVisible("SelectYesno") then
            yield("/pcall SelectYesno true 0")
        end

        repeat
            Sleep(0.1)
        until not IsAddonReady("SelectYesno")

        Sleep(0.5)
    end
end

-- Usage: BuyFromStoreSingle(1)
--
-- Buys one item
-- number_in_list is which item you're buying from the list, top item is 1, 2 is below that, 3 is below that etc...
-- only works for the "Store" addon window, i'd be careful calling it anywhere else
function BuyFromStoreSingle(number_in_list)
    -- compensates for the top being 0
    number_in_list = number_in_list - 1
    local attempts = 0

    repeat
        attempts = attempts + 1
        Sleep(0.1)
    until (IsAddonReady("Shop") or attempts >= 100)

    -- attempts above 50 is about 5 seconds
    if attempts >= 100 then
        Echo("Waited too long, store window not found, moving on")
    end

    if IsAddonReady("Shop") and number_in_list then
        yield("/pcall Shop True 0 " .. number_in_list .. " 1")
        repeat
            Sleep(0.1)
        until IsAddonReady("SelectYesno")
        
        yield("/pcall SelectYesno true 0")
        Sleep(0.5)
        
        if IsAddonVisible("SelectYesno") then
            yield("/pcall SelectYesno true 0")
        end
        repeat
            Sleep(0.1)
        until not IsAddonReady("SelectYesno")

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
    if DoesObjectExist(target) then
        local target_command = "/target \"" .. target .. "\""
        repeat
            yield(target_command)
            Sleep(0.1)
        until string.lower(GetTargetName()) == string.lower(target)
        return true
    else
        return false
    end
end

-- Usage: DoGcRankUp()
--
-- Checks if you can rank up in your current gc, then it'll attempt to rank you up
function DoGcRankUp()
    -- check in case it's called when you can't rank up
    local can_rankup = CanGCRankUp()
    if not can_rankup then
        return
    end

    yield("/at e")
    local gc_id = GetPlayerGC()

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

    OpenAndAttemptRankup()
    
    Sleep(1.0)

    repeat
        Sleep(0.1)
    until IsPlayerAvailable()
end

-- Usage: can_rankup, next_rank = CanGCRankUp()
--
-- returns true and the next rank if you can rank up, returns false if you can't
function CanGCRankUp()
    local gc_rank_9_mission_complete = false
    local gc_rank_8_mission_complete = false
    local can_rankup = false
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

    local next_rank = gc_rank + 1 -- adds one so we know which gc rank we're attempting to rank up total
    if next_rank == 5 then
        local log_rank_1_complete = IsHuntLogComplete(9, 0)
        if log_rank_1_complete then
            can_rankup = true
        else
            Echo("You need to finish GC hunting log 1 to rank up more")
        end
    elseif next_rank == 8 then
        if not gc_rank_8_mission_complete then
            Echo('You need to finish the quest "Shadows Uncast" to rank up more')
        else
            can_rankup = true
        end
    elseif next_rank == 9 then
        local log_rank_2_complete = IsHuntLogComplete(9, 1)
        if log_rank_2_complete and gc_rank_9_mission_complete then
            can_rankup = true
        else
            if not log_rank_2_complete then
                Echo("You need to finish GC hunting log 2 to rank up more")
            end
            if not gc_rank_9_mission_complete then
                Echo('You need to finish the quest "Gilding The Bilious" to rank up more')
            end
        end
    else
        can_rankup = true
    end

    if current_seals > gc_ranks[next_rank] and next_rank <= 9 and can_rankup then -- excludes rank 10 and above as we don't handle that atm
        return true, next_rank
    else
        return false, next_rank
    end
end

-- Attempts to use an fc buff with the name you provide
function UseFCAction(action_name)
    repeat
        Sleep(0.1)
    until IsPlayerAvailable()
    action_name = string.lower(tostring(action_name))
    yield("/freecompanycmd")
    repeat
        Sleep(0.1)
    until IsAddonReady("FreeCompany")
    yield("/callback FreeCompany true 0 4")
    Sleep(1)

    -- Check if the requested buff is already active
    for i = 1, 15 do
        local node_text = GetNodeText("FreeCompanyAction", 13, i, 4)
        node_text = string.lower(node_text)
        if node_text == action_name then
            yield("/callback FreeCompany true -1")
            return true, "Action already active" -- send back a true because the buff is already active, so no action is needed
        end
        Sleep(0.0001)
    end

    -- Find the requested buff and use it if it is found
    for i = 1, 30 do
        local node_text = GetNodeText("FreeCompanyAction", 5, i, 3)
        node_text = string.lower(node_text)
        if node_text == action_name then
            yield("/callback FreeCompanyAction true 1 " .. (i - 1))
            Sleep(0.2)
            yield("/callback ContextMenu true 0 0 0")
            repeat
                Sleep(0.1)
            until IsAddonReady("SelectYesno")
            yield("/callback SelectYesno true 0")
            Sleep(1.0)
            yield("/callback FreeCompany true -1")
            return true, "Action successfully activated"
        end
        Sleep(0.0001)
    end
    if IsAddonReady("FreeCompany") then
        yield("/callback FreeCompany true -1")
    end
    return false, "Failed to find action"
end

-- Attempts to buy an fc buff with the name you provide, assumes you are in front of the OIC Quartermaster
function BuyFCAction(action_name)
    repeat
        Sleep(0.1)
    until IsPlayerAvailable()
    action_name = tostring(action_name)
    if not action_name then
        Echo("No action name to buy provided")
        return false, "No action name provided"
    end

    local actions = {
        { name = "The Heat of Battle",     index = 0,  rank = 5, credit_cost = 3150 },
        { name = "Earth and Water",        index = 1,  rank = 5, credit_cost = 3150 },
        { name = "Helping Hand",           index = 2,  rank = 5, credit_cost = 3150 },
        { name = "A Man's Best Friend",    index = 3,  rank = 5, credit_cost = 2520 },
        { name = "Mark Up",                index = 4,  rank = 5, credit_cost = 2520 },
        { name = "Seal Sweetener",         index = 5,  rank = 5, credit_cost = 2520 },
        { name = "Jackpot",                index = 6,  rank = 5, credit_cost = 2520 },
        { name = "Brave New World",        index = 7,  rank = 5, credit_cost = 1575 },
        { name = "Live Off the Land",      index = 8,  rank = 5, credit_cost = 2520 },
        { name = "What You See",           index = 9,  rank = 5, credit_cost = 2520 },
        { name = "Eat from the Hand",      index = 10, rank = 5, credit_cost = 2520 },
        { name = "In Control",             index = 11, rank = 5, credit_cost = 2520 },
        { name = "That Which Binds Us",    index = 12, rank = 5, credit_cost = 3150 },
        { name = "Meat and Mead",          index = 13, rank = 5, credit_cost = 2520 },
        { name = "Proper Care",            index = 14, rank = 5, credit_cost = 3150 },
        { name = "Fleet-footed",           index = 15, rank = 5, credit_cost = 2520 },
        { name = "Reduced Rates",          index = 16, rank = 5, credit_cost = 3150 },
        { name = "The Heat of Battle II",  index = 17, rank = 8, credit_cost = 6300 },
        { name = "Earth and Water II",     index = 18, rank = 8, credit_cost = 6300 },
        { name = "Helping Hand II",        index = 19, rank = 8, credit_cost = 6300 },
        { name = "A Man's Best Friend II", index = 20, rank = 8, credit_cost = 6300 },
        { name = "Mark Up II",             index = 21, rank = 8, credit_cost = 6300 },
        { name = "Seal Sweetener II",      index = 22, rank = 8, credit_cost = 6300 },
        { name = "Jackpot II",             index = 23, rank = 8, credit_cost = 6300 },
        { name = "Brave New World II",     index = 24, rank = 8, credit_cost = 3150 },
        { name = "Live Off the Land II",   index = 25, rank = 8, credit_cost = 6300 },
        { name = "What You See II",        index = 26, rank = 8, credit_cost = 6300 },
        { name = "Eat from the Hand II",   index = 27, rank = 8, credit_cost = 6300 },
        { name = "In Control II",          index = 28, rank = 8, credit_cost = 6300 },
        { name = "That Which Binds Us II", index = 29, rank = 8, credit_cost = 6300 },
        { name = "Meat and Mead II",       index = 30, rank = 8, credit_cost = 6300 },
        { name = "Proper Care II",         index = 31, rank = 8, credit_cost = 6300 },
        { name = "Fleet-footed II",        index = 32, rank = 8, credit_cost = 5040 },
        { name = "Reduced Rates II",       index = 33, rank = 8, credit_cost = 6300 },
    }

    local function find_action(search_name)
        for i, action in ipairs(actions) do
            if string.lower(action.name) == string.lower(search_name) then
                return action
            end
        end
        return false
    end

    local found_target = Target("OIC Quartermaster") -- Target the quartermaster
    if not found_target then
        Echo("OIC Quartermaster not found, aborting attempt to buy FC action")
        return false, "Quartermaster not found"
    end
    yield("/lockon")
    Sleep(0.2)
    Interact()
    repeat
        Sleep(0.1)
    until IsAddonReady("SelectString")
    yield("/callback SelectString true 0")
    repeat
        Sleep(0.1)
    until IsAddonReady("FreeCompanyExchange")
    Sleep(1)
    local action_info = find_action(action_name)
    local current_credit_amount = tonumber((GetNodeText("FreeCompanyExchange", 40):gsub(",", "")))
    local current_fc_rank = tonumber(GetNodeText("FreeCompanyExchange", 42))
    if not action_info then
        Echo("Action ".. action_name .." not found, aborting buy process")
        yield("/callback FreeCompanyExchange true -1")
        return false, "Action not found"
    end
    if current_credit_amount > action_info.credit_cost then
        if action_info.rank and current_fc_rank and current_fc_rank >= action_info.rank then
            yield("/callback FreeCompanyExchange true 2 " .. action_info.index)
            repeat
                Sleep(0.1)
            until IsAddonReady("SelectYesno")
            yield("/callback SelectYesno true 0")
            repeat
                Sleep(0.1)
            until not IsAddonVisible("SelectYesno")
            yield("/callback FreeCompanyExchange true -1")
            return true
        else
            yield("/callback FreeCompanyExchange true -1")
            return false, "Missing rank requirement"
        end
    else
        yield("/callback FreeCompanyExchange true -1")
        repeat
            Sleep(0.1)
        until not IsAddonVisible("FreeCompanyExchange")
        return false, "Missing credits"
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
    if IsAddonReady("GrandCompanySupplyList") then
        yield("/callback GrandCompanySupplyList true -1")

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

    if HasPlugin("YesAlready") then
        PauseYesAlready()
    end

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
            LogInfo("[VAC] Nothing here, moving on")
            goto skip
        end

        local row_to_call = i - 2
        yield("/pcall GrandCompanySupplyList true 1 " .. row_to_call)
        local err_counter_request = 0
        local err_counter_supply = 0

        repeat
            err_counter_request = err_counter_request + 1
            Sleep(0.1)
        until IsAddonReady("GrandCompanySupplyReward") or err_counter_request >= 70

        if err_counter_request >= 70 then
            LogInfo("[VAC] Something might have gone wrong")
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
                    if IsAddonReady("SelectYesno") then
                        yield("/callback SelectYesno true 0")
                    end
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
            err_counter_supply = err_counter_supply + 1
            Sleep(0.1)
        until IsAddonReady("GrandCompanySupplyList") or err_counter_supply >= 50

        err_counter_supply = 0
        ::skip::
    end

    if HasPlugin("YesAlready") then
        RestoreYesAlready()
    end
end

-- Usage: GCDeliverooExpertDelivery()
--
-- Will activate deliveroo and wait for it to finish
function GCDeliverooExpertDelivery()
    local gc_id = GetPlayerGC()
    if gc_id == 1 then -- checks if gc is maelstrom and checks if the quests are done
        Target("Storm Personnel Officer")
    elseif gc_id == 2 then -- checks if gc is twin adder and checks if the quests are done
        Target("Serpent Personnel Officer")
    elseif gc_id == 3 then -- checks if gc is immortal flames and checks if the quests are done
        Target("Flame Personnel Officer")
    end
    Sleep(0.5)
    yield("/lockon")
    Sleep(0.5)
    yield("/lockon")
    Sleep(0.2)
    ClearTarget()
    Sleep(0.2)
    yield("/deliveroo enable")
    Sleep(3)
    repeat
        Sleep(0.1)
    until not DeliverooIsTurnInRunning() and IsPlayerAvailable()
end

-- Usage: FindWorldByID(11) // FindWorldByID(GetHomeWorld())
--
-- Looks through the World_ID_List for the world name with X id and returns the name
function FindWorldByID(searchID)
    for name, data in pairs(World_ID_List) do
        if data.ID == searchID then
            return name, data
        end
    end
    return nil, nil
end

-- Usage: FindDCWorldIsOn("Cerbeus") Will return Chaos
--
-- Looks through the DC_With_Worlds table and returns the datacenter a world is on
function FindDCWorldIsOn(worldName)
    for datacenter, worlds in pairs(DC_With_Worlds) do
        for _, world in ipairs(worlds) do
            if world == worldName then
                return datacenter
            end
        end
    end
    return nil
end

-- Usage: FindDutyID("Sastasha")
--
-- returns the id of the duty you search for, if the search is vague enough it'll return any of the ones that it finds, so try to be specific
function FindDutyID(duty_name)
    -- this needs to be here to replace funky dashes since square is funny
    local function replaceDashes(s)
        return s:gsub("–", "-"):gsub("—", "-"):gsub("‑", "-"):gsub("‐", "-")
    end
    local duty_name_lower = replaceDashes(string.lower(duty_name))
    for key, value in pairs(Zone_List) do
        local duty_value_lower = replaceDashes(string.lower(value["Duty"]))

        if duty_value_lower == duty_name_lower then
            return key
        end
    end

    return nil
end

-- Usage: FindZoneID("Limsa Lominsa Lower Decks")
--
-- returns the id of the zone you search for, if the search is vague enough it'll return any of the ones that it finds, so try to be specific
function FindZoneID(zone)
    zone = zone or Zone_List["" .. GetZoneID() .. ""]["Zone"]

    -- Check if zone is string
    if type(zone) ~= "string" then
        return nil -- return 0
    end

    local searchLower = zone:lower()

    for id, entry in pairs(Zone_List) do
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
    if type(targetAetheryte) ~= "string" then
        return nil
    end

    local lowerTarget = targetAetheryte:lower()

    for key, value in pairs(Zone_List) do
        if type(value) == "table" and type(value["Aetherytes"]) == "table" then
            for _, aetheryte in ipairs(value["Aetherytes"]) do
                if type(aetheryte) == "table" and type(aetheryte["Name"]) == "string" then
                    if aetheryte["Name"]:lower():find(lowerTarget, 1, true) then
                        return tonumber(key), aetheryte
                    end
                end
            end
        end
    end

    return nil, "Not found"
end

-- Function to find the name of an aetheryte by ID
-- Usage: local name = FindAetheryteNameByID("55")
-- 
-- Will return the name of the aetheryte with the given id, or nil if not found
function FindAetheryteNameByID(aetheryte_id)
    aetheryte_id = tonumber(aetheryte_id) -- make sure the id is a number
    for _, zone in pairs(Zone_List) do -- iterate over the zone list
        if zone["Aetherytes"] then -- checks if the aetheryte section is present
            for _, aetheryte in ipairs(zone["Aetherytes"]) do -- iterates over each aetheryte inside the zone
                if tonumber(aetheryte["ID"]) == aetheryte_id then -- converts the aetheryte id to number and checks it against the provided id
                    return aetheryte["Name"] -- returns the correct aetheryte name
                end
            end
        end
    end
    return nil  -- Return nil if not found
end


-- Function to find the ID of an aetheryte by name
-- Usage: local id = FindAetheryteIDByName("Aleport")
-- 
-- Will return the ID of the aetheryte with the given name, or nil if not found
function FindAetheryteIDByName(aetheryte_name)
    aetheryte_name = tostring(aetheryte_name):lower()  -- Convert input name to lower case
    for _, zone in pairs(Zone_List) do -- iterate over the zone list
        if zone["Aetherytes"] then -- checks if the aetheryte section is present
            for _, aetheryte in ipairs(zone["Aetherytes"]) do -- iterates over each aetheryte inside the zone
                if aetheryte["Name"]:lower() == aetheryte_name then  -- converts aetheryte name to lower case and checks it against the provided name
                    return tonumber(aetheryte["ID"]) -- returns the correct aetheryte id
                end
            end
        end
    end
    return nil     -- Return nil if not found
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
    return math.sqrt(dx ^ 2 + dy ^ 2 + dz ^ 2)
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
    return math.sqrt(dx ^ 2 + dy ^ 2 + dz ^ 2)
end

-- Usage: PathToObject("First Last") or PathToObject("Aetheryte", 2)
-- Finds specified object and paths to it
-- Optionally can include a range value to stop once distance between character and target has been reached
function PathToObject(path_object_name, range)
    -- Check whether path_object_name isn't nil or empty
    if not path_object_name or path_object_name == "" then
        LogInfo("[VAC] (PathToObject) PathToObject name is empty.")
        Echo("PathToObject name is empty.")
        return false
    end

    path_object_name = string.lower(path_object_name)
    if not DoesObjectExist(path_object_name) then
        LogInfo("[VAC] (PathToObject) Object '" .. path_object_name .. "' does not exist.")
        Echo("Object '" .. path_object_name .. "' does not exist.")
        return false
    end

    -- Get the object position
    local objectX = GetObjectRawXPos(path_object_name)
    local objectY = GetObjectRawYPos(path_object_name)
    local objectZ = GetObjectRawZPos(path_object_name)

    -- Get player's current position
    local playerX = GetPlayerRawXPos()
    local playerY = GetPlayerRawYPos()
    local playerZ = GetPlayerRawZPos()

    LogInfo(string.format("[VAC] (PathToObject) Player position: X=%.2f, Y=%.2f, Z=%.2f", playerX, playerY, playerZ))
    LogInfo(string.format("[VAC] (PathToObject) Object position: X=%.2f, Y=%.2f, Z=%.2f", objectX, objectY, objectZ))

    -- Try different extents for finding a valid navmesh point
    local extents = {0, 1, 2, 5, 10, 15, 20}
    local nearestX, nearestY, nearestZ

    for _, extent in ipairs(extents) do
        nearestX = QueryMeshNearestPointX(objectX, objectY, objectZ, extent, extent)
        nearestY = QueryMeshNearestPointY(objectX, objectY, objectZ, extent, extent)
        nearestZ = QueryMeshNearestPointZ(objectX, objectY, objectZ, extent, extent)

        if nearestX and nearestY and nearestZ then
            LogInfo(string.format("[VAC] (PathToObject) Found valid navmesh point with extent %.2f", extent))
            LogInfo(string.format("[VAC] (PathToObject) Nearest point: X=%.2f, Y=%.2f, Z=%.2f", nearestX, nearestY, nearestZ))
            break
        end
    end

    if not (nearestX and nearestY and nearestZ) then
        LogInfo("[VAC] (PathToObject) Couldn't find a valid navmesh point near the object with any extent.")
        Echo("Unable to find a path to the object.")
        return false
    end

    -- Find a valid floor point for the player to stand on
    local floorX = QueryMeshPointOnFloorX(nearestX, nearestY, nearestZ, true, 2)
    local floorY = QueryMeshPointOnFloorY(nearestX, nearestY, nearestZ, true, 2)
    local floorZ = QueryMeshPointOnFloorZ(nearestX, nearestY, nearestZ, true, 2)

    if not (floorX and floorY and floorZ) then
        LogInfo("[VAC] (PathToObject) Couldn't find a valid floor point near the object.")
        Echo("Unable to find a safe position near the object.")
        return false
    end

    LogInfo(string.format("[VAC] (PathToObject) Valid floor point: X=%.2f, Y=%.2f, Z=%.2f", floorX, floorY, floorZ))

    -- Calculate distance to check if we're already close enough
    local distance = math.sqrt((playerX - floorX) ^ 2 + (playerY - floorY) ^ 2 + (playerZ - floorZ) ^ 2)
    LogInfo(string.format("[VAC] (PathToObject) Distance to floor point: %.2f", distance))

    if distance > (range or 3) then  -- Use specified range or default to 3
        LogInfo("[VAC] (PathToObject) Moving to floor point.")
        Movement(floorX, floorY, floorZ, range or 3.5)

        -- Wait until the pathing is complete
        repeat
            Sleep(0.1)
        until not PathIsRunning()

        return true
    else
        LogInfo("[VAC] (PathToObject) Already close to the object.")
        return true
    end
end

-- Usage: PathToEstateEntrance()
-- Finds where your estate entrance is and paths to it
-- Assumes you are outside your plot/recently used estate teleport
function PathToEstateEntrance()
    local entranceX = GetObjectRawXPos("Entrance")
    local entranceY = GetObjectRawYPos("Entrance")
    local entranceZ = GetObjectRawZPos("Entrance")

    -- Check if we got valid entrance coordinates
    if not entranceX or not entranceY or not entranceZ then
        LogInfo("[VAC] (PathToEstateEntrance) Failed to get valid entrance coordinates.")
        LogInfo(string.format("[VAC] (PathToEstateEntrance) Entrance coordinates: X=%s, Y=%s, Z=%s", 
            tostring(entranceX), tostring(entranceY), tostring(entranceZ)))
        return false
    end

    -- Get player's current position
    local playerX = GetPlayerRawXPos()
    local playerY = GetPlayerRawYPos()
    local playerZ = GetPlayerRawZPos()

    LogInfo(string.format("[VAC] (PathToEstateEntrance) Player position: X=%.2f, Y=%.2f, Z=%.2f", playerX, playerY, playerZ))
    LogInfo(string.format("[VAC] (PathToEstateEntrance) Entrance position: X=%.2f, Y=%.2f, Z=%.2f", entranceX, entranceY, entranceZ))

    -- Try different extents for finding a valid navmesh point
    local extents = {0, 1, 2, 5, 10, 15, 20}
    local nearestX, nearestY, nearestZ

    for _, extent in ipairs(extents) do
        nearestX = QueryMeshNearestPointX(entranceX, entranceY, entranceZ, extent, extent)
        nearestY = QueryMeshNearestPointY(entranceX, entranceY, entranceZ, extent, extent)
        nearestZ = QueryMeshNearestPointZ(entranceX, entranceY, entranceZ, extent, extent)

        if nearestX and nearestY and nearestZ then
            LogInfo(string.format("[VAC] (PathToEstateEntrance) Found valid navmesh point with extent %.2f", extent))
            LogInfo(string.format("[VAC] (PathToEstateEntrance) Nearest point: X=%.2f, Y=%.2f, Z=%.2f", nearestX, nearestY, nearestZ))
            break
        end
    end

    if not (nearestX and nearestY and nearestZ) then
        LogInfo("[VAC] (PathToEstateEntrance) Couldn't find a valid navmesh point near the entrance with any extent.")
        return false
    end

    -- Find a valid floor point for the player to path to
    local floorX = QueryMeshPointOnFloorX(nearestX, nearestY, nearestZ, true, 2)
    local floorY = QueryMeshPointOnFloorY(nearestX, nearestY, nearestZ, true, 2)
    local floorZ = QueryMeshPointOnFloorZ(nearestX, nearestY, nearestZ, true, 2)

    if floorX and floorY and floorZ then
        LogInfo(string.format("[VAC] (PathToEstateEntrance) Valid floor point: X=%.2f, Y=%.2f, Z=%.2f", floorX, floorY, floorZ))

        -- Calculate distance to check if we're already close enough
        local distance = math.sqrt((playerX - floorX) ^ 2 + (playerY - floorY) ^ 2 + (playerZ - floorZ) ^ 2)
        LogInfo(string.format("[VAC] (PathToEstateEntrance) Distance to floor point: %.2f", distance))

        if distance > 3 then  -- Only move if we're more than 3 units away
            LogInfo("[VAC] (PathToEstateEntrance) Moving to floor point.")
            Movement(floorX, floorY, floorZ, 3.5)

            -- Wait until the pathing is complete
            repeat
                Sleep(0.1)
            until not PathIsRunning()

            LogInfo("[VAC] (PathToEstateEntrance) Movement to estate entrance complete.")
            return true
        else
            LogInfo("[VAC] (PathToEstateEntrance) Already close to the estate entrance.")
            return true
        end
    else
        LogInfo("[VAC] (PathToEstateEntrance) Couldn't find a valid floor point near the entrance.")
        return false
    end
end

-- Function to navigate to the summoning bell in limsa lominsa lower decks
-- Usage: PathToLimsaBell()
--
-- Will move the character to the summoning bell if already in limsa lominsa lower decks,
-- Otherwise teleports to limsa lominsa and then moves to the summoning bell
function PathToLimsaBell()
    if not ZoneCheck("Limsa Lominsa Lower Decks") then
        LogInfo("[VAC] (PathToLimsaBell) Not in Limsa Lominsa Lower Decks.")
        Teleporter("Limsa Lominsa", "tp")
    end

    local bellX = GetObjectRawXPos("Summoning Bell")
    local bellY = GetObjectRawYPos("Summoning Bell")
    local bellZ = GetObjectRawZPos("Summoning Bell")

    if not bellX or not bellY or not bellZ then
        LogInfo("[VAC] (PathToLimsaBell) Failed to get Summoning Bell coordinates.")
        return false
    end

    LogInfo(string.format("[VAC] (PathToLimsaBell) Summoning Bell position: X=%.2f, Y=%.2f, Z=%.2f", bellX, bellY, bellZ))

    -- Try different extents for finding a valid navmesh point
    local extents = {0, 1, 2, 5, 10, 15, 20}
    local nearestX, nearestY, nearestZ

    for _, extent in ipairs(extents) do
        nearestX = QueryMeshNearestPointX(bellX, bellY, bellZ, extent, extent)
        nearestY = QueryMeshNearestPointY(bellX, bellY, bellZ, extent, extent)
        nearestZ = QueryMeshNearestPointZ(bellX, bellY, bellZ, extent, extent)

        if nearestX and nearestY and nearestZ then
            LogInfo(string.format("[VAC] (PathToLimsaBell) Found valid navmesh point with extent %.2f", extent))
            LogInfo(string.format("[VAC] (PathToLimsaBell) Nearest point: X=%.2f, Y=%.2f, Z=%.2f", nearestX, nearestY, nearestZ))
            break
        end
    end

    if not (nearestX and nearestY and nearestZ) then
        LogInfo("[VAC] (PathToLimsaBell) Couldn't find a valid navmesh point near the Summoning Bell with any extent.")
        return false
    end

    -- Find a valid floor point for the player to stand on
    local floorX = QueryMeshPointOnFloorX(nearestX, nearestY, nearestZ, true, 2)
    local floorY = QueryMeshPointOnFloorY(nearestX, nearestY, nearestZ, true, 2)
    local floorZ = QueryMeshPointOnFloorZ(nearestX, nearestY, nearestZ, true, 2)

    if not (floorX and floorY and floorZ) then
        LogInfo("[VAC] (PathToLimsaBell) Couldn't find a valid floor point near the Summoning Bell.")
        return false
    end

    LogInfo(string.format("[VAC] (PathToLimsaBell) Moving to Summoning Bell: X=%.2f, Y=%.2f, Z=%.2f", floorX, floorY, floorZ))
    Movement(floorX, floorY, floorZ, 3)

    -- Wait until the pathing is complete
    repeat
        Sleep(0.1)
    until not PathIsRunning()

    LogInfo("[VAC] (PathToLimsaBell) Reached the Summoning Bell.")
    return true
end

-- Function to wait until a specified amount of gil is traded
-- Usage: WaitForGilIncrease(1)
-- This function monitors the gil amount and waits until it increases by the specified amount.
-- It acts as a trigger before proceeding with further actions.
function WaitForGilIncrease(gil_increase_amount)
    -- Store the current amount of gil before the trade
    local previous_gil = GetGil()
    -- Continuously check the gil amount until the specified increase is detected
    while true do
        Sleep(1.0) -- Pause execution for 1 second between checks
        -- Retrieve the current amount of gil
        local current_gil = GetGil()
        local gil_difference = current_gil - previous_gil
        -- Check if the gil has increased by the specified amount
        if gil_difference == gil_increase_amount then
            LogInfo(string.format("%d Gil successfully received", gil_increase_amount))
            return true
        end
        if gil_difference > gil_increase_amount then
            LogInfo(string.format("Gil difference (%d) exceeded expected amount (%d). Resetting...", gil_difference, gil_increase_amount))
            previous_gil = current_gil
        end
    end
end

-- Function to wait until a specified amount of gil is traded
-- Usage: WaitForGilDecrease(1)
-- This function monitors the gil amount and waits until it decreases by the specified amount.
-- It acts as a trigger before proceeding with further actions.
function WaitForGilDecrease(gil_decrease_amount)
    -- Store the current amount of gil before the trade
    local previous_gil = GetGil()
    -- Continuously check the gil amount until the specified decrease is detected
    while true do
        Sleep(1.0) -- Pause execution for 1 second between checks
        -- Retrieve the current amount of gil
        local current_gil = GetGil()
        local gil_difference = previous_gil - current_gil
        -- Check if the gil has decreased by the specified amount
        if gil_difference == gil_decrease_amount then
            LogInfo(string.format("%d Gil successfully traded", gil_decrease_amount))
            return true
        end
        if gil_difference > gil_decrease_amount then
            LogInfo(string.format("Gil difference (%d) exceeded expected amount (%d). Resetting...", gil_difference, gil_decrease_amount))
            previous_gil = current_gil
        end
    end
end

-- Usage: PartyInvite("First Last")
-- Will target and invite player to a party, and retrying if the invite timeout happens
-- Can only be used if target is in range
function PartyInvite(party_invite_name)
    local invite_timeout = 305   -- 300 Seconds is the invite timeout, adding 5 seconds for good measure
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
                break                  -- Break the loop to resend the invite
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
    local invite_timeout = 305   -- 300 Seconds is the invite timeout, adding 5 seconds for good measure
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
            if IsAddonReady("SocialList") then
                yield('/callback SocialList true 1 0 "' .. party_invite_menu_full .. '"')
            end
            Sleep(0.5)
        until IsAddonVisible("ContextMenu")

        repeat
            if IsAddonReady("ContextMenu") then
                yield("/callback ContextMenu true 0 3 0")
            end
            Sleep(0.1)
        until not IsAddonVisible("ContextMenu")

        repeat
            if IsAddonReady("Social") then
                yield("/callback Social true -1")
            end
            Sleep(0.1)
        until not IsAddonVisible("Social")

        -- Wait for the target player to accept the invite or the timeout to expire
        while not IsInParty() do
            Sleep(0.1)

            -- Check if the invite has expired
            if os.time() - start_time >= invite_timeout then
                Echo("Invite expired. Reinviting " .. party_invite_menu_full)
                start_time = os.time() -- Reset the start time for the new invite
                break                  -- Break the loop to resend the invite
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
        until IsAddonReady("SelectYesno")
        repeat
            if IsAddonReady("SelectYesno") then
                yield("/callback SelectYesno true 0")
            end
            Sleep(0.1)
        until not IsAddonVisible("SelectYesno")
    end
end

-- Usage: PartyAccept()
-- Will accept party invite if not in party
-- NEEDS a name arg
function PartyAccept()
    if not IsInParty() then
        -- Wait until the player is available, not casting, and not in combat
        repeat
            Sleep(0.1)
        until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)

        -- Wait until the "SelectYesno" addon is visible
        repeat
            Sleep(0.1)
        until IsAddonVisible("SelectYesno")

        Sleep(0.1)

        -- Accept the party invite
        yield("/pcall SelectYesno true 0")

        -- Wait until the player is in a party
        repeat
            Sleep(0.1)
        until IsInParty()

        LogInfo("[VAC] Party invitation accepted.")
    else
        LogInfo("[VAC] Player is already in a party.")
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

        Sleep(0.1)

        repeat
            if IsAddonReady("SelectYesno") then
                yield("/callback SelectYesno true 0")
            end
            Sleep(0.1)
        until not IsAddonVisible("SelectYesno")

        LogInfo("[VAC] Party has been left.")
    else
        LogInfo("[VAC] Player is not in a party.")
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
-- Will check if player is in a santuary
-- Requires @Server else it will not work
-- Requires Auto Retainer plugin
function RelogCharacter(relog_char_name)
    -- Wait until the player is available, not casting, and conditions are met
    repeat
        Sleep(0.1)
    until (IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)) or IsAddonVisible("Title")

    -- If the player is not in a sanctuary, wait 20 seconds before relogging
    if not InSanctuary() then
        -- Start the 20 second countdown
        for i = 1, 200 do
            Sleep(0.1)
        end
    end

    -- Proceed with the relog command after the wait or immediately if in sanctuary
    yield("/ays relog " .. relog_char_name)
end


-- Usage: EquipRecommendedGear()
-- Equips recommended gear if any available
function EquipRecommendedGear()
    LogInfo("[VAC] Equipping recommended gear")
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)

    repeat
        yield("/character")
        Sleep(0.1)
    until IsAddonVisible("Character")

    repeat
        if IsAddonReady("Character") then
            yield("/callback Character true 12")
        end
        Sleep(0.1)
    until IsAddonVisible("RecommendEquip")

    repeat
        yield("/character")
        Sleep(0.1)
    until not IsAddonVisible("Character")

    repeat
        if IsAddonReady("RecommendEquip") then
            yield("/callback RecommendEquip true 0")
        end
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

-- Usage: GetPlayerJob()
-- Returns the current player job abbreviation, or pass true if you want the full name
function GetPlayerJob(player_job_full_name)
    -- Mapping for GetClassJobId()
    -- Find and return job ID
    local job_id = GetClassJobId()
    -- check if true has been passed
    if player_job_full_name == true then
        -- returns the full name of the job
        return Job_List[job_id]["Name"] or "Unknown job"
    else
        -- returns the job abbreviation
        return Job_List[job_id]["Abbreviation"] or "Unknown job"
    end
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
    -- Check if the action is not "Jump" and the character is mounted
    if general_action_name ~= "Jump" and GetCharacterCondition(4) then
        repeat
            Dismount()
            Sleep(0.1)
        until not GetCharacterCondition(4)
    end

    -- Do the general action
    yield('/gaction "' .. general_action_name .. '"')
end

-- Usage: DoTargetLockon()
-- Locks on to current target
function DoTargetLockon(target_lockon_name)
    yield("/lockon")
end

-- Usage: IsQuestDone("Hello Halatali")
-- Checks if you have completed the specified quest
function IsQuestDone(quest_done_name)
    if not quest_done_name or quest_done_name == "" then
        return nil -- Return nil if the quest_done_name is nil or an empty string
    end

    -- Initialize a variable to store the quest_key
    local quest_key = nil

    -- Search for the quest in Quest_List by name
    for key, quest in pairs(Quest_List) do
        if string.lower(quest['Name']) == string.lower(quest_done_name) then
            quest_key = tonumber(key)
            break
        end
    end

    -- If the quest is found, check if it is complete
    if quest_key then
        return IsQuestComplete(tonumber(quest_key))
    end

    -- Return false if the quest is not found or not completed
    return false
end

-- Usage: DoQuest("Hallo Halatali") or DoQuest(1433)
-- Checks if you have completed the specified quest and starts if you have not
function DoQuest(quest_do_name)
    EquipRecommendedGear() -- Equip recommended gear before starting a quest

    -- If input is nil or an empty string
    if not quest_do_name or quest_do_name == "" then
        LogInfo("[VAC] (DoQuest) quest_do_name is nil or an empty string")
        return nil -- Return nil if the quest_do_name is nil or an empty string
    end

    -- Initialize variables to store quest information
    local quest_key = nil
    local quest_id = nil

    -- check if quest id was already provided by user directly
    if type(quest_do_name) == "number" then
        quest_id = quest_do_name
    else
        quest_id = nil
    end

    -- Search for the quest in Quest_List by name
    if not quest_id then
        for key, quest in pairs(Quest_List) do
            if string.lower(quest['Name']) == string.lower(quest_do_name) and (string.lower(quest['ClassJobUnlock']) == string.lower(GetPlayerJob(true)) or string.lower(quest['ClassJobUnlock'])) == string.lower("adventurer") then
                quest_id = tonumber(quest['ID'])
                quest_key = tonumber(key)
                break
            end
        end
    else
    -- Search for the quest key by quest_id instead since quest_id was provided by user
        for key, quest in pairs(Quest_List) do
            if tonumber(quest['ID']) == quest_do_name then
                quest_key = tonumber(key)
                break
            end
        end
    end

    -- If the quest is not found, echo and return false
    if not quest_id or not quest_key then
        LogInfo('[VAC] (DoQuest) Quest "' .. quest_do_name .. '" not found.')
        Echo('Quest "' .. quest_do_name .. '" not found.')
        return false
    end

    -- Check if the quest is already completed
    if IsQuestComplete(tonumber(quest_key)) then
        LogInfo('[VAC] (DoQuest) You have already completed the "' .. quest_do_name .. '" quest.')
        Echo('You have already completed the "' .. quest_do_name .. '" quest.')
        return true
    end

    -- Ensure the player is available and not in the middle of zone transition before starting the quest
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26) and not (GetCharacterCondition(45) or GetCharacterCondition(51))

    -- Readies the quest
    yield("/qst next " .. quest_id)

    -- Wait for player availability again after quest initiation, also acts as a small sleep
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)

    -- Start the quest
    yield("/qst start")
    
    -- Ensure Questionable is running before checking for stuck issues
    repeat
        Sleep(0.1)
    until QuestionableIsRunning() -- Wait for quest to fully start

    -- Initialize stuck checker variables
    local stuck_check_interval = 0.50   -- Time between stuck checks
    local stuck_threshold_seconds = 4.0 -- Time before considering stuck
    local min_progress_distance = 0.1   -- Minimum distance to be considered as progress

    local stuck_timer = 0
    local previous_position = {
        x = GetPlayerRawXPos(),
        y = GetPlayerRawYPos(),
        z = GetPlayerRawZPos()
    }

    -- Function to handle stuck checks
    local function CheckIfStuck()
        -- Loop continuously while the quest is incomplete
        while not IsQuestComplete(tonumber(quest_key)) do
            Sleep(stuck_check_interval)

            -- If player is busy or in a zone transition, reset the stuck timer and skip
            if not IsPlayerAvailable() or IsPlayerCasting() or GetCharacterCondition(26) or GetCharacterCondition(32) then
                stuck_timer = 0 -- Reset stuck timer
                previous_position = { -- Reset position for next check
                    x = GetPlayerRawXPos(),
                    y = GetPlayerRawYPos(),
                    z = GetPlayerRawZPos()
                }
                -- Wait for the player to be available again
                repeat
                    Sleep(0.1)
                until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26) and not GetCharacterCondition(32) and not (GetCharacterCondition(31) or GetCharacterCondition(32))
            end

            -- Handle zone transitions
            if GetCharacterCondition(45) or GetCharacterCondition(51) then
                previous_position = { -- Reset position tracking
                    x = GetPlayerRawXPos(),
                    y = GetPlayerRawYPos(),
                    z = GetPlayerRawZPos()
                }
                stuck_timer = 0 -- Reset stuck timer

                -- Wait until the player finishes zoning
                repeat
                    Sleep(0.1)
                until not GetCharacterCondition(45) and not GetCharacterCondition(51)

                -- After zoning, reload navmesh and questionable
                NavReload()
                
                -- Check if the quest has been accepted and reloads, otherwise it will loop forever
                if IsQuestNameAccepted(quest_do_name) then
                    yield("/qst reload")
                else
                    -- Retry quest start if it hasn't been accepted yet
                    yield("/qst next " .. quest_id)
                    
                    repeat
                        Sleep(0.1)
                    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
                    
                    yield("/qst start")
                end
            end

            -- Calculate player's movement since last check
            local current_position = {
                x = GetPlayerRawXPos(),
                y = GetPlayerRawYPos(),
                z = GetPlayerRawZPos()
            }
            local dx = current_position.x - previous_position.x
            local dy = current_position.y - previous_position.y
            local dz = current_position.z - previous_position.z
            local distance_moved_squared = dx * dx + dy * dy + dz * dz

            -- If the player hasn't moved far enough, increase the stuck timer
            if distance_moved_squared < min_progress_distance * min_progress_distance then
                stuck_timer = stuck_timer + stuck_check_interval
            else
                stuck_timer = 0 -- Reset stuck timer if progress is made
            end

            -- If stuck for too long, attempt to resolve by jumping and reloading quest data
            if stuck_timer >= stuck_threshold_seconds then
                DoGeneralAction("Jump") -- Try jumping to get unstuck
                Sleep(0.1)
                NavReload() -- Reload Navmesh
                
                -- Check if the quest has been accepted, otherwise it will loop forever
                if IsQuestNameAccepted(quest_do_name) then
                    NavReload() -- Reload Navmesh
                    yield("/qst reload") -- Reload quest data
                else
                    -- If the quest hasn't been accepted, retry quest start
                    yield("/qst next " .. quest_id)
                    repeat
                        Sleep(0.1)
                    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
                    yield("/qst start")
                end

                -- Wait until navigation and quest are ready
                repeat
                    Sleep(0.05)
                until NavIsReady() or QuestionableIsRunning()

                stuck_timer = 0 -- Reset stuck timer after reloading
            end

            -- Update the previous position for the next check
            previous_position = current_position
            
            -- Exit the function if ContentsFinder and Entrance exist so stuck checker loop ends
            if IsAddonVisible("ContentsFinder") and DoesObjectExist("Entrance") then
                return
            end
        end
    end

    -- Run the stuck checker while waiting for the quest to complete
    while not IsQuestComplete(tonumber(quest_key)) do
        Sleep(0.1)

        -- Check if the player is available and not busy before running the stuck checker
        if IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26) and not GetCharacterCondition(32) then
            CheckIfStuck() -- Run the stuck checker
        end
        
        -- Exit the function if ContentsFinder and Entrance exist so stuck checker loop ends
        if IsAddonVisible("ContentsFinder") and DoesObjectExist("Entrance") then
            return
        end
    end

    -- Ensure the quest is fully completed before ending
    Sleep(0.5)

    -- Clear the quest values after completion
    quest_id = nil
    quest_key = nil

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

-- Usage: AutoDutyRun("Sastasha")
-- 
-- Runs a dungeon once through AutoDuty
function AutoDutyRun(duty)
    duty = tostring(duty)
    local duty_id = FindDutyID(duty)
    yield("/autoduty run support " .. duty_id .. " 1")
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
        if IsAddonReady("ContentsFinder") then
            yield("/callback ContentsFinder true 1 " .. duty_finder_tab_number)
        end
        Sleep(0.1)
    until IsAddonVisible("JournalDetail")

    -- Clear the duty selection
    repeat
        if IsAddonReady("ContentsFinder") then
            yield("/callback ContentsFinder true 12 1")
        end
        Sleep(0.1)
    until IsAddonVisible("ContentsFinder")

    -- Pick the duty
    repeat
        if IsAddonReady("ContentsFinder") then
            yield("/callback ContentsFinder true 3 " .. duty_finder_number)
        end
        Sleep(0.1)
    until IsAddonVisible("ContentsFinder")

    -- Take note of current ZoneID to know when duty is over later
    Sleep(0.1)
    local current_zone_id = GetZoneID()

    -- Queue the duty
    repeat
        if IsAddonReady("ContentsFinder") then
            yield("/callback ContentsFinder true 12 0")
        end
        Sleep(0.1)
    until IsAddonVisible("ContentsFinderConfirm")

    -- Accept the duty
    repeat
        if IsAddonReady("ContentsFinderConfirm") then
            yield("/callback ContentsFinderConfirm true 8")
        end
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
    local duty_finder_settings = { ... }

    -- Open duty finder
    repeat
        yield("/dutyfinder")
        Sleep(0.1)
    until IsAddonVisible("ContentsFinder")

    -- Open duty finder settings
    repeat
        if IsAddonReady("ContentsFinder") then
            yield("/callback ContentsFinder true 15")
        end
        Sleep(0.1)
    until IsAddonVisible("ContentsFinderSetting")

    -- Loop through each setting and apply it
    for _, setting_number in ipairs(duty_finder_settings) do
        repeat
            if IsAddonReady("ContentsFinderSetting") then
                yield("/callback ContentsFinderSetting true 1 " .. setting_number .. " 1")
            end
            Sleep(0.1)
        until IsAddonVisible("ContentsFinderSetting")
    end

    -- Close duty finder settings
    repeat
        if IsAddonReady("ContentsFinderSetting") then
            yield("/callback ContentsFinderSetting true 0")
        end
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
        if IsAddonReady("ContentsFinder") then
            yield("/callback ContentsFinder true 15")
        end
        Sleep(0.1)
    until IsAddonVisible("ContentsFinderSetting")

    -- Iterate through all settings (0-8) and clear them
    for setting_number = 0, 8 do
        repeat
            if IsAddonReady("ContentsFinderSetting") then
                yield("/callback ContentsFinderSetting true 1 " .. setting_number .. " 0")
            end
            Sleep(0.1)
        until IsAddonVisible("ContentsFinderSetting")
    end

    -- Close duty finder settings
    repeat
        if IsAddonReady("ContentsFinderSetting") then
            yield("/callback ContentsFinderSetting true 0")
        end
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
    if not Item_List then
        LogInfo("[VAC] Item_List is nil. Cannot set items.")
        return
    end
    
    -- Gil cap or specified gil amount
    local gil = dropbox_gil or 999999999
    
    -- Maximum quantity for items (999 * 140)
    local max_quantity = 139860
    
    -- Iterate over the Item_List
    for id, item in pairs(Item_List) do
        -- Check if the item is tradeable
        if not item['Untradeable'] then
            if id == 1 then
                -- Set gil to gil cap or specified gil amount
                DropboxSetItemQuantity(id, false, gil)
            elseif id < 2 or id > 19 then -- Excludes Shards, Crystals, and Clusters
                -- Set all item ID except 2-19
                DropboxSetItemQuantity(id, false, max_quantity) -- NQ
                DropboxSetItemQuantity(id, true, max_quantity)  -- HQ
            end
        end
    
        Sleep(0.0001)
    end
end

-- Usage: DropboxClearAll()
-- Clears all items in Dropbox plugin
function DropboxClearAll()
    if not Item_List then
        LogInfo("[VAC] Item_List is nil. Cannot clear items.")
        return
    end

    for id, item in pairs(Item_List) do
        if not item['Untradeable'] then
            DropboxSetItemQuantity(id, false, 0) -- NQ
            DropboxSetItemQuantity(id, true, 0)  -- HQ
        end
        Sleep(0.0001)
    end
end

-- Usage: IsQuestNameAccepted("Hello Halatali.")
-- Checks if quest name is accepted
function IsQuestNameAccepted(quest_accepted_name)
    if not quest_accepted_name or quest_accepted_name == "" then
        return nil -- Return nil if the quest_accepted_name is nil or an empty string
    end

    for key, entry in pairs(Quest_List) do
        if string.lower(entry['Name']) == string.lower(quest_accepted_name) then
            return IsQuestAccepted(tonumber(key))
        end
    end
    return nil -- Return nil if the name isn't found
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
            for index, job in ipairs(Job_List) do
                if job["Abbreviation"] == abbreviation then
                    return tonumber(GetLevel(job["ExpArrayIndex"]))
                end
            end
            return "Unknown job"
        end
        return findJobXPByAbbreviation(job) or "Unknown job"
    elseif type(job) ~= nil then
        return tonumber(GetLevel(Job_List[job]["ExpArrayIndex"]))
    end
end

-- Usage: ReturnHomeWorld()
-- Checks if player is not on home world and returns Home
-- ZoneTransitions() not required to be called after
function ReturnHomeWorld()
    local homeworld = FindWorldByID(GetHomeWorld())
    Echo("Attempting to return to " .. homeworld)

    if GetCurrentWorld() ~= GetHomeWorld() then
        Teleporter(homeworld, "li")
    end

    repeat
        Sleep(0.1)
    until GetCurrentWorld() == GetHomeWorld() and IsPlayerAvailable() and not LifestreamIsBusy()
end

-- Usage: CheckPluginsEnabled("AutoRetainer") or CheckPluginsEnabled("AutoRetainer", "TeleporterPlugin", "Lifestream")
-- Can take an infinite amount of plugin strings
-- Will check if the player has the specified plugins installed/enabled and echoes enabled + disabled plugins
-- If statement can be used
function CheckPluginsEnabled(...)
    local enabled_plugins = {}
    local missing_plugins = {}

    -- Pass all arguments into a table
    local plugins = { ... }

    for _, plugin_name in ipairs(plugins) do
        if HasPlugin(plugin_name) then
            table.insert(enabled_plugins, plugin_name)
        else
            table.insert(missing_plugins, plugin_name)
        end
    end

    -- Sort the plugin names a-z
    table.sort(enabled_plugins)
    table.sort(missing_plugins)

    -- Echo enabled plugins
    if #enabled_plugins > 0 then
        LogInfo("[VAC] Enabled plugins: " .. table.concat(enabled_plugins, ", "))
        Echo("Enabled plugins: " .. table.concat(enabled_plugins, ", "))
    else
        LogInfo("[VAC] No plugins are enabled.")
        Echo("No plugins are enabled.")
    end

    -- Echo missing plugins
    if #missing_plugins > 0 then
        LogInfo("[VAC] Missing or not enabled plugins: " .. table.concat(missing_plugins, ", "))
        Echo("Missing or not enabled plugins: " .. table.concat(missing_plugins, ", "))
        return false -- Returns false to be used with if statements to stop script
    else
        LogInfo("[VAC] All plugins are enabled.")
        Echo("All plugins are enabled.")
        return true -- Returns true be used with if statements to start script
    end
end

-- Usage: FindItemID("Copper")
--
-- Searches the item list for an item and returns its id, not case sensitive but you need the full item name
function FindItemID(item_to_find)
    local search_term = string.lower(item_to_find)

    for key, item in pairs(Item_List) do
        local item_name = string.lower(item['Name'])

        if item_name == search_term then
            return key
        end
    end
    return nil
end

-- Usage: FindItemName(1)
-- Searches the item list for an item and returns its name, inverse of FindItemID()
function FindItemName(item_id)
    -- Check if the item ID exists in the Item_List
    if Item_List[item_id] then
        -- Return the item name if the item ID is valid
        return Item_List[item_id]['Name']
    else
        -- Return nil if the item ID does not exist
        return nil
    end
end

-- Usage: IsAetheryteAttuned("Limsa Lominsa")
-- Will check whether player has specified aetheryte attuned
-- Returns true or false
function IsAetheryteAttuned(aetheryte_attuned_name)
    -- Validate input
    if not aetheryte_attuned_name or aetheryte_attuned_name == "" then
        LogInfo("[VAC] IsAetheryteAttuned: Aetheryte name is missing or empty.")
        Echo("Aetheryte name is missing or empty.")
        return false
    end

    -- Convert the input name to lowercase
    local aetheryte_attuned_name = string.lower(aetheryte_attuned_name)

    -- Find the Aetheryte ID by name
    local aetheryte_id = FindAetheryteIDByName(aetheryte_attuned_name)
    
    -- If Aetheryte ID is not found
    if not aetheryte_id then
        LogInfo("[VAC] IsAetheryteAttuned: Aetheryte '" .. aetheryte_attuned_name .. "' not found.")
        Echo("Aetheryte '" .. aetheryte_attuned_name .. "' not found.")
        return false
    end

    -- Check if the Aetheryte is unlocked/attuned
    if IsAetheryteUnlocked(aetheryte_id) then
        return true
    else
        return false
    end
end

-- Usage: GetLocalTime()
-- Returns local time in HH:MM:SS format
function GetLocalTime()
    return os.date("%H:%M:%S")
end

-- Usage: GetServerTime()
-- Returns UTC time in HH:MM:SS format
function GetServerTime()
    return os.date("!%H:%M:%S")
end

-- Usage: GetEorzeanTime()
-- Returns Eorzean Time in HH:MM:SS format
function GetEorzeanTime()
    local eorzean_time = os.time() * 3600 / 175
    return string.format("%02d:%02d:%02d", 
        math.floor(eorzean_time / 3600) % 24, 
        math.floor(eorzean_time / 60) % 60, 
        math.floor(eorzean_time) % 60)
end

-- Usage: ReturnTeleport()
-- Uses /return action to return to aetheryte location
function ReturnTeleport()
    -- Initial check to ensure player can teleport
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26) and not GetCharacterCondition(32)

    yield("/return")
    
    repeat
        Sleep(0.1)
    until IsAddonVisible("SelectYesno")

    yield("/pcall SelectYesno true 0")

    repeat
        Sleep(0.1)
    until not IsAddonVisible("SelectYesno")

    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)

    -- Wait for a zone transition to complete
    repeat
        Sleep(0.1)
    until GetCharacterCondition(45) or GetCharacterCondition(51)

    -- Once zone change has happened, wait until the conditions turn false
    repeat
        Sleep(0.1)
    until not GetCharacterCondition(45) and not GetCharacterCondition(51)

    Sleep(0.5)
end

-- Usage: IsTeleportUnlocked()
-- Checks if player has teleport unlocked
function IsTeleportUnlocked()
    local aetheryte_list = GetAetheryteList()

    -- Check if aetheryte_list is nil, empty, or has a count less than 2
    if aetheryte_list and aetheryte_list.Count and aetheryte_list.Count >= 2 then
        return true
    else
        return false
    end
end

-- Usage: AttuneAethernetShard()
-- Attunes with the Aethernet Shard, exits out of menus if already attuned
function AttuneAethernetShard()
    -- Wait until the player is ready to interact
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26) and not IsMoving() and not (GetCharacterCondition(45) or GetCharacterCondition(51))

    -- Target and interact with the Aethernet Shard
    Target("Aethernet Shard")
    Sleep(0.1)
    Interact()

    -- If the player is already attuned, exit the menu
    if (GetCharacterCondition(31) or GetCharacterCondition(32)) and IsAddonVisible("TelepotTown") then
        repeat
            Sleep(0.1)
        until IsAddonVisible("TelepotTown")

        Sleep(0.5)
        yield("/pcall TelepotTown true 1")

        -- Wait until the menu is no longer visible
        repeat
            Sleep(0.1)
        until not IsAddonVisible("TelepotTown")
    end

    -- Wait until player is available
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not (GetCharacterCondition(31) or GetCharacterCondition(32))
    
    Sleep(1.0)
end

-- Usage: GetCharacterLevel()
-- Encapsulates the GetLevel() snd function with better handling
-- Returns the player level
function GetCharacterLevel()
    -- Check for conditions where the level might not be accessible due to changing zones
    if GetCharacterCondition(45) or GetCharacterCondition(51) then
        return nil -- Return nil if the player is changing zones
    end

    local player_level = GetLevel()

    -- Check if we have a number, if not return nil
    if type(player_level) ~= "number" then
        return nil
    end

    return player_level
end

-- Usage: ExitGame()
-- Exits the game
function ExitGame()
    yield("/shutdown")

    repeat
        Sleep(0.1)
    until IsAddonVisible("SelectYesno")

    yield("/pcall SelectYesno true 0")

    repeat
        Sleep(0.1)
    until not IsAddonVisible("SelectYesno")
end

-- Usage: GetSubmersibleParts()
-- Will return the currently open submersible components from the "CompanyCraftSupply" Addon menu in abbreviation form such as SSSS
-- Requires Addon "CompanyCraftSupply" to be visible
function GetSubmersibleParts()
    if IsAddonVisible("CompanyCraftSupply") then
        -- Target totals to be used to match parts
        local target_favor = tonumber(GetNodeText("CompanyCraftSupply", 5, 3)) or 0
        local target_range = tonumber(GetNodeText("CompanyCraftSupply", 6, 3)) or 0
        local target_speed = tonumber(GetNodeText("CompanyCraftSupply", 7, 3)) or 0
        local target_retrieval = tonumber(GetNodeText("CompanyCraftSupply", 8, 3)) or 0
        local target_surveillance = tonumber(GetNodeText("CompanyCraftSupply", 9, 3)) or 0

        local num_parts = #Submersible_Part_List

        for hull = 1, num_parts do
            for stern = 1, num_parts do
                for bow = 1, num_parts do
                    for bridge = 1, num_parts do
                        -- Check if the parts are of the correct type for each slot
                        if Submersible_Part_List[hull].SlotName == "Hull" and
                           Submersible_Part_List[stern].SlotName == "Stern" and
                           Submersible_Part_List[bow].SlotName == "Bow" and
                           Submersible_Part_List[bridge].SlotName == "Bridge" then
                            
                            local total_favor = Submersible_Part_List[hull].Favor + Submersible_Part_List[stern].Favor + Submersible_Part_List[bow].Favor + Submersible_Part_List[bridge].Favor
                            local total_range = Submersible_Part_List[hull].Range + Submersible_Part_List[stern].Range + Submersible_Part_List[bow].Range + Submersible_Part_List[bridge].Range
                            local total_speed = Submersible_Part_List[hull].Speed + Submersible_Part_List[stern].Speed + Submersible_Part_List[bow].Speed + Submersible_Part_List[bridge].Speed
                            local total_retrieval = Submersible_Part_List[hull].Retrieval + Submersible_Part_List[stern].Retrieval + Submersible_Part_List[bow].Retrieval + Submersible_Part_List[bridge].Retrieval
                            local total_surveillance = Submersible_Part_List[hull].Surveillance + Submersible_Part_List[stern].Surveillance + Submersible_Part_List[bow].Surveillance + Submersible_Part_List[bridge].Surveillance

                            if total_favor == target_favor and
                               total_range == target_range and
                               total_speed == target_speed and
                               total_retrieval == target_retrieval and
                               total_surveillance == target_surveillance then
                                
                                local function get_abbreviation(part)
                                    if part.PartName:find("Modified") then
                                        return part.PartAbbreviation
                                    else
                                        return part.PartAbbreviation:sub(1,1)  -- Return first letter if not modified
                                    end
                                end

                                local abbreviations = {
                                    get_abbreviation(Submersible_Part_List[hull]),
                                    get_abbreviation(Submersible_Part_List[stern]),
                                    get_abbreviation(Submersible_Part_List[bow]),
                                    get_abbreviation(Submersible_Part_List[bridge])
                                }

                                local abbreviation = table.concat(abbreviations)
                                local modified_count = select(2, abbreviation:gsub("%+", ""))

                                if modified_count == 4 then
                                    abbreviation = abbreviation:gsub("%+", "") .. "++"
                                end

                                LogInfo("[VAC] (GetSubmersibleParts) Matching Parts Found: " .. abbreviation)
                                LogInfo("[VAC] (GetSubmersibleParts) Hull: " .. Submersible_Part_List[hull].PartName)
                                LogInfo("[VAC] (GetSubmersibleParts) Stern: " .. Submersible_Part_List[stern].PartName)
                                LogInfo("[VAC] (GetSubmersibleParts) Bow: " .. Submersible_Part_List[bow].PartName)
                                LogInfo("[VAC] (GetSubmersibleParts) Bridge: " .. Submersible_Part_List[bridge].PartName)
                                LogInfo("[VAC] (GetSubmersibleParts) Total Favor: " .. total_favor)
                                LogInfo("[VAC] (GetSubmersibleParts) Total Range: " .. total_range)
                                LogInfo("[VAC] (GetSubmersibleParts) Total Speed: " .. total_speed)
                                LogInfo("[VAC] (GetSubmersibleParts) Total Retrieval: " .. total_retrieval)
                                LogInfo("[VAC] (GetSubmersibleParts) Total Surveillance: " .. total_surveillance)
                                
                                return abbreviation--[[{
                                    abbreviation = abbreviation,
                                    hull = Submersible_Part_List[hull],
                                    stern = Submersible_Part_List[stern],
                                    bow = Submersible_Part_List[bow],
                                    bridge = Submersible_Part_List[bridge],
                                    totals = {
                                        favor = total_favor,
                                        range = total_range,
                                        speed = total_speed,
                                        retrieval = total_retrieval,
                                        surveillance = total_surveillance
                                    }
                                }--]]
                            end
                        end
                    end
                end
            end
        end
        LogInfo("[VAC] (GetSubmersibleParts) No matching combination found.")
        return nil
    else
        LogInfo('[VAC] (GetSubmersibleParts) Addon "CompanyCraftSupply" not visible.')
        return nil
    end
end

-- Usage: GetSubmersibleRank() or GetSubmersibleRank(1)
-- Will return the submersible rank from either the "CompanyCraftSupply" or "SelectString" Addon menus
-- Works with both "SelectString" Addon menus that display all submersibles and individual submersibles
-- If using "SelectString" for displaying all submersibles, then specifying a submersible number is required
-- Options: 1-4 to select a submersible, defaults to 1 if empty
function GetSubmersibleRank(sub_number)
    if IsAddonVisible("CompanyCraftSupply") then
        local sub_rank = tonumber(GetNodeText("CompanyCraftSupply", 40)) or 0
        return sub_rank or 0
    end
    
    if IsAddonVisible("SelectString") then
        local node_text = tostring(GetNodeText("SelectString", 3)) or ""
        local sub_rank_number = tonumber(node_text:match("%(Rank: (%d+)%)"))
        
        if sub_rank_number and sub_rank_number ~= "" then
            return sub_rank_number or 0
        else
            -- Ensure sub_number is 1, 2, 3, or 4 and exit if not
            local sub_number = tonumber(sub_number) or 1

            if not sub_number or sub_number < 1 or sub_number > 4 then
                LogInfo("[VAC] (SelectSubmersible) sub_number is not between 1 and 4")
                return
            end

            local sub_rank_text = tostring(GetNodeText("SelectString", 2, sub_number, 3)) or ""
            
            -- "SelectString" multiple submersible menu
            if node_text:match("Select a submersible%.$") and sub_rank_text:match("%(Rank:%s%d+%)") then
                sub_rank_number = sub_rank_text:match("%(Rank:%s(%d+)%)")
                return sub_rank_number or 0
            end
        end
    end
    
    return 0 -- Default return if no conditions are met
end

-- Usage: GetSubmersibleName() or GetSubmersibleName(1)
-- Will return the submersible name from either the "CompanyCraftSupply" or "SelectString" Addon menus
-- Works with both "SelectString" Addon menus that display all submersibles and individual submersibles
-- If using "SelectString" for displaying all submersibles, then specifying a submersible number is required
-- Options: 1-4 to select a submersible, defaults to 1 if empty
function GetSubmersibleName(sub_number)
    -- Check if CompanyCraftSupply addon is visible and return its node text if so
    if IsAddonVisible("CompanyCraftSupply") then
        return GetNodeText("CompanyCraftSupply", 42) or ""
    end
    -- Return empty string if SelectString addon is not visible
    if not IsAddonVisible("SelectString") then return "" end

    -- Get text from SelectString addon
    local node_text = GetNodeText("SelectString", 3) or ""

    -- Helper function to extract and clean submersible name
    local extract_name = function(text, remove_last_dot)
        local name = text:match("^(.-)%s*%(Rank:") or text:match("^(.-)%s*%-") or text
        name = name:match("^%s*(.-)%s*$"):gsub(remove_last_dot and "%.$" or "$", "")
        return name
    end

    -- Check if it's a multiple submersible selection menu
    local is_multiple_menu = node_text:match("Select a submersible%.$")
    local sub_name

    if is_multiple_menu then
        -- Handle multiple menu case
        sub_number = tonumber(sub_number) or 1
        if sub_number < 1 or sub_number > 4 then return "" end
        sub_name = GetNodeText("SelectString", 2, sub_number, 3)
    else
        -- Handle single menu case
        for line in node_text:gmatch("[^\r\n]+") do
            if not line:match("^Ceruleum tanks:") and not line:match("^Vessels deployed:") then
                sub_name = line
                break
            end
        end
    end

    -- Extract and return the submersible name, or empty string if not found
    return sub_name and extract_name(sub_name, is_multiple_menu) or ""
end

-- Usage: GetSubmersibleExperience()
-- Will return the currently open submersible experience from the "CompanyCraftSupply" Addon menu
-- "SelectString" Addon menus do not contain this information so it can only be used in the "CompanyCraftSupply" Addon menu
function GetSubmersibleExperience()
    if IsAddonVisible("CompanyCraftSupply") then
        local exp_text = GetNodeText("CompanyCraftSupply", 39)

        if exp_text then
            -- Extract the current experience value using pattern matching
            local current_exp = exp_text:match("EXP:%s*(%d+)/")
            
            if current_exp then
                LogInfo('[VAC] (GetSubmersibleExperience) Submersible "' .. GetSubmersibleName() .. '" has ' .. current_exp .. ' experience')
                return tonumber(current_exp)
            else
                LogInfo("[VAC] (GetSubmersibleExperience) Failed to parse experience value from: " .. exp_text)
            end
        else
            LogInfo('[VAC] (GetSubmersibleExperience) Failed to get experience text from "CompanyCraftSupply"')
        end
    else
        LogInfo('[VAC] (GetSubmersibleExperience) "CompanyCraftSupply" addon is not visible')
    end

    return 0 -- Return 0 if we couldn't get or parse the experience value
end

-- Usage: SelectSubmersible(1)
-- Will select the specified submersible and select the string to open it
-- Requires Addon "SelectString" to be visible
-- Options: 1-4 to select a submersible, defaults to 1 if empty
function SelectSubmersible(sub_number)
    -- Ensure sub_number is 1, 2, 3, or 4 and exit if not
    local sub_number = tonumber(sub_number)

    if not sub_number or sub_number < 1 or sub_number > 4 then
        LogInfo("[VAC] (SelectSubmersible) sub_number is not between 1 and 4")
        return
    end

    -- Adjust sub_number to be zero-indexed since the menu starts at 0
    sub_number = sub_number - 1

    if IsAddonVisible("SelectString") and GetNodeText("SelectString", 3):match("Select a submersible%.$") then
        yield("/pcall SelectString true " .. sub_number)

        -- Wait for the SelectString menu to show "Quit"
        while IsAddonVisible("SelectString") do
            local node_text_5 = GetNodeText("SelectString", 2, 5, 3)
            local node_text_7 = GetNodeText("SelectString", 2, 7, 3)

            if node_text_5 == "Quit" or node_text_7 == "Quit" then
                break
            end
            Sleep(0.1)
        end
        LogInfo("[VAC] (SelectSubmersible) Opened submersible slot " .. sub_number)
    else
        LogInfo('[VAC] (SelectSubmersible) "SelectString" addon is not visible')
    end
end

-- Usage: ChangeSubmersibleParts("SSSS")
-- Will change the current submersible components by specified part abbreviation
-- Case insensitive
-- Requires Addon "CompanyCraftSupply" to be visible
function ChangeSubmersibleParts(desired_parts)
    if not IsAddonVisible("CompanyCraftSupply") then
        LogInfo("[VAC] (ChangeSubmersibleParts) CompanyCraftSupply addon is not visible.")
        return false
    end

    local current_parts = GetSubmersibleParts()

    if not current_parts then
        LogInfo("[VAC] (ChangeSubmersibleParts) Failed to get current submersible parts.")
        return false
    end

    desired_parts = string.upper(desired_parts)

    if current_parts == desired_parts then
        LogInfo("[VAC] (ChangeSubmersibleParts) Submersible parts already match the desired configuration.")
        return true
    end

    local part_slots = {
        { menu_options = "2 1 0", name = "Hull", index = 1 },
        { menu_options = "2 1 1", name = "Stern", index = 2 },
        { menu_options = "2 1 2", name = "Bow", index = 3 },
        { menu_options = "2 1 3", name = "Bridge", index = 4 }
    }

    for _, slot in ipairs(part_slots) do
        local current_part = current_parts:sub(slot.index, slot.index)
        local desired_part = desired_parts:sub(slot.index, slot.index)

        if current_part ~= desired_part then
            LogInfo(string.format("[VAC] (ChangeSubmersibleParts) Changing %s from %s to %s", slot.name, current_part, desired_part))

            -- Amount of parts to try (Node capacity)
            for attempt = 1, 35 do
                -- Open the parts menu for the current slot
                if IsAddonReady("CompanyCraftSupply") then
                    yield("/callback CompanyCraftSupply true " .. slot.menu_options)
                end

                -- Wait for the menu to appear
                local menu_appeared = false

                for _ = 1, 10 do
                    if IsAddonVisible("ContextIconMenu") then
                        menu_appeared = true
                        break
                    end
                    Sleep(0.5)
                end

                if not menu_appeared then
                    LogInfo(string.format("[VAC] (ChangeSubmersibleParts) Failed to open menu for %s", slot.name))
                    return false
                end

                -- Try changing the part
                if IsAddonReady("ContextIconMenu") then
                    yield("/callback ContextIconMenu true 0 " .. (attempt - 1))
                end

                -- Wait for the menu to disappear
                local menu_disappeared = false

                for _ = 1, 10 do
                    if not IsAddonVisible("ContextIconMenu") then
                        menu_disappeared = true
                        break
                    end
                    Sleep(0.5)
                end

                if not menu_disappeared then
                    LogInfo(string.format("[VAC] (ChangeSubmersibleParts) Menu didn't close for %s (Attempt %d)", slot.name, attempt))
                    break
                end

                Sleep(0.5) -- Delay after menu closes

                -- Check if the part has been changed correctly
                local new_parts = GetSubmersibleParts()

                if not new_parts then
                    LogInfo("[VAC] (ChangeSubmersibleParts) Failed to get updated submersible parts.")
                    return false
                end

                if new_parts:sub(slot.index, slot.index) == desired_part then
                    LogInfo(string.format("[VAC] (ChangeSubmersibleParts) Successfully changed %s to %s", slot.name, desired_part))
                    break
                end

                -- If this is not the last attempt, prepare for the next attempt
                if attempt < 4 then
                    Sleep(0.5) -- Delay before next attempt
                else
                    LogInfo(string.format("[VAC] (ChangeSubmersibleParts) Failed to change %s to %s after all attempts", slot.name, desired_part))
                    return false
                end
            end
        end

        -- Check if all parts are correct after each change
        current_parts = GetSubmersibleParts()
        
        if not current_parts then
            LogInfo("[VAC] (ChangeSubmersibleParts) Failed to get updated submersible parts.")
            return false
        end
        
        if current_parts == desired_parts then
            LogInfo("[VAC] (ChangeSubmersibleParts) Successfully changed submersible parts to: " .. desired_parts)
            return true
        end
    end

    LogInfo("[VAC] (ChangeSubmersibleParts) Failed to change submersible parts to: " .. desired_parts)
    return false
end

-- Usage: RegisterNewSubmersible()
-- Will attempt to register any available submarines
-- Requires Addon "SelectString" to be visible
function RegisterNewSubmersible()
    if not IsAddonReady("SelectString") and not GetNodeText("SelectString", 3):match("Select a submersible%.$") then
        LogInfo("[VAC] (RegisterNewSubmersible) Not in the right SelectString menu")
        return
    end
    for i = 1, 4 do
        local node_text = GetNodeText("SelectString", 2, i, 3)

        if node_text:match("Outfit and register a submersible%.") then
            LogInfo("[VAC] (RegisterNewSubmersible) Submarine " .. i .. " possible to register, checking if we have the required parts")

            local required_items = { -- List of all items needed for creating a submersible
                { id = 21794, name = "Shark-class Pressure Hull" },
                { id = 21795, name = "Shark-class Stern" },
                { id = 21792, name = "Shark-class Bow" },
                { id = 21793, name = "Shark-class Bridge" },
                { id = 22317, name = "Dive Credit" }
            }

            -- Check how many dive credits we need for the submersible
            local needed_dive_credits = 99 -- placeholder until it gets set below
            if i == 1 then
                needed_dive_credits = 1
            elseif i == 2 then
                needed_dive_credits = 3
            elseif i == 3 then
                needed_dive_credits = 5
            elseif i == 4 then
                needed_dive_credits = 7
            end

            -- Variable that will be set to false if we're missing any item
            local enough_items = true

            for _, item in ipairs(required_items) do
                LogInfo("[VAC] (RegisterNewSubmersible) Checking if we have enough of " .. item.name)

                if item.name == "Dive Credit" then -- special handling for dive credits
                    local current_dive_credits = GetItemCount(item.id)
                    LogInfo("[VAC] (RegisterNewSubmersible) Found " .. current_dive_credits .. " " .. item.name .. ". We need " .. needed_dive_credits)

                    if current_dive_credits >= needed_dive_credits then
                        LogInfo("[VAC] (RegisterNewSubmersible) We have enough Dive Credits")
                    else
                        LogInfo("[VAC] (RegisterNewSubmersible) Not enough Dive Credits")
                        Echo("Missing " .. needed_dive_credits .. " Dive Credits")
                        enough_items = false
                    end

                else
                    local item_count = GetItemCount(item.id)
                    LogInfo("[VAC] (RegisterNewSubmersible) Found " .. item_count .. " " .. item.name)

                    if item_count >= 1 then
                        LogInfo("[VAC] (RegisterNewSubmersible) Found " .. item.name)
                    else
                        LogInfo("[VAC] (RegisterNewSubmersible) Missing " .. item.name)
                        enough_items = false
                    end
                end
                Sleep(0.001)
            end
            if enough_items then
                LogInfo("[VAC] (RegisterNewSubmersible) Can register submersible number " .. i)
                LogInfo("[VAC] (RegisterNewSubmersible) Attempting to register submersible number " .. i)

                yield("/callback SelectString true " .. (i - 1)) -- Open the "CompanyCraftSupply" addon so we can register the submarine

                repeat
                    Sleep(0.1)
                until IsAddonReady("CompanyCraftSupply") -- Wait for the "CompanyCraftSupply" addon to be ready

                ChangeSubmersibleParts("SSSS") -- Put on the parts

                yield("/callback CompanyCraftSupply true 0") -- Click Register

                repeat
                    Sleep(0.1)
                until IsAddonReady("SelectYesno") -- Wait for the confirm menu to load

                yield("/callback SelectYesno true 0") -- Confirm submersible registration

                repeat
                    Sleep(0.1)
                until IsAddonReady("SelectString") -- Wait for the submersible selection menu to load properly

                for x = 1, 10 do -- Find Quit so we can go back to the submersible selection menu
                    local quit_text = GetNodeText("SelectString", 2, x, 3)
                    if quit_text == "Quit" then
                        yield("/callback SelectString true " .. (x - 1))
                        Sleep(0.5)
                        repeat
                            Sleep(0.1)
                        until IsAddonReady("SelectString")
                        break
                    end
                    Sleep(0.001)
                end
            else
                Echo("Missing items for submersible " .. i .. ". Skipping.")
            end
        else
            LogInfo("[VAC] (RegisterNewSubmersible) Submarine " .. i .. " unavailable")
        end
        Sleep(0.001)
    end
end

-- Usage: BuyCeruleum(999)
-- Will buy X amount of ceruleum from the Mammet Voyager inside the workshop
function BuyCeruleum(amount)
    if not amount then -- Check if anything was passed
        LogInfo("[VAC] (BuyCeruleum) Ceruleum amount missing")
        return
    end

    if not type(amount) == "number" then -- Chjeck if the input is a number
        LogInfo("[VAC] (BuyCeruleum) BuyCeruleum input not a number")
        return
    end

    if not IsPlayerAvailable() then
        LogInfo("[VAC] (BuyCeruleum) Player isn't available, cancelling ceruleum buy attempt")
        Echo("Player isn't available, cancelling ceruleum buy attempt")
        return
    end

    LogInfo("[VAC] (BuyCeruleum) Targeting the mammet")
    Target("Mammet Voyager #004A") -- Target the mammet we're buying ceruleum from

    yield("/lockon")
    Sleep(1)

    LogInfo("[VAC] (BuyCeruleum) Moving towards the mammet")
    yield("/automove") -- Move to the mammet, i don't want to rely on Movement() here
    Sleep(1)

    repeat
        Sleep(0.1)
    until not IsMoving() -- Wait until we're no longer moving
    LogInfo("[VAC] (BuyCeruleum) Attempting to talk to the mammet")
    Interact() -- Talk to the mammet

    repeat
        Sleep(0.1)
    until IsAddonReady("SelectIconString") -- Wait for the talk window to open
    yield("/callback SelectIconString true 0") -- Open the company credit exchange

    repeat
        Sleep(0.1)
    until IsAddonReady("FreeCompanyCreditShop") -- Waits for the company credit exchange to open

    local ceruleum_price = 100
    local current_fc_credits_str = GetNodeText("FreeCompanyCreditShop", 40)
    local current_fc_credits = tonumber(current_fc_credits_str:gsub(",", ""):match("%d+")) -- Remove commas from the string and convert it to a number

    if not current_fc_credits then
        LogInfo("[VAC] (BuyCeruleum) Failed to find current fc credit amount")
        yield("/callback FreeCompanyCreditShop true -1")
        return
    end

    local max_affordable_amount = math.floor(current_fc_credits / ceruleum_price)

    amount = math.min(amount, max_affordable_amount)

    if amount <= 0 then
        LogInfo("[VAC] (BuyCeruleum) Not enough credits to buy ceruleum")
        yield("/callback FreeCompanyCreditShop true -1")
        return
    end

    while amount > 0 do
        -- Limit the amount per buy to 999
        local buy_amount = math.min(amount, 999)

        LogInfo("[VAC] (BuyCeruleum) Buying " .. buy_amount .. " ceruleum")
        yield("/callback FreeCompanyCreditShop true 0 0 " .. buy_amount) -- Buy X amount of ceruleum
        repeat
            Sleep(0.01)
        until IsAddonReady("SelectYesno") -- Wait for confirm window

        yield("/callback SelectYesno true 0") -- Confirm
        repeat
            Sleep(0.01)
        until not IsAddonVisible("SelectYesno")

        amount = amount - buy_amount
    end
    LogInfo("[VAC] (BuyCeruleum) Finished buying ceruleum")
    yield("/callback FreeCompanyCreditShop true -1") -- Exit shop menu
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsAddonVisible("FreeCompanyCreditShop")
end

-- Usage: CreateJSONLibrary()
-- This contains the JSON parsing library for lua
-- Obtained from https://github.com/craigmj/json4lua

-- Copyright (c) 2009 Craig Mason-Jones

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

-- For full license text, see: https://github.com/craigmj/json4lua/blob/master/doc/LICENCE.txt

-- The inclusion of MIT-licensed code in this GPL-licensed project does not affect
-- the overall licensing of the project, which remains under the GNU GPL v3.
function CreateJSONLibrary()
    local json = {}

    do
       -----------------------------------------------------------------------------
       -- Imports and dependencies
       -----------------------------------------------------------------------------
       local math, string, table = require'math', require'string', require'table'
       local math_floor, math_max, math_type = math.floor, math.max, math.type or function() end
       local string_char, string_sub, string_find, string_match, string_gsub, string_format
          = string.char, string.sub, string.find, string.match, string.gsub, string.format
       local table_insert, table_remove, table_concat = table.insert, table.remove, table.concat
       local type, tostring, pairs, assert, error = type, tostring, pairs, assert, error
       local loadstring = loadstring or load

       -----------------------------------------------------------------------------
       -- Public functions
       -----------------------------------------------------------------------------
       -- function  json.encode(obj)       encodes Lua value to JSON, returns JSON as string.
       -- function  json.decode(s, pos)    decodes JSON, returns the decoded result as Lua value (may be very memory-consuming).

       --    Both functions json.encode() and json.decode() work with "special" Lua values json.null and json.empty
       --       special Lua value  json.null    =  JSON value  null
       --       special Lua value  json.empty   =  JSON value  {}     (empty JSON object)
       --       regular Lua empty table         =  JSON value  []     (empty JSON array)

       --    Empty JSON objects and JSON nulls require special handling upon sending (encoding).
       --       Please make sure that you send empty JSON objects as json.empty (instead of empty Lua table).
       --       Empty Lua tables will be encoded as empty JSON arrays, not as empty JSON objects!
       --          json.encode( {empt_obj = json.empty, empt_arr = {}} )   -->   {"empt_obj":{},"empt_arr":[]}
       --       Also make sure you send JSON nulls as json.null (instead of nil).
       --          json.encode( {correct = json.null, incorrect = nil} )   -->   {"correct":null}

       --    Empty JSON objects and JSON nulls require special handling upon receiving (decoding).
       --       After receiving the result of decoding, every Lua table returned (including nested tables) should firstly
       --       be compared with special Lua values json.empty/json.null prior to making operations on these values.
       --       If you don't need to distinguish between empty JSON objects and empty JSON arrays,
       --       json.empty may be replaced with newly created regular empty Lua table.
       --          v = (v == json.empty) and {} or v
       --       If you don't need special handling of JSON nulls, you may replace json.null with nil to make them disappear.
       --          if v == json.null then v = nil end

       -- Function  json.traverse(s, callback, pos)  traverses JSON using user-supplied callback function, returns nothing.
       --    Traverse is useful to reduce memory usage: no memory-consuming objects are being created in Lua while traversing.
       --    Each item found inside JSON will be sent to callback function passing the following arguments:
       --    (path, json_type, value, pos, pos_last)
       --       path      is array of nested JSON identifiers/indices, "path" is empty for root JSON element
       --       json_type is one of "null"/"boolean"/"number"/"string"/"array"/"object"
       --       value     is defined when json_type is "null"/"boolean"/"number"/"string", value == nil for "object"/"array"
       --       pos       is 1-based index of first character of current JSON element
       --       pos_last  is 1-based index of last character of current JSON element (defined only when "value" ~= nil)
       -- "path" table reference is the same on each callback invocation, but its content differs every time.
       --    Do not modify "path" array inside your callback function, use it as read-only.
       --    Do not save reference to "path" for future use (create shallow table copy instead).
       -- callback function should return a value, when it is invoked with argument "value" == nil
       --    a truthy value means user wants to decode this JSON object/array and create its Lua counterpart (this may be memory-consuming)
       --    a falsy value (or no value returned) means user wants to traverse through this JSON object/array
       --    (returned value is ignored when callback function is invoked with value ~= nil)

       -- Traverse examples:

       --    json.traverse([[ 42 ]], callback)
       --    will invoke callback 1 time:
       --                 path        json_type  value           pos  pos_last
       --                 ----------  ---------  --------------  ---  --------
       --       callback( {},         "number",  42,             2,   3   )
       --
       --    json.traverse([[ {"a":true, "b":null, "c":["one","two"], "d":{ "e":{}, "f":[] } } ]], callback)
       --    will invoke callback 9 times:
       --                 path        json_type  value           pos  pos_last
       --                 ----------  ---------  --------------  ---  --------
       --       callback( {},         "object",  nil,            2,   nil )
       --       callback( {"a"},      "boolean", true,           7,   10  )
       --       callback( {"b"},      "null",    json.null,      17,  20  )   -- special Lua value for JSON null
       --       callback( {"c"},      "array",   nil,            27,  nil )
       --       callback( {"c", 1},   "string",  "one",          28,  32  )
       --       callback( {"c", 2},   "string",  "two",          34,  38  )
       --       callback( {"d"},      "object",  nil,            46,  nil )
       --       callback( {"d", "e"}, "object",  nil,            52,  nil )
       --       callback( {"d", "f"}, "array",   nil,            60,  nil )
       --
       --    json.traverse([[ {"a":true, "b":null, "c":["one","two"], "d":{ "e":{}, "f":[] } } ]], callback)
       --    will invoke callback 9 times if callback returns true when invoked for array "c" and object "e":
       --                 path        json_type  value           pos  pos_last
       --                 ----------  ---------  --------------  ---  --------
       --       callback( {},         "object",  nil,            2,   nil )
       --       callback( {"a"},      "boolean", true,           7,   10  )
       --       callback( {"b"},      "null",    json.null,      17,  20  )
       --       callback( {"c"},      "array",   nil,            27,  nil )  -- this callback returned true (user wants to decode this array)
       --       callback( {"c"},      "array",   {"one", "two"}, 27,  39  )  -- the next invocation brings the result of decoding
       --       callback( {"d"},      "object",  nil,            46,  nil )
       --       callback( {"d", "e"}, "object",  nil,            52,  nil )  -- this callback returned true (user wants to decode this object)
       --       callback( {"d", "e"}, "object",  json.empty,     52,  53  )  -- the next invocation brings the result of decoding (special Lua value for empty JSON object)
       --       callback( {"d", "f"}, "array",   nil,            60,  nil )


       -- Both decoder functions json.decode(s) and json.traverse(s, callback) can accept JSON (argument s)
       --    as a "loader function" instead of a string.
       --    This function will be called repeatedly to return next parts (substrings) of JSON.
       --    An empty string, nil, or no value returned from "loader function" means the end of JSON.
       --    This may be useful for low-memory devices or for traversing huge JSON files.


       --- The json.null table allows one to specify a null value in an associative array (which is otherwise
       -- discarded if you set the value with 'nil' in Lua. Simply set t = { first=json.null }
       local null = {"This Lua table is used to designate JSON null value, compare your values with json.null to determine JSON nulls"}
       json.null = setmetatable(null, {
          __tostring = function() return 'null' end
       })

       --- The json.empty table allows one to specify an empty JSON object.
       -- To encode empty JSON array use usual empty Lua table.
       -- Example: t = { empty_object=json.empty, empty_array={} }
       local empty = {}
       json.empty = setmetatable(empty, {
          __tostring = function() return '{}' end,
          __newindex = function() error("json.empty is an read-only Lua table", 2) end
       })

       -----------------------------------------------------------------------------
       -- Private functions
       -----------------------------------------------------------------------------
       local decode
       local decode_scanArray
       local decode_scanConstant
       local decode_scanNumber
       local decode_scanObject
       local decode_scanString
       local decode_scanIdentifier
       local decode_scanWhitespace
       local encodeString
       local isArray
       local isEncodable
       local isConvertibleToString
       local isRegularNumber

       -----------------------------------------------------------------------------
       -- PUBLIC FUNCTIONS
       -----------------------------------------------------------------------------
       --- Encodes an arbitrary Lua object / variable.
       -- @param   obj     Lua value (table/string/boolean/number/nil/json.null/json.empty) to be JSON-encoded.
       -- @return  string  String containing the JSON encoding.
       function json.encode(obj)
          -- Handle nil and null values
          if obj == nil or obj == null then
             return 'null'
          end

          -- Handle empty JSON object
          if obj == empty then
             return '{}'
          end

          local obj_type = type(obj)

          -- Handle strings
          if obj_type == 'string' then
             return '"'..encodeString(obj)..'"'
          end

          -- Handle booleans
          if obj_type == 'boolean' then
             return tostring(obj)
          end

          -- Handle numbers
          if obj_type == 'number' then
             assert(isRegularNumber(obj), 'numeric values Inf and NaN are unsupported')
             return math_type(obj) == 'integer' and tostring(obj) or string_format('%.17g', obj)
          end

          -- Handle tables
          if obj_type == 'table' then
             local rval = {}
             -- Consider arrays separately
             local bArray, maxCount = isArray(obj)
             if bArray then
                for i = obj[0] ~= nil and 0 or 1, maxCount do
                   table_insert(rval, json.encode(obj[i]))
                end
             else  -- An object, not an array
                for i, j in pairs(obj) do
                   if isConvertibleToString(i) and isEncodable(j) then
                      table_insert(rval, '"'..encodeString(i)..'":'..json.encode(j))
                   end
                end
             end
             if bArray then
                return '['..table_concat(rval, ',')..']'
             else
                return '{'..table_concat(rval, ',')..'}'
             end
          end

          error('Unable to JSON-encode Lua value of unsupported type "'..obj_type..'": '..tostring(obj))
       end

       local function create_state(s)
          -- Argument s may be "whole JSON string" or "JSON loader function"
          -- Returns "state" object which holds current state of reading long JSON:
          --    part = current part (substring of long JSON string)
          --    disp = number of bytes before current part inside long JSON
          --    more = function to load next substring (more == nil if all substrings are already read)
          local state = {disp = 0}
          if type(s) == "string" then
             -- s is whole JSON string
             state.part = s
          else
             -- s is loader function
             state.part = ""
             state.more = s
          end
          return state
       end

       --- Decodes a JSON string and returns the decoded value as a Lua data structure / value.
       -- @param   s           The string to scan (or "loader function" for getting next substring).
       -- @param   pos         (optional) The position inside s to start scan, default = 1.
       -- @return  Lua object  The object that was scanned, as a Lua table / string / number / boolean / json.null / json.empty.
       function json.decode(s, pos)
          return (decode(create_state(s), pos or 1))
       end

       --- Traverses a JSON string, sends everything to user-supplied callback function, returns nothing
       -- @param   s           The string to scan (or "loader function" for getting next substring).
       -- @param   callback    The user-supplied callback function which accepts arguments (path, json_type, value, pos, pos_last).
       -- @param   pos         (optional) The position inside s to start scan, default = 1.
       function json.traverse(s, callback, pos)
          decode(create_state(s), pos or 1, {path = {}, callback = callback})
       end

       local function read_ahead(state, startPos)
          -- Make sure there are at least 32 bytes read ahead
          local endPos = startPos + 31
          local part = state.part  -- current part (substring of "whole JSON" string)
          local disp = state.disp  -- number of bytes before current part inside "whole JSON" string
          local more = state.more  -- function to load next substring
          assert(startPos > disp)
          while more and disp + #part < endPos do
             --  (disp + 1) ... (disp + #part)  -  we already have this segment now
             --  startPos   ... endPos          -  we need to have this segment
             local next_substr = more()
             if not next_substr or next_substr == "" then
                more = nil
             else
                disp, part = disp + #part, string_sub(part, startPos - disp)
                disp, part = disp - #part, part..next_substr
             end
          end
          state.disp, state.part, state.more = disp, part, more
       end

       local function get_word(state, startPos, length)
          -- 1 <= length <= 32
          if state.more then read_ahead(state, startPos) end
          local idx = startPos - state.disp
          return string_sub(state.part, idx, idx + length - 1)
       end

       local function skip_until_word(state, startPos, word)
          -- #word < 30
          -- returns position after that word (nil if not found)
          repeat
             if state.more then read_ahead(state, startPos) end
             local part, disp = state.part, state.disp
             local b, e = string_find(part, word, startPos - disp, true)
             if b then
                return disp + e + 1
             end
             startPos = disp + #part + 2 - #word
          until not state.more
       end

       local function match_with_pattern(state, startPos, pattern, operation)
          -- pattern must be
          --    "^[some set of chars]+"
          -- returns
          --    matched_string, endPos   for operation "read"   (matched_string == "" if no match found)
          --    endPos                   for operation "skip"
          if operation == "read" then
             local t = {}
             repeat
                if state.more then read_ahead(state, startPos) end
                local part, disp = state.part, state.disp
                local str = string_match(part, pattern, startPos - disp)
                if str then
                   table_insert(t, str)
                   startPos = startPos + #str
                end
             until not str or startPos <= disp + #part
             return table_concat(t), startPos
          elseif operation == "skip" then
             repeat
                if state.more then read_ahead(state, startPos) end
                local part, disp = state.part, state.disp
                local b, e = string_find(part, pattern, startPos - disp)
                if b then
                   startPos = startPos + e - b + 1
                end
             until not b or startPos <= disp + #part
             return startPos
          else
             error("Wrong operation name")
          end
       end

       --- Decodes a JSON string and returns the decoded value as a Lua data structure / value.
       -- @param   state             The state of JSON reader.
       -- @param   startPos          Starting position where the JSON string is located.
       -- @param   traverse          (optional) table with fields "path" and "callback" for traversing JSON.
       -- @param   decode_key        (optional) boolean flag for decoding key inside JSON object.
       -- @return  Lua_object,int    The object that was scanned, as a Lua table / string / number / boolean / json.null / json.empty,
       --                            and the position of the first character after the scanned JSON object.
       function decode(state, startPos, traverse, decode_key)
          local curChar, value, nextPos
          startPos, curChar = decode_scanWhitespace(state, startPos)
          if curChar == '{' and not decode_key then
             -- Object
             if traverse and traverse.callback(traverse.path, "object", nil, startPos, nil) then
                -- user wants to decode this JSON object (and get it as Lua value) while traversing
                local object, endPos = decode_scanObject(state, startPos)
                traverse.callback(traverse.path, "object", object, startPos, endPos - 1)
                return false, endPos
             end
             return decode_scanObject(state, startPos, traverse)
          elseif curChar == '[' and not decode_key then
             -- Array
             if traverse and traverse.callback(traverse.path, "array", nil, startPos, nil) then
                -- user wants to decode this JSON array (and get it as Lua value) while traversing
                local array, endPos = decode_scanArray(state, startPos)
                traverse.callback(traverse.path, "array", array, startPos, endPos - 1)
                return false, endPos
             end
             return decode_scanArray(state, startPos, traverse)
          elseif curChar == '"' then
             -- String
             value, nextPos = decode_scanString(state, startPos)
             if traverse then
                traverse.callback(traverse.path, "string", value, startPos, nextPos - 1)
             end
          elseif decode_key then
             -- Unquoted string as key name
             return decode_scanIdentifier(state, startPos)
          elseif string_find(curChar, "^[%d%-]") then
             -- Number
             value, nextPos = decode_scanNumber(state, startPos)
             if traverse then
                traverse.callback(traverse.path, "number", value, startPos, nextPos - 1)
             end
          else
             -- Otherwise, it must be a constant
             value, nextPos = decode_scanConstant(state, startPos)
             if traverse then
                traverse.callback(traverse.path, value == null and "null" or "boolean", value, startPos, nextPos - 1)
             end
          end
          return value, nextPos
       end

       -----------------------------------------------------------------------------
       -- Internal, PRIVATE functions.
       -- Following a Python-like convention, I have prefixed all these 'PRIVATE'
       -- functions with an underscore.
       -----------------------------------------------------------------------------

       --- Scans an array from JSON into a Lua object
       -- startPos begins at the start of the array.
       -- Returns the array and the next starting position
       -- @param   state       The state of JSON reader.
       -- @param   startPos    The starting position for the scan.
       -- @param   traverse    (optional) table with fields "path" and "callback" for traversing JSON.
       -- @return  table,int   The scanned array as a table, and the position of the next character to scan.
       function decode_scanArray(state, startPos, traverse)
          local array = not traverse and {}  -- The return value
          local elem_index, elem_ready, object = 1
          startPos = startPos + 1
          -- Infinite loop for array elements
          while true do
             repeat
                local curChar
                startPos, curChar = decode_scanWhitespace(state, startPos)
                if curChar == ']' then
                   return array, startPos + 1
                elseif curChar == ',' then
                   if not elem_ready then
                      -- missing value in JSON array
                      if traverse then
                         table_insert(traverse.path, elem_index)
                         traverse.callback(traverse.path, "null", null, startPos, startPos - 1)  -- empty substring: pos_last = pos - 1
                         table_remove(traverse.path)
                      else
                         array[elem_index] = null
                      end
                   end
                   elem_ready = false
                   elem_index = elem_index + 1
                   startPos = startPos + 1
                end
             until curChar ~= ','
             if elem_ready then
                error('Comma is missing in JSON array at position '..startPos)
             end
             if traverse then
                table_insert(traverse.path, elem_index)
             end
             object, startPos = decode(state, startPos, traverse)
             if traverse then
                table_remove(traverse.path)
             else
                array[elem_index] = object
             end
             elem_ready = true
          end
       end

       --- Scans for given constants: true, false or null
       -- Returns the appropriate Lua type, and the position of the next character to read.
       -- @param  state        The state of JSON reader.
       -- @param  startPos     The position in the string at which to start scanning.
       -- @return object, int  The object (true, false or json.null) and the position at which the next character should be scanned.
       function decode_scanConstant(state, startPos)
          local w5 = get_word(state, startPos, 5)
          local w4 = string_sub(w5, 1, 4)
          if w5 == "false" then
             return false, startPos + 5
          elseif w4 == "true" then
             return true, startPos + 4
          elseif w4 == "null" then
             return null, startPos + 4
          end
          error('Failed to parse JSON at position '..startPos)
       end

       --- Scans a number from the JSON encoded string.
       -- (in fact, also is able to scan numeric +- eqns, which is not in the JSON spec.)
       -- Returns the number, and the position of the next character after the number.
       -- @param   state        The state of JSON reader.
       -- @param   startPos     The position at which to start scanning.
       -- @return  number,int   The extracted number and the position of the next character to scan.
       function decode_scanNumber(state, startPos)
          local stringValue, endPos = match_with_pattern(state, startPos, '^[%+%-%d%.eE]+', "read")
          local stringEval = loadstring('return '..stringValue)
          if not stringEval then
             error('Failed to scan number '..stringValue..' in JSON string at position '..startPos)
          end
          return stringEval(), endPos
       end

       --- Scans a JSON object into a Lua object.
       -- startPos begins at the start of the object.
       -- Returns the object and the next starting position.
       -- @param   state       The state of JSON reader.
       -- @param   startPos    The starting position of the scan.
       -- @param   traverse    (optional) table with fields "path" and "callback" for traversing JSON
       -- @return  table,int   The scanned object as a table and the position of the next character to scan.
       function decode_scanObject(state, startPos, traverse)
          local object, elem_ready = not traverse and empty
          startPos = startPos + 1
          while true do
             repeat
                local curChar
                startPos, curChar = decode_scanWhitespace(state, startPos)
                if curChar == '}' then
                   return object, startPos + 1
                elseif curChar == ',' then
                   startPos = startPos + 1
                   elem_ready = false
                end
             until curChar ~= ','
             if elem_ready then
                error('Comma is missing in JSON object at '..startPos)
             end
             -- Scan the key as string or unquoted identifier such as in {"a":1,b:2}
             local key, value
             key, startPos = decode(state, startPos, nil, true)
             local colon
             startPos, colon = decode_scanWhitespace(state, startPos)
             if colon ~= ':' then
                error('JSON object key-value assignment mal-formed at '..startPos)
             end
             startPos = decode_scanWhitespace(state, startPos + 1)
             if traverse then
                table_insert(traverse.path, key)
             end
             value, startPos = decode(state, startPos, traverse)
             if traverse then
                table_remove(traverse.path)
             else
                if object == empty then
                   object = {}
                end
                object[key] = value
             end
             elem_ready = true
          end  -- infinite loop while key-value pairs are found
       end

       --- Scans JSON string for an identifier (unquoted key name inside object)
       -- Returns the string extracted as a Lua string, and the position after the closing quote.
       -- @param  state        The state of JSON reader.
       -- @param  startPos     The starting position of the scan.
       -- @return string,int   The extracted string as a Lua string, and the next character to parse.
       function decode_scanIdentifier(state, startPos)
          local identifier, idx = match_with_pattern(state, startPos, '^[%w_%-%$]+', "read")
          if identifier == "" then
             error('JSON String decoding failed: missing key name at position '..startPos)
          end
          return identifier, idx
       end

       -- START SoniEx2
       -- Initialize some things used by decode_scanString
       -- You know, for efficiency
       local escapeSequences = { t = "\t", f = "\f", r = "\r", n = "\n", b = "\b" }
       -- END SoniEx2

       --- Scans a JSON string from the opening quote to the end of the string.
       -- Returns the string extracted as a Lua string, and the position after the closing quote.
       -- @param  state        The state of JSON reader.
       -- @param  startPos     The starting position of the scan.
       -- @return string,int   The extracted string as a Lua string, and the next character to parse.
       function decode_scanString(state, startPos)
          local t, idx, surrogate_pair_started, regular_part = {}, startPos + 1
          while true do
             regular_part, idx = match_with_pattern(state, idx, '^[^"\\]+', "read")
             table_insert(t, regular_part)
             local w6 = get_word(state, idx, 6)
             local c = string_sub(w6, 1, 1)
             if c == '"' then
                return table_concat(t), idx + 1
             elseif c == '\\' then
                local esc = string_sub(w6, 2, 2)
                if esc == "u" then
                   local n = tonumber(string_sub(w6, 3), 16)
                   if not n then
                      error("String decoding failed: bad Unicode escape "..w6.." at position "..idx)
                   end
                   -- Handling of UTF-16 surrogate pairs
                   if n >= 0xD800 and n < 0xDC00 then
                      surrogate_pair_started, n = n
                   elseif n >= 0xDC00 and n < 0xE000 then
                      n, surrogate_pair_started = surrogate_pair_started and (surrogate_pair_started - 0xD800) * 0x400 + (n - 0xDC00) + 0x10000
                   end
                   if n then
                      -- Convert unicode codepoint n (0..0x10FFFF) to UTF-8 string
                      local x
                      if n < 0x80 then
                         x = string_char(n % 0x80)
                      elseif n < 0x800 then
                         -- [110x xxxx] [10xx xxxx]
                         x = string_char(0xC0 + (math_floor(n/64) % 0x20), 0x80 + (n % 0x40))
                      elseif n < 0x10000 then
                         -- [1110 xxxx] [10xx xxxx] [10xx xxxx]
                         x = string_char(0xE0 + (math_floor(n/64/64) % 0x10), 0x80 + (math_floor(n/64) % 0x40), 0x80 + (n % 0x40))
                      else
                         -- [1111 0xxx] [10xx xxxx] [10xx xxxx] [10xx xxxx]
                         x = string_char(0xF0 + (math_floor(n/64/64/64) % 8), 0x80 + (math_floor(n/64/64) % 0x40), 0x80 + (math_floor(n/64) % 0x40), 0x80 + (n % 0x40))
                      end
                      table_insert(t, x)
                   end
                   idx = idx + 6
                else
                   table_insert(t, escapeSequences[esc] or esc)
                   idx = idx + 2
                end
             else
                error('String decoding failed: missing closing " for string at position '..startPos)
             end
          end
       end

       --- Scans a JSON string skipping all whitespace from the current start position.
       -- Returns the position of the first non-whitespace character.
       -- @param   state      The state of JSON reader.
       -- @param   startPos   The starting position where we should begin removing whitespace.
       -- @return  int,char   The first position where non-whitespace was encountered, non-whitespace char.
       function decode_scanWhitespace(state, startPos)
          while true do
             startPos = match_with_pattern(state, startPos, '^[ \n\r\t]+', "skip")
             local w2 = get_word(state, startPos, 2)
             if w2 == '/*' then
                local endPos = skip_until_word(state, startPos + 2, '*/')
                if not endPos then
                   error("Unterminated comment in JSON string at "..startPos)
                end
                startPos = endPos
             else
                local next_char = string_sub(w2, 1, 1)
                if next_char == '' then
                   error('Unexpected end of JSON')
                end
                return startPos, next_char
             end
          end
       end

       --- Encodes a string to be JSON-compatible.
       -- This just involves backslash-escaping of quotes, slashes and control codes
       -- @param   s        The string to return as a JSON encoded (i.e. backquoted string)
       -- @return  string   The string appropriately escaped.
       local escapeList = {
             ['"']  = '\\"',
             ['\\'] = '\\\\',
             ['/']  = '\\/',
             ['\b'] = '\\b',
             ['\f'] = '\\f',
             ['\n'] = '\\n',
             ['\r'] = '\\r',
             ['\t'] = '\\t',
             ['\127'] = '\\u007F'
       }
       function encodeString(s)
          if type(s) == 'number' then
             s = math_type(s) == 'integer' and tostring(s) or string_format('%.f', s)
          end
          return string_gsub(s, ".", function(c) return escapeList[c] or c:byte() < 32 and string_format('\\u%04X', c:byte()) end)
       end

       -- Determines whether the given Lua type is an array or a table / dictionary.
       -- We consider any table an array if it has indexes 1..n for its n items, and no other data in the table.
       -- I think this method is currently a little 'flaky', but can't think of a good way around it yet...
       -- @param   t                 The table to evaluate as an array
       -- @return  boolean,number    True if the table can be represented as an array, false otherwise.
       --                            If true, the second returned value is the maximum number of indexed elements in the array.
       function isArray(t)
          -- Next we count all the elements, ensuring that any non-indexed elements are not-encodable
          -- (with the possible exception of 'n')
          local maxIndex = 0
          for k, v in pairs(t) do
             if type(k) == 'number' and math_floor(k) == k and 0 <= k and k <= 1e6 then  -- k,v is an indexed pair
                if not isEncodable(v) then  -- All array elements must be encodable
                   return false
                end
                maxIndex = math_max(maxIndex, k)
             elseif not (k == 'n' and v == #t) then  -- if it is n, then n does not hold the number of elements
                if isConvertibleToString(k) and isEncodable(v) then
                   return false
                end
             end -- End of k,v not an indexed pair
          end  -- End of loop across all pairs
          return true, maxIndex
       end

       --- Determines whether the given Lua object / table / value can be JSON encoded.
       -- The only types that are JSON encodable are: string, boolean, number, nil, table and special tables json.null and json.empty.
       -- @param   o        The object to examine.
       -- @return  boolean  True if the object should be JSON encoded, false if it should be ignored.
       function isEncodable(o)
          local t = type(o)
          return t == 'string' or t == 'boolean' or t == 'number' and isRegularNumber(o) or t == 'nil' or t == 'table'
       end

       --- Determines whether the given Lua object / table / variable can be a JSON key.
       -- Integer Lua numbers are allowed to be considered as valid string keys in JSON.
       -- @param   o        The object to examine.
       -- @return  boolean  True if the object can be converted to a string, false if it should be ignored.
       function isConvertibleToString(o)
          local t = type(o)
          return t == 'string' or t == 'number' and isRegularNumber(o) and (math_type(o) == 'integer' or math_floor(o) == o)
       end

       local is_Inf_or_NaN = {[tostring(1/0)]=true, [tostring(-1/0)]=true, [tostring(0/0)]=true, [tostring(-(0/0))]=true}
       --- Determines whether the given Lua number is a regular number or Inf/Nan.
       -- @param   v        The number to examine.
       -- @return  boolean  True if the number is a regular number which may be encoded in JSON.
       function isRegularNumber(v)
          return not is_Inf_or_NaN[tostring(v)]
       end

    end

    return json
end

-- Usage: ManageCollection("Auto Retainer", true)
-- Enables or disables a collection
-- Options: true = enables the collection, false = disables the collection
function ManageCollection(collection_name, enable)
    if type(collection_name) ~= "string" or collection_name == "" then
        LogError("[VAC] (ManageCollection) Invalid collection name provided")
        return false
    end

    local action = enable and "enable" or "disable"

    LogInfo("[VAC] (ManageCollection) Attempting to " .. action .. " profile: " .. collection_name)

    yield("/xl" .. action .. "profile " .. collection_name)
    Sleep(0.1)

    local success = true

    if success then
        LogInfo("[VAC] (ManageCollection) Successfully " .. action .. "d profile: " .. collection_name)
        return true
    else
        LogError("[VAC] (ManageCollection) Failed to " .. action .. " profile: " .. collection_name)
        return false
    end
end

-- Usage: OpenLetterMenu()
-- Opens the letter menu if player is within distance of Delivery Moogle or Regal/Moogle Letter Box
function OpenLetterMenu()
    if not IsAddonVisible("LetterList") then
        -- List of possible targets
        local targets = { "Delivery Moogle", "Regal Letter Box", "Moogle Letter Box" }

        -- Try to target each one in sequence
        for _, target_name in ipairs(targets) do
            if Target(target_name) then
                break  -- Exit the loop once a target is found
            else
                return  -- Exit if no target is found
            end
        end

        Interact()

        repeat
            Sleep(0.1)
        until IsAddonReady("Talk")

        repeat
            yield("/callback Talk true 0")
            Sleep(0.1)
        until not IsAddonVisible("Talk")

        repeat
            Sleep(0.1)
        until IsAddonReady("LetterList")

        -- Handle the "SelectOk" window with a check to prevent getting stuck
        local max_attempts = 10
        local attempts = 0

        repeat
            if IsAddonReady("SelectOk") and string.match(GetNodeText("SelectOk", 3), "You cannot carry any more campaign") then
                yield("/callback SelectOk true 0")
                break
            end
            attempts = attempts + 1

            if attempts >= max_attempts then
                break
            end

            Sleep(0.1)
        until IsAddonVisible("SelectOk") and IsAddonVisible("LetterList")

        repeat
            Sleep(0.1)
        until IsAddonReady("LetterList") and string.match(GetNodeText("LetterList", 14, 13, 2), "Purchases & Rewards")
    end
end

-- Usage: SelectLetter()
-- Selects the top letter in the "LetterList" addon menu
function SelectLetter()
    -- Check if "LetterList" addon is ready
    repeat
        Sleep(0.1)
    until IsAddonReady("LetterList")

    -- Selects the first letter in the letter list
    repeat
        yield("/callback LetterList true 0 0")
        Sleep(0.1)
    until IsAddonVisible("LetterViewer")

    -- If "LetterList" breaks, timeout to recover opening remaining letters
    local max_attempts = 10
    local attempts = 0

    repeat
        yield("/callback LetterList true 0 0")
        Sleep(0.1)
        attempts = attempts + 1

        if attempts >= max_attempts then
            repeat
                yield("/callback LetterList true -1")
            until not IsAddonVisible("LetterList")
            OpenLetterMenu()
        end

        Sleep(0.1)
    until IsAddonVisible("LetterViewer")
end

-- Usage: TakeLetterContents()
-- Takes the letter contents in the "LetterViewer" addon menu
function TakeLetterContents()
    -- Check if "LetterViewer" addon is ready
    repeat
        Sleep(0.1)
    until IsAddonReady("LetterViewer")

    -- If letter contains "Enclosed" then take items
    -- This also needs visibility check if it gets added here
    if string.match(GetNodeText("LetterViewer", 28), "Enclosed") and IsNodeVisible("LetterViewer", 1, 2, 5) then
        yield("/callback LetterViewer true 1")
    end
end

-- Usage: DeleteLetter()
-- Deletes the open letter in thet "LetterViewer" addon menu
function DeleteLetter()
    -- Check if "LetterViewer" addon is ready
    repeat
        Sleep(0.1)
    until IsAddonReady("LetterViewer")

    -- Track whether letter has been deleted
    local deleted_letter = false

    -- Check whether letter has text and node visibility, then delete the letter
    repeat
        if IsAddonReady("LetterViewer") and string.match(GetNodeText("LetterViewer", 28), ".+") then
            repeat
                yield("/callback LetterViewer true 2")
                Sleep(0.1)
            until IsAddonReady("SelectYesno") and string.match(GetNodeText("SelectYesno", 15), "Delete this letter?")
            yield("/callback SelectYesno true 0")
        end
        Sleep(0.1)
    until not IsAddonVisible("LetterViewer") and IsAddonVisible("LetterList")
end

-- Usage: RequestLetter()
-- Requests any additional letters in the "LetterList" addon menu
function RequestLetter()
    -- Check if "LetterList" addon is ready
    repeat
        Sleep(0.1)
    until IsAddonReady("LetterList")

    repeat
        yield("/callback LetterList true 3")
        Sleep(0.1)
    until IsAddonReady("SelectYesno") and string.match(GetNodeText("SelectYesno", 15), "Send a request to have recently acquired special")

    repeat
        yield("/callback SelectYesno true 0")
        Sleep(0.1)
    until not IsAddonVisible("SelectYesno") and IsAddonVisible("LetterList")
end

-- Usage: GetFCGCID()
-- Returns the Grand Company id for your FC
function GetFCGCID()
    local gc_name = GetFCGrandCompany()
    if gc_name == "Maelstrom" then
        return 1
    elseif gc_name == "Twin Adders" then
        return 2
    elseif gc_name == "Immortal Flames" then
        return 3
    else
        return false -- if it fails to find a gc with that name
    end
end