--##########################################
--   CONFIGS
--##########################################









--##########################################
--   DON'T TOUCH ANYTHING BELOW HERE 
--   UNLESS YOU KNOW WHAT YOU'RE DOING
--##########################################

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
function QuestNPC(DialogueType, DialogueConfirm, DialogueOption) -- NPC interaction handler, only supports one dialogue option for now. DialogueOption optional.
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

-- usage: Teleporter("Limsa", "tp")
function Teleporter(Location, TP_Kind) -- Teleporter handler
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26)
    yield("/" .. TP_Kind .. " " .. Location)
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable()
end

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
--  DOL STUFF
--##############

function DOL()
    OpenTimers()
    Teleporter("Ul'dah", "tp")
    ZoneTransitions()
    Teleporter("mb", "li")
    ZoneTransitions()
    MarketBoardChecker() -- should probably add auto buying here or something
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    Teleporter("Aftcastle", "li")
    ZoneTransitions()
    yield("/vnav moveto 93.00 40.27 75.60")
    VNavChecker()
    yield('/target "Storm Personnel Officer"')
    QuestNPCSingle("SelectString", true, 0)
    QuestNPCSingle("GrandCompanySupplyList", true, "0 1")
    QuestNPCSingle("GrandCompanySupplyList", true, "1 0")
    QuestNPCSingle("Request", true, 0)
    QuestNPCSingle("GrandCompanySupplyList", true, "1 0")
    QuestNPCSingle("Request", true, 0)
    QuestNPCSingle("GrandCompanySupplyList", true, "1 0")
    QuestNPCSingle("Request", true, 0)
    QuestNPCSingle("GrandCompanySupplyList", true, -1)
    QuestNPCSingle("SelectString", true, 3)
    LogOut()
end

--##########################################
--  MAIN SCRIPT
--##########################################
function main()
    DOL()
end

main()
