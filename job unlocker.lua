-- You should have used Questionable plugin (https://git.carvel.li/liza/Questionable/) or equivalent for MSQ completion up to certain points listed below, but at the very least up until you can select your GC
-- All options are better used when a mount is unlocked, mounts are not required as it has fallback but will slow the speed of completion
-- Job quests are completed so you can unlock other jobs which are required for min/btn/fsh unlocks, only the first 3 job quests are included here
-- DoL unlocks are for use with the dol leveller script, but mainly for ability to bulk level up retainers so they can be min/btn/fsh jobs
-- Maelstrom log rank 1 should be used after you have selected your GC and ideally have gotten your mount (not required but speeds everything up)
-- Maelstrom log rank 2 should be used after you have a combat 47 as Aurum Vale requires level 47
-- The quest unlocks will unlock the optional quests required for each stage of the Maelstrom progression, see the comments below for what they are for

-- ###########
-- # CONFIGS #
-- ###########

-- Only set one of these
-- Should really change to a DO_JOB_QUESTS = "Arcanist" or something
--DO_JOB_QUESTS = "Arcanist"
DO_ARCANIST_QUESTS = false
DO_ARCHER_QUESTS = false

DO_DOL_QUESTS = false

-- Maelstrom Hunt logs
DO_MAELSTROM_LOG_1 = false
DO_MAELSTROM_LOG_2 = false

-- Dungeon unlocks
DO_HALATALI = false                  -- Maelstrom hunt log 1 hunt enemies       Hallo Halatali
DO_THE_SUNKEN_TEMPLE_OF_QARN = false -- Maelstrom hunt log 2 hunt enemies       Braving New Depths
DO_DZEMAEL_DARKHOLD = false          -- Requires Storm Sergeant First Class
DO_THE_AURUM_VALE = false            -- Requires Chief Storm Sergeant

-- Housing unlocks
DO_THE_LAVENDER_BEDS = false         -- The Lavender Beds Housing   Where the Heart Is (The Lavender Beds)
DO_THE_GOBLET = false                -- The Goblet Housing          Where the Heart Is (The Goblet)
DO_MIST = false                      -- Mist Housing                Where the Heart Is (Mist)


local use_external_character_list = true  -- Options: true = uses the external character list in the same folder, default name being CharList.lua, false uses the list you put in this file 

MULTICHAR = false

-- This is where you put your character list if you choose to not use the external one
-- If us_external_character_list is set to true then this list is completely skipped
-- Usage: First Last@Server, return_home, return_location
-- return_home options: 0 = no, 1 = yes
-- return_location options: 0 = fc entrance, 1 nearby bell, 2 limsa bell
-- This is where your alts that need items are listed
local character_list = {
    "First Last@Server",
    "First Last@Server"
}

-- #####################################
-- #  DON'T TOUCH ANYTHING BELOW HERE  #
-- # UNLESS YOU KNOW WHAT YOU'RE DOING #
-- #####################################

-- Enemy names for Arcanist quests
local ArcanistEnemies = {
    "Wharf Rat",           -- arcanist_01 "Way of the Arcanist"
    "Aurelia",             -- arcanist_02 "Way of the Arcanist"
    "Little Ladybug",      -- arcanist_03 "Way of the Arcanist"
    "Wild Dodo",           -- arcanist_04 "My First Grimoire"
    "Tiny Mandragora",     -- arcanist_05 "My First Grimoire"
    "Roseling",            -- arcanist_06 "What's in the Box"
    "Wild Jackal"          -- arcanist_07 "What's in the Box"
}

-- Enemy names for Archer quests
local ArcherEnemies = {
    "Ground Squirrel",     -- archer_01 "Way of the Archer"
    "Little Ladybug",      -- archer_02 "Way of the Archer"
    "Forest Funguar",      -- archer_03 "Way of the Archer"
    "Opo-opo",             -- archer_04 "My First Bow"
    "Microchu",            -- archer_05 "My First Bow"
    "Tree Slug",           -- archer_06 "A Matter of Perspective"
    "Northern Vulture"     -- archer_07 "A Matter of Perspective"
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

-- Will eventually be made into an excel browser function and put into functions
-- Only these quests work, all will work once excel browser integration is done
QuestNameList = {
    -- Dungeons
    ["Hallo Halatali"]                         = {quest_id =  697, quest_key = 66233}, -- Halatali
    ["Braving New Depths"]                     = {quest_id =  764, quest_key = 66300}, -- The Sunken Temple of Qarn
    ["Shadows Uncast (Maelstrom)"]             = {quest_id = 1128, quest_key = 66664}, -- Dzemael Darkhold
    ["Gilding the Bilious (Maelstrom)"]        = {quest_id = 1131, quest_key = 66667}, -- The Aurum Vale
    -- Housing
    ["Where the Heart Is (The Lavender Beds)"] = {quest_id = 1212, quest_key = 66748}, -- The Lavender Beds
    ["Where the Heart Is (The Goblet)"]        = {quest_id = 1213, quest_key = 66749}, -- The Goblet
    ["Where the Heart Is (Mist)"]              = {quest_id = 1214, quest_key = 66750}, -- Mist
    -- DoL (Disciples of the Land)
    ["Way of the Miner"]                       = {quest_id =  597, quest_key = 66133}, -- Miner
    ["Way of the Botanist"]                    = {quest_id =    3, quest_key = 65539}, -- Botanist
    ["Way of the Fisher"]                      = {quest_id = 1107, quest_key = 66643}, -- Fisher
    -- Mount
    ["My Little Chocobo (Twin Adder)"]         = {quest_id =  700, quest_key = 66236}, -- Twin Adder Chocobo
    ["My Little Chocobo (Maelstrom)"]          = {quest_id =  701, quest_key = 66237}, -- Maelstrom Chocobo
    ["My Little Chocobo (Immortal Flames)"]    = {quest_id =  702, quest_key = 66238}, -- Immortal Flames Chocobo
    -- Job Quests
    ["Way of the Arcanist"]                    = {quest_id =  452, quest_key = 65988}, -- Arcanist Quest 01
    ["My First Grimoire"]                      = {quest_id =  454, quest_key = 65990}, -- Arcanist Quest 02
    ["What's in the Box"]                      = {quest_id =  455, quest_key = 65991}, -- Arcanist Quest 03
    ["Way of the Archer"]                      = {quest_id =  131, quest_key = 65667}, -- Archer Quest 01
    ["My First Bow"]                           = {quest_id =  219, quest_key = 65755}, -- Archer Quest 02
    ["A Matter of Perspective"]                = {quest_id =   46, quest_key = 65582}  -- Archer Quest 03
}

-- #####################################
-- #  DON'T TOUCH ANYTHING BELOW HERE  #
-- # UNLESS YOU KNOW WHAT YOU'RE DOING #
-- #####################################

-- Edit CharList.lua file for configuring characters
CharList = "CharList.lua"

SNDConfigFolder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
LoadFunctionsFileLocation = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(LoadFunctionsFileLocation)
LoadFunctions()
LoadFileCheck()
LogInfo("[JU] ##############################")
LogInfo("[JU] Starting script...")
LogInfo("[JU] SNDConfigFolder: " .. SNDConfigFolder)
LogInfo("[JU] CharList: " .. CharList)
LogInfo("[JU] SNDC+Char: " .. SNDConfigFolder .. "" .. CharList)
LogInfo("[JU] ##############################")

if use_external_character_list then
    local char_data = dofile(SNDConfigFolder .. CharList)
    character_list = char_data.character_list
end

-- ############
-- # ARCANIST #
-- ############

-- NEEDS fixing
-- limsa arcanists' first quest level 1 "Way of the Arcanist"
function Arcanist1()
    if IsQuestComplete(QuestID[14].id) then
        Echo('You have already completed the "' .. QuestID[14].questName .. '" quest.')
        Echo("Skipping unlock.")
        return
    end
    
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Arcanist", "li")
    ZoneTransitions()
    Movement(-327.86, 12.89, 9.79)
    Target("Thubyrgeim")
    QuestNPC("SelectYesno", true, 0)
    Movement(-335.29, 11.99, 54.45)
    Teleporter("Tempest", "li")
    ZoneTransitions()
    Movement(14.71, 64.52, 87.16)
    --QuestChecker(ArcanistEnemies[1], 25, "_ToDoList", 13, 3, x, x, x, "Slay wharf rats.")
    --QuestChecker(ArcanistEnemies[3], 25, "_ToDoList", 15, 3, x, x, x, "Slay little ladybugs.")
    Movement(232.67, 40.64, 57.39)
    --QuestChecker(ArcanistEnemies[2], 25, "_ToDoList", 13, 3, x, x, x, "Report to Thubyrgeim at the Arcanists' Guild.")
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Arcanist", "li")
    ZoneTransitions()
    Movement(-327.86, 12.89, 9.79)
    Target("Thubyrgeim")
    QuestNPC()
end

-- NEEDS fixing
-- limsa arcanists' second quest level 5 "What's in the Box"
function Arcanist2()
    if IsQuestComplete(QuestID[15].id) then
        Echo('You have already completed the "' .. QuestID[15].questName .. '" quest.')
        Echo("Skipping unlock.")
        return
    end
    
    Movement(-327.86, 12.89, 9.79)
    Target("Thubyrgeim")
    QuestNPC()
    Movement(-335.29, 11.99, 54.45)
    Teleporter("Zephyr", "li")
    ZoneTransitions()
    Movement(219.94, 66.81, 287.77)
    ZoneTransitions()
    Movement(381.76, 71.93, -256.04)
    --QuestChecker(ArcanistEnemies[4], 25, "_ToDoList", 13, 3, x, x, x, "Slay wild dodos.")
    Movement(418.06, 65.90, -160.37)
    --QuestChecker(ArcanistEnemies[5], 25, "_ToDoList", 13, 3, x, x, x, "Report to Thubyrgeim at the Arcanists' Guild.")
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Arcanist", "li")
    ZoneTransitions()
    Movement(-327.86, 12.89, 9.79)
    Target("Thubyrgeim")
    QuestNPC()
    Movement(-335.29, 11.99, 54.45)
    Teleporter("Zephyr", "li")
    ZoneTransitions()
    Movement(-0.01, 24.5, 194.68)
    Target("Practice Crates") -- Crates with the s
    QuestNPC()
    yield("/rotation auto")
    
    repeat 
        Sleep(0.1)
    until GetCharacterCondition(26)
    
    repeat 
        Sleep(0.1)
    until not GetCharacterCondition(26)
    
    yield("/rotation off")
    Movement(-0.01, 24.5, 194.68)
    Sleep(1.6)
    WaitUntilObjectExists("Practice Crate") -- Crate without the s
    Target("Practice Crates")
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
    Target("Thubyrgeim")
    QuestNPC()
end

-- NEEDS fixing
-- limsa arcanists' third quest level 10 "Tactical Planning"
function Arcanist3()
    if IsQuestComplete(QuestID[16].id) then
        Echo('You have already completed the "' .. QuestID[16].questName .. '" quest.')
        Echo("Skipping unlock.")
        return
    end
    
    Movement(-327.86, 12.89, 9.79)
    Target("Thubyrgeim")
    QuestNPC()
    Teleporter("Swiftperch", "tp")
    ZoneTransitions()
    Movement(674.92, 19.37, 436.02)
    --QuestChecker(ArcanistEnemies[6], 25, "_ToDoList", 13, 3, x, x, x, "Slay roselings.")
    Teleporter("Moraby", "tp")
    ZoneTransitions()
    Movement(30.84, 46.18, 831.01)
    --QuestChecker(ArcanistEnemies[7], 40, "_ToDoList", 13, 3, x, x, x, "Report to Thubyrgeim at the Arcanists' Guild.")
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Arcanist", "li")
    ZoneTransitions()
    Movement(-327.86, 12.89, 9.79)
    Target("Thubyrgeim")
    QuestNPC()
    Movement(-347.72, -2.37, 12.88)
    Target("K'lyhia")
    DoTargetLockon()
    QuestNPC()
    Teleporter("Summerford", "tp")
    ZoneTransitions()
    Movement(-103.76, 46.15, -253.17)
    Target("K'lyhia")
    Interact()
    yield("/waitaddon SelectYesno <maxwait.10><wait.0.5>")
    yield("/pcall SelectYesno true 0")
    ZoneTransitions()
    yield("/rotation auto")
    QuestInstance()
    ZoneTransitions()
    Sleep(1.6)
    yield("/rotation off")
    Target("K'lyhia")
    DoTargetLockon()
    QuestNPC()
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Arcanist", "li")
    ZoneTransitions()
    Movement(-327.86, 12.89, 9.79)
    Target("Thubyrgeim")
    QuestNPC()
end

-- ##########
-- # ARCHER #
-- ##########

-- gridania archer first quest level 1 "Way of the Archer"
function Archer1()
    if IsQuestComplete(QuestID[17].id) then
        Echo('You have already completed the "' .. QuestID[17].questName .. '" quest.')
        Echo("Skipping unlock.")
        return
    end
    
    -- forgot to do this one, probs will later.
end

-- NEEDS adjusting
-- gridania archer second quest level 5 "A Matter of Perspective"
function Archer2()
    if IsQuestComplete(QuestID[18].id) then
        Echo('You have already completed the "' .. QuestID[18].questName .. '" quest.')
        Echo("Skipping unlock.")
        return
    end
    
    Teleporter("New Gridania", "tp")
    ZoneTransitions()
    Teleporter("Archers' Guild", "li")
    ZoneTransitions()
    Movement(207.80, 0.10, 35.06)
    Target("Luciane")
    QuestNPC()
    Movement(187.65, -1.25, 63.54)
    Target("Archery Butt")
    DoAction("Heavy Shot")
    Movement(109.31, 0.12, 59.86)
    Target("Archery Butt")
    DoAction("Heavy Shot")
    Movement(50.87, 0.93, 25.88)
    Target("Archery Butt")
    DoAction("Heavy Shot")
    Movement(51.35, -1.52, 61.06)
    Target("Archery Butt")
    DoAction("Heavy Shot")
    Movement(66.11, -4.96, 91.91)
    Target("Archery Butt")
    DoAction("Heavy Shot")
    Movement(57.20, -8.56, 105.41)
    Target("Archery Butt")
    DoAction("Heavy Shot")
    Movement(34.93, 1.92, 34.09)
    Teleporter("Archers' Guild", "li")
    ZoneTransitions()
    Movement(207.80, 0.10, 35.06)
    Target("Luciane")
    QuestNPC()
    Teleporter("Fallgourd", "tp")
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
    Target("Luciane")
    QuestNPC()
end

-- NEEDS adjusting
-- gridania archer third quest level 10 "Training with Leih"
function Archer3()
    if IsQuestComplete(QuestID[19].id) then
        Echo('You have already completed the "' .. QuestID[19].questName .. '" quest.')
        Echo("Skipping unlock.")
        return
    end
    
    Sleep(1.0)
    Target("Luciane")
    QuestNPC()
    Movement(208.91, 0.00, 29.65)
    Target("Leih Aliapoh")
    QuestNPC()
    Teleporter("Bentbranch", "tp")
    ZoneTransitions()
    --First zone
    Movement(-88.03, -4.58, -73.39)
    Target("Archery Butt")
    DoAction("Heavy Shot")
    Sleep(0.2)
    Movement(-112.35, -3.95, -64.35)
    Target("Archery Butt")
    DoAction("Heavy Shot")
    Sleep(0.2)
    Movement(-135.89, -1.61, -71.04)
    Target("Archery Butt")
    DoAction("Heavy Shot")
    Sleep(0.2)
    --Second zone
    Movement(-146.34, 3.64, -129.18)
    Target("Archery Butt")
    DoAction("Heavy Shot")
    Sleep(0.2)
    Movement(-111.04, 7.75, -164.70)
    Target("Archery Butt")
    DoAction("Heavy Shot")
    Sleep(0.2)
    -- Third zone
    Movement(-80.48, 0.53, -176.20)
    Target("Archery Butt")
    DoAction("Heavy Shot")
    Sleep(0.2)
    -- Report to Leih Aliapoh
    Teleporter("New Gridania", "tp")
    ZoneTransitions()
    Teleporter("Archers' Guild", "li")
    ZoneTransitions()
    Movement(208.91, 0.00, 29.65)
    Target("Leih Aliapoh")
    QuestNPC()
    -- Kill some enemies
    -- Probably needs handling or validation adding
    Movement(147.35, -0.24, 84.22)
    Movement(115.20, -0.14, 74.28)
    Movement(94.11, 3.91, 24.27)
    Movement(99.57, 4.77, 17.09)
    Movement(101.94, 5.31, 13.12)
    Sleep(2.0)
    ZoneTransitions()
    Movement(179.43, -2.16, -242.84)
    Target("Romarique")
    Sleep(0.5)
    Interact()
    
    repeat 
        Sleep(0.1)
    until IsAddonReady("SelectIconString")
    
    yield("/pcall SelectIconString true 0")
    Sleep(1.0)
    
    repeat 
        Sleep(0.1)
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
    Target("Leih Aliapoh")
    QuestNPC()
    -- report to Luciane
    Movement(207.80, 0.10, 35.06)
    Target("Luciane")
    Interact()
    
    repeat 
        Sleep(0.1)
    until IsAddonReady("SelectYesno")
    
    yield("/pcall SelectYesno true 0")
    
    repeat 
        Sleep(0.1)
    until IsPlayerAvailable()
end

-- ###############
-- # JOB UNLOCKS #
-- ###############

-- NEEDS fixing
function MinerUnlock()
    if IsQuestComplete(QuestID[8].id) then
        Echo('You have already completed the "' .. QuestID[8].questName .. '" quest.')
        Echo("Skipping unlock.")
        return
    end
    
    Teleporter("Ul'dah", "tp")
    ZoneTransitions()
    -- Teleporter("Weaver", "li")
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
-- Questionable does not support this yet, using alternative method
function BotanistUnlock()
    if IsQuestComplete(QuestID[9].id) then
        Echo('You have already completed the "' .. QuestID[9].questName .. '" quest.')
        Echo("Skipping unlock.")
        return
    end
    
    Teleporter("Gridania", "tp")
    ZoneTransitions()
    -- Teleporter("Mih", "li")
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

-- NEEDS fixing
-- Questionable does not support this yet, using alternative method
function FisherUnlock()
    if IsQuestComplete(QuestID[10].id) then
        Echo('You have already completed the "' .. QuestID[10].questName .. '" quest.')
        Echo("Skipping unlock.")
        return
    end
    
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    -- Teleporter("Fish", "li")
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

-- ################
-- # HUNT UNLOCKS #
-- ################

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
    Target("Aetheryte")
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
    Target("Aetheryte")
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
    Target("Aetheryte")
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
    Target("Aetheryte")
    Interact()
    Movement(-405, 9.5, 128)
    ZoneTransitions()
    Movement(468.13, 232.79, 321.85)
    -- QuestChecker(MaelstromEnemiesLog1[10], 40, "MonsterNote", "Report to Thubyrgeim at the Arcanists' Guild.")
    Movement(224.32, 301.51, -142.16)
    Movement(229.20, 312.91, -235.02)
    Target("Aetheryte")
    Interact()
    Teleport("Limsa", "tp")
end

function MaelstromRank2()
    -- stuff goes here
end

-- ###################
-- # DUNGEON UNLOCKS #
-- ###################

-- can also probably use questionable once commands or ipc work better
-- needs updating once nodescanner works
function HalataliUnlock()
    if GetLevel() < 20 then
        Echo("You do not have the level 20 requirement.")
        return
    end

    if not IsQuestDone("Hallo Halatali") then
        Teleporter("Horizon", "tp") -- could also use vesper bay ticket but needs the teleporter function adjusting
        ZoneTransitions()
        Movement(-280.59, 15.26, -316.75) -- It gets stuck otherwise
        Movement(-308.26, 21.15, -343.13) -- It gets stuck otherwise
        Movement(-399.64, 23.00, -351.08) -- It gets stuck otherwise
        DoQuest("Hallo Halatali")
    else
        DoQuest("Hallo Halatali") -- This has the echo text inside
    end
end

-- Questionable does not support this yet, using alternative method
function TheSunkenTempleOfQarnUnlock()
    if GetLevel() < 35 then
        Echo("You do not have the level 35 requirement.")
        return
    end

    if not IsQuestDone("Braving New Depths") then
        Teleporter("Horizon", "tp") -- could also use vesper bay ticket but needs the teleporter function adjusting
        ZoneTransitions()
        Movement(-280.59, 15.26, -316.75) -- It gets stuck otherwise
        Movement(-308.26, 21.15, -343.13) -- It gets stuck otherwise
        Movement(-399.64, 23.00, -351.08) -- It gets stuck otherwise
        Movement(-471.06, 23.01, -354.81)
        Target("Nedrick Ironheart")
        Interact()
        yield("/pcall SelectIconString true 0")
        Sleep(0.5)
        yield("/pcall JournalAccept true 0")
        Sleep(0.5)
        Teleporter("Little Ala Mhigo", "tp")
        Movement(184.26, 13.79, -444.12)
        Target("Bibimu")
        Interact()
        --DoQuest("Braving New Depths")
    else
        DoQuest("Braving New Depths") -- This has the echo text inside
    end
end

-- Requires Storm Sergeant First Class
function DzemaelDarkholdUnlock()
    if GetMaelstromGCRank() < 7 or GetLevel() < 44 then
        Echo("You do not have the Storm Sergeant First Class rank or the level 44 requirements.")
        return
    end
    
    if not IsQuestDone("Shadows Uncast (Maelstrom)") then
        Teleporter("Limsa", "tp")
        ZoneTransitions()
        --Teleporter("Aftcastle", "li")
        yield("/li aftcastle")
        ZoneTransitions()
        DoQuest("Shadows Uncast (Maelstrom)")
    else
        DoQuest("Shadows Uncast (Maelstrom)") -- This has the echo text inside
    end
end

-- Questionable does not support this yet, using alternative method
-- Requires Chief Storm Sergeant
-- NEEDS doing
function TheAurumValeUnlock()
    if GetMaelstromGCRank() < 8 or GetLevel() < 47 then
        Echo("You do not have the Chief Storm Sergeant rank or the level 47 requirements.")
        return
    end

    if not IsQuestDone("Gilding the Bilious (Maelstrom)") then
        Teleporter("Limsa", "tp")
        ZoneTransitions()
        --Teleporter("Aftcastle", "li")
        yield("/li aftcastle")
        ZoneTransitions()
        DoQuest("Gilding the Bilious (Maelstrom)")
    else
        DoQuest("Gilding the Bilious (Maelstrom)") -- This has the echo text inside
    end
end

-- ###################
-- # HOUSING UNLOCKS #
-- ###################

function TheLavenderBedsUnlock()
    -- stuff goes here
end

function TheGobletUnlock()
    -- stuff goes here
end

function MistUnlock()
    -- stuff goes here
end

-- ###############
-- # MAIN SCRIPT #
-- ###############

function Main()
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

if MULTICHAR then
    for _, char in ipairs(character_list) do
        if GetCharacterName(true) == char then
            -- continue, no relogging needed
        else
            RelogCharacter(char)
            Sleep(7.5)
            LoginCheck()
        end
        repeat
            Sleep(0.1)
        until IsPlayerAvailable()
        Main()
    end
else
    Main()
end