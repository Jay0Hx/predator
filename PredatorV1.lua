-- 'PredatorV1' An assetto corsa menu created by LuaLoom
-- This software and code is FREE to use and edit.
-- The official version can be found at https://github.com/Jay0Hx/PredatorV1
-- https://discord.gg/M768CjCcP8

local predator_setting = {
  menu_settings = {
    drivers_tab = true,
    client_information = true,
  },
}

function script.windowMain(PredatorV1)
  ui.tabBar("main_tabs", function()
    ui.tabItem("Settings", function()
      if ui.checkbox("Enable 'Drivers' tab.", predator_setting.menu_settings.drivers_tab) then  
        predator_setting.menu_settings.drivers_tab = not predator_setting.menu_settings.drivers_tab   
      end
      if ui.checkbox("Enable 'Your Information' tab.", predator_setting.menu_settings.client_information) then  
        predator_setting.menu_settings.client_information = not predator_setting.menu_settings.client_information   
      end
    end)
    if predator_setting.menu_settings.drivers_tab then
      ui.tabItem("Drivers", function()
      end)
    end

    if predator_setting.menu_settings.client_information then
      ui.tabItem("🧑 Your Information", function()
        ui.treeNode("Client Information", ui.TreeNodeFlags.DefaultClosed and ui.TreeNodeFlags.Framed, function ()
          ui.text("   🎌 • Race Position: "..ac.getCar().racePosition)
          ui.text("   👋 • Display Name: "..ac.getDriverName())
          ui.text("   🩹 • Patch Version: "..ac.getPatchVersion())
          ui.text("   📐 • Current FOV: "..ac.getCameraFOV())
          ui.text("   🗺️ • Position:")
          ui.sameLine()
          ui.text(ac.getCameraPosition())
          ui.text("   📷 • Camera:")
          ui.sameLine()
          ui.text(ac.getCameraDirection()) 
        end)
        ui.treeNode("Track Information", ui.TreeNodeFlags.DefaultClosed and ui.TreeNodeFlags.Framed, function ()
          ui.text("   🛣️ • Track ID: "..ac.getTrackId())
          ui.text("   🛣️ • Track Name: "..ac.getTrackName())
        end)
        ui.treeNode("Car Information", ui.TreeNodeFlags.DefaultClosed and ui.TreeNodeFlags.Framed, function ()
          ui.text("   🚩 • Car Country: "..ac.getCarCountry())
          ui.text("   🚗 • Car Name: "..ac.getCarName())
          ui.text("   🚗 • Car Brand: "..ac.getCarBrand())
          ui.text("   🪪 • Car ID: "..ac.getCarID())
          ui.text("   💨 • Current Speed: "..ac.getCarSpeedKmh())
          ui.text("   🛞 • Tyres Name: "..ac.getTyresName())  
        end)
      end)
    end
  end) 
end
