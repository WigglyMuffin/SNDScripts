--[[
  _____             _      __  __                       _       
 |  __ \           | |    |  \/  |                     | |      
 | |__) |___   ___ | |_   | \  / |  ___    ___    __ _ | |  ___ 
 |  ___// _ \ / __|| __|  | |\/| | / _ \  / _ \  / _` || | / _ \
 | |   | (_) |\__ \| |_   | |  | || (_) || (_) || (_| || ||  __/
 |_|    \___/ |___/ \__|  |_|  |_| \___/  \___/  \__, ||_| \___|
                                                 __/ |         
                                                |___/          
####################
##    Version     ##
##     1.1.5      ##
####################

-> 1.0.0: Initial release

-> 1.1.0: 
   - Added prioritisation of high-quality items
   - Added toggle to allow mixing of high-quality and normal-quality items
   - Updated TradeItems function to respect new settings

-> 1.1.1:
   - Fixed issue with 1 gil trade not occurring after all items have been traded
   - Improved transition to final 1 gil trade
   - Added more detailed logging for trade process

-> 1.1.2:
   - Fixed item trading logic to work correctly alongside gil trading
   - Improved inventory handling and trade setup
   - Enhanced logging for better trade process visibility

-> 1.1.3:
   - Implemented inventory check for always_include items
   - Fixed retry for failed trades
   - Improved gil trading logic for partial trades
   - Enhanced logging for detailed trade information
   - Added final verification step before 1 gil trade
   - Implemented separate handling for HQ and NQ items
   - Added return values to TradeItems function
   - Improved error handling for incomplete trades

-> 1.1.4:
   - Fixed the script failing to return home if you were the final character in the list

-> 1.1.5:
   - Should fix prioritisation of hq items

####################################################
##                  Description                   ##
####################################################

https://github.com/WigglyMuffin/SNDScripts

This script allows you to send out a configurable post moogle to deliver items to the character of your choice. 
it allows you to configure what you deliver on a per character basis and it allows you to use an always_include list to forcibly add items in that to all deliveries
it also allows for swapping delivery character and continue deliveries from them, it's all configurable in the Delivery_List.lua

it's supposed to be used alongside Kupo Box where they will meet up, this will trade the items and when kupo box receives the 1 gil trade it'll go to next character

####################################################
##                  Requirements                  ##
####################################################

-> AutoRetainer : https://love.puni.sh/ment.json
-> Teleporter : In the default first party dalamud repository
-> Lifestream : https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
-> TextAdvance : https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
-> Something Need Doing (Expanded Edition) : https://puni.sh/api/repository/croizat
-> Pandora's Box : https://love.puni.sh/ment.json
-> vnavmesh : https://puni.sh/api/repository/veyn
-> Dropbox : https://puni.sh/api/repository/kawaii
    -> Recommended settings in dropbox are 4 frames delay between trades and 1500ms trade open command throttle. (Ctrl + left click to specify exact values).
    -> You NEED to make sure the dropbox window is open on the Item Trade Queue tab when you start this script

#####################
##    Settings     ##
#####################

These settings will override what you include in the character list, which means if you set a setting here then all characters will use that setting
to use any of the overrides you need to uncomment the line and set it to what you want. uncommenting is just removing the two lines at the start  ]]

-- local trading_with_override = "Smol Meow"            -- Name of the character you're trading with, do not include world
-- local destination_server_override = "Sephirot"       -- Server characters need to travel to for collecting items
-- local destination_type_override = 0                  -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
-- local destination_aetheryte_override = "Aleport"     -- Aetheryte that characters need to travel to for collecting items, case insensitive and you can be vague
-- local destination_house_override = 0                 -- Options: 0 = FC, 1 = Personal, 2 = Apartment
-- local do_movement_override = true                    -- Options: true = Paths to chosen character, false = Does nothing and waits for chosen character to come to you
-- local return_home_override = true                    -- Options: true = Returns home from destination, false = Does nothing and logs out
-- local return_location_override = 0                   -- Options: 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc 

-- This is how much gil you want to always cut off the top when doing gil trades, just so the character has some gil to travel with
-- Set it to zero if you'd like to cut off nothing
local gil_cut = 0

-- Options: true = waits for party invite before trading, false = uses distance based proximity check for trading
-- toggling this off is usually the faster but less safe method of trading
local party_invite = true

-- Here you can add items you want included with every trade
local always_include = {
    { "Salvaged Ring", 99999 },
    { "Salvaged Bracelet", 99999 },
    { "Salvaged Earring", 99999 },
    { "Salvaged Necklace", 99999 },
    { "Extravagant Salvaged Ring", 99999 },
    { "Extravagant Salvaged Bracelet", 99999 },
    { "Extravagant Salvaged Earring", 99999 },
    { "Extravagant Salvaged Necklace", 99999 }
}

local prioritise_hq = true -- Options: true = prioritise HQ items, false = prioritise NQ items
local allow_mixed_quality = true -- Options: true = allow mixing HQ and NQ, false = use only one quality type (prioritise_hq value)

-- in case something somehow goes wrong you can set the amount of characters in the list to skip, this goes from the top of the list
-- a good way to know how many chars you actually need to skip is to read the processing echo in chat which lists how many chars it's finished already and which char it's on  ]]
local skip_chars = 0 -- number of characters you'd like to skip

-- Options: true / false
-- If the below options is set to true then it will utilize the external vac_char_list and you need to make sure that is correctly configured
local use_external_character_list = true

-- This is where you put your character list if you choose to not use the external one
-- If use_external_character_list is set to true then this list is completely skipped
-- This list uses the same options as shown in the overrides above

local character_list_postmoogle = {
    {
        ["Name"] = "Large Meow@Bismarck", -- the name of the character you're logging in on
        ["Trading With"] = "Smol Meow", -- character you're trading with, without world
        ["Destination Server"] = "Sephirot", -- server you're going to pick up items on
        ["Destination Type"] = 0, -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
        ["Destination Aetheryte"] = "Aleport", -- aetheryte to meet at if ["Destination Type"] is set to 0
        ["Destination House"] = 0, -- Options: 0 = FC, 1 = Personal, 2 = Apartment // Only active if ["Destination Type"] is set to 1 or 2
        ["Do Movement"] = false, -- will move to the character you're trading to, usually this is done by the delivery character
        ["Return Home"] = false, -- will just log out if set to false, otherwise will move to home server and to set location configured by ["Return Location"]
        ["Return Location"] = 0, -- 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc
        ["Items"] = {
            -- This is where you configure what items each character is going to be delivering, the format is {ITEMNAME, AMOUNT}
            --{ "Copper", 50 }, -- It is not case sensitive, however it needs to be the full name so it doesn't accidentally get the wrong item
            --{ "Gold Ore", 10 }
        },
    },
    {
        ["Name"] = "Larger Meow@Sephirot", -- The name of the character you're using to trade
        ["Trading With"] = "Smol Meow", -- Character you're trading with, without world
        ["Destination Server"] = "Sephirot",  -- Server you're going to meet the recipient
        ["Destination Type"] = 0, -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
        ["Destination Aetheryte"] = "Aleport", -- Aetheryte to meet at if ["Destination Type"] is set to 0
        ["Destination House"] = 0, -- Options: 0 = FC, 1 = Personal, 2 = Apartment // Only active if ["Destination Type"] is set to 1 or 2
        ["Do Movement"] = false, -- Will move to the character you're trading to, usually this is done by the delivery character
        ["Return Home"] = false, -- Will just log out if set to false, otherwise will move to home server and to set location configured by ["Return Location"]. This is always processed after it no longer has any trades left
        ["Return Location"] = 0, -- 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc
        ["Items"] = {
            -- This is where you configure what items each character is going to be delivering, the format is {ITEMNAME, AMOUNT}
            --{ "Copper", 50 }, -- It is not case sensitive, however it needs to be the full name so it doesn't accidentally get the wrong item
            --{ "Gold Ore", 10 }
        },
    },
}

--[[#################################
#  DON'T TOUCH ANYTHING BELOW HERE  #
# UNLESS YOU KNOW WHAT YOU'RE DOING #
#####################################

###################
# FUNCTION LOADER #
#################]]

-- Edit char_list.lua file for configuring characters
char_list = "vac_char_list.lua"

snd_config_folder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
vac_config_folder = snd_config_folder .. "\\VAC\\"
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

LogInfo("[PostMoogle] ##############################")
LogInfo("[PostMoogle] Starting script...")
LogInfo("[PostMoogle] snd_config_folder: " .. snd_config_folder)
LogInfo("[PostMoogle] char_list: " .. char_list)
LogInfo("[PostMoogle] SNDConf+Char: " .. snd_config_folder .. "" .. char_list)
LogInfo("[PostMoogle] ##############################")

if use_external_character_list then
    local char_data = dofile(snd_config_folder .. char_list)
    character_list_postmoogle = char_data.character_list_postmoogle
end

--[[###########
# MAIN SCRIPT #
#############]]

local function Main(character_list_postmoogle)
    for i = 1, #character_list_postmoogle do
        DropboxSetItemQuantity(0, false, 0)
        -- Update alt character name
        local alt_char_name = character_list_postmoogle[i]["Name"]

        -- This is just to store the boolean for if we're skipping a char or not
        local skip = false

        -- Check if the character is supposed to be skipped
        if i <= skip_chars then
            LogInfo("[PostMoogle] Skipping char " .. i .. ": " .. alt_char_name )
            skip = true
        end

        if not skip then
            -- Apply overrides if they're needed, otherwise set the settings from the character
            local trading_with = trading_with_override or character_list_postmoogle[i]["Trading With"]
            local destination_server = destination_server_override or character_list_postmoogle[i]["Destination Server"]
            local destination_type = destination_type_override or character_list_postmoogle[i]["Destination Type"]
            local destination_aetheryte = destination_aetheryte_override or character_list_postmoogle[i]["Destination Aetheryte"]
            local destination_house = destination_house_override or character_list_postmoogle[i]["Destination House"]
            local do_movement = do_movement_override or character_list_postmoogle[i]["Do Movement"]
            local return_home = return_home_override or character_list_postmoogle[i]["Return Home"]
            local return_location = return_location_override or character_list_postmoogle[i]["Return Location"]

            -- Switch characters if required, looks up current character and compares
            if GetCharacterName(true) ~= alt_char_name then
                -- checks if return_location options matches 1 which returns player to Limsa
                if return_location == 1 then
                    if not (ZoneCheck("Limsa Lominsa Lower") or ZoneCheck("Limsa Lominsa Upper")) then
                        Teleporter("Limsa", "tp")
                    end
                end

                RelogCharacter(alt_char_name)
                LoginCheck()
            end

            Echo("Delivering items to " .. trading_with .. " on server " .. destination_server)
            LogInfo("[PostMoogle] Delivering items to " .. trading_with .. " on server " .. destination_server)

            Echo("Processing " .. i .. "/" .. #character_list_postmoogle .. ", current character: " .. alt_char_name)
            LogInfo("[PostMoogle] Processing " .. i .. "/" .. #character_list_postmoogle .. ", current character: " .. alt_char_name)

            -- Check if alt character on correct server
            if GetCurrentWorld() == World_ID_List[destination_server].ID then
                -- Already on the right server, do nothing
                LogInfo("[PostMoogle] Already on the right server to trade: "..destination_server)
            else
                -- Go to the needed server
                LogInfo("[PostMoogle] On the wrong server, transferring to: "..destination_server)
                Teleporter(destination_server, "li")
            end

            repeat
                Sleep(0.1)
            until IsPlayerAvailable() and not LifestreamIsBusy()

            -- Alt character destination type, how alt char is travelling to the main
            -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
            if destination_type == 0 then
                local dest_aetheryte_id = FindZoneIDByAetheryte(destination_aetheryte)

                -- If player is not at the destination then tp there
                if GetZoneID() ~= dest_aetheryte_id then
                    Echo("Teleporting to " .. destination_aetheryte .. " to find " .. trading_with)
                    LogInfo("[PostMoogle] Teleporting to " .. destination_aetheryte .. " to find " .. trading_with)
                    Teleporter(destination_aetheryte, "tp")
                else
                    Echo("Already in the right zone to meet " .. trading_with)
                end
            end

            -- Requires main added to friend list for access to estate list teleports
            -- Keeping it for future stuff
            if destination_type > 0 then
                Echo("Teleporting to estate to find " .. trading_with)
                LogInfo("[PostMoogle] Teleporting to estate to find " .. trading_with)
                EstateTeleport(trading_with, destination_house)
            end

            -- Handle different destination types
            -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
            if destination_type == 0 or destination_type == 1 then
                -- Waits until main char is present
                LogInfo("[PostMoogle] Waiting for " .. trading_with)
                WaitUntilObjectExists(trading_with)
                LogInfo("[PostMoogle] Found " .. trading_with)

                -- Paths to main char only if you have do_movement set to true
                if do_movement then
                    -- Path to main char
                    LogInfo("[PostMoogle] do_movement is set to true, moving towards " .. trading_with)
                    PathToObject(trading_with, 3.5)
                else
                    LogInfo("[PostMoogle] do_movement is set to false, not moving")
                end

            elseif destination_type == 2 then
                -- If destination_type is 2, first go to the estate entrance, then to the main character
                PathToEstateEntrance()
                Interact()

                repeat
                    Sleep(0.1)
                    yield("/pcall SelectYesno true 0")
                until not IsAddonVisible("SelectYesno")

                -- Waits until main char is present
                LogInfo("[PostMoogle] Waiting for " .. trading_with)
                WaitUntilObjectExists(trading_with)
                LogInfo("[PostMoogle] Found " .. trading_with)

                -- Paths to main char only if you have do_movement set to true
                if do_movement then
                    -- Path to main char
                    LogInfo("[PostMoogle] do_movement is set to true, moving towards " .. trading_with)
                    PathToObject(trading_with, 3.5)
                else
                    LogInfo("[PostMoogle] do_movement is set to false, not moving")
                end
            end
            Sleep(1.0)

            -- trade section
            local function TradeItems()
                local items_to_trade = {}
                local gil_to_trade = 0
                local gil_traded = 0
                local initial_gil = GetGil()

                local function RefreshInv()
                    items_to_trade = {}  -- Reset the list
                    for _, item in ipairs(character_list_postmoogle[i]["Items"]) do
                        local item_name = item[1]
                        local item_id = FindItemID(item_name)
                        local item_amount = item[2]
                        if item_id == 1 then  -- Gil
                            gil_to_trade = item_amount
                        else
                            local current_count = GetItemCount(item_id, false) + GetItemCount(item_id, true)
                            if current_count > 0 then
                                table.insert(items_to_trade, {id = item_id, amount = math.min(item_amount, current_count), initial_count = current_count})
                            end
                        end
                        --Sleep(0.0001)
                    end
                    
                    -- Add always_include items, but only if they exist in the inventory
                    for _, item in ipairs(always_include) do
                        local item_name = item[1]
                        local item_id = FindItemID(item_name)
                        local item_amount = item[2]
                        local current_count = GetItemCount(item_id, false) + GetItemCount(item_id, true)
                        if current_count > 0 then
                            local found = false
                            for _, existing_item in ipairs(items_to_trade) do
                                if existing_item.id == item_id then
                                    existing_item.amount = math.min(existing_item.amount + item_amount, current_count)
                                    found = true
                                    break
                                end
                            end
                            if not found then
                                table.insert(items_to_trade, {id = item_id, amount = math.min(item_amount, current_count), initial_count = current_count})
                            end
                        end
                        --Sleep(0.0001)
                    end

                    -- Log the items that will be traded
                    LogInfo("[PostMoogle] Items to be traded:")
                    for _, item in ipairs(items_to_trade) do
                        LogInfo("[PostMoogle] Item ID: " .. item.id .. ", Amount: " .. item.amount .. ", Initial Count: " .. item.initial_count)
                    end
                    if gil_to_trade > 0 then
                        LogInfo("[PostMoogle] Gil to be traded: " .. gil_to_trade)
                    end
                end

                RefreshInv()

                -- Do the actual trading
                local all_trades_succeeded = false
                local max_retries = 10
                local retry_count = 0
                
                while not all_trades_succeeded and retry_count < max_retries do
                    DropboxClearAll()
                    Sleep(0.1)

                    -- Handle gil trade
                    if gil_to_trade > gil_traded then
                        local current_gil = GetGil()
                        local gil_remaining = gil_to_trade - gil_traded
                        local gil_to_trade_now = math.min(gil_remaining, current_gil - gil_cut)
                        if gil_to_trade_now > 0 then
                            DropboxSetItemQuantity(1, false, gil_to_trade_now)
                            LogInfo("[PostMoogle] Setting up gil trade of " .. gil_to_trade_now)
                        end
                    end

                    -- Handle item trades
                    for _, item in ipairs(items_to_trade) do
                        local item_id = item.id
                        local item_amount = item.amount
                        local current_count = GetItemCount(item_id, false) + GetItemCount(item_id, true)
                        local traded_so_far = item.initial_count - current_count
                        local remaining_amount = item_amount - traded_so_far

                        if remaining_amount > 0 then
                            local normal_amount = GetItemCount(item_id, false)
                            local hq_amount = GetItemCount(item_id, true) - GetItemCount(item_id, false)

                            local hq_trade = 0
                            local nq_trade = 0

                            if prioritise_hq then
                                -- Prioritise HQ items
                                if hq_amount > 0 then
                                    hq_trade = math.min(hq_amount, remaining_amount)
                                    remaining_amount = remaining_amount - hq_trade
                                end
                                if allow_mixed_quality and remaining_amount > 0 and normal_amount > 0 then
                                    nq_trade = math.min(normal_amount, remaining_amount)
                                end
                            else
                                -- Prioritise NQ items
                                if normal_amount > 0 then
                                    nq_trade = math.min(normal_amount, remaining_amount)
                                    remaining_amount = remaining_amount - nq_trade
                                end
                                if allow_mixed_quality and remaining_amount > 0 and hq_amount > 0 then
                                    hq_trade = math.min(hq_amount, remaining_amount)
                                end
                            end

                            if hq_trade > 0 then
                                DropboxSetItemQuantity(item_id, true, hq_trade)
                                LogInfo("[PostMoogle] Setting up HQ trade for item " .. item_id .. ": " .. hq_trade)
                            end
                            if nq_trade > 0 then
                                DropboxSetItemQuantity(item_id, false, nq_trade)
                                LogInfo("[PostMoogle] Setting up NQ trade for item " .. item_id .. ": " .. nq_trade)
                            end
                        end
                        
                        --Sleep(0.0001)
                    end

                    DropboxStart()
                    repeat
                        trade_status = DropboxIsBusy()
                        if trade_status then
                            LogInfo("[PostMoogle] Currently trading...")
                            Sleep(0.5)
                        end
                    until not trade_status

                    -- Check if everything went smoothly
                    all_trades_succeeded = true
                    local new_gil_amount = GetGil()

                    if gil_to_trade > gil_traded then
                        local gil_traded_now = initial_gil - new_gil_amount - gil_traded
                        if gil_traded_now > 0 then
                            gil_traded = gil_traded + gil_traded_now
                            LogInfo("[PostMoogle] Gil trade of " .. gil_traded_now .. " succeeded. Total gil traded: " .. gil_traded)
                        else
                            LogInfo("[PostMoogle] Gil trade did not succeed")
                            all_trades_succeeded = false
                        end
                    end

                    for _, item in ipairs(items_to_trade) do
                        local item_id = item.id
                        local expected_amount = item.amount
                        local current_count = GetItemCount(item_id, false) + GetItemCount(item_id, true)
                        local traded_amount = item.initial_count - current_count

                        if traded_amount < expected_amount then
                            LogInfo("[PostMoogle] Trade for item " .. item_id .. " partially succeeded. Traded: " .. traded_amount .. "/" .. expected_amount)
                            all_trades_succeeded = false
                        else
                            LogInfo("[PostMoogle] Trade for item " .. item_id .. " fully succeeded")
                        end
                        --Sleep(0.0001)
                    end

                    if not all_trades_succeeded then
                        retry_count = retry_count + 1
                        LogInfo("[PostMoogle] Trade attempt " .. retry_count .. " of " .. max_retries .. " failed. Retrying...")
                        Sleep(1)  -- Wait a bit before retrying
                    end
                end
                
                DropboxClearAll()
                
                -- Final check to ensure all items were traded
                local all_items_traded = true
                for _, item in ipairs(items_to_trade) do
                    local current_count = GetItemCount(item.id, false) + GetItemCount(item.id, true)
                    local traded_amount = item.initial_count - current_count
                    if traded_amount < item.amount then
                        all_items_traded = false
                        LogInfo("[PostMoogle] Item " .. item.id .. " was not fully traded. Traded: " .. traded_amount .. "/" .. item.amount)
                    end
                end

                if gil_traded < gil_to_trade then
                    all_items_traded = false
                    LogInfo("[PostMoogle] Gil was not fully traded. Traded: " .. gil_traded .. "/" .. gil_to_trade)
                end

                if not all_items_traded then
                    LogInfo("[PostMoogle] Not all items or gil were successfully traded. Skipping final 1 gil trade.")
                    return false
                end

                LogInfo("[PostMoogle] All items and gil successfully traded. Proceeding to final 1 gil trade.")

                -- Perform the final 1 gil trade
                local gil_trade_succeeded = false
                local gil_retry_count = 0
                while not gil_trade_succeeded and gil_retry_count < max_retries do
                    DropboxClearAll()  -- Clear any previous trade setup
                    Sleep(0.1)

                    local gil_inv_amount = GetGil()
                    DropboxSetItemQuantity(1, false, 1)
                    LogInfo("[PostMoogle] Setting up final 1 gil trade")

                    Sleep(0.1)
                    DropboxStart()

                    repeat
                        trade_status = DropboxIsBusy()
                        if trade_status then
                            LogInfo("[PostMoogle] Trading final 1 gil...")
                            Sleep(0.5)
                        end
                    until not trade_status

                    if GetGil() == (gil_inv_amount - 1) then
                        gil_trade_succeeded = true
                        LogInfo("[PostMoogle] Successfully traded final 1 gil.")
                    else
                        LogInfo("[PostMoogle] Final gil trade did not succeed, retrying...")
                        gil_retry_count = gil_retry_count + 1
                    end

                    Sleep(0.1)
                end
                
                if not gil_trade_succeeded then
                    LogInfo("[PostMoogle] Failed to trade final 1 gil after " .. max_retries .. " attempts.")
                    return false
                end
                
                DropboxClearAll()
                ClearFocusTarget()
                return true
            end

            local ready_to_trade = false

            -- checks if party invite method is set to true or not
            if party_invite then
                while not ready_to_trade do
                    if IsInParty() then
                        PartyLeave()
                        Sleep(0.1)
                    end

                    Echo("Waiting for party invite from " .. trading_with)

                    repeat
                        PartyAccept()
                        Sleep(0.1)
                    until IsInParty()

                    local party_member = GetPartyMemberName(0)

                    if party_member == trading_with then
                        ready_to_trade = true
                        Sleep(0.5)
                        Target(party_member)
                        yield("/focustarget <t>")
                        Sleep(0.5)
                    else
                        Echo(party_member .. " is not the right character, leaving party")
                    end
                end
            else
                Target(trading_with)
                yield("/focustarget <t>")
                repeat
                    Sleep(0.1)
                until GetDistanceToTarget() < 4
                Sleep(0.5)
            end

            TradeItems()

            -- Notify when all characters are finished
            if i == #character_list_postmoogle then
                Echo("Finished all " .. #character_list_postmoogle .. " characters")
                LogInfo("Finished all " .. #character_list_postmoogle .. " characters")
            end

            -- Character handling to go home if the next in list is not receiving items from this character
            -- [2] return_home options: 0 = no, 1 = yes
            -- [3] return_location options: 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc
            local i_temp = i + 1 -- adds + 1 to the index so i can check which character is next and only run return routine if the character is different
            -- Checks if there's another char in the list
            local next_char_in_list = "Place Holder" -- Makes sure that if the below if check fails it will have something to fallback on
            if character_list_postmoogle[i_temp] and character_list_postmoogle[i_temp]["Name"] then
                next_char_in_list = character_list_postmoogle[i_temp]["Name"]
            end
            -- Returns home if the next char is either nil(list done) or another name 
            if alt_char_name ~= next_char_in_list then
                Echo("delivery job done")
                if return_home then
                    Echo(alt_char_name .. " returning home to")
                    LogInfo("[PostMoogle] Returning home")
                    ReturnHomeWorld()

                    -- Limsa stuff
                    if return_location == 1 then
                        if not (ZoneCheck("Limsa Lominsa Lower") or ZoneCheck("Limsa Lominsa Upper")) then
                            LogInfo("[PostMoogle] Attempting to go to Limsa")
                            Teleporter("Limsa", "tp")
                        end
                    end

                    -- Limsa Retainer Bell Stuff
                    if return_location == 2 then
                        LogInfo("[PostMoogle] Attempting to go to Limsa retainer bell")
                        PathToLimsaBell()
                    end

                    -- Nearby Retainer Bell Stuff
                    if return_location == 3 then
                        LogInfo("[PostMoogle] Attempting to go to nearest retainer bell")
                        PathToObject("Summoning Bell")
                    end

                    -- FC Entrance stuff
                    if return_location == 4 then
                        LogInfo("[PostMoogle] Attempting to go to FC Entrance")
                        Teleporter("Estate Hall (Free Company)", "tp")
                        PathToObject("Entrance")
                    end
                end
            end
            i_temp = i
        end
        skip = false
        --Sleep(0.0001)
    end
end

Main(character_list_postmoogle)
LogInfo("[PostMoogle] All characters complete, script finished")

if HasPlugin("YesAlready") then
    RestoreYesAlready()
end
