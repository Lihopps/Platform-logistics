local handler = require("__core__.lualib.event_handler")

handler.add_libraries({
	require("__flib__.gui"),
	require("script.main"),
	require("script.dispatcher"),
	require("script.platform_manager"),
    require("script.request_manager"),
	require("script.supply_manager"),
	require("script.reservation_manager"),
	require("script.gui.LPN_gui_entity"),
	require("script.provider"),
	require("script.requester"),
	require("script.gui.LPN_gui_manager"),
	require("script.research"),
	require("script.cargo-pod"),
	require("script.gui.inventory"),
	require("script.gui.platform"),
    require("script.gui.debug"),
	require("migration.migration-gui"),

	require("script.debug")
	
})


lihop_debug=false
