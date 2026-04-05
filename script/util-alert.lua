local util=require("script.util")
local util_alert={}

function util_alert.create_alert_no_provider(entity,itemqal,show)
    local item,quality=table.unpack(util.name_and_qual(itemqal))
    local signal={type="item",name="ptflog-provider"}

    util_alert.create_alert(entity,signal,{"alert.provider","[item="..item..",quality="..quality.."]"},show)
end

function util_alert.create_alert_no_platform(entity,itemqal,show)
    local item,quality=table.unpack(util.name_and_qual(itemqal))
    local signal={type="fluid",name="LPN-no-platform"}

    util_alert.create_alert(entity,signal,{"alert.platform","[item="..item..",quality="..quality.."]"},show)
end

function util_alert.create_alert(entity,signal,message,show)
    for _,player in pairs(entity.force.players) do
        player.add_custom_alert(entity,signal,message,show)
    end
end

return util_alert