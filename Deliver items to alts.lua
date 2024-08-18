-- This script is to be used on your main to automatically trade the right items to your alts as they show up
-- The alts should be running the improved tony script to come and pick stuff up at the location you've set in that script
-- It bases the trades off the order the character list was in so make sure it's all consistent
-- if you have everything configured right it's just start the script, go afk and you have eventually delivered all items to your alts

-- ###########
-- # CONFIGS #
-- ###########
-- Set your alt accounts %appdata% config location otherwise it will not work
SNDAltConfigFolder = "C:\\Users\\ff14lowres\\AppData\\Roaming\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"


-- #####################################
-- #  DON'T TOUCH ANYTHING BELOW HERE  #
-- # UNLESS YOU KNOW WHAT YOU'RE DOING #
-- #####################################

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
local listlength = 0
local chars_processed = 0

for index, item in ipairs(Delivery_List) do
    local current_char = item["Trading from"]
    if GetCharacterName(true) == current_char then
        LogInfo("[APL] Already on the right character: "..current_char)
    else 
        LogInfo("[APL] Logging into: "..current_char)
        ZoneCheck(129, "Limsa", "tp")
        RelogCharacter(current_char)
        Sleep(7.5) -- This is enough time to log out completely and not too long to cut into new logins
        LoginCheck()
    end
    repeat
        Sleep(0.1)
    until IsPlayerAvailable()
    
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
