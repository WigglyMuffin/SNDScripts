
-- This script is to be used on your main to automatically trade the right items to your alts as they show up
-- The alts should be running the improved tony script to come and pick stuff up at the location you've set in that script
-- It bases the trades off the order the character list was in so make sure it's all consistent
-- if you have everything configured right it's just start the script, go afk and you have eventually delivered all items to your alts

ProvisioningListNameToLoad = "ProvisioningList.lua"
SNDAltConfigFolder = "C:\\Users\\ff14lowres\\AppData\\Roaming\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"


-- ###################################
-- ###################################
-- ###################################
-- ###################################
-- ###################################
-- ###################################

DropboxSetItemQuantity(1, false, 0)
dofile(SNDAltConfigFolder..""..ProvisioningListNameToLoad)
local function Distance(x1, y1, z1, x2, y2, z2)
    if type(x1) ~= "number" then
        x1 = 0
    end
    if type(y1) ~= "number" then
        y1 = 0
    end
    if type(z1) ~= "number" then
        z1 = 0
    end
    if type(x2) ~= "number" then
        x2 = 0
    end
    if type(y2) ~= "number" then
        y2 = 0
    end
    if type(z2) ~= "number" then
        z2 = 0
    end
    zoobz = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 2)
    if type(zoobz) ~= "number" then
        zoobz = 0
    end
    --return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
    return zoobz
end

function Approach(CharToApproach)
    PathfindAndMoveTo(GetObjectRawXPos(CharToApproach), GetObjectRawYPos(CharToApproach), GetObjectRawZPos(CharToApproach), false)
end

-- ###################################
-- ########## MAIN SCRIPT ############
-- ###################################

for index, item in ipairs(ProvisioningList) do
    yield("/echo ############################")
    yield("/echo Waiting for "..item["CharNameClean"])
    yield("/echo ############################")
    while string.len(GetTargetName()) == 0 do
        yield('/target "' ..item["CharNameClean"]..'"')
        yield("/wait 1")
    end
    while Distance(
        GetPlayerRawXPos(),
        GetPlayerRawYPos(),
        GetPlayerRawZPos(),
        GetObjectRawXPos(item["CharNameClean"]),
        GetObjectRawYPos(item["CharNameClean"]),
        GetObjectRawZPos(item["CharNameClean"])
    ) > 3 do
        while string.len(GetTargetName()) == 0 do
            yield('/target "' ..item["CharNameClean"]..'"')
            yield("/wait 1")
        end
        if not PathfindInProgress() then
            yield("/echo ############################")
            yield("/echo Moving towards <t>")
            yield("/echo ############################")
            Approach(item["CharNameClean"])
            yield("/wait 2")
        end
    end
    repeat
        yield("/vnav stop")
    until not PathfindInProgress()
    yield("/echo ############################")
    yield("/echo Getting Ready to trade")
    yield("/echo ############################")
    yield("/wait 0.5")
    yield("/focustarget <t>")
    yield("/wait 0.5")
    DropboxSetItemQuantity(1, false, 1)
    yield("/wait 0.2")
    DropboxSetItemQuantity(tonumber(item["BotanistItemID"]), false, tonumber(item["BotanistItemQty"]))
    yield("/wait 0.2")
    DropboxSetItemQuantity(tonumber(item["MinerItemID"]), false, tonumber(item["MinerItemQty"]))
    yield("/wait 0.2")
    DropboxSetItemQuantity(tonumber(item["FisherItemID"]), false, tonumber(item["FisherItemQty"]))
    yield("/wait 1")
    yield("/echo ############################")
    yield("/echo Starting trade!")
    yield("/echo ############################")
    DropboxStart()
    yield("/wait 2")
    tradestatus = DropboxIsBusy()
    while tradestatus == true do
        tradestatus = DropboxIsBusy()
        LogInfo("[GCID] Currently trading...")
        yield("/wait 2")
    end
    yield("/echo ############################")
    yield("/echo Trading done")
    yield("/echo ############################")
    yield("/echo ############################")
    yield("/echo Cleaning up Dropbox")
    yield("/echo ############################")
    DropboxSetItemQuantity(tonumber(item["BotanistItemID"]), false, 0)
    yield("/wait 0.2")
    DropboxSetItemQuantity(tonumber(item["MinerItemID"]), false, 0)
    yield("/wait 0.2")
    DropboxSetItemQuantity(tonumber(item["FisherItemID"]), false, 0)
    yield("/echo ############################")
    yield("/echo Done!")
    yield("/echo Moving onto next char")
    yield("/echo ############################")
    yield("/wait 5")
end
DropboxSetItemQuantity(1, false, 0)
yield("/echo ############################")
yield("/echo Script finished")
yield("/echo ############################")
