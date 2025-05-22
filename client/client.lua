local QBCore = exports['qb-core']:GetCoreObject()
local pawnShopPed = nil

-- Pawnshop location
local pawnShopCoords = Config.PedProps['location']

-- Create pawnshop NPC
local function createPawnShopPed()
    local model = Config.PedProps['hash']
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    pawnShopPed = CreatePed(4, model, pawnShopCoords.x, pawnShopCoords.y, pawnShopCoords.z - 1.0, pawnShopCoords.w, false, true)
    SetEntityHeading(pawnShopPed, pawnShopCoords.w)
    FreezeEntityPosition(pawnShopPed, true)
    SetEntityInvincible(pawnShopPed, true)
    SetBlockingOfNonTemporaryEvents(pawnShopPed, true)

    -- Create a blip for the pawnshop
    local blip = AddBlipForCoord(pawnShopCoords.x, pawnShopCoords.y, pawnShopCoords.z)
    SetBlipSprite(blip, 605) -- Pawnshop blip sprite
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.7)
    SetBlipColour(blip, 5) -- Purple
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Pawn Shop")
    EndTextCommandSetBlipName(blip)

    -- Add target interaction
    exports['qb-target']:AddTargetEntity(pawnShopPed, {
        options = {
            {
                type = "client",
                event = "brp-pawn:client:openPawnShopMenu",
                icon = "fas fa-hand-holding-usd",
                label = "Talk to Pawn Shop",
            }
        },
        distance = 2.0
    })
end

-- Initialize pawnshop
CreateThread(function()
    createPawnShopPed()
end)

-- Function to open the pawnshop stash
local function openPawnShopStash()
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "pawn_shop_stash", {
        maxweight = 1000000, -- Very large capacity
        slots = 30,
    })
    TriggerEvent("inventory:client:SetCurrentStash", "pawn_shop_stash")
end

-- Open the pawnshop menu
RegisterNetEvent('brp-pawn:client:openPawnShopMenu')
AddEventHandler('brp-pawn:client:openPawnShopMenu', function()
    lib.registerContext({
        id = 'pawn_shop_menu',
        title = 'Pawn Shop',
        options = {
            {
                title = 'Sell Items',
                description = 'Place items in the basket to sell them',
                icon = 'basket-shopping',
                onSelect = function()
                    openPawnShopStash()
                end
            },
            {
                title = 'Confirm Sale',
                description = 'Sell all items in the basket',
                icon = 'check',
                onSelect = function()
                    TriggerServerEvent('brp-pawn:server:sellItems')
                end
            }
        }
    })
    lib.showContext('pawn_shop_menu')
end)

-- Resource cleanup
AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then return end

    if pawnShopPed ~= nil then
        DeleteEntity(pawnShopPed)
    end
end)