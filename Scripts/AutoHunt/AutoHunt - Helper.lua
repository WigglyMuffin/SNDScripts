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
    if GetDutyInfoText(2) == "Clear the feasting hall: 0/1" and GetTargetName() == "All-seeing Eye" then
        local Crystal_Coords = {
            [1] = {
                ["Coords"] = "17.4 -13.8 86.7"
            },
            [2] = {
                ["Coords"] = "74.6 -13.4 83.0"
            },
            [3] = {
                ["Coords"] = "48.8 -11.6 116"
            },
            [4] = {
                ["Coords"] = "15.3 -9.5 46.7"
            }
        }
        for i=1, #Crystal_Coords do  --just taking the boss to the crystals
            for i=1, 50 do
                yield("/vnav moveto "..Crystal_Coords[i]["Coords"])
                Sleep(2.00819)
                repeat
                    Sleep(0.20824)
                until GetToastNodeText(2, 3) == "The power of the crystal begins to dim." or not DoesObjectExist("All-seeing Eye")
            end
        end
    end
    local duty_timer = GetDutyTimer()
    if duty_timer and duty_timer < 4200 then
        yield("/ad stop")
        LeaveDuty()
    end
    Sleep(5)
until forever
