local QBCore = exports['qb-core']:GetCoreObject()

-- Pawnshop stash ID
local pawnShopStashId = 'pawn_shop_stash'

-- Process item sales
RegisterNetEvent('brp-pawn:server:sellItems')
AddEventHandler('brp-pawn:server:sellItems', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Get the stash items
    local stashItems = MySQL.Sync.fetchAll('SELECT items FROM stashitems WHERE stash = ?', { pawnShopStashId })[1]
    if not stashItems or not stashItems.items then 
        TriggerClientEvent('QBCore:Notify', src, 'No items found in basket!', 'error')
        return 
    end

    local items = json.decode(stashItems.items)
    if type(items) ~= 'table' then items = {} end

    -- Process each item
    local totalAmount = 0
    local soldItems = {}

    for slot, item in pairs(items) do
        local itemName = string.lower(item.name)

        -- Check if this is an item we buy
        if Config.Items[itemName] then
            local price = Config.Items[itemName].price * item.amount
            totalAmount = totalAmount + price

            -- Add to sold items for notification
            if not soldItems[itemName] then
                soldItems[itemName] = item.amount
            else
                soldItems[itemName] = soldItems[itemName] + item.amount
            end
        end
    end

    -- If nothing was sold
    if totalAmount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'No valid items to sell!', 'error')
        return
    end

    -- Clear the stash
    MySQL.Sync.execute('UPDATE stashitems SET items = ? WHERE stash = ?', {
        json.encode({}),
        pawnShopStashId
    })

    -- Pay the player
    Player.Functions.AddMoney('cash', totalAmount, 'pawn-shop-sale')

    -- Create summary text
    local summaryText = "Sold: "
    for item, amount in pairs(soldItems) do
        summaryText = summaryText .. amount .. "x " .. item .. ", "
    end
    summaryText = summaryText:sub(1, -3) -- Remove last comma and space
    summaryText = summaryText .. " for $" .. totalAmount

    -- Notify the player
    TriggerClientEvent('QBCore:Notify', src, summaryText, 'success')

    -- Log the transaction
    print(Player.PlayerData.name .. " sold items for $" .. totalAmount)
end)

-- Check stash value
RegisterNetEvent('brp-pawn:server:checkStashValue')
AddEventHandler('brp-pawn:server:checkStashValue', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Get the stash items
    local stashItems = MySQL.Sync.fetchAll('SELECT items FROM stashitems WHERE stash = ?', { pawnShopStashId })[1]
    if not stashItems or not stashItems.items then 
        TriggerClientEvent('brp-pawn:client:checkStashValue', src, 0)
        return 
    end

    local items = json.decode(stashItems.items)
    if type(items) ~= 'table' then items = {} end

    -- Calculate total value
    local totalValue = 0
    for slot, item in pairs(items) do
        local itemName = string.lower(item.name)
        if Config.Items[itemName] then
            totalValue = totalValue + (Config.Items[itemName].price * item.amount)
        end
    end

    -- Send the total value to the client
    TriggerClientEvent('brp-pawn:client:checkStashValue', src, totalValue)
end)