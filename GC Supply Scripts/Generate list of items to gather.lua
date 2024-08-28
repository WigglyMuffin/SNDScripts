-- This script will generate a file in the SND_CONFIG_FOLDER which lists all the items you need to get to make the Deliver items to alt script fully automatic
-- as long as you make sure you have all the items this script tells you to get you should be able to proceed without issue

-- by default uses the output from the script that generates a provisioning_list
-- probably don't touch this

-- ###########
-- # CONFIGS #
-- ###########

-- Configuration is not required for this file

-- #####################################
-- #  DON'T TOUCH ANYTHING BELOW HERE  #
-- # UNLESS YOU KNOW WHAT YOU'RE DOING #
-- #####################################

snd_config_folder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
vac_config_folder = snd_config_folder .. "\\VAC\\"
load_functions_file_location = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(load_functions_file_location)
LoadFunctions()
LoadFileCheck()

if not CheckPluginsEnabled("SomethingNeedDoing") then
    return -- Stops script as plugins not available
end

provisioning_list_name_to_load = "provisioning_list.lua"

local gc_config_folder = vac_config_folder .. "\\GC\\"
dofile(gc_config_folder .. provisioning_list_name_to_load)

local output_filename = "list_to_gather.txt"
local output_folder = gc_config_folder

EnsureFolderExists(output_folder)

local function combine_items_by_category(provisioning_list)
    local category_totals = {}
    
    local category_names = {
        MIN = "Miner",
        BTN = "Botanist",
        FSH = "Fisher"
    }
    
    for _, data in pairs(provisioning_list) do
        for category, item_data in pairs(data) do
            if type(item_data) == "table" and item_data["Item"] then
                local item_name = item_data["Item"]
                local item_qty = tonumber(item_data["QTY"])
                local category_name = category_names[category] or category
                
                if not category_totals[category_name] then
                    category_totals[category_name] = {}
                end
                
                if not category_totals[category_name][item_name] then
                    category_totals[category_name][item_name] = 0
                end
                
                category_totals[category_name][item_name] = category_totals[category_name][item_name] + item_qty
            end
        end
    end
    
    return category_totals
end

local function create_character_summary(provisioning_list)
    local summaries = {}
    
    for character_name, data in pairs(provisioning_list) do
        local character_summary = {}
        for category, item_data in pairs(data) do
            if type(item_data) == "table" and item_data["Item"] then
                table.insert(character_summary, item_data["Item"] .. ": " .. item_data["QTY"])
            end
        end
        summaries[character_name] = character_summary
    end
    
    return summaries
end

local function write_to_file(category_totals, character_summaries, filename)
    local file = io.open(filename, "w")
    if not file then
        return
    end
    
    file:write("************************\n")
    file:write("* Provisioning Summary *\n")
    file:write("************************\n\n")

    -- Job ordering
    local job_order = { "Miner", "Botanist", "Fisher" }
    local remaining_categories = {}

    -- Separate order categories and gather remaining ones
    for category in pairs(category_totals) do
        if not table.concat(job_order):find(category) then
            table.insert(remaining_categories, category)
        end
    end

    -- Sort remaining categories a-z
    table.sort(remaining_categories)

    -- Combine ordered categories with the sorted remaining ones
    local sorted_categories = {}
    
    for _, category in ipairs(job_order) do
        if category_totals[category] then
            table.insert(sorted_categories, category)
        end
    end
    
    for _, category in ipairs(remaining_categories) do
        table.insert(sorted_categories, category)
    end

    -- Write categories to file
    for _, category in ipairs(sorted_categories) do
        local items = category_totals[category]
        file:write(category .. "\n")
        file:write(string.rep("=", #category + 4) .. "\n")
        
        -- Sort items a-z
        local sorted_items = {}
        
        for item in pairs(items) do
            table.insert(sorted_items, item)
        end
        table.sort(sorted_items)
        
        for _, item in ipairs(sorted_items) do
            local qty = items[item]
            file:write(item .. ": " .. qty .. "\n")
        end
        file:write("\n")
    end

    file:write("******************************\n")
    file:write("* Per Character Requirements *\n")
    file:write("******************************\n\n")
    
    -- Sort character names a-z
    local sorted_characters = {}
    
    for character_name in pairs(character_summaries) do
        table.insert(sorted_characters, character_name)
    end
    table.sort(sorted_characters)

    for _, character_name in ipairs(sorted_characters) do
        local summary = character_summaries[character_name]
        file:write(character_name .. "\n")
        file:write(string.rep("-", #character_name + 4) .. "\n")
        
        for _, item_line in ipairs(summary) do
            file:write(item_line .. "\n")
        end
        file:write("\n")
    end
    
    file:close()
end


local combined_items_by_category = combine_items_by_category(provisioning_list)
local character_summaries = create_character_summary(provisioning_list)

write_to_file(combined_items_by_category, character_summaries, output_folder .. output_filename)