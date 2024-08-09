-- This file needs to be dropped inside %appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\
-- So it should look like this %appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\vac_functions.lua
-- It contains the functions required to make the scripts work

function LoadFileCheck()
	yield("/e Successfully loaded the functions file")
end

-- InteractAndWait()
--
-- Interacts with the current target and waits until the player is available again before proceeding
function InteractAndWait()
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
    yield("/pint")
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable()
end

-- Interact()
--
-- Just interacts with the current target
function Interact()
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
    yield("/pint")
end

-- usage: Echo("meow")
--
-- prints provided text into chat
function Echo(text)
    yield("/echo "..text)
end

-- usage: Sleep("0.5")
--
-- replaces yield wait spam, halts the script for X seconds 
function Sleep(time)
    yield("/wait "..tostring(time))
end

-- usage: ZoneTransitions()
--
-- Zone transition checker, does nothing if changing zones
function ZoneTransitions()
    repeat 
         yield("/wait 0.1")
    until GetCharacterCondition(45) or GetCharacterCondition(51)
    repeat 
        yield("/wait 0.1")
    until not GetCharacterCondition(45) or not GetCharacterCondition(51)
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable()
end

-- usage: QuestNPC("SelectYesno"|"CutSceneSelectString", true, 0)
--
-- NPC interaction handler, only supports one dialogue option for now. DialogueOption optional.
function QuestNPC(DialogueType, DialogueConfirm, DialogueOption)
    while not GetCharacterCondition(32) do
        yield("/pint")
        yield("/wait 0.1")
    end
    if DialogueConfirm then
        repeat 
            yield("/wait 0.1")
        until IsAddonVisible(DialogueType)
        if DialogueOption == nil then
            repeat
                yield("/pcall " .. DialogueType .. " true 0")
                yield("/wait 0.1")
            until not IsAddonVisible(DialogueType)
        else
            repeat
                yield("/pcall " .. DialogueType .. " true " .. DialogueOption)
                yield("/wait 0.1")
            until not IsAddonVisible(DialogueType)
        end
    end
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable()
end

-- usage: QuestNPCSingle("SelectYesno"|"CutSceneSelectString", true, 0)
--
-- NPC interaction handler. dialogue_option optional.
function QuestNPCSingle(dialogue_type, dialogue_confirm, dialogue_option)
    while not GetCharacterCondition(32) do
        yield("/pint")
        yield("/wait 0.5")
    end
    if dialogue_confirm then
        repeat 
            yield("/wait 0.1")
        until IsAddonReady(dialogue_type)
        yield("/wait 0.5")
        if dialogue_option == nil then
            yield("/pcall " .. dialogue_type .. " true 0")
            yield("/wait 0.5")
        else
            yield("/pcall " .. dialogue_type .. " true " .. dialogue_option)
            yield("/wait 0.5")
        end
    end
end

-- not explicitly used
function QuestCombat(target, enemy_max_dist)
    local all_targets = {target}
    local combined_list = {}
    local best_target = 0
    local lowest_distance = 0
    for _, current_target in ipairs(all_targets) do
        local current_list = {} 
        for i = 0, 10 do
            --yield("/echo <list." .. i .. ">")
            yield("/target " .. current_target .. " <list." .. i .. ">")
            yield("/wait 0.1")
            if (GetTargetName() == target) and GetTargetHP() > 0 and GetDistanceToTarget() <= enemy_max_dist then
                local distance = GetDistanceToTarget()
                table.insert(current_list, {target = current_target, index = i, distance = distance})
            end
        end
        table.sort(current_list, function(a, b) return a.distance < b.distance end)
        if #current_list > 0 and (best_target == 0 or current_list[1].distance < lowest_distance) then
            best_target = #combined_list + 1
            lowest_distance = current_list[1].distance
        end
        for _, entry in ipairs(current_list) do
            table.insert(combined_list, entry)
        end
    end
    if best_target > 0 then
        local best_entry = combined_list[best_target]
        yield("/target " .. best_entry.target .. " <list." .. best_entry.index .. ">")
        --yield("/echo =====================")
        --yield("/echo best_entry.target = " .. tostring(best_entry.target))
        --yield("/echo best_entry.index = " .. tostring(best_entry.index))
        --yield("/echo =====================")
        yield("/wait 0.5")

        local dist_to_enemy = GetDistanceToTarget()

        if GetTargetHP() > 0 and dist_to_enemy <= enemy_max_dist then
            repeat
                yield("/rotation auto")
                yield("/vnavmesh movetarget")
                
                yield("/wait 0.2")
            until GetDistanceToTarget() <= 3
            yield('/ac "Auto-attack"')
            yield("/vnavmesh stop")
        end
    end
    repeat
      yield("/wait 0.1")
    until GetTargetHP() == 0
      yield("/wait 0.5")
end

-- usage: QuestInstance()
--
-- Targetting/Movement Logic for Solo Duties. Pretty sure this is broken atm
function QuestInstance()
    while true do
        -- Check if GetCharacterCondition(34) is false and exit if so
        if not GetCharacterCondition(34) then
            break
        end

        if not IsPlayerAvailable() then
            yield("/wait 1")
            yield("/pcall SelectYesno true 0")
        elseif GetCharacterCondition(1) then
            yield("/pint")
            yield("/wait 1")
            while IsPlayerCasting() do 
                yield("/wait 0.5")
            end
            repeat 
                yield("/wait 0.1")
                -- Check condition in the middle of the loop
                if not GetCharacterCondition(34) then
                    break
                end
            until not IsAddonVisible("SelectYesno")
        elseif not IsPlayerAvailable() and not GetCharacterCondition(26) then
            repeat
                yield("/wait 0.1")
                -- Check condition in the middle of the loop
                if not GetCharacterCondition(34) then
                    break
                end
            until GetCharacterCondition(34)
        else
            local paused = false
            while GetCharacterCondition(34) do
                if paused then
                    repeat
                        yield("/wait 0.1")
                        -- Check condition in the middle of the loop
                        if not GetCharacterCondition(34) then
                            break
                        end
                    until GetCharacterCondition(26, false)
                    paused = false
                else
                    yield("/wait 1")
                    yield("/rotation auto")

                    local current_target = GetTargetName()

                    if not current_target or current_target == "" then
                        yield("/targetenemy") 
                        current_target = GetTargetName()
                        if current_target == "" then
                            yield("/wait 1") 
                        end
                    end

                    local enemy_max_dist = 100
                    local dist_to_enemy = GetDistanceToTarget()

                    if dist_to_enemy and dist_to_enemy > 0 and dist_to_enemy <= enemy_max_dist then
                        local enemy_x, enemy_y, enemy_z = GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos()
                        yield("/vnavmesh moveto " .. enemy_x .. " " .. enemy_y .. " " .. enemy_z)
                        yield("/wait 3")
                        yield("/vnavmesh stop")  
                    end

                    -- Check condition to pause
                    if not IsPlayerAvailable() or not GetCharacterCondition(26, true) then
                        paused = true
                    end
                end

                -- Check condition at the end of the loop iteration
                if not GetCharacterCondition(34) then
                    break
                end
            end
        end

        -- Check condition at the end of the loop iteration
        if not GetCharacterCondition(34) then
            break
        end
    end
end

-- usage: GetNodeTextLookupUpdate("_ToDolist",16,3,4) // GetNodeTextLookupUpdate("_ToDolist",16,3)
--
-- function i really don't like the existence of, is only called by Questchecker and Nodescanner, could be called manually.
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

-- usage: QuestChecker(ArcanistEnemies[3], 50, "_ToDoList", "Slay little ladybugs.")
--
-- needs a rewrite to deal with hunting logs, for now it works with _ToDoList
function QuestChecker(target_name, target_distance, get_node_text_type, get_node_text_match)
    local target = target_name
    local enemy_max_dist = target_distance
    local get_node_text_location, get_node_text_location_1, get_node_text_location_2 = NodeScanner(get_node_text_type, get_node_text_match)
    local function extractTask(text)
        local task = string.match(text, "^(.-)%s%d+/%d+$")
        return task or text
    end
    while true do
        --UiCheck(get_node_text_type)
        updated_node_text = GetNodeTextLookupUpdate(get_node_text_type, get_node_text_location, get_node_text_location_1, get_node_text_location_2)
        LogInfo("[JU] updated_node_text: "..updated_node_text)
        LogInfo("[JU] Extract: "..extractTask(updated_node_text))
        local last_char = string.sub(updated_node_text, -1)
        LogInfo("[JU] last char: "..updated_node_text)
        yield("/wait 2")
        if updated_node_text == get_node_text_match or not string.match(last_char, "%d") then
            --UiCheck(get_node_text_type, true)
            LogInfo("GUUUUUUUUUUUH")
            break
        end
        QuestCombat(target_name, enemy_max_dist)
    end
    -- checks if player in combat before ending rotation solver
    if not GetCharacterCondition(26) then
        yield("/rotation off")
    end
end

-- usage: NodeScanner("_ToDoList", "Slay wild dodos.")
--
-- scans provided node type for node that has provided text and returns minimum 2 but up to 3 variables with the location which you can use with GetNodeText()
--
-- this will fail if the node is too nested and scanning deeper than i am currently is just not a good idea i think, nor do i know how to improve this
function NodeScanner(get_node_text_type, get_node_text_match)
    node_type_count = tonumber(GetNodeListCount(get_node_text_type))
    local function extractTask(text)
        local task = string.match(text, "^(.-)%s*%d*/%d*$")
        return task or text
    end
    for location = 0, node_type_count do
        for sub_node = 0, 60 do
            yield("/wait 0.0001")
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
                yield("/wait 0.0001")
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

-- usage: Uicheck("MonsterNote", true)
--
-- Closes or opens supported ui's, true is close and false is open. Probably will be changed into individual functions like i've already done for some
function UiCheck(get_node_text_type, close_ui)
    -- hunting log checks
    if get_node_text_type == "MonsterNote" then
        if close_ui() then
            repeat
                yield("/huntinglog")
                yield("/wait 0.5")
            until not IsAddonVisible("MonsterNote")
        else
            repeat
                yield("/huntinglog")
                yield("/wait 0.5")
            until IsAddonVisible("MonsterNote")
        end
    end
end


-- usage: Teleporter("Limsa", "tp") or Teleporter("gc", "li")  
-- add support for item tp Teleporter("Vesper", "item")  
-- likely rewriting teleporter to have own version of lifestream with locations, coords and nav/tp handling
-- add trade detection to initiate /busy and remove after successful tp
-- maybe add random delays between retries
function Teleporter(location, tp_kind) -- Teleporter handler
    local lifestream_stopped = false
    local extra_cast_time_buffer = 0 -- Just in case a buffer is required, teleports are 5 seconds long. Slidecasting, ping and fps can affect casts
    local max_retries = 10  -- Teleporter retry amount, will not tp after number has been reached for safety
    local retries = 0
    
    -- Initial check to ensure player can teleport
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26) -- 26 is combat
    
    -- Try teleport, retry until max_retries is reached
    while retries < max_retries do
        -- Stop lifestream only once per teleport attempt
        if tp_kind == "li" and not lifestream_stopped then
            yield("/lifestream stop")
            lifestream_stopped = true
            yield("/wait 0.1")
        end
        
        -- Attempt teleport
        if not IsPlayerCasting() then
            yield("/" .. tp_kind .. " " .. location)
            yield("/wait 2") -- Short wait to check if casting starts
            
            -- Check if the player started casting, indicating a successful attempt
            if IsPlayerCasting() then
                yield("/wait " .. 5 + extra_cast_time_buffer) -- Wait for cast to complete
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
-- usage: Mount("SDS Fenrir") 
--
-- Can leave empty for mount roulette
function Mount(mount_name)
    local max_retries = 10   -- Maximum number of retries
    local retry_interval = 1 -- Time interval between retries in seconds
    local retries = 0        -- Counter for the number of retries

    -- Check if the player has unlocked mounts by checking the quest completion
    if not (IsQuestComplete(66236) or IsQuestComplete(66237) or IsQuestComplete(66238)) then
        if not mount_message then
            yield('/e You do not have a mount unlocked, please consider completing the "My Little Chocobo" quest.')
            yield("/e Skipping mount.")
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
        yield("/wait 0.1")
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
    
    -- Retry loop for mounting with a max retry limit (set above)
    while retries < max_retries do
        -- Attempt to mount using the chosen mount or Mount Roulette if none
        if mount_name == nil then
            yield('/ac "Mount Roulette"')
        else
            yield('/mount "' .. mount_name .. '"')
        end
        
        -- Wait for the retry interval
        yield("/wait " .. retry_interval)
        
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
        yield("/wait 0.1")
    until IsPlayerAvailable() and GetCharacterCondition(4)
end

-- usage: LogOut()
function LogOut()
    repeat
        yield("/logout")
        yield("/wait 0.1")
    until IsAddonVisible("SelectYesno")
    repeat
        yield("/pcall SelectYesno true 0")
        yield("/wait 0.1")
    until not IsAddonVisible("SelectYesno")
end

-- usage: Movement(674.92, 19.37, 436.02)
--
-- deals with vnav movement, kind of has some stuck checks but it's probably not as reliable as it can be
function Movement(x_position, y_position, z_position)
    local function floor_position(pos)
        return math.floor(pos + 0.49999999999999994)
    end

    local x_position_floored = floor_position(x_position)
    local y_position_floored = floor_position(y_position)
    local z_position_floored = floor_position(z_position)

    local range = 3

    local function NavToDestination()
        NavReload()
        repeat
            yield("/wait 0.1")
        until NavIsReady()

        local retries = 0
        local max_retries = 100
        repeat
            yield("/wait 0.1")
            yield("/vnav moveto " .. x_position .. " " .. y_position .. " " .. z_position)
            retries = retries + 1
        until PathIsRunning() or retries >= max_retries
        yield("/wait 1.0")
    end

    NavToDestination()

    while true do
        local xpos = floor_position(GetPlayerRawXPos())
        local ypos = floor_position(GetPlayerRawYPos())
        local zpos = floor_position(GetPlayerRawZPos())

        yield("/wait 0.1")

        -- Check if within 3 numbers of each pos
        if math.abs(xpos - x_position_floored) <= range and
           math.abs(ypos - y_position_floored) <= range and
           math.abs(zpos - z_position_floored) <= range then
            if PathIsRunning() then
                --nothing
            else 
                break
            end
        end

        yield("/wait 0.5")
        
        local xpos2 = floor_position(GetPlayerRawXPos())
        local ypos2 = floor_position(GetPlayerRawYPos())
        local zpos2 = floor_position(GetPlayerRawZPos())

        if xpos == xpos2 and ypos == ypos2 and zpos == zpos2 then
            if math.abs(xpos - x_position_floored) > range or
               math.abs(ypos - y_position_floored) > range or
               math.abs(zpos - z_position_floored) > range then
                NavToDestination()
                yield('/gaction "Jump"')
                yield("/wait 0.5")
                yield('/gaction "Jump"')
            end
        end
    end
end

-- usage: OpenTimers()
--
-- Opens the timers window
function OpenTimers()
    repeat
        yield("/timers")
        yield("/wait 0.1")
    until IsAddonVisible("ContentsInfo")
    repeat
        yield("/pcall ContentsInfo True 12 1")
        yield("/wait 0.1")
    until IsAddonVisible("ContentsInfoDetail")
    repeat
        yield("/timers")
        yield("/wait 0.1")
    until not IsAddonVisible("ContentsInfo")
end

-- usage: MarketBoardChecker()
--
-- just checks if the marketboard is open and keeps the script stopped until it's closed
function MarketBoardChecker()
    local ItemSearchWasVisible = false
    repeat
        yield("/wait 0.1")
        if IsAddonVisible("ItemSearch") then
            ItemSearchWasVisible = true
        end
    until ItemSearchWasVisible
    
    repeat
        yield("/wait 0.1")
    until not IsAddonVisible("ItemSearch")
end

-- usage: BuyFromStore(1, 15) <--- buys 15 of X item
--
-- number_in_list is which item you're buying from the list, top item is 1, 2 is below that, 3 is below that etc...  
-- only works for the "Store" addon window, i'd be careful calling it anywhere else
function BuyFromStore(number_in_list, amount)
    -- compensates for the top being 0
    number_in_list = number_in_list - 1
    attempts = 0
    repeat
        yield("/wait 0.1")
        attempts = attempts + 1
    until (IsAddonReady("Shop") or attempts >= 100)
    -- attempts above 50 is about 5 seconds
    if attempts >= 100 then
        Echo("Waited too long, store window not found, moving on")
    end
    if IsAddonReady("Shop") and number_in_list and amount then
        yield("/pcall Shop True 0 "..number_in_list.." "..amount)
        repeat
            yield("/wait 0.1")
        until IsAddonReady("SelectYesno")
        yield("/pcall SelectYesno true 0")
        yield("/wait 0.5")
    end
end

-- usage: CloseStore()  
-- Function used to close store windows
function CloseStore()
    if IsAddonVisible("Shop") then
        yield("/pcall Shop True -1")
    end
    repeat
        yield("/wait 0.1")
    until not IsAddonVisible("Shop")
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable()
end

-- usage: Target("Storm Quartermaster")  
-- TODO: target checking for consistency and speed
function Target(target)
    yield('/target "'..target..'"')
    yield("/wait 0.5")
end

-- usage: OpenGcSupplyWindow(1)  
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
            yield("/pcall GrandCompanySupplyList true 0 "..tab)
        end
    elseif not IsAddonVisible("GrandCompanySupplyList") then
        -- attempt to target any of the 3 gc Officers
        -- could add more robust checks so you know which one to target right away, no waiting needed
        Target("Storm Personnel Officer")
        Target("Serpent Personnel Officer")
        Target("Flame Personnel Officer")
        Interact()
        repeat
            Sleep(0.1)
        until IsAddonReady("SelectString")
        yield("/pcall SelectString true 0")
        repeat
            Sleep(0.1)
        until IsAddonReady("GrandCompanySupplyList")
        yield("/pcall GrandCompanySupplyList true 0 "..tab)
    end
end
-- usage: CloseGcSupplyWindow()  
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
        Sleep(0.1)
        attempt_counter = attempt_counter + 1
    until not IsAddonVisible("GrandCompanySupplyList") and not IsAddonVisible("SelectString") or attempt_counter >= 50
    if attempt_counter >= 50 then
        Echo("Window still open, trying again")
        goto tryagain
    end
end

-- usage: GcProvisioningDeliver(3)
--
-- Clicks and delivers the top option X amount of times  
-- Works because when you deliver one the others move up
function GcProvisioningDeliver(amount)
    local amount = amount
    if not amount then
        amount = 1
    end
    for i = 1, amount do
        yield("/pcall GrandCompanySupplyList true 1 0")
        local err_counter_request = 0
        local err_counter_supply = 0
        repeat
            Sleep(0.1)
            err_counter_request = err_counter_request+1
        until IsAddonReady("GrandCompanySupplyReward") or err_counter_request >= 30
        if err_counter_request >= 30 then
            Echo("Something went wrong or request window was auto skipped, continuing")
            err_counter_request = 0
        else 
            yield("/pcall GrandCompanySupplyReward true 0")
        end
        repeat
            Sleep(0.1)
            err_counter_supply = err_counter_supply+1
        until IsAddonReady("GrandCompanySupplyList") or err_counter_supply >= 30
        err_counter_supply = 0
    end
end

WorldIDList={["Cerberus"]={ID=80},["Louisoix"]={ID=83},["Moogle"]={ID=71},["Omega"]={ID=39},["Phantom"]={ID=401},["Ragnarok"]={ID=97},["Sagittarius"]={ID=400},["Spriggan"]={ID=85},["Alpha"]={ID=402},["Lich"]={ID=36},["Odin"]={ID=66},["Phoenix"]={ID=56},["Raiden"]={ID=403},["Shiva"]={ID=67},["Twintania"]={ID=33},["Zodiark"]={ID=42},["Adamantoise"]={ID=73},["Cactuar"]={ID=79},["Faerie"]={ID=54},["Gilgamesh"]={ID=63},["Jenova"]={ID=40},["Midgardsormr"]={ID=65},["Sargatanas"]={ID=99},["Siren"]={ID=57},["Balmung"]={ID=91},["Brynhildr"]={ID=34},["Coeurl"]={ID=74},["Diabolos"]={ID=62},["Goblin"]={ID=81},["Malboro"]={ID=75},["Mateus"]={ID=37},["Zalera"]={ID=41},["Cuchulainn"]={ID=408},["Golem"]={ID=411},["Halicarnassus"]={ID=406},["Kraken"]={ID=409},["Maduin"]={ID=407},["Marilith"]={ID=404},["Rafflesia"]={ID=410},["Seraph"]={ID=405},["Behemoth"]={ID=78},["Excalibur"]={ID=93},["Exodus"]={ID=53},["Famfrit"]={ID=35},["Hyperion"]={ID=95},["Lamia"]={ID=55},["Leviathan"]={ID=64},["Ultros"]={ID=77},["Bismarck"]={ID=22},["Ravana"]={ID=21},["Sephirot"]={ID=86},["Sophia"]={ID=87},["Zurvan"]={ID=88},["Aegis"]={ID=90},["Atomos"]={ID=68},["Carbuncle"]={ID=45},["Garuda"]={ID=58},["Gungnir"]={ID=94},["Kujata"]={ID=49},["Tonberry"]={ID=72},["Typhon"]={ID=50},["Alexander"]={ID=43},["Bahamut"]={ID=69},["Durandal"]={ID=92},["Fenrir"]={ID=46},["Ifrit"]={ID=59},["Ridill"]={ID=98},["Tiamat"]={ID=76},["Ultima"]={ID=51},["Anima"]={ID=44},["Asura"]={ID=23},["Chocobo"]={ID=70},["Hades"]={ID=47},["Ixion"]={ID=48},["Masamune"]={ID=96},["Pandaemonium"]={ID=28},["Titan"]={ID=61},["Belias"]={ID=24},["Mandragora"]={ID=82},["Ramuh"]={ID=60},["Shinryu"]={ID=29},["Unicorn"]={ID=30},["Valefor"]={ID=52},["Yojimbo"]={ID=31},["Zeromus"]={ID=32}}