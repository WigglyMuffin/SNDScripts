--This needs to go on the party_member that helps you do the dungeons
--Needs to be manually stopped when you're done

function Sleep(time)
    yield("/wait " .. tostring(time))
end

function TargetNearestObject(target_name, objectKind, radius)
    local smallest_distance = math.huge
    local closest_target
    local objectKind = objectKind or 0                                                               -- Set objectkind to 0 so GetNearbyObjectNames pulls everything nearby
    local radius = radius or 0
    local nearby_objects = GetNearbyObjectNames(radius ^ 2, objectKind)                              -- Pull all nearby objects/enemies into a list
    if nearby_objects.Count > 0 then                                                                 -- Starts a loop if there's more than 0 nearby objects
        for i = 0, nearby_objects.Count - 1 do
            if nearby_objects.Count > 20 then                                                        --This is to prevent crashes, may want to comment it if it works anyway
                Sleep(0.0001)
            end                                                                                      -- Loops until no more objects
            yield("/target " .. nearby_objects[i])
            if not GetTargetName() or nearby_objects[i] ~= GetTargetName() then                      -- If target name is nil, skip it
            elseif GetDistanceToTarget() < smallest_distance and GetTargetName() == target_name then -- If object matches the target_name and the distance to target is smaller than the current smallest_distance, proceed
                smallest_distance = GetDistanceToTarget()
                closest_target = GetTargetName()
            elseif not target_name and GetDistanceToTarget() < smallest_distance then                                                              -- If there is no target specified, return closest anything
                smallest_distance = GetDistanceToTarget()
                closest_target = GetTargetName()
            end
        end
        ClearTarget()
        if closest_target then yield("/target " .. closest_target) end -- after the loop ends it targets the closest enemy
    end
    return closest_target
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
            if DoesObjectExist("Magitek Transporter") then --try to move if AD path is running ahead
                TargetNearestObject("Magitek Transporter", 7, 10)
                if GetTargetName() == "Magitek Transporter" and current_x == GetPlayerRawXPos() and current_z == GetPlayerRawZPos() then
                    yield("/ad pause")
                    yield("/vnav moveto " .. GetTargetRawXPos() .. " " .. GetTargetRawYPos() .. " " .. GetTargetRawZPos())
                    repeat
                        Sleep(0.1)
                    until GetDistanceToTarget() < 2
                    yield("/interact")
                    Sleep(0.5)
                    while IsAddonReady("SelectYesno") do
                        yield("/callback SelectYesno true 0")
                        Sleep(0.0956)
                    end
                    yield("/ad resume")
                end
            end
    local duty_timer = GetDutyTimer()
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
                    ["Coords"] = "-16.22 -17.3 -177.55"
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
    elseif duty_timer and duty_timer < 5010 and GetDutyInfoText(2) == "Clear the feasting hall: 1/1" and not GetDutyInfoText(4) == "Defeat Batraal: 0/1" then
        yield("/vnav moveto "..Terminal_List[3]["Coords"])
    elseif GetDutyInfoText(2) == "Clear the feasting hall: 0/1" and GetTargetName() == "All-seeing Eye" then
        local Crystal_Coords = {
            [1] = {
                ["x"] = 74.6,
                ["y"] = -13.4,
                ["z"] = 83.0
            },
            [2] = {
                ["x"] = 21.6,
                ["y"] = -14.2,
                ["z"] = 90.9
            },
            [3] = {
                ["x"] = 48.8,
                ["y"] = -11.6,
                ["z"] = 116.0
            },
            [4] = {
                ["x"] = 15.3,
                ["y"] = -9.5,
                ["z"] = 46.7
            }
        }
        yield("/ad pause")
        local crystal = 1
        while DoesObjectExist("All-seeing Eye") do
            yield("/vnav moveto "..Crystal_Coords[crystal]["x"].." "..Crystal_Coords[crystal]["y"].." "..Crystal_Coords[crystal]["z"])
            if not HasStatus("Crystal Veil") and current_x and current_z and current_x^2 + current_z^2 < 1 then
                crystal=crystal+1
                if crystal == 5 then
                    crystal = 1
                end
            else
                while TargetHasStatus(325)==true and HasStatus("Crystal Veil") do
                    yield("/vnav moveto "..Crystal_Coords[crystal]["x"].." "..Crystal_Coords[crystal]["y"].." "..Crystal_Coords[crystal]["z"])
                    Sleep(1.34)
                end
            end
            Sleep(1.37)
        end
        yield("/ad resume")
    elseif GetDutyInfoText(1) == "Open the grand hall gate: 0/1" and (GetToastNodeText(2, 3) == "Magitek terminal "..Terminal_List[1]["Name"].."'s countdown completes." or (duty_timer and duty_timer < 5220)) then
        yield("/vnav moveto "..Terminal_List[2]["Coords"])
    elseif duty_timer and duty_timer < 5280 and GetDutyInfoText(1) == "Open the grand hall gate: 0/1" then
        yield("/vnav moveto "..Terminal_List[1]["Coords"])
    end
    if duty_timer and duty_timer < 4200 then
        yield("/ad stop")
        LeaveDuty()
    end
    current_x = GetPlayerRawXPos()
    current_z = GetPlayerRawZPos()
    Sleep(2)
until forever
