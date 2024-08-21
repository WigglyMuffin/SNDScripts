-- This script will generate a file in the SNDConfigFolder which lists all the items you need to get to make the Deliver items to alt script fully automatic
-- as long as you make sure you have all the items this script tells you to get you should be able to proceed without issue

-- by default uses the output from the script that generates a provisioninglist
-- probably don't touch this

-- ###########
-- # CONFIGS #
-- ###########

-- Configuration is not required for this file

-- #####################################
-- #  DON'T TOUCH ANYTHING BELOW HERE  #
-- # UNLESS YOU KNOW WHAT YOU'RE DOING #
-- #####################################

ProvisioningListNameToLoad = "ProvisioningList.lua"

SNDConfigFolder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
dofile(SNDConfigFolder .. ProvisioningListNameToLoad)

local outputFilename = "List_to_gather.txt"
local outputFolder = SNDConfigFolder .. "Lists\\"

if not os.execute("cd " .. outputFolder) then
    os.execute("mkdir " .. outputFolder)
end

local function combineItemsByCategory(ProvisioningList)
    local categoryTotals = {}
    
    local categoryNames = {
        MIN = "Miner",
        BTN = "Botanist",
        FSH = "Fisher"
    }
    
    for _, data in pairs(ProvisioningList) do
        for category, itemData in pairs(data) do
            if type(itemData) == "table" and itemData["Item"] then
                local itemName = itemData["Item"]
                local itemQty = tonumber(itemData["QTY"])
                local categoryName = categoryNames[category] or category
                
                if not categoryTotals[categoryName] then
                    categoryTotals[categoryName] = {}
                end
                
                if not categoryTotals[categoryName][itemName] then
                    categoryTotals[categoryName][itemName] = 0
                end
                
                categoryTotals[categoryName][itemName] = categoryTotals[categoryName][itemName] + itemQty
            end
        end
    end
    
    return categoryTotals
end

local function createCharacterSummary(ProvisioningList)
    local summaries = {}
    
    for characterName, data in pairs(ProvisioningList) do
        local characterSummary = {}
        for category, itemData in pairs(data) do
            if type(itemData) == "table" and itemData["Item"] then
                table.insert(characterSummary, itemData["Item"] .. ": " .. itemData["QTY"])
            end
        end
        summaries[characterName] = characterSummary
    end
    
    return summaries
end

local function writeToFile(categoryTotals, characterSummaries, filename)
    local file = io.open(filename, "w")
    if not file then
        return
    end
    file:write("************************\n")
    file:write("* Provisioning Summary *\n")
    file:write("************************\n\n")
    
    for category, items in pairs(categoryTotals) do
        file:write(category .. "\n")
        file:write(string.rep("=", #category + 4) .. "\n")
        for item, qty in pairs(items) do
            file:write(item .. ": " .. qty .. "\n")
        end
        file:write("\n")
    end

    file:write("******************************\n")
    file:write("* Per Character Requirements *\n")
    file:write("******************************\n\n")
    
    for characterName, summary in pairs(characterSummaries) do
        file:write(characterName .. "\n")
        file:write(string.rep("-", #characterName + 4) .. "\n")
        for _, itemLine in ipairs(summary) do
            file:write(itemLine .. "\n")
        end
        file:write("\n")
    end
    
    file:close()
end

local combinedItemsByCategory = combineItemsByCategory(ProvisioningList)
local characterSummaries = createCharacterSummary(ProvisioningList)

writeToFile(combinedItemsByCategory, characterSummaries, outputFolder..outputFilename)


