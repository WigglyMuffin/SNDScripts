--[[
Fat Tony script

This is a pair script for the bagman script. basically it will load x chars go to location to wait for deliveries. when it receives a 1 gil trade, it knows its time to switch to next char.
it won't do anything really different than bagman.

This script is a modified version of mcvaxius's script with improvements to make it faster and more consistent, also removes the reliancy on the functions file as i felt it was not needed here.
]]
--[[

requires plugins
Lifestream
Teleporter
Pandora -> TURN OFF AUTO NUMERICS
automaton -> TURN OFF AUTO NUMERICS
Dropbox -> autoconfirm
Visland
Vnavmesh
Simpletweaks -> enable targeting fix
YesAlready -> /Enter .*/

Optional:
Autoretainer
Liza's plugin : Kitchen Sink if you want to use her queue method
]]
tonys_turf = "Sagittarius" --what server will our tonies run to
tonys_spot = "Solution 9" --where we tping to aka aetheryte name
tony_zoneID = 186 --this is the zone id for where the aetheryte is, if its anything other than 0, it will be evaluated to see if your already in teh zone for cases of multi transfer from or to same
tonys_house = 0 --0 fc 1 personal 2 apartment. don't judge. tony doesnt trust your bagman to come to the big house
tony_type = 0 --0 = specific aetheryte name, 1 first estate in list outside, 2 first estate in list inside

--if all of these are not 42069420, then we will try to go there at the very end of the process otherwise we will go directly to fat tony himself
tony_x = 42069420
tony_y = 42069420
tony_z = 42069420

--[[
tony firstname, lastname, meeting locationtype, returnhome 1 = yes 0 = no, 0 = fc entrance 1 = nearby bell 2 = limsa bell
]]
local franchise_owners = {
    {"EXAMPLE EXAMPLE@World", 1, 2},
    {"EXAMPLE EXAMPLE@World", 1, 2},
    {"EXAMPLE EXAMPLE@World", 1, 2},
    {"EXAMPLE EXAMPLE@World", 1, 2},
    {"EXAMPLE EXAMPLE@World", 1, 2}
}

--loadfiyel = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\_functions.lua"
--functionsToLoad = loadfile(loadfiyel)
--functionsToLoad()
--DidWeLoadcorrectly()

--the boss wants that monthly gil payment, have your bagman ready with the gil.
--If he has to come pick it up himself its gonna get messy
WorldIDList={["Cerberus"]={ID=80},["Louisoix"]={ID=83},["Moogle"]={ID=71},["Omega"]={ID=39},["Phantom"]={ID=401},["Ragnarok"]={ID=97},["Sagittarius"]={ID=400},["Spriggan"]={ID=85},["Alpha"]={ID=402},["Lich"]={ID=36},["Odin"]={ID=66},["Phoenix"]={ID=56},["Raiden"]={ID=403},["Shiva"]={ID=67},["Twintania"]={ID=33},["Zodiark"]={ID=42},["Adamantoise"]={ID=73},["Cactuar"]={ID=79},["Faerie"]={ID=54},["Gilgamesh"]={ID=63},["Jenova"]={ID=40},["Midgardsormr"]={ID=65},["Sargatanas"]={ID=99},["Siren"]={ID=57},["Balmung"]={ID=91},["Brynhildr"]={ID=34},["Coeurl"]={ID=74},["Diabolos"]={ID=62},["Goblin"]={ID=81},["Malboro"]={ID=75},["Mateus"]={ID=37},["Zalera"]={ID=41},["Cuchulainn"]={ID=408},["Golem"]={ID=411},["Halicarnassus"]={ID=406},["Kraken"]={ID=409},["Maduin"]={ID=407},["Marilith"]={ID=404},["Rafflesia"]={ID=410},["Seraph"]={ID=405},["Behemoth"]={ID=78},["Excalibur"]={ID=93},["Exodus"]={ID=53},["Famfrit"]={ID=35},["Hyperion"]={ID=95},["Lamia"]={ID=55},["Leviathan"]={ID=64},["Ultros"]={ID=77},["Bismarck"]={ID=22},["Ravana"]={ID=21},["Sephirot"]={ID=86},["Sophia"]={ID=87},["Zurvan"]={ID=88},["Aegis"]={ID=90},["Atomos"]={ID=68},["Carbuncle"]={ID=45},["Garuda"]={ID=58},["Gungnir"]={ID=94},["Kujata"]={ID=49},["Tonberry"]={ID=72},["Typhon"]={ID=50},["Alexander"]={ID=43},["Bahamut"]={ID=69},["Durandal"]={ID=92},["Fenrir"]={ID=46},["Ifrit"]={ID=59},["Ridill"]={ID=98},["Tiamat"]={ID=76},["Ultima"]={ID=51},["Anima"]={ID=44},["Asura"]={ID=23},["Chocobo"]={ID=70},["Hades"]={ID=47},["Ixion"]={ID=48},["Masamune"]={ID=96},["Pandaemonium"]={ID=28},["Titan"]={ID=61},["Belias"]={ID=24},["Mandragora"]={ID=82},["Ramuh"]={ID=60},["Shinryu"]={ID=29},["Unicorn"]={ID=30},["Valefor"]={ID=52},["Yojimbo"]={ID=31},["Zeromus"]={ID=32}}

yield("/ays multi d")
fat_tony = "Firstname Lastname" --ignore this dont set it

function visland_stop_moving()
    muuv = 1
    muuvX = GetPlayerRawXPos()
    muuvY = GetPlayerRawYPos()
    muuvZ = GetPlayerRawZPos()
    while muuv == 1 do
       yield("/wait 1")
       if muuvX == GetPlayerRawXPos() and muuvY == GetPlayerRawYPos() and muuvZ == GetPlayerRawZPos() then
           muuv = 0
       end
       muuvX = GetPlayerRawXPos()
       muuvY = GetPlayerRawYPos()
       muuvZ = GetPlayerRawZPos()
    end
    --yield("/echo movement stopped - time for GC turn ins or whatever")
    yield("/echo movement stopped safely - script proceeding to next bit")
    yield("/visland stop")
    yield("/vnavmesh stop")
    yield("/wait 0.5")
    --added becuase simpletweaks is slow to update :(
end

function CharacterSafeWait()
yield("/waitaddon NamePlate <maxwait.600> <wait.5>")
 --ZoneTransition()
repeat
yield("/wait 0.1")
until IsPlayerAvailable()
end

local function distance(x1, y1, z1, x2, y2, z2)
    if type(x1) ~= "number" then
        x1 = 0
    end
    if type(y1) ~= "number" then
        y1 = 0
    end
    if type(z1) ~= "number" then
        z1 = 0
    end
    if type(x2) ~= "number" then
        x2 = 0
    end
    if type(y2) ~= "number" then
        y2 = 0
    end
    if type(z2) ~= "number" then
        z2 = 0
    end
    zoobz = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 2)
    if type(zoobz) ~= "number" then
        zoobz = 0
    end
    --return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
    return zoobz
end

local function approach_tony()
    local specific_tony = 0
    if tony_x ~= 42069420 and tony_y ~= 42069420 and tony_z ~= 42069420 then
        specific_tony = 1
    end
    if specific_tony == 0 then
        PathfindAndMoveTo(GetObjectRawXPos(fat_tony), GetObjectRawYPos(fat_tony), GetObjectRawZPos(fat_tony), false)
    end
    if specific_tony == 1 then
        PathfindAndMoveTo(tony_x, tony_y, tony_z, false)
    end
end

local function approach_entrance()
    PathfindAndMoveTo(GetObjectRawXPos("Entrance"), GetObjectRawYPos("Entrance"), GetObjectRawZPos("Entrance"), false)
end

geel = 0
local function shake_hands()
    gilxit = 0
    bababobo = 0
    while gilxit == 0 do
        bababobo = bababobo + 1
        yield("/wait 1")
        if bababobo > 15 then
            yield("/echo where is this bagman, im gonna teach them a lesson....")
            bababobo = 0
        end
        if GetGil() > geel then
            if (GetGil() - geel) == 1 then
                gilxit = 1 --we are done, get out next tony time
                yield("/echo allright time to deliver this to the boss")
            end
        end
        geel = GetGil()
    end
end

function ZoneTransition()
iswehehe = IsPlayerAvailable() 
iswoah = 0
    repeat 
        yield("/wait 0.5")
        yield("/echo Are we ready? -> "..iswoah.."/20")
iswehehe = IsPlayerAvailable() 
iswoah = iswoah + 1
if iswoah == 20 then
iswehehe = false
end
    until not iswehehe
iswoah = 0
    repeat 
        yield("/wait 0.5")
        yield("/echo Are we ready? (backup check)-> "..iswoah.."/20")
iswehehe = IsPlayerAvailable() 
iswoah = iswoah + 1
if iswoah == 20 then
iswehehe = true
end
    until iswehehe
end

function return_to_limsa_bell()
yield("/tp Limsa Lominsa")
ZoneTransition()
yield("/wait 2")
yield("/wait 1")
yield("/pcall SelectYesno true 0")
PathfindAndMoveTo(-125.440284729, 18.0, 21.004405975342, false)
visland_stop_moving() --added so we don't accidentally end before we get to the inn person
end

for i = 1, #franchise_owners do
    --update tony's name
    fat_tony = franchise_owners[i][1]

    yield(
        "/echo Loading tony to recieve protection payments Fat Tony -> " ..
            fat_tony .. ".  Tony -> " .. franchise_owners[i][1]
    )
    yield("/echo Processing Tony " .. i .. "/" .. #franchise_owners)

    --only switch chars if the bagman is changing. in some cases we are delivering to same tony or different tonies. we dont care about the numbers
    if GetCharacterName(true) ~= franchise_owners[i][1] then
        yield("/ays relog " .. franchise_owners[i][1])
        yield("/wait 2")
        CharacterSafeWait()
    end

    yield("/echo Processing Tony " .. i .. "/" .. #franchise_owners)

    --allright time for a road trip. tony needs that bag
    road_trip = 1 --we took a road trip
    --now we must head to the place we are meeting this filthy animal
    --first we have to find his neighbourhood, this uber driver better not complain
    --are we on the right server already?
    local homeworld = GetHomeWorld()
    yield("/li " .. tonys_turf)
    repeat
        yield("/wait 0.1")
    until GetCurrentWorld() == WorldIDList[tonys_turf].ID
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable()
    yield("/echo Processing Tony " .. i .. "/" .. #franchise_owners)

    --now we have to walk or teleport?!!?!? to fat tony, where is he waiting this time?
    if tony_type == 0 then
        yield("/echo " .. fat_tony .. " is meeting us in the alleyways.. watch your back")
        if tony_zoneID ~= GetZoneID() then --we are teleporting to Tony's spot
            yield("/tp " .. tonys_spot)
            yield("/wait 2")
            yield("/pcall SelectYesno true 0")
            ZoneTransition()
        end
    end
    if tony_type > 0 then
        yield("/echo " .. fat_tony .. " is meeting us at the estate, we will approach with respect")
        yield("/estatelist " .. fat_tony)
        yield("/wait 0.5")
        --very interesting discovery
        --1= personal, 0 = fc, 2 = apartment
        yield("/pcall TeleportHousingFriend true " .. tonys_house)
        ZoneTransition()
    end
    geel = GetGil() --get the initial geel value

    --ok this filthy animal is nearby. let's approach this guy, weapons sheathed, we are just doing business
    if tony_type == 0 then
        approach_tony()
        visland_stop_moving()
    end
    if tony_type == 1 then
        approach_entrance()
        visland_stop_moving()
        if tony_type == 2 then
            yield("/interact")
            yield("/pcall SelectYesno true 0")
            yield("/wait 5")
        end
        approach_tony()
        visland_stop_moving()
    end
    shake_hands() -- its a business doing pleasure with you tony as always
    if road_trip == 1 then --we need to get home
        --time to go home.. maybe?
        if franchise_owners[i][2] == 0 then
            yield("/echo wait why can't i leave " .. fat_tony .. "?")
        end
        if franchise_owners[i][2] == 1 then
            yield("/li")
            yield("/echo See ya " .. fat_tony .. ", a pleasure.")
            repeat
                yield("/wait 0.1")
            until GetCurrentWorld() == homeworld
            repeat
                yield("/wait 0.1")
            until IsPlayerAvailable()
            if franchise_owners[i][3] == 0 then
                yield("/tp Estate Hall")
                ZoneTransition()
                yield("/waitaddon NamePlate <maxwait.600><wait.5>")
                --normal small house shenanigans
                yield("/hold W <wait.1.0>")
                yield("/release W")
                yield("/target Entrance <wait.1>")
                yield("/lockon on")
                yield("/automove on <wait.2.5>")
                yield("/automove off <wait.1.5>")
                yield("/hold Q <wait.2.0>")
                yield("/release Q")
            end
            --retainer bell nearby shenanigans
            if franchise_owners[i][3] == 1 then
                yield('/target "Summoning Bell"')
                yield("/wait 2")
                PathfindAndMoveTo(
                    GetObjectRawXPos("Summoning Bell"),
                    GetObjectRawYPos("Summoning Bell"),
                    GetObjectRawZPos("Summoning Bell"),
                    false
                )
                visland_stop_moving() --added so we don't accidentally end before we get to the bell
            end
            --limsa bell
            if franchise_owners[i][3] == 2 then
                yield("/echo returning to limsa bell")
                return_to_limsa_bell()
            end
        end
    end
end

--what you thought your job was done you ugly mug? get back to work you gotta pay up that gil again next month!
--boss please i just collected the stuff be nice
