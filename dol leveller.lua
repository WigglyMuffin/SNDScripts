-- Ideally used with The Road to 90 buff, otherwise it will take double the amount for everything
-- You need approx 2m gil per character you wish to level through this with The Road to 90, probably 4mil with no buff (no clue, you won't have the double xp though)
-- You likely only need around 20-30 per item it asks for, fish 2-3, very unlikely you need more than that, don't spend more than 20k or try not to
-- This is not a full automated script (yet, maybe maybe not)
-- It will teleport you to a market board, you are required to purchase the items the GC asks for, after that it will auto turnin and log off, you will need to start the script again for additional characters
-- If the market board does not have the item you need, stop the script and go to another world, start the script again
-- Closing the market board early doesn't matter either, cancel the tp and buy items, then /tp limsa
-- You should use the Yes Already plugin to bypass the capped seals warning or it will break the script

--##########################################
--   CONFIGS
--##########################################


--##########################################
--   DON'T TOUCH ANYTHING BELOW HERE 
--   UNLESS YOU KNOW WHAT YOU'RE DOING
--##########################################

Loadfiyel = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
FunctionsToLoad = loadfile(Loadfiyel)
FunctionsToLoad()
DidWeLoadcorrectly()

--##############
--  DOL STUFF
--##############

function DOL()
    OpenTimers()
    Teleporter("Ul'dah", "tp")
    ZoneTransitions()
    yield("/li mb")
    ZoneTransitions()
    MarketBoardChecker() -- should probably add auto buying here or something
    Teleporter("Limsa", "tp")
    ZoneTransitions()
    yield("/li Aftcastle")
    ZoneTransitions()
    Movement(93.00 40.27 75.60)
    OpenGcSupplyWindow(1)
    GcProvisioningDeliver(3)
    LogOut()
end

--##########################################
--  MAIN SCRIPT
--##########################################
function main()
    DOL()
end

main()
