local guiEnabled = false
local hasOpened = false
local lstMsgs = {}
local lstContacts = {}
local inPhone = false
local radioChannel = math.random(1,999)
local usedFingers = false
local dead = false
local onhold = false
local YellowPageArray = {}
local PhoneBooth = GetEntityCoords(GetPlayerPed(-1))
local AnonCall = false
local phoneNotifications = true
local insideDelivers = false
local curhrs = 9
local curmins = 2
local allowpopups = true
local vehicles = {}
RegisterNUICallback('btnNotifyToggle', function(data, cb)
    allowpopups = not allowpopups
    if allowpopups then
      TriggerEvent("DoLongHudText","Popups Enabled")
    else
      TriggerEvent("DoLongHudText","Popups Disabled")
    end
end)


activeTasks = {
  --[1] = { ["Gang"] = 2, ["TaskType"] = 1, ["TaskState"] = 2, ["TaskOwner"] = 12(cid), ["TaskInfo"] = , ["location"] = { ['x'] = -1248.52,['y'] = -1141.12,['z'] = 7.74,['h'] = 284.71, ['info'] = 'Down at Smokies on the Beach' }, }
}

activeNumbersClient = {}


RegisterNetEvent('Yougotpaid')
AddEventHandler('Yougotpaid', function(cidsent)
    local cid = exports["isPed"]:isPed("cid")
    if tonumber(cid) == tonumber(cidsent) then
        TriggerEvent("DoLongHudText","Life Invader Payslip Generated.")
    end
end)
           
RegisterNetEvent('Payment:Successful')
AddEventHandler('Payment:Successful', function()
    SendNUIMessage({
        openSection = "error",
        textmessage = "Payment Processed.",
    })     
end)

RegisterNetEvent('warrants:AddInfo')
AddEventHandler('warrants:AddInfo', function(name, charges)

    openGuiNow()

    SendNUIMessage({
      openSection = "enableoutstanding",
    })
    for i = 1, #charges do

      SendNUIMessage({
        openSection = "inputoutstanding",
        textmessage = charges[i],
      })
    end
    
end)




RegisterNetEvent("phone:listREproperties")
AddEventHandler("phone:listREproperties", function(outstandingArray)
    openGuiNow()

    SendNUIMessage({
      openSection = "enableoutstanding",
    })
    for i = 1, #outstandingArray do

      SendNUIMessage({
        openSection = "inputoutstanding",
        textmessage = outstandingArray[i],
      })
    end

    -- finish outstanding payments here.
end)


RegisterNetEvent("phone:listunpaid")
AddEventHandler("phone:listunpaid", function(outstandingArray)
    SendNUIMessage({
      openSection = "enableoutstanding",
    })
    for i = 1, #outstandingArray do

      SendNUIMessage({
        openSection = "inputoutstanding",
        textmessage = outstandingArray[i],
      })
    end

    -- finish outstanding payments here.
end)

RegisterNetEvent("phone:activeNumbers")
AddEventHandler("phone:activeNumbers", function(activePhoneNumbers)
  print("i has opened active numbers")
  activeNumbersClient = activePhoneNumbers
  hasOpened = false
end)


RegisterNetEvent("gangTasks:updateClients")
AddEventHandler("gangTasks:updateClients", function(newTasks)
  activeTasks = newTasks
end)

TaskState = {
  [1] = "Ready For Pickup",
  [2] = "In Process",
  [3] = "Successful",
  [4] = "Failed",
  [5] = "Delivered with Damaged Goods",
}

TaskTitle = {
  [1] = "Ordering 'Take-Out'",
  [2] = "Ordering 'Disposal Service'",
  [3] = "Ordering 'Postal Delivery'",
  [4] = "Ordering 'Hot Food Room Service'",
}

function findTaskIdFromBlockChain(blockchain)
  local retnum = 1
  for i = 1, #activeTasks do
    if activeTasks[i]["BlockChain"] == blockchain then
      retnum = i
    end
  end
  return retnum
end


-- real estate nui app responses

function loading()
    SendNUIMessage({
        openSection = "error",
        textmessage = "Loading, please wait.",
    })  
end
local ownedkeys = {}
local sharedkeys = {}



RegisterNetEvent("timeheader")
AddEventHandler("timeheader", function(hrs,mins)


  if hrs < 10 then
    hrs = "0"..hrs
  end
  if mins < 10 then
    mins = "0"..mins
  end
  curhrs = hrs
  curmins = mins

  local timesent = curhrs .. ":" .. curmins
  if guiEnabled then
    SendNUIMessage({
      openSection = "timeheader",
      timestamp = timesent,
    })   
  end
end)
function doTimeUpdate()
  local timesent = curhrs .. ":" .. curmins
  if guiEnabled then
    SendNUIMessage({
      openSection = "timeheader",
      timestamp = timesent,
    })   
  end
end
RegisterNetEvent("returnPlayerKeys")
AddEventHandler("returnPlayerKeys", function(ownedkeys,sharedkeys)

      if not guiEnabled then
        return
      end

      SendNUIMessage({
        openSection = "keys",
      })    

      for i = 1, #sharedkeys do

        SendNUIMessage({
          openSection = "key",
          house_id = sharedkeys[i]["house_id"],
          house_model = sharedkeys[i]["house_model"],
          house_name = sharedkeys[i]["house_name"],
          house_owner = false,
        })  
      end 

      for i = 1, #ownedkeys do

        SendNUIMessage({
          openSection = "key",

            amount_due = ownedkeys[i]["amountdue"],
            last_payment = ownedkeys[i]["days"],
            house_id = ownedkeys[i]["house_id"],
            house_model = ownedkeys[i]["house_model"],
            house_name = ownedkeys[i]["house_name"],
            house_owner = true,

        })   
      end 

      SendNUIMessage({
        openSection = "keysends",
      })    

end)



RegisterNUICallback('btnPropertyOutstanding', function(data, cb)
    loading()
    TriggerServerEvent("houses:PropertyOutstanding")
end)



RegisterNUICallback('btnMortgage', function(data, cb)
    TriggerEvent("houses:Mortgage")
    loading()
    Citizen.Wait(400)
     TriggerServerEvent("ReturnHouseKeys")
    
end)

RegisterNUICallback('btnFurniture', function(data, cb)
    closeGui()
    TriggerEvent("openFurniture")
end)

RegisterNUICallback('btnGiveKey', function(data, cb)
    TriggerEvent("houses:GiveKey")
end)

RegisterNUICallback('btnWipeKeys', function(data, cb)
    TriggerEvent("houses:WipeKeys")
end)


RegisterNUICallback('btnProperty2', function(data, cb)
    loading()
    TriggerServerEvent("ReturnHouseKeys")
end)

RegisterNUICallback('btnProperty', function(data, cb)
    loading()
    local realEstateRank = GroupRank("real_estate")
    if realEstateRank > 0 then
      SendNUIMessage({
          openSection = "RealEstate"
      })        
    end
end)

RegisterNUICallback('btnPropertyModify', function(data, cb)
  TriggerEvent("housing:info:realtor","modify")
end)

RegisterNUICallback('btnPropertyReset', function(data, cb)
  TriggerEvent("housing:info:realtor","reset")
end)



RegisterNUICallback('btnPropertyClothing', function(data, cb)
  TriggerEvent("housing:info:realtor","setclothing")
end)

RegisterNUICallback('btnPropertyStorage', function(data, cb)
  TriggerEvent("housing:info:realtor","setstorage")
end)




RegisterNUICallback('btnPropertySetGarage', function(data, cb)
  TriggerEvent("housing:info:realtor","setgarage")
end)

RegisterNUICallback('btnPropertyWipeGarages', function(data, cb)
  TriggerEvent("housing:info:realtor","wipegarages")
end)

RegisterNUICallback('btnPropertySetBackdoorInside', function(data, cb)
  TriggerEvent("housing:info:realtor","backdoorinside")
end)

RegisterNUICallback('btnPropertySetBackdoorOutside', function(data, cb)
  TriggerEvent("housing:info:realtor","backdooroutside")
end)

RegisterNUICallback('btnPropertyUpdateHouse', function(data, cb)
  TriggerEvent("housing:info:realtor","update")
end)
RegisterNUICallback('btnPropertyUnlock', function(data, cb)
  TriggerEvent("housing:info:realtor","unlock")
end)

RegisterNUICallback('btnPropertyHouseCreationPoint', function(data, cb)
  TriggerEvent("housing:info:realtor","creationpoint")
end)
RegisterNUICallback('btnPropertyStopHouse', function(data, cb)
  TriggerEvent("housing:info:realtor","stop")
end)
RegisterNUICallback('btnAttemptHouseSale', function(data, cb)
  TriggerEvent("housing:sendPurchaseAttempt",data.cid,data.price)
end)


-- real estate nui app responses end











RegisterNUICallback('btnGiveTaskToPlayer', function(data, cb)
    TriggerServerEvent("Tasks:AttemptGive",data.taskid,data.targetid)
end)

RegisterNUICallback('trackTaskLocation', function(data, cb)
    local taskID = findTaskIdFromBlockChain(data.TaskIdentifier)
    TriggerEvent("DoLongHudText","Location Set",15)

    SetNewWaypoint(activeTasks[taskID]["Location"]["x"],activeTasks[taskID]["Location"]["y"])
end)

function GroupName(groupid)
  local name = "Error Retrieving Name"
  local mypasses = exports["isPed"]:isPed("passes")
  for i=1, #mypasses do
    if mypasses[i]["pass_type"] == groupid then
      name = mypasses[i]["business_name"]
    end 
  end
  return name
end

function GroupRank(groupid)
  local rank = 0
  local mypasses = exports["isPed"]:isPed("passes")
  for i=1, #mypasses do
    if mypasses[i]["pass_type"] == groupid then
      rank = mypasses[i]["rank"]
    end 
  end
  return rank
end


RegisterNUICallback('bankGroup', function(data)
    local gangid = data.gangid
    local cashamount = data.cashamount
    print(gangid)
    print(cashamount)
    TriggerServerEvent("server:gankGroup", gangid,cashamount)
end)

RegisterNUICallback('payGroup', function(data)
    local gangid = data.gangid
    local cid = data.cid
    local cashamount = data.cashamount
    print(gangid)
    print(cid)
    print(cashamount)
    TriggerServerEvent("server:givepayGroup", gangid,cashamount,cid)
end)

RegisterNUICallback('promoteGroup', function(data)
    local gangid = data.gangid
    local cid = data.cid
    local newrank = data.newrank
    SendNUIMessage({
        openSection = "error",
        textmessage = "Loading, please wait.",
    })   
    TriggerServerEvent("server:givepass", gangid,newrank,cid)
end)


RegisterNUICallback('callNumber', function(data)
  closeGui()
    local number = data.callnum
    print(number .. " called")
    TriggerServerEvent("phone:callContact",number,true)
end)
RegisterNUICallback('manageGroup', function(data)
    local groupid = data.GroupID
    
    local rank = GroupRank(groupid)
    if rank < 2 then
      SendNUIMessage({
        openSection = "error",
        textmessage = "Permission Error",
      })   
      return
    end

    SendNUIMessage({
        openSection = "error",
        textmessage = "Loading, please wait.",
    })   

    TriggerServerEvent("group:pullinformation",groupid,rank)

end)

RegisterNetEvent("phone:error")
AddEventHandler("phone:error", function()
      SendNUIMessage({
        openSection = "error",
        textmessage = "<b>Network Error</b> <br><br> Please contact support if this error persists, thank you for using nopixel Phone Services.",
      })   
end)



RegisterNetEvent("group:fullList")
AddEventHandler("group:fullList", function(result,bank,groupid)

    local groupname = GroupName(groupid)
    SendNUIMessage({
      openSection = "GroupManager",
      sentbank = "<b>" .. groupname .. "</b> <br> Banked Money: $" .. bank,
      sentgroupid = groupid
    }) 

    for i,v in pairs(result) do
        SendNUIMessage({
          openSection = "GroupManagerUpdate",
          info = v
        }) 
 
    end

end)

-- associate is a legal worker
-- manager is a legal management worker, can pay / hire / remove below.
-- Partner is associated with "other" business activities and can not alter legal workers.
-- Part-Time Manager is associated with "other" business activites but can also manage legal workers, can pay / hire / remove below.
-- CEO runs that shit dawg, can pay / hire / remove below.


local recentcalls = {}

RegisterNUICallback('btnPhoneNumber', function()
      SendNUIMessage({
        openSection = "calls"
      })
  for i = 1, #recentcalls do
      SendNUIMessage({
        openSection = "addcall",
        typecall = recentcalls[i]["type"],
        phonenumber = recentcalls[i]["number"],
        contactname = recentcalls[i]["name"],
      })
  end
end)




RegisterNUICallback('btnTaskGroups', function()

    local mypasses = exports["isPed"]:isPed("passes")

    for i = 1, #mypasses do

        local rankConverted = "No Association"
        if mypasses[i]["rank"] == 1 then
          rankConverted = "Associate"
        elseif mypasses[i]["rank"] == 2 then
          rankConverted = "Management"
        elseif mypasses[i]["rank"] == 3 then
          rankConverted = "Partner"
        elseif mypasses[i]["rank"] == 4 then
          rankConverted = "Part-Time Manager"
        elseif mypasses[i]["rank"] == 5 then
          rankConverted = "CEO"
        end

        SendNUIMessage({
          openSection = "addgroup",
          namesent = mypasses[i]["business_name"],
          ranksent = rankConverted,
          idsent = mypasses[i]["pass_type"],
        })

    end

end)






RegisterNUICallback('btnTaskGang', function()

    local gang = exports["isPed"]:isPed("gang")
    local cid = tonumber(exports["isPed"]:isPed("cid"))

    for i = 1, #activeTasks do

      if activeTasks[i]["Gang"] ~= 0 and gang ~= 0 and tonumber(activeTasks[i]["taskOwnerCid"]) ~= cid then
        if gang == activeTasks[i]["Gang"] then
          SendNUIMessage({
            openSection = "addtask",
            namesent = TaskTitle[activeTasks[i]["TaskType"]] .. "(" .. activeTasks[i]["taskOwnerCid"] .. ")",
            taskstatus = TaskState[activeTasks[i]["TaskState"]],
            identifier = activeTasks[i]["BlockChain"],
            retrace = 0,
          })
        end
      elseif activeTasks[i]["Gang"] == 0 and tonumber(activeTasks[i]["taskOwnerCid"]) ~= cid then

        local passes = exports["isPed"]:isPed("passes")
        for z = 1, #passes do

          local passType = activeTasks[i]["Group"]
          if passes[z].pass_type == passType and (passes[z].rank == 2 or passes[z].rank > 3) then
            SendNUIMessage({
              openSection = "addtask",
              namesent = activeTasks[i]["TaskNameGroup"] .. "(" .. activeTasks[i]["taskOwnerCid"] .. ")",
              taskstatus = TaskState[activeTasks[i]["TaskState"]],
              identifier = activeTasks[i]["BlockChain"],
              retrace = 0,
            })
          end

        end

      else
        if tonumber(activeTasks[i]["taskOwnerCid"]) == cid then

          local TaskName = ""
          if activeTasks[i]["Gang"] == 0 then
            TaskName = activeTasks[i]["TaskNameGroup"] .. "(" .. activeTasks[i]["taskOwnerCid"] .. ")"
          else
            TaskName = TaskTitle[activeTasks[i]["TaskType"]] .. "(" .. activeTasks[i]["taskOwnerCid"] .. ")"
          end

          SendNUIMessage({
            openSection = "addtask",
            namesent = TaskName .. "(" .. activeTasks[i]["taskOwnerCid"] .. ")",
            taskstatus = TaskState[activeTasks[i]["TaskState"]],
            identifier = activeTasks[i]["BlockChain"],
            retrace = 1,
          })
        end
      end
    end
end)



local pcs = {
  [1] = 1333557690,
  [2] = -1524180747, 
}


function IsNearPC()
  for i = 1, #pcs do
    local objFound = GetClosestObjectOfType( GetEntityCoords(GetPlayerPed(-1)), 0.75, pcs[i], 0, 0, 0)

    if DoesEntityExist(objFound) then
      TaskTurnPedToFaceEntity(GetPlayerPed(-1), objFound, 3.0)
      return true
    end
  end

  if GetDistanceBetweenCoords(GetEnttiyCoords(GetPlayerPed(-1)),1272.27, -1711.91, 54.78) < 1.0 then
    SetEntityHeading(GetPlayerPed(-1),14.0)
    return true
  end
  if GetDistanceBetweenCoords(GetEnttiyCoords(GetPlayerPed(-1)),1275.4, -1710.52, 54.78) < 5.0 then
    SetEntityHeading(GetPlayerPed(-1),300.0)
    return true
  end


  return false
end


RegisterNetEvent("open:deepweb")
AddEventHandler("open:deepweb", function()
  SetNuiFocus(true,true)
  guiEnabled = true
  SendNUIMessage({
    openSection = "deepweb" 
  })
end)

RegisterNetEvent("gangTasks:updated")
AddEventHandler("gangTasks:updated", function()
  Citizen.Wait(50)

  SendNUIMessage({
    openSection = "taskUpdated" 
  })

    local gang = exports["isPed"]:isPed("gang")
    local cid = tonumber(exports["isPed"]:isPed("cid"))

    for i = 1, #activeTasks do

      if activeTasks[i]["Gang"] ~= 0 and gang ~= 0 and tonumber(activeTasks[i]["taskOwnerCid"]) ~= cid then
        if gang == activeTasks[i]["Gang"] then
          SendNUIMessage({
            openSection = "addtask",
            namesent = TaskTitle[activeTasks[i]["TaskType"]] .. "(" .. activeTasks[i]["taskOwnerCid"] .. ")",
            taskstatus = TaskState[activeTasks[i]["TaskState"]],
            identifier = activeTasks[i]["BlockChain"],
            retrace = 0,
          })
        end
      elseif activeTasks[i]["Gang"] == 0 and tonumber(activeTasks[i]["taskOwnerCid"]) ~= cid then

        local passes = exports["isPed"]:isPed("passes")
        for z = 1, #passes do

          local passType = activeTasks[i]["Group"]
          if passes[z].pass_type == passType and (passes[z].rank == 2 or passes[z].rank > 3) then
            SendNUIMessage({
              openSection = "addtask",
              namesent = activeTasks[i]["TaskNameGroup"] .. "(" .. activeTasks[i]["taskOwnerCid"] .. ")",
              taskstatus = TaskState[activeTasks[i]["TaskState"]],
              identifier = activeTasks[i]["BlockChain"],
              retrace = 0,
            })
          end

        end

      else
        if tonumber(activeTasks[i]["taskOwnerCid"]) == cid then

          local TaskName = ""
          if activeTasks[i]["Gang"] == 0 then
            TaskName = activeTasks[i]["TaskNameGroup"] .. "(" .. activeTasks[i]["taskOwnerCid"] .. ")"
          else
            TaskName = TaskTitle[activeTasks[i]["TaskType"]] .. "(" .. activeTasks[i]["taskOwnerCid"] .. ")"
          end

          SendNUIMessage({
            openSection = "addtask",
            namesent = TaskName .. "(" .. activeTasks[i]["taskOwnerCid"] .. ")",
            taskstatus = TaskState[activeTasks[i]["TaskState"]],
            identifier = activeTasks[i]["BlockChain"],
            retrace = 1,
          })
        end
      end
    end
end)

RegisterNetEvent("purchasePhone")
AddEventHandler("purchasePhone", function()
  TriggerServerEvent("purchasePhone")
end)

RegisterNUICallback('btnMute', function()
  if phoneNotifications then
    TriggerEvent("DoShortHudText", "Notifications Disabled.",10)
  else
    TriggerEvent("DoShortHudText", "Notifications Enabled.",10)
  end
  phoneNotifications = not phoneNotifications
end)

RegisterNetEvent("tryTweet")
AddEventHandler("tryTweet", function(tweetinfo,message,user)
  if hasPhone() then
    TriggerServerEvent("AllowTweet",tweetinfo,message)
  end
end)

RegisterNUICallback('btnDecrypt', function()
  TriggerEvent("secondaryjob:accepttask")
end)

RegisterNUICallback('btnGarage', function()
  TriggerEvent("Garages:PhoneUpdate")
end)

RegisterNUICallback('btnHelp', function()
  closeGui()
  TriggerEvent("openWiki")
end)

RegisterNUICallback('carpaymentsowed', function()
  TriggerEvent("car:carpaymentsowed")
end)

RegisterNUICallback('vehspawn', function(data)
  print("attempt spawn of" .. data.vehplate )
  findVehFromPlateAndSpawn(data.vehplate)

end)

RegisterNUICallback('vehtrack', function(data)
  print("attempt tracking of " .. data.vehplate )
  findVehFromPlateAndLocate(data.vehplate)

  

end)

function findVehFromPlateAndLocate(plate)

  for ind, value in pairs(vehicles) do

      vehPlate = value.license_plate
    if vehPlate == plate then

      
      state = value.vehicle_state
      coordlocation = value.coords

      SetNewWaypoint(coordlocation[1], coordlocation[2])

    end

  end
  
end
function findVehFromPlateAndSpawn(plate)

  if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
    print("cant spawn while in vehicle.")
    return
  end

  for ind, value in pairs(vehicles) do

    vehPlate = value.license_plate
    print(vehPlate .. " vs " .. plate)
    if vehPlate == plate then
      print("triggered?")
      
      state = value.vehicle_state
      coordlocation = value.coords

      if GetDistanceBetweenCoords(coordlocation[1],coordlocation[2],coordlocation[3],GetEntityCoords(GetPlayerPed(-1))) < 10.0 and state == "Out" then

        local DoesVehExistInProximity = CheckExistenceOfVehWithPlate(platesent)

        if not DoesVehExistInProximity then
          TriggerServerEvent("garages:phonespawn",vehPlate)
          print("Spawning vehicle because its apparently not here?!")
        else

          print("Found vehicle already existing!")
        end

      end

    end

  end

end

RegisterNetEvent("phone:SpawnVehicle")
AddEventHandler('phone:SpawnVehicle', function(vehicle, plate, customized, state, Fuel, coordlocation)
  local car = GetHashKey(vehicle)
  local customized = json.decode(customized)
  Citizen.CreateThread(function()     
    Citizen.Wait(100)

      if state == "Out" then

        RequestModel(car)
        while not HasModelLoaded(car) do
        Citizen.Wait(0)
        end

        veh = CreateVehicle(car, coordlocation[1],coordlocation[2],coordlocation[3], 0.0, true, false)
                   
        if Fuel < 5 then
          Fuel = 5
        end
        
        DecorSetInt(veh, "CurrentFuel", Fuel)
        SetVehicleOnGroundProperly(veh)
        SetEntityInvincible(veh, false) 

        SetVehicleModKit(veh, 0)

        SetVehicleNumberPlateText(veh, plate)

        if customized then
          
          SetVehicleWheelType(veh, customized.wheeltype)
          SetVehicleNumberPlateTextIndex(veh, 3)

          for i = 0, 16 do
            SetVehicleMod(veh, i, customized.mods[tostring(i)])
          end

          for i = 17, 22 do
            ToggleVehicleMod(veh, i, customized.mods[tostring(i)])
          end

          for i = 23, 24 do
            SetVehicleMod(veh, i, customized.mods[tostring(i)])
          end

          for i = 0, 3 do
            SetVehicleNeonLightEnabled(veh, i, customized.neon[tostring(i)])
          end

          SetVehicleColours(veh, customized.colors[1], customized.colors[2])
          SetVehicleExtraColours(veh, customized.extracolors[1], customized.extracolors[2])
          SetVehicleNeonLightsColour(veh, customized.lights[1], customized.lights[2], customized.lights[3])
          SetVehicleTyreSmokeColor(veh, customized.smokecolor[1], customized.smokecolor[2], customized.smokecolor[3])
          SetVehicleWindowTint(veh, customized.tint)

        else

          SetVehicleColours(veh, 0, 0)
          SetVehicleExtraColours(veh, 0, 0)

        end


        TriggerEvent("keys:addNew",veh,plate)
        SetVehicleHasBeenOwnedByPlayer(veh,true)
        

        local id = NetworkGetNetworkIdFromEntity(veh)
        SetNetworkIdCanMigrate(id, true)
        



        TriggerServerEvent('garages:SetVehOut', veh, plate)

          SetPedIntoVehicle(GetPlayerPed(-1), veh, - 1)

          TriggerServerEvent('veh.getVehicles', plate, veh)
          

        if GetEntityModel(veh) == GetHashKey("rumpo") then
          SetVehicleLivery(veh,0)
        end

        if GetEntityModel(veh) == GetHashKey("taxi") then

          SetVehicleExtra(veh, 8, 1)
          SetVehicleExtra(veh, 9, 1)
          SetVehicleExtra(veh, 6, 0)

        end

        SetEntityAsMissionEntity(veh,false,true)
        TriggerEvent("chop:plateoff",plate)
      end
      
    TriggerServerEvent("garages:CheckGarageForVeh")
  end)
end)



Citizen.CreateThread(function()
    print("starting")
    local invehicle = false
    local plateupdate = "None"
    local vehobj = 0
    while true do
        Wait(1000)
        if not invehicle and IsPedInAnyVehicle(GetPlayerPed(-1), false) then
        local playerPed = GetPlayerPed(-1)
        local veh = GetVehiclePedIsIn(playerPed, false)
          if GetPedInVehicleSeat(veh, -1) == GetPlayerPed(-1) then
            vehobj = veh
            print("entered vehicle as driver")
            local checkplate = GetVehicleNumberPlateText(veh)
            print("updating plate coords for " .. checkplate)
            invehicle = true
            plateupdate = checkplate
            local coords = GetEntityCoords(vehobj)
            coords = { coords["x"], coords["y"], coords["z"] }
            TriggerServerEvent("vehicle:coords",plateupdate,coords)
          end
        end
        if invehicle and not IsPedInAnyVehicle(GetPlayerPed(-1), false) then
          print("exited vehicle driver")
          print("updating plate coords for " .. plateupdate .. " and resetting")
          local coords = GetEntityCoords(vehobj)
          coords = { coords["x"], coords["y"], coords["z"] }
          TriggerServerEvent("vehicle:coords",plateupdate,coords)
          invehicle = false
          plateupdate = "None"
          vehobj = 0
        end  
    end
end)


function CheckExistenceOfVehWithPlate(platesent)
    local playerped = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(playerped)
    local handle, scannedveh = FindFirstVehicle()
    local success
    local rped = nil
    local distanceFrom
    repeat
        local pos = GetEntityCoords(scannedveh)
        local distance = GetDistanceBetweenCoords(playerCoords, pos, true)
          if distance < 50.0 then
            local checkplate = GetVehicleNumberPlateText(scannedveh)
            if checkplate == platesent then
              return true
            end
          end
        success, scannedveh = FindNextVehicle(handle)
    until not success
    EndFindVehicle(handle)
    return false
end



RegisterNetEvent("phone:Garage")
AddEventHandler("phone:Garage", function(vehs)
    vehicles = vehs
    SendNUIMessage({
      openSection = "garages"
    })

    local rankCarshop = exports["isPed"]:GroupRank("car_shop")
    local rankImport = exports["isPed"]:GroupRank("illegal_carshop")

    local job = exports["isPed"]:isPed("myjob")

    if rankCarshop > 0 or rankImport > 0 or job == "judge" or job == "police" then
      SendNUIMessage({
        openSection = "carpaymentsowed"
      })
    end

    for ind, value in pairs(vehs) do
      enginePercent = value.engine_damage / 10
      bodyPercent = value.body_damage / 10
      vehName = value.name
      vehPlate = value.license_plate
      currentGarage = value.current_garage
      damages = " Engine %:" .. enginePercent .. " Body %:" .. bodyPercent .. ""
      state = value.vehicle_state
      currentGarage = currentGarage .. "(" .. state .. ")"
      coordlocation = value.coords
      allowspawnattempt = 0
      print(GetDistanceBetweenCoords(coordlocation[1],coordlocation[2],coordlocation[3],GetEntityCoords(GetPlayerPed(-1))))
      if GetDistanceBetweenCoords(coordlocation[1],coordlocation[2],coordlocation[3],GetEntityCoords(GetPlayerPed(-1))) < 20.0 and state == "Out" then
        allowspawnattempt = 1
      end
      SendNUIMessage
      ({
        openSection = "addcar",
        name = vehName,
        plate = vehPlate,
        garage = currentGarage,
        damages = damages,
        payments = value.payments,
        last_payment = value.last_payment,
        amount_due = value.amount_due,
        canspawn = allowspawnattempt
      })
    end
    
end)

local pickuppoints = {
  [1] =  { ['x'] = 923.94,['y'] = -3037.88,['z'] = 5.91,['h'] = 270.81, ['info'] = ' Shipping Container BMZU 822693' },
  [2] =  { ['x'] = 938.02,['y'] = -3026.28,['z'] = 5.91,['h'] = 265.85, ['info'] = ' Shipping Container BMZU 822693' },
  [3] =  { ['x'] = 1006.17,['y'] = -3028.94,['z'] = 5.91,['h'] = 269.31, ['info'] = ' Shipping Container BMZU 822693' },
  [4] =  { ['x'] = 1020.42,['y'] = -3044.91,['z'] = 5.91,['h'] = 87.37, ['info'] = ' Shipping Container BMZU 822693' },
  [5] =  { ['x'] = 1051.75,['y'] = -3045.09,['z'] = 5.91,['h'] = 268.37, ['info'] = ' Shipping Container BMZU 822693' },
  [6] =  { ['x'] = 1134.92,['y'] = -2992.22,['z'] = 5.91,['h'] = 87.9, ['info'] = ' Shipping Container BMZU 822693' },
  [7] =  { ['x'] = 1149.1,['y'] = -2976.06,['z'] = 5.91,['h'] = 93.23, ['info'] = ' Shipping Container BMZU 822693' },
  [8] =  { ['x'] = 1121.58,['y'] = -3042.39,['z'] = 5.91,['h'] = 88.49, ['info'] = ' Shipping Container BMZU 822693' },
  [9] =  { ['x'] = 830.58,['y'] = -3090.46,['z'] = 5.91,['h'] = 91.15, ['info'] = ' Shipping Container BMZU 822693' },
  [10] =  { ['x'] = 830.81,['y'] = -3082.63,['z'] = 5.91,['h'] = 271.61, ['info'] = ' Shipping Container BMZU 822693' },
  [11] =  { ['x'] = 909.91,['y'] = -2976.51,['z'] = 5.91,['h'] = 271.02, ['info'] = ' Shipping Container BMZU 822693' },
}


function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end
blip = 0

function CreateBlip(location)
    DeleteBlip()
    blip = AddBlipForCoord(location["x"],location["y"],location["z"])
    SetBlipSprite(blip, 514)
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Pick Up")
    EndTextCommandSetBlipName(blip)
end
function DeleteBlip()
  if DoesBlipExist(blip) then
    RemoveBlip(blip)
  end
end

function refreshmail()
    lstnotifications = {}
    for i = 1, #curNotifications do

        local message2 = {
          id = tonumber(i),
          name = curNotifications[tonumber(i)].name,
          message = curNotifications[tonumber(i)].message
        }
        table.insert(lstnotifications, message2)
    end
    SendNUIMessage({openSection = "notifications", list = lstnotifications})
end

function rundropoff(boxcount,costs)

  print(curhrs .. " vs " .. curmins)
  if curhrs ~= curmins then
    for i = 1, math.random(20) do
      TriggerEvent("chatMessage", "SPAM EMAIL ", 8, "This message was blocked for your safety. Thank you for using nopixel mail services.")
    end
    refreshmail()
    return
  end
  local success = true
  local timer = 600000
  TriggerEvent("chatMessage", "EMAIL ", 8, "Yo, here are the coords for the drop off, you have 10 minutes - leave $" .. costs .. " in cash there!")
  refreshmail()
  local location = pickuppoints[math.random(#pickuppoints)]
  CreateBlip(location)
  while timer > 0 do
    Citizen.Wait(1)
    local plycoords = GetEntityCoords(GetPlayerPed(-1))
    local dstcheck = GetDistanceBetweenCoords(plycoords,location["x"],location["y"],location["z"]) 
    if dstcheck < 5.0 then
      DrawText3Ds(location["x"],location["y"],location["z"], "Press E to pickup the dropoff.")
       if dstcheck < 3.0 and IsControlJustReleased(0,38) then
          success = true
          timer = 0
       end
    end
    timer = timer - 1
    if timer == 1 then
      success = false
    end
  end
  if success then
    TriggerServerEvent("weed:phone:buybox",boxcount,costs)
  end
  DeleteBlip()
end


-- turn this to false to re-enable weed purchases.
local waiting = true
RegisterNUICallback('btnBox1', function()
  if waiting then
    return
  end
  waiting = true
  
  --Citizen.Wait(math.random(100000))
  rundropoff(1,1100)
  waiting = false
end)

RegisterNUICallback('btnBox2', function()
  if waiting then
    return
  end
  waiting = true
  
  --Citizen.Wait(math.random(100000))
  rundropoff(5,4300)
  waiting = false
end)

RegisterNUICallback('btnBox3', function()
  if waiting then
    return
  end
  waiting = true
  
  --Citizen.Wait(math.random(100000))
  rundropoff(10,8500)
  waiting = false
end)

RegisterNUICallback('btnDelivery', function()
  TriggerEvent("trucker:confirmation")
end)

RegisterNUICallback('btnPackages', function()
  insideDelivers = true
  TriggerEvent("Trucker:GetPackages")
end)

RegisterNUICallback('btnTrucker', function()
  TriggerEvent("Trucker:GetJobs")
end)

RegisterNUICallback('resetPackages', function()
  insideDelivers = false
end)

--[[

for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    


]]


RegisterNetEvent("phone:trucker")
AddEventHandler("phone:trucker", function(jobList)
    SendNUIMessage({
      openSection = "trucker"
    })

    for i, v in pairs(jobList) do
      local nameTag = ""
      local itemTag

      local currentStreetHash, intersectStreetHash = GetStreetNameAtCoord(v.pickup[1], v.pickup[2], v.pickup[3], currentStreetHash, intersectStreetHash)
      local currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
      local intersectStreetName = GetStreetNameFromHashKey(intersectStreetHash)

      local currentStreetHash2, intersectStreetHash2 = GetStreetNameAtCoord(v.drop[1], v.drop[2], v.drop[3], currentStreetHash2, intersectStreetHash2)
      local currentStreetName2 = GetStreetNameFromHashKey(currentStreetHash2)
      local intersectStreetName2 = GetStreetNameFromHashKey(intersectStreetHash2)
      if v.active == 0 then
          SendNUIMessage({openSection = "addtrucker",  street1 = currentStreetName, street2 = currentStreetName2, jobId = v.id , jobType = v.JobType})
      end
    end 
end)

local requestHolder = 0

RegisterNetEvent("phone:packages")
AddEventHandler("phone:packages", function(packages)
  while insideDelivers do
    if requestHolder ~= 0 then
      SendNUIMessage({
        openSection = "packagesWith"
      })
    else
      SendNUIMessage({
        openSection = "packages"
      })
    end 
    

    for i, v in pairs(packages) do
      if GetPlayerServerId(PlayerId()) == v.source then
        local currentStreetHash2, intersectStreetHash2 = GetStreetNameAtCoord(v.drop[1], v.drop[2], v.drop[3], currentStreetHash2, intersectStreetHash2)
        local currentStreetName2 = GetStreetNameFromHashKey(currentStreetHash2)
        local intersectStreetName2 = GetStreetNameFromHashKey(intersectStreetHash2)

        SendNUIMessage({openSection = "addPackages", street2 = currentStreetName2, jobId = v.id ,distance = getDriverDistance(v.driver , v.drop)})
      end
    end 
    Wait(4000)
  end
end)


RegisterNetEvent("phone:OwnerRequest")
AddEventHandler("phone:OwnerRequest", function(holder)
  requestHolder = holder
end)

RegisterNUICallback('btnRequest', function()
  TriggerServerEvent("trucker:confirmRequest",requestHolder)
  requestHolder = 0
end)




function getDriverDistance(driver , drop)
  local dist = 0

  local ped = GetPlayerPed(value)
  if driver ~= 0 then
    local current = GetDistanceBetweenCoords(drop[1],drop[2],drop[3],GetEntityCoords(ped))
    if current < 15 then
      dist = "Driver at store"
    else
      dist = current
      dist = math.ceil(dist)
    end
    
  else
    dist = "Waiting for driver"
  end

  return dist
end

RegisterNUICallback('selectedJob', function(data, cb)
    TriggerEvent("Trucker:SelectJob",data)
end)

gurgleList = {}
RegisterNetEvent('websites:updateClient')
AddEventHandler('websites:updateClient', function(passedList)
  gurgleList = passedList
  for i = 1, #gurgleList do
    if not guiEnabled then
      return
    end
    SendNUIMessage({
      openSection = "websiteAdd", 
      webTitle = gurgleList[i]["Title"], 
      webKeywords = gurgleList[i]["Keywords"], 
      webDescription = gurgleList[i]["Description"] 
      })
  end
end)

function hasDecrypt2()
    if exports["np-inventory"]:hasEnoughOfItem(81,1,false) and not exports["isPed"]:isPed("disabled") then
      return true
    else
      return false
    end
end

function hasTrucker()
    if exports["np-base"]:getModule("LocalPlayer"):getVar("job") == "trucker"  then
      return true
    else
      return false
    end
end

function hasDecrypt()
    if exports["np-inventory"]:hasEnoughOfItem(80,1,false) or exports["np-inventory"]:hasEnoughOfItem(78,1,false) or exports["np-inventory"]:hasEnoughOfItem(79,1,false) and not exports["isPed"]:isPed("disabled") or exports["np-inventory"]:hasEnoughOfItem(80,1,false) and not exports["isPed"]:isPed("disabled") then
      return true
    else
      return false
    end
end

function hasDevice()
    if exports["np-inventory"]:hasEnoughOfItem(103,1,false) and not exports["isPed"]:isPed("disabled") then
      return true
    else
      return false
    end
end

function hasPhone()
    if exports["np-inventory"]:hasEnoughOfItem(66,1,false) and not exports["isPed"]:isPed("disabled") and not exports["isPed"]:isPed("handcuffed") then
      return true
    else
      return false
    end
end

function hasRadio()
    if exports["np-inventory"]:hasEnoughOfItem(67,1,false) and not exports["isPed"]:isPed("disabled") then
      return true
    else
      return false
    end
end

function DrawRadioChatter(x,y,z, text,opacity)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    if opacity > 215 then
      opacity = 215
    end
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, opacity)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end
local activeMessages = 0

RegisterNetEvent('radiotalkcheck')
AddEventHandler('radiotalkcheck', function(args,senderid)

  if hasRadio() and radioChannel ~= 0 then
    randomStatic(true)

    local ped = GetPlayerPed( -1 )

      if ( DoesEntityExist( ped ) and not IsEntityDead( ped )) then

        loadAnimDict( "random@arrests" )

        TaskPlayAnim(ped, "random@arrests", "generic_radio_chatter", 8.0, 2.0, -1, 50, 2.0, 0, 0, 0 )

        SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
      end


    TriggerServerEvent("radiotalkconfirmed",args,senderid,radioChannel)
    Citizen.Wait(2500)
    ClearPedSecondaryTask(GetPlayerPed(-1))
  end

end)




function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end 

function randomStatic(loud)
  local vol = 0.05
  if loud then
    vol = 0.9
  end
  local pickS = math.random(4)
  if pickS == 4 then
    TriggerEvent("InteractSound_CL:PlayOnOne","radiostatic1",vol)
  elseif pickS == 3 then
    TriggerEvent("InteractSound_CL:PlayOnOne","radiostatic2",vol)
  elseif pickS == 2 then
    TriggerEvent("InteractSound_CL:PlayOnOne","radiostatic3",vol)
  else
    TriggerEvent("InteractSound_CL:PlayOnOne","radioclick",vol)
  end

end

RegisterNetEvent('radiotalk')
AddEventHandler('radiotalk', function(args,senderid,channel)

    local senderid = tonumber(senderid)

    table.remove(args,1)
    local radioMessage = ""
    for i = 1, #args do
        radioMessage = radioMessage .. " " .. args[i]
    end

    if channel == radioChannel and hasRadio() and radioMessage ~= nil then
      -- play radio click sound locally.
      TriggerEvent('chatMessage', "RADIO #" .. channel, 3, radioMessage, 5000)
      randomStatic(true)

      local radioMessage = ""
      for i = 1, #args do
        if math.random(50) > 25 then
          radioMessage = radioMessage .. " " .. args[i]
        else
          radioMessage = radioMessage .. " **BZZZ** "
        end
      end
      TriggerServerEvent("radiochatter:server",radioMessage)
    end
end)
RegisterNetEvent('radiochatter:client')
AddEventHandler('radiochatter:client', function(radioMessage,senderid)

    local senderid = tonumber(senderid) 
    local location = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(senderid)))
    local dst = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), location, true)
    activeMessages = activeMessages + 0.1
    if dst < 5.0 then
      -- play radio static sound locally.
      local counter = 350
      local msgZ = location["z"]+activeMessages
      if GetPlayerPed(-1) ~= GetPlayerPed(GetPlayerFromServerId(senderid)) then
        randomStatic(false)
        while counter > 0 and dst < 5.0 do
          location = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(senderid)))
          dst = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), location, true)
          DrawRadioChatter(location["x"],location["y"],msgZ, "Radio Chatter: " .. radioMessage, counter)
          counter = counter - 1
          Citizen.Wait(1)
        end
      end
    end
    activeMessages = activeMessages - 0.1 
end)


RegisterNetEvent('radiochannel')
AddEventHandler('radiochannel', function(chan)
  local chan = tonumber(chan)
  if hasRadio() and chan < 1000 and chan > -1 then
    radioChannel = chan
    TriggerEvent("InteractSound_CL:PlayOnOne","radioclick",0.4)
    TriggerEvent('chatMessage', "RADIO CHANNEL " .. radioChannel, 3, "Active", 5000)
    -- play radio click sound.
  end
end)

RegisterNetEvent('canPing')
AddEventHandler('canPing', function(target)
  if hasPhone() and imdead == 0 then
    local crds = GetEntityCoords(GetPlayerPed(-1))
    TriggerServerEvent("requestPing", target, crds["x"],crds["y"],crds["z"] )
  else
    TriggerEvent("DoLongHudText","You need a phone to use GPS!",2)
  end
end)

local pingcount = 0
local currentblip = 0
local currentping = { ["x"] = 0.0,["y"] = 0.0,["z"] = 0.0, ["src"] = 0 }
RegisterNetEvent('allowedPing')
AddEventHandler('allowedPing', function(x,y,z,src,name)
  if pingcount > 0 then
    TriggerEvent("DoLongHudText","Somebody sent you a GPS flag but you already have one in process!",2)
    return
  end
  
  if hasPhone() and imdead == 0 then
    pingcount = 5
    currentping = { ["x"] = x,["y"] = y,["z"] = z, ["src"] = src }
    while pingcount > 0 do
      TriggerEvent("DoLongHudText",name .. "has given you a ping location, type /pingaccept to accept",2)
      Citizen.Wait(5000)
      pingcount = pingcount - 1
    end
  else
    TriggerEvent("DoLongHudText","Somebody sent you a GPS flag but you have no phone!",2)
  end
  pingcount = 0
  currentping = { ["x"] = 0.0,["y"] = 0.0,["z"] = 0.0, ["src"] = 0 }
end)

RegisterNetEvent('acceptPing')
AddEventHandler('acceptPing', function()
  print("accepting ping?")
  if pingcount > 0 then
    if DoesBlipExist(currentblip) then
      RemoveBlip(currentblip)
    end
    print("creating ping?")
    currentblip = AddBlipForCoord(currentping["x"], currentping["y"], currentping["z"])
    SetBlipSprite(currentblip, 280)
    SetBlipAsShortRange(currentblip, false)
    BeginTextCommandSetBlipName("STRING")
    SetBlipColour(currentblip, 4)
    SetBlipScale(currentblip, 1.2)
    AddTextComponentString("Accepted GPS Marker")
    EndTextCommandSetBlipName(currentblip)
    TriggerEvent("DoLongHudText","Their GPS ping has been marked on the map")
    TriggerServerEvent("pingAccepted",currentping["src"])
    pingcount = 0
    Citizen.Wait(60000)
    if DoesBlipExist(currentblip) then
      RemoveBlip(currentblip)
    end
  end
end)


--radiotalk
--radiochannel

-- Open Gui and Focus NUI

-- read -- cellphone_text_read_base
-- texting -- cellphone_swipe_screen
-- phone away -- cellphone_text_out


local recentopen = false
function openGuiNow()

  if hasPhone() then
    
    GiveWeaponToPed(GetPlayerPed(-1), 0xA2719263, 0, 0, 1)
    guiEnabled = true
    SetNuiFocus(true)
    TriggerServerEvent("websitesList")

    local device = false
    if hasDevice() then
      device = true
    end
    local decrypt = false
    if hasDecrypt() then
      decrypt = true
    end
    local decrypt2 = false
    if hasDecrypt2() then
      print("decrypt2")
      decrypt2 = true
    end

    local trucker = false
    if hasTrucker() then
      print("has trucker")
      trucker = true
    end

    SendNUIMessage({openPhone = true, hasDevice = device, hasDecrypt = decrypt, hasDecrypt2 = decrypt2,hasTrucker = trucker})

    TriggerEvent('phoneEnabled',true)
    TriggerEvent('animation:sms',true)

        --TaskStartScenarioInPlace(GetPlayerPed(-1), "CODE_HUMAN_MEDIC_TIME_OF_DEATH", 0, 1)
        
    -- If this is the first time we've opened the phone, load all contacts
    if hasOpened == false then
      lstContacts = {}
      TriggerServerEvent('phone:getContacts')
      hasOpened = true
    end
    doTimeUpdate()
  else
    closeGui()
    if not exports["isPed"]:isPed("disabled") then
      TriggerEvent("DoLongHudText","You do not have a phone.",2)
    else
      TriggerEvent("DoLongHudText","You cannot use your phone right now.",2)
    end
  end
  recentopen = false
end

function openGui()
  if recentopen then
    return
  end
  if hasPhone() then
    
    GiveWeaponToPed(GetPlayerPed(-1), 0xA2719263, 0, 0, 1)
    guiEnabled = true
    SetNuiFocus(true)
    TriggerServerEvent("websitesList")

    local device = false
    if hasDevice() then
      device = true
    end
    local decrypt = false
    if hasDecrypt() then
      decrypt = true
    end
    local decrypt2 = false
    if hasDecrypt2() then
      print("decrypt2")
      decrypt2 = true
    end

    local trucker = false
    if hasTrucker() then
      print("has trucker")
      trucker = true
    end

    SendNUIMessage({openPhone = true, hasDevice = device, hasDecrypt = decrypt, hasDecrypt2 = decrypt2,hasTrucker = trucker})

    TriggerEvent('phoneEnabled',true)
    TriggerEvent('animation:sms',true)

        --TaskStartScenarioInPlace(GetPlayerPed(-1), "CODE_HUMAN_MEDIC_TIME_OF_DEATH", 0, 1)
        
    -- If this is the first time we've opened the phone, load all contacts
    if hasOpened == false then
      lstContacts = {}
      TriggerServerEvent('phone:getContacts')
      hasOpened = true
    end
    doTimeUpdate()
  else
    closeGui()
    if not exports["isPed"]:isPed("disabled") then
      TriggerEvent("DoLongHudText","You do not have a phone.",2)
    else
      TriggerEvent("DoLongHudText","You cannot use your phone right now.",2)
    end
  end
  Citizen.Wait(3000)
  recentopen = false
end

RegisterNUICallback('btnPagerType', function(data, cb)
  TriggerServerEvent("secondaryjob:ServerReturnDate")
end)
local jobnames = {
  ["taxi"] = "Taxi Driver",
  ["towtruck"] = "Tow Truck Driver",
  ["trucker"] = "Delivery Driver",
}

RegisterNUICallback('newPostSubmit', function(data, cb)

  local myjob = exports["isPed"]:isPed("myjob")
  if myjob ~= "taxi" and myjob ~= "towtruck" and myjob ~= "trucker" then
    TriggerServerEvent('phone:updatePhoneJob', data.advert)
  else
    TriggerServerEvent('phone:updatePhoneJob', jobnames[myjob] .. " | " .. data.advert)
    TriggerEvent("DoLongHudText","You are already listed as a " .. myjob)
  end
  
end)

RegisterNUICallback('deleteYP', function()
  TriggerServerEvent('phone:RemovePhoneJob')
end)

RegisterNetEvent('YPUpdatePhone')
AddEventHandler('YPUpdatePhone', function()

  lstnotifications = {}

  for i = 1, #YellowPageArray do
      local messageConverted = "<b>" .. YellowPageArray[tonumber(i)].job .. "</b> <br> Phone Number " .. YellowPageArray[tonumber(i)].phonenumber
      local message2 = {
        id = tonumber(i),
        name = YellowPageArray[tonumber(i)].name,
        message = messageConverted
      }

      table.insert(lstnotifications, message2)
  end

    
  SendNUIMessage({openSection = "notificationsYP", list = lstnotifications})
end)

-- Close Gui and disable NUI
function closeGui()
  SetNuiFocus(false,false)
  SendNUIMessage({openPhone = false})
  guiEnabled = false
  TriggerEvent('animation:sms',false)
  TriggerEvent('phoneEnabled',false)
  recentopen = true
  Citizen.Wait(3000)
  recentopen = false
  insideDelivers = false
end

function closeGui2()
  SetNuiFocus(false)
  SendNUIMessage({openPhone = false})
  guiEnabled = false
  recentopen = true
  Citizen.Wait(3000)
  recentopen = false  
end
local mousenumbers = {
  [1] = 1,
  [2] = 2,
  [3] = 3, 
  [4] = 4, 
  [5] = 5, 
  [6] = 6, 
  [7] = 12, 
  [8] = 13, 
  [9] = 66, 
  [10] = 67, 
  [11] = 95, 
  [12] = 96,   
  [13] = 97,   
  [14] = 98,
  [15] = 169,
   [16] = 170,
}

-- Disable controls while GUI open
Citizen.CreateThread(function()
  local focus = true
  while true do

    if guiEnabled then
      
      SendNUIMessage({openSection = "callStatus", status = callStatus})
      DisableControlAction(0, 1, guiEnabled) -- LookLeftRight
      DisableControlAction(0, 2, guiEnabled) -- LookUpDown
      DisableControlAction(0, 14, guiEnabled) -- INPUT_WEAPON_WHEEL_NEXT
      DisableControlAction(0, 15, guiEnabled) -- INPUT_WEAPON_WHEEL_PREV
      DisableControlAction(0, 16, guiEnabled) -- INPUT_SELECT_NEXT_WEAPON
      DisableControlAction(0, 17, guiEnabled) -- INPUT_SELECT_PREV_WEAPON
      DisableControlAction(0, 99, guiEnabled) -- INPUT_VEH_SELECT_NEXT_WEAPON
      DisableControlAction(0, 100, guiEnabled) -- INPUT_VEH_SELECT_PREV_WEAPON
      DisableControlAction(0, 115, guiEnabled) -- INPUT_VEH_FLY_SELECT_NEXT_WEAPON
      DisableControlAction(0, 116, guiEnabled) -- INPUT_VEH_FLY_SELECT_PREV_WEAPON
      DisableControlAction(0, 142, guiEnabled) -- MeleeAttackAlternate
      DisableControlAction(0, 106, guiEnabled) -- VehicleMouseControlOverride
      if IsDisabledControlJustReleased(0, 142) then -- MeleeAttackAlternate
        SendNUIMessage({type = "click"})
      end
  --    if IsControlJustReleased(0,27) then
  --      focus = not focus
  --      SetNuiFocus(focus)
  --    end
    else
      mousemovement = 0
    end

    Citizen.Wait(1)
  end
end)



-- Opens our phone
RegisterNetEvent('phoneGui2')
AddEventHandler('phoneGui2', function()
  openGui()
end)

-- NUI Callback Methods
RegisterNUICallback('close', function(data, cb)
  closeGui()
  cb('ok')
end)

RegisterNetEvent('phone:close')
AddEventHandler('phone:close', function(number, message)
  closeGui()

end)




RegisterNUICallback('2ndRemove', function(data, cb)
  TriggerEvent("secondaryjob:removejob")
  cb('ok')
end)

RegisterNUICallback('2ndWeedSt', function(data, cb)
  TriggerEvent("secondaryjob:weedStreet")
  cb('ok')
end)
RegisterNUICallback('2ndWeedHigh', function(data, cb)
  TriggerEvent("secondaryjob:weedHigh")
  cb('ok')
end)
RegisterNUICallback('2ndMethSt', function(data, cb)
  TriggerEvent("secondaryjob:cocaineStreet")
  cb('ok')
end)
RegisterNUICallback('2ndMethHigh', function(data, cb)
  TriggerEvent("secondaryjob:cocaineHigh")
  cb('ok')
end)
RegisterNUICallback('2ndGunSt', function(data, cb)
  TriggerEvent("secondaryjob:gunStreet")
  cb('ok')
end)
RegisterNUICallback('2ndGunHigh', function(data, cb)
  TriggerEvent("secondaryjob:gunHigh")
  cb('ok')
end)
RegisterNUICallback('2ndGunSmith', function(data, cb)
  local rank = exports["isPed"]:GroupRank("carpet_factory")
  if rank > 0 then
    TriggerEvent("secondaryjob:gunSmith")
  else
    TriggerEvent("DoLongHudText","This does not seem to work.")
  end
  cb('ok')
end)
RegisterNUICallback('2ndMoneyCleaner', function(data, cb)
  TriggerEvent("secondaryjob:moneyCleaner")
  cb('ok')
end)
RegisterNUICallback('2ndMoneySt', function(data, cb)
  TriggerEvent("secondaryjob:moneyStreet")
  cb('ok')
end)
RegisterNUICallback('2ndMoneyHigh', function(data, cb)
  TriggerEvent("secondaryjob:moneyHigh")
  cb('ok')
end)

-- phone button EVH




RegisterNUICallback('btnStances', function()
  closeGui()
  TriggerEvent("openSubMenu","Anim Sets")
end)

RegisterNUICallback('btnMarkers', function()
  TriggerEvent("GPSLocations")
   
end)

RegisterNUICallback('btnProps', function()
  closeGui()
  TriggerEvent("openSubMenu","Prop Attach")
end)


RegisterNUICallback('btnShowId', function()
  closeGui()
  TriggerEvent("checkmyId")
  loadAnimDict('friends@laf@ig_5')
  TaskPlayAnim(GetPlayerPed(-1),'friends@laf@ig_5', 'nephew',5.0, 1.0, 5.0, 48, 0.0, 0, 0, 0)

  
end)

RegisterNUICallback('btnEmotes', function()
  closeGui()
  TriggerEvent("emotes:OpenMenu")
end)

RegisterNUICallback('btnPagerToggle', function()
  TriggerEvent("togglePager")
end)

RegisterNUICallback('btnCarKey', function()
  closeGui()
  TriggerEvent("keys:give")
end)

RegisterNUICallback('btnHouseKey', function()
  closeGui()
  TriggerEvent("apart:giveKey")
end)










-- SMS Callbacks
RegisterNUICallback('messages', function(data, cb)
  loading()
  if (#lstMsgs == 0) then

    TriggerServerEvent('phone:getSMS')
  else
    SendNUIMessage({openSection = "messages", list = lstMsgs})
  end
  cb('ok')
end)

RegisterNUICallback('messageRead', function(data, cb)

  SendNUIMessage({openSection = "messageRead", list = lstMsgs, senderN = data.number})


  cb('ok')
end)

RegisterNUICallback('messageDelete', function(data, cb)
  TriggerServerEvent('phone:removeSMS', data.id, data.number)
  cb('ok')
end)

RegisterNUICallback('newMessage', function(data, cb)
  SendNUIMessage({openSection = "newMessage"})
  cb('ok')
end)





RegisterNUICallback('messageReply', function(data, cb)
  SendNUIMessage({openSection = "newMessageReply", number = data.number})
  cb('ok')
end)

RegisterNUICallback('newMessageSubmit', function(data, cb)
  if imdead == 0 then
    TriggerEvent('phone:sendSMS', tonumber(data.number), data.message)
    cb('ok')
  else
    TriggerEvent("DoLongHudText","You can not do this while injured.",2)
  end
end)



-- Contact Callbacks
RegisterNUICallback('contacts', function(data, cb)

  if (#lstMsgs == 0) then

    TriggerServerEvent('phone:getSMSc')

  end


  SendNUIMessage({openSection = "contacts"})
  cb('ok')
end)

RegisterNUICallback('newContact', function(data, cb)
  SendNUIMessage({openSection = "newContact"})
  cb('ok')
end)

RegisterNUICallback('newContactSubmit', function(data, cb)
  TriggerEvent('phone:addContact', data.name, tonumber(data.number))
  cb('ok')
end)

RegisterNUICallback('removeContact', function(data, cb)
  TriggerServerEvent('phone:removeContact', data.name, data.number)
  cb('ok')
end)

--call status 0 = no call, 1 = dialing, 2 = receiving call, 3 = in progresss
myID = 0
mySourceID = 0

mySourceHoldStatus = false
callStatus = 0
costCount = 1
RegisterNetEvent('animation:phonecallstart')
AddEventHandler('animation:phonecallstart', function()

  local lPed = GetPlayerPed(-1)
  RequestAnimDict("cellphone@")
  while not HasAnimDictLoaded("cellphone@") do
    Citizen.Wait(0)
  end
  local count = 0
  costCount = 1
  inPhone = false
  Citizen.Wait(200)
  ClearPedTasks(lPed)
  
  TriggerEvent("attachItemPhone","phone01")

  TriggerEvent("DoShortHudText", "[E] Toggles Call.",10)

  print("Call Information: Status" .. callStatus .. " SourceID" .. mySourceID .. " MyID" .. myID)

  if mySourceHoldStatus then
    print("Other party on hold")
  else
    print("Other party not on hold")
  end

  while callStatus ~= 0 do

    local dead = exports["isPed"]:isPed("dead")
    if dead then
      print("Ending call because I am dead?")
      endCall()
    end


    if IsEntityPlayingAnim(lPed, "cellphone@", "cellphone_call_listen_base", 3) and not IsPedRagdoll(GetPlayerPed(-1)) then
      --ClearPedSecondaryTask(lPed)
    else 



      if IsPedRagdoll(GetPlayerPed(-1)) then
        Citizen.Wait(1000)
      end
      TaskPlayAnim(lPed, "cellphone@", "cellphone_call_listen_base", 1.0, 1.0, -1, 49, 0, 0, 0, 0)
    end
    Citizen.Wait(1)
    count = count + 1

    if AnonCall then
       local dPB = GetDistanceBetweenCoords(PhoneBooth, GetEntityCoords( GetPlayerPed(-1) ), true)
       if dPB > 2.0 then
        TriggerEvent("DoShortHudText", "Moved Too Far.",10)
        print("Ending call because I moved too much?")
        endCall()
       end
    end



    if IsControlJustPressed(0, 38) then
      TriggerEvent("phone:holdToggle")
    end

    if onhold then
      if count == 800 then
         count = 0
         TriggerEvent("DoShortHudText", "Call On Hold.",10)
      end
    end

      --check if not unarmed
    local curw = GetSelectedPedWeapon(GetPlayerPed(-1))
    noweapon = GetHashKey("WEAPON_UNARMED")
    if noweapon ~= curw then
      SetCurrentPedWeapon(GetPlayerPed(-1), GetHashKey("WEAPON_UNARMED"), true)
    end

  end
  ClearPedTasks(lPed)
  TaskPlayAnim(lPed, "cellphone@", "cellphone_call_out", 2.0, 2.0, 800, 49, 0, 0, 0, 0)
  Citizen.Wait(700)
  TriggerEvent("destroyPropPhone")
  
end)


imdead = 0
RegisterNetEvent('pd:deathcheck')
AddEventHandler('pd:deathcheck', function()
  if imdead == 0 then 
    print("Ending call because I am dead?")
    endCall()
    imdead = 1
  else
    imdead = 0
  end
end)

RegisterNetEvent('phone:makecall')
AddEventHandler('phone:makecall', function(pnumber)

  local pnumber = tonumber(pnumber)
  AnonCall = false
  if callStatus == 0 and imdead == 0 and hasPhone() then
    callStatus = 1
    TriggerEvent("animation:phonecallstart")
    recentcalls[#recentcalls + 1] = { ["type"] = 2, ["number"] = pnumber, ["name"] = getContactName(pnumber) }
    TriggerServerEvent('phone:callContact', pnumber, true)
  else
    TriggerEvent("DoLongHudText","It appears you are already in a call, injured or with out a phone, please type /hangup to reset your calls.",2)
  end
end)



local PayPhoneHex = {
  [1] = 1158960338,
  [2] = -78626473,
  [3] = 1281992692,
  [4] = -1058868155,
  [5] = -429560270,
  [6] = -2103798695,
  [7] = 295857659,
}

function checkForPayPhone()
  for i = 1, #PayPhoneHex do
    local objFound = GetClosestObjectOfType( GetEntityCoords(GetPlayerPed(-1)), 5.0, PayPhoneHex[i], 0, 0, 0)
    if DoesEntityExist(objFound) then
      return true
    end
  end
  return false
end

RegisterNetEvent('phone:makepayphonecall')
AddEventHandler('phone:makepayphonecall', function(pnumber)

    if not checkForPayPhone() then
      TriggerEvent("DoLongHudText","You are not near a payphone.",2)
      return
    end

    PhoneBooth = GetEntityCoords( GetPlayerPed(-1) )
    AnonCall = true

    local pnumber = tonumber(pnumber)
    if callStatus == 0 and imdead == 0 and hasPhone() then
      callStatus = 1
      TriggerEvent("animation:phonecallstart")
      TriggerEvent("InteractSound_CL:PlayOnOne","payphonestart",0.5)
      TriggerServerEvent('phone:callContact', pnumber, false)
    else
      TriggerEvent("DoLongHudText","It appears you are already in a call, injured or with out a phone, please type /hangup to reset your calls.",2)
    end

end)





RegisterNUICallback('callContact', function(data, cb)
  closeGui2()
  AnonCall = false
  if callStatus == 0 and imdead == 0 and hasPhone() then
    callStatus = 1
    TriggerEvent("animation:phonecallstart")
    TriggerServerEvent('phone:callContact', data.number, true)
  else
    TriggerEvent("DoLongHudText","It appears you are already in a call, injured or with out a phone, please type /hangup to reset your calls.",2)
  end
  cb('ok')
end)

debugn = false
function t(trace)
  print(trace)
end

RegisterNetEvent('phone:failedCall')
AddEventHandler('phone:failedCall', function()
    t("Failed Call")
    endCall()
end)




RegisterNetEvent('phone:hangup')
AddEventHandler('phone:hangup', function(AnonCall)
    if AnonCall then
      t("Call Anon Hangup")
      endCall2()
    else
      t("Call Hangup")
      endCall()
    end
end)

RegisterNetEvent('phone:hangupcall')
AddEventHandler('phone:hangupcall', function()
    if AnonCall then
      t("Call Anon Hangup 2")
      endCall2()
    else
      t("Call Hangup 2")
      endCall()
    end
end)
RegisterNetEvent('phone:otherClientEndCall')
AddEventHandler('phone:otherClientEndCall', function()

    TriggerEvent("DoLongHudText","Your call was ended!",2)
    myID = 0
    mySourceID = 0

    mySourceHoldStatus = false
    callStatus = 0
    onhold = false
    NetworkSetTalkerProximity(1.0)
    Citizen.Wait(1000)
    NetworkClearVoiceChannel()
    Citizen.Wait(1000)
    NetworkSetTalkerProximity(18.0)
end)

RegisterNUICallback('btnAnswer', function()
    closeGui()
    TriggerEvent("phone:answercall")
end)
RegisterNUICallback('btnHangup', function()
    closeGui()
    TriggerEvent("phone:hangup")
end)

RegisterNetEvent('phone:answercall')
AddEventHandler('phone:answercall', function()
    if callStatus == 2 and imdead == 0 then
    answerCall()
    TriggerEvent("animation:phonecallstart")
    TriggerEvent("DoLongHudText","You have answered a call.",1)
    callTimer = 0
  else
    TriggerEvent("DoLongHudText","You are not being called, injured, or you took too long.",2)
  end
end)

RegisterNetEvent('phone:initiateCall')
AddEventHandler('phone:initiateCall', function(recIdentifier, phoneNumber, srcID)
    
    TriggerEvent("DoLongHudText","You have started a call.",1)
    initiatingCall()
    if not AnonCall then
      TriggerEvent("InteractSound_CL:PlayOnOne","demo",0.1)
    end
end)

RegisterNetEvent('phone:callFullyInitiated')
AddEventHandler('phone:callFullyInitiated', function(srcID,sentSource)
 TriggerEvent("InteractSound_CL:PlayOnOne","demo",0.1)
  print("initiated call")
  myID = srcID
   print(myID)
  mySourceID = sentSource
  callStatus = 3
  callTimer = 0
  NetworkSetVoiceChannel(srcID+1)
  NetworkSetTalkerProximity(0.0)
  TriggerEvent("phone:callactive")
end)
function drawTxt(x,y ,width,height,scale, text, r,g,b,a)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end
RegisterNetEvent('phone:callactive')
AddEventHandler('phone:callactive', function()
    Citizen.Wait(100)
    local held1 = false
    local held2 = false
    while callStatus == 3 do
      local phoneString = ""
      Citizen.Wait(1)

      if onhold then
        phoneString = phoneString .. "They are on Hold | "
        if not held1 then
          TriggerEvent("DoLongHudText","You have put the caller on hold.",888)
          held1 = true
        end
      else
        phoneString = phoneString .. "Call Active | "
        if held1 then
          TriggerEvent("DoLongHudText","Your call is no longer on hold.",888)
          held1 = false
        end
      end

      if mySourceHoldStatus then
        phoneString = phoneString .. "You are on hold"
        if not held2 then
          TriggerEvent("DoLongHudText","You are on hold.",2)
          held2 = true
        end
      else
        phoneString = phoneString .. "Caller Active"
        if held2 then
          TriggerEvent("DoLongHudText","You are no longer on hold.",2)
          held2 = false
        end
      end
      drawTxt(0.97, 1.46, 1.0,1.0,0.33, phoneString, 255, 255, 255, 255)  -- INT: kmh
    end
end)


RegisterNetEvent('phone:receiveCall')
AddEventHandler('phone:receiveCall', function(phoneNumber, srcID, calledNumber)
  recentcalls[#recentcalls + 1] = { ["type"] = 1, ["number"] = calledNumber, ["name"] = getContactName(calledNumber) }

  if callStatus == 0 then
    myID = 0
    mySourceID = srcID
    callStatus = 2    

    receivingCall(calledNumber)
  else

    TriggerEvent("DoLongHudText","You are receiving a call but are currently already in one, sending busy response.",2)
  end
end)
callTimer = 0
function initiatingCall()
  callTimer = 8

  TriggerEvent("DoLongHudText","You are making a call, please hold.",1)
  while (callTimer > 0 and callStatus == 1) do
    if AnonCall and callTimer < 7 then
      TriggerEvent("InteractSound_CL:PlayOnOne","payphoneringing",0.5)
    elseif not AnonCall then
      TriggerEvent("InteractSound_CL:PlayOnOne","cellcall",0.5)
    end
    
    Citizen.Wait(2500)
    callTimer = callTimer - 1
  end
  if callStatus == 1 then
    endCall()
  end
end

function receivingCall(calledNumber)
  callTimer = 8


  while (callTimer > 0 and callStatus == 2) do
    TriggerEvent("DoShortHudText","Call from: " .. calledNumber .. " /answer or /hangup",10)
    if phoneNotifications then
      TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 2.0, 'cellcall', 0.5)
    end
    Citizen.Wait(2300)
    callTimer = callTimer - 1
  end
end

function answerCall()
    if mySourceID ~= 0 then
      NetworkSetVoiceChannel(mySourceID+1)
      NetworkSetTalkerProximity(0.0)
      TriggerServerEvent("phone:StartCallConfirmed",mySourceID)
      callStatus = 3
      TriggerEvent("phone:callactive")
    end
end

function endCall()
  TriggerEvent("InteractSound_CL:PlayOnOne","demo",0.1)
  if mySourceID ~= 0 then
    TriggerServerEvent("phone:EndCall",mySourceID)
  end 
  myID = 0
  mySourceID = 0
  callStatus = 0
  onhold = false
  mySourceHoldStatus = false
  AnonCall = false
  NetworkSetTalkerProximity(1.0)
  Citizen.Wait(300)
  NetworkClearVoiceChannel()
  Citizen.Wait(300)
  NetworkSetTalkerProximity(18.0)
  SendNUIMessage({openSection = "callStatus", status = callStatus})
end
function endCall2()
  TriggerEvent("InteractSound_CL:PlayOnOne","payphoneend",0.1)
  if mySourceID ~= 0 then
    TriggerServerEvent("phone:EndCall",mySourceID)
  end 
  myID = 0
  mySourceID = 0
  callStatus = 0
  onhold = false
  mySourceHoldStatus = false
  AnonCall = false
  NetworkSetTalkerProximity(1.0)
  Citizen.Wait(300)
  NetworkClearVoiceChannel()
  Citizen.Wait(300)
  NetworkSetTalkerProximity(18.0)
  SendNUIMessage({openSection = "callStatus", status = callStatus})
end


RegisterNetEvent('phone:holdToggle')
AddEventHandler('phone:holdToggle', function()
  if myID == nil then
    myID = 0
  end
  if myID ~= 0 then
    if not onhold then
      TriggerEvent("DoShortHudText", "Call on hold.",10)
      onhold = true
      NetworkSetTalkerProximity(1.0)
      Citizen.Wait(300)
      NetworkClearVoiceChannel()
      Citizen.Wait(300)
      NetworkSetTalkerProximity(18.0)
      TriggerServerEvent("OnHold:Server",mySourceID,true)
    else
      TriggerEvent("DoShortHudText", "No longer on hold.",10)
      TriggerServerEvent("OnHold:Server",mySourceID,false)
      onhold = false
      NetworkSetVoiceChannel(myID+1)
      NetworkSetTalkerProximity(0.0)
    end
  else

    if mySourceID ~= 0 then
      if not onhold then
        TriggerEvent("DoShortHudText", "Call on hold.",10)
        onhold = true
        NetworkSetTalkerProximity(1.0)
        Citizen.Wait(300)
        NetworkClearVoiceChannel()
        Citizen.Wait(300)
        NetworkSetTalkerProximity(18.0)
        TriggerServerEvent("OnHold:Server",mySourceID,true)
      else
        TriggerEvent("DoShortHudText", "No longer on hold.",10)
        TriggerServerEvent("OnHold:Server",mySourceID,false)
        onhold = false
        NetworkSetVoiceChannel(mySourceID+1)
        NetworkSetTalkerProximity(0.0)
      end
    end

  end
end)


RegisterNetEvent('OnHold:Client')
AddEventHandler('OnHold:Client', function(newHoldStatus)
    mySourceHoldStatus = newHoldStatus
    if mySourceHoldStatus then
        TriggerEvent("DoLongHudText","You just got put on hold.")
    else
        TriggerEvent("DoLongHudText","Your caller is back on the line.")
    end

end)


curNotifications = {}




RegisterNetEvent('phone:addnotification')
AddEventHandler('phone:addnotification', function(name,message)
    if not guiEnabled then
      SendNUIMessage({
          openSection = "newemail"
      }) 
    end 
    curNotifications[#curNotifications+1] = { ["name"] = name, ["message"] = message }
end)



RegisterNetEvent('YellowPageArray')
AddEventHandler('YellowPageArray', function(pass)
    YellowPageArray = pass
end)

local currentTwats = {}





RegisterNetEvent('Client:UpdateTweet')
AddEventHandler('Client:UpdateTweet', function(tweets)
    local handle = exports["isPed"]:isPed("twitterhandle")
    currentTwats = tweets 
    if currentTwats[#currentTwats]["handle"] == handle then
      SendNUIMessage({openSection = "twatter", twats = currentTwats, myhandle = handle})
    end



    if string.find(currentTwats[#currentTwats]["message"],handle) then
      --
      if currentTwats[#currentTwats]["handle"] ~= handle then
        SendNUIMessage({openSection = "newtweet"})
      end


      if phoneNotifications then
        PlaySound(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0, 0, 1)
        TriggerEvent("DoLongHudText","You were just mentioned in a tweet on your phone.",15)
      end
    end

    if allowpopups and not guiEnabled then
      SendNUIMessage({openSection = "notify", handle = currentTwats[#currentTwats]["handle"], message =currentTwats[#currentTwats]["message"]})
    end

end)


local customGPSlocations = {
  [1] = { ["x"] = 484.77066040039, ["y"] = -77.643089294434, ["z"] = 77.600166320801, ["info"] = "Garage A"},
  [2] = { ["x"] = -331.96115112305, ["y"] = -781.52337646484, ["z"] = 33.964477539063,  ["info"] = "Garage B"},
  [3] = { ["x"] = -451.37295532227, ["y"] = -794.06591796875, ["z"] = 30.543809890747, ["info"] = "Garage C"},
  [4] = { ["x"] = 399.51190185547, ["y"] = -1346.2742919922, ["z"] = 31.121940612793, ["info"] = "Garage D"},
  [5] = { ["x"] = 598.77319335938, ["y"] = 90.707237243652, ["z"] = 92.829048156738, ["info"] = "Garage E"},
  [6] = { ["x"] = 641.53442382813, ["y"] = 205.42562866211, ["z"] = 97.186958312988, ["info"] = "Garage F"},
  [7] = { ["x"] = 82.359413146973, ["y"] = 6418.9575195313, ["z"] = 31.479639053345, ["info"] = "Garage G"},
  [8] = { ["x"] = -794.578125, ["y"] = -2020.8499755859, ["z"] = 8.9431390762329, ["info"] = "Garage H"},
  [9] = { ["x"] = -669.15631103516, ["y"] = -2001.7552490234, ["z"] = 7.5395741462708, ["info"] = "Garage I"},
  [10] = { ["x"] = -606.86322021484, ["y"] = -2236.7624511719, ["z"] = 6.0779848098755, ["info"] = "Garage J"},
  [11] = { ["x"] = -166.60482788086, ["y"] = -2143.9333496094, ["z"] = 16.839847564697, ["info"] = "Garage K"},
  [12] = { ["x"] = -38.922565460205, ["y"] = -2097.2663574219, ["z"] = 16.704851150513, ["info"] = "Garage L"},
  [13] = { ["x"] = -70.179389953613, ["y"] = -2004.4139404297, ["z"] = 18.016941070557, ["info"] = "Garage M"},
  [14] = { ["x"] = 549.47796630859, ["y"] = -55.197559356689, ["z"] = 71.069190979004, ["info"] = "Garage Impound Lot"},
  [15] = { ["x"] = 364.27685546875, ["y"] = 297.84490966797, ["z"] = 103.49515533447, ["info"] = "Garage O"},
  [16] = { ["x"] = -338.31619262695, ["y"] = 266.79782104492, ["z"] = 85.741966247559, ["info"] = "Garage P"},
  [17] = { ["x"] = 273.66683959961, ["y"] = -343.83737182617, ["z"] = 44.919876098633, ["info"] = "Garage Q"},
  [18] = { ["x"] = 66.215492248535, ["y"] = 13.700443267822, ["z"] = 69.047248840332, ["info"] = "Garage R"},
  [19] = { ["x"] = 3.3330917358398, ["y"] = -1680.7877197266, ["z"] = 29.170293807983, ["info"] = "Garage Imports"},
  [20] = { ["x"] = 286.67013549805, ["y"] = 79.613700866699, ["z"] = 94.362899780273, ["info"] = "Garage S"},
  [21] = { ["x"] = 211.79, ["y"] = -808.38, ["z"] = 30.833, ["info"] = "Garage T"},
  [22] = { ["x"] = 447.65, ["y"] = -1021.23, ["z"] = 28.45, ["info"] = "Garage Police Department"},
  [23] = { ["x"] = -25.59, ["y"] = -720.86, ["z"] = 32.22, ["info"] = "Garage House"},
}
local loadedGPS = false
RegisterNetEvent('openGPS')
AddEventHandler('openGPS', function(mansions,houses,rented)
  
  SendNUIMessage({openSection = "GPS"})
  if loadedGPS then
    return
  end
  for i = 1, #customGPSlocations do
    SendNUIMessage({openSection = "AddGPSLocation", info = customGPSlocations[i]["info"], house_id = i, house_type = 69})
    Citizen.Wait(1)
  end

  for i = 1, #mansions do
    SendNUIMessage({openSection = "AddGPSLocation", info = mansions[i]["info"], house_id = i, house_type = 2})
    Citizen.Wait(1)
  end

  for i = 1, #houses do
    SendNUIMessage({openSection = "AddGPSLocation", info = houses[i]["info"], house_id = i, house_type = 1})
    Citizen.Wait(1)
  end
  for i = 1, #rented do
    SendNUIMessage({openSection = "AddGPSLocation", info = rented[i]["name"], house_id = i, house_type = 3})
    Citizen.Wait(1)
  end
  loadedGPS = true
end)




RegisterNUICallback('loadUserGPS', function(data)
      TriggerEvent("GPS:SetRoute",data.house_id,data.house_type)
  


end)


RegisterNUICallback('btnTwatter', function()
  local handle = exports["isPed"]:isPed("twitterhandle")
  SendNUIMessage({openSection = "twatter", twats = currentTwats, myhandle = handle})
end)




RegisterNUICallback('newTwatSubmit', function(data, cb)
    local handle = exports["isPed"]:isPed("twitterhandle")
    TriggerServerEvent('Tweet', handle, data.twat)   
 
end)

RegisterNUICallback('btnCamera', function()
  SetNuiFocus(true,true)
end)
RegisterNUICallback('btnAccount', function()
  local cash = exports["isPed"]:isPed("mycash")
  local bank = exports["isPed"]:isPed("mybank")
  local myjob = exports["isPed"]:isPed("myjob")
  local licensestring = exports["isPed"]:isPed("licensestring")
  local pagerstatus = exports["isPed"]:isPed("pagerstatus")
  local SecondaryJob = exports["isPed"]:isPed("secondaryjob")
  local pagerString = " <br><b>Pager</b> | Disabled"
  if pagerstatus then
    pagerString = " <br><b>Pager</b> | Enabled"
  end
  local infoStats = "<div class='accountbubble'><div class='h6'>Licenses</div>" .. licensestring .. " </div><div class='accountbubble'>  <div class='h6'>Banking</div> <b>Cash</b> | $" .. cash .. " <br> <b> Bank</b> | $" .. bank .. " </div> <div class='accountbubble'>  <div class='h6'>Work Related</div> <b> Job</b> | " .. myjob .. "<br><b> Page Job</b> | " .. SecondaryJob .. "" .. pagerString .. "</div>"
  SendNUIMessage({openSection = "account", InfoString = infoStats})
end)

RegisterNUICallback('notificationsYP', function()

    lstnotificationsyp = {}

    for i = 1, #YellowPageArray do
        local messageConverted = "<b>" .. YellowPageArray[tonumber(i)].job .. "</b> <br> Phone Number " .. YellowPageArray[tonumber(i)].phonenumber
        local message2 = {
          id = tonumber(i),
          name = YellowPageArray[tonumber(i)].name,
          message = messageConverted
        }

        table.insert(lstnotificationsyp, message2)
    end

    
  SendNUIMessage({openSection = "notificationsYP", list = lstnotificationsyp})

end)


RegisterNUICallback('notifications', function()

    lstnotifications = {}

    for i = 1, #curNotifications do

        local message2 = {
          id = tonumber(i),
          name = curNotifications[tonumber(i)].name,
          message = curNotifications[tonumber(i)].message
        }

        table.insert(lstnotifications, message2)
    end

    
  SendNUIMessage({openSection = "notifications", list = lstnotifications})

end)

RegisterNetEvent('phone:loadSMSOther')
AddEventHandler('phone:loadSMSOther', function(messages,mynumber)
  openGui()
  lstMsgs = {}
  if (#messages ~= 0) then
    for k,v in pairs(messages) do
      if v ~= nil then
        local ireceived = false
        if v.receiver == mynumber then
          ireceived = true
        end
        local message = {
          id = tonumber(v.id),
          name = getContactName(v.sender),
          sender = tonumber(v.sender),
          receiver = tonumber(v.receiver),
          recipient = ireceived,
          date = tonumber(v.date),
          message = v.message
        }
        table.insert(lstMsgs, message)
      end
    end
  end
  SendNUIMessage({openSection = "messagesOther", list = lstMsgs})
end)




RegisterNetEvent('phone:newSMS')
AddEventHandler('phone:newSMS', function(id, number, message, mypn, date, recip)
  
  local omessage = message
  local message = {
      id = tonumber(id),
      name = getContactName(number),
      sender = tonumber(number),
      receiver = tonumber(mypn),
      recipient = recip,
      date = tonumber(date),
      message = message
  }
  table.insert(lstMsgs, message)

  SendNUIMessage({
    newSMS = true,
    sms = message,
  })


  lastnumber = number
  if recip then

    SendNUIMessage({
        openSection = "newsms"
    })  
    
    if phoneNotifications then
      TriggerEvent("DoLongHudText","You just received a new SMS.",16)
      PlaySound(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0, 0, 1)
    end
  end
end)

-- SMS Events
RegisterNetEvent('phone:loadSMS')
AddEventHandler('phone:loadSMS', function(messages,mynumber)

  lstMsgs = {}
  if (#messages ~= 0) then
    for k,v in pairs(messages) do
      if v ~= nil then
        local ireceived = false
        if v.receiver == mynumber then
          ireceived = true
        end
        local message = {
          id = tonumber(v.id),
          name = getContactName(v.sender),
          sender = tonumber(v.sender),
          receiver = tonumber(v.receiver),
          recipient = ireceived,
          date = tonumber(v.date),
          message = v.message
        }
        table.insert(lstMsgs, message)
      end
    end
  end
  SendNUIMessage({openSection = "messages", list = lstMsgs})
end)

RegisterNetEvent('phone:loadSMSbg')
AddEventHandler('phone:loadSMSbg', function(messages,mynumber)

  lstMsgs = {}
  if (#messages ~= 0) then
    for k,v in pairs(messages) do
      if v ~= nil then
        local ireceived = false
        if v.receiver == mynumber then
          ireceived = true
        end
        local message = {
          id = tonumber(v.id),
          name = getContactName(v.sender),
          sender = tonumber(v.sender),
          receiver = tonumber(v.receiver),
          recipient = ireceived,
          date = tonumber(v.date),
          message = v.message
        }
        table.insert(lstMsgs, message)
      end
    end
  end
  SendNUIMessage({openSection = "updateMessages", list = lstMsgs})
end)
RegisterNetEvent('phone:sendSMS')
AddEventHandler('phone:sendSMS', function(number, message)
  if(number ~= nil and message ~= nil) then
    TriggerServerEvent('phone:sendSMS', number, message)
    TriggerEvent("DoLongHudText","Message sent.",16)
    Citizen.Wait(1000)
    TriggerServerEvent('phone:getSMSc')
  else
    phoneMsg("You must fill in a number and message!")
  end
end)

local lastnumber = 0

-- read -- cellphone_text_read_base
-- texting -- cellphone_swipe_screen
-- phone away -- cellphone_text_out

RegisterNetEvent('animation:sms')
AddEventHandler('animation:sms', function(enable)
  local lPed = GetPlayerPed(-1)
  inPhone = enable

  RequestAnimDict("cellphone@")
  while not HasAnimDictLoaded("cellphone@") do
    Citizen.Wait(0)
  end

  local intrunk = exports["isPed"]:isPed("intrunk")
  if not intrunk then
    TaskPlayAnim(lPed, "cellphone@", "cellphone_text_in", 2.0, 3.0, -1, 49, 0, 0, 0, 0)
  end
  Citizen.Wait(300)
  if inPhone then
    TriggerEvent("attachItemPhone","phone01")
    Citizen.Wait(150)
    while inPhone do

      local dead = exports["isPed"]:isPed("dead")
      if dead then
        closeGui()
        inPhone = false
      end
      local intrunk = exports["isPed"]:isPed("intrunk")
      if not intrunk and not IsEntityPlayingAnim(lPed, "cellphone@", "cellphone_text_read_base", 3) and not IsEntityPlayingAnim(lPed, "cellphone@", "cellphone_swipe_screen", 3) then
        TaskPlayAnim(lPed, "cellphone@", "cellphone_text_read_base", 2.0, 3.0, -1, 49, 0, 0, 0, 0)
      end    
      Citizen.Wait(1)
    end
    local intrunk = exports["isPed"]:isPed("intrunk")
    if not intrunk then
      ClearPedTasks(GetPlayerPed(-1))
    end
  else
    local intrunk = exports["isPed"]:isPed("intrunk")
    if not intrunk then
      Citizen.Wait(100)
      ClearPedTasks(GetPlayerPed(-1))
      TaskPlayAnim(lPed, "cellphone@", "cellphone_text_out", 2.0, 1.0, 5.0, 49, 0, 0, 0, 0)
      Citizen.Wait(400)
      TriggerEvent("destroyPropPhone")
      Citizen.Wait(400)
      ClearPedTasks(GetPlayerPed(-1))
    else
      TriggerEvent("destroyPropPhone")
    end
  end
end)

local inTablet = false
RegisterNetEvent('animation:tablet')
AddEventHandler('animation:tablet', function(enable)

  local lPed = GetPlayerPed(-1)
  inPhone = enable
  if inPhone then
    TriggerEvent("attachItemPhone","tablet01")
    while inPhone do
      RequestAnimDict("amb@code_human_in_bus_passenger_idles@female@tablet@base")
      while not HasAnimDictLoaded("amb@code_human_in_bus_passenger_idles@female@tablet@base") do
        Citizen.Wait(0)
      end
  
      local dead = exports["isPed"]:isPed("dead")
      if dead then
        closeGui()
        inPhone = false
      end

      local intrunk = exports["isPed"]:isPed("intrunk")

      if not intrunk and not IsEntityPlayingAnim(lPed, "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 3) then
        TaskPlayAnim(lPed, "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 3.0, 3.0, -1, 49, 0, 0, 0, 0)
      end
    
      Citizen.Wait(1)
    end

  else

    TriggerEvent("destroyPropPhone")
    local intrunk = exports["isPed"]:isPed("intrunk")
    if not intrunk then
      ClearPedTasks(GetPlayerPed(-1))
    end
  end
end)

RegisterNetEvent('phone:reply')
AddEventHandler('phone:reply', function(message)
  if lastnumber ~= 0 then
    TriggerServerEvent('phone:sendSMS', lastnumber, message)
    TriggerEvent("chatMessage", "You", 6, message)
  else
    phoneMsg("No user has recently SMS'd you.")
  end
end)



function phoneMsg(inputText)
  TriggerEvent("chatMessage", "Service ", 5, inputText)
end



RegisterNetEvent('phone:deleteSMS')
AddEventHandler('phone:deleteSMS', function(id)
  table.remove( lstMsgs, tablefindKeyVal(lstMsgs, 'id', tonumber(id)))
  phoneMsg("Message Removed!")
end)

function getContactName(number)

  if (#lstContacts ~= 0) then
    for k,v in pairs(lstContacts) do
      if v ~= nil then
        if (v.number ~= nil and tonumber(v.number) == tonumber(number)) then
          return v.name
        end
      end
    end
  end

  return number
end

-- Contact Events
RegisterNetEvent('phone:loadContacts')
AddEventHandler('phone:loadContacts', function(contacts)

  lstContacts = {}

  if (#contacts ~= 0) then
    for k,v in pairs(contacts) do
      if v ~= nil then
        local contact = {
        }
        if activeNumbersClient['active' .. tonumber(v.number)] then
        
          contact = {
            name = v.name,
            number = v.number,
            activated = 1
          }
        else
    
          contact = {
            name = v.name,
            number = v.number,
            activated = 0
          }
        end
        table.insert(lstContacts, contact)

        SendNUIMessage({
          newContact = true,
          contact = contact,
        })
      end
    end
  else
       SendNUIMessage({
        emptyContacts = true
      })
  end
end)

RegisterNetEvent('phone:addContact')
AddEventHandler('phone:addContact', function(name, number)
  if(name ~= nil and number ~= nil) then
    number = tonumber(number)
    TriggerServerEvent('phone:addContact', name, number)
  else
     phoneMsg("You must fill in a name and number!")
  end
end)

RegisterNetEvent('phone:newContact')
AddEventHandler('phone:newContact', function(name, number)
  local contact = {
      name = name,
      number = number
  }
  table.insert(lstContacts, contact)

  SendNUIMessage({
    newContact = true,
    contact = contact,
  })
  phoneMsg("Contact Saved!")
  TriggerServerEvent('phone:getContacts')
end)

RegisterNetEvent('phone:deleteContact')
AddEventHandler('phone:deleteContact', function(name, number)

  local contact = {
      name = name,
      number = number
  }

  table.remove( lstContacts, tablefind(lstContacts, contact))
  
  SendNUIMessage({
    removeContact = true,
    contact = contact,
  })
  
end)

function tablefind(tab,el)
  for index, value in pairs(tab) do
    if value == el then
      return index
    end
  end
end

function tablefindKeyVal(tab,key,val)
  for index, value in pairs(tab) do
    if value ~= nil  and value[key] ~= nil and value[key] == val then
      return index
    end
  end
end


RegisterNetEvent('resetPhone')
AddEventHandler('resetPhone', function()
  hasOpened = false
     SendNUIMessage({
      emptyContacts = true
    })

end)

Citizen.CreateThread( function()
    Citizen.Wait(10000)
    NetworkClearVoiceChannel()
    Citizen.Wait(1000)
    NetworkSetTalkerProximity(18.0)
end)

