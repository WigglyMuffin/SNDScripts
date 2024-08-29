--[[

############################################################
##                        Kupo Box                        ##
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

Generates a character list you can insert into vac_char_list for use with Kupo Box, or directly into Kupo Box itself

####################################################
##                Required Plugins                ##
####################################################

-> None

#####################
##    Settings     ##
###################]]
-- set the characters you're generating a list with, the list generates in order
-- you could technically just copy the character_list from the vac_char_list if you have one there into this

local gen_char_list = {
    "Mrow Mrow@Louisoux",
    "Smol Meow@Lich",
    "Beeg Meow@Zodiark",
}

-- Here you set the default settings each character will have when generated

local trading_with = "Meow meow"   -- The name of the character you're trading with
local destination_server = "Zodiark" -- Set this to the server you're meeting the delivery character on
local destination_type = 0 -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
local destination_aetheryte = "Aleport" -- Aetheryte to meet at if ["Destination Type"] is set to 0
local destination_house = 0 -- Options: 0 = FC, 1 = Personal, 2 = Apartment // Only active if ["Destination Type"] is set to 1 or 2
local do_movement = false -- Options: true, false // will move to the character you're trading to, usually this is done by the delivery character
local return_home = false -- Options: true, false // will just log out if set to false, otherwise will move to home server and to set location configured by ["Return Location"]
local return_location = 0 -- Options: 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc 

-- This option if set to true will override destination_server and set it to that chars home server
-- If the list is in order it can be used to make everything faster as the characters do not have to travel anywhere, 
-- they just meet the trader on their server at the set location
local set_destination_server_to_home_server = true


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

local function extract_world_from_name(char_name)
    local at_position = string.find(char_name, "@")
    if at_position then
        return string.sub(char_name, at_position + 1)
    end
    return nil
end

local function generate_character_list_options()
    local character_list_options = {}

    for _, char in ipairs(gen_char_list) do
        local char_name = char
        local server_to_use = destination_server
        
        -- If set_destination_server_to_home_server is true, extract the world from the character name
        if set_destination_server_to_home_server then
            server_to_use = extract_world_from_name(char_name) or destination_server
        end
        
        -- Insert the character data into the list and maintain order
        table.insert(character_list_options, {
            ["Name"] = char_name,
            ["Trading With"] = trading_with,
            ["Destination Server"] = server_to_use,
            ["Destination Type"] = destination_type,
            ["Destination Aetheryte"] = destination_aetheryte,
            ["Destination House"] = destination_house,
            ["Do Movement"] = do_movement,
            ["Return Home"] = return_home,
            ["Return Location"] = return_location,
            -- Order list
            ["_order"] = {
                "Name",
                "Trading With",
                "Destination Server",
                "Destination Type",
                "Destination Aetheryte",
                "Destination House",
                "Do Movement",
                "Return Home",
                "Return Location"
            }
        })
    end

    return character_list_options
end

local character_list_options = generate_character_list_options()

local function write_to_file(filename, data)
    local tools_folder = vac_config_folder .. "Tools\\"
    EnsureFolderExists(vac_config_folder)
    EnsureFolderExists(tools_folder)
    local file = io.open(tools_folder .. filename, "w")

    file:write("local character_list_kupobox = {\n")
    
    for _, char in ipairs(data) do
        file:write("    {\n")
        local order = char["_order"]
        for _, key in ipairs(order) do
            local value = char[key]
            if type(value) == "string" then
                file:write(string.format("        [\"%s\"] = \"%s\",\n", key, value))
            else
                file:write(string.format("        [\"%s\"] = %s,\n", key, tostring(value)))
            end
        end
        file:write("    },\n")
    end

    file:write("}\n")
    file:close()
end

write_to_file("Kupo Box chars.lua", character_list_options)