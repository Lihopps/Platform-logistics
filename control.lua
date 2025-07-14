local handler = require("__core__.lualib.event_handler")

handler.add_libraries({
	require("__flib__.gui"),
	require("script.main"),
	require("script.requester"),
	require("script.provider"),
    require("script.network"),
	require("script.cargo-pod"),
	require("script.research"),
	require("script.LPN_gui_entity"),
	require("script.LPN_gui_manager"),
	require("script.debug"),
})

lihop_debug=true
