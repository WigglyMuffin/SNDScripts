-- This script will rotate through your characters and generate a list of items needed for gc supply and output that file to the snd config folder
-- This file can then be used in other scripts to automate other tasks
--


ProvisioningListSaveName = "ProvisioningList.lua"
CharList = "CharList.lua"
-- you need to use the following format in your CharList.lua
-- place it in your snd config folder
-- located in %appdata%\xivlauncher\pluginConfigs\SomethingNeedDoing
-- usually anyway
-- i do it this way so you can share the same character list between scripts
-- chars = {
--     "EXAMPLE EXAMPLE@WORLD",
--     "EXAMPLE EXAMPLE@WORLD",
--     "EXAMPLE EXAMPLE@WORLD",
--     "EXAMPLE EXAMPLE@WORLD",
--     "EXAMPLE EXAMPLE@WORLD"
-- }

--##################################
--##################################
--##################################
--##################################

SNDConfigFolder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
LogInfo("[APL] ##############################")
LogInfo("[APL] Starting script...")
LogInfo("[APL] SNDConfigFolder: "..SNDConfigFolder)
LogInfo("[APL] ProvisioningListSaveName: "..ProvisioningListSaveName)
LogInfo("[APL] SNDC+PROV: "..SNDConfigFolder..""..ProvisioningListSaveName)
LogInfo("[APL] CharList: "..CharList)
LogInfo("[APL] SNDC+Char: "..SNDConfigFolder..""..CharList)
LogInfo("[APL] ##############################")
local ProvisioningList = {}
dofile(SNDConfigFolder..""..CharList)
yield("/echo "..chars[1])
BotanistList = {
    ["Latex"] = {ID = 5509},
    ["Allagan Snail"] = {ID = 5050},
    ["Maple Log"] = {ID = 5380},
    ["Cinnamon"] = {ID = 4828},
    ["Beehive Chip"] = {ID = 5516},
    ["Maple Branch"] = {ID = 5396},
    ["Cock Feather"] = {ID = 5351},
    ["Tinolqa Mistletoe"] = {ID = 5534},
    ["La Noscean Orange"] = {ID = 4809},
    ["Ash Log"] = {ID = 5383},
    ["Ash Branch"] = {ID = 5402},
    ["Kukuru Bean"] = {ID = 4803},
    ["Cloves"] = {ID = 4831},
    ["Rye"] = {ID = 4823},
    ["Sunset Wheat"] = {ID = 4824},
    ["Tree Toad"] = {ID = 5051},
    ["Grass Viper"] = {ID = 5560},
    ["Lavender"] = {ID = 5539},
    ["Straw"] = {ID = 5342},
    ["Carnation"] = {ID = 5540},
    ["Coerthan Carrot"] = {ID = 4778},
    ["La Noscean Lettuce"] = {ID = 4782},
    ["Black Pepper"] = {ID = 4830},
    ["Cieldalaes Spinach"] = {ID = 4783},
    ["Gridanian Chestnut"] = {ID = 4805},
    ["Alpine Parsnip"] = {ID = 4781},
    ["Highland Parsley"] = {ID = 4784},
    ["Ruby Tomato"] = {ID = 4780},
    ["Faerie Apple"] = {ID = 4810},
    ["Galago Mint"] = {ID = 4834},
    ["Paprika"] = {ID = 4785},
    ["Lalafellin Lentil"] = {ID = 4820},
    ["Sun Lemon"] = {ID = 4811},
    ["Belladonna"] = {ID = 5541},
    ["Nopales"] = {ID = 4786},
    ["Popoto"] = {ID = 4787},
    ["Gil Bun"] = {ID = 4796},
    ["Yew Log"] = {ID = 5386},
    ["White Scorpion"] = {ID = 5563},
    ["Yew Branch"] = {ID = 5405},
    ["Gridanian Walnut"] = {ID = 4806},
    ["Pixie Plums"] = {ID = 4812},
    ["Button Mushroom"] = {ID = 4797},
    ["Noble Grapes"] = {ID = 6145},
    ["Ala Mhigan Mustard"] = {ID = 4835},
    ["Matron's Mistletoe"] = {ID = 5535},
    ["Pearl Ginger"] = {ID = 4836},
    ["Walnut Log"] = {ID = 5388},
    ["Millioncorn"] = {ID = 4821},
    ["Sticky Rice"] = {ID = 4819},
    ["Jade Peas"] = {ID = 4822},
    ["Wizard Eggplant"] = {ID = 4788},
    ["Midland Cabbage"] = {ID = 4789},
    ["Chocobo Feather"] = {ID = 5359},
    ["Moor Leech"] = {ID = 5559},
    ["Flax"] = {ID = 5346},
    ["Oak Branch"] = {ID = 5409},
    ["Aloe"] = {ID = 4790},
    ["Midland Basil"] = {ID = 4837},
    ["Mandrake"] = {ID = 5543},
    ["White Truffle"] = {ID = 4798},
    ["Salt Leek"] = {ID = 4791},
    ["Wildfowl Feather"] = {ID = 5360},
    ["Desert Saffron"] = {ID = 4843},
    ["Dragon Pepper"] = {ID = 4838},
    ["Tarantula"] = {ID = 5562},
    ["Blood Currants"] = {ID = 4814},
    ["Iron Acorn"] = {ID = 4807},
    ["Mugwort"] = {ID = 4840},
    ["Maiden Artichoke"] = {ID = 4793},
    ["Nutmeg"] = {ID = 4844},
    ["Thyme"] = {ID = 4841},
    ["Almonds"] = {ID = 4842},
    ["Sagolii Sage"] = {ID = 4845},
    ["Black Scorpion"] = {ID = 5564},
    ["Mirror Apple"] = {ID = 6146},
    ["Rolanberry"] = {ID = 4815},
    ["Mistletoe"] = {ID = 5536},
    ["Dart Frog"] = {ID = 5054},
    ["Rosewood Log"] = {ID = 5393},
    ["Rosewood Branch"] = {ID = 5414},
    ["Thanalan Tea Leaves"] = {ID = 4846},
    ["Lava Toad"] = {ID = 5055},
    ["Cedar Branch"] = {ID = 5403},
    ["Cedar Log"] = {ID = 5384},
    ["Rainbow Cotton Boll"] = {ID = 12597},
    ["Mist Dill"] = {ID = 12883},
    ["Highland Wheat"] = {ID = 12880},
    ["Dark Chestnut Log"] = {ID = 12578},
    ["Stalk of Ramie"] = {ID = 12598},
    ["Dark Chestnut Branch"] = {ID = 12585},
    ["Magma Beet"] = {ID = 12885},
    ["Coneflower"] = {ID = 12638},
    ["Cow Bitter"] = {ID = 12639},
    ["Sesame Seeds"] = {ID = 12887},
    ["Birch Branch"] = {ID = 12586},
    ["Rue"] = {ID = 12642},
    ["Birch Sap"] = {ID = 12891},
    ["Coriander"] = {ID = 12643},
    ["Dandelion"] = {ID = 12640},
    ["Gaelicatnip"] = {ID = 12641},
    ["Loquat"] = {ID = 19851},
    ["Beech Log"] = {ID = 19930},
    ["Beech Branch"] = {ID = 19936},
    ["Buckwheat Kernels"] = {ID = 19850},
    ["Mountain Popoto"] = {ID = 19861},
    ["Gem Algae"] = {ID = 19881},
    ["Larch Log"] = {ID = 19931},
    ["Holy Basil"] = {ID = 19917},
    ["Ruby Cotton Boll"] = {ID = 19979},
    ["Pine Resin"] = {ID = 19908},
    ["Sugar Beet"] = {ID = 19856},
    ["Ama Nori"] = {ID = 19879},
    ["Shiitake Mushroom"] = {ID = 19863},
    ["Kudzu Root"] = {ID = 19853},
    ["Cumin Seeds"] = {ID = 19864},
    ["Persimmon Leaf"] = {ID = 19870},
    ["Daikon Radish"] = {ID = 19855},
    ["Fennel"] = {ID = 19867},
    ["Persimmon"] = {ID = 19869},
    ["Persimmon Log"] = {ID = 19932},
    ["Ruby Tide Kelp"] = {ID = 19880},
    ["Yanxian Parsley"] = {ID = 19911},
    ["Nagxian Cudweed"] = {ID = 19913},
    ["Chickweed"] = {ID = 19914},
    ["Doman Eggplant"] = {ID = 19854},
    ["Twincoon"] = {ID = 19989},
    ["Zelkova Log"] = {ID = 19933},
    ["Frantoio"] = {ID = 27820},
    ["White Oak Log"] = {ID = 27683},
    ["White Oak Branch"] = {ID = 27816},
    ["Blood Tomato"] = {ID = 27825},
    ["Miracle Apple Log"] = {ID = 27684},
    ["Garden Beet"] = {ID = 27824},
    ["Iridescent Cocoon"] = {ID = 27750},
    ["Upland Wheat"] = {ID = 27832},
    ["White Ash Log"] = {ID = 27685},
    ["Pixie Floss Boll"] = {ID = 27753},
    ["Gianthive Chip"] = {ID = 27834},
    ["Creamtop Mushroom"] = {ID = 27829},
    ["Royal Grapes"] = {ID = 27826},
    ["Amber Cloves"] = {ID = 27821},
    ["Sandteak Log"] = {ID = 27686},
    ["Sweet Alyssum"] = {ID = 27779},
    ["Fernleaf Lavender"] = {ID = 27780},
    ["Harcot"] = {ID = 27819},
    ["Lime Basil"] = {ID = 27783},
    ["Coffee Beans"] = {ID = 27837},
    ["Tiger Lily"] = {ID = 27784},
    ["Light Gerbera"] = {ID = 27785},
    ["Dwarven Cotton Boll"] = {ID = 27759},
    ["Lignum Vitae Log"] = {ID = 27687},
    ["Ironwood Log"] = {ID = 36193},
    ["Sykon"] = {ID = 36096},
    ["Giant Popoto"] = {ID = 36089},
    ["Elder Nutmeg Seeds"] = {ID = 36095},
    ["Sideritis Leaves"] = {ID = 36094},
    ["AR-Caean Cotton Boll"] = {ID = 36206},
    ["Integral Log"] = {ID = 36194},
    ["Alien Onion"] = {ID = 36097},
    ["Snow Cotton"] = {ID = 44024},
    ["Eucalyptus"] = {ID = 44042},
    ["Ut'ohmu Tomato"] = {ID = 43978},
    ["Ginseng Log"] = {ID = 44014},
    ["Wild Ja Tiika Bananas"] = {ID = 43990},
    ["Turali Aloe"] = {ID = 43989},
    ["Ceiba Log"] = {ID = 44015},
    ["Royal Maple Sap"] = {ID = 43979},
    ["Mountain Flax"] = {ID = 44025},
    ["Kozama'uka Chamomile"] = {ID = 44040},
    ["Shaaloani Oilseeds"] = {ID = 43980},
    ["Dark Mahogany Log"] = {ID = 44016},
    ["Sweet Kukuru Bean"] = {ID = 43991},
    ["Turali Corn"] = {ID = 43981},
    ["White Pepper"] = {ID = 43986},
    ["Sarcenet"] = {ID = 44026},
    ["Turali Pineapple"] = {ID = 43988},
    ["Acacia Log"] = {ID = 44017},
    ["Claro Walnut Log"] = {ID = 44018},
    ["Acacia Bark"] = {ID = 44052},
    ["Levinsilk"] = {ID = 44028},
    ["Mesquite Beans"] = {ID = 43987},
    ["Wind Parsley"] = {ID = 44039},
    ["Bell Pepper"] = {ID = 43984},
    ["Yyasulani Garlic"] = {ID = 43985},
    ["Broccoli"] = {ID = 43983},
    ["Windsbalm Bay Leaf"] = {ID = 44041},
    ["Pearl Grass"] = {ID = 44043},
}

FisherList = {
    ["Crayfish"] = {ID = 4925},
    ["Merlthor Goby"] = {ID = 4869},
    ["Chub"] = {ID = 4926},
    ["Dwarf Catfish"] = {ID = 4928},
    ["Striped Goby"] = {ID = 4927},
    ["Bone Crayfish"] = {ID = 4929},
    ["Princess Trout"] = {ID = 4930},
    ["Dusk Goby"] = {ID = 4931},
    ["Pipira"] = {ID = 4932},
    ["Crimson Crayfish"] = {ID = 4933},
    ["Gudgeon"] = {ID = 4934},
    ["Vongola Clam"] = {ID = 4875},
    ["Maiden Carp"] = {ID = 4936},
    ["Mudskipper"] = {ID = 4939},
    ["Rainbow Trout"] = {ID = 4940},
    ["River Crab"] = {ID = 4941},
    ["Ala Mhigan Fighting Fish"] = {ID = 4942},
    ["Acorn Snail"] = {ID = 4944},
    ["La Noscean Perch"] = {ID = 4946},
    ["Navigator's Dagger"] = {ID = 4882},
    ["Angelfish"] = {ID = 4883},
    ["Moat Carp"] = {ID = 4947},
    ["Bluebell Salmon"] = {ID = 4949},
    ["Mudcrab"] = {ID = 4950},
    ["Tricolored Carp"] = {ID = 4951},
    ["Blowfish"] = {ID = 4886},
    ["Jade Eel"] = {ID = 4953},
    ["Pond Mussel"] = {ID = 4954},
    ["Warmwater Trout"] = {ID = 4955},
    ["Four-eyed Fish"] = {ID = 4957},
    ["Glass Perch"] = {ID = 4956},
    ["Saber Sardine"] = {ID = 4887},
    ["Blue Octopus"] = {ID = 4885},
    ["Ogre Barracuda"] = {ID = 4888},
    ["Aegis Shrimp"] = {ID = 4960},
    ["Monkfish"] = {ID = 4889},
    ["Sea Bo"] = {ID = 4890},
    ["Bianaq Bream"] = {ID = 4891},
    ["Climbing Perch"] = {ID = 4962},
    ["Shadow Catfish"] = {ID = 4963},
    ["Lamprey"] = {ID = 4965},
    ["Plaguefish"] = {ID = 4966},
    ["Spotted Pleco"] = {ID = 4968},
    ["Grip Killifish"] = {ID = 4970},
    ["Ropefish"] = {ID = 4969},
    ["Bone Cleaner"] = {ID = 4971},
    ["Monke Onke"] = {ID = 4975},
    ["Root Skipper"] = {ID = 4972},
    ["Bonytongue"] = {ID = 4973},
    ["Haraldr Haddock"] = {ID = 4899},
    ["Mitten Crab"] = {ID = 4974},
    ["Sandfish"] = {ID = 4977},
    ["Clown Loach"] = {ID = 4979},
    ["Sand Bream"] = {ID = 5032},
    ["Silverfish"] = {ID = 4978},
    ["Armored Pleco"] = {ID = 4980},
    ["Balloonfish"] = {ID = 4902},
    ["Desert Catfish"] = {ID = 5033},
    ["Dustfish"] = {ID = 5034},
    ["Spotted Puffer"] = {ID = 4983},
    ["Velodyna Carp"] = {ID = 4982},
    ["Storm Rider"] = {ID = 5035},
    ["Trader Eel"] = {ID = 4985},
    ["Antlion Slug"] = {ID = 5036},
    ["Discus"] = {ID = 4987},
    ["Dune Manta"] = {ID = 5037},
    ["Silver Shark"] = {ID = 4903},
    ["Loyal Pleco"] = {ID = 4990},
    ["Thunderbolt Sculpin"] = {ID = 4991},
    ["Fall Jumper"] = {ID = 4992},
    ["Knifefish"] = {ID = 4993},
    ["Wahoo"] = {ID = 4904},
    ["Common Sculpin"] = {ID = 4995},
    ["Oakroot"] = {ID = 4994},
    ["Archerfish"] = {ID = 4999},
    ["Cloud Jellyfish"] = {ID = 5038},
    ["Southern Pike"] = {ID = 4996},
    ["Agelyss Carp"] = {ID = 5001},
    ["Goblin Perch"] = {ID = 5000},
    ["Pike Eel"] = {ID = 4907},
    ["Assassin Betta"] = {ID = 5002},
    ["Mummer Wrasse"] = {ID = 4908},
    ["Skyfish"] = {ID = 5039},
    ["Blind Manta"] = {ID = 5041},
    ["Garpike"] = {ID = 5005},
    ["Plaice"] = {ID = 4909},
    ["Boxing Pleco"] = {ID = 5008},
    ["Paglth'an Discus"] = {ID = 5007},
    ["Rift Sailor"] = {ID = 5042},
    ["Kissing Trout"] = {ID = 5009},
    ["Sagolii Monkfish"] = {ID = 5043},
    ["Saucerfish"] = {ID = 5044},
    ["Cloud Coral"] = {ID = 12714},
    ["Ice Faerie"] = {ID = 12715},
    ["Skyworm"] = {ID = 12716},
    ["Fanged Clam"] = {ID = 12719},
    ["Sorcerer Fish"] = {ID = 12726},
    ["Whilom Catfish"] = {ID = 12721},
    ["Maiboi"] = {ID = 12728},
    ["Seema Patrician"] = {ID = 12737},
    ["Sky Faerie"] = {ID = 12753},
    ["Ammonite"] = {ID = 12738},
    ["Bubble Eye"] = {ID = 12739},
    ["Kissing Fish"] = {ID = 12743},
    ["Cloud Rider"] = {ID = 12760},
    ["Marble Oscar"] = {ID = 12750},
    ["Mercy Staff"] = {ID = 12765},
    ["Blue Medusa"] = {ID = 12771},
    ["Gobbie Mask"] = {ID = 12770},
    ["Shadowhisker"] = {ID = 12769},
    ["Cometoise"] = {ID = 12787},
    ["Orn Butterfly"] = {ID = 12781},
    ["Philosopher's Stone"] = {ID = 12790},
    ["Letter Puffer"] = {ID = 12793},
    ["Rockclimber"] = {ID = 12811},
    ["Rudderfish"] = {ID = 12805},
    ["Battle Galley"] = {ID = 12817},
    ["Cobrafish"] = {ID = 12813},
    ["Winged Gurnard"] = {ID = 12822},
    ["Black Magefish"] = {ID = 12826},
    ["Hinterlands Perch"] = {ID = 12819},
    ["Vampiric Tapestry"] = {ID = 12834},
    ["Miounnefish"] = {ID = 20058},
    ["Ruby Coral"] = {ID = 20095},
    ["Brindlebass"] = {ID = 20166},
    ["Gliding Fish"] = {ID = 20106},
    ["Hermit Goby"] = {ID = 20177},
    ["Yanxian Koi"] = {ID = 20118},
    ["Red-eyed Lates"] = {ID = 20182},
    ["Sun Bass"] = {ID = 20130},
    ["Bowfish"] = {ID = 20134},
    ["Tengu Fan"] = {ID = 20188},
    ["Dotharli Gudgeon"] = {ID = 20202},
    ["Dragonfish"] = {ID = 20116},
    ["Bull's Bite"] = {ID = 20076},
    ["Tithe Collector"] = {ID = 20216},
    ["Bashful Batfish"] = {ID = 20217},
    ["Meditator"] = {ID = 20073},
    ["Flamefish"] = {ID = 20231},
    ["Whitehorse"] = {ID = 20035},
    ["Asteroidea"] = {ID = 27412},
    ["Lakelouse"] = {ID = 27519},
    ["Misty Killifish"] = {ID = 27433},
    ["Shade Gudgeon"] = {ID = 27523},
    ["Hornhelm"] = {ID = 27460},
    ["Misteye"] = {ID = 27532},
    ["Daisy Turban"] = {ID = 27538},
    ["Rebel"] = {ID = 27476},
    ["Petalfish"] = {ID = 27545},
    ["Spotted Ctenopoma"] = {ID = 27478},
    ["Clown Tetra"] = {ID = 27490},
    ["Dandyfish"] = {ID = 27550},
    ["Hunter's Arrow"] = {ID = 27553},
    ["Flowering Kelpie"] = {ID = 27558},
    ["Ghoulfish"] = {ID = 27559},
    ["Silver Kitten"] = {ID = 27493},
    ["Blue Lightning"] = {ID = 27564},
    ["Desert Saw"] = {ID = 27464},
    ["Jester Fish"] = {ID = 27563},
    ["Deep Purple Coral"] = {ID = 27495},
    ["Hermit Crab"] = {ID = 27575},
    ["Anpa's Handmaid"] = {ID = 27579},
    ["Diamondtongue"] = {ID = 27573},
    ["Hoodwinker"] = {ID = 27500},
    ["Onihige"] = {ID = 36549},
    ["Peacock Bass"] = {ID = 36392},
    ["Cloudy Cat Shark"] = {ID = 36553},
    ["Mesonauta"] = {ID = 36404},
    ["False Fusilier"] = {ID = 36565},
    ["Fate's Design"] = {ID = 36425},
    ["Crown Fish"] = {ID = 36557},
    ["Flowerhorn"] = {ID = 36448},
    ["Smooth Lumpfish"] = {ID = 36561},
    ["Blue Shark"] = {ID = 36559},
    ["Imperial Pleco"] = {ID = 36461},
    ["Keeled Fugu"] = {ID = 36563},
    ["Lunar Cichlid"] = {ID = 36465},
    ["Meyhane Reveler"] = {ID = 36537},
    ["Pale Panther"] = {ID = 36585},
    ["Antheia"] = {ID = 36484},
    ["Red-spotted Blenny"] = {ID = 36567},
    ["Spicy Pickle"] = {ID = 36529},
    ["Blue Marlin"] = {ID = 36533},
    ["Bluefin Trevally"] = {ID = 36579},
    ["Vacuum Shrimp"] = {ID = 36489},
    ["Class Twenty-four"] = {ID = 36510},
    ["Floral Snakehead"] = {ID = 36545},
    ["Mini Yasha"] = {ID = 36575},
    ["Dusky Shark"] = {ID = 36547},
    ["E.B.E.-9318"] = {ID = 36519},
    ["Uzumaki"] = {ID = 36581},
    ["Blue Purse"] = {ID = 43673},
    ["Petticoat Tetra"] = {ID = 43666},
    ["Shark Catfish"] = {ID = 43806},
    ["Candiru"] = {ID = 43695},
    ["Severum"] = {ID = 43809},
    ["Lau Lau"] = {ID = 43819},
    ["First Feastfish"] = {ID = 43684},
    ["Charcoal Eel"] = {ID = 43817},
    ["Tsoly Turtle"] = {ID = 43825},
    ["Corn Dace"] = {ID = 43706},
    ["Variegated Sisterscale"] = {ID = 43815},
    ["Turali Land Crab"] = {ID = 43823},
    ["Archmatron Angelfish"] = {ID = 43725},
    ["Ihuyka Colossoma"] = {ID = 43813},
    ["Horizon Crocodile"] = {ID = 43827},
    ["Zorgor Scorpion"] = {ID = 43759},
    ["Turali Beaded Lizard"] = {ID = 43733},
    ["Variatus"] = {ID = 43738},
    ["Xty'iinbek Sleeper"] = {ID = 43748},
    ["Azure Glider"] = {ID = 43763},
    ["Deadleaf Minnow"] = {ID = 43835},
    ["Tiger Muskellunge"] = {ID = 43768},
    ["Mosaic Loach"] = {ID = 43779},
    ["Frillfin Goby"] = {ID = 43831},
    ["Crackling Flounder"] = {ID = 43774},
    ["Sauger"] = {ID = 43845},
    ["Minted Arowana"] = {ID = 43839},
    ["Harlequin Lancer"] = {ID = 43783},
    ["Canal Drum"] = {ID = 43790},
    ["Speckled Peacock Bass"] = {ID = 43833},
}

MinerList = {
    ["Copper Ore"] = {ID = 5106},
    ["Muddy Water"] = {ID = 5488},
    ["Bone Chip"] = {ID = 5432},
    ["Tin Ore"] = {ID = 5107},
    ["Raw Lapis Lazuli"] = {ID = 5133},
    ["Soiled Femur"] = {ID = 5433},
    ["Zinc Ore"] = {ID = 5110},
    ["Obsidian"] = {ID = 5124},
    ["Copper Sand"] = {ID = 5268},
    ["Rock Salt"] = {ID = 5518},
    ["Ragstone"] = {ID = 5228},
    ["Iron Ore"] = {ID = 5111},
    ["Iron Sand"] = {ID = 5269},
    ["Cinnabar"] = {ID = 5519},
    ["Raw Malachite"] = {ID = 5130},
    ["Raw Fluorite"] = {ID = 5132},
    ["Raw Danburite"] = {ID = 5129},
    ["Alumen"] = {ID = 5524},
    ["Sunrise Tellin"] = {ID = 5465},
    ["Mudstone"] = {ID = 5229},
    ["Earth Rock"] = {ID = 5155},
    ["Silver Sand"] = {ID = 5270},
    ["Fire Rock"] = {ID = 5152},
    ["Ice Rock"] = {ID = 5153},
    ["Lightning Rock"] = {ID = 5156},
    ["Wind Rock"] = {ID = 5154},
    ["Water Rock"] = {ID = 5157},
    ["Bomb Ash"] = {ID = 5528},
    ["Silex"] = {ID = 5523},
    ["Wyvern Obsidian"] = {ID = 5125},
    ["Brimstone"] = {ID = 5527},
    ["Siltstone"] = {ID = 5231},
    ["Raw Garnet"] = {ID = 5134},
    ["Raw Heliodor"] = {ID = 5137},
    ["Mythril Sand"] = {ID = 5271},
    ["Raw Goshenite"] = {ID = 5135},
    ["Raw Peridot"] = {ID = 5136},
    ["Mythril Ore"] = {ID = 5114},
    ["Raw Aquamarine"] = {ID = 5139},
    ["Raw Tourmaline"] = {ID = 5142},
    ["Raw Spinel"] = {ID = 5144},
    ["Raw Zircon"] = {ID = 5141},
    ["Jade"] = {ID = 5168},
    ["Black Alumen"] = {ID = 5525},
    ["Grenade Ash"] = {ID = 5526},
    ["Raw Turquoise"] = {ID = 5145},
    ["Electrum Sand"] = {ID = 5272},
    ["Electrum Ore"] = {ID = 5115},
    ["Raw Amber"] = {ID = 5143},
    ["Raw Rubellite"] = {ID = 5140},
    ["Basilisk Egg"] = {ID = 5263},
    ["Cobalt Ore"] = {ID = 5116},
    ["Adamantoise Shell"] = {ID = 5458},
    ["Dragon Obsidian"] = {ID = 5126},
    ["Ogre Horn"] = {ID = 5439},
    ["Yellow Copper Ore"] = {ID = 5108},
    ["Mythrite Sand"] = {ID = 12531},
    ["Pyrite"] = {ID = 5109},
    ["Raw Agate"] = {ID = 12553},
    ["Raw Tiger's Eye"] = {ID = 12552},
    ["Yellow Quartz"] = {ID = 5162},
    ["Chalcocite"] = {ID = 12941},
    ["Raw Larimar"] = {ID = 12551},
    ["Dravanian Spring Water"] = {ID = 12631},
    ["Limonite"] = {ID = 5112},
    ["Raw Mormorion"] = {ID = 12559},
    ["Green Quartz"] = {ID = 5161},
    ["Raw Star Ruby"] = {ID = 12554},
    ["Raw Star Sapphire"] = {ID = 12555},
    ["Fossilized Dragon Bone"] = {ID = 13761},
    ["Hardsilver Sand"] = {ID = 12532},
    ["Abalathian Spring Water"] = {ID = 12632},
    ["Light Kidney Ore"] = {ID = 5117},
    ["Raw Opal"] = {ID = 12556},
    ["Cloud Mica"] = {ID = 12539},
    ["Cuprite"] = {ID = 12942},
    ["Raw Carnelian"] = {ID = 12560},
    ["Aurum Regis Sand"] = {ID = 12533},
    ["Raw Citrine"] = {ID = 12557},
    ["Tektite"] = {ID = 13759},
    ["Eventide Jade"] = {ID = 13760},
    ["Raw Chrysolite"] = {ID = 12558},
    ["Wyrm Obsidian"] = {ID = 5127},
    ["Gyr Abanian Mineral Water"] = {ID = 19871},
    ["Koppranickel Sand"] = {ID = 19950},
    ["Stiperstone"] = {ID = 5232},
    ["Raw Kyanite"] = {ID = 19969},
    ["Slate"] = {ID = 20007},
    ["Diatomite"] = {ID = 20006},
    ["Koppranickel Ore"] = {ID = 19951},
    ["Crescent Spring Water"] = {ID = 19872},
    ["Doman Iron Ore"] = {ID = 19953},
    ["Durium Sand"] = {ID = 19952},
    ["Doman Iron Sand"] = {ID = 19955},
    ["Durium Ore"] = {ID = 19954},
    ["Palladium Sand"] = {ID = 19956},
    ["Molybdenum Ore"] = {ID = 19957},
    ["Hard Mudstone"] = {ID = 27801},
    ["Truegold Sand"] = {ID = 27696},
    ["Truegold Ore"] = {ID = 27697},
    ["Highland Spring Water"] = {ID = 27968},
    ["Bluespirit Ore"] = {ID = 27698},
    ["Manasilver Sand"] = {ID = 27699},
    ["Titancopper Sand"] = {ID = 27700},
    ["Titancopper Ore"] = {ID = 27701},
    ["Underground Spring Water"] = {ID = 27782},
    ["Dimythrite Sand"] = {ID = 27702},
    ["Dimythrite Ore"] = {ID = 27703},
    ["High Durium Sand"] = {ID = 36162},
    ["Raw Ametrine"] = {ID = 36174},
    ["High Durium Ore"] = {ID = 36163},
    ["Pewter Ore"] = {ID = 36175},
    ["Phrygian Gold Ore"] = {ID = 36176},
    ["Eblan Alumen"] = {ID = 36241},
    ["Bismuth Ore"] = {ID = 36164},
    ["Manganese Ore"] = {ID = 36165},
    ["Raw Blue Zircon"] = {ID = 36177},
    ["Annite"] = {ID = 36181},
    ["Ambrosial Water"] = {ID = 36263},
    ["Chondrite"] = {ID = 36166},
    ["Raw Star Quartz"] = {ID = 36178},
    ["Mountain Chromite Ore"] = {ID = 43992},
    ["Lar Ore"] = {ID = 44002},
    ["Mountain Rock Salt"] = {ID = 43982},
    ["Raw Ihuykanite"] = {ID = 44003},
    ["Ruthenium Ore"] = {ID = 43993},
    ["Cobalt Tungsten Ore"] = {ID = 43994},
    ["Raw Pink Beryl"] = {ID = 44004},
    ["Yak T'el Spring Water"] = {ID = 44034},
    ["Titanium Gold Ore"] = {ID = 43995},
    ["Magnesia Powder"] = {ID = 44007},
    ["Raw Black Star"] = {ID = 44006},
    ["White Gold Ore"] = {ID = 44005},
    ["Ra'Kaznar Ore"] = {ID = 43996},
}

function OpenTimers()
    repeat
        yield("/timers")
        yield("/wait 0.1")
    until IsAddonVisible("ContentsInfo")
    repeat
        yield("/pcall ContentsInfo True 12 1")
        yield("/wait 0.1")
    until IsAddonVisible("ContentsInfoDetail")
    repeat
        yield("/timers")
        yield("/wait 0.1")
    until not IsAddonVisible("ContentsInfo")
end

function SerializeTable(val, name, depth)
    depth = depth or 0
    local result = ""
    local indent = string.rep("  ", depth)

    if name then
        result = result .. indent .. name .. " = "
    end

    if type(val) == "table" then
        result = result .. "{\n"
        for k, v in pairs(val) do
            local key
            if type(k) == "string" then
                key = string.format("[%q]", k)
            else
                key = "[" .. k .. "]"
            end
            result = result .. SerializeTable(v, key, depth + 1) .. ",\n"
        end
        result = result .. indent .. "}"
    elseif type(val) == "string" then
        result = result .. string.format("%q", val)
    elseif type(val) == "number" or type(val) == "boolean" then
        result = result .. tostring(val)
    else
        error("Unsupported data type: " .. type(val))
    end

    return result
end

function GetAndSaveProvisioningToTable()
    for _, char in ipairs(chars) do
        LogInfo("[APL] Processing char number ".._)
        if GetCharacterName(true) == char then
            LogInfo("[APL] Already on the right character: "..char)
        else 
            LogInfo("[APL] Logging into: "..char)
            yield("/ays relog " ..char)
            yield("<wait.15.0>")
            yield("/waitaddon NamePlate <maxwait.6000><wait.5>")
        end
        repeat
            yield("/wait 0.1")
        until IsPlayerAvailable()
        OpenTimers()

        local CharacterName = GetCharacterName(true)
        function ContainsLetters(input)
            if input:match("%a") then
                return true
            else
                return false
            end
        end
        local MinerText = GetNodeText("ContentsInfoDetail", 101, 5)
        if ContainsLetters(MinerText) then
            LogInfo("[APL] Node text found, continuing")
        else
            LogInfo("[APL] Node text not found, skipping to next char")
            goto skip
        end
        local BotanistText = GetNodeText("ContentsInfoDetail", 100, 5)
        local FisherText = GetNodeText("ContentsInfoDetail", 99, 5)

        local MinerItemID = MinerList[MinerText].ID
        local BotanistItemID = BotanistList[BotanistText].ID
        local FisherItemID = FisherList[FisherText].ID

        local MinerItemAmount = GetNodeText("ContentsInfoDetail", 101, 2)
        local BotanistItemAmount = GetNodeText("ContentsInfoDetail", 100, 2)
        local FisherItemAmount = GetNodeText("ContentsInfoDetail", 99, 2)
        local CharNameClean = GetCharacterName()
        ProvisioningList[_] = {CharNameClean = CharNameClean, CharNameWithWorld = CharacterName, MinerItemName = MinerText, MinerItemID = MinerItemID, MinerItemQty = MinerItemAmount,BotanistItemName = BotanistText, BotanistItemID = BotanistItemID, BotanistItemQty = BotanistItemAmount,FisherItemName = FisherText, FisherItemID = FisherItemID, FisherItemQty = FisherItemAmount}
        ::skip::
    end
end

function Main()
    GetAndSaveProvisioningToTable()
    local ProvisioningListString = "ProvisioningList = " .. SerializeTable(ProvisioningList)
    local File = io.open(SNDConfigFolder..""..ProvisioningListSaveName, "w")
    File:write(ProvisioningListString)
    File:close()
end

Main()
