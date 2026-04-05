local routing = require("script.routing")


--data.raw["space-connection"]["nauvis-fulgora"].length=5000

routing.collect_data()

for name, connection in pairs(data.raw["space-connection"]) do
  local from = data.raw["space-location"][connection.from] or data.raw["planet"][connection.from]
  local to = data.raw["space-location"][connection.to] or data.raw["planet"][connection.to]
  local layers = {
    {
      filename = "__space-age__/graphics/icons/planet-route.png",
      size = 64,
    },
    {
      filename = from.icon,
      size = from.icon_size or 64,
      shift = { -12, -12 },
      scale=0.666*(64 / (from.icon_size or 64))
    },
    {
      filename = to.icon,
      size = to.icon_size or 64,
      shift = { 12, 12 },
      scale=0.666*(64 / (to.icon_size or 64))
    }
  }
  data:extend({
    {
      type = "sprite",
      name = "LPN-" .. connection.from .. "_" .. connection.to,
      layers = layers,
      priority = "extra-high-no-scale",
      width = 64,
      height = 64,
      flags = { "gui-icon" },
    },
  })
end
