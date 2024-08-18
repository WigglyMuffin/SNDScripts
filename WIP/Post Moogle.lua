--[[
  _____             _    __  __                       _       
 |  __ \           | |  |  \/  |                     | |      
 | |__) |___   ___ | |_ | \  / |  ___    ___    __ _ | |  ___ 
 |  ___// _ \ / __|| __|| |\/| | / _ \  / _ \  / _` || | / _ \
 | |   | (_) |\__ \| |_ | |  | || (_) || (_) || (_| || ||  __/
 |_|    \___/ |___/ \__||_|  |_| \___/  \___/  \__, ||_| \___|
                                                __/ |         
                                               |___/          
##################################################################
##                   What does this script do?                  ##
##################################################################
This script allows you to send out a configurable post moogle to deliver items to the character of your choice. 
it allows you to configure what you deliver on a per character basis and it allows you to use an always_include list to forcibly add items in that to all deliveries
it also allows for swapping delivery character and continue deliveries from them, it's all configurable in the Delivery_List.lua

##################################################################
##                  Explanations and how to use                 ##
##################################################################
To configure this script you need to edit your own Delivery_List.lua and place it in the SND config directory, an example will be in the directory you got this script from

Here's what each option does:

["Trading From"] = "meow meow@Cerberus", || This is the character you want to deliver items with 
["Trading To"] = "guh guh",             || This is the character you want to deliver items to, do not include world
["Pickup At Estate"] = false,            || If true this will try to deliver to an estate configured by the ["Estate Type"] option and zone will be ignored, if set to false zone will be done instead
["Estate Type"] = 0,                     || This has 3 options: 0 = FC, 1 = Personal, 2 = Apartment This option will be ignored if ["Pickup At Estate"] is set to false
["Pickup Zone"] = "Aleport",             || Set this to the zone you're delivering to
["Pickup Server Location"] = "Cerberus", || Set this to the server you're delivering to
["ReturnToHomeServer"] = false,          || if true the postmoogle will return to their home server before going to the next character to deliver more 
["ReturnToPlace"] = 0,                   || This has 3 options: 0 = FC, 1 = Personal, 2 = Apartment. This option will be ignored if ["ReturnToHomeServer"] is set to false
["Items"] = {                            || This is where you configure what items each character is going to be delivering, the format is {ITEMID, AMOUNT}
    {1, 1},                              || for example this will deliver 1 gil
    {5268, 50}                           || and this will deliver 50 copper sand
}

##################################################################
##                          CONFIGS                             ##
################################################################]]


-- anything put here will be forced on every character, this is useful if you for example want to force every character to change where things is being delivered
local config_overrides = {
    --["Trading From"] = "Meow Meow@Cerberus",
    --["Trading To"] = "guh guh",
    --["Pickup At Estate"] = 0,
    --["Estate Type"] = 0,
    --["Pickup Zone"] = "Aleport",
    --["Pickup Server Location"] = "Cerberus",
    --["ReturnToHomeServer"] = false,
    --["ReturnToPlace"] = 0,
}

-- Here you can add items you want included with every trade
local always_include = {
    {5156, 100},
    {3423, 50},
    {3252, 35}
}

-- here you can adjust how many characters forward in the list you'd like to skip, in case something breaks
charstoskip = 0



--[[##############################################################
##               DON'T TOUCH ANYTHING BELOW HERE                ##
##              UNLESS YOU KNOW WHAT YOU'RE DOING               ##
################################################################]]

DeliveryListToLoad = "Delivery_List.lua"

SNDConfigFolder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
LoadFunctionsFileLocation = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(LoadFunctionsFileLocation)
LoadFunctions()
LoadFileCheck()

dofile(SNDAltConfigFolder .. DeliveryListToLoad)

-- ###############
-- # MAIN SCRIPT #
-- ###############

DropboxSetItemQuantity(1, false, 0)
local chars_processed = 0

for i, item in ipairs(Delivery_List) do
    local char_we_are_trading_from = item["Trading From"]
    local char_we_are_trading_to = item["Trading To"]
    local pickup_server = item["Pickup Server Location"]
    local pickup_zone = item["Pickup Location"]

    if GetCharacterName(true) == char_we_are_trading_from then
        LogInfo("Already on the right character: "..char_we_are_trading_from)
    else 
        LogInfo("Logging into: "..char_we_are_trading_from)
        ZoneCheck(129, "Limsa", "tp")
        RelogCharacter(char_we_are_trading_from)
        Sleep(7.5) -- This is enough time to log out completely and not too long to cut into new logins
        LoginCheck()
    end
    repeat
        Sleep(0.1)
    until IsPlayerAvailable()
    Echo("Delivering items to: " .. item["Trading To"])
    Echo("Processing " .. i .. "/" .. #Delivery_List .. ", current character: " .. char_we_are_trading_from)

    yield("/li " .. pickup_server)
        
    repeat
        Sleep(0.1)
    until GetCurrentWorld() == WorldIDList[pickup_server].ID and IsPlayerAvailable()

    -- Alt character destination type, how alt char is travelling to the main
    -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
    if destination_type == 0 then
        Echo("Teleporting to " .. pickup_zone .. " to find " .. char_we_are_trading_to)
        
        if destination_zone_id ~= GetZoneID() then
            Teleporter(destination_zone, "tp")
            ZoneTransitions()
        end
    end
    
    -- Requires main added to friend list for access to estate list teleports
    -- Keeping it for future stuff
    if destination_type > 0 then
        Echo("Teleporting to estate to find " .. char_we_are_trading_to)
        EstateTeleport(char_we_are_trading_to, destination_house)
    end

    -- I really don't like the repeat of destination_type checking here, should probably be refactored into stuff above
    -- Handle different destination types
    -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
    if destination_type == 0 or destination_type == 1 then
        -- Waits until main char is present
        WaitUntilObjectExists(main_char_name)
        
        -- Paths to main char only if you have do_movement set to true
        if do_movement then
            -- Path to main char
            PathToObject(main_char_name)
        end
        
        -- Invite main char to party, needs a target
        PartyInvite(main_char_name)
        
    elseif destination_type == 2 then
        -- If destination_type is 2, first go to the estate entrance, then to the main character
        PathToEstateEntrance()
        Interact()
        
        repeat
            Sleep(0.1)
            yield("/pcall SelectYesno true 0")
        until not IsAddonVisible("SelectYesno")
        
        -- Waits until main char is present
        WaitUntilObjectExists(main_char_name)
        
        -- Paths to main char only if you have do_movement set to true
        if do_movement then
            -- Path to main char
            PathToObject(main_char_name)
        end
        
        -- Invite main char to party, needs a target
        PartyInvite(main_char_name)
    end
    
    function ClearTrades()
        -- it's like this just to make sure it cleans the trades properly
        Sleep(0.5)
    end
    function PrepareTrade()





    end

    
    --        DropboxStart()
    --        Sleep(2.0)
    --        tradestatus = DropboxIsBusy()
    --        while tradestatus == true do
    --            tradestatus = DropboxIsBusy()
    --            LogInfo("[GCID] Currently trading...")
    --            Sleep(2.0)
    --        end
    --    end
    --end
    while not onlist do
        Echo("############################")
        Echo("Waiting for party invite")
        Echo("############################")
        repeat 
            PartyAccept()
            Sleep(0.1)
        until IsInParty()
        party_member = GetPartyMemberName(0)
        for index1, item1 in pairs(Delivery_List) do
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
