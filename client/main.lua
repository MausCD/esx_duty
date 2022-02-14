local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
}
--- action functions
local CurrentAction           = nil
local HasAlreadyEnteredMarker = false
local LastZone                = nil


--- esx
local GUI = {}
ESX                           = nil
GUI.Time                      = 0
local PlayerData              = {}

Citizen.CreateThread(function ()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

Citizen.CreateThread(function() while true do if(ESX.IsPlayerLoaded()) then
  PlayerData = ESX.GetPlayerData()
end Citizen.Wait(1000) end end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

----markers
AddEventHandler('esx_duty:hasEnteredMarker', function (zone)
  CurrentAction     = zone
end)

AddEventHandler('esx_duty:hasExitedMarker', function (zone)
  CurrentAction = nil
end)


--keycontrols
Citizen.CreateThread(function ()
  while true do 
    Citizen.Wait(0)
    if(ESX.IsPlayerLoaded()) then

      local playerPed = GetPlayerPed(-1)

    if CurrentAction ~= nil then
      if PlayerData.job.name == Config.Zones[CurrentAction].In then
        SetTextComponentFormat('STRING')
        AddTextComponentString(_U('gooffduty'))
        DisplayHelpTextFromStringLabel(0, 0, 1, -1)
      else
        if PlayerData.job.name == Config.Zones[CurrentAction].Out then
          SetTextComponentFormat('STRING')
          AddTextComponentString(_U('goonduty'))
          DisplayHelpTextFromStringLabel(0, 0, 1, -1)
        end
      end

      if IsControlJustReleased(0, Keys['E']) then
        if PlayerData.job.name == Config.Zones[CurrentAction].In then
          TriggerServerEvent('esx_duty:mcd:duty', CurrentAction)

          sendNotification(_U('offduty'), 'success', 2500)
          Wait(1000)
        else
            if PlayerData.job.name == Config.Zones[CurrentAction].Out then
              TriggerServerEvent('esx_duty:mcd:duty', CurrentAction)
              
              sendNotification(_U('onduty'), 'success', 2500)
              Wait(1000)
            end
        end

      end
    end
  end end      
end)

-- Display markers
Citizen.CreateThread(function() while true do Citizen.Wait(0) if(ESX.IsPlayerLoaded()) then
  PlayerData = ESX.GetPlayerData()
  local coords = GetEntityCoords(GetPlayerPed(-1))

  for k,v in pairs(Config.Zones) do
    if PlayerData.job.name == v.Out then
      for i,p in ipairs(v.Positions) do
        if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, p.x, p.y, p.z, true) < Config.DrawDistance) then
          DrawMarker(v.Type, p.x, p.y, p.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, 255, 0, 0, 100, false, true, 2, false, false, false, false)
        end
      end
    else
      if PlayerData.job.name == v.In then
        for i,p in ipairs(v.Positions) do
          if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, p.x, p.y, p.z, true) < Config.DrawDistance) then
            DrawMarker(v.Type, p.x, p.y, p.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, 0, 255, 0, 100, false, true, 2, false, false, false, false)
          end
        end
      end
    end
  end
end end end)

-- Enter / Exit marker events
Citizen.CreateThread(function ()
  while true do
    Wait(0)

    local coords      = GetEntityCoords(GetPlayerPed(-1))
    local isInMarker  = false
    local currentZone = nil

    for k,v in pairs(Config.Zones) do
      for i,p in ipairs(v.Positions) do
        if(GetDistanceBetweenCoords(coords, p.x, p.y, p.z, true) < v.Size.x) then
          isInMarker  = true
          currentZone = k
        end
      end
    end

    if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
      HasAlreadyEnteredMarker = true
      LastZone                = currentZone
      TriggerEvent('esx_duty:hasEnteredMarker', currentZone)
    end

    if not isInMarker and HasAlreadyEnteredMarker then
      HasAlreadyEnteredMarker = false
      TriggerEvent('esx_duty:hasExitedMarker', LastZone)
    end
  end
end)

--notification
function sendNotification(message, messageType, messageTimeout)
	-- TriggerEvent("pNotify:SendNotification", {
	-- 	text = message,
	-- 	type = messageType,
	-- 	queue = "duty",
	-- 	timeout = messageTimeout,
	-- 	layout = "bottomCenter"
	-- })

  exports['okokNotify']:Alert("Life-V", message, 2000, 'info')
end