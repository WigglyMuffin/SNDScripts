--##########################################
--   CONFIGS
--##########################################

-- Only set one of these
-- Should really change to a DO_JOB_QUESTS = "Arcanist" or something
--DO_JOB_QUESTS = "Arcanist"
DO_ARCANIST_QUESTS = 0
DO_ARCHER_QUESTS = 0

DO_DOL_QUESTS = 0

DO_MAELSTROM_LOG_1 = 1
DO_MAELSTROM_LOG_2 = 0

-- Quest unlocks
DO_HALATALI = 0
DO_THE_SUNKEN_TEMPLE_OF_QARN = 0
DO_DZEMAEL_DARKHOLD = 0
DO_THE_AURUM_VALE = 0

-- Level until n
DO_LEVEL = 47

--##########################################
--   DON'T TOUCH ANYTHING BELOW HERE 
--   UNLESS YOU KNOW WHAT YOU'RE DOING
--##########################################

-- Enemy names for Arcanist quests
local ArcanistEnemies = {
    "Wharf Rat",           -- arcanist_01 quest 1
    "Aurelia",             -- arcanist_02 quest 1
    "Little Ladybug",      -- arcanist_03 quest 1
    "Wild Dodo",           -- arcanist_04 quest 2
    "Tiny Mandragora",     -- arcanist_05 quest 2
    "Roseling",            -- arcanist_06 quest 3
    "Wild Jackal"          -- arcanist_07 quest 3
}

-- Enemy names for Archer quests
local ArcherEnemies = {
    "Ground Squirrel",     -- archer_01 quest 1
    "Little Ladybug",      -- archer_02 quest 1
    "Forest Funguar",      -- archer_03 quest 1
    "Opo-opo",             -- archer_04 quest 2
    "Microchu",            -- archer_05 quest 2
    "Tree Slug",           -- archer_06 quest 3
    "Northern Vulture"     -- archer_07 quest 3
}

-- Enemy names for Maelstrom hunting log 1 (02-04 are inside "Halatali")
local MaelstromEnemiesLog1 = {
    "Amalj'aa Hunter",     -- maelstrom_01 "MonsterNote", 2, 18, 3
    "Heckler Imp",         -- maelstrom_02 "MonsterNote", 2, 19, 3
    "Doctore",             -- maelstrom_03 "MonsterNote", 2, 20, 3
    "Firemane",            -- maelstrom_04 "MonsterNote", 2, 21, 3
    "Sylvan Groan",        -- maelstrom_05 "MonsterNote", 2, 22, 3
    "Sylvan Sough",        -- maelstrom_06 "MonsterNote", 2, 23, 3
    "Kobold Pickman",      -- maelstrom_07 "MonsterNote", 2, 24, 3
    "Amalj'aa Bruiser",    -- maelstrom_08 "MonsterNote", 2, 25, 3
    "Ixali Straightbreak", -- maelstrom_09 "MonsterNote", 2, 26, 3
    "Ixali Wildtalon"      -- maelstrom_10 "MonsterNote", 2, 27, 3
}

-- Enemy names for Maelstrom hunting log 2 (13-15 are inside "The Sunken Temple of Qarn")
local MaelstromEnemiesLog2 = {
    "Amalj'aa Divinator",  -- maelstrom_11 "MonsterNote", 2, 18, 3
    "Kobold Pitman",       -- maelstrom_12 "MonsterNote", 2, 19, 3
    "Temple Bat",          -- maelstrom_13 "MonsterNote", 2, 20, 3
    "The Condemned",       -- maelstrom_14 "MonsterNote", 2, 21, 3
    "Teratotaur",          -- maelstrom_15 "MonsterNote", 2, 22, 3
    "Kobold Bedesman",     -- maelstrom_16 "MonsterNote", 2, 23, 3
    "Kobold Priest",       -- maelstrom_17 "MonsterNote", 2, 24, 3
    "Sylvan Sigh",         -- maelstrom_18 "MonsterNote", 2, 25, 3
    "Shelfscale Sahagin",  -- maelstrom_19 "MonsterNote", 2, 26, 3
    "Amalj'aa Pugilist"    -- maelstrom_20 "MonsterNote", 2, 27, 3
}

local QuestIDs = {
    66233,                 -- Hallo Halatali "Halatali"
    66300,                 -- Braving New Depths "The Sunken Temple of Qarn"
    66664,                 -- Shadows Uncast (Maelstrom) "Dzemael Darkhold"
    66667                  -- Gilding the Bilious (Maelstrom) "The Aurum Vale"
}

-- usage: VNavChecker()
function VNavChecker() --Movement checker, does nothing if moving
    yield("/wait 1.0")
    repeat
        yield("/wait 0.1")
    until not PathIsRunning() and IsPlayerAvailable()
end

-- usage: ZoneTransitions()
function ZoneTransitions() --Zone transition checker, does nothing if changing zones
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
function QuestNPC(DialogueType, DialogueConfirm, DialogueOption) -- NPC interaction handler. DialogueOption optional.
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
function QuestNPCSingle(DialogueType, DialogueConfirm, DialogueOption) -- NPC interaction handler, only supports one dialogue option for now. DialogueOption optional.
    while not GetCharacterCondition(32) do
        yield("/pint")
        yield("/wait 0.5")
    end
    if DialogueConfirm then
        yield("/wait 0.5")
        if DialogueOption == nil then
            yield("/pcall " .. DialogueType .. " true 0")
            yield("/wait 0.5")
        else
            yield("/pcall " .. DialogueType .. " true " .. DialogueOption)
            yield("/wait 0.5")
        end
    end
end

-- ALWAYS takes target = X
-- ALWAYS takes enemy_max_dist = X
-- not explicitly used
function QuestCombat(target1)
    local all_targets = {target1}
    local combined_list = {}
    local best_target = 0
    local lowest_distance = 0
    for _, current_target in ipairs(all_targets) do
        local current_list = {}
        for i = 0, 20 do
            yield("/echo <list." .. i .. ">")
            yield("/target " .. current_target .. " <list." .. i .. ">")
            yield("/wait 0.1")
            local current_target_name = GetTargetName()
            if (current_target_name == target1) and GetTargetHP() > 0 and GetDistanceToTarget() <= enemy_max_dist then
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
                VNavChecker()
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
function QuestInstance() -- Targetting/Movement Logic for Solo Duties
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

function GetNodeTextLookupUpdate(GetNodeTextMatchLocation)
    return GetNodeText("_ToDoList", GetNodeTextMatchLocation)
end

-- usage: QuestChecker(ArcanistEnemies[3], 25, "_ToDoList", "Slay little ladybugs.")

function QuestChecker(target_name, target_distance, GetNodeTextType, GetNodeTextMatch) -- Quest and UI element handler
    local target = target_name
    local enemy_max_dist = target_distance
    local GetNodeTextMatchLocation = tostring.(NodeScanner(GetNodeTextType, GetNodeTextMatch))
    while true do
        UiCheck(GetNodeTextType)
        if GetNodeTextLookupUpdate(GetNodeTextMatchLocation) == GetNodeTextMatch then
            UiCheck(GetNodeTextType, true)
            break
        end
        QuestCombat(target_name)
    end
    -- checks if player in combat before ending rotation solver
    if not GetCharacterCondition(26) then
        yield("/rotation off")
    end
end
-- QuestChecker(ArcanistEnemies[7], 40, "_ToDoList", "Report to Thubyrgeim at the Arcanists' Guild.")

function NodeScanner(GetNodeTextType, GetNodeTextMatch)
    NodeTypeCount = tonumber(GetNodeListCount(GetNodeTextType))
    for location = 0, NodeTypeCount do
        for subNode = 0, 60 do
            yield("/wait 0.0001")
            local nodeCheck = GetNodeText(GetNodeTextType, location, subNode)
            if nodeCheck == GetNodeTextMatch then
                return location, subNode
            end
        end
    end
    -- deeper scan
    for location = 0, NodeTypeCount do
        for subNode = 0, 60 do
            for subNode2 = 0, 20 do
                yield("/wait 0.0001")
                local nodeCheck = GetNodeText(GetNodeTextType, location, subNode, subNode2)
                if nodeCheck == GetNodeTextMatch then
                    return location, subNode, subNode2
                end
            end
        end
    end
    yield("/echo Can't find the node text")
    return
end

function UiCheck(GetNodeTextType, CloseUI)
    -- hunting log checks
    if GetNodeTextType == "MonsterNote" then
        if CloseUI() then
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

-- usage: Teleporter("Limsa", "tp")
-- add support for item tp
function Teleporter(Location, TP_Kind) -- Teleporter handler
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
    yield("/" .. TP_Kind .. " " .. Location)
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable()
end

-- usage: Mount("SDS Fenrir") can leave empty for mount roulette
function Mount(MountName)
    -- return if player already mounted
    if GetCharacterCondition(4) then
        return
    end
    -- wait until the player is available, not casting, and not in combat
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
    -- if MountName is empty then use mount roulette instead
    if MountName == nil then
        repeat
            yield('/ac "Mount Roulette"')
            yield("/wait 0.1")
        until GetCharacterCondition(27)
    else
        repeat
            yield('/mount "' .. MountName .. '"')
            yield("/wait 0.1")
        until GetCharacterCondition(27) 
    end
    -- wait until player available and is mounted
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
function Movement(X_Position, Y_Position, Z_Position)
    NavReload()
    repeat
        yield("/wait 0.1")
    until NavIsReady()
    repeat
        yield("/wait 0.1")
        yield("/vnav moveto " .. X_Position .. Y_Position .. Z_Position)
    until PathIsRunning()
end

-- usage: Interact()
function Interact()
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
    yield("/pint")
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable()
end

--##############
--   ARCANIST
--##############

-- limsa arcanists' first quest level 1 "Way of the Arcanist"
function Arcanist1()
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Arcanist", "li")
    ZoneTransitions()
    Movement(-327.86, 12.89, 9.79)
    VNavChecker()
    yield("/target Thubyrgeim")
    -- yield("/pinteract")
    -- yield("/waitaddon SelectYesno <maxwait.15><wait.9.5>")
    -- yield("/pcall SelectYesno true 0")
    QuestNPC("SelectYesno", true, 0)
    Movement(-335.29, 11.99, 54.45)
    VNavChecker()
    Teleporter("Tempest", "li")
    ZoneTransitions()
    Movement(14.71, 64.52, 87.16)
    VNavChecker()
    QuestChecker(ArcanistEnemies[1], 25, "_ToDoList", 13, 3, x, x, x, "Slay wharf rats.")
    QuestChecker(ArcanistEnemies[3], 25, "_ToDoList", 15, 3, x, x, x, "Slay little ladybugs.")
    Movement(232.67, 40.64, 57.39)
    VNavChecker()
    QuestChecker(ArcanistEnemies[2], 25, "_ToDoList", 13, 3, x, x, x, "Report to Thubyrgeim at the Arcanists' Guild.")
    --yield("/wait 1.6")
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Arcanist", "li")
    ZoneTransitions()
    Movement(-327.86, 12.89, 9.79)
    VNavChecker()
    yield("/target Thubyrgeim")
    QuestNPC()
end

-- limsa arcanists' second quest level 5 "What's in the Box"
function Arcanist2()
    Movement(-327.86, 12.89, 9.79)
    VNavChecker()
    yield("/target Thubyrgeim")
    QuestNPC()
    Movement(-335.29, 11.99, 54.45)
    VNavChecker()
    Teleporter("Zephyr", "li")
    ZoneTransitions()
    Movement(219.94, 66.81, 287.77)
    VNavChecker()
    ZoneTransitions()
    Movement(381.76, 71.93, -256.04)
    VNavChecker()
    QuestChecker(ArcanistEnemies[4], 25, "_ToDoList", 13, 3, x, x, x, "Slay wild dodos.")
    Movement(418.06, 65.90, -160.37)
    VNavChecker()
    QuestChecker(ArcanistEnemies[5], 25, "_ToDoList", 13, 3, x, x, x, "Report to Thubyrgeim at the Arcanists' Guild.")
    --yield("/wait 1.6")
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Arcanist", "li")
    ZoneTransitions()
    Movement(-327.86, 12.89, 9.79)
    VNavChecker()
    yield("/target Thubyrgeim")
    QuestNPC()
    Movement(-335.29, 11.99, 54.45)
    VNavChecker()
    Teleporter("Zephyr", "li")
    ZoneTransitions()
    Movement(-0.007, 24.5, 194.68)
    VNavChecker()
    yield("/target Practice Crates")
    QuestNPC()
    yield("/rotation auto")
    repeat 
        yield("/wait 0.1")
    until GetCharacterCondition(26)
    repeat 
        yield("/wait 0.1")
    until not GetCharacterCondition(26)
    yield("/rotation off")
    Movement(-0.007, 24.5, 194.68)
    VNavChecker()
    yield("/wait 1.6")
    -- probably should make this a function for future stuff...
    while true do
        if DoesObjectExist("Practice Crate") then
            yield("/target Practice Crate")
            break
        else
            yield("/wait 0.1")
        end
    end
    -- yield("/pint")
    -- yield("/waitaddon CutSceneSelectString <maxwait.30><wait.6>")
    -- yield("/pcall CutSceneSelectString True 0")
    QuestNPC("CutSceneSelectString", true, 0)
    repeat
        yield("/wait 0.1")
    until not GetCharacterCondition(35)
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable()
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Arcanist", "li")
    ZoneTransitions()
    Movement(-327.86, 12.89, 9.79)
    VNavChecker()
    yield("/target Thubyrgeim")
    QuestNPC()
end

-- limsa arcanists' third quest level 10 "Tactical Planning"
function Arcanist3()
    Movement(-327.86, 12.89, 9.79)
    VNavChecker()
    yield("/target Thubyrgeim")
    QuestNPC()
    Teleporter("Swiftperch", "tp")
    ZoneTransitions()
    Movement(674.92, 19.37, 436.02)
    VNavChecker()
    QuestChecker(ArcanistEnemies[6], 25, "_ToDoList", 13, 3, x, x, x, "Slay roselings.")
    --yield("/wait 1.6")
    Teleporter("Moraby", "tp")
    ZoneTransitions()
    Movement(30.84, 46.18, 831.01)
    VNavChecker()
    QuestChecker(ArcanistEnemies[7], 40, "_ToDoList", 13, 3, x, x, x, "Report to Thubyrgeim at the Arcanists' Guild.")
    --yield("/wait 1.6")
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Arcanist", "li")
    ZoneTransitions()
    Movement(-327.86, 12.89, 9.79)
    VNavChecker()
    yield("/target Thubyrgeim")
    QuestNPC()
    Movement(-347.72, -2.37, 12.88)
    VNavChecker()
    yield("/target K'lyhia")
    yield("/lockon")
    QuestNPC()
    Teleporter("Summerford", "tp")
    ZoneTransitions()
    Movement(-103.76, 46.15, -253.17)
    VNavChecker()
    yield("/target K'lyhia")
    yield("/pinteract")
    yield("/waitaddon SelectYesno <maxwait.10><wait.0.5>")
    yield("/pcall SelectYesno true 0")
    ZoneTransitions()
    yield("/rotation auto")
    QuestInstance()
    ZoneTransitions()
    yield("/wait 1.6")
    yield("/rotation off")
    yield("/target K'lyhia")
    yield("/lockon")
    QuestNPC()
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Arcanist", "li")
    ZoneTransitions()
    Movement(-327.86, 12.89, 9.79)
    VNavChecker()
    yield("/target Thubyrgeim")
    QuestNPC()
end

--##############
--   ARCHER
--##############

-- gridania arcanists' first quest level 1 "Way of the Archer"
function Archer1()

end

-- gridania arcanists' second quest level 5 "A Matter of Perspective"
function Archer2()

end

-- gridania arcanists' third quest level 10 "Training with Leih"
function Archer3()

end

--##############
-- JOB UNLOCKS
--##############

function FisherUnlock()
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Fisher", "li")
    ZoneTransitions()
    Movement(-167.30, 4.55, 152.46)
    VNavChecker()
    yield("/target N'nmulika")
    yield("/pint")
    yield("/waitaddon SelectYesno <maxwait.15><wait.0.5>")
    yield("/pcall SelectYesno true 0")
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable()
    yield("/wait 1.6")
    yield("/target N'nmulika")
    QuestNPC()
    Movement(-173.59, 4.2, 162.77)
    VNavChecker()
    Movement(-165.74, 4.55, 165.38)
    VNavChecker()
    yield("/target Sisipu")
    yield("/pint")
    yield("/waitaddon SelectYesno <maxwait.15><wait.0.5>")
    yield("/pcall SelectYesno true 0")
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable()
end

function MinerUnlock()
    Teleporter("Ul'dah", "tp")
    ZoneTransitions()
    Teleporter("Miner", "li")
    ZoneTransitions()
    Movement(1.54, 7.6, 153.55)
    VNavChecker()
    yield("/target Linette")
    yield("/pint")
    yield("/waitaddon SelectYesno <maxwait.15><wait.0.5>")
    yield("/pcall SelectYesno true 0")
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable()
    yield("/wait 1.6")
    yield("/target Linette")
    QuestNPC()
    Movement(-17.33, 6.2, 157.59)
    VNavChecker()
    yield("/target Adalberta")
    yield("/pint")
    yield("/waitaddon SelectYesno <maxwait.15><wait.0.5>")
    yield("/pcall SelectYesno true 0")
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable()
end

function BotanistUnlock()
    Teleporter("Gridania", "tp")
    ZoneTransitions()
    Teleporter("Botanist", "li")
    ZoneTransitions()
    Movement(-238.64, 8, -144.90)
    VNavChecker()
    yield("/target Leonceault")
    yield("/pint")
    yield("/waitaddon SelectYesno <maxwait.15><wait.0.5>")
    yield("/pcall SelectYesno true 0")
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable()
    yield("/wait 1.6")
    yield("/target Leonceault")
    QuestNPC()
    Movement(-234.09, 6.23, -170.02)
    VNavChecker()
    yield("/target Fufucha")
    yield("/pint")
    yield("/waitaddon SelectYesno <maxwait.15><wait.0.5>")
    yield("/pcall SelectYesno true 0")
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable()
end

--##############
-- HUNT UNLOCKS
--##############

function MaelstromRank1() --needs nodescanner adding and the matching text adjusting
    -- Amalj'aa Hunter
    Teleporter("Camp Drybone", "tp")
    ZoneTransitions()
    Movement(-112.60, -27.88, 343.99)
    VNavChecker()
    -- QuestChecker(MaelstromEnemiesLog1[1], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    Movement(-122.43, -30.10, 297.20)
    VNavChecker()
    -- QuestChecker(MaelstromEnemiesLog1[1], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    Movement(-122.43, -30.10, 297.20)
    VNavChecker()
    -- QuestChecker(MaelstromEnemiesLog1[1], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    -- Amalj'aa Bruiser
    Movement(-169.97, -46.71, 493.46)
    VNavChecker()
    ZoneTransitions()
    Movement(-157.06, 26.13, -410.14)
    VNavChecker()
    yield("/target Aetheryte")
    Interact()
    Movement(-32.69, 15.53, -277.9)
    VNavChecker()
    -- QuestChecker(MaelstromEnemiesLog1[8], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    Movement(-9.38, 15.62, -291.08)
    VNavChecker()
    -- QuestChecker(MaelstromEnemiesLog1[8], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    -- QuestChecker(MaelstromEnemiesLog1[8], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    -- Sylvan Groan + Sylvan Sough
    Teleporter("Bentbranch Meadows", "tp")
    ZoneTransitions()
    Movement(389.27, -3.36, -186.45)
    VNavChecker()
    ZoneTransitions()
    Movement(-189.88, 4.43, 294.46)
    VNavChecker()
    yield("/target Aetheryte")
    Interact()
    Movement(-135.26, 15.12, -1.46)
    VNavChecker()
    -- QuestChecker(MaelstromEnemiesLog1[5], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    -- QuestChecker(MaelstromEnemiesLog1[6], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    Movement(-104.98, 18.52, 14.46)
    VNavChecker()
    -- QuestChecker(MaelstromEnemiesLog1[5], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    -- QuestChecker(MaelstromEnemiesLog1[6], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    Movement(-71.64, 17.58, 7.27)
    VNavChecker()
    -- QuestChecker(MaelstromEnemiesLog1[5], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    -- QuestChecker(MaelstromEnemiesLog1[6], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    -- Kobold Pickman
    Teleporter("Aleport", "tp")
    ZoneTransitions()
    Movement(417.30, 35.15, -17.66)
    VNavChecker()
    ZoneTransitions()
    Movement(-477.30, 26.29, 61.12)
    VNavChecker()
    -- QuestChecker(MaelstromEnemiesLog1[7], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    -- QuestChecker(MaelstromEnemiesLog1[7], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    Movement(-432.12, 38.29, 19.78)
    VNavChecker()
    -- QuestChecker(MaelstromEnemiesLog1[7], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    -- Ixali Straightbeak
    Teleporter("New Gridania", "tp")
    ZoneTransitions()
    yield("/target Aetheryte")
    Interact()
    QuestNPCSingle("SelectString", true, "0")
    yield("/pcall TelepotTown true 11 4u <wait.1>")
    yield("/pcall TelepotTown true 11 4u")
    ZoneTransitions()
    Movement(-231, 15.75, -89.25)
    VNavChecker()
    ZoneTransitions()
    Movement(53.52, -37.91, 312.72)
    VNavChecker()
    -- QuestChecker(MaelstromEnemiesLog1[9], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    Movement(75.32, -38.07, 331.25)
    VNavChecker()
    -- QuestChecker(MaelstromEnemiesLog1[9], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    Movement(75.83, -41.24, 352.80)
    VNavChecker()
    -- QuestChecker(MaelstromEnemiesLog1[9], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    -- Ixali Wildtalon
    Movement(-36.96, -39.16, 232.40)
    VNavChecker()
    yield("/target Aetheryte")
    Interact()
    Movement(-405, 9.5, 128)
    VNavChecker()
    ZoneTransitions()
    Movement(468.13, 232.79, 321.85)
    -- QuestChecker(MaelstromEnemiesLog1[10], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    VNavChecker()
    Movement(224.32, 301.51, -142.16)
    VNavChecker()
    Movement(229.20, 312.91, -235.02)
    VNavChecker()
    yield("/target Aetheryte")
    Interact()
    Teleport("Limsa", "tp")
end

function MaelstromRank2()
    
end

--#################
-- DUNGEON UNLOCKS
--#################

-- can also probably use questionable once commands or ipc work better
-- needs updating once nodescanner works
function HalataliUnlock()
    Teleporter("Horizon", "tp") -- could also use vesper bay ticket but needs the teleporter function adjusting
    ZoneTransitions()
    Movement(-471.37, 23.01, -355.12)
    VNavChecker()
    yield("/target Nedrick Ironheart")
    QuestNPC()
    -- once accepted quest
    Teleporter("Camp Drybone", "tp")
    ZoneTransitions()
    Movement(-330.92, -22.48, 434.14)
    VNavChecker()
    yield("/target Fafajoni")
    QuestNPC()
end

function TheSunkenTempleOfQarnUnlock()
    
end

function DzemaelDarkholdUnlock()
    
end

function TheAurumValeUnlock()
    
end

--##########################################
--  MAIN SCRIPT
--##########################################
function main()
    yield("/at e")
    yield("/p")
    yield("/vbm cfg AI Enabled true")
    yield("/vbmai on")
    if DO_ARCANIST_QUESTS == 1 then
        Arcanist1()
        Arcanist2()
        Arcanist3()
    elseif DO_ARCHER_QUESTS == 1 then
        Archer1()
        Archer2()
        Archer3()
    end
    
-- DoL
    if DO_DOL_QUESTS == 1 then
        FisherUnlock()
        MinerUnlock()
        BotanistUnlock()
    end
    
-- Hunt Logs
    if MaelstromEnemiesLog1 == 1 then
        MaelstromRank1()
    end
    
    if MaelstromEnemiesLog2 == 1 then
        MaelstromRank2()
    end
    
-- Quests
    if DO_HALATALI == 1 then
        HalataliUnlock()
    end
    
    if DO_THE_SUNKEN_TEMPLE_OF_QARN == 1 then
        TheSunkenTempleOfQarnUnlock()
    end
    
    if DO_DZEMAEL_DARKHOLD == 1 then
        DzemaelDarkholdUnlock()
    end
    
    if DO_THE_AURUM_VALE == 1 then
        TheAurumValeUnlock()
    end
    
-- GC tp
    Teleporter("gc", "li")
end

main()
