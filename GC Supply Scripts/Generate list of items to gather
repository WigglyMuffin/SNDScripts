-- This script will generate a file in the SNDConfigFolder which lists all the items you need to get to make the Deliver items to alt script fully automatic
-- as long as you make sure you have all the items this script tells you to get you should be able to proceed without issue

-- by default uses the output from the script that generates a provisioninglist
-- probably don't touch this
ProvisioningListNameToLoad = "ProvisioningList.lua"







--########################################
--########################################
--########################################
--########################################
SNDConfigFolder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
dofile(SNDConfigFolder..""..ProvisioningListNameToLoad)
local combined_miner_items = {}
local combined_fisher_items = {}
local combined_botanist_items = {}


local function str_to_num(str)
    return tonumber(str) or 0
end


for _, entry in ipairs(ProvisioningList) do
    -- Combine Miner items
    local miner_item_name = entry.MinerItemName
    local miner_item_qty = str_to_num(entry.MinerItemQty)
    if miner_item_name then
        if combined_miner_items[miner_item_name] then
            combined_miner_items[miner_item_name] = combined_miner_items[miner_item_name] + miner_item_qty
        else
            combined_miner_items[miner_item_name] = miner_item_qty
        end
    end

    -- Combine Fisher items
    local fisher_item_name = entry.FisherItemName
    local fisher_item_qty = str_to_num(entry.FisherItemQty)
    if fisher_item_name then
        if combined_fisher_items[fisher_item_name] then
            combined_fisher_items[fisher_item_name] = combined_fisher_items[fisher_item_name] + fisher_item_qty
        else
            combined_fisher_items[fisher_item_name] = fisher_item_qty
        end
    end

    -- Combine Botanist items
    local botanist_item_name = entry.BotanistItemName
    local botanist_item_qty = str_to_num(entry.BotanistItemQty)
    if botanist_item_name then
        if combined_botanist_items[botanist_item_name] then
            combined_botanist_items[botanist_item_name] = combined_botanist_items[botanist_item_name] + botanist_item_qty
        else
            combined_botanist_items[botanist_item_name] = botanist_item_qty
        end
    end
end


local function table_to_list(tbl, item_type)
    local result = {}
    for name, qty in pairs(tbl) do
        local item = {}
        item[item_type .. "Name"] = name
        item[item_type .. "Qty"] = qty
        table.insert(result, item)
    end
    return result
end


local combined_miner_list = table_to_list(combined_miner_items, "MinerItem")
local combined_fisher_list = table_to_list(combined_fisher_items, "FisherItem")
local combined_botanist_list = table_to_list(combined_botanist_items, "BotanistItem")


local function format_list(title, list)
    local result = {}
    table.insert(result, title)
    for _, item in ipairs(list) do
        local item_str = ""
        for k, v in pairs(item) do
            item_str = item_str .. string.format("%s: %s ", k, v)
        end
        table.insert(result, item_str)
    end
    return table.concat(result, "\n")
end


local function write_to_file(filename, ...)
    local file = io.open(filename, "w")
    for _, str in ipairs({...}) do
        file:write(str .. "\n\n")
    end
    file:close()
end


local miner_list_str = format_list("Combined Miner Items:", combined_miner_list)
local fisher_list_str = format_list("Combined Fisher Items:", combined_fisher_list)
local botanist_list_str = format_list("Combined Botanist Items:", combined_botanist_list)


write_to_file(SNDConfigFolder.."List_to_gather.txt", miner_list_str, fisher_list_str, botanist_list_str)
