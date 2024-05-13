local settings = {
    cl_information = {                                                      -- THIS INFORMATION IS WHAT WE HAVE STORED FOR USE IN THE INFORMATION PAGE.
        cl_discord              = "https://discord.gg/AK6YmRNBcV",          -- Discord link that we hyperlink
        cl_author               = "CodeLoom | J I N X & itsluiz",           -- Author information with creds too DLL creator.
        cl_name                 = "Predator",                               -- Project name.
        cl_version              = "v0.2(A)",                                -- Version name.
    },
    cl_autoPilot = {                                                        -- ALL VALUES HERE ARE STORED DEFAULTS FOR AI DRIVING!
        cl_apEnabled            = false,                                    -- By default we disable the AI driving feature.
        cl_throttleLim          = nil,                                      -- DONT KNOW YET.
        cl_steerMulti           = nil,                                      -- DONT KNOW YET.
        cl_skill                = 50,                                       -- Default value for how skillfull a driver the AI is.
        cl_aggressiveness       = 50,                                       -- Default value for how aggressive the AI drive.
        cl_topSpeed             = 250,                                      -- Default top speed that AI are allowed to drive.
        cl_grip                 = 5,                                        -- Default value for AI grip.
    }, 
    cl_vehicle = {                                                          -- ALL VALUES HERE ARE STORED DEFAULTS FOR THE 'VEHICLES' MENU!
        cl_optTires             = false,                                    -- By default we want to set this to false.
        cl_damage               = false,                                    -- This is for disabling body and engine damge.
        cl_antiRam              = false,                                    -- This is basically no clip but REALLY bad.
        cl_drs                  = false,                                    -- This will attempt to force DRS in the session.
        cl_power                = 0.0,                                      -- Default to 0 because this is additional power.
        cl_braking              = 0.0,                                      -- Default to 0 because this is additional breaking.
        cl_downforce            = 0.0,                                      -- Default to 0 because this is additional downforce.
        cl_fuel                 = 15,                                       -- Deafult to 15 so the tank isnt empty if we use it.
        cl_freezeFuel           = -1,                                       -- This will freeze how much fuel is in the users car.
    },
    cl_experimental = {                                                     -- THIS IS WHERE THE EXPIERIMENTAL FEATURES ARE STORED FOR USE.
        cl_velX                 = 0.0,                                      -- This is the X value for the jumpy tool thing.
        cl_velY                 = 0.0,                                      -- This is the Y value for the jumpy tool thing.
        cl_velZ                 = 0.0,                                      -- This is the Z value for the jumpy tool thing.
    },
}

local localCar;

function script.windowMain(cl_predator) 
    ui.tabBar("cl_predator", function()
        ui.tabItem("Information", function()
            ui.separator()
            ui.text("Join the discord:") ui.sameLine() ui.copyable(settings.cl_information.cl_discord)  -- Discord plug!    
            ui.text("Created by:") ui.sameLine() ui.text(settings.cl_information.cl_author)             -- Author credits.          
            ui.text("Join the discord:") ui.sameLine() ui.text(settings.cl_information.cl_name)         -- Software name.      
            ui.text("Join the discord:") ui.sameLine() ui.text(settings.cl_information.cl_version)      -- Version number.
            ui.separator()  
        end)

        ui.tabItem("Drivers: "..ac.getSim().connectedCars, function()
            ui.separator()
            ui.text('• You must SPECTATE the target before you can teleport to them!')
            ui.text('• Teleportation is dependent on camera angle. (First person TPs inside the target)')
            ui.text('• AI Controls only works on SINGLE PLAYER AI dont try on live servers!')
            ui.separator()
            for i = 0, ac.getSim().carsCount - 1 do
                if ac.getDriverName(i) ~= "" then
                    ui.treeNode(ac.getDriverName(i), ui.TreeNodeFlags.DefaultOpen and ui.TreeNodeFlags.Framed, function ()
                        ui.separator()
                        ui.text("Driver information: ")
                        ui.text("Position: "..ac.getCar(i).racePosition)
                        ui.text("Display Name: "..ac.getDriverName(i))
                        ui.text("Car Name: "..ac.getCarName(i))
                        ui.separator()
                        ui.text("Player Controls:")ui.sameLine()
                        if ui.button("Spectate") then ac.focusCar(i) end ui.sameLine()
                        if ui.button("Teleport Too") then physics.setCarPosition(0, ac.getCameraPosition(), ac.getCameraDirection()) end ui.sameLine()
                        if ui.button("Steal Name") then physics.setDriverName(ac.getDriverName(i).." ", "eng") end ui.separator()
                        ui.text("AI Controls:") ui.sameLine()
                        if ui.button("Force Jump") then physics.setCarVelocity(i, vec3(0, 9, 0)) end ui.sameLine()
                        if ui.button("Launch Up") then physics.setCarVelocity(i, vec3(0, 25, 0)) end ui.sameLine()
                        if ui.button("Skid Off Track") then physics.setCarVelocity(i, vec3(0, 0, 25)) end ui.separator()
                    end)
                end
            end
            ui.text("Know bugs with the 'Drivers' menu.")
            ui.text("• When people leave, their name will not dissapear.") -- Potentially move all drivers stuff to a contantly updating thread? (LAGGY?)
            ui.text("• Teleport only works when spectating the taget.")
            ui.text("• Stealing name will not steal drivers nation code.")
        end)

        ui.tabItem("Vehicle", function()
            ui.separator()
            if ui.radioButton("Optimal tire temperatures", settings.cl_vehicle.cl_optTires) then settings.cl_vehicle.cl_optTires = not settings.cl_vehicle.cl_optTires end
            if ui.radioButton("Disable body and engine damage", settings.cl_vehicle.cl_damage) then settings.cl_vehicle.cl_damage = not settings.cl_vehicle.cl_damage end
            if ui.radioButton("Freeze fuel amount", settings.cl_vehicle.cl_freezeFuel >= 0) then settings.cl_vehicle.cl_freezeFuel = settings.cl_vehicle.cl_freezeFuel > 0 and -1 or localCar.fuel end
            if ui.radioButton("Counter rammers | This will make it hard for people to ram you off the road!", settings.cl_vehicle.cl_antiRam) then
                settings.cl_vehicle.cl_antiRam = not settings.cl_vehicle.cl_antiRam
                physics.setCarCollisions(0, settings.cl_vehicle.cl_antiRam)
            end
            if ui.radioButton("Attempt to force DRS usage.", settings.cl_vehicle.cl_drs) then
                settings.cl_vehicle.cl_drs = not settings.cl_vehicle.cl_drs
                physics.allowCarDRS(1, settings.cl_vehicle.cl_drs)
            end ui.separator()
            local currentDownforce, hasChangedDownforce = ui.slider(" ", settings.cl_vehicle.cl_downforce, 0, 5000, "%.0fkg - Downforce")
            if hasChangedDownforce then settings.cl_vehicle.cl_downforce = currentDownforce end 
            local currentPassive, hasChangedPassive = ui.slider("   ", settings.cl_vehicle.cl_power, 0, 1000, "x%.1f - Power")
            if hasChangedPassive then settings.cl_vehicle.cl_power = currentPassive end
            local currentFuel, hasFuelChanged = ui.slider("  ", settings.cl_vehicle.cl_fuel, 0, 150, "%.0fkg - Fuel")
            if hasFuelChanged then settings.cl_vehicle.cl_fuel = currentFuel physics.setCarFuel(0, currentFuel) end
            local currentBrake, hasChangedBrake = ui.slider("    ", settings.cl_vehicle.cl_braking, 0, 1000, "%.1fnm - Braking")
            if hasChangedBrake then settings.cl_vehicle.cl_braking = currentBrake end
            ui.separator() ui.text("Vehicle relative position manipulation:")           
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
            ui.text("Know bugs with the 'Vehicle' menu.")
            ui.text("• Trigger current values wont work unless all bars have a value.")
            ui.text("• Counter rammers is a bit tempremental.")
            ui.text("• Fuel slider won't work unless fuel is NOT frozen.")
            ui.text("• Fuel slider is not specific to car.")
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
                physics.setExtraAIGrip(0, settings.cl_autoPilot.cl_grip / 5)         
            end
            local currentTop, hasTopChanged = ui.slider("    ", settings.cl_autoPilot.cl_topSpeed, 0, 1000, "Allowed top speed - %.0f%mph")
            if hasTopChanged then
                settings.cl_autoPilot.cl_topSpeed = currentTop
                physics.setAITopSpeed(0, settings.cl_autoPilot.cl_topSpeed)        
            end
            ui.text("Know bugs with the 'Auto-Pilot' menu.")
            ui.text("• Too much grip will make you fly off the track (Can be countered with downforce).")
            ui.text("• Allowed speed seems to being ignored in 90% of use cases.")
        end)

        ui.tabItem("Experimental", function()
            local carOffset = ac.getCar(0)                                      -- Car offset
            local wheelsOffset = ac.getCar(0).wheels[0]                         -- Wheels offset
            ui.text(wheelsOffset)
            ui.text(carOffset)
        end)

    end)
end

function script.update(cl_predator)
    localCar = ac.getCar(0)
    if settings.cl_vehicle.cl_optTires then local temp = ac.getCar(0).wheels[0].tyreOptimumTemperature physics.setTyresTemperature(0, ac.Wheel.All, temp) end
    if settings.cl_vehicle.cl_downforce > 0 then physics.addForce(0, vec3(0, 0, 0), true, vec3(0, -settings.cl_vehicle.cl_downforce * 9.8 * cl_predator * 100, 0), true) end
    if settings.cl_vehicle.cl_freezeFuel >= 0 then physics.setCarFuel(0, settings.cl_vehicle.cl_freezeFuel) end
    if settings.cl_vehicle.cl_damage then physics.setCarBodyDamage(0, vec4(0, 0, 0, 0)) physics.setCarEngineLife(0, 1000) end
    if settings.cl_vehicle.cl_power > 0 and (localCar.gear > 0) and (localCar.rpm + 200 < localCar.rpmLimiter) then
        local passivePush = settings.cl_vehicle.cl_power * localCar.mass * localCar.gas * cl_predator * 100     
        physics.addForce(0, vec3(0, 0, 0), true, vec3(0, 0, passivePush), true)
    end
    if settings.cl_vehicle.cl_braking > 0 and (localCar.speedKmh > 5) then
        local passivePush = settings.cl_vehicle.cl_braking * localCar.mass * localCar.brake * cl_predator * 100
        passivePush = localCar.localVelocity.z > 0.0 and -passivePush or passivePush     
        physics.addForce(0, vec3(0, 0, 0), true, vec3(0, 0, passivePush), true)
    end
end
