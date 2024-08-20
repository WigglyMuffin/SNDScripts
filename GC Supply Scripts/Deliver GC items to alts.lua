--[[
This script is to be used on your main to automatically trade the right items to your alts as they show up
The alts should be running the improved tony script to come and pick stuff up at the location you've set in that script
It bases the trades off the order the character list was in so make sure it's all consistent
if you have everything configured right it's just start the script, go afk and you have eventually delivered all items to your alts

###########
# CONFIGS #
###########
]]
-- Set your alt accounts %appdata% config location otherwise it will not work
SNDAltConfigFolder = "C:\\Users\\ff14lowres\\AppData\\Roaming\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"

-- #####################################
-- #  DON'T TOUCH ANYTHING BELOW HERE  #
-- # UNLESS YOU KNOW WHAT YOU'RE DOING #
-- #####################################

ProvisioningListNameToLoad = "ProvisioningList.lua"

SNDConfigFolder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
LoadFunctionsFileLocation = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(LoadFunctionsFileLocation)
LoadFunctions()
LoadFileCheck()

dofile(SNDAltConfigFolder .. ProvisioningListNameToLoad)

-- ###############
-- # MAIN SCRIPT #
-- ###############

DropboxSetItemQuantity(1, false, 0)
local listlength = 0
local chars_processed = 0

for _ in pairs(ProvisioningList) do
    listlength = listlength + 1
end

for indexName, item in pairs(ProvisioningList) do
    local party_member = ""
    local onlist = false
    local item_1_succeeded = false
    local item_2_succeeded = false
    local item_3_succeeded = false
    local item_trades_succeeded = false
    local gil_trade_succeeded = false
    local Row1Item_inv_amount = 0
    local Row2Item_inv_amount = 0
    local Row3Item_inv_amount = 0
    local gil_inv_amount = 0
    local tradestatus = DropboxIsBusy()
    
    function RefreshInv(item1)
        Row1Item_inv_amount = GetItemCount(tonumber(item1["Row1ItemID"]))
        Row2Item_inv_amount = GetItemCount(tonumber(item1["Row2ItemID"]))
        Row3Item_inv_amount = GetItemCount(tonumber(item1["Row3ItemID"]))
        gil_inv_amount = tonumber(GetGil())
    end
    
    function TradeItems(item1)
        PartyLeave()
        Sleep(0.5)
        Target(party_member)
        yield("/focustarget <t>")
        yield("/dropbox")
        Sleep(1.0)
        Echo("############################")
        Echo("Starting trades!")
        Echo("############################")
        
        while not item_trades_succeeded do
            RefreshInv(item1)
            
            if item1["Row1ItemName"] and not item_1_succeeded then
                if GetItemCount(tonumber(item1["Row1ItemID"])) ~= 0 then
                    DropboxSetItemQuantity(tonumber(item1["Row1ItemID"]), false, tonumber(item1["Row1ItemAmount"]))
                else
                    item_1_succeeded = true
                end
            end
            
            Sleep(0.5)
            
            if item1["Row2ItemName"] and not item_2_succeeded then
                if GetItemCount(tonumber(item1["Row2ItemID"])) ~= 0 then
                    DropboxSetItemQuantity(tonumber(item1["Row2ItemID"]), false, tonumber(item1["Row2ItemAmount"]))
                else
                    item_2_succeeded = true
                end
            end
            
            Sleep(0.5)
            
            if item1["Row3ItemName"] and not item_3_succeeded then
                if GetItemCount(tonumber(item1["Row3ItemID"])) ~= 0 then
                    DropboxSetItemQuantity(tonumber(item1["Row3ItemID"]), false, tonumber(item1["Row3ItemAmount"]))
                else
                    item_3_succeeded = true
                end
            end

            Sleep(0.1)
            DropboxStart()
            
            -- Wait for the item trade to complete
            repeat
                tradestatus = DropboxIsBusy()
                if tradestatus then
                    LogInfo("[GCID] Currently trading...")
                    Sleep(0.5)
                end
            until not tradestatus -- Exit loop when item trade is no longer busy

            if GetItemCount(tonumber(item1["Row1ItemID"])) == Row1Item_inv_amount and not item_1_succeeded then
                Echo("Trading "..item1["Row1ItemName"].." failed, will try again")
            else
                item_1_succeeded = true
            end
            
            if GetItemCount(tonumber(item1["Row2ItemID"])) == Row2Item_inv_amount and not item_2_succeeded then
                Echo("Trading "..item1["Row2ItemName"].." failed, will try again")
            else
                item_2_succeeded = true
            end
            
            if GetItemCount(tonumber(item1["Row3ItemID"])) == Row3Item_inv_amount and not item_3_succeeded then
                Echo("Trading "..item1["Row3ItemName"].." failed, will try again")
            else
                item_3_succeeded = true
            end
            
            if item_1_succeeded and item_2_succeeded and item_3_succeeded then
                item_trades_succeeded = true
            end
            
            Sleep(0.1)
            DropboxClearAll()
            --Sleep(1.1)
        end
        
        while not gil_trade_succeeded do
            RefreshInv(item1)
            -- Set gil amount to 1
            DropboxSetItemQuantity(1, false, 1)
            
            Sleep(0.1)
            DropboxStart()
            
            -- Wait for the gil trade to complete
            repeat
                tradestatus = DropboxIsBusy()
                if tradestatus then
                    LogInfo("[GCID] Currently trading...")
                    Sleep(0.5)
                end
            until not tradestatus -- Exit loop when gil trade is no longer busy
            
            if GetGil() == (gil_inv_amount - 1) then
                gil_trade_succeeded = true
            else
                LogInfo("[GCID] Trade did not succeed, retrying...")
            end
            
            Sleep(0.1)
            DropboxClearAll()
            --Sleep(1.1)
        end
    end
    
    while not onlist do
        Echo("############################")
        Echo("Waiting for party invite")
        Echo("############################")
        
        repeat 
            PartyAccept()
            Sleep(0.1)
        until IsInParty()
        
        party_member = GetPartyMemberName(0)
        
        for index1, item1 in pairs(ProvisioningList) do
            if party_member == index1 then
                Echo("############################")
                Echo("Found "..party_member.." in trade list")
                Echo("Getting Ready to trade")
                Echo("############################")
                TradeItems(item1)
                onlist = true
                break
            end
        end
        
        if not onlist then
            Echo("############################")
            Echo("Did not find "..party_member.." in trade list.")
            Echo("Disbanding party and starting again")
            Echo("############################")
            PartyLeave()
            Sleep(1)
        end
    end
    
    if onlist then
        Sleep(0.1)
        DropboxClearAll()
        chars_processed = chars_processed + 1
        Echo("############################")
        Echo("Done! " .. chars_processed .. "/" .. listlength .. " characters processed")
        Echo("############################")
        Sleep(7.5)
    end
end
DropboxSetItemQuantity(1, false, 0)
Echo("############################")
Echo("Script finished")
Echo("############################")
