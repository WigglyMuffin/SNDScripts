--[[
############################################################
##                        Overseer                        ##
##                        Launcher                        ##
############################################################

####################################################
##                  Description                   ##
####################################################

https://github.com/WigglyMuffin/SNDScripts

Launcher for the Overseer script, set this to the script that runs on Autoretainer Postprocess

####################################################
##                  Requirements                  ##
####################################################

-->  
--> The ability to set this script to run on Autoretainer Postprocess inside of the snd options

####################################################
##                    Settings                    ##
##################################################]]

local overseer_script_name = "Overseer" -- This is what you have the script named in snd, preferably left to default

--[[################################################
##                  Script Start                  ##
##################################################]]

ARFinishCharacterPostProcess()
if not IsMacroRunningOrQueued(overseer_script_name) then
    yield("/runmacro " .. overseer_script_name)
end