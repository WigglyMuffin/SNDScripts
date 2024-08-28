--[[
  _____             _    __  __                       _       
 |  __ \           | |  |  \/  |                     | |      
 | |__) |___   ___ | |_ | \  / |  ___    ___    __ _ | |  ___ 
 |  ___// _ \ / __|| __|| |\/| | / _ \  / _ \  / _` || | / _ \
 | |   | (_) |\__ \| |_ | |  | || (_) || (_) || (_| || ||  __/
 |_|    \___/ |___/ \__||_|  |_| \___/  \___/  \__, ||_| \___|
                                                __/ |         
                                               |___/          
####################
##    Version     ##
##     1.0.0      ##
####################

-> 1.0.0: Initial release

############################################################
##                      Description                       ##
############################################################

This script allows you to send out a configurable post moogle to deliver items to the character of your choice. 
it allows you to configure what you deliver on a per character basis and it allows you to use an always_include list to forcibly add items in that to all deliveries
it also allows for swapping delivery character and continue deliveries from them, it's all configurable in the Delivery_List.lua

it's supposed to be used alongside Kupo Box where they will meet up, this will trade the items and when kupo box receives the 1 gil trade it'll go to next character
############################################################
##                   Required Plugins                     ##
############################################################

-> AutoRetainer : https://love.puni.sh/ment.json
-> Teleporter : In the default first party dalamud repository
-> Lifestream : https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
-> TextAdvance : https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
-> Something Need Doing (Expanded Edition) : https://puni.sh/api/repository/croizat
-> Pandora's Box : https://love.puni.sh/ment.json
-> vnavmesh : https://puni.sh/api/repository/veyn

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



-- Here you can add items you want included with every trade
local always_include = {
    {"Gil", 5}, -- trades 5 gil
}

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
        ["Items"] = {  -- This is where you configure what items each character is going to be delivering, the format is {ITEMNAME, AMOUNT}
            {"Copper", 50}, -- It is not case sensitive, however it needs to be the full name so it doesn't accidentally get the wrong item
            {"Gold Ore", 10}
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
        ["Items"] = {  -- This is where you configure what items each character is going to be delivering, the format is {ITEMNAME, AMOUNT}
            --{"Copper", 50}, -- It is not case sensitive, however it needs to be the full name so it doesn't accidentally get the wrong item
            --{"Gold Ore", 10}
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
LoadFunctions = loadfile(load_functions_file_location)
LoadFunctions()
LoadFileCheck()

if not CheckPluginsEnabled("AutoRetainer", "TeleporterPlugin", "Lifestream", "PandorasBox", "SomethingNeedDoing", "TextAdvance", "vnavmesh") then
    return -- Stops script as plugins not available
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
                Sleep(7.5)
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
                    PathToObject(trading_with, 3)
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
                    PathToObject(trading_with, 3)
                else
                    LogInfo("[PostMoogle] do_movement is set to false, not moving")
                end
            end


            -- trade section

            function TradeItems()
                local items_to_trade_inventory_amount = {}
                local items_to_trade = {}

                local function RefreshInv()
                    for _, item in ipairs(items_to_trade) do
                        local item_id = item.id
                        local item_count = GetItemCount(item_id, true)
                        table.insert(items_to_trade_inventory_amount, {id = item_id, amount = item_count})
                        Sleep(0.0001)
                    end
                end

                Echo("Getting Ready to trade")

                Sleep(0.5)
                Target(party_member)
                yield("/focustarget <t>")
                Sleep(0.5)

                local item_trades_succeeded = false

                -- process character item list
                for _, item in ipairs(i["Items"]) do
                    local item_name = item[1]
                    local item_id = FindItemID(item_name)
                    local item_amount = item[2]
                    table.insert(items_to_trade, {id = item_id, amount = item_amount})
                    Sleep(0.0001)
                end

                -- process always include list
                for _, item in ipairs(always_include) do
                    local item_name = item[1]
                    local item_id = FindItemID(item_name)
                    local item_amount = item[2]
                    table.insert(items_to_trade, {id = item_id, amount = item_amount})
                    Sleep(0.0001)
                end

                RefreshInv()

                local item_amount_lookup = {}
                for _, item in ipairs(items_to_trade) do
                    item_amount_lookup[item.id] = item.amount
                end

                -- Do the actual trading
                while not item_trades_succeeded do
                    DropboxClearAll()
                    for _, item in ipairs(items_to_trade_inventory_amount) do
                        local item_id = item.id
                        local item_amount = item_amount_lookup[item_id]

                        if item_amount then
                            DropboxSetItemQuantity(item_id, false, item_amount)
                            DropboxSetItemQuantity(item_id, true, item_amount)
                            Sleep(0.0001)
                        end
                    end

                    Sleep(0.2)
                    DropboxStart()

                    repeat
                        trade_status = DropboxIsBusy()

                        if trade_status then
                            LogInfo("[PostMoogle] Currently trading...")
                            Sleep(0.5)
                        end
                    until not trade_status

                    -- Check if everything went smoothly
                    for s = #items_to_trade_inventory_amount, 1, -1 do
                        local item = items_to_trade_inventory_amount[s]
                        local item_id = item.id
                        local expected_amount = item.amount

                        -- Get the current count of the item in the inventory
                        local current_count = GetItemCount(item_id, true)

                        -- Check if the current item amount is less than the expected amount
                        if current_count < expected_amount then
                            -- Remove the item from the list
                            table.remove(items_to_trade_inventory_amount, s)
                        end
                    end

                    -- If list is empty then all items succeded
                    if #items_to_trade_inventory_amount == 0 then
                        item_trades_succeeded = true
                    end
                end

                -- save current gil so we can check if the gil trade went right

                while not gil_trade_succeeded do
                    DropboxClearAll()
                    local gil_inv_amount = GetGil()
                    -- Set gil trade amount to 1
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
                    
                    -- Check if the gil trade went right
                    if GetGil() == (gil_inv_amount - 1) then
                        gil_trade_succeeded = true
                    else
                        LogInfo("[GCID] Trade did not succeed, retrying...")
                    end
                    
                    Sleep(0.1)
                end
                ClearFocusTarget()
            end

            local ready_to_trade = false

            while not ready_to_trade do
                if IsInParty() then
                    PartyLeave()
                    Sleep(0.1)
                end

                Echo("Waiting for party invite from " .. i["Trading With"])

                repeat
                    PartyAccept()
                    Sleep(0.1)
                until IsInParty()

                local party_member = GetPartyMemberName(0)

                if party_member == i["Trading With"] then
                    ready_to_trade = true
                else
                    Echo(party_member .. " is not the right character, leaving party")
                end
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
            local i_temp = i + 1 -- adds +1 to the index so i can check which character is next and only run return routine if the character is different
            if alt_char_name ~= character_list_postmoogle[i_temp]["Name"] then
                Echo("delivery job done")
                if return_home then
                    Echo(alt_char_name .. " returning home")
                    LogInfo("[PostMoogle] Returning home")
                    if return_location == 1 then
                        ReturnHomeWorld()
                    end
    
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
                        Movement(GetObjectRawXPos("Summoning Bell"), GetObjectRawYPos("Summoning Bell"), GetObjectRawZPos("Summoning Bell"))
                    end
    
                    -- FC Entrance stuff
                    if return_location == 4 then
                        LogInfo("[PostMoogle] Attempting to go to FC Entrance")
                        Teleporter("Estate Hall (Free Company)", "tp")
                        -- This likely needs some logic on nearest "Entrance" for nearby estates
                        PathToEstateEntrance()
                    end
                end
            end
            i_temp = i
        end
        skip = false
        Sleep(0.0001)
    end
end

Main(character_list_postmoogle)
LogInfo("[PostMoogle] All characters complete, script finished")
