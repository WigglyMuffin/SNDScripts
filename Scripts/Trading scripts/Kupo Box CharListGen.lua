--[[

############################################################
##                        Kupo Box                        ##
##                 Character List Generator               ##
############################################################


####################
##    Version     ##
##     1.1.0      ##
####################

-> 1.0.0: Initial release
   - Basic functionality to generate character list for Kupo Box
   - Support for multiple characters and trading partners

-> 1.0.1: Enhanced functionality
   - Added support for more trading partners than characters
   - Implemented cyclic character assignment when there are more trading partners

-> 1.0.2: Major update to improve flexibility and usability
   - Reworked logic to handle various trading scenarios:
     * Single main character trading with multiple partners
     * Multiple characters trading with multiple partners
   - Improved handling of gen_char_list and trading_with_list:
     * If gen_char_list has one entry, it's used as the main trading character for all partners
     * If gen_char_list has multiple entries, they're paired with trading_with_list entries
   - Enhanced server destination logic:
     * Added set_destination_server_to_home_server option for automatic server assignment
   - Refined code structure for better readability and maintenance
   - Updated comments and variable names for clarity
   
-> 1.1.0: Comprehensive revision for correct list handling and enhanced flexibility
   - Corrected the roles of gen_char_list and trading_with_list:
     * gen_char_list now represents the "Trading With" entries
     * trading_with_list now represents the "Name" entries
   - Implemented flexible entry generation based on the larger of the two lists
   - Added support for all possible list combinations:
     * Single entry in gen_char_list with multiple entries in trading_with_list
     * Multiple entries in gen_char_list with fewer entries in trading_with_list
     * Equal number of entries in both lists
   - Improved cyclic assignment logic to handle any list size discrepancy
   - Maintained compatibility with existing server destination and movement options
   - Further refined code structure and comments for improved clarity and maintainability

####################################################
##                  Description                   ##
####################################################

The Kupo Box Character List Generator is a versatile Lua script designed to streamline the process of creating character configurations for Kupo Box.

Key Features:
1. Flexible Character Management: Supports configuration for multiple characters and trading partners.
2. Dynamic Trading Scenarios: Handles various setups, including one-to-many and many-to-many trading.
3. Server Destination Logic: Includes an option to automatically set destination servers based on characters' home servers.
4. Customisable Trading Parameters: Allows specification of trading locations, movement options, and return behaviours.
5. Item Configuration: Supports detailed item listings for each character, including item names and quantities.
6. Output Compatibility: Generates a Lua table (character_list_kupobox.lua) that can be directly inserted into vac_char_list or Kupo Box configurations.

This script is ideal for players managing multiple characters or complex trading arrangements, offering a powerful tool to automate and organise character setups for efficient item exchanges.

####################################################
##                Required Plugins                ##
####################################################

-> SomethingNeedDoing

#####################
##    Settings     ##
###################]]

-- Set the characters you're generating a list with, the list generates in order
-- If only one character is listed, it will be used as the main trading partner for all entries in trading_with_list
local gen_char_list = {
    "Mrow Mrow@Louisoix",    -- Main trading character
    -- "Smol Meow@Lich",     -- Uncomment to add more main trading characters
    -- "Beeg Meow@Zodiark"   -- Uncomment to add more main trading characters
}

-- Here you can define a list of trading partners.
-- If gen_char_list has only one entry, this list determines the number of entries generated.
local trading_with_list = {
    "Mrow Mrow@Louisoix",   -- Trading partner 1 for main trading character
    "Smol Meow@Lich",       -- Trading partner 2 for main trading character
    "Beeg Meow@Zodiark"     -- Trading partner 3 for main trading character
}

-- Here you set the default settings each character will have when generated

local destination_server = "Zodiark" -- Set this to the server you're meeting the delivery character on
local destination_type = 0 -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
local destination_aetheryte = "Aleport" -- Aetheryte to meet at if ["Destination Type"] is set to 0
local destination_house = 0 -- Options: 0 = FC, 1 = Personal, 2 = Apartment // Only active if ["Destination Type"] is set to 1 or 2
local do_movement = true -- Options: true, false // will move to the character you're trading to, usually this is done by the delivery character
local return_home = false -- Options: true, false // will just log out if set to false, otherwise will move to home server and to set location configured by ["Return Location"]
local return_location = 0 -- Options: 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc 

-- This option if set to true will override destination_server and set it to that chars home server
-- If the list is in order it can be used to make everything faster as the characters do not have to travel anywhere, 
-- they just meet the trader on their server at the set location
local set_destination_server_to_home_server = false

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

if not CheckPluginsEnabled("SomethingNeedDoing") then
    return -- Stops script as plugins not available
end

if HasPlugin("YesAlready") then
    PauseYesAlready()
end

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

local function strip_after_at(input_string)
    local result = string.match(input_string, "([^@]+)")
    return result
end

local function generate_character_list_options()
    local character_list_options = {}
    local num_chars = #gen_char_list
    local num_trading_partners = #trading_with_list

    local entries_to_generate = math.max(num_chars, num_trading_partners)

    for i = 1, entries_to_generate do
        local trading_with_index = ((i - 1) % num_chars) + 1
        local name_index = ((i - 1) % num_trading_partners) + 1

        local char_name = trading_with_list[name_index]
        local trading_with_t = strip_after_at(gen_char_list[trading_with_index])

        local server_to_use = destination_server
        
        -- If set_destination_server_to_home_server is true, extract the world from the character name
        if set_destination_server_to_home_server then
            server_to_use = extract_world_from_name(char_name) or destination_server
        end
        
        -- Insert the character data into the list and maintain order
        table.insert(character_list_options, {
            ["Name"] = char_name,
            ["Trading With"] = trading_with_t,
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

write_to_file("character_list_kupobox.lua", character_list_options)

if HasPlugin("YesAlready") then
    RestoreYesAlready()
end
