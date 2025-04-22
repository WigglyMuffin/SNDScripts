--[[
  _____              _         ____  ____   ___ _                     
 |_   _| __ __ _  __| | ___   / ___|/ ___| |_ _| |_ ___ _ __ ___  ___ 
   | || '__/ _` |/ _` |/ _ \ | |  _| |      | || __/ _ \ '_ ` _ \/ __|
   | || | | (_| | (_| |  __/ | |_| | |___   | || ||  __/ | | | | \__ \
   |_||_|  \__,_|\__,_|\___|  \____|\____| |___|\__\___|_| |_| |_|___/
                                                                      

####################
##    Version     ##
##     1.0.2      ##
####################

-> 1.0.0: Initial release
-> 1.0.1: Duplicate name targetting fix and truncation of @World from provisioning_list character names
-> 1.0.2: Fixed duplicate names when matching player to items they require and removed truncation of @World to facilitate this change

####################################################
##                  Description                   ##
####################################################

https://github.com/WigglyMuffin/SNDScripts

This script automatically trade GC items from your main character to your alt characters as they show up

####################################################
##                  Requirements                  ##
####################################################

-> AutoRetainer : https://love.puni.sh/ment.json
-> Teleporter : In the default first party dalamud repository
-> Lifestream : https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
-> TextAdvance : https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
-> Something Need Doing (Expanded Edition) : https://puni.sh/api/repository/croizat
-> vnavmesh : https://puni.sh/api/repository/veyn
-> Dropbox : https://puni.sh/api/repository/kawaii
    -> Recommended settings in dropbox are 4 frames delay between trades and 1500ms trade open command throttle. (Ctrl + left click to specify exact values).
    -> You need to enable "Enable auto-accept trades." under the dropbox settings for receiving items.
    -> Dropbox UI is required to be visible and on the "Item Trade Queue" tab for trading functionality to operate for giving items.

####################################################
##                    Settings                    ##
##################################################]]

-- Set your alt accounts %appdata% config location otherwise this script will not work
-- Replace "ff14lowres" with your alt account username if different
snd_alt_config_folder = "C:\\Users\\ff14lowres\\AppData\\Roaming\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"

--[[################################################
##                  Script Start                  ##
##################################################]]

provisioning_list_name_to_load = "provisioning_list.lua"

snd_config_folder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
load_functions_file_location = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(load_functions_file_location)()
LoadFileCheck()

-- Plugin checker
local required_plugins = {
    AutoRetainer = "4.4.4",
    TeleporterPlugin = "2.0.2.5",
    Lifestream = "2.3.2.8",
    SomethingNeedDoing = "1.75",
    TextAdvance = "3.2.4.4",
    vnavmesh = "0.0.0.54"
}

if not CheckPlugins(required_plugins) then
    return -- Stops script as plugins not available or versions don't match
end

if HasPlugin("YesAlready") then
    PauseYesAlready()
end

alt_vac_config_folder = snd_alt_config_folder .. "VAC"
dofile(alt_vac_config_folder .. '\\GC\\' .. provisioning_list_name_to_load)

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
        
        if GetPartyMemberName(0) .. "@" .. FindWorldByID(GetPartyMemberWorldId(0)) == party_member then
            yield("/target <2>")
            yield("/focustarget <2>")
            yield("/dropbox")
            Sleep(1.0)
        end
        
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
            Sleep(0.1)
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
        
        if gil_trade_succeeded and IsInParty() then
            PartyLeave()
            Sleep(0.1)
        end
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
        
        party_member = GetPartyMemberName(0) .. "@" .. FindWorldByID(GetPartyMemberWorldId(0))
        
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
            Sleep(1.0)
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

if HasPlugin("YesAlready") then
    RestoreYesAlready()
end