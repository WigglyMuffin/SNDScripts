--[[

############################################################
##                       Post Moogle                      ##
##                 Character List Generator               ##
############################################################


####################
##    Version     ##
##     1.1.0      ##
####################

-> 1.0.0: Initial release
   - Basic functionality to generate partner list for Post Moogle
   - Support for multiple partner characters

-> 1.0.1: Comprehensive update for partner-specific functionality
   - Adapted core structure from Post Moogle character list generator
   - Implemented inverse behavior to complement main Kupo Box generator for Post Moogle:
     * gen_char_list now represents partner characters to trade with
     * trading_with_list now represents the main trading character(s)
   - Added flexibility for various trading scenarios:
     * Support for single main trader with multiple partners
     * Support for multiple main traders with multiple partners
   - Incorporated item list functionality from Post Moogle script
   - Enhanced server destination logic:
     * Added set_destination_server_to_home_server option for automatic server assignment
   - Improved comments and variable names for better readability and maintenance
   
-> 1.1.0: Major update to improve flexibility and usability
   - Reworked logic to handle various trading scenarios:
     * Single delivery character trading with multiple partners
     * Multiple delivery characters trading with multiple partners
   - Improved handling of gen_char_list and trading_with_list:
     * gen_char_list now represents the delivery characters
     * trading_with_list now represents the characters to trade with
   - Enhanced flexibility in list handling:
     * Supports cases where gen_char_list has more entries than trading_with_list
     * Handles scenarios where trading_with_list has more entries than gen_char_list
   - Implemented flexible entry generation based on the larger of the two lists
   - Improved cyclic assignment logic to handle any list size discrepancy
   - Maintained item configuration support with always_include list
   - Enhanced server destination logic:
     * Kept set_destination_server_to_home_server option for automatic server assignment
   - Refined code structure for better readability and maintenance
   - Updated comments and variable names for clarity
   - Ensured compatibility with the main Post Moogle script

####################################################
##                  Description                   ##
####################################################

The Post Moogle Character List Generator is a versatile Lua script designed to create character configurations for Post Moogle.

Key Features:
1. Character-Centric Design: Optimised for setting up characters who will be sending or receiving items through Post Moogle.
2. Flexible Delivery Scenarios: Supports both one-to-many and many-to-many delivery.
3. Trading Partner Configuration: Uses gen_char_list for delivery characters and trading_with_list for recipient characters.
4. Destination Server Logic: Includes options for specifying destination servers for each character.
5. Item Listing: Incorporates functionality to specify items and quantities for each character to deliver.
6. Output Compatibility: Generates a Lua table (character_list_postmoogle.lua) that can be directly inserted into vac_char_list or Post Moogle configurations.
7. Customizable Delivery Parameters: Allows specification of delivery locations, movement options, and return behaviors.

This script is particularly useful for players managing complex item deliveries. It provides a streamlined way to configure characters for Post Moogle deliveries, ensuring efficient and organised item exchanges.

####################################################
##                Required Plugins                ##
####################################################

-> SomethingNeedDoing

#####################
##    Settings     ##
###################]]

-- Set the characters you're generating a list with, these are the partners to trade with
local gen_char_list = {
    "Mrow Mrow@Louisoix",   -- Trading partner 1 for main trading character
    "Smol Meow@Lich",       -- Trading partner 2 for main trading character
    "Beeg Meow@Zodiark"     -- Trading partner 3 for main trading character
}

-- Here you can define the main trading character(s).
-- If only one character is listed, it will be used as the main trading partner for all entries in gen_char_list
local trading_with_list = {
    "Mrow Mrow@Louisoix",    -- Main trading character
    -- "Smol Meow@Lich",     -- Uncomment to add more main trading characters
    -- "Beeg Meow@Zodiark"   -- Uncomment to add more main trading characters
}

-- Here you set the default settings each character will have when generated

local destination_server = "Zodiark" -- Set this to the server you're meeting the delivery character on
local destination_type = 0 -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
local destination_aetheryte = "Aleport" -- Aetheryte to meet at if ["Destination Type"] is set to 0
local destination_house = 0 -- Options: 0 = FC, 1 = Personal, 2 = Apartment // Only active if ["Destination Type"] is set to 1 or 2
local do_movement = false -- Options: true, false // will move to the character you're trading to, usually this is done by the delivery character
local return_home = false -- Options: true, false // will just log out if set to false, otherwise will move to home server and to set location configured by ["Return Location"]
local return_location = 0 -- Options: 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc 

local items = {
    -- This is where you configure what items each character is going to be delivering, the format is {"ITEMNAME", AMOUNT}
    -- If you want to do it character specific you have to edit the generated character list afterwards
    -- It is not case sensitive, however it needs to be the full name so it doesn't accidentally get the wrong item
    -- Add or remove as you wish, can even leave it empty just fine
    { "Salvaged Ring", 99999 },
    { "Salvaged Bracelet", 99999 },
    { "Salvaged Earring", 99999 },
    { "Salvaged Necklace", 99999 },
    { "Extravagant Salvaged Ring", 99999 },
    { "Extravagant Salvaged Bracelet", 99999 },
    { "Extravagant Salvaged Earring", 99999 },
    { "Extravagant Salvaged Necklace", 99999 }
}

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
            ["Items"] = items,
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
                "Return Location",
                "Items"
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

    file:write("local character_list_postmoogle = {\n")
    
    for _, char in ipairs(data) do
        file:write("    {\n")
        local order = char["_order"]
        for _, key in ipairs(order) do
            local value = char[key]
            if type(value) == "string" then
                file:write(string.format("        [\"%s\"] = \"%s\",\n", key, value))
            elseif type(value) == "table" then
                file:write(string.format("        [\"%s\"] = {\n", key))
                for _, item in ipairs(value) do
                    file:write(string.format("            { \"%s\", %d },\n", item[1], item[2]))
                end
                file:write("        },\n")
            else
                file:write(string.format("        [\"%s\"] = %s,\n", key, tostring(value)))
            end
        end
        file:write("    },\n")
    end

    file:write("}\n")
    file:close()
end

write_to_file("character_list_postmoogle.lua", character_list_options)

if HasPlugin("YesAlready") then
    RestoreYesAlready()
end
