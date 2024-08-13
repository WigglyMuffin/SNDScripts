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
dofile(SNDConfigFolder..""..ProvisioningListNameToLoad)


function combineItems(list)
    local combinedItems = {}
    for _, entry in ipairs(list) do
        if entry["Row1ItemName"] and entry["Row1ItemAmount"] then
            local itemName = entry["Row1ItemName"]
            local itemAmount = tonumber(entry["Row1ItemAmount"])
            combinedItems[itemName] = (combinedItems[itemName] or 0) + itemAmount
        end
        if entry["Row2ItemName"] and entry["Row2ItemAmount"] then
            local itemName = entry["Row2ItemName"]
            local itemAmount = tonumber(entry["Row2ItemAmount"])
            combinedItems[itemName] = (combinedItems[itemName] or 0) + itemAmount
        end
        if entry["Row3ItemName"] and entry["Row3ItemAmount"] then
            local itemName = entry["Row3ItemName"]
            local itemAmount = tonumber(entry["Row3ItemAmount"])
            combinedItems[itemName] = (combinedItems[itemName] or 0) + itemAmount
        end
    end

    return combinedItems
end

function writeToFile(combinedItems, filename)
    local file = io.open(SNDConfigFolder..""..filename, "w")

    for itemName, itemAmount in pairs(combinedItems) do
        file:write(itemName .. " = " .. itemAmount .. "\n")
    end

    file:close()
end


local combinedItems = combineItems(ProvisioningList)

local outputFilename = "Lists/List_to_gather.txt"
writeToFile(combinedItems, outputFilename)

