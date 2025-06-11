--This needs to go on the party_member that helps you do the dungeons
--Needs to be manually stopped when you're done

function Sleep(time)
    yield("/wait " .. tostring(time))
end

function GetDutyInfoText(pos)
    local function GetDutyInfoStartingNode()
        for i=8, 12 do
            if IsNodeVisible("_ToDoList", 1, (70013-i)) then
                return (39-2*i)
            end
        end
        return 13
    end
    local starting_node = GetDutyInfoStartingNode()
    if not pos then
        return
    end
    local text = GetNodeText("_ToDoList", (starting_node+pos-1), 3)
    return text
end

function LeaveDuty()
    while GetCharacterCondition(34) do
        if IsAddonReady("SelectYesno") then
            yield("/callback SelectYesno true 0")
        elseif IsAddonVisible("ContentsFinderMenu") then
            yield("/callback ContentsFinderMenu true 0")
        else
            yield("/dutyfinder")
        end
        Sleep(0.1)
    end
end

function GetDutyTimer()
    if not GetCharacterCondition(34) and not GetCharacterCondition(56) then
        LogInfo("[VAC] GetDutyTimer(): You're not in a duty.")
        return
    end
    local function GetDutyTimerTextNode()
        for i=8, 12 do
            if IsNodeVisible("_ToDoList", 1, (70013-i)) then
                
                return (23-i)
            end
        end
        return 10
    end
    local duty_timer_node = GetDutyTimerTextNode()
    local duty_timer_text = GetNodeText("_ToDoList", duty_timer_node, 8)
    local minutes, seconds = duty_timer_text:match("^(%d+):(%d+)$")
    local duty_timer_seconds = tonumber(minutes) * 60 + tonumber(seconds)
    return duty_timer_seconds
end

repeat
    if GetTargetName() == "All-seeing Eye" and GetDutyInfoText(2) == "Clear the feasting hall: 0/1" then
        local party_member = GetNearbyObjectNames(30, 1)[1]
        yield("/vnav moveto "..GetPlayerRawXPos(party_member).." "..GetPlayerRawYPos(party_member).." "..GetPlayerRawZPos(party_member))
    end
    local duty_timer = GetDutyTimer()
    if duty_timer and duty_timer < 4200 then
        yield("/ad stop")
        LeaveDuty()
    end
    Sleep(5)
until forever