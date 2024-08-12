
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
LoadFunctionsFileLocation = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(LoadFunctionsFileLocation)
LoadFunctions()
LoadFileCheck()

dofile(SNDAltConfigFolder..""..ProvisioningListNameToLoad)

-- ###################################
-- ########## MAIN SCRIPT ############
-- ###################################
DropboxSetItemQuantity(1, false, 0)

for index, item in ipairs(ProvisioningList) do
    if item["CharHomeWorld"] == nil then
        LogInfo("Item doesn't exist, skipping")
        goto skip
    end
    if not FindDCWorldIsOn(item["CharHomeWorld"]) == FindDCWorldIsOn(FindWorldByID(GetCurrentWorld())) then
        LogInfo(""..item["CharName"].." is on a different DC, skipping")
        goto skip
    end
    Echo("############################")
    Echo("Waiting for "..item["CharName"])
    Echo("############################")
    repeat 
        Sleep(0.1)
    until GetObjectRawXPos(tostring(item["CharName"])) ~= 0
    while string.len(GetTargetName()) == 0 do
        yield('/target "' ..item["CharName"]..'"')
        Sleep(1)
    end
    repeat 
        Sleep(0.1)
    until IsAddonReady("SelectYesno")
    repeat 
        yield("/pcall SelectYesno true 0")
        Sleep(1)
    until not IsAddonVisible("SelectYesno")
    repeat 
        Sleep(0.1)
    until IsInParty()

    Echo("############################")
    Echo("Getting Ready to trade")
    Echo("############################")
    Sleep(0.5)
    yield('/target "' ..item["CharName"]..'"')
    yield("/focustarget <t>")
    yield("/dropbox")
    Sleep(1)
    if item["Row1ItemName"] then
        DropboxSetItemQuantity(tonumber(item["Row1ItemID"]), false, tonumber(item["Row1ItemAmount"]))
        Sleep(0.5)
        DropboxSetItemQuantity(tonumber(item["Row1ItemID"]), false, tonumber(item["Row1ItemAmount"]))
    end
    Sleep(0.2)
    if item["Row2ItemName"] then
        DropboxSetItemQuantity(tonumber(item["Row2ItemID"]), false, tonumber(item["Row2ItemAmount"]))
        Sleep(0.5)
        DropboxSetItemQuantity(tonumber(item["Row2ItemID"]), false, tonumber(item["Row2ItemAmount"]))
    end
    Sleep(0.2)
    if item["Row3ItemName"] then
        DropboxSetItemQuantity(tonumber(item["Row3ItemID"]), false, tonumber(item["Row3ItemAmount"]))
        Sleep(0.5)
        DropboxSetItemQuantity(tonumber(item["Row3ItemID"]), false, tonumber(item["Row3ItemAmount"]))
    end
    DropboxSetItemQuantity(1, false, 1)
    Sleep(1)
    DropboxSetItemQuantity(1, false, 1)
    Sleep(0.5)
    Echo("############################")
    Echo("Starting trade!")
    Echo("############################")
    DropboxStart()
    Sleep(2)
    tradestatus = DropboxIsBusy()
    while tradestatus == true do
        tradestatus = DropboxIsBusy()
        LogInfo("[GCID] Currently trading...")
        Sleep(2)
    end
    Echo("############################")
    Echo("Trading done")
    Echo("############################")
    Echo("############################")
    Echo("Cleaning up Dropbox")
    Echo("############################")
    DropboxSetItemQuantity(1, false, 0)
    Sleep(0.5)
    DropboxSetItemQuantity(tonumber(item["Row1ItemID"]), false, 0)
    Sleep(0.5)
    DropboxSetItemQuantity(tonumber(item["Row1ItemID"]), false, 0)
    Sleep(0.5)
    DropboxSetItemQuantity(tonumber(item["Row2ItemID"]), false, 0)
    Sleep(0.5)
    DropboxSetItemQuantity(tonumber(item["Row2ItemID"]), false, 0)
    Sleep(0.5)
    DropboxSetItemQuantity(tonumber(item["Row3ItemID"]), false, 0)
    Sleep(0.5)
    DropboxSetItemQuantity(tonumber(item["Row3ItemID"]), false, 0)
    Sleep(0.5)
    DropboxSetItemQuantity(1, false, 0)
    Echo("############################")
    Echo("Done!")
    Echo("############################")
    Sleep("5")
    ::skip::
end
DropboxSetItemQuantity(1, false, 0)
yield("/echo ############################")
yield("/echo Script finished")
yield("/echo ############################")
LogOut()
