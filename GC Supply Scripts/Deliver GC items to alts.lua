--[[
  _  __                      ____              
 | |/ /                     |  _ \             
 | ' / _   _  _ __    ___   | |_) |  ___ __  __
 |  < | | | || '_ \  / _ \  |  _ <  / _ \\ \/ /
 | . \| |_| || |_) || (_) | | |_) || (_) |>  < 
 |_|\_\\__,_|| .__/  \___/  |____/  \___//_/\_\
             | |                               
             |_|                               
##################################################################
##                     What does this script do?                ##
##################################################################
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
    local item_1_succeded = false
    local item_2_succeded = false
    local item_3_succeded = false
    local item_trades_succeded = false
    local gil_trade_succeded = false
    local Row1Item_inv_amount = 0
    local Row2Item_inv_amount = 0
    local Row3Item_inv_amount = 0
    local gil_inv_amount = 0
    local party_member = ""
    function ClearTrades()
        -- it's like this just to make sure it cleans the trades properly
        DropboxSetItemQuantity(1, false, 0)
        DropboxSetItemQuantity(1, false, 0)
        DropboxSetItemQuantity(tonumber(item["Row1ItemID"]), false, 0)
        DropboxSetItemQuantity(tonumber(item["Row1ItemID"]), false, 0)
        DropboxSetItemQuantity(tonumber(item["Row1ItemID"]), false, 0)
        DropboxSetItemQuantity(tonumber(item["Row1ItemID"]), false, 0)
        DropboxSetItemQuantity(tonumber(item["Row2ItemID"]), false, 0)
        DropboxSetItemQuantity(tonumber(item["Row2ItemID"]), false, 0)
        DropboxSetItemQuantity(tonumber(item["Row2ItemID"]), false, 0)
        DropboxSetItemQuantity(tonumber(item["Row2ItemID"]), false, 0)
        DropboxSetItemQuantity(tonumber(item["Row3ItemID"]), false, 0)
        DropboxSetItemQuantity(tonumber(item["Row3ItemID"]), false, 0)
        DropboxSetItemQuantity(tonumber(item["Row3ItemID"]), false, 0)
        DropboxSetItemQuantity(tonumber(item["Row3ItemID"]), false, 0)
        DropboxSetItemQuantity(1, false, 0)
        DropboxSetItemQuantity(1, false, 0)
        Sleep(0.5)
    end
    function RefreshInv()
        Row1Item_inv_amount = GetItemCount(tonumber(item["Row1ItemID"]))
        Row2Item_inv_amount = GetItemCount(tonumber(item["Row2ItemID"]))
        Row3Item_inv_amount = GetItemCount(tonumber(item["Row3ItemID"]))
        gil_inv_amount = tonumber(GetGil())
    end
    function TradeItems()
        while not item_trades_succeded do
            RefreshInv()
            if item["Row1ItemName"] and not item_1_succeded then
                if GetItemCount(tonumber(item["Row1ItemID"])) ~= 0 then
                    DropboxSetItemQuantity(tonumber(item["Row1ItemID"]), false, tonumber(item["Row1ItemAmount"]))
                else
                    item_1_succeded = true
                end
            end
            Sleep(0.5)
            if item["Row2ItemName"] and not item_2_succeded then
                if GetItemCount(tonumber(item["Row2ItemID"])) ~= 0 then
                    DropboxSetItemQuantity(tonumber(item["Row2ItemID"]), false, tonumber(item["Row2ItemAmount"]))
                else
                    item_2_succeded = true
                end
            end
            Sleep(0.5)
            if item["Row3ItemName"] and not item_3_succeded then
                if GetItemCount(tonumber(item["Row3ItemID"])) ~= 0 then
                    DropboxSetItemQuantity(tonumber(item["Row3ItemID"]), false, tonumber(item["Row3ItemAmount"]))
                else
                    item_3_succeded = true
                end
            end

            DropboxStart()
            Sleep(2.0)
            tradestatus = DropboxIsBusy()
            while tradestatus == true do
                tradestatus = DropboxIsBusy()
                LogInfo("[GCID] Currently trading...")
                Sleep(2.0)
            end

            if GetItemCount(tonumber(item["Row1ItemID"])) == Row1Item_inv_amount and not item_1_succeded then
                Echo("Trading "..item["Row1ItemName"].." failed, will try again")
            else
                item_1_succeded = true
            end
            if GetItemCount(tonumber(item["Row2ItemID"])) == Row2Item_inv_amount and not item_2_succeded then
                Echo("Trading "..item["Row2ItemName"].." failed, will try again")
            else
                item_2_succeded = true
            end
            if GetItemCount(tonumber(item["Row3ItemID"])) == Row3Item_inv_amount and not item_3_succeded then
                Echo("Trading "..item["Row3ItemName"].." failed, will try again")
            else
                item_3_succeded = true
            end
            if item_1_succeded and item_2_succeded and item_3_succeded then
                item_trades_succeded = true
            end
            Sleep(0.1)
            ClearTrades()
        end
        while not gil_trade_succeded do
            RefreshInv()
            DropboxSetItemQuantity(1, false, 1)
            DropboxSetItemQuantity(1, false, 1)
            DropboxSetItemQuantity(1, false, 1)
            DropboxSetItemQuantity(1, false, 1)
            Sleep(0.2)
            DropboxStart()
            Sleep(2.0)
            while tradestatus == true do
                tradestatus = DropboxIsBusy()
                LogInfo("[GCID] Currently trading...")
                Sleep(2.0)
            end
            if GetGil() == (gil_inv_amount - 1) then
                gil_trade_succeded = true
            end
            ClearTrades()
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
                Echo("############################")
                onlist = true
                break
            else
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
        Echo("############################")
        Echo("Getting Ready to trade")
        Echo("############################")
        Sleep(0.5)
        Target(party_member)
        yield("/focustarget <t>")
        yield("/dropbox")
        Sleep(1.0)
        Echo("############################")
        Echo("Starting trades!")
        Echo("############################")
        TradeItems()
        Echo("############################")
        Echo("Trading done!")
        Echo("Cleaning up Dropbox")
        Echo("############################")
        ClearTrades()
        chars_processed = chars_processed + 1
        Echo("############################")
        Echo("Done! " .. chars_processed .. "/" .. listlength .. " characters processed")
        Echo("############################")
        Sleep(5.0)
    end
end
DropboxSetItemQuantity(1, false, 0)
Echo("############################")
Echo("Script finished")
Echo("############################")
