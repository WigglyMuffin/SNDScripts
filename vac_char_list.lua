-- Stuff could go here

-- ###########
-- # CONFIGS #
-- ###########

-- Usage: First Last@Server
-- This is where your alts are listed
local character_list = {
    "First Last@Server",
    "First Last@Server"
}

-- this is for use with the KupoBox item pickup script
local character_list_options = {
    {
        ["Name"] = "Large Meow@Bismarck", -- the name of the character you're logging in on
        ["Trading With"] = "Smol Meow", -- character you're trading with, without world
        ["Destination Server"] = "Sephirot", -- server you're going to pick up items on
        ["Destination Type"] = 0, -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
        ["Destination Aetheryte"] = "Aleport", -- aetheryte to meet at if ["Destination Type"] is set to 0
        ["Destination House"] = 0, -- Options: 0 = FC, 1 = Personal, 2 = Apartment // Only active if ["Destination Type"] is set to 1 or 2
        ["Do Movement"] = false, -- will move to the character you're trading to, usually this is done by the delivery character
        ["Return Home"] = false, -- will just log out if set to false, otherwise will move to home server and to set location configured by ["Return Location"]
        ["Return Location"] = 0 -- 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc 
    },
    {
        ["Name"] = "Larger Meow@Ravana", -- the name of the character you're logging in on
        ["Trading With"] = "Smol Meow", -- character you're trading with, without world
        ["Destination Server"] = "Sephirot", -- server you're going to pick up items on
        ["Destination Type"] = 0, -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
        ["Destination Aetheryte"] = "Aleport", -- aetheryte to meet at if ["Destination Type"] is set to 0
        ["Destination House"] = 0, -- Options: 0 = FC, 1 = Personal, 2 = Apartment // Only active if ["Destination Type"] is set to 1 or 2
        ["Do Movement"] = false, -- will move to the character you're trading to, usually this is done by the delivery character
        ["Return Home"] = false, -- will just log out if set to false, otherwise will move to home server and to set location configured by ["Return Location"]
        ["Return Location"] = 0 -- 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc 
    },
}

-- Usage: First Last@Server
-- This is where you can skip characters, either by choice or something went wrong
local character_list_skip = {
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