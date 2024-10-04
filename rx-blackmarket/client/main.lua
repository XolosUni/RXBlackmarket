local QBCore = exports['qb-core']:GetCoreObject()
local cfg = rx

local collectPed
local clipboardEntity
local toggle = false
local blocked = 'false'
local Cache = {}
local payed = 'wait'
local balance = 0


-- Function to update cache
local function CacheUp(item, quantity)
    if Cache[item] then
        Cache[item].amount = Cache[item].amount + quantity
    else
        Cache[item] = {itemName = item, amount = quantity}
    end
end

-- Function to collect cache and grant items
local function CollectCache()
    DeleteEntity(collectPed)
    DeleteEntity(clipboardEntity)
    collectPed = nil
    clipboardEntity = nil


    for itemName, v in pairs(Cache) do
        TriggerServerEvent('rx-blackmarket:server:charge', 0, 'pureGrant', true, v.itemName, v.amount, true)
    end
    blocked = 'false'
    Cache = {}
end

-- Function to start the delivery process
local function SendToDelivery()
    print(1)
    blocked = 'i should wait for the order to arrive'
    Wait(cfg.DeliveryTime)
    blocked = 'My order has arrived, I have to go and collect it!'

    local animDict = rx.CollectPed.animDict
    local clipboardModel = 'p_amb_clipboard_01'

    RequestModel(rx.CollectPed.model)
    while not HasModelLoaded(rx.CollectPed.model) do Wait(0) end
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(0) end
    RequestModel(clipboardModel)
    while not HasModelLoaded(clipboardModel) do Wait(0) end

    if clipboardEntity then DeleteEntity(clipboardEntity) end
    if collectPed then DeleteEntity(collectPed) end

    clipboardEntity = CreateObject(clipboardModel, cfg.CollectPed.coords.x, cfg.CollectPed.coords.y, cfg.CollectPed.coords.z, false, false, false)
    collectPed = CreatePed(1, rx.CollectPed.model, cfg.CollectPed.coords.x, cfg.CollectPed.coords.y, cfg.CollectPed.coords.z - 1, cfg.CollectPed.coords.w, false, false)
    AttachEntityToEntity(clipboardEntity, collectPed, GetPedBoneIndex(collectPed, 0x49D9), 0.16, 0.08, 0.1, -130.0, -50.0, 0.0, true, true, false, true, 1, true)
    
    exports['qb-target']:AddTargetEntity(collectPed, {
        options = {
            {
                num = 1,
                type = "client",
                event = "rx-blackmarket:client:CollectCache",
                icon = 'fa-solid fa-hand-holding-hand',
                label = 'Grab Delivery',
                action = function()
                    exports['qb-target']:RemoveTargetEntity(collectPed, 'Grab Delivery')
                    CollectCache()
                end,
            }
        },
        distance = 2.5,
    })

    TaskPlayAnim(collectPed, animDict, cfg.CollectPed.animName, 2.0, 2.0, -1, 51, 0, false, false, false)
    FreezeEntityPosition(collectPed, true)
    SetEntityInvincible(collectPed, true)
    SetBlockingOfNonTemporaryEvents(collectPed, true)
end

-- Event handler for opening the laptop
RegisterNetEvent('rx-blackmarket:client:OpenLaptop', function()

    local Player = QBCore.Functions.GetPlayerData()
    local citizenID = Player.citizenid
    local Priority = '1'

    for i, v in pairs(cfg.PriorityItem) do
        if QBCore.Functions.HasItem(i) then
            Priority = tostring(v)
        end
    end


    for i, v in pairs(cfg.customPriority) do
        if tostring(i) == tostring(citizenID) then
            Priority = v
            print('detected Custom Priority for ' .. citizenID .. " Value " .. Priority .. " N " .. v)
        end
    end



    for _, v in pairs(cfg.ReqToRun) do
        if not QBCore.Functions.HasItem(v) then
            QBCore.Functions.Notify('Missing required item: ' .. v, 'error', 2000)
            return
        end
    end



    if blocked ~= 'false' then
        QBCore.Functions.Notify('Blocked: ' .. blocked, 'error', 2000)
        return
    end

    balance = Player.money['crypto']
    


    if not toggle then
        SendNUIMessage({ type = 'req', req = 'ShowLaptop', pio = tonumber(Priority), balance = balance })
        SetNuiFocus(true, true)
        toggle = true
        
    else
        SendNUIMessage({ type = 'req', req = 'HideLaptop' })
        SetNuiFocus(false, false)
        toggle = false
    end

    
end)


RegisterNUICallback('js', function(data, cb)
    if data.action == 'req' and data.req == 'sendNotif' then
        -- Notify the user and return an error response
        cb('trustError')
        QBCore.Functions.Notify('I will not sell you anything that I can\'t trust you will use carefully', 'error', 5000)

    elseif data.action == 'ofucos' then
        if data.data == 'false' then
            -- Handle the focus state
            cb('backed out!')
            toggle = false
            SetNuiFocus(false, false)
        elseif data.data == 'trust' then
            -- Handle the focus state
            cb('backed in!')
            SetNuiFocus(true, true)
        end

    elseif data.action == 'order' then
        print('sdfsdf')
        SetNuiFocus(false, false)
        
        if data.cart and type(data.cart) == "table" then
            if blocked ~= 'false' then
                -- If blocked, do nothing and exit
                return
            end

            local cost = data.totalCrypto
            TriggerServerEvent('rx-blackmarket:server:charge', cost, 'crypto', false, nil, nil, nil)

            CreateThread(function()
                while true do
                    Wait(100)

                    if payed == 'wait' then
                        print('Waiting for payment confirmation...')
                    elseif payed == 'false' then
                        print('Payment failed')
                        break
                    elseif payed == 'true' then
                        print('Payment successful')
                        Cache = {}

                        -- Process the items in the cart
                        for _, item in pairs(data.cart) do
                            if item.name and item.quantity then
                                CacheUp(item.name, item.quantity)
                            else
                                print("Invalid item data: ", json.encode(item))
                            end
                        end

                        SendToDelivery()
                        payed = 'wait'
                        break
                    end
                end
            end)

        else
            print("Invalid cart data: ", json.encode(data.cart))
        end
    end
end) 

-- Event handler for transaction results
RegisterNetEvent('rx-blackmarket:client:transactionResult')
AddEventHandler('rx-blackmarket:client:transactionResult', function(success, message)
    payed = success
    if success == 'true' then
        QBCore.Functions.Notify('Transaction successful: ' .. message, 'success', 5000)
    else
        QBCore.Functions.Notify('Transaction failed: ' .. message, 'error', 5000)
    end
end)




-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    Cache = {}
    if collectPed then DeleteEntity(collectPed) end
    if clipboardEntity then DeleteEntity(clipboardEntity) end
    toggle = false
    blocked = 'false'
end)

-- Ensure cleanup on resource start as well
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    Cache = {}
    if collectPed then DeleteEntity(collectPed) end
    if clipboardEntity then DeleteEntity(clipboardEntity) end
    toggle = false
    blocked = 'false'

end)
