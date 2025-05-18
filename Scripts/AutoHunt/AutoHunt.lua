--[[***************
*     AutoHunt    *
*******************

    Version Notes:
    0.1.1.3  ->    Added support for all GC dungeons.
    0.1.1.2  ->    DeathHandler added in a few places
    0.1.1.1  ->    Made things more reliable: stop if close enough to flag, prevent getting stuck while attempting to mount. 
    0.1.1.0  ->    Added Flames GC dungeon support, with or without helper toon. See Settings.
    0.1.0.0  ->    Friendly's makeover. Turbocharged for reliability: checks to see if it gets stuck in many places, mount selector, added fate support, etc.
    0.0.1.0  ->    The official versioning of this script begins now. I spent time getting the actual coordinates for the GC log mobs, but the class log mobs still use publicly available coordinates, which are highly inaccurate. pot0to cleaned up a bunch of things, especially a bug that was causing errors with the job to class conversion. I streamlined the pathing process. Originally it used node pathing from Mootykins.

]]
--[[**********
*  Settings  *
**************
]]

-- Choose either "class" to do your class log or "GC" to do your Grand Company Log
local route = "GC"
-- Choose what rank to start 1, 2, 3, 4 or 5
local rankToDo = 1
-- Walk or Fly?
local mount = true -- have you unlocked mounts yet?
local mount_name = "SDS Fenrir" -- eg. Company Chocobo/SDS Fenrir
local move_type = "walk"
-- These variables help with pathing and are used for unstucking
local interval_rate = 0.3 -- if you set this lower and it creates a bug, set it higher
local timeout_threshold = 3
local ping_radius = 20
local killtimeout_threshold = 30

--GC specific
local do_dungeons = true -- true/false
local party_member = "" --Firstname Lastname or leave empty ("") for solo
local server = "Bismarck" --write the server name to meet the helper

    --[[***********
    * Description *
    ***************

    A SND Lua script that allows you to loop through all the incomplete mobs in your hunt log for a given class/GC and rank.
    Includes dungeon mobs.
 
    ****************
    *    Agenda    *
    ****************
    If possible, look for any uncompleted mobs in the hunt log while travelling.
    Skip dungeon mobs in other GC logs to IncompleteTargets function.
    Test all the mobs.
    
    *********************
    *    Requirements   *
    *********************
    -> Chat Coordinates: Dalamud
    -> Pandora Box: https://love.puni.sh/ment.json
    -> vnavmesh: https://puni.sh/api/repository/veyn
    -> RSR: https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json
    -> vbm : https://puni.sh/api/repository/veyn
    -> SomethingNeedDoing (Expanded Edition) [Make sure to press the lua button when you import this] -> https://puni.sh/api/repository/croizat
    -> Teleporter: Dalamud
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
                2. Disable "Treat 1hp target as invincible"

    ***********
    * Credits *
    ***********

    Author(s): CacahuetesManu | pot0to | Friendly
    Functions borrowed from: McVaxius, Umbra, LeafFriend, plottingCreeper, Mootykins and WigglyMuffin
]] --[[
********************************
*  Helper Functions and Files  *
********************************
]] -- JSON handler is from https://github.com/Egor-Skriptunoff/json4lua/blob/master/json.lua
local json = require("json")

-- I made this territories dictionary to quickly change between zone ID and zone name.
require("Territories")
-- Monster log is from Hunty Plugin https://github.com/Infiziert90/Hunty/tree/mas
open = io.open
monsters = open(os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\monsters.json")
local stringmonsters = monsters:read "*a"
monsters:close()

-- VAC stuff
char_list = "vac_char_list.lua"
SNDConfigFolder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
LoadFunctionsFileLocation = SNDConfigFolder .. "vac_functions.lua"
LoadFunctions = loadfile(LoadFunctionsFileLocation)()
LoadFileCheck()

--[[
************************
*  Required Functions  *
************************
]]

-- Call user provided input to figure out if we should work on Class Log or Hunt Log

if route == "class" then
    if GetClassJobId() > 18 and GetClassJobId() < 25 then
        ClassID = GetClassJobId() - 18
    elseif GetClassJobId() == 26 or GetClassJobId() == 27 or GetClassJobId() == 28 then
        ClassID = 26
    elseif GetClassJobId() == 29 or GetClassJobId() == 30 then
        ClassID = 29
    else
        ClassID = GetClassJobId()
    end

    LogFinder = tostring(ClassID)
elseif route == "GC" then
    LogFinder = tostring(GetPlayerGC() + 10000)
end

-- This Function is used within json.traverse to figure out where in the JSON we want to extract data.

local function my_callback(path, json_type, value)
    if #path == 4 and path[#path - 2] == LogFinder and path[#path - 1] == rankToDo then
        CurrentLog = value
        return true
    end
end

function Truncate1Dp(num)
    return truncate and ("%.1f"):format(num) or num
end

function ParseNodeDataString(string)
    return Split(string, ",")
end

function GetDistanceToNode(node)
    local given_node = ParseNodeDataString(node)
    return GetDistanceToPoint(tonumber(given_node[2]), tonumber(given_node[3]), tonumber(given_node[4]))
end

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
    was_ready = NavIsReady()
    while not NavIsReady() do
        yield("/echo Building navmesh, currently at " .. Truncate1Dp(NavBuildProgress() * 100) .. "%")
        Sleep(interval_rate * 10 + 0.0188)
    end
end

function MountFly()
    if HasFlightUnlocked(GetZoneID()) then
        while not GetCharacterCondition(4) do
            yield("/mount " .. mount_name)
            repeat
                Sleep(interval_rate*3 + 0.00197)
            until not IsPlayerCasting() and not GetCharacterCondition(57)
        end
        if not GetCharacterCondition(81) and GetCharacterCondition(4) and not GetCharacterCondition(77) and
            not (IsInZone(146) or IsInZone(180)) then -- vnavmesh has problems flying around Outer La Noscea, Southern Thanalan, and Central Coerthas Highlands
            repeat
                yield("/echo Jumping to mount")
                yield("/gaction jump")
                Sleep(interval_rate*3 + 0.00205)
            until GetCharacterCondition(77) and not GetCharacterCondition(48)
        end
    end
end

function StopMoveFly()
    PathStop()
    while PathIsRunning() do
        Sleep(interval_rate + 0.00214)
    end
end

function NodeMoveFly()
    repeat
        Sleep(interval_rate + 0.00220)
    until IsPlayerAvailable()
    CheckNavmeshReady()
    if mount == true and move_type == "fly" then
        MountFly()
        yield("/vnav flyflag")
    elseif mount == true and move_type == "walk" then
        Mount(mount_name)
        yield("/vnav moveflag")
    else
        yield("/vnav moveflag")
    end
end

function TargetMoveFly()
    CheckNavmeshReady()
    if HasTarget() then
        if mount == true and move_type == "fly" and GetDistanceToTarget() > 15 then
            MountFly()
            PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos())
        elseif mount == true and move_type == "walk" and GetDistanceToTarget() > 15 then
            Mount(mount_name)
            PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos())
        else
            PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos())
        end
    end
end


function unstuckflag()
    if PathIsRunning() then
        local retry_timer = 0
        while PathIsRunning() do
            local success1, x1 = pcall(GetPlayerRawXPos)
            local success2, y1 = pcall(GetPlayerRawYPos)
            local success3, z1 = pcall(GetPlayerRawZPos)
            if not (success1 and success2 and success3) then
                goto continue
            end
            Sleep(1.60260) --purposeful wait amount, but you can adjust it
            local success4, x2 = pcall(GetPlayerRawXPos)
            local success5, y2 = pcall(GetPlayerRawYPos)
            local success6, z2 = pcall(GetPlayerRawZPos)
            if not (success4 and success5 and success6) then
                goto continue
            end
            if WithinThreeUnits(x1, y1, z1, x2, y2, z2) and PathIsRunning() then
                retry_timer = retry_timer + 1
                if IsCloseToFlag() then
                    yield("/vnav stop")
                    break
                elseif retry_timer > 7 then
                    yield("/vnav stop")
                    yield("/echo Pathing failed, abandoning hunt and returning home")
                    -- Go back home somewhere
                    Teleporter("auto", "li")
                    yield("/snd stop")
                elseif retry_timer == 5 then
                    yield("/vnav rebuild")
                    NodeMoveFly()
                elseif retry_timer > 2 then
                    for i = 1, 3 do
                        yield("/gaction jump")
                        Sleep(0.80284) --purposeful wait amount, but you can adjust it
                    end
                    yield("/vnav reload")
                    NodeMoveFly()
                else
                    yield("/vnav reload")
                    NodeMoveFly()
                end
            else
                retry_timer = 0
            end
            ::continue::
        end
    end
end

function unstucktarget()
    if PathIsRunning() and HasTarget() then
        local retry_timer = 0
        while PathIsRunning() do
            local success1, x1 = pcall(GetPlayerRawXPos)
            local success2, y1 = pcall(GetPlayerRawYPos)
            local success3, z1 = pcall(GetPlayerRawZPos)
            if not (success1 and success2 and success3) then
                goto continue
            end
            Sleep(1.30310) --purposeful wait amount, but you can adjust it
            local success4, x2 = pcall(GetPlayerRawXPos)
            local success5, y2 = pcall(GetPlayerRawYPos)
            local success6, z2 = pcall(GetPlayerRawZPos)
            if not (success4 and success5 and success6) then
                goto continue
            end
            if WithinThreeUnits(x1, y1, z1, x2, y2, z2) and PathIsRunning() then
                retry_timer = retry_timer + 1
                if retry_timer > 7 then
                    yield("/vnav stop")
                    yield("/echo Pathing failed, abandoning hunt and returning home")
                    -- Go back home somewhere
                    Teleporter("auto", "li")
                    yield("/snd stop")
                elseif retry_timer == 5 then
                    yield("/vnav rebuild")
                    TargetMoveFly()
                elseif retry_timer > 2 then
                    yield("/gaction jump")
                    Sleep(0.80330) --purposeful wait amount, but you can adjust it
                    yield("/vnav reload")
                    TargetMoveFly()
                else
                    yield("/vnav reload")
                    TargetMoveFly()
                end
            else
                retry_timer = 0
            end
            ::continue::
        end
    end
end

function IsCloseToFlag()
    x1 = GetPlayerRawXPos()
    y1 = GetPlayerRawYPos()
    z1 = GetPlayerRawZPos()
    if mobZ then
        distance_to_flag = SquaredDistance(x1, y1, z1, rawX, rawY, rawZ)
        Echo("x1: " .. x1 .. ", y1: " .. y1 .. ", z1: " .. z1, "rawX: " .. rawX .. ", rawY: " .. rawY .. ", rawZ: " .. rawZ)
        Echo("Distance to flag: " .. distance_to_flag)
    else
        distance_to_flag = SquaredDistance(x1, y1, z1, rawX, y1, rawZ)
        Echo("x1: " .. x1 .. ", y1: " .. y1 .. ", z1: " .. z1, "rawX: " .. rawX .. ", y1: " .. y1 .. ", rawZ: " .. rawZ)
        Echo("Distance to flag: " .. distance_to_flag)
    end
    if distance_to_flag <= ping_radius then
        return true
    else
        return false
    end
end

function MountandMovetoFlag()
    if IsInZone(GetFlagZone()) then
        LogInfo("[AutoHunt]Position acquired X= " .. rawX .. ", Y= " .. rawY .. ", Z= " .. rawZ)
        if HasFlightUnlocked(GetZoneID()) and not (IsInZone(146) or IsInZone(180)) then -- vnavmesh has problems in Outer La Noscea and Southern Thanalan
            yield("/gaction jump")
        end
        Sleep(0.20371)
        MountFly()
        local rng_offset = 0
        ::APPROXPATH_START::
        CheckNavmeshReady()

        local node = string.format("NAMENOTGIVEN,%1.f,%1.f,%1.f", rawX, rawY, rawZ)

        NodeMoveFly()
        Sleep(interval_rate * 3 + 0.00380)
        unstuckflag()
        StopMoveFly()
        Dismount()
        return true
    end
end

function ClassorGCID()
    if GetClassJobId() > 18 and GetClassJobId() < 25 then
        ClassID = GetClassJobId() - 18
    elseif GetClassJobId() == 26 or GetClassJobId() == 27 or GetClassJobId() == 28 then
        ClassID = 26
    elseif GetClassJobId() == 29 or GetClassJobId() == 30 then
        ClassID = 29
    else
        ClassID = GetClassJobId()
    end

    GCID = GetPlayerGC()

    if route == "class" then
        LogFinder = tostring(ClassID)
    elseif route == "GC" then
        LogFinder = tostring(GCID + 10000)
    end
end

function loadupHuntlog()
    ClassID = GetClassJobId()
    rank = rankToDo - 1
    Sleep(0.20411)
    if ClassID == 1 or ClassID == 19 then
        pcallClassID = 0 -- Gladiator
    elseif ClassID == 2 or ClassID == 20 then
        pcallClassID = 1 -- Pugilist
    elseif ClassID == 3 or ClassID == 21 then
        pcallClassID = 2 -- Marauder
    elseif ClassID == 4 or ClassID == 22 then
        pcallClassID = 3 -- Lancer
    elseif ClassID == 5 or ClassID == 23 then
        pcallClassID = 4 -- Archer
    elseif ClassID == 6 or ClassID == 24 then
        pcallClassID = 6 -- Conjurer
    elseif ClassID == 7 or ClassID == 25 then
        pcallClassID = 7 -- Thaumaturge
    elseif ClassID == 26 or ClassID == 27 or ClassID == 28 then
        pcallClassID = 8 -- Arcanist
    elseif ClassID == 29 or ClassID == 30 then
        pcallClassID = 5 -- Rogue
    end

    if route == "GC" then
        yield("/callback MonsterNote true 3 9 " .. GCID) -- this is not really needed, but it's to make sure it's always working
        Sleep(interval_rate + 0.0434)
    elseif route == "class" then
        yield("/callback MonsterNote true 0 " .. pcallClassID) -- this will swap tabs
        Sleep(interval_rate + 0.0437)
    end
    yield("/callback MonsterNote true 1 " .. rank) -- this will swap rank pages
    Sleep(interval_rate + 0.0440)
    yield("/callback MonsterNote false 2 2") -- this will change it to show incomplete
end

-- Wrapper handling to show incomplete targets
function IncompleteTargets()
    if GetNodeText("MonsterNote", 2, 18, 4) == "Heckler Imp" then
        NextIncompleteTarget = GetNodeText("MonsterNote", 2, 21, 4)
    elseif GetNodeText("MonsterNote", 2, 18, 4) == "Temple Bee" then
        NextIncompleteTarget = GetNodeText("MonsterNote", 2, 20, 4)
    elseif GetNodeText("MonsterNote", 2, 18, 4) == "Doctore" then
        NextIncompleteTarget = GetNodeText("MonsterNote", 2, 21, 4)
    elseif GetNodeText("MonsterNote", 2, 18, 4) == "Firemane" then
        NextIncompleteTarget = GetNodeText("MonsterNote", 2, 20, 4)
    elseif GetNodeText("MonsterNote", 2, 18, 4) == "Thunderclap Guivre" then
        NextIncompleteTarget = GetNodeText("MonsterNote", 2, 19, 4)
    elseif GetNodeText("MonsterNote", 2, 18, 4) == "Sand Bat" then
        NextIncompleteTarget = GetNodeText("MonsterNote", 2, 21, 4)
    elseif GetNodeText("MonsterNote", 2, 18, 4) == "Temple Bat" then
        NextIncompleteTarget = GetNodeText("MonsterNote", 2, 21, 4)
    else
        if not IsNodeVisible("MonsterNote", 1, 46, 5, 2) then
            NextIncompleteTarget = GetNodeText("MonsterNote", 2, 18, 4)
        elseif IsNodeVisible("MonsterNote", 1, 46, 5, 2) and not IsNodeVisible("MonsterNote", 1, 46, 51001, 2) then
            NextIncompleteTarget = GetNodeText("MonsterNote", 2, 19, 4)
        elseif IsNodeVisible("MonsterNote", 1, 46, 5, 2) and IsNodeVisible("MonsterNote", 1, 46, 51001, 2) then
            NextIncompleteTarget = GetNodeText("MonsterNote", 2, 20, 4)
        end
    end

    Sleep(interval_rate + 0.0470)
    return NextIncompleteTarget
end

function OpenHuntlog()
    if not IsNodeVisible("MonsterNote", 1) then
        yield("/hlog")
    end
    Sleep(interval_rate + 0.0478)
end

function hlogRefresh()
    if (os.clock() - killtimeout_start > killtimeout_threshold) then
        killtimeout_start = os.clock()
        yield("/hlog")
        for i=1, 20 do
            Sleep(0.10486)
            if IsAddonVisible("MonsterNote") then
                break
            end
        end
        for i=1, 20 do
            Sleep(0.10492)
            if IsAddonVisible("MonsterNote") then
                break
            end
        end
        OpenHuntlog()
    end
end

function DeathHandler()
    if HasPlugin("YesAlready") then
        PauseYesAlready()
    end
    if GetCharacterCondition(2) then -- !! something fucky
        for i = 1, 200 do
            Sleep(0.10507)
            if IsAddonReady("SelectYesno") then
                yield("/callback SelectYesno true 0")
                Sleep(0.10510)
                break
            end
        end
        ZoneTransitions()
        Sleep(2.0515)
        repeat
            yield("/tpm " .. ZoneName)
            Sleep(interval_rate*3+0.10518)
        until IsPlayerCasting()
        ZoneTransitions()
        RotationStart()
        MountandMovetoFlag()
    end
    if HasPlugin("YesAlready") then
        RestoreYesAlready()
    end
end

function RotationStart()
    yield("/rotation manual")
    yield("/vbmai on")
    yield("/vbmai followtarget on")
    yield("/vbmai followoutofcombat on")
    yield("/vbmai followcombat on")
end

function DoDungeon()
    local duty = "Halatali"
    if not IsHuntLogComplete(9, 0) and rankToDo == 1 and route == "GC" then
        duty = "Halatali"
    elseif not IsHuntLogComplete(9, 1) and rankToDo == 2 and route == "GC" then
        if GetPlayerGC() == 3 then
            duty = "Cutter's Cry"
        else
            duty = "The Sunken Temple of Qarn"
        end
    elseif not IsHuntLogComplete(9, 2) and rankToDo == 3 and route == "GC" then
        duty = "The Wanderer's Palace"
    else
        yield("/echo No dungeon to do.")
        return
    end
    local solo = true
    if party_member ~= "" then
        solo = false
    end
    if IsAddonVisible("RetainerList") then
        yield('/callback RetainerList true -1')
    end
    Sleep(0.50560)
    if not solo then
        Teleporter(server, "li")
        Teleporter("ul", "tp")
        PartyInvite(party_member)
    end
    DoGCQuestRequirements()
    if GetCharacterCondition(34) then
        yield("/ad start")
    end
    while not GetCharacterCondition(34) and not GetCharacterCondition(56) and not GetCharacterCondition(45) and not GetCharacterCondition(51) do
        AutoDutyUnsyncRun(duty)
        Sleep(3.0572)
    end
    for i = 1, 5 do
        Sleep(3.0575)
    end
    if not solo then
        --yield("/p autofollow") --for autofollow, but it's not great
    end
    local mobs_done = false
    repeat --target mobs for the log as needed, and then dip if solo
        if duty == "Halatali" then
            if not mobs_done then
                if GetPlayerGC() == 1 then --Maelstrom
                    FindAndKillTarget("Heckler Imp", 20)
                    Sleep(interval_rate*5+0.0586)
                    FindAndKillTarget("Doctore", 20)
                    Sleep(interval_rate*5+0.0588)
                    if not GetCharacterCondition(26) then --checking the hunt log for mobs repeatedly in combat gave crashes
                        if not HuntLogCheck("Heckler Imp", 9, 0) and not HuntLogCheck("Doctore", 9, 0) then
                            mobs_done = true
                            yield("/echo Non-boss mobs done")
                        end
                    end
                elseif GetPlayerGC() == 2 then --Twin Adders
                    FindAndKillTarget("Heckler Imp", 20)
                    Sleep(interval_rate*5+0.0597)
                    FindAndKillTarget("Scythe Mantis", 20)
                    Sleep(interval_rate*5+0.0599)
                    FindAndKillTarget("Coliseum Python", 20)
                    Sleep(interval_rate*5+0.0601)
                    if not GetCharacterCondition(26) then --checking the hunt log for mobs repeatedly in combat gave crashes
                        if not HuntLogCheck("Heckler Imp", 9, 0) and not HuntLogCheck("Scythe Mantis", 9, 0) and not HuntLogCheck("Coliseum Python", 9, 0) then --!!need to check this
                            mobs_done = true
                            yield("/echo Non-boss mobs done")
                        end
                    end
                elseif GetPlayerGC() == 3 then --Immortal Flames
                    FindAndKillTarget("Doctore", 20)
                    Sleep(interval_rate*5+0.0610)
                    if not GetCharacterCondition(26) then --checking the hunt log for mobs repeatedly in combat gave crashes
                        if not HuntLogCheck("Doctore", 9, 0) then
                            mobs_done = true
                            yield("/echo Non-boss mobs done")
                        end
                    end
                end
            elseif IsHuntLogComplete(9, 0) and solo then
                repeat
                    Sleep(0.50620)
                until IsPlayerAvailable()
                yield("/leaveduty")
            end
        elseif duty == "The Sunken Temple of Qarn" then
            if not mobs_done then
                if GetPlayerGC() == 1 then
                    FindAndKillTarget("Temple Bat", 20)
                    Sleep(interval_rate*5+0.0628)
                    FindAndKillTarget("The Condemned", 20)
                    Sleep(interval_rate*5+0.0630)
                    if not GetCharacterCondition(26) then --checking the hunt log for mobs repeatedly in combat gave crashes
                        if not HuntLogCheck("Temple Bat", 9, 1) and not HuntLogCheck("The Condemned", 9, 1) then
                            mobs_done = true
                            yield("/echo Non-boss mobs done")
                        end
                    end
                elseif GetPlayerGC() == 2 then
                    FindAndKillTarget("Temple Bee", 20)
                    Sleep(interval_rate*5+0.0639)
                    if not GetCharacterCondition(26) then --checking the hunt log for mobs repeatedly in combat gave crashes
                        if not HuntLogCheck("Temple Bee", 9, 1) then
                            mobs_done = true
                            yield("/echo Non-boss mobs done")
                        end
                    end
                end
            elseif IsHuntLogComplete(9, 1) and solo then 
                repeat
                    Sleep(0.50649)
                until IsPlayerAvailable()
                yield("/leaveduty")
            end
        elseif duty == "Cutter's Cry" then
            if not mobs_done then
                FindAndKillTarget("Sand Bat", 20)
                Sleep(interval_rate*5+0.0656)
                FindAndKillTarget("Sabotender Desertor", 20)
                Sleep(interval_rate+0.0658)
                if not GetCharacterCondition(26) then --checking the hunt log for mobs repeatedly in combat gave crashes
                    if not HuntLogCheck("Sand Bat", 9, 1) and not HuntLogCheck("Sabotender Desertor", 9, 1) then
                        mobs_done = true
                        yield("/echo Non-boss mobs done")
                    end
                end
            elseif IsHuntLogComplete(9, 1) and solo then 
                repeat
                    Sleep(0.50667)
                until IsPlayerAvailable()
                yield("/leaveduty")
            end
        elseif duty == "The Wanderer's Palace" then
            if not mobs_done then
                if GetPlayerGC() == 1 then
                    FindAndKillTarget("Tonberry", 20)
                    Sleep(interval_rate*5+0.0675)
                    if not GetCharacterCondition(26) then --checking the hunt log
                        if not HuntLogCheck("Tonberry", 9, 2) then
                            mobs_done = true
                            yield("/echo Non-boss mobs done")
                        end
                    end
                elseif GetPlayerGC() == 2 then
                    FindAndKillTarget("Tonberry", 20)
                    Sleep(interval_rate*5+0.0684)
                    FindAndKillTarget("Bronze Beetle", 20)
                    Sleep(interval_rate*5+0.0686)
                    if not GetCharacterCondition(26) then --checking the hunt log
                        if not HuntLogCheck("Tonberry", 9, 2) and not HuntLogCheck("Bronze Beetle", 9, 2) then
                            mobs_done = true
                            yield("/echo Non-boss mobs done")
                        end
                    end
                elseif GetPlayerGC() == 3 then
                    FindAndKillTarget("Tonberry", 20)
                    Sleep(interval_rate*5+0.0695)
                    FindAndKillTarget("Corrupted Nymian", 20)
                    Sleep(interval_rate*5+0.0697)
                    FindAndKillTarget("Soldier of Nym", 20)
                    Sleep(interval_rate*5+0.0699)
                    if not GetCharacterCondition(26) then --checking the hunt log
                        if not HuntLogCheck("Tonberry", 9, 2) and not HuntLogCheck("Corrupted Nymian", 9, 2) and not HuntLogCheck("Soldier of Nym", 9, 2) then
                            mobs_done = true
                            yield("/echo Non-boss mobs done")
                        end
                    end
                end
            elseif IsHuntLogComplete(9, 2) and solo then 
                repeat
                    Sleep(0.50709)
                until IsPlayerAvailable()
                yield("/leaveduty")
            end        
        end
        Sleep(3.0714)
        LogInfo("[AutoHunt] Waiting for instance to finish...")
    until not GetCharacterCondition(34) and not GetCharacterCondition(56) and not GetCharacterCondition(45) and not GetCharacterCondition(51)
    if not solo then
        PartyDisband()
        Teleporter(" ", "li") --back to home world
        Teleporter("inn", "li")
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

yield("Doing the hunt log! Looking for next available mob.")
yield("/at e")

-- This function traverses through the JSON and saves the data we want into a more specific table called "CurrentLog"
ClassorGCID()
json.traverse(stringmonsters, my_callback)

-- Now we loop through the table and extract each mob, territory, location and kills needed in order to execute our hunt log doer

for i = 1, #CurrentLog do
    OpenHuntlog()
    loadupHuntlog()
    for j = 1, #CurrentLog[i].Monsters do -- this is the loop that goes through each mob in the hunt log
        mobName = CurrentLog[i].Monsters[j].Name
        if IncompleteTargets() == mobName then --check next mob based on hunt log
            KillsNeeded = CurrentLog[i].Monsters[j].Count
            mobZone = CurrentLog[i].Monsters[j].Locations[1].Terri
            mobX = CurrentLog[i].Monsters[j].Locations[1].xCoord
            mobY = CurrentLog[i].Monsters[j].Locations[1].yCoord
            mobZ = CurrentLog[i].Monsters[j].Locations[1].zCoord
            ZoneName = Territories[tostring(mobZone)]

            yield("/echo " .. mobName .. " in " .. ZoneName .. " is next! We need " .. KillsNeeded)

            RotationStart()

            if IsInZone(tonumber(mobZone)) then -- If you are in the same zone, no need to teleport
                -- Here we use a plugin called ChatCoordinates to make a flag and teleport to the zone if needed
                if mobZ then
                    SetMapFlag(mobZone, mobX, mobY, mobZ)
                    yield("/echo Using better coordinates.") -- the ones with height data
                else
                    yield("/coord " .. mobX .. " " .. mobY .. " :" .. ZoneName)
                    Sleep(interval_rate + 0.0775)
                end
            else
                if mobZ then
                    SetMapFlag(mobZone, mobX, mobY, mobZ)
                    Sleep(interval_rate*2 + 0.0780)
                    yield("/echo Using better coordinates.")
                    repeat
                        yield("/tpm " .. ZoneName)
                        Sleep(interval_rate*3+0.0784)
                        DeathHandler()
                    until IsPlayerCasting()
                    ZoneTransitions()
                else
                    while not IsInZone(tonumber(mobZone)) do -- addresses getting attacked during tp
                        yield("/ctp " .. mobX .. " " .. mobY .. " :" .. ZoneName)
                        repeat
                            Sleep(interval_rate+0.0792)
                            DeathHandler()
                        until IsPlayerAvailable() and not IsPlayerCasting()
                        while GetCharacterCondition(26) do
                            yield("/battletarget") -- if other mobs are attacking you
                            Sleep(0.10797)
                            TargetMoveFly()
                            if PathIsRunning() or PathfindInProgress() then
                                yield("/echo Attacking " .. mobName .. " moving closer.")
                                if GetDistanceToTarget() > 15 then
                                    unstucktarget()
                                elseif GetDistanceToTarget() > 3.9 then
                                    Sleep(1.0804)
                                end
                            end
                        end
                        DeathHandler()
                    end
                end
            end
            -- Now convert those simple map coordinates to RAW coordinates that vnav uses

            if mobZ then
                rawX = mobX
                rawY = mobY
                rawZ = mobZ
            else
                rawX = GetFlagXCoord()
                rawY = 1024
                rawZ = GetFlagYCoord()
            end

            if GetZoneID() == 139 and GetPlayerRawXPos() > -306 then -- avoid swimming in Upper La Noscea
                if mobName == "Kobold Footman" or mobName == "Kobold Pickman" then -- these two mobs are on the west side of Upper La Noscea
                    Movement(283.750, 46.000, -212.500)
                    Movement(-334.194, 51.997, -64.813)
                end
            end

            -- you're in the zone now, moving to flag

            MountandMovetoFlag()

            -- Wait until you stop moving and when you reach your destination, dismount

            while IsMoving() or PathIsRunning() or PathfindInProgress() do
                yield("/echo Moving to next area...")
                Sleep(1.0839)
            end

            if not IsMoving() then
                Sleep(0.10843)
                Dismount()
            end

            OpenHuntlog()
            loadupHuntlog()
            killtimeout_start = os.clock()
            while IncompleteTargets() == mobName do
                LogInfo("[AutoHunt]Killing " .. mobName .. "s in progress...")
                OpenHuntlog()
                loadupHuntlog()
                if not GetCharacterCondition(26) then
                    DeathHandler()
                    yield("/target \"" .. mobName .. "\"")
                    Sleep(0.10857)
                    TargetMoveFly()
                    Sleep(0.20859)
                    if PathIsRunning() or PathfindInProgress() then
                        yield("/echo Found " .. mobName .. " moving closer.")
                        if GetDistanceToTarget() > 15 then
                            unstucktarget()
                        elseif GetDistanceToTarget() > 3.9 then
                            Sleep(1.0865)
                        end
                    end
                    if IsInFate() and not IsLevelSynced() then
                        yield("/lsync")
                    end
                    Sleep(0.10871)                
                    Dismount()
                    yield('/action "Auto-attack"')
                    Sleep(0.10874)
                else
                    yield("/echo In combat against " .. GetTargetName())
                    Sleep(0.10877)
                    if IsInFate() and not IsLevelSynced() then
                        yield("/lsync")
                    end
                    yield('/action "Auto-attack"')
                    if not HasTarget() then
                        yield("/battletarget") -- if other mobs are attacking you
                        Sleep(0.10884)
                        TargetMoveFly()
                        if GetDistanceToTarget() > 15 then
                            unstucktarget()
                        elseif GetDistanceToTarget() > 3.9 then
                            Sleep(1.0889)
                        end
                    end
                end
                yield("/vnav stop")
                hlogRefresh()
                Sleep(3.0895)
            end
        end
    end
end
yield("/echo Finished overworld hunt log for Rank " .. rankToDo .. "!")
LogInfo("[AutoHunt]Finished overworld hunt log for Rank " .. rankToDo .. "!")

if do_dungeons then
    DoDungeon()
    Sleep(1.0905)
    yield("/echo Finished dungeon hunt log for Rank " .. rankToDo .. "!")
end

if (GetZoneID() ~= 177 and GetZoneID() ~= 178 and GetZoneID() ~= 179) then
    Teleporter("inn", "li")
end
