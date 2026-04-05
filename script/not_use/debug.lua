local LPN_gui_manager= require("script.gui.LPN_gui_manager")

local v1_0_4=require("migration.1_0_4")


local debug={}


commands.add_command("lpn_rebuild", nil,
    function(command)
       LPN_gui_manager.rebuild()
       game.print("LOGISTIC PLANET NETWORK : LPN GUI MANAGER REBUILT")
    end)

commands.add_command("lpn_migration", nil,
    function(command) 
       v1_0_4.change()
       --game.print("Simulation changement effectué")
    end)

commands.add_command("lpn_reset", nil,
    function(command)
       game.print("LOGISTIC PLANET NETWORK : Start complete reset")
       storage.idle_platforms = {}
       storage.requests = {}
       storage.supplies = {}
       storage.reservations = {}
       storage.request_reservations = {}
       for id, platform in pairs(storage.platforms) do
            platform.entity.get_schedule().clear_records()
            platform.mission=nil
            plaform.mission_index=1

       end
       game.print("LOGISTIC PLANET NETWORK : End complete reset")
       
    end)


return debug