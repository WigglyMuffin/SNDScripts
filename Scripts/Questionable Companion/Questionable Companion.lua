--[[
############################################################
##                      Questionable                      ##
##                       Companion                        ##
############################################################

####################
##    Version     ##
##     0.2.4      ##
####################

-> 0.2.4: Added death handler; will respawn, tp to zone and move to place where you died. Added jumping to stuck checker
-> 0.2.3: Added an option to remove the entrance restriction placed to stop erroneous duty queueing 
-> 0.2.2: Added a few more bossmod settings
-> 0.2.1: Updated the settings companion sets when starting to more optimal ones
-> 0.2.0: Updated plugin requirements
-> 0.1.9: Added an option to force bossmod ai on if it detects the character is under X health, very basic implementation and will probably be improved in the future
-> 0.1.8: Fixed the script being broken due to an SND update
-> 0.1.7: Unexpected combat should be fixed
-> 0.1.6: Hopefully finally actually fixed the bug with z2. And added extra rsr calls once inside an instance to see if that helps with it not starting properly.
-> 0.1.5: Changed to using the rsr ipc for hopefully more consistency, also redid how combat is handled in the overworld, hopefully this works better in practice. A bug where the script sometimes would crash going between zones should also be fixed
-> 0.1.4: Added an extra option to toggle the chat output of quest reloader
-> 0.1.3: Added various log outputs and made some minor changes to the quest reloader. Also removed unneeded old code.
-> 0.1.2: Changed how combat is handled, a lot of rsr settings will be modified to ensure consistency. Should also now equip recommended gear after duties/instances.
-> 0.1.1: Potentially made certain things more robust. Make sure to update your VAC_Functions.lua
-> 0.1.0: Fixed a bug in the qst reloader, and added temporary rsr auto calls to make sure it actually starts properly once entering instances
-> 0.0.9: Some minor changes for consistency, and qst now should start properly again after instances/dungeons
-> 0.0.8: Added the experimental features section, and added an experimental qst reloader which will reload if it finds questionable being stuck
-> 0.0.7: Added a duty whitelist so it won't try to queue duties that don't have duty support
-> 0.0.6: Added unexpected combat handler
-> 0.0.5: Solo instances should be working properly again
-> 0.0.4: Added some extra checks which should cause it to no longer fail to queue into duties
-> 0.0.3: Should no longer vnav rebuild after short periods of time, should now be about 8 seconds
-> 0.0.2: Questionable should now start again after a duty ends
-> 0.0.1: Initial release, it is not tested properly so it might not work as intended. Consider it a testing version of sorts.

####################################################
##                  Description                   ##
####################################################

https://github.com/WigglyMuffin/SNDScripts

Just a simple script you can run alongside questionable to have it automatically queue and finish dungeons, it will enter and try to do instances but not every instance is doable.
Also has a stuck checker that reloads vnav, and if stuck for long enough, rebuilds the zone entirely.
 
Will also modify a lot of settings inside of Rotation solver and some in bossmod so beware of that before using.

####################################################
##                  Requirements                  ##
####################################################    

-> AutoDuty - https://puni.sh/api/repository/herc
-> AutoRetainer : https://love.puni.sh/ment.json
-> BossMod or BossMod Reborn - https://puni.sh/api/repository/veyn // https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json
-> Lifestream - https://raw.githubusercontent.com/NightmareXIV/MyDalamudPlugins/main/pluginmaster.json
-> Pandora - https://love.puni.sh/ment.json
-> Questionable - https://plugins.carvel.li/
-> Rotation Solver Reborn - https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json
-> Something Need Doing (Expanded Edition) - https://puni.sh/api/repository/croizat
-> Teleporter : In the default first party dalamud repository
-> Textadvance - https://raw.githubusercontent.com/NightmareXIV/MyDalamudPlugins/main/pluginmaster.json
-> Vnavmesh - https://puni.sh/api/repository/veyn

####################################################
##                    Settings                    ##
##################################################]]

-- Toggle if you want bossmod ai to be enabled all the time or only when it's required
local bossmod_ai_outside_of_instances = true

-- This setting will force enable bossmod if it finds your character below x% health, set to 0 if you want it disabled
local enable_bossmod_ai_hp_treshold = 50

-- This setting will enforce recommended settings for both Bossmod and RSR once the script starts
-- Keep it commented out and wait for update to this script
-- local enforce_settings = true

-- leave this empty if you don't want the chars to stop at any specific quest, but this will cause it to never try to rotate to another char
local quest_name_to_stop_at = ""

-- This setting will remove the nearby entrance check implemented to stop the script from queueing if you accidentally open the duty window at any point.
-- Turning it off will cause the script to attempt queuing upon opening the duty finder window, no matter if it was opened by you or questionable
local remove_entrance_restriction = false

-- Here you provide it a character list to go through, this used alongside the above option will let you get a lot of different character to X quest
local chars = {
    "EXAMPLE CHARACTER@WORLD",
    "EXAMPLE CHARACTER@WORLD",
    "EXAMPLE CHARACTER@WORLD"
}

--[[################################################
##              Experimental Features             ##
##################################################]]

-- will attempt to reload qst whenever it detects it's stuck on a step
local qst_reloader_enabled = true
local qst_reloader_threshold = 15 -- this is how many loops quest reloader will wait before it triggers a reload if it finds you being stuck, set this higher if you end up having issues with follow quests and similar
local qst_reloader_echo = true -- set this to false if you want to disable quest reloader outputting timer info into the chat

--[[################################################
##                  Script Start                  ##
##################################################]]
SNDConfigFolder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
LoadFunctionsFileLocation = SNDConfigFolder.."vac_functions.lua"
LoadFunctions = loadfile(LoadFunctionsFileLocation)()
LoadFileCheck()

-- Plugin checker
local required_plugins = {
    AutoDuty = "0.0.0.118",
    AutoRetainer = "4.4.4",
    BossMod = "0.0.0.292",
    Lifestream = "2.3.2.8",
    PandorasBox = "1.6.2.5",
    Questionable = "4.19",
    SomethingNeedDoing = "1.75",
    TeleporterPlugin = "2.0.2.5",
    TextAdvance = "3.2.4.4",
    vnavmesh = "0.0.0.54"
}

if not CheckPlugins(required_plugins) then
    return -- Stops script as plugins not available or versions don't match
end

if HasPlugin("YesAlready") then
    PauseYesAlready()
end

local whitelisted_duties = {
    "Sastasha",
    "The Tam-Tara Deepcroft",
    "Copperbell Mines",
    "The Bowl of Embers",
    "The Thousand Maws of Toto-Rak",
    "Haukke Manor",
    "Brayflox's Longstop",
    "The Navel",
    "The Stone Vigil",
    "The Howling Eye",
    "Castrum Meridianum",
    "The Praetorium",
    "The Porta Decumana",
    "Snowcloak",
    "The Keeper of the Lake",
    "Sohm Al",
    "The Aery",
    "The Vault",
    "The Great Gubal Library",
    "The Aetherochemical Research Facility",
    "The Antitower",
    "Sohr Khai",
    "Xelphatol",
    "Baelsar's Wall",
    "The Sirensong Sea",
    "Bardam's Mettle",
    "Doma Castle",
    "Castrum Abania",
    "Ala Mhigo",
    "The Drowned City of Skalla",
    "The Burn",
    "The Ghimlyt Dark",
    "Holminster Switch",
    "Dohn Mheg",
    "The Qitana Ravel",
    "Malikah's Well",
    "Mt. Gulg",
    "Amaurot",
    "The Grand Cosmos",
    "Anamnesis Anyder",
    "The Heroes' Gauntlet",
    "Matoya's Relict",
    "Paglth'an",
    "The Tower of Zot",
    "The Tower of Babil",
    "Vanaspati",
    "Ktisis Hyperboreia",
    "The Aitiascope",
    "The Mothercrystal",
    "The Dead Ends",
    "Alzadaal's Legacy",
    "The Fell Court of Troia",
    "Lapis Manalis",
    "The Aetherfont",
    "The Lunar Subterrane",
    "Ihuykatumu",
    "Worqor Zormor",
    "Worqor Lar Dor",
    "The Skydeep Cenote",
    "Vanguard",
    "Origenics",
    "Everkeep",
    "Alexandria"
}

function IsDutyWhitelisted(duty_name)
    LogInfo("[QSTC] Checking if " .. duty_name .. " is in the whitelist")
    -- replaces the dashes square uses with normal ones, just to be extra sure
    local function ReplaceDashes(s)
        return s:gsub("–", "-"):gsub("—", "-"):gsub("‑", "-"):gsub("‐", "-")
    end

    -- lowers the string in case there's inconsistencies
    local duty_name_lower = ReplaceDashes(string.lower(duty_name))

    for _, whitelisted_duty in ipairs(whitelisted_duties) do
        local whitelisted_duty_lower = ReplaceDashes(string.lower(whitelisted_duty))
        if whitelisted_duty_lower == duty_name_lower then
            LogInfo("[QSTC] " .. duty_name .. " is in the whitelist")
            return true
        end
    end
    LogInfo("[QSTC] " .. duty_name .. " is not in the whitelist")
    return false
end

local function SquaredDistance(x1, y1, z1, x2, y2, z2)

    if type(x1) ~= "number" or type(y1) ~= "number" or type(z1) ~= "number" or
       type(x2) ~= "number" or type(y2) ~= "number" or type(z2) ~= "number" then
        LogInfo("[QSTC] invalid input type in squared distance, returning nil")
        return nil
    end

    LogInfo("[QSTC] Squaring distance " .. x1 .. " " .. y1 .. " " .. z1 .. " against " .. x2 .. " " .. y2 .. " " .. z2)

    if GetCharacterCondition(45) then
        LogInfo("[QSTC] Cancelling distance squaring due to zone transition, returning nil")
        return nil
    end

    local success, result = pcall(function()
        local dx = x2 - x1
        local dy = y2 - y1
        local dz = z2 - z1
        local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
        return math.floor(dist + 0.5)
    end)

    if success then
        LogInfo("[QSTC] Successfully squared distance: " .. result)
        return result
    else
        LogInfo("[QSTC] Failed to square distance " .. x1 .. " " .. y1 .. " " .. z1 .. " against " .. x2 .. " " .. y2 .. " " .. z2)
        return nil
    end
end


local function WithinThreeUnits(x1, y1, z1, x2, y2, z2)
    local dist = SquaredDistance(x1, y1, z1, x2, y2, z2)
    if dist then
        return dist <= 3
    else
        return false
    end
end

local function CheckForQuestSpecificActions()
    -- currently none
end

local function CheckForQuestSpecificInstanceActions()
    -- currently none
end

local function WaitforInstanceFinishAndStartQst()
    CheckForQuestSpecificInstanceActions()
    LogInfo("[QSTC] Wait for instance finish active")
    repeat
        Sleep(1)
        LogInfo("[QSTC] Waiting for instance to finish...")
    until not GetCharacterCondition(34) and not GetCharacterCondition(56) and not GetCharacterCondition(45) and not GetCharacterCondition(51)
    repeat
        Sleep(0.1)
    until IsPlayerAvailable()
    LogInfo("[QSTC] Out of instance")
    Sleep(1)
    EquipRecommendedGear()
    local qst_start_retry_timer = 0
    repeat
        qst_start_retry_timer = qst_start_retry_timer + 1
        LogInfo("[QSTC] Out of duty, starting Questionable")
        yield("/qst start")
        Sleep(2)
        if qst_start_retry_timer == 5 and not QuestionableIsRunning() then
            LogInfo("[QSTC] Questionable still not started, attempting reload")
            yield("/qst reload")
        end
    until QuestionableIsRunning() or qst_start_retry_timer > 10
    if qst_start_retry_timer > 10 then
        LogInfo("[QSTC] Questionable seems to have failed to start")
    end
    Sleep(0)
    LogInfo("[QSTC] Setting rsr to off")
    RSRChangeOperatingMode(0)
    Sleep(1)
    LogInfo("[QSTC] Setting rsr to auto")
    RSRChangeOperatingMode(1)
    if bossmod_ai_outside_of_instances then
        LogInfo("[QSTC] Setting bmrai to on")
        yield("/vbmai on")
    else
        LogInfo("[QSTC] Setting bmrai to off")
        yield("/vbmai off")
    end
    LogInfo("[QSTC] Wait for instance finish no longer active")
end

-- Qst reloader stuff
local qst_reloader_player_pos_x = GetPlayerRawXPos()
local qst_reloader_player_pos_y = GetPlayerRawYPos()
local qst_reloader_player_pos_z = GetPlayerRawZPos()
local qst_reloader_counter = 0
local qst_reloader_timer = 0
local qst_success_1
local qst_success_2
local qst_success_3
LogInfo("[QSTC] Questionable companion started successfully")
for _, char in ipairs(chars) do
    local finished = false
    if GetCharacterName(true) == char then
        -- continue, no relogging needed
    else
        LogInfo("[QSTC] Logging into character: "..char)
        RelogCharacter(char)
        Sleep(23.0)
        LoginCheck()
        LogInfo("[QSTC] Logged in successfully")
    end
    LogInfo("[QSTC] Changing all needed settings on character: "..char)
    repeat
        Sleep(0.1)
    until IsPlayerAvailable()
    yield("/at e")
    yield("/qst start")
    RSRChangeOperatingMode(1)
    if enforce_settings then
        -- RSR Settings
        yield("/rotation Settings HostileType AllTargetsWhenSoloInDuty")
        yield("/rotation Settings TargetFatePriority False")
        yield("/rotation Settings SwitchTargetFriendly True")
        yield("/rotation Settings UseHpPotions True")
        yield("/rotation Settings NoNewHostiles True")
        yield("/rotation Settings AoEType Full")
        yield("/rotation Settings HostileType AllTargetsWhenSoloInDuty")
        yield("/rotation Settings AutoOffWhenDutyCompleted False")
        yield("/rotation Settings AutoOffSwitchClass False")
        yield("/rotation Settings AutoOffWhenDead False")
        yield("/rotation Settings AutoOffAfterCombat False")
        yield("/rotation Settings AutoOffCutScene False")
        yield("/rotation Settings AutoOffBetweenArea False")
        yield("/rotation Settings TargetingTypes removeall")
        yield("/rotation Settings TargetingTypes add LowHP")
        -- VBM settings
        yield("/vbm ar toggle")
        yield("/vbm cfg ZoneModuleConfig EnableQuestBattles True")
        yield("/vbm cfg ZoneModuleConfig MinMaturity 1")
        yield("/vbm cfg BossModuleConfig MinMaturity 1")
        yield("/vbm cfg AiConfig AutoFate False")
    end
    if bossmod_ai_outside_of_instances then
        yield("/vbmai on")
    else
        yield("/vbmai off")
    end
    LogInfo("[QSTC] All settings set, going into main loop")
    local hp_treshold_switch = false
    while not finished do

        -- Disables bmr while vnav is moving so it doesn't break movement, but only if in combat
        if PathIsRunning() and not GetCharacterCondition(34) and GetCharacterCondition(26) then
            yield("/vbmai off")
        end

        -- Unexpected combat handler
        if GetCharacterCondition(26) and not GetCharacterCondition(34) and not PathIsRunning() then
            LogInfo("[QSTC] Unexpected combat handler active")
            if not QuestionableIsRunning() then
                LogInfo("[QSTC] Unexpected combat handler: Turning bmrai on")
                yield("/vbmai on")
                repeat
                    Sleep(1)
                until not GetCharacterCondition(26)
                LogInfo("[QSTC] Unexpected combat handler: Setting bmr back to configured setting")
                if bossmod_ai_outside_of_instances then
                    yield("/vbmai on")
                else
                    yield("/vbmai off")
                end
                Sleep(0.5)
                LogInfo("[QSTC] Unexpected combat handler: Reloading questionable")
                yield("/qst reload")
                Sleep(1)
                LogInfo("[QSTC] Unexpected combat handler: Starting questionable")  
                yield("/qst start")
            end
            LogInfo("[QSTC] Unexpected combat handler no longer active")
        end

        -- Force enable bossmod under x% health 
        local current_hp_percentage = (GetHP() / GetMaxHP()) * 100
        if current_hp_percentage < enable_bossmod_ai_hp_treshold and not hp_treshold_switch and enable_bossmod_ai_hp_treshold ~= 0 and not GetCharacterCondition(34) then
            yield("/vbmai on")
            hp_treshold_switch = true
        elseif current_hp_percentage > enable_bossmod_ai_hp_treshold and hp_treshold_switch and enable_bossmod_ai_hp_treshold ~= 0 and not GetCharacterCondition(34) and not GetCharacterCondition(26) then
            hp_treshold_switch = false
            if bossmod_ai_outside_of_instances then
                yield("/vbmai on")
            else
                yield("/vbmai off")
            end
        end

        -- Qst reloader
        if qst_reloader_enabled and not GetCharacterCondition(26) and not GetCharacterCondition(34) and IsPlayerAvailable() and NavIsReady() then
            if qst_reloader_counter % 2 == 0 then
                qst_success_1, qst_reloader_player_pos_x = pcall(GetPlayerRawXPos)
                qst_success_2, qst_reloader_player_pos_y = pcall(GetPlayerRawYPos)
                qst_success_3, qst_reloader_player_pos_z = pcall(GetPlayerRawZPos)
            elseif qst_reloader_counter % 2 == 1 then
                local qst_success_4, x1 = pcall(GetPlayerRawXPos)
                local qst_success_5, y1 = pcall(GetPlayerRawYPos)
                local qst_success_6, z1 = pcall(GetPlayerRawZPos)
                if not (qst_success_1 and qst_success_2 and qst_success_3 and qst_success_4 and qst_success_5 and qst_success_6) then
                    -- do nothing
                else
                    if not GetCharacterCondition(45) and IsPlayerAvailable() then
                        if WithinThreeUnits(qst_reloader_player_pos_x, qst_reloader_player_pos_y, qst_reloader_player_pos_z, x1, y1, z1) then
                            qst_reloader_timer = qst_reloader_timer + 1
                            if qst_reloader_echo then
                                Echo("Quest reloader timer incremented to " .. qst_reloader_timer)
                            end
                            if qst_reloader_timer > qst_reloader_threshold then
                                yield("/qst reload")
                                Echo("Questionable seems stuck, reloading and attempting to start it again")
                                Sleep(2)
                                yield("/qst start")
                                qst_reloader_timer = 0
                            end
                        else
                            if qst_reloader_echo then
                                Echo("Quest reloader timer reset")
                            end
                            qst_reloader_timer = 0
                        end
                    end
                end
            end
            qst_reloader_counter = qst_reloader_counter + 1
        end

        -- Stuck checker
        if PathIsRunning() then
            local retry_timer = 0
            while PathIsRunning() do
                local success1, x1 = pcall(GetPlayerRawXPos)
                local success2, y1 = pcall(GetPlayerRawYPos)
                local success3, z1 = pcall(GetPlayerRawZPos)
                if not (success1 and success2 and success3) then
                    goto continue
                end
                Sleep(2)
                local success4, x2 = pcall(GetPlayerRawXPos)
                local success5, y2 = pcall(GetPlayerRawYPos)
                local success6, z2 = pcall(GetPlayerRawZPos)
                if not (success4 and success5 and success6) then
                    goto continue
                end
                if WithinThreeUnits(x1, y1, z1, x2, y2, z2) and PathIsRunning() then
                    LogInfo("[QSTC] Stuck checker active, stopping questionable and attempting reload unstuck")
                    yield("/qst stop")
                    retry_timer = retry_timer + 1
                    if retry_timer > 4 then -- 4 would be about 8 seconds, with some extra time since it waits a second after reloading
                        LogInfo("[QSTC] Stuck checker: Stuck for too long, attempting rebuild")
                        yield("/vnav rebuild")
                    else
                        LogInfo("[QSTC] Stuck checker: Reloading vnav")
                        yield("/vnav reload")
                    end
                    Sleep(1)
                    LogInfo("[QSTC] Stuck checker: Starting questionable again")
                    yield("/qst start")
                    repeat
                        Sleep(0.1)
                    until PathIsRunning()
                    DoGeneralAction("Jump")
                else
                    retry_timer = 0
                end
                ::continue::
            end
        end

        -- Quest checker
        if IsQuestNameAccepted(quest_name_to_stop_at) then
            LogInfo("[QSTC] Quest checker active, time to stop questionable and move on to next character")
            repeat
                Sleep(0.1)
            until IsPlayerAvailable()
            repeat
                yield("/qst stop")
                Sleep(2)
            until not QuestionableIsRunning()
            finished = true
            LogInfo("[QSTC] Quest checker not longer active")
        end

        -- Quest specific actions
        CheckForQuestSpecificActions()

        -- Duty helper
        if IsAddonReady("ContentsFinder") and (remove_entrance_restriction or DoesObjectExist("Entrance")) then
            LogInfo("[QSTC] Duty helper active, attempting to pull the duty name from JournalDetail")
            repeat
                Sleep(1)
            until IsAddonReady("JournalDetail")
            Sleep(2) -- to really make sure it's ready to pull the duty name
            local duty = GetNodeText("JournalDetail", 19)
            LogInfo("[QSTC] Duty helper: JournalDetail 19 is " .. duty)
            LogInfo("[QSTC] Duty helper: Checking if "..duty.." is on the whitelist")
            if IsDutyWhitelisted(duty) then
                LogInfo("[QSTC] Duty helper: "..duty.." is on the whitelist, queueing it with supports")
                AutoDutyRun(duty)
                LogInfo("[QSTC] Duty helper: Waiting 30 seconds to make sure we're properly in the duty")
                yield("/vbmai on")
                ZoneTransitions()
                Sleep(2)
                RSRChangeOperatingMode(1)
                WaitforInstanceFinishAndStartQst()
            else
                Echo(duty.." is not on the duty whitelist")
                LogInfo("[QSTC] Duty helper: "..duty.." is not on the whitelist, closing duty finder")
                repeat
                    yield("/pcall ContentsFinder true -1")
                    Sleep(1)
                until not IsAddonVisible("ContentsFinder")
            end
            LogInfo("[QSTC] Duty helper no longer active")
        end

        -- Instance helper
        if IsAddonReady("SelectYesno") or IsAddonReady("DifficultySelectYesNo") then
            LogInfo("[QSTC] Instance helper active")
            Sleep(3)
            local text1 = GetNodeText("SelectYesno", 15)
            LogInfo("[QSTC] Instance helper: SelectYesno 15 is "..tostring(text1))
            local text2 = GetNodeText("DifficultySelectYesNo", 13)
            LogInfo("[QSTC] Instance helper: DifficultySelectYesNo 13 is "..tostring(text2))
            if string.find(text1, "Commence") or string.find(text2, "Commence") then
                if string.find(text1, "Commence") then
                    repeat
                        LogInfo("[QSTC] Instance helper: Commence under SelectYesno found, attempting to start the instance")
                        yield("/pcall SelectYesno true 0")
                        Sleep(1)
                    until not IsAddonVisible("SelectYesno")
                elseif string.find(text2, "Commence") then
                    repeat
                        LogInfo("[QSTC] Instance helper: Commence under DifficultySelectYesNo found, attempting to start the instance")
                        yield("/pcall DifficultySelectYesNo true 0")
                        Sleep(1)
                    until not IsAddonVisible("DifficultySelectYesNo")
                end
                ZoneTransitions() -- make sure to wait properly for the transition
                Sleep(3)
                RSRChangeOperatingMode(1)
                LogInfo("[QSTC] Instance helper: Inside instance, setting bmrai to on")
                yield("/vbmai on")
                WaitforInstanceFinishAndStartQst()
                LogInfo("[QSTC] Instance helper no longer active")
            end
        end

        -- Death handler !!needs to check if not in duty (maybe)
        if GetHP() == 0 then
            yield("/vbm ai off")
            yield("/vbm ai followtarget off")
            yield("/vbm ai followcombat off")
            yield("/vbm ai followoutofcombat off")
            yield("/echo [QST Companion] You have died. Returning to home aetheryte.")
            local xpos = GetPlayerRawXPos()
            local ypos = GetPlayerRawYPos()
            local zpos = GetPlayerRawZPos()
            local selectedZoneId = tostring(GetZoneID()) -- Convert Zone ID to string to match Zone_List keys
            yield("/echo [QST Companion] Selected Zone ID: " .. selectedZoneId)
            local selectedZone = Zone_List[selectedZoneId] -- Look up the zone in Zone_List
            local firstAetheryte = nil -- Aetheryte to return to after respawn    
            if selectedZone then
                yield("/echo [QST Companion] Found Zone: " .. selectedZone["Zone"])
                    -- Check if there are Aetherytes available in the zone
                if #selectedZone["Aetherytes"] > 0 then
                    -- Iterate through all Aetherytes and find the first unlocked one
                    for _, aetheryte in ipairs(selectedZone["Aetherytes"]) do
                        if IsAetheryteAttuned(aetheryte["Name"]) then
                            firstAetheryte = aetheryte["Name"]
                            break
                        end
                    end
                    if firstAetheryte then
                        yield("/echo [QST Companion] Teleporting to: " .. firstAetheryte)
                    else
                        yield("/echo [QST Companion] No unlocked aetherytes available in the current zone.")
                    end 
                else
                    yield("/echo [QST Companion] No aetherytes available in the current zone.")
                end
            else
                yield("/echo [QST Companion] Zone not found in Zone_List.") --!!should add handling to this
            end
            for i=1, 100 do
                Sleep(0.1)
                if IsAddonVisible("SelectYesno") then
                    yield("/callback SelectYesno true 0")
                    Sleep(0.1)
                end
            end
            LoginCheck()
            Teleporter(firstAetheryte, "tp")
            Movement(xpos, ypos, zpos)
        end
        LogInfo("[QSTC] Waiting for 1 second...")
        Sleep(1)
    end
    LogInfo("[QSTC] " .. char .. " is finished! Moving on")
    finished = false
    Teleporter("Limsa", "tp")
end
LogOut()

if HasPlugin("YesAlready") then
    RestoreYesAlready()
end
