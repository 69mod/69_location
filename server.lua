ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('rental:deleteVehicle', function(vehicleNetId)
    local src = source
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if DoesEntityExist(vehicle) then
        TriggerClientEvent('rental:deleteVehicleClient', -1, vehicleNetId)
    end
end)

RegisterNetEvent('rental:attemptRentVehicle', function(vehicleModel, price)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        TriggerClientEvent('rental:spawnVehicle', source, vehicleModel)
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Location de véhicule',
            description = 'Vous n\'avez pas assez d\'argent pour louer ce véhicule.',
            type = 'error'
        })
    end
end)