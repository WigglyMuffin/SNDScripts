--[[
  __  __       _  _    ___                             
 |  \/  | __ _(_)| |  / _ \ _ __   ___ _ __   ___ _ __ 
 | |\/| |/ _` | || | | | | | '_ \ / _ \ '_ \ / _ \ '__|
 | |  | | (_| | || | | |_| | |_) |  __/ | | |  __/ |   
 |_|  |_|\__,_|_||_|  \___/| .__/ \___|_| |_|\___|_|   
                           |_|    
####################
##    Version     ##
##     1.0.1      ##
####################

-> 1.0.0: Initial release

-> 1.0.1: 
   - Fixed disabling Text Advance
   - Potentially fixed exiting out of the "LetterList" addon if stuck

####################################################
##                  Description                   ##
####################################################

https://github.com/WigglyMuffin/SNDScripts

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
        repeat
            yield(target_command)
            Sleep(0.1)
        until string.lower(GetTargetName()) == string.lower(target)
        return true
    else
        return false
    end
end

function Sleep(time)
    yield("/wait " .. tostring(time))
end

function Interact()
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting() and not GetCharacterCondition(26) and not IsMoving() or GetCharacterCondition(32)

    Dismount()
    Sleep(0.5)
    yield("/interact")

    repeat
        Sleep(0.1)
    until not IsPlayerCasting()
end

function Dismount()
    if TerritorySupportsMounting() then
        if GetCharacterCondition(4) then
            repeat
                yield("/mount")
                Sleep(0.1)
            until not GetCharacterCondition(4)
        end

        repeat
            Sleep(0.1)
        until IsPlayerAvailable() and not IsPlayerCasting()
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
            else
                return  -- Exit if no target is found
            end
        end

        Interact()

        repeat
            Sleep(0.1)
        until IsAddonReady("Talk")
        
        repeat
            yield("/callback Talk true 0")
            Sleep(0.1)
        until not IsAddonVisible("Talk")

        repeat
            Sleep(0.1)
        until IsAddonReady("LetterList")

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

            Sleep(0.1)
        until IsAddonVisible("SelectOk") and IsAddonVisible("LetterList")

        repeat
            Sleep(0.1)
        until IsAddonReady("LetterList") and string.match(GetNodeText("LetterList", 14, 13, 2), "Purchases & Rewards")
    end
end

local function SelectLetter()
    -- Check if "LetterList" addon is ready
    repeat
        Sleep(0.1)
    until IsAddonReady("LetterList")

    -- Selects the first letter in the letter list
    repeat
        yield("/callback LetterList true 0 0")
        Sleep(0.1)
    until IsAddonVisible("LetterViewer")

    -- If "LetterList" breaks, timeout to recover opening remaining letters
    local max_attempts = 10
    local attempts = 0

    repeat
        yield("/callback LetterList true 0 0")
        Sleep(0.1)
        attempts = attempts + 1

        if attempts >= max_attempts then
            repeat
                yield("/callback LetterList true -1")
            until not IsAddonVisible("LetterList")
            OpenLetterMenu()
        end

        Sleep(0.1)
    until IsAddonVisible("LetterViewer")
end

local function TakeLetterContents()
    -- Check if "LetterViewer" addon is ready
    repeat
        Sleep(0.1)
    until IsAddonReady("LetterViewer")

    -- If letter contains "Enclosed" then take items
    -- This also needs visibility check if it gets added here
    if string.match(GetNodeText("LetterViewer", 28), "Enclosed") and IsNodeVisible("LetterViewer", 1, 2, 5) then
        yield("/callback LetterViewer true 1")
    end
end

local function DeleteLetter()
    -- Check if "LetterViewer" addon is ready
    repeat
        Sleep(0.1)
    until IsAddonReady("LetterViewer")

    -- Track whether letter has been deleted
    local deleted_letter = false

    -- Check whether letter has text and node visibility, then delete the letter
    repeat
        if IsAddonReady("LetterViewer") and string.match(GetNodeText("LetterViewer", 28), ".+") then
            repeat
                yield("/callback LetterViewer true 2")
                Sleep(0.1)
            until IsAddonReady("SelectYesno") and string.match(GetNodeText("SelectYesno", 15), "Delete this letter?")
            yield("/callback SelectYesno true 0")
        end
        Sleep(0.1)
    until not IsAddonVisible("LetterViewer") and IsAddonVisible("LetterList")
end

local function RequestLetter()
    -- Check if "LetterList" addon is ready
    repeat
        Sleep(0.1)
    until IsAddonReady("LetterList")

    repeat
        yield("/callback LetterList true 3")
        Sleep(0.1)
    until IsAddonReady("SelectYesno") and string.match(GetNodeText("SelectYesno", 15), "Send a request to have recently acquired special")

    repeat
        yield("/callback SelectYesno true 0")
        Sleep(0.1)
    until not IsAddonVisible("SelectYesno") and IsAddonVisible("LetterList")
end

-- Flag whether wait for request has been triggered
wait_for_request_triggered = false  -- Improve this if GetMailQuantity gets added

function Main()
    OpenLetterMenu()

    local letter_quantity = string.match(GetNodeText("LetterList", 3), "(%d+)")

    for i = 1, letter_quantity do
        SelectLetter()
        TakeLetterContents()
        if IsAddonVisible("LetterViewer") then
            if IsNodeVisible("LetterViewer", 1, 14, 20) or IsNodeVisible("LetterViewer", 1, 2, 5) then
                Sleep(item_accept_wait_time)  -- Improve this if RGBA gets added
            end
        end
        DeleteLetter()
    end

    RequestLetter()

    -- Improve this if GetMailQuantity gets added
    if wait_for_request and not wait_for_request_triggered then
        yield("/callback LetterList true -1")
        wait_for_request_triggered = true
        Sleep(10.0)
        Main()
    end
end

Main()

if HasPlugin("YesAlready") then
    RestoreYesAlready()
end