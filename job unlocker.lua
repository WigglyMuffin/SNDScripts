--##########################################
--   CONFIGS
--##########################################

-- Only set one of these
-- Should really change to a DO_TYPE_QUESTS = "Arcanist" or something
DO_ARCANIST_QUESTS = 1
DO_ARCHER_QUESTS = 0

DO_DOL_QUESTS = 1

DO_MAELSTROM_LOG_1 = 0
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

-- i hate this functions existence
function GetNodeTextLookupUpdate(number1, number2, number3, number4, number5)
    if (number3 == nil or number3 == "x") then
        return GetNodeText("_ToDoList", number1, number2)
    elseif (number4 == nil or number4 == "x") then
        return GetNodeText("_ToDoList", number1, number2, number3)
    elseif (number5 == nil or number5 == "x") then
        return GetNodeText("_ToDoList", number1, number2, number3, number4)
    end
    return GetNodeText("_ToDoList", number1, number2, number3, number4, number5)
end

-- usage: QuestChecker(ArcanistEnemies[1], 50, "_ToDoList"|"MonsterNote", 15, 3, x, x, x, "Report to Thubyrgeim at the Arcanists' Guild.")
-- use x as replacement for number if shorter


-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- GetNodeTextType needs adding to GetNodeTextLookupUpdate() and QuestChecker() and UIChecker()
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


function QuestChecker(target_name, target_distance, GetNodeTextType, GNT1, GNT2, GNT3, GNT4, GNT5, GetNodeTextMatch) -- Quest and UI element handler
    local target = target_name
    local enemy_max_dist = target_distance
    while true do
        SpecialChecks(GetNodeTextType)
        if GetNodeTextLookupUpdate(GetNodeTextType,GNT1,GNT2,GNT3,GNT4,GNT5) == GetNodeTextMatch then
            SpecialChecks(GetNodeTextType, true)
            break
        end
        QuestCombat(target_name)
    end
    -- checks if player in combat before ending rotation solver
    if not GetCharacterCondition(26) then
        yield("/rotation off")
    end
end

function SpecialChecks(GetNodeTextType, CloseUI)
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

--##############
--   ARCANIST
--##############

-- limsa arcanists' first quest level 1 "Way of the Arcanist"
function ACN_1()
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Arcanist", "li")
    ZoneTransitions()
    yield("/vnav moveto -327.86 12.89 9.79")
    VNavChecker()
    yield("/target Thubyrgeim")
    -- yield("/pinteract")
    -- yield("/waitaddon SelectYesno <maxwait.15><wait.9.5>")
    -- yield("/pcall SelectYesno true 0")
    QuestNPC("SelectYesno", true, 0)
    yield("/vnav moveto -335.29 11.99 54.45")
    VNavChecker()
    Teleporter("Tempest", "li")
    ZoneTransitions()
    yield("/vnav moveto 14.71 64.52 87.16")
    VNavChecker()
    QuestChecker(ArcanistEnemies[1], 25, "_ToDoList", 13, 3, x, x, x, "Slay wharf rats.")
    QuestChecker(ArcanistEnemies[3], 25, "_ToDoList", 15, 3, x, x, x, "Slay little ladybugs.")
    yield("/vnav moveto 232.67 40.64 57.39")
    VNavChecker()
    QuestChecker(ArcanistEnemies[2], 25, "_ToDoList", 13, 3, x, x, x, "Report to Thubyrgeim at the Arcanists' Guild.")
    --yield("/wait 1.6")
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Arcanist", "li")
    ZoneTransitions()
    yield("/vnav moveto -327.86 12.89 9.79 ")
    VNavChecker()
    yield("/target Thubyrgeim")
    QuestNPC()
end

-- limsa arcanists' second quest level 5 "What's in the Box"
function ACN_2()
    yield("/vnav moveto -327.86 12.89 9.79")
    VNavChecker()
    yield("/target Thubyrgeim")
    QuestNPC()
    yield("/vnav moveto -335.29 11.99 54.45")
    VNavChecker()
    Teleporter("Zephyr", "li")
    ZoneTransitions()
    yield("/vnav moveto 219.94 66.81 287.77")
    VNavChecker()
    ZoneTransitions()
    yield("/vnav moveto 381.76 71.93 -256.04")
    VNavChecker()
    QuestChecker(ArcanistEnemies[4], 25, "_ToDoList", 13, 3, x, x, x, "Slay wild dodos.")
    yield("/vnav moveto 418.06 65.90 -160.37")
    VNavChecker()
    QuestChecker(ArcanistEnemies[5], 25, "_ToDoList", 13, 3, x, x, x, "Report to Thubyrgeim at the Arcanists' Guild.")
    --yield("/wait 1.6")
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Arcanist", "li")
    ZoneTransitions()
    yield("/vnav moveto -327.86 12.89 9.79")
    VNavChecker()
    yield("/target Thubyrgeim")
    QuestNPC()
    yield("/vnav moveto -335.29 11.99 54.45")
    VNavChecker()
    Teleporter("Zephyr", "li")
    ZoneTransitions()
    yield("/vnav moveto -0.007 24.5 194.68")
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
    yield("/vnav moveto -0.007 24.5 194.68")
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
    yield("/vnav moveto -327.86 12.89 9.79")
    VNavChecker()
    yield("/target Thubyrgeim")
    QuestNPC()
end

-- limsa arcanists' third quest level 10 "Tactical Planning"
function ACN_3()
    yield("/vnav moveto -327.86 12.89 9.79")
    VNavChecker()
    yield("/target Thubyrgeim")
    QuestNPC()
    Teleporter("Swiftperch", "tp")
    ZoneTransitions()
    yield("/vnav moveto 674.92 19.37 436.02")
    VNavChecker()
    QuestChecker(ArcanistEnemies[6], 25, "_ToDoList", 13, 3, x, x, x, "Slay roselings.")
    --yield("/wait 1.6")
    Teleporter("Moraby", "tp")
    ZoneTransitions()
    yield("/vnav moveto 30.84 46.18 831.01")
    VNavChecker()
    QuestChecker(ArcanistEnemies[7], 40, "_ToDoList", 13, 3, x, x, x, "Report to Thubyrgeim at the Arcanists' Guild.")
    --yield("/wait 1.6")
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Arcanist", "li")
    ZoneTransitions()
    yield("/vnav moveto -327.86 12.89 9.79")
    VNavChecker()
    yield("/target Thubyrgeim")
    QuestNPC()
    yield("/vnav moveto -347.72 -2.37 12.88")
    VNavChecker()
    yield("/target K'lyhia")
    yield("/lockon")
    QuestNPC()
    Teleporter("Summerford", "tp")
    ZoneTransitions()
    yield("/vnav moveto -103.76 46.15 -253.17")
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
    yield("/vnav moveto -327.86 12.89 9.79")
    VNavChecker()
    yield("/target Thubyrgeim")
    QuestNPC()
end

--##############
--   ARCHER
--##############

-- gridania arcanists' first quest level 1 "Way of the Archer"
function ARC_1()

end

-- gridania arcanists' second quest level 5 "A Matter of Perspective"
function ARC_2()

end

-- gridania arcanists' third quest level 10 "Training with Leih"
function ARC_3()

end

--##############
-- JOB UNLOCKS
--##############

function FSH_UNLOCK()
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Fisher", "li")
    ZoneTransitions()
    yield("/vnav moveto -167.30 4.55 152.46")
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
    yield("/vnav moveto -173.59 4.2 162.77")
    VNavChecker()
    yield("/vnav moveto -165.74 4.55 165.38")
    VNavChecker()
    yield("/target Sisipu")
    yield("/pint")
    yield("/waitaddon SelectYesno <maxwait.15><wait.0.5>")
    yield("/pcall SelectYesno true 0")
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable()
end

function MIN_UNLOCK()
    Teleporter("Ul'dah", "tp")
    ZoneTransitions()
    Teleporter("Miner", "li")
    ZoneTransitions()
    yield("/vnav moveto 1.54 7.6 153.55")
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
    yield("/vnav moveto -17.33 6.2 157.59")
    VNavChecker()
    yield("/target Adalberta")
    yield("/pint")
    yield("/waitaddon SelectYesno <maxwait.15><wait.0.5>")
    yield("/pcall SelectYesno true 0")
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable()
end

function BTN_UNLOCK()
    Teleporter("Gridania", "tp")
    ZoneTransitions()
    Teleporter("Botanist", "li")
    ZoneTransitions()
    yield("/vnav moveto -238.64 8 -144.90")
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
    yield("/vnav moveto -234.09 6.23 -170.02")
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

function Maelstrom_Rank_1()
    
end

function Maelstrom_Rank_2()
    
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
        ACN_1()
        ACN_2()
        ACN_3()
    elseif DO_ARCHER_QUESTS == 1 then
        ARC_1()
        ARC_2()
        ARC_3()
    end
    
    if DO_DOL_QUESTS == 1 then
        FSH_UNLOCK()
        MIN_UNLOCK()
        BTN_UNLOCK()
    end
    
    if MaelstromEnemiesLog1 == 1 then
        Maelstrom_Rank_1()
    end
    
    if MaelstromEnemiesLog2 == 1 then
        Maelstrom_Rank_2()
    end
    
    Teleporter("gc", "li")
end

main()
