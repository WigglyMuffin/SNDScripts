--[[

############################################################
##                         SCRIPT                         ##
##                          NAME                          ##
############################################################


####################
##    Version     ##
##     1.0.0      ##
####################

-> 1.0.0: Initial release

####################################################
##                  Description                   ##
####################################################

template of a script

####################################################
##                  Requirements                  ##
####################################################

-> a : link
-> b : link
-> c : link

####################################################
##                    Settings                    ##
##################################################]]

-- stuff can go here

--[[################################################
##                  Script Start                  ##
##################################################]]

snd_config_folder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
vac_config_folder = snd_config_folder .. "\\VAC\\"
load_functions_file_location = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(load_functions_file_location)()
LoadFileCheck()

-- Plugin checker
local required_plugins = {"a", "b", "c"}

if conditional_plugin then
    table.insert(required_plugins, "d")
end

if not CheckPluginsEnabled(unpack(required_plugins)) then
    return -- Stops script as plugins not available
end

if HasPlugin("YesAlready") then
    PauseYesAlready()
end

--[[###########
# MAIN SCRIPT #
#############]]

local function abc()
    -- stuff can go here
end

abc()

if HasPlugin("YesAlready") then
    RestoreYesAlready()
end