-- You should have used Questionable plugin (https://git.carvel.li/liza/Questionable/) or equivalent for MSQ completion up to certain points listed below, but at the very least up until you can select your GC
-- All options are better used when a mount is unlocked, mounts are not required as it has fallback but will slow the speed of completion
-- Job quests are completed so you can unlock other jobs which are required for min/btn/fsh unlocks, only the first 3 job quests are included here
-- DoL unlocks are for use with the dol leveller script, but mainly for ability to bulk level up retainers so they can be min/btn/fsh jobs
-- Maelstrom log rank 1 should be used after you have selected your GC and ideally have gotten your mount (not required but speeds everything up)
-- Maelstrom log rank 2 should be used after you have a combat 47 as Aurum Vale requires level 47
-- The quest unlocks will unlock the optional quests required for each stage of the Maelstrom progression, see the comments below for what they are for

--##########################################
--   CONFIGS
--##########################################

-- this toggle allows you to run the script on as many characters as you'd like, it'll rotate between them
multichar = false

local chars = {
    "example example@world",
    "example example@world",
    "example example@world"
}

-- Only set one of these
-- Should really change to a DO_JOB_QUESTS = "Arcanist" or something
--DO_JOB_QUESTS = "Arcanist"
DO_ARCANIST_QUESTS = false
DO_ARCHER_QUESTS = false

DO_DOL_QUESTS = true

-- Maelstrom Hunt logs
DO_MAELSTROM_LOG_1 = false
DO_MAELSTROM_LOG_2 = false

-- Dungeon unlocks
DO_HALATALI = false                  -- Maelstrom hunt log 1 hunt enemies       Hallo Halatali
DO_THE_SUNKEN_TEMPLE_OF_QARN = false -- Maelstrom hunt log 2 hunt enemies       Braving New Depths
DO_DZEMAEL_DARKHOLD = false          -- Chief Storm Sergeant requirement        Shadows Uncast (Maelstrom)
DO_THE_AURUM_VALE = false            -- Second Storm Lieutenant requirement     Going for Gold

-- Housing unlocks
DO_THE_LAVENDER_BEDS = false         -- The Lavender Beds Housing   Where the Heart Is (The Lavender Beds)
DO_THE_GOBLET = false                -- The Goblet Housing          Where the Heart Is (The Goblet)
DO_MIST = false                      -- Mist Housing                Where the Heart Is (Mist)

--#####################################
--#  DON'T TOUCH ANYTHING BELOW HERE  #
--# UNLESS YOU KNOW WHAT YOU'RE DOING #
--#####################################

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

-- Enemy names for Maelstrom hunting log 1
local MaelstromEnemiesLog1 = {
    "Amalj'aa Hunter",     -- maelstrom_01
    "Heckler Imp",         -- maelstrom_02 "Halatali"
    "Doctore",             -- maelstrom_03 "Halatali"
    "Firemane",            -- maelstrom_04 "Halatali"
    "Sylvan Groan",        -- maelstrom_05
    "Sylvan Sough",        -- maelstrom_06
    "Kobold Pickman",      -- maelstrom_07
    "Amalj'aa Bruiser",    -- maelstrom_08
    "Ixali Straightbreak", -- maelstrom_09
    "Ixali Wildtalon"      -- maelstrom_10
}

-- Enemy names for Maelstrom hunting log 2
local MaelstromEnemiesLog2 = {
    "Amalj'aa Divinator",  -- maelstrom_11
    "Kobold Pitman",       -- maelstrom_12
    "Temple Bat",          -- maelstrom_13 "The Sunken Temple of Qarn"
    "The Condemned",       -- maelstrom_14 "The Sunken Temple of Qarn"
    "Teratotaur",          -- maelstrom_15 "The Sunken Temple of Qarn"
    "Kobold Bedesman",     -- maelstrom_16
    "Kobold Priest",       -- maelstrom_17
    "Sylvan Sigh",         -- maelstrom_18
    "Shelfscale Sahagin",  -- maelstrom_19
    "Amalj'aa Pugilist"    -- maelstrom_20
}

-- usage: QuestID[1].questNumber or QuestID[1].id or QuestID[1].questName
local QuestID = {
    -- Dungeons
    {questNumber = 1,  id = 66233, questName = "Hallo Halatali"},                         -- Halatali
    {questNumber = 2,  id = 66300, questName = "Braving New Depths"},                     -- The Sunken Temple of Qarn
    {questNumber = 3,  id = 66664, questName = "Shadows Uncast (Maelstrom)"},             -- Dzemael Darkhold
    {questNumber = 4,  id = 66667, questName = "Gilding the Bilious (Maelstrom)"},        -- The Aurum Vale
    -- Housing
    {questNumber = 5,  id = 66748, questName = "Where the Heart Is (The Lavender Beds)"}, -- The Lavender Beds
    {questNumber = 6,  id = 66749, questName = "Where the Heart Is (The Goblet)"},        -- The Goblet
    {questNumber = 7,  id = 66750, questName = "Where the Heart Is (Mist)"},              -- Mist
    -- DoL
    {questNumber = 8,  id = 66133, questName = "Way of the Miner"},                       -- Miner
    {questNumber = 9,  id = 65539, questName = "Way of the Botanist"},                    -- Botanist
    {questNumber = 10, id = 66643, questName = "Way of the Fisher"},                      -- Fisher
    -- Mount
    {questNumber = 11, id = 66236, questName = "My Little Chocobo (Twin Adder)"},
    {questNumber = 12, id = 66237, questName = "My Little Chocobo (Maelstrom)"},
    {questNumber = 13, id = 66238, questName = "My Little Chocobo (Immortal Flames)"},
    -- Job Quests
    {questNumber = 14, id = 65988, questName = "Way of the Arcanist"},                    -- Arcanist Quest 01
    {questNumber = 15, id = 65990, questName = "My First Grimoire"},                      -- Arcanist Quest 02
    {questNumber = 16, id = 65991, questName = "What's in the Box"},                      -- Arcanist Quest 03
    {questNumber = 17, id = 65667, questName = "Way of the Archer"},                      -- Archer Quest 01
    {questNumber = 18, id = 65755, questName = "My First Bow"},                           -- Archer Quest 02
    {questNumber = 19, id = 65582, questName = "A Matter of Perspective"}                 -- Archer Quest 03
}


Loadfiyel = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
FunctionsToLoad = loadfile(Loadfiyel)
FunctionsToLoad()
DidWeLoadcorrectly()

--############
--# ARCANIST #
--############

-- NEEDS fixing
-- limsa arcanists' first quest level 1 "Way of the Arcanist"
function Arcanist1()
    if IsQuestComplete(QuestID[14].id) then
        yield('/e You have already completed the "' .. QuestID[14].questName .. '" quest.')
        yield("/e Skipping unlock.")
        return
    end
    
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Arcanist", "li")
    ZoneTransitions()
    Movement(-327.86, 12.89, 9.79)
    yield("/target Thubyrgeim")
    -- yield("/pinteract")
    -- yield("/waitaddon SelectYesno <maxwait.15><wait.9.5>")
    -- yield("/pcall SelectYesno true 0")
    QuestNPC("SelectYesno", true, 0)
    Movement(-335.29, 11.99, 54.45)
    Teleporter("Tempest", "li")
    ZoneTransitions()
    Movement(14.71, 64.52, 87.16)
    QuestChecker(ArcanistEnemies[1], 25, "_ToDoList", 13, 3, x, x, x, "Slay wharf rats.")
    QuestChecker(ArcanistEnemies[3], 25, "_ToDoList", 15, 3, x, x, x, "Slay little ladybugs.")
    Movement(232.67, 40.64, 57.39)
    QuestChecker(ArcanistEnemies[2], 25, "_ToDoList", 13, 3, x, x, x, "Report to Thubyrgeim at the Arcanists' Guild.")
    --yield("/wait 1.6")
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Arcanist", "li")
    ZoneTransitions()
    Movement(-327.86, 12.89, 9.79)
    yield("/target Thubyrgeim")
    QuestNPC()
end

-- NEEDS fixing
-- limsa arcanists' second quest level 5 "What's in the Box"
function Arcanist2()
    if IsQuestComplete(QuestID[15].id) then
        yield('/e You have already completed the "' .. QuestID[15].questName .. '" quest.')
        yield("/e Skipping unlock.")
        return
    end
    
    Movement(-327.86, 12.89, 9.79)
    yield("/target Thubyrgeim")
    QuestNPC()
    Movement(-335.29, 11.99, 54.45)
    Teleporter("Zephyr", "li")
    ZoneTransitions()
    Movement(219.94, 66.81, 287.77)
    ZoneTransitions()
    Movement(381.76, 71.93, -256.04)
    QuestChecker(ArcanistEnemies[4], 25, "_ToDoList", 13, 3, x, x, x, "Slay wild dodos.")
    Movement(418.06, 65.90, -160.37)
    QuestChecker(ArcanistEnemies[5], 25, "_ToDoList", 13, 3, x, x, x, "Report to Thubyrgeim at the Arcanists' Guild.")
    --yield("/wait 1.6")
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Arcanist", "li")
    ZoneTransitions()
    Movement(-327.86, 12.89, 9.79)
    yield("/target Thubyrgeim")
    QuestNPC()
    Movement(-335.29, 11.99, 54.45)
    Teleporter("Zephyr", "li")
    ZoneTransitions()
    Movement(-0.007, 24.5, 194.68)
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
    yield("/target Thubyrgeim")
    QuestNPC()
end

-- NEEDS fixing
-- limsa arcanists' third quest level 10 "Tactical Planning"
function Arcanist3()
    if IsQuestComplete(QuestID[16].id) then
        yield('/e You have already completed the "' .. QuestID[16].questName .. '" quest.')
        yield("/e Skipping unlock.")
        return
    end
    
    Movement(-327.86, 12.89, 9.79)
    yield("/target Thubyrgeim")
    QuestNPC()
    Teleporter("Swiftperch", "tp")
    ZoneTransitions()
    Movement(674.92, 19.37, 436.02)
    QuestChecker(ArcanistEnemies[6], 25, "_ToDoList", 13, 3, x, x, x, "Slay roselings.")
    --yield("/wait 1.6")
    Teleporter("Moraby", "tp")
    ZoneTransitions()
    Movement(30.84, 46.18, 831.01)
    QuestChecker(ArcanistEnemies[7], 40, "_ToDoList", 13, 3, x, x, x, "Report to Thubyrgeim at the Arcanists' Guild.")
    --yield("/wait 1.6")
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Arcanist", "li")
    ZoneTransitions()
    Movement(-327.86, 12.89, 9.79)
    yield("/target Thubyrgeim")
    QuestNPC()
    Movement(-347.72, -2.37, 12.88)
    yield("/target K'lyhia")
    yield("/lockon")
    QuestNPC()
    Teleporter("Summerford", "tp")
    ZoneTransitions()
    Movement(-103.76, 46.15, -253.17)
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
    yield("/target Thubyrgeim")
    QuestNPC()
end

--##########
--# ARCHER #
--##########

-- gridania archer first quest level 1 "Way of the Archer"
function Archer1()
    if IsQuestComplete(QuestID[17].id) then
        yield('/e You have already completed the "' .. QuestID[17].questName .. '" quest.')
        yield("/e Skipping unlock.")
        return
    end
    
    -- forgot to do this one, probs will later.
end
   
-- gridania archer second quest level 5 "A Matter of Perspective"
function Archer2()
    if IsQuestComplete(QuestID[18].id) then
        yield('/e You have already completed the "' .. QuestID[18].questName .. '" quest.')
        yield("/e Skipping unlock.")
        return
    end
    
    Teleporter("New Gridania", "tp")
    ZoneTransitions()
    Teleporter("Archers' Guild", "li")
    ZoneTransitions()
    Movement(207.80, 0.10, 35.06)
    yield("/target Luciane")
    QuestNPC()
    Movement(187.65, -1.25, 63.54)
    yield("/target Archery Butt")
    yield('/ac "Heavy Shot"')
    Movement(109.31, 0.12, 59.86)
    yield("/target Archery Butt")
    yield('/ac "Heavy Shot"')
    Movement(50.87, 0.93, 25.88)
    yield("/target Archery Butt")
    yield('/ac "Heavy Shot"')
    Movement(51.35, -1.52, 61.06)
    yield("/target Archery Butt")
    yield('/ac "Heavy Shot"')
    Movement(66.11, -4.96, 91.91)
    yield("/target Archery Butt")
    yield('/ac "Heavy Shot"')
    Movement(57.20, -8.56, 105.41)
    yield("/target Archery Butt")
    yield('/ac "Heavy Shot"')
    Movement(34.93, 1.92, 34.09)
    Teleporter("Archers' Guild", "li")
    ZoneTransitions()
    Movement(207.80, 0.10, 35.06)
    yield("/target Luciane")
    QuestNPC()
    Teleporter("Fallgourd","tp")
    ZoneTransitions()
    Movement(307.65, -19.79, 171.31)
    QuestChecker(ArcherEnemies[4], 60, "_ToDoList", "Slay opo-opos.")
    Movement(301.68, -9.38, 11.51)
    QuestChecker(ArcherEnemies[5], 60, "_ToDoList", "Slay microchus.")
    Teleporter("New Gridania", "tp")
    ZoneTransitions()
    Teleporter("Archers' Guild", "li")
    ZoneTransitions()
    Movement(207.80, 0.10, 35.06)
    yield("/target Luciane")
    QuestNPC()
end

-- gridania archer third quest level 10 "Training with Leih"
function Archer3()
    if IsQuestComplete(QuestID[19].id) then
        yield('/e You have already completed the "' .. QuestID[19].questName .. '" quest.')
        yield("/e Skipping unlock.")
        return
    end
    
    yield("/wait 1")
    yield("/target Luciane")
    QuestNPC()
    Movement(208.91, 0.00, 29.65)
    yield("/target Leih Aliapoh")
    QuestNPC()
    Teleporter("Bentbranch", "tp")
    ZoneTransitions()
    --First zone
    Movement(-88.03, -4.58, -73.39)
    yield("/target Archery Butt")
    yield('/ac "Heavy Shot"')
    yield("/wait 0.2")
    Movement(-112.35, -3.95, -64.35)
    yield("/target Archery Butt")
    yield('/ac "Heavy Shot"')
    yield("/wait 0.2")
    Movement(-135.89, -1.61, -71.04)
    yield("/target Archery Butt")
    yield('/ac "Heavy Shot"')
    yield("/wait 0.2")
    --Second zone
    Movement(-146.34, 3.64, -129.18)
    yield("/target Archery Butt")
    yield('/ac "Heavy Shot"')
    yield("/wait 0.2")
    Movement(-111.04, 7.75, -164.70)
    yield("/target Archery Butt")
    yield('/ac "Heavy Shot"')
    yield("/wait 0.2")
    -- Third zone
    Movement(-80.48, 0.53, -176.20)
    yield("/target Archery Butt")
    yield('/ac "Heavy Shot"')
    yield("/wait 0.2")
    -- Report to Leih Aliapoh
    Teleporter("New Gridania", "tp")
    ZoneTransitions()
    Teleporter("Archers' Guild", "li")
    ZoneTransitions()
    Movement(208.91, 0.00, 29.65)
    yield("/target Leih Aliapoh")
    QuestNPC()
    -- Kill some enemies
    Movement(147.35, -0.24, 84.22)
    Movement(115.20, -0.14, 74.28)
    Movement(94.11, 3.91, 24.27)
    Movement(99.57, 4.77, 17.09)
    yield("/vnav moveto 101.94 5.31 13.12")
    yield("/wait 2")
    ZoneTransitions()
    Movement(179.43, -2.16, -242.84)
    yield("/target Romarique")
    yield("/wait 0.5")
    yield("/pint")
    repeat 
        yield("/wait 0.1")
    until IsAddonReady("SelectIconString")
    yield("/pcall SelectIconString true 0")
    yield("/wait 1")
    repeat 
        yield("/wait 0.1")
    until IsAddonReady("SelectYesno")
    yield("/pcall SelectYesno true 0")
    ZoneTransitions()
    Movement(-496.79, 8.99, 89.93)
    QuestChecker(ArcherEnemies[7], 50, "_ToDoList", "Slay northern vultures.")
    Movement(-448.56, -0.31, 226.01)
    QuestChecker(ArcherEnemies[6], 50, "_ToDoList", "Slay tree slugs.")
    --Report to Leih
    Teleporter("New Gridania", "tp")
    ZoneTransitions()
    Teleporter("Archers' Guild", "li")
    ZoneTransitions()
    Movement(208.91, 0.00, 29.65)
    yield("/target Leih Aliapoh")
    QuestNPC()
    -- report to Luciane
    Movement(207.80, 0.10, 35.06)
    yield("/target Luciane")
    yield("/pint")
    repeat 
        yield("/wait 0.1")
    until IsAddonReady("SelectYesno")
    yield("/pcall SelectYesno true 0")
    repeat 
        yield("/wait 0.1")
    until IsPlayerAvailable()
end

--###############
--# JOB UNLOCKS #
--###############

-- NEEDS fixing
function FisherUnlock()
    if IsQuestComplete(66643) then
        Echo("Already finished the Fisher quest, moving on")
        return
    end
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    yield("/li fish")
    ZoneTransitions()
    Movement(-167.30, 4.55, 152.46)
    Target("N'nmulika")
    QuestNPC("SelectYesno", true, 0)
    Sleep(1.6)
    Target("N'nmulika")
    QuestNPC()
    Movement(-173.59, 4.2, 162.77)
    Movement(-165.74, 4.55, 165.38)
    Target("Sisipu")
    QuestNPC("SelectYesno", true, 0)
end

-- NEEDS fixing
function MinerUnlock()
    if IsQuestComplete(66133) then
        Echo("Already finished the Miner quest, moving on")
        return
    end
    Teleporter("Ul'dah", "tp")
    ZoneTransitions()
    yield("/li weaver")
    ZoneTransitions()
    Movement(1.54, 7.6, 153.55)
    Target("Linette")
    QuestNPC("SelectYesno", true, 0)
    Sleep(1.6)
    Target("Linette")
    QuestNPC()
    Movement(-17.33, 6.2, 157.59)
    Target("Adalberta")
    QuestNPC("SelectYesno", true, 0)
end

-- NEEDS fixing
function BotanistUnlock()
    if IsQuestComplete(65539) then
        Echo("Already finished the Botanist quest, moving on")
        return
    end
    Teleporter("Gridania", "tp")
    ZoneTransitions()
    yield("/li mih")
    ZoneTransitions()
    Movement(-170.48, 10.39, -161.96)
    Movement(-238.64, 8, -144.90)
    Target("Leonceault")
    QuestNPC("SelectYesno", true, 0)
    Sleep(1.6)
    Target("Leonceault")
    QuestNPC()
    Movement(-234.09, 6.23, -170.02)
    Target("Fufucha")
    QuestNPC("SelectYesno", true, 0)
end

--################
--# HUNT UNLOCKS #
--################

-- NEEDS fixing
--needs nodescanner adding and the matching text adjusting
function MaelstromRank1()
    -- Amalj'aa Hunter
    Teleporter("Camp Drybone", "tp")
    ZoneTransitions()
    Movement(-112.60, -27.88, 343.99)
    -- QuestChecker(MaelstromEnemiesLog1[1], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    Movement(-122.43, -30.10, 297.20)
    -- QuestChecker(MaelstromEnemiesLog1[1], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    Movement(-122.43, -30.10, 297.20)
    -- QuestChecker(MaelstromEnemiesLog1[1], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    -- Amalj'aa Bruiser
    Movement(-169.97, -46.71, 493.46)
    ZoneTransitions()
    Movement(-157.06, 26.13, -410.14)
    yield("/target Aetheryte")
    Interact()
    Movement(-32.69, 15.53, -277.9)
    -- QuestChecker(MaelstromEnemiesLog1[8], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    Movement(-9.38, 15.62, -291.08)
    -- QuestChecker(MaelstromEnemiesLog1[8], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    -- QuestChecker(MaelstromEnemiesLog1[8], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    -- Sylvan Groan + Sylvan Sough
    Teleporter("Bentbranch Meadows", "tp")
    ZoneTransitions()
    Movement(389.27, -3.36, -186.45)
    ZoneTransitions()
    Movement(-189.88, 4.43, 294.46)
    yield("/target Aetheryte")
    Interact()
    Movement(-135.26, 15.12, -1.46)
    -- QuestChecker(MaelstromEnemiesLog1[5], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    -- QuestChecker(MaelstromEnemiesLog1[6], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    Movement(-104.98, 18.52, 14.46)
    -- QuestChecker(MaelstromEnemiesLog1[5], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    -- QuestChecker(MaelstromEnemiesLog1[6], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    Movement(-71.64, 17.58, 7.27)
    -- QuestChecker(MaelstromEnemiesLog1[5], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    -- QuestChecker(MaelstromEnemiesLog1[6], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    -- Kobold Pickman
    Teleporter("Aleport", "tp")
    ZoneTransitions()
    Movement(417.30, 35.15, -17.66)
    ZoneTransitions()
    Movement(-477.30, 26.29, 61.12)
    -- QuestChecker(MaelstromEnemiesLog1[7], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    -- QuestChecker(MaelstromEnemiesLog1[7], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    Movement(-432.12, 38.29, 19.78)
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
    ZoneTransitions()
    Movement(53.52, -37.91, 312.72)
    -- QuestChecker(MaelstromEnemiesLog1[9], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    Movement(75.32, -38.07, 331.25)
    -- QuestChecker(MaelstromEnemiesLog1[9], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    Movement(75.83, -41.24, 352.80)
    -- QuestChecker(MaelstromEnemiesLog1[9], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    -- Ixali Wildtalon
    Movement(-36.96, -39.16, 232.40)
    yield("/target Aetheryte")
    Interact()
    Movement(-405, 9.5, 128)
    ZoneTransitions()
    Movement(468.13, 232.79, 321.85)
    -- QuestChecker(MaelstromEnemiesLog1[10], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    Movement(224.32, 301.51, -142.16)
    Movement(229.20, 312.91, -235.02)
    yield("/target Aetheryte")
    Interact()
    Teleport("Limsa", "tp")
end

function MaelstromRank2()
    -- stuff goes here
end

--###################
--# DUNGEON UNLOCKS #
--###################

-- can also probably use questionable once commands or ipc work better
-- needs updating once nodescanner works
function HalataliUnlock()
    if IsQuestComplete(QuestID[1].id) then
        yield('/e You have already completed the "' .. QuestID[1].questName .. '" quest.')
        yield("/e Skipping unlock.")
        return
    end

    Teleporter("Horizon", "tp") -- could also use vesper bay ticket but needs the teleporter function adjusting
    ZoneTransitions()
    Movement(-471.37, 23.01, -355.12)
    yield("/target Nedrick Ironheart")
    QuestNPC()
    -- once accepted quest
    Teleporter("Camp Drybone", "tp")
    ZoneTransitions()
    Movement(-330.92, -22.48, 434.14)
    yield("/target Fafajoni")
    QuestNPC()
end

function TheSunkenTempleOfQarnUnlock()
    if IsQuestComplete(QuestID[2].id) then
        yield('/e You have already completed the "' .. QuestID[2].questName .. '" quest.')
        yield("/e Skipping unlock.")
        return
    end
    
    -- stuff goes here
end

function DzemaelDarkholdUnlock()
    if IsQuestComplete(QuestID[3].id) then
        yield('/e You have already completed the "' .. QuestID[3].questName .. '" quest.')
        yield("/e Skipping unlock.")
        return
    end
    
    -- stuff goes here
end

function TheAurumValeUnlock()
    
end

--##########################################
--  MAIN SCRIPT
--##########################################
function Main()
    if IsQuestComplete(QuestID[4].id) then
        yield('/e You have already completed the "' .. QuestID[4].questName .. '" quest.')
        yield("/e Skipping unlock.")
        return
    end
    
    -- stuff goes here
end

function TheLavenderBedsUnlock()
    if IsQuestComplete(QuestID[5].id) then
        yield('/e You have already completed the "' .. QuestID[5].questName .. '" quest.')
        yield("/e Skipping unlock.")
        return
    end
    
    -- stuff goes here
end

function TheGobletUnlock()
    if IsQuestComplete(QuestID[6].id) then
        yield('/e You have already completed the "' .. QuestID[6].questName .. '" quest.')
        yield("/e Skipping unlock.")
        return
    end
    
    -- stuff goes here
end

function MistUnlock()
    if IsQuestComplete(QuestID[7].id) then
        yield('/e You have already completed the "' .. QuestID[7].questName .. '" quest.')
        yield("/e Skipping unlock.")
        return
    end
    
    -- stuff goes here
end

--###############
--# MAIN SCRIPT #
--###############

function main()
    yield("/at e")
    yield("/p")
    yield("/vbm cfg AI Enabled true")
    yield("/vbmai on")
    if DO_ARCANIST_QUESTS then
        Arcanist1()
        Arcanist2()
        Arcanist3()
    elseif DO_ARCHER_QUESTS then
        Archer1()
        Archer2()
        Archer3()
    end
    
-- DoL
    if DO_DOL_QUESTS then
        FisherUnlock()
        MinerUnlock()
        BotanistUnlock()
    end
    
-- Hunt Logs
    if DO_MAELSTROM_LOG_1 then
        MaelstromRank1()
    end
    
    if DO_MAELSTROM_LOG_2 then
        MaelstromRank2()
    end
    
-- Dungeons
    if DO_HALATALI then
        HalataliUnlock()
    end
    
    if DO_THE_SUNKEN_TEMPLE_OF_QARN then
        TheSunkenTempleOfQarnUnlock()
    end
    
    if DO_DZEMAEL_DARKHOLD then
        DzemaelDarkholdUnlock()
    end
    
    if DO_THE_AURUM_VALE then
        TheAurumValeUnlock()
    end
    
-- Housing
    if DO_THE_LAVENDER_BEDS then
        TheLavenderBedsUnlock()
    end
    
    if DO_THE_GOBLET then
        TheGobletUnlock()
    end
    
    if DO_MIST then
        MistUnlock()
    end
end

if multichar then
    for _, char in ipairs(chars) do
        if GetCharacterName(true) == char then
            -- continue, no relogging needed
        else
            yield("/ays relog " ..char)
            yield("<wait.15.0>")
            yield("/waitaddon NamePlate <maxwait.6000><wait.5>")
        end
        repeat
            yield("/wait 0.1")
        until IsPlayerAvailable()
        Main()
    end
else
    Main()
end