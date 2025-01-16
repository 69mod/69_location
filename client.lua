local peds = {
    {
        --legion
        model = "a_m_y_business_01",
        coords = vector3(195.17, -933.77, 29.7),
        heading = 70.0,
        blip = {
            sprite = 225,
            color = 40,
            text = "Location de véhicules"
        }
    },
    {
        --paleto
        model = "a_m_y_business_02",
        coords = vector3(80.35, 6424.12, 31.67),
        heading = 160.0,
        blip = {
            sprite = 225,
            color = 40,
            text = "Location de véhicules"
        }
    },
    {
        --poloicedp
        model = "a_m_y_business_02",
        coords = vector3(428.23, -984.28, 29.76),
        heading = 160.0,
        blip = {
            sprite = 225,
            color = 40,
            text = "Location de véhicules"
        }
    },
    {
        --motel
        model = "a_m_y_business_02",
        coords = vector3(327.56, -205.08, 53.08),
        heading = 160.0,
        blip = {
            sprite = 225,
            color = 40,
            text = "Location de véhicules"
        }
    }
}

for _, pedInfo in ipairs(peds) do
    local pedModel = pedInfo.model
    local pedCoords = pedInfo.coords
    local pedHeading = pedInfo.heading

    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(1)
    end

    local rentalPed = CreatePed(4, pedModel, pedCoords.x, pedCoords.y, pedCoords.z, pedHeading, false, true)
    SetEntityInvincible(rentalPed, true)
    SetBlockingOfNonTemporaryEvents(rentalPed, true)
    FreezeEntityPosition(rentalPed, true)

    exports.ox_target:addLocalEntity(rentalPed, {
        {
            name = 'rental:openMenu',
            label = 'Louer un véhicule',
            icon = 'fa-solid fa-car',
            onSelect = function()
                lib.registerContext({
                    id = 'rental_menu',
                    title = 'Location de véhicules',
                    options = {
                        {
                            title = "Compact",
                            description = "Louer une voiture compacte pour $200",
                            event = "rental:rentVehicle",
                            args = { model = "blista", price = 200 }
                        },
                        {
                            title = "Scooter",
                            description = "Louer un scooter pour $100",
                            event = "rental:rentVehicle",
                            args = { model = "faggio", price = 100 }
                        },
                        {
                            title = "Velo",
                            description = "Louer un velo pour $50",
                            event = "rental:rentVehicle",
                            args = { model = "cruiser", price = 50 }
                        }
                    }
                })

                lib.showContext('rental_menu')
            end
        }
    })

    local blip = AddBlipForCoord(pedCoords.x, pedCoords.y, pedCoords.z)
    SetBlipSprite(blip, pedInfo.blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, pedInfo.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(pedInfo.blip.text)
    EndTextCommandSetBlipName(blip)
end

RegisterNetEvent('rental:rentVehicle', function(data)
    local playerPed = PlayerPedId()
    local vehicleModel = data.model
    local price = data.price

    TriggerServerEvent('rental:attemptRentVehicle', vehicleModel, price)
end)

RegisterNetEvent('rental:spawnVehicle', function(vehicleModel)
    local playerPed = PlayerPedId()

    RequestModel(vehicleModel)
    while not HasModelLoaded(vehicleModel) do
        Wait(1)
    end

    local vehicle = CreateVehicle(vehicleModel, GetEntityCoords(playerPed) + vector3(5, 0, 0), GetEntityHeading(playerPed), true, false)
    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

    local timer = 0.5 * 60 -- 15 minutes en secondes
    local notificationId = lib.notify({
        title = 'Location de véhicule',
        description = 'Vous avez loué un véhicule pour 15 minutes.',
        type = 'inform',
        duration = timer * 1000, -- Durée en milliseconde
        position = 'top'
    })

    Citizen.CreateThread(function()
        while timer > 0 do
            Citizen.Wait(1000)
            timer = timer - 1
        end

        TriggerServerEvent('rental:deleteVehicle', NetworkGetNetworkIdFromEntity(vehicle))
    end)
end)

RegisterNetEvent('rental:deleteVehicleClient', function(vehicleNetId)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if DoesEntityExist(vehicle) then
        SetEntityAsMissionEntity(vehicle, true, true)
        DeleteVehicle(vehicle)
        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end

        lib.notify({
            title = 'Location de véhicule',
            description = 'Votre temps de location est terminé. Le véhicule a été retourné.',
            type = 'inform',
            position = 'top'
        })
    end
end)