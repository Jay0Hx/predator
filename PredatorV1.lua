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
      ui.tabItem("Client Information", function()
      end)
    end

  end) 
end