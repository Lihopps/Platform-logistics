
local styles = data.raw["gui-style"]["default"]

--- LABEL

styles.LPN_label_signal_count_inventory = {
	type = "label_style",
	parent = "count_label",
	size = 36,
	width = 36,
	horizontal_align = "right",
	vertical_align = "bottom",
	right_padding = 2,
	parent_hovered_font_color = { 1, 1, 1 },
}

styles.LPN_label_signal_count = {
	type = "label_style",
	parent = "LPN_label_signal_count_inventory",
	bottom_padding = 3,
	right_padding = 4,
}

styles.LPN_label_train_count_inventory = {
	type = "label_style",
	parent = "count_label",
	size = 36,
	width = 36,
	horizontal_align = "right",
	vertical_align = "top",
	right_padding = 3,
	top_padding = -4,
	parent_hovered_font_color = { 1, 1, 1 },
}
styles.LPN_label_position = {
	type = "label_style",
	parent = "heading_2_label",
	bottom_padding = 3,
	right_padding = 4,
	height=10
}

styles.LPN_minimap_label = {
	type = "label_style",
	font = "default-game",
	font_color = default_font_color,
	size = 100,
	vertical_align = "bottom",
	horizontal_align = "right",
	right_padding = 4,
}

styles.LPN_station_camera_label = {
	type = "label_style",
	font = "default-game",
	font_color = default_font_color,
	size = 225,
	vertical_align = "bottom",
	horizontal_align = "right",
	right_padding = 4,
}

styles.LPN_station_camera_planet = {
	type = "label_style",
	font = "default-game",
	font_color = default_font_color,
	size = 225,
	vertical_align = "top",
	horizontal_align = "left",
	right_padding = 4,
}

styles.LPN_station_camera_label_type = {
	type = "label_style",
	font = "default-game",
	font_color = default_font_color,
	size = 225,
	vertical_align = "top",
	horizontal_align = "right",
	right_padding = 4,
}

---Frames
styles.LPN_main_toolbar_frame = {
	type = "frame_style",
	parent = "subheader_frame",
	top_margin = 4,
	bottom_margin = 12,
	vertical_align = "center",
	horizontal_flow_style = {
		type = "horizontal_flow_style",
		horizontal_spacing = 12,
		vertical_align = "center",
	},
}

styles.LPN_table_inset_frame_dark = {
	type = "frame_style",
	parent = "deep_frame_in_shallow_frame",
	graphical_set = {
		base = {
			position = { 51, 0 },
			corner_size = 8,
			center = { position = { 42, 8 }, size = { 1, 1 } },
			draw_type = "outer",
		},
		shadow = default_inner_shadow,
	},
}

styles.LPN_table_toolbar_frame = {
	type = "frame_style",
	parent = "subheader_frame",
	left_padding = 9,
	right_padding = 7 + 12,
	horizontally_stretchable = "on", 
	horizontal_flow_style = {
		type = "horizontal_flow_style",
		horizontal_spacing = 10,
		vertical_align = "center",
	},
}

styles.LPN_table_row_frame_light = {
	type = "frame_style",
	--parent = "statistics_table_item_frame",
	--this is likely incorrect, unsure what the 2.0 equivalent is
	parent = "neutral_message_frame",
	top_padding = 8,
	bottom_padding = 8,
	left_padding = 8,
	right_padding = 8,
	minimal_height = 52,
	horizontal_flow_style = {
		type = "horizontal_flow_style",
		vertical_align = "center",
		horizontal_spacing = 10,
		horizontally_stretchable = "on",
	},
	graphical_set = {
		base = {
			center = { position = { 76, 8 }, size = { 1, 1 } },
			-- bottom = {position = {8, 40}, size = {1, 8}},
		},
	},
}

styles.LPN_table_row_frame_dark = {
	type = "frame_style",
	parent = "LPN_table_row_frame_light",
	-- graphical_set = {
	--   base = {bottom = {position = {8, 40}, size = {1, 8}}},
	-- },
	graphical_set = {},
}

-- TABBED PANE STYLES

styles.LPN_tabbed_pane = {
	type = "tabbed_pane_style",
	tab_content_frame = {
		type = "frame_style",
		parent = "tabbed_pane_frame",
		left_padding = 12,
		right_padding = 12,
		bottom_padding = 8,
	},
}


-- SCROLL PANE STYLES

styles.LPN_table_scroll_pane = {
	type = "scroll_pane_style",
	parent = "flib_naked_scroll_pane_no_padding",
	vertical_flow_style = {
		type = "vertical_flow_style",
		vertical_spacing = 0,
	},
}

styles.LPN_slot_table_scroll_pane = {
	type = "scroll_pane_style",
	parent = "flib_naked_scroll_pane_no_padding",
	horizontally_squashable = "off",
	background_graphical_set = {
		base = {
			position = { 282, 17 },
			corner_size = 8,
			overall_tiling_horizontal_padding = 4,
			overall_tiling_horizontal_size = 32,
			overall_tiling_horizontal_spacing = 8,
			overall_tiling_vertical_padding = 4,
			overall_tiling_vertical_size = 32,
			overall_tiling_vertical_spacing = 8,
		},
	},
}

-- CHECKBOX STYLES

-- inactive is grey until hovered
-- checked = ascending, unchecked = descending
styles.LPN_sort_checkbox = {
	type = "checkbox_style",
	font = "heading-2",
	font_color = gui_color.caption,
	padding = 0,
	default_graphical_set = {
		filename = "__core__/graphics/arrows/table-header-sort-arrow-down-white.png",
		size = { 16, 16 },
		scale = 0.5,
	},
	hovered_graphical_set = {
		filename = "__core__/graphics/arrows/table-header-sort-arrow-down-hover.png",
		size = { 16, 16 },
		scale = 0.5,
	},
	clicked_graphical_set = {
		filename = "__core__/graphics/arrows/table-header-sort-arrow-down-white.png",
		size = { 16, 16 },
		scale = 0.5,
	},
	disabled_graphical_set = {
		filename = "__core__/graphics/arrows/table-header-sort-arrow-down-white.png",
		size = { 16, 16 },
		scale = 0.5,
	},
	selected_graphical_set = {
		filename = "__core__/graphics/arrows/table-header-sort-arrow-up-white.png",
		size = { 16, 16 },
		scale = 0.5,
	},
	selected_hovered_graphical_set = {
		filename = "__core__/graphics/arrows/table-header-sort-arrow-up-hover.png",
		size = { 16, 16 },
		scale = 0.5,
	},
	selected_clicked_graphical_set = {
		filename = "__core__/graphics/arrows/table-header-sort-arrow-up-white.png",
		size = { 16, 16 },
		scale = 0.5,
	},
	selected_disabled_graphical_set = {
		filename = "__core__/graphics/arrows/table-header-sort-arrow-up-white.png",
		size = { 16, 16 },
		scale = 0.5,
	},
	checkmark = util.empty_checkmark,
	disabled_checkmark = util.empty_checkmark,
	text_padding = 5,
}

--- selected is orange by default
styles.LPN_selected_sort_checkbox = {
	type = "checkbox_style",
	parent = "LPN_sort_checkbox",
	-- font_color = bold_font_color,
	default_graphical_set = {
		filename = "__core__/graphics/arrows/table-header-sort-arrow-down-active.png",
		size = { 16, 16 },
		scale = 0.5,
	},
	selected_graphical_set = {
		filename = "__core__/graphics/arrows/table-header-sort-arrow-up-active.png",
		size = { 16, 16 },
		scale = 0.5,
	},
}

-- MINIMAP STYLES

styles.LPN_train_minimap = {
	type = "minimap_style",
	size = 100,
}

-- Camera STYLES

styles.LPN_station_camera = {
	type = "camera_style",
	size = 225,
}


---button styles
styles.LPN_train_minimap_button = {
	type = "button_style",
	parent = "button",
	size = 100,
	default_graphical_set = {},
	hovered_graphical_set = {
		base = { position = { 81, 80 }, size = 1, opacity = 0.7 },
	},
	clicked_graphical_set = { position = { 70, 146 }, size = 1, opacity = 0.7 },
}

styles.LPN_station_camera_button = {
	type = "button_style",
	parent = "button",
	size = 225,
	default_graphical_set = {},
	hovered_graphical_set = {
		base = { position = { 81, 80 }, size = 1, opacity = 0.7 },
	},
	clicked_graphical_set = { position = { 70, 146 }, size = 1, opacity = 0.7 },
}