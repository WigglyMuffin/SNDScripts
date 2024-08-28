-- Stuff could go here

-- ###########
-- # CONFIGS #
-- ###########

-- Usage: First Last@Server
-- This is where your alts are listed
-- used for some simple scripts
local character_list = {
    "First Last@Server",
    "First Last@Server"
}

-- this is for use with the Kupo Box item pickup script
local character_list_kupobox = {
    {
        ["Name"] = "Large Meow@Sephirot", -- The name of the character you're logging in on
        ["Trading With"] = "Smol Meow", -- Character you're trading with, without world
        ["Destination Server"] = "Sephirot", -- Server you're going to pick up items on
        ["Destination Type"] = 0, -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
        ["Destination Aetheryte"] = "Aleport", -- Aetheryte to meet at if ["Destination Type"] is set to 0
        ["Destination House"] = 0, -- Options: 0 = FC, 1 = Personal, 2 = Apartment // Only active if ["Destination Type"] is set to 1 or 2
        ["Do Movement"] = false, -- Options: true, false // will move to the character you're trading to, usually this is done by the delivery character
        ["Return Home"] = false, -- Options: true, false // will just log out if set to false, otherwise will move to home server and to set location configured by ["Return Location"]
        ["Return Location"] = 0 -- Options: 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc 
    },
    {
        ["Name"] = "Larger Meow@Ravana", -- The name of the character you're logging in on
        ["Trading With"] = "Smol Meow", -- Character you're trading with, without world
        ["Destination Server"] = "Sephirot", -- Server you're going to pick up items on
        ["Destination Type"] = 0, -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
        ["Destination Aetheryte"] = "Aleport", -- Aetheryte to meet at if ["Destination Type"] is set to 0
        ["Destination House"] = 0, -- Options: 0 = FC, 1 = Personal, 2 = Apartment // Only active if ["Destination Type"] is set to 1 or 2
        ["Do Movement"] = false, -- Options: true, false // will move to the character you're trading to, usually this is done by the delivery character
        ["Return Home"] = false, -- Options: true, false // will just log out if set to false, otherwise will move to home server and to set location configured by ["Return Location"]
        ["Return Location"] = 0 -- Options: 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc 
    },
}

-- this is for use with the Post Moogle item delivery script
local character_list_postmoogle = {
    {
        ["Name"] = "Large Meow@Bismarck", -- The name of the character you're using to trade
        ["Trading With"] = "Smol Meow", -- Character you're trading with, without world
        ["Destination Server"] = "Sephirot", -- Server you're going to meet the recipient
        ["Destination Type"] = 0, -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
        ["Destination Aetheryte"] = "Aleport", -- Aetheryte to meet at if ["Destination Type"] is set to 0
        ["Destination House"] = 0, -- Options: 0 = FC, 1 = Personal, 2 = Apartment // Only active if ["Destination Type"] is set to 1 or 2
        ["Do Movement"] = false, -- Will move to the character you're trading to, usually this is done by the delivery character
        ["Return Home"] = false, -- Will just log out if set to false, otherwise will move to home server and to set location configured by ["Return Location"]. This is always processed after it no longer has any trades left
        ["Return Location"] = 0, -- 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc
        ["Items"] = {  -- This is where you configure what items each character is going to be delivering, the format is {ITEMNAME, AMOUNT}
            --{"Copper", 50}, -- It is not case sensitive, however it needs to be the full name so it doesn't accidentally get the wrong item
            --{"Gold Ore", 10}
        },
    },
    {
        ["Name"] = "Larger Meow@Sephirot", -- The name of the character you're using to trade
        ["Trading With"] = "Smol Meow", -- Character you're trading with, without world
        ["Destination Server"] = "Sephirot",  -- Server you're going to meet the recipient
        ["Destination Type"] = 0, -- Options: 0 = Aetheryte name, 1 = Estate and meet outside, 2 = Estate and meet inside
        ["Destination Aetheryte"] = "Aleport", -- Aetheryte to meet at if ["Destination Type"] is set to 0
        ["Destination House"] = 0, -- Options: 0 = FC, 1 = Personal, 2 = Apartment // Only active if ["Destination Type"] is set to 1 or 2
        ["Do Movement"] = false, -- Will move to the character you're trading to, usually this is done by the delivery character
        ["Return Home"] = false, -- Will just log out if set to false, otherwise will move to home server and to set location configured by ["Return Location"]. This is always processed after it no longer has any trades left
        ["Return Location"] = 0, -- 0 = do nothing, 1 = limsa, 2 = limsa bell, 3 = nearby bell, 4 = fc
        ["Items"] = {  -- This is where you configure what items each character is going to be delivering, the format is {ITEMNAME, AMOUNT}
            --{"Copper", 50}, -- It is not case sensitive, however it needs to be the full name so it doesn't accidentally get the wrong item
            --{"Gold Ore", 10}
        },
    },
}

-- #####################################
-- #  DON'T TOUCH ANYTHING BELOW HERE  #
-- # UNLESS YOU KNOW WHAT YOU'RE DOING #
-- #####################################

return {
    character_list = character_list,
    character_list_kupobox = character_list_kupobox,
    character_list_postmoogle = character_list_postmoogle
}