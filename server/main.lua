ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('esx_duty:mcd:duty')
AddEventHandler('esx_duty:mcd:duty', function(zone)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer.job.name == Config.Zones[zone].In then
        xPlayer.setJob(Config.Zones[zone].Out, xPlayer.job.grade)
    else
        if xPlayer.job.name == Config.Zones[zone].Out then
            xPlayer.setJob(Config.Zones[zone].In, xPlayer.job.grade)
        end
    end
end)

--notification
function sendNotification(xSource, message, messageType, messageTimeout)
    TriggerClientEvent("pNotify:SendNotification", xSource, {
        text = message,
        type = messageType,
        queue = "qalle",
        timeout = messageTimeout,
        layout = "bottomCenter"
    })
end