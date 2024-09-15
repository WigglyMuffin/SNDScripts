--[[
############################################################
##                      Retainer Maker                    ##
##                 Character List Generator               ##
############################################################


####################
##    Version     ##
##     1.0.0      ##
####################

-> 1.0.0: Initial release

####################################################
##                  Description                   ##
####################################################

Generates a character list you can insert into the retainer maker script

if outputs the list into %appdata%\XIVLauncher\pluginConfigs\SomethingNeedDoing\VAC\Tools
aka the snd config folder for that installation

####################################################
##                Required Plugins                ##
####################################################

-> None

#####################
##    Settings     ##
###################]]

local gen_char_list = {
    "Mrow Mrow@Louisoux",
    "Smol Meow@Lich",
    "Beeg Meow@Zodiark",
}

-- can leave this empty
local retainer_jobs_to_include_on_all = {
    {"MIN", 1},
    {"BTN", 1}
}


--[[#################################
#  DON'T TOUCH ANYTHING BELOW HERE  #
# UNLESS YOU KNOW WHAT YOU'RE DOING #
#####################################

###################
# FUNCTION LOADER #
#################]]


snd_config_folder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
vac_config_folder = snd_config_folder .. "\\VAC\\"
load_functions_file_location = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(load_functions_file_location)
LoadFunctions()
LoadFileCheck()

--[[###########
# MAIN SCRIPT #
#############]]

local tools_folder = vac_config_folder .. "Tools\\"
EnsureFolderExists(vac_config_folder)
EnsureFolderExists(tools_folder)

-- Open file for writing in the tools folder
local file = io.open(tools_folder .. "Make Retainers Chars.lua", "w")

-- Create the desired output structure
local function generate_character_list()
    file:write("local chars = {\n")
    for _, char_str in ipairs(gen_char_list) do
        file:write("{\n")
        file:write("    [\"Character Name\"] = \"" .. char_str .. "\",\n")
        file:write("    [\"Retainers\"] = {\n")
        for _, retainer in ipairs(retainer_jobs_to_include_on_all) do
            file:write("        {\"" .. retainer[1] .. "\", " .. retainer[2] .. "},\n")
        end
        file:write("    }\n")
        file:write("},\n")
    end
    file:write("}")
end

-- Write the formatted list to the file
generate_character_list()

-- Close the file
file:close()