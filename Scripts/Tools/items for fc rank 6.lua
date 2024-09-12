function ItemsForFcRank6()
    local ilvl = 640   -- Item level
    local is_hq = true -- Options: true = HQ, false = NQ

    -- Execute the Free Company command to update credits info
    repeat
        yield("/freecompanycmd")
        yield("/wait 0.1")
    until IsAddonVisible("FreeCompany")
    
    yield("/wait 0.5")

    -- Fetch current Free Company credits
    local fc_node_credits = tonumber(((GetNodeText("FreeCompany", 15) or ""):gsub(",", ""))) or 0

    -- Define the credit amounts required for each rank (Rank 1 to Rank 6)
    local fc_rank_credits = {
        [1] = 0,         -- Rank 1 credits
        [2] = 4043,      -- Rank 2 credits
        [3] = 16173,     -- Rank 3 credits
        [4] = 36389,     -- Rank 4 credits
        [5] = 64691,     -- Rank 5 credits
        [6] = 98228      -- Rank 6 credits
    }
    
    -- Get the current FC rank and credits
    local fc_rank = GetFCRank()

    -- Ensure the correct current credits value
    local current_credits = fc_node_credits

    -- If the FC credits are less than the current rank credits, use the required credits amount for that rank instead
    if fc_node_credits > fc_rank_credits[fc_rank] then
        current_credits = fc_node_credits
    else
        current_credits = fc_rank_credits[fc_rank]
    end

    -- Calculate seals amount based on item level
    local function CalculateSealsAmount(ilvl)
        if ilvl <= 200 then
            return 5.75 * ilvl
        elseif ilvl <= 400 then
            return 2 * ilvl + 750
        elseif ilvl <= 530 then
            return 1.75 * ilvl + 850.5
        elseif ilvl <= 660 then
            return 1.6667 * ilvl + 895
        elseif ilvl <= 790 then
            return ilvl + 1339
        else
            return 0
        end
    end

    -- Calculate the company credit amount based on item quality
    local function CalculateCreditAmount(ilvl, is_hq)
        if is_hq then
            return ilvl * 3 -- HQ items: ilvl * 3
        else
            return ilvl * 1.5 -- NQ items: ilvl * 1.5
        end
    end

    -- Get the required credits for rank 6
    local rank_6_credits = fc_rank_credits[6]

    -- Calculate how many credits are needed to reach rank 6
    local credits_needed = rank_6_credits - current_credits

    -- Calculate the seals amount for the given ilvl
    local seals_amount = CalculateSealsAmount(ilvl)

    -- Calculate the credit amount for the given ilvl and item quality
    local credit_amount = CalculateCreditAmount(ilvl, is_hq)

    -- Calculate the number of items needed to reach rank 6
    local items_needed = credits_needed / credit_amount

    -- Return the result (rounded up to ensure whole items)
    return math.ceil(items_needed)
end

yield("/e Items needed: " .. ItemsForFcRank6())