--[[
############################################################
##                         SCRIPT                         ##
##                          NAME                          ##
############################################################
https://patorjk.com/software/taag/#p=display&f=Standard&t= (optional to use this in place of above)

####################
##    Version     ##
##     1.0.0      ##
####################

-> 1.0.0: Initial release
   - Changed this
   - Changed that
   - Not required to create sub lists but it is helpful if there have been a lot of changes, instead you can do just the version and a brief description
-> 1.1.0: Such as this
-> 1.2.0: Changed how this works
-> 1.3.0: Don't forget to change the version above

####################################################
##                  Description                   ##
####################################################

https://github.com/WigglyMuffin/SNDScripts

Template of a script
Description of what it does and everything else a user needs to know

####################################################
##                  Requirements                  ##
####################################################

-> a_plugin : link
-> b_plugin : link
-> c_plugin : link
    -> Specific settings a plugin needs or requirements

Optional plugins:
-> d_plugin : link

####################################################
##                    Settings                    ##
##################################################]]

-- Put settings and everything a user should configure here

local a_setting = true                -- Options: true = Do this, false = Do that
local b_setting = 100                 -- This is how many do this happens

local conditional_plugin = true       -- Example to show optional plugin added to plugin check

--[[################################################
##                  Script Start                  ##
##################################################]]

snd_config_folder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
vac_config_folder = snd_config_folder .. "\\VAC\\"
load_functions_file_location = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(load_functions_file_location)()
LoadFileCheck()

-- Plugin checker
local required_plugins = { "a", "b", "c" }

if conditional_plugin then
    table.insert(required_plugins, "d")
end

if not CheckPluginsEnabled(unpack(required_plugins)) then
    return -- Stops script as plugins not available
end

if HasPlugin("YesAlready") then
    PauseYesAlready()
end

local function Main()
    -- Best to do things as functions and call them as they are needed than a top to down checklist of sorts
    -- So this could be the main function that calls other parts, check other scripts in our repo for examples of this structure
    
    -- Best to stay true to a specific coding style too, helps with readability and maintainability
    -- We use PascalCase for functions and snake_case for variables etc.
    -- Not required if you choose to change things but keep it in mind when using vac_functions and other files
end

Main()

if HasPlugin("YesAlready") then
    RestoreYesAlready()
end