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
    while not IsPlayerAvailable() do
        Sleep(1.0534)
    end
                local Terminal_List = {
                [1] = {
                    ["Name"] = "III",
                    ["Coords"] = "124 -13.8 123.4"
                },
                [2] = {
                    ["Name"] = "IV",
                    ["Coords"] = "140.75 -12 113.2"
                },
                [3] = {
                    ["Name"] = "IX",
                    ["Coords"] = "-14.9 -21 -143.97"
                },
                [4] = {
                    ["Name"] = "VIII",
                    ["Coords"] = "-16.32 -17.3 -177.65"
                }
            }
            for i=1, #Terminal_List do
                if GetToastNodeText(2, 3) == "Magitek terminal "..Terminal_List[i]["Name"].." begins counting down." then
                    local counter = 0
                    repeat
                        ClearTarget()
                        yield("/vnav moveto "..Terminal_List[i]["Coords"])
                        Sleep(0.22)
                        counter = counter+1
                    until GetToastNodeText(2, 3) == "Magitek terminal "..Terminal_List[i]["Name"].."'s countdown completes." or counter > 200
                end
            end
    if duty_timer and duty_timer < 4950 and GetDutyInfoText(2) == "Clear the feasting hall: 1/1" and GetToastNodeText(2, 3) == "Magitek terminal "..Terminal_List[3]["Name"].."'s countdown completes." then
        yield("/vnav moveto "..Terminal_List[4]["Coords"])
    elseif duty_timer and duty_timer < 5010 and GetDutyInfoText(2) == "Clear the feasting hall: 1/1" then
        yield("/vnav moveto "..Terminal_List[3]["Coords"])
    elseif GetDutyInfoText(2) == "Clear the feasting hall: 0/1" and GetTargetName() == "All-seeing Eye" then
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
            repeat
                yield("/vnav moveto "..Crystal_Coords[i]["Coords"])
                Sleep(1.0824)
                if HasStatus("Crystal Veil") then
                    break
                end
            until not HasStatus("Crystal Veil") or not DoesObjectExist("All-seeing Eye")
        end
    elseif duty_timer and duty_timer < 5190 and GetDutyInfoText(1) == "Open the grand hall gate: 0/1" and GetToastNodeText(2, 3) == "Magitek terminal "..Terminal_List[1]["Name"].."'s countdown completes." then
        yield("/vnav moveto "..Terminal_List[2]["Coords"])
    elseif duty_timer and duty_timer < 5250 and GetDutyInfoText(1) == "Open the grand hall gate: 0/1" then
        yield("/vnav moveto "..Terminal_List[1]["Coords"])
    end
    local duty_timer = GetDutyTimer()
    if duty_timer and duty_timer < 4200 then
        yield("/ad stop")
        LeaveDuty()
    end
    Sleep(2)
until forever
