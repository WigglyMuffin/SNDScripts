--[[
  __  __       _  _    ___                             
 |  \/  | __ _(_)| |  / _ \ _ __   ___ _ __   ___ _ __ 
 | |\/| |/ _` | || | | | | | '_ \ / _ \ '_ \ / _ \ '__|
 | |  | | (_| | || | | |_| | |_) |  __/ | | |  __/ |   
 |_|  |_|\__,_|_||_|  \___/| .__/ \___|_| |_|\___|_|   
                           |_|    
####################
##    Version     ##
##     1.0.2      ##
####################

-> 1.0.0: Initial release

-> 1.0.1: 
   - Fixed disabling Text Advance
   - Potentially fixed exiting out of the "LetterList" addon if stuck

-> 1.0.2:
    - Added checks to every repeat to prevent getting stuck
    - Increased Sleep() times to help with stability
    - Disabled RequestLetter() function as it tends to get stuck (for me at least)
    - Added re-enabling Text Advance

####################################################
##                  Description                   ##
####################################################

https://github.com/WigglyMuffin/SNDScripts
Tweaked by Friendly <3

This script automatically opens all of your characters mail
It will also request additional mail if the setting is enabled
There is no movement, so it is assumed you are outside somewhere that can view your mail

####################################################
##                  Requirements                  ##
####################################################

-> Something Need Doing (Expanded Edition) : https://puni.sh/api/repository/croizat

####################################################
##                    Settings                    ##
##################################################]]

local item_accept_wait_time = 4.5  -- Increase this if you have issues
local wait_for_request = true  -- Waits for requested mail. Options: true = will wait for requested mail, false = will not wait for requested mail

--[[################################################
##                  Script Start                  ##
##################################################]]

if HasPlugin("YesAlready") then
    PauseYesAlready()
end

if HasPlugin("TextAdvance") then
    yield("/at n")
end

function Target(target)
    if DoesObjectExist(target) then
        local target_command = "/target \"" .. target .. "\""
        attempts = 0
        maxattempts = 10
        repeat
            yield(target_command)
            attempts = attempts + 1
            Sleep(0.2)
        until string.lower(GetTargetName()) == string.lower(target) or attempts >= maxattempts
        return true
    else
        return false
    end
end

function Sleep(time)
    yield("/wait " .. tostring(time))
end

function Interact()
    attempts = 0
    maxattempts = 10
    repeat
        attempts = attempts + 1
        Sleep(0.21)
    until (IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26) and not IsMoving()) or GetCharacterCondition(32) or attempts >= maxattempts
    
    Dismount()
    Sleep(0.5)
    yield("/interact")
    Sleep(1)
    attempts = 0
    maxattempts = 10
    repeat
        Sleep(0.211)
        attempts = attempts + 1
    until not IsPlayerCasting() or attempts >= maxattempts
end

function Dismount()
    if TerritorySupportsMounting() then
        if GetCharacterCondition(4) then
            attempts = 0
            maxattempts = 10
            repeat
                yield("/mount")
                Sleep(0.212)
            until not GetCharacterCondition(4) or attempts >= maxattempts
        end

        attempts = 0
        maxattempts = 10
        repeat
            Sleep(0.213)
            attempts = attempts + 1
        until IsPlayerAvailable() and not IsPlayerCasting() or attempts >= maxattempts
    else
        -- do nothing
    end
end

local function OpenLetterMenu()
    if not IsAddonVisible("LetterList") then
        -- List of possible targets
        local targets = { "Delivery Moogle", "Regal Letter Box", "Moogle Letter Box" }

        -- Try to target each one in sequence
        for _, target_name in ipairs(targets) do
            if Target(target_name) then
                break  -- Exit the loop once a target is found
            end
        end

        Interact()

        attempts = 0
        maxattempts = 10
        repeat
            attempts = attempts + 1
            Sleep(0.214)
        until IsAddonReady("Talk") or attempts >= maxattempts
        
        attempts = 0
        maxattempts = 10
        repeat
            yield("/callback Talk true 0")
            attempts = attempts + 1
            Sleep(0.215)
        until not IsAddonVisible("Talk") or attempts >= maxattempts

        attempts = 0
        maxattempts = 10
        repeat
            attempts = attempts + 1
            Sleep(0.216)
        until IsAddonReady("LetterList") or attempts >= maxattempts

        -- Handle the "SelectOk" window with a check to prevent getting stuck

        local max_attempts = 10
        local attempts = 0
        repeat
            if IsAddonReady("SelectOk") and string.match(GetNodeText("SelectOk", 3), "You cannot carry any more campaign") then
                yield("/callback SelectOk true 0")
                break
            end
            attempts = attempts + 1

            if attempts >= max_attempts then
                break
            end
            Sleep(0.217)
        until IsAddonVisible("SelectOk") and IsAddonVisible("LetterList") or attempts >= maxattempts
        attempts = 0
        maxattempts = 10
        repeat
            Sleep(0.218)
            attempts = attempts + 1
        until IsAddonReady("LetterList") and string.match(GetNodeText("LetterList", 14, 13, 2), "Purchases & Rewards") or attempts >= maxattempts
    end
end

local function SelectLetter()
    -- Check if "LetterList" addon is ready
    attempts = 0
    maxattempts = 10
    repeat
        Sleep(0.219)
        attempts = attempts + 1
    until IsAddonReady("LetterList") or attempts >= maxattempts

    -- Selects the first letter in the letter list
    attempts = 0
    maxattempts = 10
    repeat
        yield("/callback LetterList true 0 0")
        Sleep(0.22)
        attempts = attempts + 1
    until IsAddonVisible("LetterViewer") or attempts >= maxattempts

    -- If "LetterList" breaks, timeout to recover opening remaining letters

    local max_attempts = 10
    local attempts = 0
    repeat
        yield("/callback LetterList true 0 0")
        Sleep(0.221)
        attempts = attempts + 1

        if attempts >= max_attempts then
            attempts = 0
            maxattempts = 10
            repeat
                yield("/callback LetterList true -1")
                attempts = attempts + 1
            until not IsAddonVisible("LetterList") or attempts >= maxattempts
            OpenLetterMenu()
            return
        end

        Sleep(0.222)
    until IsAddonVisible("LetterViewer") or attempts >= maxattempts
end

local function TakeLetterContents()

    -- Check if "LetterViewer" addon is ready
    attempts = 0
    maxattempts = 10
    repeat
        Sleep(0.223)
        attempts = attempts + 1
    until IsAddonReady("LetterViewer") or attempts >= maxattempts

    -- If letter contains "Enclosed" then take items
    -- This also needs visibility check if it gets added here
    --if string.match(GetNodeText("LetterViewer", 28), "Enclosed") and IsNodeVisible("LetterViewer", 1, 2, 5) then
        yield("/callback LetterViewer true 1")
        yield("/callback LetterViewer true 1")
        yield("/callback LetterViewer true 1")
    --end
    Sleep(1)
end

local function DeleteLetter()

    -- Check if "LetterViewer" addon is ready
    attempts = 0
    maxattempts = 10
    repeat
        Sleep(0.224)
        attempts = attempts + 1
    until IsAddonReady("LetterViewer") or attempts >= maxattempts

    -- Track whether letter has been deleted
    local deleted_letter = false

    -- Check whether letter has text and node visibility, then delete the letter
    attempts = 0
    maxattempts = 10
    repeat
        if IsAddonReady("LetterViewer") and string.match(GetNodeText("LetterViewer", 28), ".+") then
            attempts = 0
            maxattempts = 10
            repeat
                yield("/callback LetterViewer true 2")
                Sleep(0.225)
                attempts = attempts + 1
            until IsAddonReady("SelectYesno") and string.match(GetNodeText("SelectYesno", 15), "Delete this letter?") or attempts >= maxattempts
            yield("/callback SelectYesno true 0")
        end
        Sleep(0.226)
        attempts = attempts + 1
    until (not IsAddonVisible("LetterViewer") and IsAddonVisible("LetterList")) or attempts >= maxattempts
end

local function RequestLetter()

    -- Check if "LetterList" addon is ready
    attempts = 0
    maxattempts = 10
    repeat
        Sleep(0.227)
        attempts = attempts + 1
    until IsAddonReady("LetterList") or attempts >= maxattempts

    attempts = 0
    maxattempts = 10
    repeat
        yield("/callback LetterList true 3")
        Sleep(0.228)
        attempts = attempts + 1
    until IsAddonReady("SelectYesno") and string.match(GetNodeText("SelectYesno", 15), "Send a request to have recently acquired special") or attempts >= maxattempts

    attempts = 0
    maxattempts = 10
    repeat
        attempts = attempts + 1
        yield("/callback SelectYesno true 0")
        Sleep(0.229)
    until not IsAddonVisible("SelectYesno") and IsAddonVisible("LetterList") or attempts >= maxattempts
end

-- Flag whether wait for request has been triggered
wait_for_request_triggered = false  -- Improve this if GetMailQuantity gets added

function Main()
    OpenLetterMenu()

    local letter_quantity = string.match(GetNodeText("LetterList", 3), "(%d+)")

    for i = 1, letter_quantity do
        SelectLetter()
        Sleep(1)
        TakeLetterContents()
        if IsAddonVisible("LetterViewer") then
            if IsNodeVisible("LetterViewer", 1, 14, 20) or IsNodeVisible("LetterViewer", 1, 2, 5) then
                Sleep(item_accept_wait_time)  -- Improve this if RGBA gets added
            end
        end
        DeleteLetter()
    end

--    RequestLetter()

    -- Improve this if GetMailQuantity gets added
    if wait_for_request and not wait_for_request_triggered then
        yield("/callback LetterList true -1")
        wait_for_request_triggered = true
        Sleep(1.0)
        Main()
    end
end

Main()
Sleep(1)
if IsAddonVisible("LetterList") then
    attempts = 0
    maxattempts = 10
    repeat
        attempts = attempts + 1
        yield("/callback LetterList true -1")
    until not IsAddonVisible("LetterList") or attempts >= maxattempts
end    

if HasPlugin("YesAlready") then
    RestoreYesAlready()
end

if HasPlugin("TextAdvance") then
    yield("/at y")
end
