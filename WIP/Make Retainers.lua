--[[
############################################################
##                        RETAINER                        ##
##                         MAKER                          ##
############################################################


####################
##    Version     ##
##     1.0.0      ##
####################

-> 1.0.0: Initial release

####################################################
##                  Description                   ##
####################################################

This script rotates between provided characters and creates retainers for them using set settings, worth noting it makes all retainers in limsa
Optionally also does the venture quest afterwards, or if you want you can use this script to finish venture quests on characters with retainers already

There is a list generator you can use for this in the Tools section of the repo, it will give you a quick base to edit.

####################################################
##                  Requirements                  ##
####################################################

-> Teleporter : In the default first party dalamud repository
-> Pandora - https://love.puni.sh/ment.json
-> Questionable - https://plugins.carvel.li/
-> Something Need Doing (Expanded Edition) - https://puni.sh/api/repository/croizat
-> Textadvance - https://raw.githubusercontent.com/NightmareXIV/MyDalamudPlugins/main/pluginmaster.json
-> Rotation Solver Reborn - https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json
-> Vnavmesh - https://puni.sh/api/repository/veyn
-> Boss Mod - https://puni.sh/api/repository/veyn OR BossMod Reborn - https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json

####################################################
##                    Settings                    ##
##################################################]]

-- Keep this on unless you intend on using the script to only finish the venture quests
MAKE_RETAINERS = true

-- Does the venture quest
DO_VENTURE_QUEST = true

-- This is where you place your character list with configured retainers, you can generate a template list using the list generator provided in the Tools folder of this repo.
-- It supports any job that a retainer can take, abbreviated.
local chars = {
    {
        ["Character Name"] = "First Last@Server",
        ["Retainers"] = {
            {"MIN", 1},
            {"BTN", 1}
        }
    },
    {
        ["Character Name"] = "Last First@Server",
        ["Retainers"] = {
            {"ARC", 1},
            {"MRD", 1}
        }
    },
}


--[[################################################
##                  Script Start                  ##
##################################################]]

snd_config_folder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
load_functions_file_location = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(load_functions_file_location)
LoadFunctions()
LoadFileCheck()

if not CheckPluginsEnabled() then
    return -- Stops script as plugins not available
end

if HasPlugin("YesAlready") then
    PauseYesAlready()
end

-- Lists of valid retainer jobs and the location of the item they need to buy in the shop
local valid_jobs = {
    GLA = { class = "DoW", store_location = 1, itemID = 1601, retainer_job_positon = 0},     -- Weathered Shortsword
    PGL = { class = "DoW", store_location = 10, itemID = 1680, retainer_job_positon = 3},    -- Weathered Hora
    MRD = { class = "DoW", store_location = 4, itemID = 1749, retainer_job_positon = 1},     -- Weathered War Axe
    LNC = { class = "DoW", store_location = 7, itemID = 1819, retainer_job_positon = 4},     -- Weathered Spear
    ROG = { class = "DoW", store_location = 13, itemID = 7952, retainer_job_positon = 5},    -- Weathered Daggers
    ARC = { class = "DoW", store_location = 16, itemID = 1889, retainer_job_positon = 6},    -- Weathered Shortbow
    CNJ = { class = "DoM", store_location = 11, itemID = 1995, retainer_job_positon = 2},    -- Weathered Cane
    THM = { class = "DoM", store_location = 1, itemID = 2055, retainer_job_positon = 7},     -- Weathered Scepter
    ACN = { class = "DoM", store_location = 6, itemID = 2142, retainer_job_positon = 8},     -- Weathered Grimoire
    MIN = { class = "DoL", store_location = 1, itemID = 2519, retainer_job_positon = 9},     -- Weathered Pickaxe
    BOT = { class = "DoL", store_location = 3, itemID = 2545, retainer_job_positon = 10},     -- Weathered Hatchet
    FSH = { class = "DoL", store_location = 5, itemID = 2571, retainer_job_positon = 11},     -- Weathered Fishing Rod
}

-- Function used to find details about the job in the valid_jobs list
local function GetJobDetails(job_to_find)
    local details = valid_jobs[job_to_find]
    if details then
        return details
    else
        return nil, nil, nil  -- Return nils if the job is not found
    end
end

function BuyRetainerJobItem(job, item_amount)
    local job_details = GetJobDetails(job)
    if not job_details then
        Echo("Job is not in any list?")
        return
    end
    -- Move to and target the right vendor for the class you're getting items for
    if job_details.class == "DoW" or job_details.class == "DoM" then
        Movement(-236.34, 16.20, 40.77)
        Target("Faezghim")
    else -- since it's not the two others the only option left is DoL
        Movement(-245.87, 16.20, 40.59)
        Target("Syneyhil")
    end
    Sleep(0.5)
    Interact()
    repeat
        Sleep(0.1)
    until IsAddonReady("SelectIconString")
    if job_details.class == "DoW" then -- Only need to check for DoW since if it's not that it's always DoM or DoL
        yield("/pcall SelectIconString true 0")
    else
        yield("/pcall SelectIconString true 1")
    end
    repeat
        Sleep(0.1)
    until IsAddonReady("SelectString")
    yield("/pcall SelectString true 0")
    repeat
        Sleep(0.1)
    until IsAddonReady("Shop")
    BuyFromStore(job_details.store_location, item_amount)
    yield("/pcall Shop true -1")
    repeat
        Sleep(0.1)
    until not IsAddonVisible("Shop")
    yield("/pcall SelectString true 5")
    repeat
        Sleep(0.1)
    until not IsAddonVisible("SelectString") and IsPlayerAvailable()
end

function CreateRetainerName()
    math.randomseed(os.time() + os.clock() * 100000)

    -- Prefixes 
    local prefixes = {
        "Ari", "Ela", "Luna", "Mira", "Ser", "Tala", "Cala", "Vira", "Zara", "Rina", 
        "Fae", "Syl", "Ilia", "Alia", "Bela", "Cora", "Del", "Eli", "Fira", "Lyra", 
        "Isla", "Nora", "Eira", "Thal", "Vala", "Yara", "Sora", "Rhea", "Iona", 
        "Ama", "Nyla", "Syla", "Oria", "Shira", "Asha", "Juna", "Mellia", "Fina"
    }

    -- Syllables
    local middle_syllables = {
        "la", "ra", "bel", "wen", "rin", "th", "ni", "sol", "dra", "nor", "el", 
        "ara", "lyn", "mir", "ven", "ial", "sil", "dar", "ria", "sha", "thys", 
        "sen", "wyn", "isa", "lys", "iel", "ira", "wen", "reth", "vel", "zia"
    }

    -- Suffixes
    local suffixes = {
        "na", "lia", "ra", "elle", "wyn", "a", "ine", "ara", "essa", "ina", "ora", 
        "ira", "ria", "tha", "yn", "aya", "era", "sia", "ia", "cia", "issa", "rielle", 
        "vina", "ona", "lina", "lora", "elle", "itha", "dora", "etta", "sha"
    }

    local function EndsWithVowel(s)
        return s:match("[aeiouAEIOU]$")
    end

    -- Check if a string starts with a vowel
    local function StartsWithVowel(s)
        return s:match("^[aeiouAEIOU]")
    end

    -- Check for forbidden character combinations in the name
    local function HasForbiddenCombo(name)
        local forbidden_combinations = { "kk", "zz", "xx", "yy", "thk" }
        for _, combo in ipairs(forbidden_combinations) do
            if name:find(combo) then
                return true
            end
            Sleep(0.0001)
        end
        return false
    end

    -- Function to ensure natural flow
    local function IsValidSyllableTransition(last_part, next_part)
        if EndsWithVowel(last_part) and StartsWithVowel(next_part) then
            return false
        end
        return true
    end

    -- Function to create a random female fantasy name
    local function CreateRetainerName(max_length)
        local name = ""
        local attempts = 0

        repeat
            -- Decide on how long the name should be (2 to 4 syllables)
            local syllableCount = math.random(2, 4)

            -- Start with a random prefix
            local prefix = prefixes[math.random(#prefixes)]
            name = prefix

            -- Add middle syllables based on the length decision
            for i = 1, syllableCount - 1 do
                local middle = middle_syllables[math.random(#middle_syllables)]
                if IsValidSyllableTransition(name, middle) and #name + #middle < max_length - 3 then
                    name = name .. middle
                end
                Sleep(0.0001)
            end

            -- Add a random suffix
            local suffix = suffixes[math.random(#suffixes)]
            if IsValidSyllableTransition(name, suffix) and #name + #suffix < maxLength then
                name = name .. suffix
            end

            attempts = attempts + 1
        until not HasForbiddenCombo(name) or attempts > 10 -- Retry if forbidden combo found

        -- Capitalize the first letter
        name = name:gsub("^%l", string.upper)
        return name
    end

    local retainerName = CreateRetainerName(19)
    return retainerName
end

function CreateRetainer()
    Target("Frydwyb")
    Interact()
    repeat
        Sleep(0.1)
    until IsAddonReady("SelectString")
    yield("/pcall SelectString true 0")
    repeat
        Sleep(0.1)
    until IsAddonReady("SelectYesno") or IsPlayerAvailable()
    if IsPlayerAvailable() then
        Echo("No more retainers can be made")
        return
    end
    yield("/pcall SelectYesno true 0")
    repeat
        Sleep(0.1)
    until IsAddonReady("_CharaMakeTitle")
    Sleep(1) -- just extra safety

    -- Create and randomize the miqo
    yield("/pcall _CharaMakeProgress true 0 13 0 Miqo'te 2")
    yield("/pcall _CharaMakeProgress true -13 -1")
    yield("/pcall _CharaMakeProgress true 0 13 0 Miqo'te 0")
    Sleep(0.5)
    yield("/pcall _CharaMakeFeature true -9 0")
    repeat
        Sleep(0.1)
    until IsAddonReady("SelectYesno")
    yield("/pcall SelectYesno true 1")
    repeat
        Sleep(0.1)
    until not IsAddonVisible("SelectYesno")
    repeat
        Sleep(0.1)
    until IsAddonReady("SelectYesno")
    yield("/pcall SelectYesno true 0")
    repeat
        Sleep(0.1)
    until IsAddonReady("SelectString")
    -- give it a carefree attitude
    yield("/pcall SelectString true 3")
    repeat
        Sleep(0.1)
    until IsAddonReady("SelectYesno")
    yield("/pcall SelectYesno true 0")
    repeat
        Sleep(0.1)
    until IsAddonReady("InputString")

    -- Name the miqo
    local retainer_named = false
    while not retainer_named do
        local retainer_name = CreateRetainerName()
        Echo("Attempting to name retainer " .. retainer_name)
        yield("/pcall InputString true 0 "..retainer_name.." ")
        repeat
            Sleep(0.1)
        until IsAddonReady("SelectYesno")
        yield("/pcall SelectYesno true 0")
        repeat
            Sleep(0.1)
        until IsAddonReady("InputString") or IsPlayerAvailable()
        if IsPlayerAvailable() then
            retainer_named = true
            Echo("Successfully named retainer " .. retainer_name)
        else
            retainer_named = false
            Echo("Failed to name retainer " .. retainer_name .. ", trying another name")
        end
    end
end

function SetRetainerJobAndEquipItem(retainers)
    -- A list which i can reference to find which button to press in the ui to select X job
    Movement(-125.57, 18.00, 21.17)
    Target("Summoning Bell")
    Interact()
    repeat
        Sleep(0.1)
    until IsAddonVisible("RetainerList")
    -- Find how many total retainers we're going over
    local total_retainers = 0
    for j = 1, #retainers do
        local retainer = retainers[j]
        local retainer_amount = retainer[2]
        total_retainers = total_retainers + retainer_amount
        Sleep(0.0001)
    end
    -- Loop over each retainer and set their weapons
    for j = 0, total_retainers - 1 do
        local retainer = retainers[j]
        local retainer_job = retainer[1]
        local retainer_amount = retainer[2]
        local job_details = GetJobDetails(retainer_job)
        if not job_details then
            Echo("Something went wrong when trying to get job_details while trying to set retainer classes")
            return
        end
        for k = 1, retainer_amount do
            local retainer_name_text = GetNodeText("RetainerList", 2, k, 13)
            if string.len(retainer_name_text) > 1 then -- check if there's actually a retainer in that slot
                yield("/pcall RetainerList true 2 " .. j)
                repeat
                    Sleep(0.1)
                until IsAddonReady("SelectString")
                yield("/pcall SelectString true " .. job_details.retainer_job_positon)
                repeat
                    Sleep(0.1)
                until IsAddonReady("SelectYesno")
                yield("/pcall SelectYesno true 0")
                repeat
                    Sleep(0.1)
                until IsAddonReady("SelectString")
                yield("/pcall SelectString true 6")
                repeat
                    Sleep(0.1)
                until IsAddonReady("RetainerCharacter")
                -- make sure to move the right item, checks every inventory
                MoveItemToContainer(job_details.itemID, 0, 11000)
                Sleep(0.2)
                MoveItemToContainer(job_details.itemID, 1, 11000)
                Sleep(0.2)
                MoveItemToContainer(job_details.itemID, 3, 11000)
                Sleep(0.2)
                MoveItemToContainer(job_details.itemID, 4, 11000)
                Sleep(0.2)
                MoveItemToContainer(job_details.itemID, 3500, 11000)
                Sleep(0.5)
                yield("/pcall RetainerCharacter true -1")
                repeat
                    Sleep(0.1)
                until IsAddonReady("SelectString")
                yield("/pcall SelectString true 9")
                repeat
                    Sleep(0.1)
                until IsAddonReady("RetainerList")
            else
                Echo("No retainer found")
            end
        end
        Sleep(0.0001)
    end
    yield("/pcall RetainerList true -1")
    repeat
        Sleep(0.1)
    until IsPlayerAvailable()
end

for i = 1, #chars do
    local character = chars[i]
    local char_name = character["Character Name"]
    local retainers = character["Retainers"]
    if GetCharacterName(true) == char_name then
        -- Continue, no relogging needed
    else
        LogInfo("[MRET] Logging into character: "..char_name)
        RelogCharacter(char_name)
        Sleep(23.0)
        LoginCheck()
        LogInfo("[MRET] Logged in successfully")
    end
    yield("/at e")
    if MAKE_RETAINERS then
        -- Teleport and move to the retainer lady in limsa
        Teleporter("Limsa", "tp")
        Movement(-142.93, 18.02, 20.52)
        Movement(-146.17, 18.21, 16.89)
        -- Attempt to create as many retainers as specified
        for j = 1, #retainers do
            local retainer = retainers[j]
            local retainer_amount = retainer[2]
            for k = 1, retainer_amount do
                CreateRetainer()
            end
            Sleep(0.0001)
        end
        -- Now attempt to buy all the items needed for the specified jobs
        for j = 1, #retainers do
            local retainer = retainers[j]
            local retainer_job = retainer[1]
            local retainer_amount = retainer[2]
            BuyRetainerJobItem(retainer_job, retainer_amount)
            Sleep(0.0001)
        end
    end
    -- Do the venture quest
    if DO_VENTURE_QUEST then
        Teleporter("Limsa", "tp")
        -- Let questionable do the venture quest
        DoQuest(1433)
        repeat
            Sleep(0.1)
        until IsQuestComplete(66969)
        yield("/qst stop")
    end
    -- Set job and equip the right items
    if MAKE_RETAINERS then
        SetRetainerJobAndEquipItem(retainers)
    end
end

if HasPlugin("YesAlready") then
    RestoreYesAlready()
end