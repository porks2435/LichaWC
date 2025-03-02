local _ = wesnoth.textdomain 'wesnoth-cc'
local on_event = wesnoth.require("on_event")

local bonus = {}
bonus.sceneries = {}

-- places a bonus point on the map.
function wesnoth.wml_actions.cc_place_bonus(cfg)
	local x = cfg.x or wml.error("[cc_place_bonus] missing required 'x' attribute")
	local y = cfg.y or wml.error("[cc_place_bonus] missing required 'y' attribute")
	local scenery = cfg.scenery or wml.error("[cc_place_bonus] missing required 'scenery' attribute")
	local c_scenery = bonus.sceneries[scenery]
	if not c_scenery then
		wml.error("[cc_place_bonus] invalid 'scenery' attribute: ".. tostring(scenery))
		end
	local image = c_scenery.image or scenery
	bonus.place_item(x, y, image)

	-- Note: although the numbers of options passed to mathx.random_choice might depend on the langauge
	--       the number of times random is called does not (random is called even if there is
	--       only one option), so this doesn't cause OOS.
	local name1 = cc_random_names()
	local name_options = c_scenery.names or { _"place" }
	local name2 = tostring(name_options[mathx.random(#name_options)])

	local function span_font_family(str, fam)
		return string.format("<span font-family='%s'>%s</span>", fam, str)
	end
	print("placed label", x, y)
	wesnoth.wml_actions.label {
		x = x,
		y = y,
		text = span_font_family(stringx.vformat(_ "$name's $type", {name = name1, type = name2}), "Lucida Sans Unicode")
	}
end

function bonus.place_item(x, y, image)
	if image == "campfire" then
		wesnoth.current.map[{x, y}] = "^Ecf"
		image = nil
	else
		image = image or "scenery/lighthouse.png"
	end

	wesnoth.wml_actions.item {
		x = x,
		y = y,
		image = image,
		z_order = 10,
		wml.tag.variables { cc_is_bonus = true },
	}
end

function bonus.remove_current_item(ec)
	cc_dropping.remove_current_item(ec)
	wesnoth.wml_actions.terrain {
		x = ec.x1,
		y = ec.y1,
		wml.tag["and"] {
			terrain = "*^Ecf",
		},
		terrain = "Gs",
		layer = "overlay",
	}
	wesnoth.wml_actions.item {
		x = ec.x1,
		y = ec.y1,
		image = "scenery/rubble.png",
		z_order = -10,
	}
end

-- check to be overwritten by other mods.
function bonus.can_pickup_bonus(side_num, x, y)
	local u = wesnoth.units.get(x, y)
	return cc_scenario.is_human_side(u.side)
end

-- event fired by dropping.lua
on_event("cc_drop_pickup", function(ec)
	local item = cc_dropping.current_item
	local side_num = wesnoth.current.side

	if not item.variables.cc_is_bonus then
		return
	end

	if not bonus.can_pickup_bonus then
		return
	end

	local u = wesnoth.units.get(ec.x1, ec.y1)

	if u.variables["artifact"] or not cc_scenario.is_human_side(u.side) then
		return
	end

	wesnoth.wml_actions.message {
		x = ec.x1,
		y = ec.y1,
		message = _"I found something!",
	}
	bonus.remove_current_item(ec)
	cc_heroes.heroize(u)

	local is_local = false
	local res = wesnoth.sync.evaluate_single(_"CC Invest", function()
		is_local = true
		local scenario_num = cc_scenario.scenario_num()
		local discovered_items = cc_artifacts.get_suitable_items(u, scenario_num)

		while(#discovered_items > 5) do
			table.remove(discovered_items, mathx.random(#discovered_items))
		end

		return cc_show_invest_dialog {
			items_available = discovered_items
		}
	end)
	if res.pick == "item" then
		cc_artifacts.give_item(u, res.type)
		return true
	else
		error("cc invest: invalid pick , pick='" .. tostring(res.pick) .. "'.")
	end

	assert(cc_dropping.item_taken, "item still there")
end)

function bonus.init_data(cfg)
	local sceneries = bonus.sceneries
	local lit = wml.literal(cfg)
	for k,v in pairs(wml.get_child(lit, "str") or {}) do
		local scenery = sceneries[k] or {}
		scenery.names = v
		sceneries[k] = scenery
	end
	for k,v in pairs(wml.get_child(lit, "img") or {}) do
		local scenery = sceneries[k] or {}
		sceneries[k].image = v
		sceneries[k] = scenery
	end
end

if true then
	local sceneries = bonus.sceneries
	local strings, images = wesnoth.dofile("./bonus_point_definitions.lua")
	for k,v in pairs(strings) do
		local scenery = sceneries[k] or {}
		scenery.names = v
		sceneries[k] = scenery
	end
	for k,v in pairs(images) do
		local scenery = sceneries[k] or {}
		scenery.image = v
		sceneries[k] = scenery
	end
end

return bonus
