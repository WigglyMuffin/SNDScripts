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
snd_alt_config_folder = "C:\\Users\\ff14lowres\\AppData\\Roaming\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"



-- #####################################
-- #  DON'T TOUCH ANYTHING BELOW HERE  #
-- # UNLESS YOU KNOW WHAT YOU'RE DOING #
-- #####################################

provisioning_list_name_to_load = "provisioning_list.lua"

snd_config_folder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
load_functions_file_location = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(load_functions_file_location)
LoadFunctions()
LoadFileCheck()

alt_vac_config_folder = snd_alt_config_folder .. "VAC"
dofile(alt_vac_config_folder .. '\\GC\\' .. provisioning_list_name_to_load)

-- ###############
-- # MAIN SCRIPT #
-- ###############

DropboxClearAll()
local list_length = 0
local chars_processed = 0

for _ in pairs(provisioning_list) do
    list_length = list_length + 1
    Sleep(0.1)
end

for index_name, item in pairs(provisioning_list) do
    local party_member = ""
    local on_list = false
    local min_succeeded = false
    local btn_succeeded  = false
    local fsh_succeeded = false
    local item_trades_succeeded = false
    local gil_trade_succeeded = false
    local min_inv_amount = 0
    local btn_inv_amount = 0
    local fsh_inv_amount = 0
    local gil_inv_amount = 0
    local trade_status = DropboxIsBusy()
    
    function RefreshInv(item_list)
        min_inv_amount = GetItemCount(tonumber(item_list["MIN"] and item_list["MIN"]["ID"]) or 0)
        btn_inv_amount = GetItemCount(tonumber(item_list["BTN"] and item_list["BTN"]["ID"]) or 0)
        fsh_inv_amount = GetItemCount(tonumber(item_list["FSH"] and item_list["FSH"]["ID"]) or 0)
        gil_inv_amount = tonumber(GetGil()) or 0
    end
    
    function TradeItems(item_list)
        Sleep(0.5)
        Target(party_member)
        yield("/focustarget <t>")
        yield("/dropbox")
        Sleep(1.0)
        Echo("############################")
        Echo("Starting trades!")
        Echo("############################")
        
        while not item_trades_succeeded do
            RefreshInv(item_list)

            -- Handle MIN item
            if item_list["MIN"] and not min_succeeded then
                local min_id = tonumber(item_list["MIN"]["ID"])
                local min_qty = tonumber(item_list["MIN"]["QTY"])

                if min_id and GetItemCount(min_id) ~= 0 then
                    DropboxSetItemQuantity(min_id, false, min_qty)
                else
                    min_succeeded = true
                end
            else
                min_succeeded = true
            end

            Sleep(0.5)

            -- Handle BTN item
            if item_list["BTN"] and not btn_succeeded then
                local btn_id = tonumber(item_list["BTN"]["ID"])
                local btn_qty = tonumber(item_list["BTN"]["QTY"])

                if btn_id and GetItemCount(btn_id) ~= 0 then
                    DropboxSetItemQuantity(btn_id, false, btn_qty)
                else
                    btn_succeeded = true
                end
            else
                btn_succeeded = true
            end

            Sleep(0.5)

            -- Handle FSH item
            if item_list["FSH"] and not fsh_succeeded  then
                local fsh_id = tonumber(item_list["FSH"]["ID"])
                local fsh_qty = tonumber(item_list["FSH"]["QTY"])

                if fsh_id and GetItemCount(fsh_id) ~= 0 then
                    DropboxSetItemQuantity(fsh_id, false, fsh_qty)
                else
                    fsh_succeeded = true
                end
            else
                fsh_succeeded = true
            end

            Sleep(0.1)
            DropboxStart()

            -- Wait for the item trade to complete
            repeat
                trade_status = DropboxIsBusy()

                if trade_status then
                    LogInfo("[GCID] Currently trading...")
                    Sleep(0.5)
                end
            until not trade_status -- Exit loop when item trade is no longer busy

            -- Check if trade succeeded
            if item_list["MIN"] and GetItemCount(tonumber(item_list["MIN"]["ID"])) == min_inv_amount and not min_succeeded then
                Echo("Trading " .. item_list["MIN"]["Item"] .. " failed, will try again")
            else
                min_succeeded = true
            end

            if item_list["BTN"] and GetItemCount(tonumber(item_list["BTN"]["ID"])) == btn_inv_amount and not btn_succeeded then
                Echo("Trading " .. item_list["BTN"]["Item"] .. " failed, will try again")
            else
                btn_succeeded = true
            end

            if item_list["FSH"] and GetItemCount(tonumber(item_list["FSH"]["ID"])) == fsh_inv_amount and not fsh_succeeded then
                Echo("Trading " .. item_list["FSH"]["Item"] .. " failed, will try again")
            else
                fsh_succeeded = true
            end

            if min_succeeded and btn_succeeded and fsh_succeeded then
                item_trades_succeeded = true
            end

            Sleep(0.1)
            DropboxClearAll()
        end
        
        while not gil_trade_succeeded do
            RefreshInv(item_list)
            -- Set gil amount to 1
            DropboxSetItemQuantity(1, false, 1)
            
            Sleep(0.1)
            DropboxStart()
            
            -- Wait for the gil trade to complete
            repeat
                trade_status = DropboxIsBusy()
                if trade_status then
                    LogInfo("[GCID] Currently trading...")
                    Sleep(0.5)
                end
            until not trade_status -- Exit loop when gil trade is no longer busy
            
            if GetGil() == (gil_inv_amount - 1) then
                gil_trade_succeeded = true
            else
                LogInfo("[GCID] Trade did not succeed, retrying...")
            end
            
            Sleep(0.1)
            DropboxClearAll()
        end
        
        ClearFocusTarget()
    end
    
    while not on_list do
        Echo("############################")
        Echo("Waiting for party invite")
        Echo("############################")
        
        if IsInParty() then
            PartyLeave()
            Sleep(0.1)
        end
        
        repeat 
            PartyAccept()
            Sleep(0.1)
        until IsInParty()
        
        party_member = GetPartyMemberName(0)
        
        for i, item_list in pairs(provisioning_list) do
            if party_member == i then
                Echo("############################")
                Echo("Found " .. party_member .. " in trade list")
                Echo("Getting Ready to trade")
                Echo("############################")
                TradeItems(item_list)
                on_list = true
                break
            end
        end
        
        if not on_list then
            Echo("############################")
            Echo("Did not find " .. party_member .. " in trade list.")
            Echo("Disbanding party and starting again")
            Echo("############################")
            PartyLeave()
            Sleep(1)
        end
    end
    
    if on_list then
        Sleep(0.1)
        chars_processed = chars_processed + 1
        Echo("############################")
        Echo("Done! " .. chars_processed .. "/" .. list_length .. " characters processed")
        Echo("############################")
        Sleep(7.5)
    end
end

DropboxClearAll()
Echo("############################")
Echo("Script finished")
Echo("############################")