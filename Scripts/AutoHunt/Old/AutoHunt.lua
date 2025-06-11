--[[***************
*     AutoHunt    *
*******************
    Version Notes:
    0.1.1.5  ->    Will now move back to flag after each mob + bugfixes + clean up/rewrite code.
                   It's faster and more reliable to notice if the log/entry has been completed.
                   Movement looks less like a bot.
                   Cutter's Cry should work reliably now.
                   Unlocks SAM for easy gear and DPS.
    0.1.1.4  ->    GC rank-up option added, does turnin for seals if needed for rank up.
    0.1.1.3  ->    Added basic support for all GC dungeons.
    0.1.1.2  ->    DeathHandler added in a few places.
    0.1.1.1  ->    Made things more reliable: stop if close enough to flag, prevent getting stuck while attempting to mount. 
    0.1.1.0  ->    Added Flames GC dungeon support, with or without helper toon. See Settings.
    0.1.0.0  ->    Friendly's makeover. Turbocharged for reliability: checks to see if it gets stuck in many places, mount selector, added fate support, etc.
    0.0.1.0  ->    The official versioning of this script begins now. I spent time getting the actual coordinates for the GC log mobs, but the class log mobs still use publicly available coordinates, which are highly inaccurate. pot0to cleaned up a bunch of things, especially a bug that was causing errors with the job to class conversion. I streamlined the pathing process. Originally it used node pathing from Mootykins.

    ***************
    * Description *
    ***************
    An SND script to automate the hunt log for a given class/GC and rank. Goes to home/inn after.
    If doing GC log, it's recommended that you're lvl 50. It will unlock SAM for you if you want.
    Does dungeon mobs for GC logs, with an option to invite a helper and leave duty after completing log.
    Does GC rankups, will try to exchange seals if that's preventing you from ranking up.
    
    **************
    *  Settings  *
    ************]]
-- Choose either "class" to do your class log or "GC" to do your Grand Company Log
local route = "GC"
-- Choose what log to finish: nil to do next one available or 1, 2, 3, 4, 5
local log_to_do = nil

-- Movement
local mount = true -- have you unlocked mounts yet? (you should btw, saves a bunch of time)
local mount_name = "SDS Fenrir" -- "Company Chocobo" or "SDS Fenrir" or any other mount name
local move_type = "walk" -- "walk" or "fly" aka. have you finished ARR?
local goto_inn = true --true/false, after finishing, do we go to inn or just /li auto

--GC specific (lvl 50 recommended)
local stop_at_rank_two = true --for GC rankup you only need log 1 and 2. Stop there?
local do_dungeons = true -- true/false, should it do GC dungeon mobs
local duty_timer_limit = 20 --(minutes), leave dungeon if it hasn't finished in this time, indicating a problem
local complete_duty = false --true/false, after hunt log is complete, should you finish the duty
local rank_up = true -- true/false, attempt to rank up after finishing the log, does turnin for seals.
local party_member = "" --Firstname Lastname or leave empty ("") for solo
local server = "" --write the server name to meet the helper eg. "Lich"
local meetup_tp = "limsa" --write the Aetheryte to use to meet helper, you don't have to be exact as long as it works with /tp
local swap_to_SAM = true --unlock and swap to Samurai. This won't work if your armory is full.

-- These variables help with pathing and are used for unstucking
local interval_rate = 0.3 -- sets many waiting times, if you set this lower and it creates a bug, set it higher
local ping_radius = 30 -- what's considered close enough to flag and skipping mounting

    --[[************
    *    Agenda    *
    ****************
    Test all the mobs. --Flames GC 1&2 done
    Only level sync if target can't be attacked otherwise.
    Add option to unlock SAM.

    *********************
    *    Requirements   *
    *********************
    -> Chat Coordinates: Dalamud
    -> Pandora's Box: https://love.puni.sh/ment.json
    -> vnavmesh: https://puni.sh/api/repository/veyn
    -> RSR: https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json
    -> vbm : https://puni.sh/api/repository/veyn
    -> SomethingNeedDoing (Expanded Edition) [Make sure to press the lua button when you import this] -> https://puni.sh/api/repository/croizat
    -> Teleporter: Dalamud
    -> CBT: for Expert Delivery before unlocking it https://puni.sh/api/repository/croizat
    -> monsters.json: needs to be in %appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\ . Has the mob coords.
    -> VAC functions and lists - https://github.com/WigglyMuffin/SNDScripts/tree/main

    *****************************
    *  Required Plugin Settings *
    *****************************
    -> Pandora:
                1. Make sure to enable Auto teleport to map coords with pandora (white list the echo channel
    -> SomethingNeedDoing (Expanded Edition):
                1. Make sure to press the lua button when you import this
                2. Make sure to set up your paths. Use the Lua path setting in the SND help config.
    -> RSR:
                1. Change RSR to attack ALL enemies when solo, or previously engaged.
                2. Disable "Treat 1hp target as invincible" --rarely you may get stuck otherwise

    ***********
    * Credits *
    ***********
    Author(s): CacahuetesManu | pot0to | Friendly
    Functions borrowed from: McVaxius, Umbra, LeafFriend, plottingCreeper, Mootykins and WigglyMuffin

********************************
*  Helper Functions and Files  *
********************************
]] -- JSON handler is from https://github.com/Egor-Skriptunoff/json4lua/blob/master/json.lua
local json = require("json")

-- CacahuetesManu made this territories dictionary to quickly change between zone ID and zone name.
require("Territories")
-- Monster log is from Hunty Plugin https://github.com/Infiziert90/Hunty/tree/mas
open = io.open
monsters = open(os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\monsters.json")
if not monsters then
    yield([[/e [AutoHunt] Error: You don't have monsters.json added to %appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\ Check the script requirements!]])    
    return
end
local stringmonsters = monsters:read "*a"
monsters:close()

-- VAC stuff
SNDConfigFolder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
LoadFunctionsFileLocation = SNDConfigFolder .. "vac_functions.lua"
if not LoadFunctionsFileLocation then
    yield([[/e [AutoHunt] Error: You don't have vac_functions.lua added to %appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\ Check the script requirements!]])    
    return
end
LoadFunctions = loadfile(LoadFunctionsFileLocation)()
LoadFileCheck()

--[[********************
*  Required Functions  *
************************
]]

-- This Function is used within json.traverse to figure out where in the JSON we want to extract data.
local function MyCallback(path, json_type, value)
    if #path == 4 and path[#path - 2] == LogFinder and path[#path - 1] == rank_to_do then
        CurrentLog = value
        return true
    end
end

function Truncate1Dp(num)
    return truncate and ("%.1f"):format(num) or num
end
--[[
function Split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function ParseNodeDataString(string)
    return Split(string, ",")
end

function GetDistanceToNode(node)
    local given_node = ParseNodeDataString(node)
    return GetDistanceToPoint(tonumber(given_node[2]), tonumber(given_node[3]), tonumber(given_node[4]))
end
]]
function SquaredDistance(x1, y1, z1, x2, y2, z2)
    local success, result = pcall(function()
        local dx = x2 - x1
        local dy = y2 - y1
        local dz = z2 - z1
        local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
        return math.floor(dist + 0.5)
    end)
    if success then
        return result
    else
        return nil
    end
end

function WithinThreeUnits(x1, y1, z1, x2, y2, z2)
    local dist = SquaredDistance(x1, y1, z1, x2, y2, z2)
    if dist then
        return dist <= 3
    else
        return false
    end
end

function CheckNavmeshReady()
    while not NavIsReady() do
        LogInfo("Building navmesh, currently at " .. Truncate1Dp(NavBuildProgress() * 100) .. "%")
        Sleep(interval_rate * 10 + 0.0225)
    end
end

function IsCloseToFlag()
    x1 = GetPlayerRawXPos()
    y1 = GetPlayerRawYPos()
    z1 = GetPlayerRawZPos()
    if mobZ then
        LogInfo("[AutoHunt] x1: " .. x1 .. ", y1: " .. y1 .. ", z1: " .. z1.. ", rawX: " .. rawX .. ", rawY: " .. rawY .. ", rawZ: " .. rawZ)
        distance_to_flag = SquaredDistance(x1, y1, z1, rawX, rawY, rawZ)
        LogInfo("AutoHunt] Distance to flag: " .. distance_to_flag)
    else
        LogInfo("AutoHunt] x1: " .. x1 .. ", y1: " .. y1 .. ", z1: " .. z1.. ", rawX: " .. rawX .. ", y1: " .. y1 .. ", rawZ: " .. rawZ)
        distance_to_flag = SquaredDistance(x1, y1, z1, rawX, y1, rawZ)
        LogInfo("AutoHunt] Distance to flag: " .. distance_to_flag)
    end
    if distance_to_flag <= ping_radius then
        return true
    else
        return false
    end
end

function RotationStart()
    yield("/rotation manual")
    yield("/rotation Settings AutoOffBetweenArea False")
    yield("/rotation Settings AutoOffAfterCombat False")
    yield("/rotation Settings StartOnAttackedBySomeone True")
    yield("/rotation Settings FilterOneHpInvincible False")
    yield("/vbm ai on")
end

function MountFly()
    if HasFlightUnlocked(GetZoneID()) and move_type == "fly" then
        while not GetCharacterCondition(4) do
            yield('/mount ".. mount_name .."')
            repeat
                Sleep(interval_rate*3 + 0.0234)
                if GetCharacterCondition(26) then
                    break
                end
            until not IsPlayerCasting() and not GetCharacterCondition(57)
        end
        if not GetCharacterCondition(81) and GetCharacterCondition(4) and not GetCharacterCondition(77) and
            not (IsInZone(146) or IsInZone(180)) then -- vnavmesh has problems flying around Outer La Noscea, Southern Thanalan, and Central Coerthas Highlands
            for i=1, 10 do
                Echo("Jumping to mount")
                yield("/gaction jump")
                Sleep(interval_rate*3 + 0.0245)
                if GetCharacterCondition(77) and not GetCharacterCondition(48) then
                    break
                end
            end
        end
    end
end

function StopMoveFly()
    PathStop()
    while PathIsRunning() do
        Sleep(interval_rate + 0.0257)
    end
    LogInfo("[AutoHunt] StopMoveFly() finished.")
end

function NodeMoveFly()
    repeat
        Sleep(interval_rate + 0.0264)
        DeathHandler()
    until IsPlayerAvailable()
    CheckNavmeshReady()
    if mount == true and move_type == "fly" then
        MountFly()
        yield("/vnav flyflag")
    elseif mount == true and move_type == "walk" then
        yield("/vnav moveflag")
        Mount(mount_name)
    else
        yield("/vnav moveflag")
    end
    while not PathIsRunning() and not IsCloseToFlag() do --wait till vnav started or you're already close to the flag
        Sleep(interval_rate + 0.00244)
    end
    FindAndKillEveryTarget() --Mob_List targets
    LogInfo("[AutoHunt] NodeMoveFly() finished.")
end

function TargetMoveFly()
    CheckNavmeshReady()
    if HasTarget() then
        local target_x = GetTargetRawXPos()
        local target_y = GetTargetRawYPos()
        local target_z = GetTargetRawZPos()
        if mount == true and move_type == "fly" and GetDistanceToTarget() > ping_radius then
            MountFly()
        elseif mount == true and move_type == "walk" and GetDistanceToTarget() > ping_radius then
            Mount(mount_name)
        end
        if  target_x ~= 0 and target_y ~= 0 and target_z ~= 0 then --avoid cases where target is *somehow* lost
            yield("/vnav moveto " .. target_x .. " " .. target_y .. " " .. target_z)
        end
    end
    LogInfo("[AutoHunt] TargetMoveFly() finished.")
end

function FindAndKillEveryTarget()
    for _, mob_name in ipairs(Mob_Table) do
        if DoesObjectExist(mob_name) then
            if HuntLogCheck(mob_name, CallbackID, rankID, false) then
                yield("/vnav stop")
                FindAndKillTarget(mob_name)
            end
        end
    end
end

function UnstuckCheckMobFlag()
    if PathIsRunning() then
        local retry_timer = 0
        while PathIsRunning() do
            local first_time_check = os.clock()
            local success1, x1 = pcall(GetPlayerRawXPos)
            local success2, y1 = pcall(GetPlayerRawYPos)
            local success3, z1 = pcall(GetPlayerRawZPos)
            if not (success1 and success2 and success3) then
                goto continue
            end
            
            --this part was added in to check if there's a nearby mob we can hunt on the way
            FindAndKillEveryTarget()

            while os.clock() < first_time_check + 1.6 do --purposeful wait amount, but you can adjust it
                Sleep(0.10299)
            end
            local success4, x2 = pcall(GetPlayerRawXPos)
            local success5, y2 = pcall(GetPlayerRawYPos)
            local success6, z2 = pcall(GetPlayerRawZPos)
            if not (success4 and success5 and success6) then
                goto continue
            end
            if WithinThreeUnits(x1, y1, z1, x2, y2, z2) and PathIsRunning() then
                retry_timer = retry_timer + 1
                if GetCharacterCondition(2) then
                    DeathHandler()
                elseif IsCloseToFlag() then
                    yield("/vnav stop")
                    break
                elseif retry_timer > 7 then
                    yield("/vnav stop")
                    Echo("Pathing failed, abandoning hunt and returning home")
                    -- Go back home somewhere
                    Teleporter("auto", "li")
                    yield("/snd stop")
                elseif retry_timer == 5 then
                    yield("/vnav rebuild")
                    NodeMoveFly()
                elseif retry_timer > 2 then
                    for i = 1, 3 do
                        yield("/gaction jump")
                        Sleep(0.80335) --purposeful wait amount, but you can adjust it
                    end
                    NavReload()
                    NodeMoveFly()
                else
                    NavReload()
                    NodeMoveFly()
                end
            else
                retry_timer = 0
            end
            ::continue::
        end
    end
    LogInfo("[AutoHunt] UnstuckCheckMobFlag() finished.")
end

function UnstuckTarget()
    if PathIsRunning() and HasTarget() then
        local retry_timer = 0
        while PathIsRunning() do
            local success1, x1 = pcall(GetPlayerRawXPos)
            local success2, y1 = pcall(GetPlayerRawYPos)
            local success3, z1 = pcall(GetPlayerRawZPos)
            if not (success1 and success2 and success3) then
                goto continue
            end
            Sleep(1.30362) --purposeful wait amount, but you can adjust it
            local success4, x2 = pcall(GetPlayerRawXPos)
            local success5, y2 = pcall(GetPlayerRawYPos)
            local success6, z2 = pcall(GetPlayerRawZPos)
            if not (success4 and success5 and success6) then
                goto continue
            end
            if WithinThreeUnits(x1, y1, z1, x2, y2, z2) and PathIsRunning() then
                retry_timer = retry_timer + 1
                if GetCharacterCondition(2) then
                    DeathHandler()
                elseif retry_timer > 7 then
                    yield("/vnav stop")
                    Echo("Pathing failed, abandoning hunt and returning home")
                    -- Go back home somewhere
                    Teleporter("auto", "li")
                    yield("/snd stop")
                elseif retry_timer == 5 then
                    yield("/vnav rebuild")
                    TargetMoveFly()
                elseif retry_timer > 2 then
                    yield("/gaction jump")
                    Sleep(0.80384) --purposeful wait amount, but you can adjust it
                    NavReload()
                    TargetMoveFly()
                else
                    NavReload()
                    TargetMoveFly()
                end
            else
                retry_timer = 0
            end
            ::continue::
        end
    end
    LogInfo("[AutoHunt] UnstuckTarget() finished.")
end

function FightTarget()
    TargetMoveFly()
    RotationStart() --just in case
    Sleep(0.10403)
    if GetDistanceToTarget() > 15 then
        UnstuckTarget()
    elseif GetDistanceToTarget() > 3.5 then
        Sleep(1.0407)
    end
    if IsInFate() and not IsLevelSynced() then
        yield("/lsync")
    end
    Dismount()
    DoAction("Auto-attack")
end

function MountandMovetoFlag()
    if IsInZone(GetFlagZone()) then
        LogInfo("[AutoHunt] Position acquired X= " .. rawX .. ", Y= " .. rawY .. ", Z= " .. rawZ)
        if HasFlightUnlocked(GetZoneID()) and not (IsInZone(146) or IsInZone(180)) then -- vnavmesh has problems in Outer La Noscea and Southern Thanalan
            yield("/gaction jump")
        end
        Sleep(0.20450)
        MountFly()
        NodeMoveFly()
        UnstuckCheckMobFlag()
        StopMoveFly()
    end
    LogInfo("[AutoHunt] MountAndMovetoFlag() finished.")
end

function GetCallbackID()
    local jobId = GetClassJobId()

    -- Determine ClassID
    if jobId > 18 and jobId < 25 then
        ClassID = jobId - 18
    elseif jobId >= 26 and jobId <= 28 then
        ClassID = 26
    elseif jobId == 29 or jobId == 30 then
        ClassID = 29
    else
        ClassID = jobId
    end

    -- Set LogFinder based on route
    GCID = GetPlayerGC()
    LogFinder = tostring(route == "GC" and (GCID + 10000) or ClassID)

    -- Map ClassID to CallbackID
    local CallbackID_Map = {
        [1] = 0, [19] = 0,  -- Gladiator
        [2] = 1, [20] = 1,  -- Pugilist
        [3] = 2, [21] = 2,  -- Marauder
        [4] = 3, [22] = 3,  -- Lancer
        [5] = 4, [23] = 4,  -- Archer
        [6] = 6, [24] = 6,  -- Conjurer
        [7] = 7, [25] = 7,  -- Thaumaturge
        [26] = 8, [27] = 8, [28] = 8,  -- Arcanist
        [29] = 5, [30] = 5,  -- Rogue
        [9] = 9   -- Grand Company
    }

    CallbackID = (route == "GC" and 9 or CallbackID_Map[ClassID])
    LogInfo("[AutoHunt] GetCallbackID() done. Result:"..CallbackID)
end

function DeathHandler()
    if GetCharacterCondition(2) then
        if HasPlugin("YesAlready") then
            PauseYesAlready()
        end
        repeat
            Sleep(0.10501)
            if IsAddonReady("SelectYesno") then
                yield("/callback SelectYesno true 0")
                Sleep(0.10504)
            end
        until not GetCharacterCondition(2) or GetCharacterCondition(45) or GetCharacterCondition(51)
        ZoneTransitions()
        repeat
            yield("/tpm " .. zone_name)
            Sleep(interval_rate*3+0.10618)
        until IsPlayerCasting()
        ZoneTransitions()
        RotationStart()
        MountandMovetoFlag()
        if HasPlugin("YesAlready") then
            RestoreYesAlready()
        end
    end
    LogInfo("[AutoHunt] DeathHandler() finished.")
end

function DoGCDungeon()
    local duty = "Halatali"
    local dungeon_rank = GetNextIncompleteHuntLog(CallbackID)
    if dungeon_rank == 3 and stop_at_rank_two then
        dungeon_rank = nil
    end
    local Duty_Position_History = {} --for duty stuck check

    local function StuckInDuty()
        local stuck_threshold = 3-- distance threshold to consider "stuck" (adjust as needed)
        Sleep(1.0503)
        local current_x = GetPlayerRawXPos()
        local current_z = GetPlayerRawZPos()
        
        -- Handle nil positions (player not loaded, in transition, etc.)
        if not current_x or not current_z then
            LogInfo("[AutoHunt] StuckChecker(): Position data unavailable, skipping check")
            return false
        end
        
        -- Add current position to history
        table.insert(Duty_Position_History, {x = current_x, z = current_z})
        
        -- Keep only last 5 positions
        if #Duty_Position_History > 5 then
            table.remove(Duty_Position_History, 1)
        end
        
        -- Need at least 5 cycles to check
        if #Duty_Position_History < 5 then
            return false
        end
        
        -- Compare current position with position from 5 cycles ago
        local old_pos = Duty_Position_History[1]  -- position from 5 cycles ago
        local distance_squared = ((current_x - old_pos.x)^2 + (current_z - old_pos.z)^2)
        
        -- Consider stuck if haven't moved more than threshold distance
        if distance_squared <= stuck_threshold^2 then
            LogInfo("[AutoHunt] StuckChecker(): Player appears stuck! Distance moved in 5 cycles: " .. string.format("%.2f", math.sqrt(distance_squared)))
            return true
        end

        LogInfo("[AutoHunt] StuckChecker(): All good, not stuck.")
        return false
    end

    if not IsHuntLogComplete(9, 0) and dungeon_rank == 1 then
        duty = "Halatali"
    elseif not IsHuntLogComplete(9, 1) and dungeon_rank == 2 then
        if GetPlayerGC() == 3 then
            duty = "Cutter's Cry"
        else
            duty = "The Sunken Temple of Qarn"
        end
    elseif not IsHuntLogComplete(9, 2) and dungeon_rank == 3 then
        duty = "The Wanderer's Palace"
    else
        Echo("No hunt log dungeon to do.")
        return
    end
    local solo = true
    if not party_member or party_member ~= "" then
        solo = false
    end
    if IsAddonReady("RetainerList") then --in case it's started with AR and the addon is still open
        yield('/callback RetainerList true -1')
    end
    Sleep(0.50660)
    if not solo then
        Teleporter(server, "li")
        Teleporter(meetup_tp, "tp")
        PartyInvite(party_member)
    end
    DoGCQuestRequirements(true)
    if GetCharacterCondition(34) then --in case you crashed/dc'd during dungeon try to restart path 
        yield("/return")
        Sleep(1.0537)
        while IsAddonReady("SelectYesno") do
            yield("/callback SelectYesno true 0")
            Sleep(1.0540)
        end
        ZoneTransitions()
        yield("/ad stop")
        yield("/ad start")
    else
        yield("/ad stop") --in case ad wasn't closed properly
    end
    while not GetCharacterCondition(34) do
        AutoDutyUnsyncRun(duty)
        Sleep(3.0672)
        while GetCharacterCondition(45) or GetCharacterCondition(51) do
            Sleep(1.0674)
        end
    end
    if not solo then
        --yield("/autofollow" ..party_member) --for autofollow, but it's not great !!check frenrider for a better way
    end

    local mobs_done = false
    local enemy_list = {11, 10, 9, 8, 7, 6, 5, 4}

    while not IsPlayerAvailable() do
        Sleep(1.0534)
    end
    repeat --target mobs for the log as needed, and then optionally dip if hunt log is completed        
        local x = GetPlayerRawXPos()
        local z = GetPlayerRawZPos()
        local converted_duty_timer_limit = 60*(90-duty_timer_limit) --90min for dungeons afaik
        local duty_timer = GetDutyTimer()
        
        if duty_timer and duty_timer < converted_duty_timer_limit then --leave if we are taking longer than expected
            yield("/ad stop")
            LeaveDuty()
        end

        if duty == "Halatali" then
            if not mobs_done then
                if GetPlayerGC() == 1 then --Maelstrom
                    FindAndKillTarget("Heckler Imp")
                    Sleep(interval_rate*5+0.0686)
                    FindAndKillTarget("Doctore")
                    Sleep(interval_rate*5+0.0688)
                    if not GetCharacterCondition(26) then --checking the hunt log for mobs repeatedly in combat gave crashes
                        if not HuntLogCheck("Heckler Imp", 9, 0, false) and not HuntLogCheck("Doctore", 9, 0) then
                            mobs_done = true
                            Echo("Non-boss mobs done")
                        end
                    end
                elseif GetPlayerGC() == 2 then --Twin Adders
                    FindAndKillTarget("Heckler Imp")
                    Sleep(interval_rate*5+0.0697)
                    FindAndKillTarget("Scythe Mantis")
                    Sleep(interval_rate*5+0.0699)
                    FindAndKillTarget("Coliseum Python")
                    Sleep(interval_rate*5+0.0701)
                    if not GetCharacterCondition(26) then
                        if IsHuntLogComplete(9, 0) then -- only non-boss mobs in hunt log
                            mobs_done = true
                            Echo("Non-boss mobs done")
                        end
                    end
                elseif GetPlayerGC() == 3 then --Immortal Flames
                    FindAndKillTarget("Doctore")
                    Sleep(interval_rate*5+0.0710)
                    if not GetCharacterCondition(26) then
                        if not HuntLogCheck("Doctore", 9, 0) then
                            mobs_done = true
                            Echo("Non-boss mobs done")
                        end
                    end
                end
            elseif IsHuntLogComplete(9, 0) and not complete_duty then
                yield("/ad stop")
                LeaveDuty()
            end
        elseif duty == "The Sunken Temple of Qarn" then
            if not mobs_done then
                if GetPlayerGC() == 1 then
                    FindAndKillTarget("Temple Bat")
                    Sleep(interval_rate*5+0.0728)
                    FindAndKillTarget("The Condemned")
                    Sleep(interval_rate*5+0.0730)
                    if not GetCharacterCondition(26) then --checking the hunt log for mobs repeatedly in combat gave crashes
                        if not HuntLogCheck("Temple Bat", 9, 1, false) and not HuntLogCheck("The Condemned", 9, 1) then
                            mobs_done = true
                            Echo("Non-boss mobs done")
                        end
                    end
                elseif GetPlayerGC() == 2 then
                    FindAndKillTarget("Temple Bee")
                    Sleep(interval_rate*5+0.0739)
                    if not GetCharacterCondition(26) then --checking the hunt log for mobs repeatedly in combat gave crashes
                        if not HuntLogCheck("Temple Bee", 9, 1) then
                            mobs_done = true
                            Echo("Non-boss mobs done")
                        end
                    end
                end
            elseif IsHuntLogComplete(9, 1) and not complete_duty then
                yield("/ad stop")
                LeaveDuty()
            end
        elseif duty == "Cutter's Cry" then --this dungeon can suck my ass
            if not mobs_done then
                if not HuntLogCheck("Sand Bat", 9, 1, false) and not HuntLogCheck("Sabotender Desertor", 9, 1) then
                    mobs_done = true
                    Echo("Non-boss mobs done")
                elseif GetDutyInfoText(2) ~= "Slay all the enemies: 8/8" then --just correcting AD here as it can get stuck
                    LogInfo("Found "..GetDutyInfoText(2))
                    FindAndKillTarget() --kill everything
                    Sleep(0.640)
                elseif x > -60.6 and x < -21.6 and z < 169.7 and z > 131.4 then --close to last Sand bat
                    if HuntLogCheck("Sand Bat", 9, 1) then
                        yield("/ad pause") --don't you run past you blind buffoon
                        for i=1, 15 do
                            if GetCharacterCondition(26) then --this is here to stop overpulling
                                Sleep(1)
                                RotationStart()
                            end
                        end
                        while HuntLogCheck("Sand Bat", 9, 1) do
                            Movement(-51.5, 0, 125)
                            FindAndKillTarget("Sand Bat")
                            Sleep(1.0653)
                        end
                        yield("/ad resume")
                    end
                elseif GetDutyInfoText(4) == "Clear the Sunken Antechamber: 0/1" and not (x < 2 and x > -30 and z < 224 and z > 196) then
                    while HuntLogCheck("Sabotender Desertor", 9, 1) do --if you say this is overkill, you don't know my pain
                        yield("/ad pause") --don't you dare run past you washed-up wretch
                        Sleep(0.633)
                        if GetCharacterCondition(26) then
                            FindAndKillTarget("Sabotender Desertor", 35) --this is 35 cause 36 can get stuck if you aggroed a still alive sabotender in the previous chamber
                        else
                            if z > -135 then --figure out north or south chamber 
                                yield("/vnav moveto 315.0 -1.5 -86") --this spot is between the 2 sabotenders on the right
                            else
                                yield("/vnav moveto 316 -3.3 -173") --similar spot in 2nd wet sands area
                            end
                            Sleep(3.0635)
                            FindAndKillTarget("Sabotender Desertor")
                        end
                        repeat --this is here because if you already aggroed a sabotender and you let AD run often, it WILL run past the mobs
                            local found = false
                            for _, enemy in ipairs(enemy_list) do
                                if GetNodeText("_Enemylist,", enemy, 14) == "Sabotender Desertor" then
                                    found = true
                                    Sleep(1.0642)
                                end
                            end
                        until not found
                        while GetTargetName() == "Sabotender Desertor" and GetDistanceToTarget() < 41 do --yes i even got stuck following behind a sabotender endlessly, but this should be solved now, leaving here just in case
                            FindAndKillTarget("Sabotender Desertor")
                            Sleep(1)
                        end
                        yield("/ad resume")
                    end
                end
            elseif (GetTargetName() == "Giant Tunnel Worm" or IsHuntLogComplete(9, 1)) and not complete_duty then 
                yield("/ad stop")
                LeaveDuty()
            end
        elseif duty == "The Wanderer's Palace" then
            if not mobs_done then
                if GetPlayerGC() == 1 then
                    FindAndKillTarget("Tonberry")
                    Sleep(interval_rate*5+0.0775)
                    if not GetCharacterCondition(26) then --checking the hunt log
                        if not HuntLogCheck("Tonberry", 9, 2) then
                            mobs_done = true
                            Echo("Non-boss mobs done")
                        end
                    end
                elseif GetPlayerGC() == 2 then
                    FindAndKillTarget("Tonberry")
                    Sleep(interval_rate*5+0.0784)
                    FindAndKillTarget("Bronze Beetle")
                    Sleep(interval_rate*5+0.0786)
                    if not GetCharacterCondition(26) then --checking the hunt log
                        if not HuntLogCheck("Tonberry", 9, 2, false) and not HuntLogCheck("Bronze Beetle", 9, 2) then
                            mobs_done = true
                            Echo("Non-boss mobs done")
                        end
                    end
                elseif GetPlayerGC() == 3 then
                    FindAndKillTarget("Tonberry")
                    Sleep(interval_rate*5+0.0795)
                    FindAndKillTarget("Corrupted Nymian")
                    Sleep(interval_rate*5+0.0797)
                    FindAndKillTarget("Soldier of Nym")
                    Sleep(interval_rate*5+0.0799)
                    if not GetCharacterCondition(26) then --checking the hunt log
                        if not HuntLogCheck("Tonberry", 9, 2, false) and not HuntLogCheck("Corrupted Nymian", 9, 2, false) and not HuntLogCheck("Soldier of Nym", 9, 2) then
                            mobs_done = true
                            Echo("Non-boss mobs done")
                        end
                    end
                end
            elseif IsHuntLogComplete(9, 2) and not complete_duty then 
                yield("/ad stop")
                LeaveDuty()
            end        
        end
        Sleep(1.0814)
        if GetHP() == GetMaxHP() then --preliminary stuck check
            if StuckInDuty() then --this should not trigger with wait times up to 10 seconds. even if it does, it might skip the wait which is hopefully ok. idk if there's any dungeon where you don't move for 10 seconds while full hp
                LogInfo("[AutoHunt] StuckChecker(): StuckInDuty() came back true, soft reset AD.")
                yield("/ad pause")
                Sleep(1.0783)
                yield("/ad resume")
            end
        end
        LogInfo("[AutoHunt] Waiting for instance to finish...")
    until not GetCharacterCondition(34) and not GetCharacterCondition(56) and not GetCharacterCondition(45) and not GetCharacterCondition(51)
    if not solo then
        PartyDisband()
        Teleporter(" ", "li") --back to home world
        Teleporter("inn", "li")
    end
end

function DoExtraGCDungeon() -- this does only one at a time.
    local Duty_Position_History = {} --for duty stuck check
    local duty = "Dzemael Darkhold"
    if IsQuestDone("1128") or IsQuestDone("1129") or IsQuestDone("1130") then
        duty = "The Aurum Vale"
    end
    
    local function StuckInDuty() 
        local stuck_threshold = 3-- distance threshold to consider "stuck" (adjust as needed)
        Sleep(1.0503)
        local current_x = GetPlayerRawXPos()
        local current_z = GetPlayerRawZPos()
        
        -- Handle nil positions (player not loaded, in transition, etc.)
        if not current_x or not current_z then
            LogInfo("[AutoHunt] StuckChecker(): Position data unavailable, skipping check")
            return false
        end
        
        -- Add current position to history
        table.insert(Duty_Position_History, {x = current_x, z = current_z})
        
        -- Keep only last 5 positions
        if #Duty_Position_History > 5 then
            table.remove(Duty_Position_History, 1)
        end
        
        -- Need at least 5 cycles to check
        if #Duty_Position_History < 5 then
            return false
        end
        
        -- Compare current position with position from 5 cycles ago
        local old_pos = Duty_Position_History[1]  -- position from 5 cycles ago
        local distance_squared = ((current_x - old_pos.x)^2 + (current_z - old_pos.z)^2)
        
        -- Consider stuck if haven't moved more than threshold distance
        if distance_squared <= stuck_threshold^2 then
            LogInfo("[AutoHunt] StuckChecker(): Player appears stuck! Distance moved in 5 cycles: " .. string.format("%.2f", math.sqrt(distance_squared)))
            return true
        end

        LogInfo("[AutoHunt] StuckChecker(): All good, not stuck.")
        return false
    end

    local solo = true
    if not party_member or party_member ~= "" then
        solo = false
    end
    if IsAddonReady("RetainerList") then --in case it's started with AR and the addon is still open
        yield('/callback RetainerList true -1')
    end
    Sleep(0.50660)
    if not solo then
        Teleporter(server, "li")
        Teleporter(meetup_tp, "tp")
        PartyInvite(party_member)
    end
    DoGCQuestRequirements()
    if GetCharacterCondition(34) then --in case you crashed/dc'd during dungeon try to restart path 
        yield("/return")
        Sleep(1.0537)
        while IsAddonReady("SelectYesno") do
            yield("/callback SelectYesno true 0")
            Sleep(1.0540)
        end
        ZoneTransitions()
        yield("/ad stop")
        yield("/ad start")
    else
        yield("/ad stop") --in case ad wasn't closed properly
    end
    while not GetCharacterCondition(34) do
        AutoDutyUnsyncRun(duty)
        Sleep(3.0672)
        while GetCharacterCondition(45) or GetCharacterCondition(51) do
            Sleep(1.0674)
        end
    end
    if not solo then
        --yield("/autofollow" ..party_member) --for autofollow, but it's not great !!check frenrider for a better way
    end

    while not IsPlayerAvailable() do
        Sleep(1.0534)
    end
    repeat
        local x = GetPlayerRawXPos()
        local z = GetPlayerRawZPos()
        local converted_duty_timer_limit = 60*(90-duty_timer_limit) --90min for dungeons afaik
        local duty_timer = GetDutyTimer()
        
        if duty_timer and duty_timer < converted_duty_timer_limit then --leave if we are taking longer than expected
            yield("/ad stop")
            LeaveDuty()
        end
        if duty == "Dzemael Darkhold" then
            if x then --add coords to stand in orbs
                
            end
        else--whatever aurum needs
            
        end
        
        Sleep(1.0814)
        if GetHP() == GetMaxHP() then --preliminary stuck check
            if StuckInDuty() then --this should not trigger with wait times up to 20 seconds. even if it does, it might skip the wait which is hopefully ok. idk if there's any dungeon where you don't move for 10 seconds while full hp
                LogInfo("[AutoHunt] StuckChecker(): StuckInDuty() came back true, soft reset AD.")
                yield("/ad pause")
                Sleep(1.0783)
                yield("/ad resume")
            end
        end
        LogInfo("[AutoHunt] Waiting for instance to finish...")
    until not GetCharacterCondition(34) and not GetCharacterCondition(56) and not GetCharacterCondition(45) and not GetCharacterCondition(51)
    if not solo then
        PartyDisband()
        Teleporter(" ", "li") --back to home world
        Teleporter("inn", "li")
    end
end

local function UnlockAetheryte(zone_name) --waiting for smartnav plugin until someone needs more zones badly
    if zone_name == "Coerthas Central Highlands" then
        while not IsAetheryteAttuned("Camp Dragonhead") do
            if not ZoneCheck("Camp Dragonhead") then
                if not ZoneCheck("Fallgourd Float") then
                    Teleporter("Fallgourd Float", "tp")
                end
                Movement(-355.55, -0.415, 171.31, 3.5, mount_name)
            end
            Movement(224.09, 301.36, -141.15, 3.5, mount_name)
            Movement(229.20, 312.91, -235.02, 3.5, mount_name)
            AttuneAetheryte()
        end
    elseif zone_name == "Outer La Noscea" then
        while not IsAetheryteAttuned("Camp Overlook") do
            if not ZoneCheck("Camp Overlook") then
                if not ZoneCheck("Camp Bronze Lake") then
                    Teleporter("Camp Bronze Lake", "tp")
                end
                Movement(284.54, 42.55, -204.27, 3.5, mount_name)
            end
            Movement(-113.44, 64.59, -216.03, 3.5, mount_name)
            AttuneAetheryte()
        end
    end
end

--[[
*******************
*  Start of Code  *
*******************
]]

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
--Get some data
    --GC rank
local gc_rank = 0
if route == "GC" then
    local gc_id = GetPlayerGC()
    if gc_id == 1 then -- checks if gc is maelstrom and adds seal amount to current_seals
        gc_rank = GetMaelstromGCRank()
    elseif gc_id == 2 then -- checks if gc is twin adder and adds seal amount to current_seals
        gc_rank = GetAddersGCRank()
    elseif gc_id == 3 then -- checks if gc is immortal flames and adds seal amount to current_seals
        gc_rank = GetFlamesGCRank()
    end
end
    --Choose which hunt log 
local next_log = GetNextIncompleteHuntLog(CallbackID)
local rank_to_do = log_to_do or next_log --I don't know why, I don't want to know why, I shouldn't have to wonder why, but for whatever reason this stupid var isn't seen by DoGCDungeon
if stop_at_rank_two and route == "GC" and rank_to_do == 3 then
    rank_to_do = 2
end
    --Is toon done?
local dont_start = false --!!below part should determine if the toon is done based on settings 
if do_extra_dungeons and route == "GC" then
    if IsQuestDone("1131") or IsQuestDone("1132") or IsQuestDone("1133") then
        dont_start = true
    end
elseif not rank_to_do or IsHuntLogComplete(CallbackID, (rank_to_do-1)) then    
    dont_start = true
end
if dont_start then
    Echo("Based on your current settings, everything is done.")
    return
end
local rankID = rank_to_do-1

Echo("[AutoHunt] Starting things.")
yield("/at e")

if swap_to_SAM and route == "GC" and GetClassJobId() ~= 34 and GetLevel() >= 50 and not IsQuestDone("2559") then
    while GetClassJobId() ~= 34 do
        QuestionableAddQuestPriority("2559")
        if not QuestionableIsRunning() then
            yield("/qst start")
        end
        Sleep(1.011)
    end
    while GetClassJobId == 34 and QuestionableGetCurrentQuestId() == "2559" do
        Sleep(1.014)
    end
    yield("/qst stop")
    while IsPlayerCasting() do
        yield("/send ESCAPE") --i know this /send isn't good, idk a better solution
        Sleep(1)
    end
    repeat --this is the fallback option if cancelling tp with /send ESC doesn't work
        Sleep(1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(51) and not GetCharacterCondition(45)
    EquipRecommendedGear()
end

-- This function traverses through the JSON and saves the data we want into a more specific table called "CurrentLog"
GetCallbackID()
local jobranks = json.decode(stringmonsters).JobRanks
CurrentLog = jobranks[LogFinder][rank_to_do].Tasks

-- This makes a table for the purpose of checking mobs while moving to see if we found one on the list.
Mob_Table = {}
OpenHuntLog(CallbackID, rankID) --this method is not good, but idk how else to make the bottom nodes populate
Sleep(0.5)
yield("/send NUMPAD0")
Sleep(0.5)
yield("/send NUMPAD0")
Sleep(0.5)
yield("/hold NUMPAD2")
Sleep(4)
yield("/release NUMPAD2")
for i = 1, #CurrentLog do -- which entry
    for j = 1, #CurrentLog[i].Monsters do -- which mob in the hunt log entry (most are a single exact mob, just more of them)
        local mob_name = CurrentLog[i].Monsters[j].Name
        table.insert(Mob_Table, mob_name)
        LogInfo("[AutoHunt] Inserted "..mob_name.." into Mob_Table.")
    end
end

-- Now we loop through the table and extract each mob, territory, location and kills needed
for i = 1, #CurrentLog do -- which entry
    LogInfo("[AutoHunt] Debug: Log Entry #"..i)
    for j = 1, #CurrentLog[i].Monsters do -- which mob in the hunt log entry (most are a single exact mob, just more of them)
        local mob_name = CurrentLog[i].Monsters[j].Name
        local mob_is_unfinished = HuntLogCheck(mob_name, CallbackID, rankID, false)
        LogInfo("[AutoHunt] Debug: Mob #"..j)
        LogInfo("[AutoHunt] Debug: Looking at "..mob_name)
        if mob_is_unfinished then
            LogInfo("[AutoHunt] Debug: Running target #"..j)
            local kills_needed = CurrentLog[i].Monsters[j].Count
            local mob_zone = CurrentLog[i].Monsters[j].Locations[1].Terri
            local mobX = CurrentLog[i].Monsters[j].Locations[1].xCoord
            local mobY = CurrentLog[i].Monsters[j].Locations[1].yCoord
            local mobZ = CurrentLog[i].Monsters[j].Locations[1].zCoord
            local zone_name = Territories[tostring(mob_zone)]

            Echo(" " .. mob_name .. " in " .. zone_name .. " is next! We need " .. kills_needed)

            DeathHandler()
            RotationStart()
            UnlockAetheryte(zone_name)

            if IsInZone(tonumber(mob_zone)) then -- If you are in the same zone, no need to teleport
                -- Here we use a plugin called Chat Coordinates to make a flag and teleport to the zone if needed
                if mobZ then
                    SetMapFlag(mob_zone, mobX, mobY, mobZ)
                    LogInfo("[AutoHunt] Using better coordinates.") -- the ones with 3D coordinates and not just a map x;y
                else
                    yield("/coord " .. mobX .. " " .. mobY .. " :" .. zone_name)
                    Sleep(interval_rate + 0.0975)
                end
            else
                if mobZ then
                    SetMapFlag(mob_zone, mobX, mobY, mobZ)
                    Sleep(interval_rate + 0.0980)
                    LogInfo("[AutoHunt] Using better coordinates.")
                    while not IsInZone(tonumber(mob_zone)) do
                        if GetCharacterCondition(26) then
                            LogInfo("[AutoHunt] Combat is preventing teleport.")
                            yield("/battletarget")
                            Sleep(0.101010)
                            FightTarget()
                        elseif IsPlayerCasting() or GetCharacterCondition(45) or GetCharacterCondition(51) then
                            Sleep(1.01015)
                        else
                            yield("/tpm " .. zone_name)
                            Sleep(interval_rate*3+0.0857)
                            DeathHandler()
                        end
                    end
                else
                    while not IsInZone(tonumber(mob_zone)) do
                        if GetCharacterCondition(26) then
                            LogInfo("[AutoHunt] Combat is preventing teleport.")
                            yield("/battletarget")
                            Sleep(0.101027)
                            FightTarget()
                        elseif IsPlayerCasting() or GetCharacterCondition(45) or GetCharacterCondition(51) then
                            Sleep(1.01030)
                        else
                            yield("/ctp " .. mobX .. " " .. mobY .. " :" .. zone_name)
                            Sleep(interval_rate*3+0.0101033)
                            DeathHandler()
                        end
                    end
                end
            end

            -- Now convert the simple map coordinates to RAW coordinates that vnav uses or use the better coordinates

            if not mobZ then
                rawX = GetFlagXCoord()
                rawY = 1024
                rawZ = GetFlagYCoord()
            else
                rawX = mobX
                rawY = mobY
                rawZ = mobZ
            end
            
                --Extras
                while not IsPlayerAvailable() do --this is here to prevent Failure: attempt to compare number with function on GetPlayerRawXPos() > -306
                    Sleep(0.862)
                end
                if GetZoneID() == 139 and GetPlayerRawXPos() > -306 and rawX <= -306 then -- avoid swimming to west side of Upper La Noscea by going around in Outer La Noscea
                    Movement(283.750, 46.000, -212.500, 3.5, mount_name)
                    Movement(-334.194, 51.997, -64.813, 3.5, mount_name)
                end

            -- You're in the zone now, moving to flag

            MountandMovetoFlag() --this has unstuck function and a bunch of nice things built in

            while mob_is_unfinished do
                LogInfo("[AutoHunt] Killing " .. mob_name .. " in progress...")
                if not GetCharacterCondition(26) then --not in combat
                    yield("/target \"" .. mob_name .. "\"") --/target looks for an object within 50 yalms
                    for i=1, 10 do
                        Sleep(0.0873)
                        if HasTarget() then
                            break
                        end
                    end
                    if not HasTarget() then
                        local target_x_pos, target_y_pos, target_z_pos = FindNearestObject(mob_name) --look for a target with 101 range instead of 50
                        if target_x_pos then
                            Mount(mount_name)
                            Movement(target_x_pos, target_y_pos, target_z_pos)
                        elseif not IsCloseToFlag() then
                            NodeMoveFly() --go back to node in case you went away and can't find a new target
                        end
                    else
                        LogInfo("Found " .. GetTargetName() .. " moving closer.")
                        FightTarget()
                    end
                    DeathHandler()
                else
                    if not HasTarget() then
                        yield("/battletarget") -- if other mobs are attacking you
                        Sleep(0.0101071)
                    end
                    LogInfo("In combat against " .. GetTargetName())
                    Sleep(0.0101074)
                    FightTarget()
                end
                Sleep(3.01086) --this is so long to allow for the game to update the hunt log entry completion
                mob_is_unfinished = HuntLogCheck(mob_name, CallbackID, rankID)
                if not mob_is_unfinished then
                    for pos, finished_mob in ipairs(Mob_Table) do
                        if finished_mob == mob_name then
                            table.remove(Mob_Table, pos)
                            LogInfo("[AutoHunt] Removed "..mob_name.." from Mob_Table.")
                            break
                        end
                    end                
                end
            end
        end
    end
end
Echo("[AutoHunt] Finished overworld hunt log for Rank " .. rank_to_do .. "!")
LogInfo("[AutoHunt] Finished overworld hunt log for Rank " .. rank_to_do .. "!")

if not GetCharacterCondition(34) and not InSanctuary() then --skip this is you're in dungeon
    if GetPlayerGC() == 1 then --go to sancuary while mobs are dead
        Teleporter("Limsa", "tp")
    elseif GetPlayerGC() == 2 then
        Teleporter("Gridania", "tp")
    else
        Teleporter("Ul'dah", "tp")
    end
end

if do_dungeons and route == "GC" then
    DoGCDungeon()
    Sleep(1.01089)
    Echo("Finished dungeon hunt log for Rank " .. rank_to_do .. "!")
end

if do_extra_dungeons then
    DoExtraGCDungeon()
    Sleep(1.01183)
    Echo("Finished extra dungeons!")
end

if rank_up then
    if not CanGCRankUp() and CanGCRankUpWithSeals() then --checks if more seals would enable rankup and do a turnin if so
        Teleporter("gc", "li")
	    if not CanExpertDelivery() then
            yield("/cbt enable MaxGCRank")
        end
        yield("/deliveroo e")
        for i=1, 20 do
            Sleep(0.101101)
            if IsAddonVisible("GrandCompanySupplyList") then
                break
            end
        end
        repeat
            Sleep(0.101107)
        until not IsAddonVisible("GrandCompanySupplyList") or IsAddonVisible("SelectYesno") or IsPlayerAvailable()
        yield("/deliveroo d")
        repeat
            Sleep(1.101111)
            if IsAddonReady("GrandCompanySupplyList") then
                yield("/callback GrandCompanySupplyList true -1")
                Sleep(0.101114)
            elseif IsAddonReady("SelectYesno") then
                yield("/callback SelectYesno true 1")
                Sleep(0.101117)
            elseif IsAddonReady("SelectString") then
                yield("/callback SelectString true 4")
                Sleep(0.101120)
            elseif IsAddonReady("GrandCompanyExchange") then
                yield("/callback GrandCompanyExchange true -1")
                Sleep(0.101123)
            end
        until not IsAddonVisible("GrandCompanySupplyList") and not IsAddonVisible("SelectString") and not IsAddonVisible("GrandCompanyExchange") and not IsAddonVisible("GrandCompanySupplyList") and IsPlayerAvailable()
    elseif CanGCRankUp() then
        Teleporter("gc", "li")
    end
    yield("/cbt disable MaxGCRank")
    if CanGCRankUp() == true then
        while CanGCRankUp() do
	        DoGCRankUp()
            Sleep(0.101132)
        end
    end
end

if goto_inn then
    if (GetZoneID() ~= 177 and GetZoneID() ~= 178 and GetZoneID() ~= 179) then
        Teleporter("inn", "li")
    end
else
    Teleporter("auto", "li")
end
