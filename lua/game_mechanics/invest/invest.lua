local on_event = wesnoth.require("on_event")
local _ = wesnoth.textdomain 'wesnoth-cc'

local cc_invest = {}

local function find_index(t, v)
	for i,v2 in ipairs(t) do
		if v2 == v then return i end
	end
end

function cc_invest.do_gold()
	local side_num = wesnoth.current.side
	local side = wesnoth.sides[side_num]
	local leaders = wesnoth.units.find_on_map { side = side_num, canrecruit = true }
	local l_x = leaders[1].x
	local l_y = leaders[1].y
	side.gold = side.gold + 70
	wesnoth.wml_actions.cc_map_supply_village {
		x = l_x,
		y = l_y
	}
end

function cc_invest.do_fortify()
	local side_num = wesnoth.current.side
	local side = wesnoth.sides[side_num]
	local leaders = wesnoth.units.find_on_map { side = side_num, canrecruit = true }
	local fort = wesnoth.map.get_hexes_in_radius(leaders[1].loc,2)
	local l_x = leaders[1].x
	local l_y = leaders[1].y

	for a=1, #fort do
		wesnoth.wml_actions.terrain {
	        x = fort[a][1],
	        y = fort[a][2],
	        terrain = "Ce",
	        layer = "base",
	        wml.tag["not"] {
                terrain = "C*^*,*^C*,K*^*,*^K*,*^Xm,*^Xo,*^Qov,Q*^*"
            },
	    }
	end

	local fort_endpoints = { {l_x,l_y+2}, {l_x,l_y-2}, {l_x+2,l_y+1}, {l_x+2,l_y-1}, {l_x-2,l_y+1}, {l_x-2,l_y-1} }
	for a=1,6 do
		local ballista = wesnoth.units.create {
            type = "Ballista Turret",
            side = side_num,
            random_traits = false
        }
        local x2,y2 = wesnoth.paths.find_vacant_hex(fort_endpoints[a][1],fort_endpoints[a][2])
        ballista:to_map(x2,y2)
	end
end

function cc_invest.do_teleport(t)
	local side_num = wesnoth.current.side

	-- find keep coordinates (and not leader, they might have moved)
	local keep_loc = wesnoth.sides[t].variables["keep_loc"]

	local units = wesnoth.units.find_on_map { side = side_num }

	-- teleport all units
	for i, u in ipairs(units) do
		local x2,y2 = wesnoth.paths.find_vacant_hex(keep_loc.x, keep_loc.y, u)
		wesnoth.wml_actions.teleport {
			wml.tag.filter { id = u.id },
			x = x2,
			y = y2
		}
	end    

	wesnoth.sides[side_num].variables["teleport"] = nil
end

function cc_invest.do_hero(t, is_local)
	local side_num = wesnoth.current.side
	local side = wesnoth.sides[side_num]
	local leaders = wesnoth.units.find_on_map { side = side_num, canrecruit = true }
	local x,y = leaders[1].x, leaders[1].y

	local heroes_available = stringx.split(side.variables["cc.heroes"] or "")
	local i = find_index(heroes_available, t)
	if i == nil then
		error("cc invest: invalid pick")
	end
	cc_heroes.place(t, side_num, x, y, false)
	

end

function cc_invest.do_training(t)
	local side_num = wesnoth.current.side
	cc_training.inc_level(side_num, t)
end

function cc_invest.invest()
	local side_num = wesnoth.current.side
	local side = wesnoth.sides[side_num]
	local gold_available = true

	for i = 1,2 do
		local is_local = false
		local res = wesnoth.sync.evaluate_single(_"CC Invest", function()
			is_local = true

			local heroes_available = stringx.split(side.variables["cc.heroes"] or "")
			local trainings_available = cc_training.list_available(side_num, {2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33})
			
			local merc_selection = heroes_available
			while(#merc_selection > 5) do
				table.remove(merc_selection, mathx.random(#merc_selection))
			end

			local training_selection = trainings_available
			while(#training_selection > 5) do
				table.remove(training_selection, mathx.random(#training_selection))
			end

			return cc_show_invest_dialog {
				heroes_available = merc_selection,
				trainings_available = training_selection,
				gold_available = gold_available
			}
		end)
		if res.pick == "gold" then
			cc_invest.do_gold()
			gold_available = nil
		elseif res.pick == "fortify" then
			cc_invest.do_fortify()
			gold_available = nil
		elseif res.pick == "teleport" then
			side.variables["teleport"] = res.side
			gold_available = nil
		elseif res.pick == "hero" then
			cc_invest.do_hero(res.type, is_local)
		elseif res.pick == "training" then
			cc_invest.do_training(res.type)
		else
			error("cc invest: invalid pick , pick='" .. tostring(res.pick) .. "'.")
		end
	end

end

function wesnoth.wml_actions.cc_invest(cfg)
	--disallow undoing.
	mathx.random(100)
	cc_invest.invest()
end

return cc_invest
