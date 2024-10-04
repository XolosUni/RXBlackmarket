local QBCore = exports['qb-core']:GetCoreObject()

local cfg = dealer

local dealerPed
local tableOb
local laptopOb

local function SlideMenu()
    exports['qb-menu']:openMenu({
        {
            header = 'Sketchy dealer',
            icon = 'fa-solid fa-comments',
            isMenuHeader = true,
        },
        {
            header = 'My USB',
            txt = 'To get the files, ' .. cfg.items[2].price,
            icon = 'fa-solid fa-file-export',
            params = {
                event = 'rx-blackmarket:client:USBbought',
            }
        },  
        {
            header = 'VPN',
            txt = 'If you don\'t want to get tracked down, just make sure to use this, ' .. cfg.items[3].price,
            icon = 'fa-solid fa-network-wired',
            params = {
                event = 'rx-blackmarket:client:VPNbought',
            }
        },
    })
end

local function NotifyTablet()
    print('Tablet notification or any other action')
end  

local function SpawnDealer()
    local tableModel = 'prop_table_04'
    local tableCoords = vec4(-468.99, 6289.02, 13.61, 145.62)

    local laptopModel = 'prop_laptop_01a'
    local laptopCoords = vec4(-468.84, 6289.01, 14.43, 142.43)

    RequestModel(cfg.Ped.model)
    while not HasModelLoaded(cfg.Ped.model) do Wait(1) end
    RequestAnimDict(cfg.Ped.animDict)
    while not HasAnimDictLoaded(cfg.Ped.animDict) do Wait(1) end
    RequestModel(tableModel)
    while not HasModelLoaded(tableModel) do Wait(1) end
    RequestModel(laptopModel)
    while not HasModelLoaded(laptopModel) do Wait(1) end

    dealerPed = CreatePed(1, cfg.Ped.model, cfg.Ped.coords.x, cfg.Ped.coords.y, cfg.Ped.coords.z -1, cfg.Ped.coords.w, false, false)
    tableOb = CreateObject(tableModel, tableCoords.x, tableCoords.y, tableCoords.z -1, false, false, false)
    laptopOb = CreateObject(laptopModel, laptopCoords.x, laptopCoords.y, laptopCoords.z -1, false, false, false)
    TaskPlayAnim(dealerPed, cfg.Ped.animDict, cfg.Ped.animName, 2.0, 2.0, -1, 49, 0, false, false, false)

    SetEntityHeading(tableOb, tableCoords.w)
    SetEntityHeading(laptopOb, laptopCoords.w)
    FreezeEntityPosition(dealerPed, true)
    FreezeEntityPosition(tableOb, true)
    FreezeEntityPosition(laptopOb, true)
    SetEntityInvincible(dealerPed, true)
    SetBlockingOfNonTemporaryEvents(dealerPed, true)

    SetModelAsNoLongerNeeded(cfg.Ped.model)
    SetModelAsNoLongerNeeded(tableModel)
    SetModelAsNoLongerNeeded(laptopModel)
    RemoveAnimDict(cfg.Ped.animDict)
end 

CreateThread(function ()
    SpawnDealer()

    if not dealerPed then return end

    exports['qb-target']:AddTargetEntity(dealerPed, {
        options = {
            {
                num = 1,
                event = 'rx-blackmarket:client:talkToDealer',
                icon = 'fa-solid fa-comments',
                label = 'Talk',
                action = function()
                    local Player = QBCore.Functions.GetPlayerData()
                    for _, job in pairs(cfg.BlacklistJobs) do
                        if job == Player.job.name then
                            QBCore.Functions.Notify('Get out of here, or we will just have to deal with you...', 'error', 5000)
                            NotifyTablet()
                            return
                        end
                    end

                    QBCore.Functions.Notify('Make sure to pay in cash!', 'success', 2000)
                    SlideMenu()
                end,
            }
        },
        distance = 2.5,
    })
end)

RegisterNetEvent('rx-blackmarket:client:VPNbought', function ()
    QBCore.Functions.Notify('You\'re interested in my VPN? Pay up!', 'primary', 2000)
    TriggerServerEvent('rx-blackmarket:server:charge', cfg.items[3].price, 'cash', true, cfg.items[3].itemName, 1)
end)

RegisterNetEvent('rx-blackmarket:client:USBbought', function ()
    QBCore.Functions.Notify('So you want my USB? Pay up!', 'primary', 2000)
    TriggerServerEvent('rx-blackmarket:server:charge', cfg.items[2].price, 'cash', true, cfg.items[2].itemName, 1)
end)

AddEventHandler('onResourceStop', function (resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    if dealerPed then DeleteEntity(dealerPed) end
    if tableOb then DeleteEntity(tableOb) end
    if laptopOb then DeleteEntity(laptopOb) end
end)
