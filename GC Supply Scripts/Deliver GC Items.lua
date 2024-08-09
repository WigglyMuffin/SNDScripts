-- This script assumes you have all the items needed on all characters and delivers them to their gc
-- This is a fully automated script
-- You should use the Yes Already plugin to bypass the capped seals warning or it will break the script

--###########
--# CONFIGS #
--###########

-- this toggle allows you to run the script on as many characters as you'd like, it'll rotate between them
MULTICHAR = true

CharList = "CharList.lua"
-- you need to use the following format in your CharList.lua
-- i do it this way so you can share the same character list between scripts
-- chars = {
--     "EXAMPLE EXAMPLE@WORLD",
--     "EXAMPLE EXAMPLE@WORLD",
--     "EXAMPLE EXAMPLE@WORLD",
--     "EXAMPLE EXAMPLE@WORLD",
--     "EXAMPLE EXAMPLE@WORLD"
-- }


--#####################################
--#  DON'T TOUCH ANYTHING BELOW HERE  #
--# UNLESS YOU KNOW WHAT YOU'RE DOING #
--#####################################
SNDConfigFolder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
LoadFunctionsFileLocation = SNDConfigFolder.."vac_functions.lua"
LoadFunctions = loadfile(LoadFunctionsFileLocation)
LoadFunctions()
LoadFileCheck()

-- load character list from file
dofile(SNDConfigFolder..""..CharList)

--##############
--  DOL STUFF
--##############

function DOL()
    local home = false
    if GetCurrentWorld() == GetHomeWorld() then
        home = true
    else
        if GetZoneID() ~= 129 then
            Teleporter("Limsa", "tp")
            ZoneTransitions()
        end
        yield("/li")
    end
    repeat
        Sleep(0.1)
        if GetCurrentWorld() == GetHomeWorld() then
            if GetCurrentWorld() == 0 and GetHomeWorld() == 0 then
            else
                home = true
            end
        end
    until home
    repeat
        Sleep(0.1)
    until IsPlayerAvailable()
    if GetZoneID() ~= 129 then
        Teleporter("Limsa", "tp")
        ZoneTransitions()
    end
    yield("/li Aftcastle")
    ZoneTransitions()
    Movement(93.00, 40.27, 75.60)
    OpenGcSupplyWindow(1)
    GcProvisioningDeliver(3)
    CloseGcSupplyWindow()
    LogOut()
end

--###############
--# MAIN SCRIPT #
--###############

function Main()
    DOL()
end

if MULTICHAR then
    for _, char in ipairs(chars) do
        if GetCharacterName(true) == char then
            -- continue, no relogging needed
        else
            yield("/ays relog " ..char)
            yield("<wait.15.0>")
            yield("/waitaddon NamePlate <maxwait.6000><wait.5>")
        end
        repeat
            yield("/wait 0.1")
        until IsPlayerAvailable()
        Main()
    end
else
    Main()
end
