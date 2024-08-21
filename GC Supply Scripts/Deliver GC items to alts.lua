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
    local fsh_succeeded = false
    local min_succeeded = false
    local btn_succeeded  = false
    local item_trades_succeeded = false
    local gil_trade_succeeded = false
    local fsh_inv_amount = 0
    local min_inv_amount = 0
    local btn_inv_amount = 0
    local gil_inv_amount = 0
    local tradestatus = DropboxIsBusy()
    
    function RefreshInv(item1)
        fsh_inv_amount = GetItemCount(tonumber(item1["FSH"]["ID"]))
        min_inv_amount = GetItemCount(tonumber(item1["MIN"]["ID"]))
        btn_inv_amount = GetItemCount(tonumber(item1["BTN"]["ID"]))
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
    
            -- Handle FSH (Fishing) item
            if item1["FSH"] and not fsh_succeeded then
                local fsh_id = tonumber(item1["FSH"]["ID"])
                local fsh_qty = tonumber(item1["FSH"]["QTY"])
                if fsh_id and GetItemCount(fsh_id) ~= 0 then
                    DropboxSetItemQuantity(fsh_id, false, fsh_qty)
                else
                    fsh_succeeded = true
                end
            end
    
            Sleep(0.5)
    
            -- Handle MIN (Mining) item
            if item1["MIN"] and not min_succeeded then
                local min_id = tonumber(item1["MIN"]["ID"])
                local min_qty = tonumber(item1["MIN"]["QTY"])
                if min_id and GetItemCount(min_id) ~= 0 then
                    DropboxSetItemQuantity(min_id, false, min_qty)
                else
                    min_succeeded = true
                end
            end
    
            Sleep(0.5)
    
            -- Handle BTN (Botany) item
            if item1["BTN"] and not btn_succeeded then
                local btn_id = tonumber(item1["BTN"]["ID"])
                local btn_qty = tonumber(item1["BTN"]["QTY"])
                if btn_id and GetItemCount(btn_id) ~= 0 then
                    DropboxSetItemQuantity(btn_id, false, btn_qty)
                else
                    btn_succeeded = true
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
    
            -- Check if trade succeeded
            if GetItemCount(tonumber(item1["FSH"]["ID"])) == fsh_inv_amount and not fsh_succeeded then
                Echo("Trading "..item1["FSH"]["Item"].." failed, will try again")
            else
                fsh_succeeded = true
            end
    
            if GetItemCount(tonumber(item1["MIN"]["ID"])) == min_inv_amount and not min_succeeded then
                Echo("Trading "..item1["MIN"]["Item"].." failed, will try again")
            else
                min_succeeded = true
            end
    
            if GetItemCount(tonumber(item1["BTN"]["ID"])) == btn_inv_amount and not btn_succeeded then
                Echo("Trading "..item1["BTN"]["Item"].." failed, will try again")
            else
                btn_succeeded = true
            end
    
            if fsh_succeeded and min_succeeded and btn_succeeded then
                item_trades_succeeded = true
            end
    
            Sleep(0.1)
            DropboxClearAll()
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
