local LPN_gui_manager=require("script.LPN_gui_manager")


local function on_research_finished(e)
    local research=e.research
    if research and research.valid then
        if research.name=="LPN-starter" then
            for i,player in ipairs(research.force.players) do
                LPN_gui_manager.add_button_manager(player)
            end
        end
    end
end


local research={}

research.events = {
    [defines.events.on_research_finished] = on_research_finished,
}

return research