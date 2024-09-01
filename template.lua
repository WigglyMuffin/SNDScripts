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


####################################################
##                  Requirements                  ##
####################################################

-> 
-> 
-> 
-> 
-> 
-> 
-> 

####################################################
##                    Settings                    ##
##################################################]]

-- stuff can go here




--[[################################################
##                  Script Start                  ##
##################################################]]

snd_config_folder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
load_functions_file_location = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(load_functions_file_location)
LoadFunctions()
LoadFileCheck()

if not CheckPluginsEnabled() then
    return -- Stops script as plugins not available
end

if HasPlugin("YesAlready") then
    PauseYesAlready()
end

-- stuff can go here

if HasPlugin("YesAlready") then
    RestoreYesAlready()
end