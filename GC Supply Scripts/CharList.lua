-- Stuff could go here

-- ###########
-- # CONFIGS #
-- ###########

-- Usage: First Last@Server
-- This is where your alts are listed
local character_list = {
    "First Last@Server",
    "First Last@Server",
    "First Last@Server",
    "First Last@Server",
    "First Last@Server"
}

-- Usage: First Last@Server, return_home, return_location
-- return_home options: 0 = no, 1 = yes
-- return_location options: 0 = fc entrance, 1 nearby bell, 2 limsa bell
-- This is where your alts that need items are listed
local character_list_options = {
    {"First Last@Server", 0, 2},
    {"First Last@Server", 0, 2},
    {"First Last@Server", 0, 2},
    {"First Last@Server", 0, 2},
    {"First Last@Server", 0, 2}
}

-- Usage: First Last@Server
-- This is where you can skip characters, either by choice or something went wrong
local character_list_skip = {
    "First Last@Server",
    "First Last@Server",
    "First Last@Server",
    "First Last@Server",
    "First Last@Server"
}

-- #####################################
-- #  DON'T TOUCH ANYTHING BELOW HERE  #
-- # UNLESS YOU KNOW WHAT YOU'RE DOING #
-- #####################################

return {
    character_list = character_list,
    character_list_options = character_list_options,
    character_list_skip = character_list_skip
}