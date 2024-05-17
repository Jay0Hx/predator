local settings = {
    cl_autoPilot = {                                                        -- ALL VALUES HERE ARE STORED DEFAULTS FOR AI DRIVING!
        cl_apEnabled            = false,                                    -- By default we disable the AI driving feature.
        cl_skill                = 50,                                       -- Default value for how skillfull a driver the AI is.
        cl_aggressiveness       = 50,                                       -- Default value for how aggressive the AI drive.
        cl_topSpeed             = 250,                                      -- Default top speed that AI are allowed to drive.
        cl_grip                 = 5,                                        -- Default value for AI grip.
    }, 
    cl_vehicle = {                                                          -- ALL VALUES HERE ARE STORED DEFAULTS FOR THE 'VEHICLES' MENU!
        cl_optTires             = false,                                    -- By default we want to set this to false.
        cl_damage               = false,                                    -- This is for disabling body and engine damge.
        cl_drs                  = false,                                    -- This will attempt to force DRS in the session.
        cl_power                = 0.0,                                      -- Default to 0 because this is additional power.
        cl_braking              = 0.0,                                      -- Default to 0 because this is additional breaking.
        cl_downforce            = 0.0,                                      -- Default to 0 because this is additional downforce.
        cl_fuel                 = 15,                                       -- Deafult to 15 so the tank isnt empty if we use it.
        cl_freezeFuel           = -1,                                       -- This will freeze how much fuel is in the users car.
        cl_gearLock             = false,                                    -- This is used to lock the gear in the chosen value of the user (Max 10)
        cl_chosenGear           = 1,                                        -- First gear is selected by default.
    },
    cl_experimental = {                                                     -- THIS IS WHERE THE EXPIERIMENTAL FEATURES ARE STORED FOR USE.
        cl_velX                 = 0.1,                                      -- This is the X value for the jumpy tool thing.
        cl_velY                 = 0.1,                                      -- This is the Y value for the jumpy tool thing.
        cl_velZ                 = 0.1,                                      -- This is the Z value for the jumpy tool thing.
    },
}

local cl_driversData = {}
local localCar;

function script.windowMain(dt) 
    ui.tabBar("dt", function()
        ui.tabItem("Leaderboard ("..ac.getSim().connectedCars..")", function()
            for i, cl_data in ipairs(cl_driversData) do
                if cl_data.cl_carData then
                    ui.treeNode(cl_data.cl_driverName, ui.TreeNodeFlags.DefaultOpen and ui.TreeNodeFlags.Framed, function ()
                        ui.text(" • Race position: "..cl_data.cl_driverPosition)
                        ui.text(" • Drivers name: "..cl_data.cl_driverName)
                        ui.text(" • Drivers car: "..cl_data.cl_driversCar)  
                        ui.text(ac.getCar(cl_data.cl_targetSim).position)
                        ui.separator()
                        ui.text("Online player controls:") ui.sameLine()
                        if cl_data.cl_driverName == ac.getDriverName(0) then
                            if ui.button("Cancel spectating") then 
                                ac.focusCar(0) 
                            end 
                        end
                        if cl_data.cl_driverName ~= ac.getDriverName(0) then
                            if ui.button("Spectate") then 
                                ac.focusCar(cl_data.cl_targetSim) 
                            end ui.sameLine()
                            if ui.button("Steal Name") then 
                                physics.setDriverName(ac.getDriverName(cl_data.cl_targetSim).." ", "ENG") 
                            end ui.sameLine()
                            if ui.button("Teleport Too") then 
                                physics.setCarPosition(0, ac.getCar(cl_data.cl_targetSim).position, ac.getCar(cl_data.cl_targetSim).position) 
                            end
                        end
                        if not ac.getSim().isOnlineRace and cl_data.cl_driverName ~= ac.getDriverName(0) then
                            ui.text("AI Controls:") ui.sameLine()
                            if ui.button("Force Jump") then physics.setCarVelocity(cl_data.cl_targetSim, vec3(0, 9, 0)) end ui.sameLine()
                            if ui.button("Launch Up") then physics.setCarVelocity(cl_data.cl_targetSim, vec3(0, 25, 0)) end ui.sameLine()
                            if ui.button("Skid Off Track") then physics.setCarVelocity(cl_data.cl_targetSim, vec3(0, 0, 25)) end ui.sameLine()
                            if ui.button("Make retarded") then
                                physics.setAILevel(i, 0.1)
                                physics.setAIAggression(i, 0)
                            end 
                        end          
                        ui.separator()
                    end)
                end
            end
            table.clear(cl_driversData)
        end)
        ui.tabItem("Vehicle", function()
            ui.treeNode("Gears", ui.TreeNodeFlags.DefaultOpen and ui.TreeNodeFlags.Framed, function ()
                if ui.radioButton("Lock selected gear", settings.cl_vehicle.cl_gearLock) then settings.cl_vehicle.cl_gearLock = not settings.cl_vehicle.cl_gearLock end
                local currentGear, hasGearChanged = ui.slider("     ", settings.cl_vehicle.cl_chosenGear, 0, ac.getCar(0).gearCount, "%.f - Chosen gear")
                if hasGearChanged then 
                    settings.cl_vehicle.cl_chosenGear = currentGear 
                    settings.cl_vehicle.cl_gearLock = false
                end
            end)
            ui.treeNode("Fuel", ui.TreeNodeFlags.DefaultOpen and ui.TreeNodeFlags.Framed, function ()
                if ui.radioButton("Freeze fuel amount", settings.cl_vehicle.cl_freezeFuel >= 0) then settings.cl_vehicle.cl_freezeFuel = settings.cl_vehicle.cl_freezeFuel > 0 and -1 or localCar.fuel end
                local currentFuel, hasFuelChanged = ui.slider("  ", settings.cl_vehicle.cl_fuel, 0, ac.getCar(0).maxFuel, "%.0fkg - Fuel")
                if hasFuelChanged then settings.cl_vehicle.cl_fuel = currentFuel physics.setCarFuel(0, currentFuel) end
            end)
            ui.treeNode("Handling", ui.TreeNodeFlags.DefaultOpen and ui.TreeNodeFlags.Framed, function ()
                if ui.radioButton("Optimal tire temperatures", settings.cl_vehicle.cl_optTires) then settings.cl_vehicle.cl_optTires = not settings.cl_vehicle.cl_optTires end
                if ui.radioButton("Force DRS", settings.cl_vehicle.cl_drs) then
                    settings.cl_vehicle.cl_drs = not settings.cl_vehicle.cl_drs
                    physics.allowCarDRS(1, settings.cl_vehicle.cl_drs)
                end
                local currentDownforce, hasChangedDownforce = ui.slider(" ", settings.cl_vehicle.cl_downforce, 0, 5000, "%.0fkg - Downforce")
                if hasChangedDownforce then settings.cl_vehicle.cl_downforce = currentDownforce end 
                local currentPassive, hasChangedPassive = ui.slider("   ", settings.cl_vehicle.cl_power, 0, 1000, "x%.1f - Power")
                if hasChangedPassive then settings.cl_vehicle.cl_power = currentPassive end
                local currentBrake, hasChangedBrake = ui.slider("    ", settings.cl_vehicle.cl_braking, 0, 1000, "%.1fnm - Braking")
                if hasChangedBrake then settings.cl_vehicle.cl_braking = currentBrake end
            end)
            ui.treeNode("Vehicle relative position manipulator", ui.TreeNodeFlags.DefaultOpen and ui.TreeNodeFlags.Framed, function () 
                local currentX, hasXchanged = ui.slider("   ", settings.cl_experimental.cl_velX, -10, 10, "%.1f - X Axis")
                if hasXchanged then settings.cl_experimental.cl_velX = currentX physics.setCarVelocity(0, vec3(currentX, 0, 0)) end ui.sameLine() ui.sameLine()   
                if ui.button("Reset X") then settings.cl_experimental.cl_velX = 0.0 end          
                local currentY, hasYchanged = ui.slider("   ", settings.cl_experimental.cl_velY, -10, 10, "%.1f - Y Axis")
                if hasYchanged then settings.cl_experimental.cl_velY = currentY physics.setCarVelocity(0, vec3(0, currentY, 0)) end ui.sameLine()
                if ui.button("Reset Y") then settings.cl_experimental.cl_velY = 0.0 end
                local currentZ, hasZchanged = ui.slider("   ", settings.cl_experimental.cl_velZ, -10, 10, "%.1f - Z Axis")
                if hasZchanged then settings.cl_experimental.cl_velZ = currentZ physics.setCarVelocity(0, vec3(0, 0, currentZ)) end ui.sameLine()
                if ui.button("Reset Z") then settings.cl_experimental.cl_velZ = 0.0 end
                if ui.button("Trigger current values") then physics.setCarVelocity(0, vec3(settings.cl_experimental.cl_velX, settings.cl_experimental.cl_velY, settings.cl_experimental.cl_velZ)) end ui.sameLine() ui.text(" | ") ui.sameLine()
                if ui.button("Lil Squat") then physics.setCarVelocity(0, vec3(0, -1.5, 0)) end ui.sameLine()
                if ui.button("Squat") then physics.setCarVelocity(0, vec3(0, -3, 0)) end ui.sameLine()
                if ui.button("Hop") then physics.setCarVelocity(0, vec3(0, 3, 0)) end ui.sameLine()
                if ui.button("Jump") then physics.setCarVelocity(0, vec3(0, 6, 0)) end ui.sameLine()
                if ui.button("Leap") then physics.setCarVelocity(0, vec3(0, 9, 0)) end  ui.separator()
            end)
            ui.text("Other options:")
            if ui.radioButton("Disable body and engine damage", settings.cl_vehicle.cl_damage) then settings.cl_vehicle.cl_damage = not settings.cl_vehicle.cl_damage end   
            ui.separator()
        end)
        ui.tabItem("Auto-pilot", function()     
            if ui.checkbox("Enable 'Auto-Pilot'", settings.cl_autoPilot.cl_apEnabled) then
                settings.cl_autoPilot.cl_apEnabled = not settings.cl_autoPilot.cl_apEnabled
                physics.setCarAutopilot(settings.cl_autoPilot.cl_apEnabled)
            end
            local currentSkill, hasChangedSkill = ui.slider(" ", settings.cl_autoPilot.cl_skill, 0, 100, "Skill - %.0f%% ")
            if hasChangedSkill then
                settings.cl_autoPilot.cl_skill = currentSkill
                physics.setAILevel(0, currentSkill * 1000)
            end
            local currentAggressiveness, hasChangedAggressiveness = ui.slider("  ", settings.cl_autoPilot.cl_aggressiveness, 0, 100, "Aggressiveness - %.0f%%")
            if hasChangedAggressiveness then
                settings.cl_autoPilot.cl_aggressiveness = currentAggressiveness
                physics.setAIAggression(0, currentAggressiveness)
            end
            local currentAiGrip, hasAIGripChanged = ui.slider("   ", settings.cl_autoPilot.cl_grip, 0, 100, "Grip - x%.0f%%")
            if hasAIGripChanged then
                settings.cl_autoPilot.cl_grip = currentAiGrip
                physics.setExtraAIGrip(0, settings.cl_autoPilot.cl_grip / 4.5)         
            end
            local currentTop, hasTopChanged = ui.slider("    ", settings.cl_autoPilot.cl_topSpeed, 0, 1000, "Allowed top speed - %.0f%kmh")
            if hasTopChanged then settings.cl_autoPilot.cl_topSpeed = currentTop end
            ui.text("Know bugs with the 'Auto-Pilot' menu.")
            ui.text("• Too much grip will make you fly off the track (Can be countered with downforce).")
        end)

        ui.tabItem("r-pilot", function()  
            ui.text(ac.getCar(0).position)
        end)
    end)
end

function script.update(dt)
    localCar = ac.getCar(0)
    if settings.cl_vehicle.cl_downforce > 0 then physics.addForce(0, vec3(0, 0, 0), true, vec3(0, -settings.cl_vehicle.cl_downforce * 9.8 * dt * 100, 0), true) end
    if settings.cl_vehicle.cl_optTires then local temp = ac.getCar(0).wheels[0].tyreOptimumTemperature physics.setTyresTemperature(0, ac.Wheel.All, temp) end
    if settings.cl_vehicle.cl_damage then physics.setCarBodyDamage(0, vec4(0, 0, 0, 0)) physics.setCarEngineLife(0, 1000) end
    if settings.cl_autoPilot.cl_topSpeed then physics.setAITopSpeed(0, settings.cl_autoPilot.cl_topSpeed) end
    if settings.cl_vehicle.cl_freezeFuel >= 0 then physics.setCarFuel(0, settings.cl_vehicle.cl_fuel) end
    if settings.cl_vehicle.cl_gearLock then physics.engageGear(0, settings.cl_vehicle.cl_chosenGear) end
    if settings.cl_vehicle.cl_power > 0 and (localCar.gear > 0) and (localCar.rpm + 200 < localCar.rpmLimiter) then
        local passivePush = settings.cl_vehicle.cl_power * localCar.mass * localCar.gas * dt * 100     
        physics.addForce(0, vec3(0, 0, 0), true, vec3(0, 0, passivePush), true)
    end
    if settings.cl_vehicle.cl_braking > 0 and (localCar.speedKmh > 5) then
        local passivePush = settings.cl_vehicle.cl_braking * localCar.mass * localCar.brake * dt * 100
        passivePush = localCar.localVelocity.z > 0.0 and -passivePush or passivePush     
        physics.addForce(0, vec3(0, 0, 0), true, vec3(0, 0, passivePush), true)
    end
    for i = 0, ac.getSim().carsCount - 1 do
        if ac.getDriverName(i) ~= "" then
            table.insert(
                cl_driversData, {
                    cl_targetSim = i,
                    cl_driverName = ac.getDriverName(i),
                    cl_driverPosition = ac.getCar(i).racePosition,
                    cl_driversCar = ac.getCarName(i),
                    cl_carData = ac.getCar(i).isConnected,              
                }
            )
        end   
    end
end
