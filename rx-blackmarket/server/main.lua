-- Example server-side script (server.lua)

local QBCore = exports['qb-core']:GetCoreObject()

-- Function to handle transactions and item grants
RegisterNetEvent('rx-blackmarket:server:charge')
AddEventHandler('rx-blackmarket:server:charge', function(cost, method, grant, item, quantity, pureGrant, successmsg)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    -- Convert arguments to proper types
    cost = tonumber(cost) or 0
    method = tostring(method)
    grant = tostring(grant) == 'true'
    item = tostring(item)
    quantity = tonumber(quantity) or 0
    pureGrant = tostring(pureGrant) == 'true'

    -- Check for pureGrant method first
    if pureGrant then
        -- Directly grant item without any cost checks
        Player.Functions.AddItem(item, quantity)
        return
    end

    -- Basic validation
    if cost <= 0 then
        TriggerClientEvent('rx-blackmarket:client:transactionResult', src, 'false', 'Invalid cost.')
        return
    end

    if not Player then
        TriggerClientEvent('rx-blackmarket:client:transactionResult', src, 'false', 'Player not found.')
        return
    end

    local success = false
    local message = ''

    -- Handle transaction based on method
    if method == 'crypto' then
        -- Handle crypto payment
        local cryptoBalance = Player.PlayerData.money['crypto']
        if cryptoBalance >= cost then
            Player.Functions.RemoveMoney('crypto', cost)
            success = true
            message = 'Payment successful via crypto.'
        else
            message = 'Not enough crypto balance.'
        end
    elseif method == 'bank' then
        -- Handle bank payment
        local bankBalance = Player.PlayerData.money['bank']
        if bankBalance >= cost then
            Player.Functions.RemoveMoney('bank', cost)
            success = true
            message = 'Payment successful via bank.'
        else
            message = 'Not enough bank balance.'
        end
    elseif method == 'cash' then
        -- Handle cash payment
        local cashBalance = Player.PlayerData.money['cash']
        if cashBalance >= cost then
            Player.Functions.RemoveMoney('cash', cost)
            success = true
            message = 'Payment successful via cash.'
        else
            message = 'Not enough cash.'
        end
    else
        message = 'Invalid payment method.'
    end

    -- Grant item if successful
    if success and grant then
        Player.Functions.AddItem(item, quantity)
        message = message .. ' Item granted.'
    end

    -- Notify client of result
    TriggerClientEvent('rx-blackmarket:client:transactionResult', src, tostring(success), message)
end)
