f_SimShaker = {
  Start = function(self)
    package.path = package.path .. ";.\\LuaSocket\\?.lua"
    package.cpath = package.cpath .. ";.\\LuaSocket\\?.dll"
    socket = require("socket")
    local connect_init =
      socket.protect(
      function()
        --host = "127.0.0.1"
        --port1=29375
        connect_1 = socket.try(socket.udp())
        socket.try(connect_1:settimeout(.001))
        socket.try(connect_1:setoption('broadcast', true))
        socket.try(connect_1:setpeername("127.255.255.255", 29375))
        socket.try(connect_1:send("Go flight."))
        lastTime = 0
      end
    )
    connect_init()
    -- log_file = io.open(lfs.writedir().."/Logs/Export.log", "w")
    -- log_file:write("DEBUT EXPORT\n")
  end,
  AfterNextFrame = function(self)
    local data_send =
      socket.protect(
      function()
        if connect_1 then
          
          local t = LoGetModelTime()

          -- 15 FPS = 0.067
          if (t - lastTime <  0.067) then
            -- do not send stuff
            return
          end  
          lastTime = t

          local dataTable = {}

          local obj = LoGetSelfData()

          if obj == nil then return end
          
          dataTable.name = obj.Name

          dataTable.modelTime = string.format("%.2f", t)
          local altAsl = LoGetAltitudeAboveSeaLevel()
          dataTable.asl = string.format("%.2f", altAsl)
          local altAgl = LoGetAltitudeAboveGroundLevel()
          dataTable.agl = string.format("%.2f", altAgl)
          local pitch, bank, yaw = LoGetADIPitchBankYaw()
          dataTable.pitch = string.format("%.2f", pitch)
          dataTable.bank = string.format("%.2f", bank)
          dataTable.yaw = string.format("%.2f", yaw)
          local aoa = LoGetAngleOfAttack()
          if aoa == nil then
            dataTable.aoa = 0
          else
            dataTable.aoa = string.format("%.2f", aoa)
          end
          local acceleration = LoGetAccelerationUnits()
          local AccelerationUnits = "0.00~0.00~0.00"
          local IAS = LoGetIndicatedAirSpeed() -- m/s
          if IAS == nil then
            dataTable.ias = 0
          else
            dataTable.ias = string.format("%.2f", IAS)
          end
          
          local M_number = LoGetMachNumber()
          if M_number == nil then
            dataTable.machNumber = 0
          else
            dataTable.machNumber = string.format("%.2f", M_number)
          end

          if acceleration then
            AccelerationUnits = string.format("%.2f~%.2f~%.2f", acceleration.x, acceleration.y, acceleration.z)
          end

          dataTable.acceleration = AccelerationUnits

          
          local myselfData

          if obj then
            myselfData = string.format("%.2f~%.2f~%.2f", obj.Heading, obj.Pitch, obj.Bank)
          end

          dataTable.myselfData = myselfData

          local vectorVel = LoGetVectorVelocity()
          if type(vectorVel) == "function" then
            do
              return
            end
          end

          local velocityVectors = string.format("%.2f~%.2f~%.2f", vectorVel.x, vectorVel.y, vectorVel.z)
          dataTable.velocityVectors = velocityVectors
          local windVelocityVectors =
            string.format(
            "%.2f~%.2f~%.2f",
            LoGetVectorWindVelocity().x,
            LoGetVectorWindVelocity().y,
            LoGetVectorWindVelocity().z
          )
          dataTable.windVelocityVectors = windVelocityVectors

          local tas = LoGetTrueAirSpeed()
          if tas == nil then
            dataTable.tas = 0
          else
            dataTable.tas = string.format("%.2f", tas)
          end

          local CM = LoGetSnares()
          if CM == nil then
            dataTable.flare = 0
            dataTable.chaff = 0
          else
            dataTable.flare = CM.flare
            dataTable.chaff = CM.chaff
          end

          local MainPanel = GetDevice(0)

          if MainPanel ~= nil then
            MainPanel:update_arguments()
          end

          local engine = LoGetEngineInfo()
          -- dataTable.engineInfo = engine

          local CannonShells = 0
          local PayloadInfo = "empty"
          if LoGetPayloadInfo() ~= nil then
            CannonShells = LoGetPayloadInfo().Cannon.shells

            local stations = LoGetPayloadInfo().Stations
            local temparray = {}

            for i_st, st in pairs(stations) do
              temparray[#temparray + 1] =
                string.format(
                "%d%d%d%d*%d",
                st.weapon.level1,
                st.weapon.level2,
                st.weapon.level3,
                st.weapon.level4,
                st.count
              )
              PayloadInfo = table.concat(temparray, "~")
            end
          end

          dataTable.cannonShells = CannonShells  
          dataTable.payload = PayloadInfo

          -------------------------------------------------------------------------------------------------------------------------------------------------------
          if obj.Name == "Mi-8MT" then
            -------------------------------------------------------------------------------------------------------------------------------------------------------
            local mainRotorRPM = MainPanel:get_argument_value(42) * 100
            local IAS_L = MainPanel:get_argument_value(24)

            local PanelShake =
              string.format(
              "%.2f~%.2f~%.2f",
              MainPanel:get_argument_value(264),
              MainPanel:get_argument_value(265),
              MainPanel:get_argument_value(282)
            )

            dataTable.rpm = string.format("%.2f", mainRotorRPM)
            dataTable.panelShake = PanelShake
          elseif obj.Name == "UH-1H" then
            -------------------------------------------------------------------------------------------------------------------------------------------------------
            local mainRotorRPM = MainPanel:get_argument_value(123) * 100
            local PanelShake =
              string.format(
              "%.2f~%.2f~%.2f",
              MainPanel:get_argument_value(264),
              MainPanel:get_argument_value(265),
              MainPanel:get_argument_value(282)
            )
            local leftDoor = MainPanel:get_argument_value(420)
            local rightDoor = MainPanel:get_argument_value(422)
            --local doors = string.format("%.2f~%.2f", MainPanel:get_argument_value(420), MainPanel:get_argument_value(422))
            local deadPilot = MainPanel:get_argument_value(248)

            dataTable.rpm = string.format("%.2f", mainRotorRPM)
            dataTable.panelShake = PanelShake
            dataTable.deadPilot = deadPilot
            dataTable.leftDoor = leftDoor
            dataTable.rightDoor = rightDoor
          elseif obj.Name == "Ka-50" or obj.Name == "Ka-50_3" then
            -------------------------------------------------------------------------------------------------------------------------------------------------------
            local mainRotorRPM = MainPanel:get_argument_value(52) * 100

            local GunTrigger = MainPanel:get_argument_value(615)
            local APUoilP = MainPanel:get_argument_value(168)
            local APUvalve = MainPanel:get_argument_value(162)
            local APU = string.format("%.1f~%.1f", APUvalve, APUoilP)

            dataTable.rpm = string.format("%.2f", mainRotorRPM)
            dataTable.apu = APU
            dataTable.cannonShells = string.format("%s~%.3f", dataTable.cannonShells, GunTrigger)
          elseif
            obj.Name == "SA342M" or obj.Name == "SA342L" or obj.Name == "SA342Mistral" or obj.Name == "SA342Minigun"
           then -- Gazelle
            -------------------------------------------------------------------------------------------------------------------------------------------------------
            -------------------------------------------------------------------------------------------------------------------------------------------------------
            local mainRotorRPM = MainPanel:get_argument_value(52) * 100
            local RAltimeterMeter = MainPanel:get_argument_value(94) * 1000
            local RAltimeterOnOff = MainPanel:get_argument_value(91)
            local RAltimeterFlagPanne = MainPanel:get_argument_value(98)
            local RAltimeterFlagMA = MainPanel:get_argument_value(999)
            local RAltimeterTest = MainPanel:get_argument_value(100)
            local StatusString =
              RAltimeterOnOff .. "~" .. RAltimeterFlagPanne .. "~" .. RAltimeterFlagMA .. "~" .. RAltimeterTest

            dataTable.rpm = mainRotorRPM
            dataTable.radarAltimeter = string.format("%.2f", RAltimeterMeter)
            dataTable.sa342SatusString = StatusString
          elseif obj.Name == "P-51D" or obj.Name == "P-51D-30-NA" or obj.Name == "TF-51D" then
            local PanelShake =
              string.format(
              "%.2f~%.2f~%.2f",
              MainPanel:get_argument_value(181),
              MainPanel:get_argument_value(180),
              MainPanel:get_argument_value(189)
            )
            local Manifold_Pressure = MainPanel:get_argument_value(10) * 65 + 10
            local WEPwire = MainPanel:get_argument_value(190)

            local Engine_RPM = MainPanel:get_argument_value(23) * 4500

            dataTable.manifoldPressure = string.format("%.2f~%.2f", Manifold_Pressure, WEPwire)
            dataTable.panelShake = PanelShake
            dataTable.rpm = Engine_RPM
          elseif obj.Name == "FW-190D9" then
            -------------------------------------------------------------------------------------------------------------------------------------------------------
            local Manifold_Pressure = MainPanel:get_argument_value(46)
            local Engine_RPM = MainPanel:get_argument_value(47)

            local PanelShake =
              string.format(
              "%.2f~%.2f~%.2f",
              MainPanel:get_argument_value(205),
              MainPanel:get_argument_value(204),
              MainPanel:get_argument_value(206)
            )
            local GunFireData =
              string.format(
              "%.2f~%.2f~%.2f~%.2f",
              MainPanel:get_argument_value(50),
              MainPanel:get_argument_value(164),
              MainPanel:get_argument_value(165),
              MainPanel:get_argument_value(166)
            )
            local MW = MainPanel:get_argument_value(106)

            dataTable.manifoldPressure = string.format("%.2f~%.2f", Manifold_Pressure, MW)
            dataTable.cannonShells = GunFireData
            dataTable.panelShake = PanelShake
            dataTable.rpm = Engine_RPM
          elseif obj.Name == "FW-190A8" then
            -------------------------------------------------------------------------------------------------------------------------------------------------------
            local Manifold_Pressure = MainPanel:get_argument_value(46)
            local Engine_RPM = MainPanel:get_argument_value(47)

            local PanelShake =
              string.format(
              "%.2f~%.2f~%.2f",
              MainPanel:get_argument_value(205),
              MainPanel:get_argument_value(204),
              MainPanel:get_argument_value(206)
            )
            local GunFireData =
              string.format(
              "%.2f~%.2f~%.2f~%.2f~%.2f~%.2f",
              MainPanel:get_argument_value(164),
              MainPanel:get_argument_value(165),
              MainPanel:get_argument_value(50),
              MainPanel:get_argument_value(53),
              MainPanel:get_argument_value(56),
              MainPanel:get_argument_value(59)
            )
            local MW = MainPanel:get_argument_value(106)

            dataTable.manifoldPressure = string.format("%.2f~%.2f", Manifold_Pressure, MW)
            dataTable.panelShake = PanelShake
            dataTable.cannonShells = GunFireData
            dataTable.rpm = Engine_RPM
          elseif obj.Name == "Bf-109K-4" then
            -------------------------------------------------------------------------------------------------------------------------------------------------------
            local Manifold_Pressure = MainPanel:get_argument_value(32)
            local Engine_RPM = MainPanel:get_argument_value(29)

            local myselfData = string.format("%.2f~%.2f~%.2f", obj.Heading, obj.Pitch, obj.Bank)
            local PanelShake =
              string.format(
              "%.2f~%.2f~%.2f",
              MainPanel:get_argument_value(146),
              MainPanel:get_argument_value(147),
              MainPanel:get_argument_value(1489)
            )
            local MW = MainPanel:get_argument_value(1)

            dataTable.manifoldPressure = string.format("%.2f~%.2f", Manifold_Pressure, MW)
            dataTable.rpm = string.format("%.2f", Engine_RPM)
            dataTable.panelShake = PanelShake
          elseif obj.Name == "SpitfireLFMkIX" or obj.Name == "SpitfireLFMkIXCW" then
            -------------------------------------------------------------------------------------------------------------------------------------------------------
            local Engine_RPM = MainPanel:get_argument_value(37)
            local PanelShake =
              string.format(
              "%.2f~%.2f~%.2f",
              MainPanel:get_argument_value(144),
              MainPanel:get_argument_value(143),
              MainPanel:get_argument_value(142)
            )
            dataTable.panelShake = PanelShake
            dataTable.rpm = string.format("%.2f", Engine_RPM)
            dataTable.manifoldPressure = string.format("%.2f~%.2f", 0, 0)
          elseif obj.Name == "F-86F Sabre" then
            ------------------------------------------------------------------------------------------------------------------------
            local Engine_RPM = MainPanel:get_argument_value(16) * 100
            dataTable.rpm = string.format("%.2f", Engine_RPM)
          elseif obj.Name == "A-10C" or obj.name == "A-10C_2" then
            -------------------------------------------------------------------------------------------------------------------------------------------------------
            local AoAunits = MainPanel:get_argument_value(4) * 30
            local FlapsPos = MainPanel:get_argument_value(653)
            local Canopy = MainPanel:get_argument_value(7)
            --local Engine_RPM_left = string.format("%.0f", MainPanel:get_argument_value(78) * 100)
            --local Engine_RPM_right = string.format("%.0f", MainPanel:get_argument_value(80) * 100)
            local APU = MainPanel:get_argument_value(13)

            dataTable.dcsCanopy = string.format("%.2f", Canopy)
            dataTable.dcsAPU = string.format("%.2f", APU)
            --dataTable.rpm = Engine_RPM_left .. "~" .. Engine_RPM_right
          elseif obj.Name == "MiG-21Bis" then
            -------------------------------------------------------------------------------------------------------------------------------------------------------
            local Voltmeter = MainPanel:get_argument_value(124) * 30

            local AirBrake3d = MainPanel:get_argument_value(7)
            local Flaps3d = MainPanel:get_argument_value(910)
            local Afterburner1 = MainPanel:get_argument_value(507)
            local Afterburner2 = MainPanel:get_argument_value(508)
            local LampCheck = MainPanel:get_argument_value(407)
            local AB12 = string.format("%.1f~%.1f~%.1f", Afterburner1, Afterburner2, LampCheck)
            local SPS = MainPanel:get_argument_value(624)
            local CanopyWarnLight = MainPanel:get_argument_value(541)

            dataTable.dcsCanopy = string.format("%.2f", CanopyWarnLight)
            dataTable.sps = string.format("%.2f", SPS)
          elseif obj.Name == "MiG-15bis" then
            -------------------------------------------------------------------------------------------------------------------------------------------------------
            local VoltAmperMeter = MainPanel:get_argument_value(83) * 30
            local GenOff = MainPanel:get_argument_value(57)
            local TestBtn = MainPanel:get_argument_value(72) -- not presented in mainpanel_init.lua

            local Engine_RPM = string.format("%.0f", MainPanel:get_argument_value(42) * 100)
            local SpeedBrakeLamp = MainPanel:get_argument_value(124)
            local Canopy = MainPanel:get_argument_value(225)

            dataTable.dcsCanopy = string.format("%.2f", Canopy)
            dataTable.rpm = Engine_RPM
          elseif obj.Name == "L-39C" or obj.Name == "L-39ZA" then
            -------------------------------------------------------------------------------------------------------------------------------------------------------
            local TestBtn = MainPanel:get_argument_value(203) -- not presented in mainpanel_init.lua
            local TestBtn2 = MainPanel:get_argument_value(538) -- not presented inmainpanel_init.lua

            local Canopy1 = MainPanel:get_argument_value(139)
            local Canopy2 = MainPanel:get_argument_value(140)

            dataTable.dcsCanopy = string.format("%.2f", Canopy1)
            dataTable.dcsCanopy2 = string.format("%.2f", Canopy2)

            local Engine_RPM = string.format("%.0f", MainPanel:get_argument_value(84) * 100)
            dataTable.rpm = Engine_RPM
          elseif obj.Name == "M-2000C" then
            -------------------------------------------------------------------------------------------------------------------------------------------------------
            local PanelShake =
              string.format(
              "%.2f~%.2f~%.2f",
              MainPanel:get_argument_value(181),
              MainPanel:get_argument_value(180),
              MainPanel:get_argument_value(189)
            )

            dataTable.panelShake = PanelShake
          elseif obj.Name == "F-5E" or obj.Name == "F-5E-3" then
            -------------------------------------------------------------------------------------------------------------------------------------------------------
            local Engine_RPM_left = MainPanel:get_argument_value(16) * 100
            local Engine_RPM_right = MainPanel:get_argument_value(17) * 100

            dataTable.rpm = string.format("%.2f~%.2f", Engine_RPM_left, Engine_RPM_right)
          elseif obj.Name == "AJS37" then
            -------------------------------------------------------------------------------------------------------------------------------------------------------
          elseif obj.Name == "FA-18C_hornet" then
            -------------------------------------------------------------------------------------------------------------------------------------------------------
            -- let's try some dcs bios magic
            local li = parse_indication(5)
            if RPM == nil then
              RPM = "0~0"
            end

            if RPM == "~" then
              RPM = "0~0"
            end

            if li then
              local LEngine_RPM = check(li.txt_RPM_L)
              local REngine_RPM = check(li.txt_RPM_R)
              if (string.len(LEngine_RPM) >= 1) and (string.len(REngine_RPM) >= 1) then
                RPM = LEngine_RPM .. "~" .. REngine_RPM
              end
            end

            dataTable.rpm = RPM
          elseif string.find(obj.Name, "F-14") then
            -------------------------------------------------------------------------------------------------------------------------------------------------------
            local REngine_RPM = "0"
            local LEngine_RPM = "0"
            if getEngineRightRPM then
              REngine_RPM = sensor_data.getEngineRightRPM()
            end
            if getEngineLeftRPM then
              LEngine_RPM = sensor_data.getEngineLeftRPM()
            end

            local RPM = REngine_RPM .. "~" .. LEngine_RPM

            if f14 == nil or f14 == false then
              setupF14Export()
            end
            if f14 == true then
              -- log.info("additionalData:"..additionalData)
              -- usual case after first time
              additionalData = ""
              local epoxy = GetDevice(6)
              if epoxy ~= nil and type(epoxy) ~= "number" and f14_i2n ~= nil then
                local values = epoxy:get_values()
                for i, v in ipairs(values) do
                  f14_variables[f14_i2n[i]] = v
                  additionalData = additionalData .. f14_i2n[i] .. "=" .. v .. ";"
                end
              end
            else
              additionalData = "" -- prevent nil error in string.format below at least
            end
          
          dataTable.additionalData = additionalData

          elseif obj.Name == "Mi-24P" then

          elseif obj.Name == "A-4E-C" then

          elseif obj.Name == "MosquitoFBMkVI" then

          elseif obj.Name == "AH-64D_BLK_II" then
            dataTable.rpm = string.format("%.0f~%.0f", LoGetEngineInfo().RPM.left, LoGetEngineInfo().RPM.right)
            dataTable.panelShake = string.format( "%.2f~%.2f~%.2f~%.2f~%.2f",
              MainPanel:get_argument_value(820),
              MainPanel:get_argument_value(821),
              MainPanel:get_argument_value(822),
              MainPanel:get_argument_value(823),
              MainPanel:get_argument_value(824)
            )

          elseif obj.Name == "Mirage-F1CE" or obj.Name == "Mirage-F1EE" then
            dataTable.rpm = string.format("%.0f~%.0f", LoGetEngineInfo().RPM.left, LoGetEngineInfo().RPM.right)

          elseif obj.Name == "MB-339" or obj.Name == "MB-339A" or obj.Name == "MB-339APAN" then

          --- FC3 Airplanes
          elseif obj.Name == "MiG-29A" or obj.Name == "MiG-29G" or obj.Name == "MiG-29S" or obj.Name == "Su-25" or obj.Name == "Su-25T" or obj.Name == "Su-27" or obj.Name == "Su-33" or obj.Name == "F-15C" or obj.Name == "A-10A"  or obj.Name == "J-11A" then
          
            local engine = LoGetEngineInfo()

            local LandingGearState = LoGetMechInfo().gear.value
            local SpeedBrakePos = LoGetMechInfo().speedbrakes.value
            local CanopyPos = LoGetMechInfo().canopy.value
            local FlapsPos = LoGetMechInfo().flaps.value
            local WingsPos = LoGetMechInfo().wing.value
            local DragChuteState = LoGetMechInfo().parachute.value
            local MechState = string.format("%.2f-%.2f", DragChuteState, 100 * LoGetMechInfo().gear.value)
            local MCP = LoGetMCPState()

            local engineRPM = string.format("%.0f~%.0f", LoGetEngineInfo().RPM.left, LoGetEngineInfo().RPM.right)
            local MCPState =
              tostring(MCP.LeftEngineFailure) .. "~" .. tostring(MCP.RightEngineFailure) .. "~" .. tostring(MCP.HydraulicsFailure) ..
                      "~" .. tostring(MCP.ACSFailure) .. "~" .. tostring(MCP.AutopilotFailure) .. "~" .. tostring(MCP.MasterWarning) ..
                      "~" .. tostring(MCP.LeftTailPlaneFailure) .. "~" .. tostring(MCP.RightTailPlaneFailure) .. "~" .. tostring(MCP.LeftAileronFailure) ..
                      "~" .. tostring(MCP.RightAileronFailure) .. "~" .. tostring(MCP.CannonFailure) .. "~" .. tostring(MCP.StallSignalization) ..
                      "~" .. tostring(MCP.LeftMainPumpFailure) .. "~" .. tostring(MCP.RightMainPumpFailure) .. "~" .. tostring(MCP.LeftWingPumpFailure) ..
                      "~" .. tostring(MCP.RightWingPumpFailure) .. "~" .. tostring(MCP.RadarFailure) .. "~" .. tostring(MCP.EOSFailure) ..
                      "~" .. tostring(MCP.MLWSFailure) .. "~" .. tostring(MCP.RWSFailure) .. "~" .. tostring(MCP.ECMFailure) ..
                      "~" .. tostring(MCP.GearFailure) .. "~" .. tostring(MCP.MFDFailure) .. "~" ..tostring(MCP.HUDFailure) ..
                      "~" .. tostring(MCP.HelmetFailure) .. "~" .. tostring(MCP.FuelTankDamage)

            dataTable.mcpState = MCPState
            dataTable.dcsFlaps = FlapsPos
            dataTable.dcsCanopy = CanopyPos
            dataTable.dcsWings = WingsPos
            dataTable.rpm = engineRPM
          end
        
          local result = {}

          for key, value in pairs(dataTable) do
            -- prepare json key-value pairs and save them in separate table
            -- str = string.format("\"%s\":\"%s\"", key, value)
            -- log_file:write(str .. "\n")
            if (type(value) == "table") then
              for key2, value2 in pairs(dataTable) do
                log_file:write(key .. " = ")
                str = string.format("\"%s\":\"%s\"", key2, value2)
                log_file:write(str .. "\n")
                table.insert(result, string.format('"%s":"%s"', key2, value2))
              end
            else
              table.insert(result, string.format('"%s":"%s"', key, value))
            end
          end

          -- get simple json string
          stringToSend = "{" .. table.concat(result, ",") .. "}"

          socket.try(connect_1:send(stringToSend))
        end
      end
    )
    data_send()
  end,
  Stop = function(self)
    local connection_close =
      socket.protect(
      function()
        if connect_1 then
          socket.try(connect_1:send("Good luck, pilot."))
          connect_1:close()
        end
      end
    )
    connection_close()
  end
}

----------------------------------------------------------------------------------------------------
--http://forums.eagle.ru/showpost.php?p=2431726&postcount=5
-- Works before mission start
do
  local SimLuaExportStart = LuaExportStart
  LuaExportStart = function()
    f_SimShaker:Start()
    if SimLuaExportStart then
      SimLuaExportStart()
    end
  end
end

-- Works after every simulation frame
do
  local SimLuaExportAfterNextFrame = LuaExportAfterNextFrame
  LuaExportAfterNextFrame = function()
    f_SimShaker:AfterNextFrame()
    if SimLuaExportAfterNextFrame then
      SimLuaExportAfterNextFrame()
    end
  end
end

-- Works after mission stop
do
  local SimLuaExportStop = LuaExportStop
  LuaExportStop = function()
    f_SimShaker:Stop()
    if SimLuaExportStop then
      SimLuaExportStop()
    end
  end
end

function parse_indication(indicator_id) -- Thanks to [FSF]Ian for this function code
  local ret = {}
  local li = list_indication(indicator_id)
  if li == "" then
    return nil
  end
  local m = li:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
  while true do
    local name, value = m()
    if not name then
      break
    end
    ret[name] = value
  end
  return ret
end

function check(indicator)
  if indicator == nil then
    return " "
  else
    return indicator
  end
end

function setupF14Export()
  local epoxy = GetDevice(6)
  if epoxy then
    -- check functions
    local meta = getmetatable(epoxy)
    f14 = false
    if meta then
      local ind = getmetatable(epoxy)["__index"]
      if ind then
        if ind["get_version"] ~= nil and ind["get_variable_names"] ~= nil and ind["get_values"] ~= nil then
          f14 = true
          --log.info("Found F-14 exports")
          f14_n2i = {}
          f14_i2n = {}
          f14_variables = {}
          names = epoxy:get_variable_names()
          for i, v in ipairs(names) do
            f14_n2i[v] = i
            f14_i2n[i] = v
            --log.debug(tostring(v).."->"..tostring(i))
          end
        end
      end
    end
  end
end
