local on_event = wesnoth.require("on_event")
local T = wml.tag

local enemy = {}

local function get_advanced_units(level, list, res)
	res = res or {}
	-- guards against units that can advance in circles or to themselves
	local res_set = {}
	local function add_units(units)
		for unused, typename in ipairs(units) do
			local unittype = wesnoth.unit_types[typename]
			if unittype.level == level then
				table.insert(res, typename)
			elseif not res_set[typename] then
				res_set[typename] = true;
				add_units(unittype.advances_to)
			end
		end
	end
	add_units(list)
	return res
end


-- todo the old code used prerecruit to allow artifact events written into unit become active in recruit, why?
on_event("recruit", function(ec)
	if wesnoth.current.turn < 2 then
		--the old code also didn't gave items on first turn.
		return
	end
	local side_variables = wesnoth.sides[wesnoth.current.side].variables
	local needs_item = side_variables["cc.random_items"] or 0
	local scenario_num = cc_scenario.scenario_num()
	if needs_item == 0 then
		return
	end
	side_variables["cc.random_items"] = needs_item - 1
	local unit = wesnoth.units.get(ec.x1, ec.y1)
	cc_heroes.heroize(unit)
	unit.experience = unit.experience + scenario_num  * (8 * wml.variables["cc_difficulty.enemy_power"])
	unit:advance(true, true)
	local possible_artifacts = cc_artifacts.get_suitable_items(unit,scenario_num)
	local p = possible_artifacts[mathx.random(#possible_artifacts)]
	cc_artifacts.give_item(unit, p)
	
	wesnoth.allow_undo(false)
end)

--Gives the enemy side @cfg.side a commander (a hero unit)
function enemy.do_commander(cfg, group_id, loc)
	if not cfg.commander or cfg.commander <= 0 then
		return
	end
	local scenario = cc_scenario.scenario_num()
	
	local ally_i = cc_utils.pick_random(("cc_enemy_army.group[%d].allies_available"):format(group_id)) - 1
	local leader_index = mathx.random(wml.variables[("cc_enemy_army.group[%d].leader.length"):format(ally_i)]) - 1
	local new_recruits = wml.variables[("cc_enemy_army.group[%d].leader[%d].recruit"):format(ally_i, leader_index)]
	wesnoth.wml_actions.allow_recruit {
		side = cfg.side,
		type = new_recruits
	}
	local commander_options = wml.variables[("cc_enemy_army.group[%d].commander.level%d"):format(ally_i, cfg.commander)]
	wesnoth.wml_actions.unit {
		x = loc[1],
		y = loc[2],
		type = mathx.random_choice(commander_options),
		side = cfg.side,
		generate_name = true,
		role = "commander",
		experience = scenario * ((wml.variables["cc_difficulty.enemy_power"] or 6) - 7 + cfg.commander),
		T.modifications {
			cc_heroes.commander_overlay_object(),
			T.trait(cc_heroes.trait_heroic),
		},
	}
end

-- CONQUEST_ENEMY_SUPPLY
function enemy.do_supply(cfg, group_id, loc, side_num)
	if cc_scenario.scenario_num() < 4 then
		return
	end
	local u = wesnoth.units.get(loc[1], loc[2])
	if u then
		-- heroize twice for large stats
		cc_heroes.heroize(u)

		u:add_modification("trait", cc_heroes.trait_expert)
		wesnoth.wml_actions.event {
			name = "side " .. cfg.side .. " turn 2",
			T.cc_map_supply_village {
				x = u.x,
				y = u.y,
			}
		}
	end
	local heroes = wesnoth.units.find_on_map({trait = "heroic",side = side_num})
	for _, hero in ipairs(heroes) do
        cc_heroes.heroize(hero)
        if not hero:matches({canrecruit = "yes"}) then
        	cc_training.apply(hero)
        end
    end

end

-- CONQUEST_ENEMY_RECALLS
on_event("recruit", function(ec)
	local side_num = wesnoth.current.side
	local side_variables = wesnoth.sides[side_num].variables
	local to_recall = stringx.split(side_variables["cc.to_recall"] or "")
	if #to_recall == 0 then
		return
	end
	local candidates = wesnoth.map.find {
		terrain = "K*,C*,*^C*,*^K*",
		T["and"] {
			T.filter {
				canrecruit = true,
				side = side_num,
				T.filter_location {
					terrain = "K*^*,*^K*",
				},
			},
			radius = 999,
			T.filter_radius {
				terrain = "K*^*,C*^*,*^K*,*^C*",
			},
		},
		T["not"] {
			T.filter {}
		}
	}
	mathx.shuffle(candidates)
	while #candidates > 0 and #to_recall > 0 do
		enemy.fake_recall(side_num, to_recall[1], candidates[1])
		table.remove(to_recall, 1)
		table.remove(candidates, 1)
	end
	side_variables["cc.to_recall"] = table.concat(to_recall, ",")
end)

--Gives the enemy side @cfg.side units that it can recall.
--It does not really addthem to the recall list but
--emulates that by placing higher level units on the map in that sides
function enemy.do_recall(cfg, group_id, loc)
	local side_num = cfg.side
	local side_variables = wesnoth.sides[side_num].variables

	local group = wml.variables[("cc_enemy_army.group[%d]"):format(group_id)]
	local to_recall = stringx.split(side_variables["cc.to_recall"] or "")
	local function recall_level(level)
		local amount = wml.get_child(cfg, "recall")["level" .. level] or 0
		local types =  stringx.split(wml.get_child(group, "recall")["level" .. level] or "")
		if #types == 0 then
			get_advanced_units(level, stringx.split(group.recruit or ""), types)
		end
		for i = 1, amount do
			table.insert(to_recall, types[mathx.random(#types)])
		end
	end
	recall_level(2)
	recall_level(3)
	side_variables["cc.to_recall"] = table.concat(to_recall, ",")
end

-- CC_ENEMY_FAKE_RECALL
function enemy.fake_recall(side_num, t, loc)
	local side = wesnoth.sides[side_num]
	local u = wesnoth.units.create {
		side = side_num,
		type = t,
		generate_name = true,
		moves = 0,
	}
	for i = 1, u.level do 
		cc_training.apply(u)
	end
	u:to_map(loc)
	wesnoth.add_known_unit(t)
	side.gold = side.gold - 20
end


-- CONQUEST_ENEMY_TRAINING
function enemy.do_training(cfg, group_id, loc)
	local tr = cfg.trained or 0
	local dif = wml.variables["cc_difficulty.enemy_trained"] or 0
	if cc_scenario.scenario_num() > 3 then
		-- give scenario num trainings
		wesnoth.wml_actions.cc_give_random_training { side = cfg.side, among="1" }
		for i = 1, cc_scenario.scenario_num() do
			wesnoth.wml_actions.cc_give_random_training {
				side = cfg.side,
				among="2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30"
			}
		end
	elseif tr ~= 0 and dif >= tr then
		wesnoth.wml_actions.cc_give_random_training {
			side = cfg.side,
			among="2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30"
		}
	end
end

function enemy.do_gold(cfg, side)
	--difficulty_enemy_power is in [6,9]
	local enemy_power = (wml.variables["cc_difficulty.enemy_power"] or 6)
	local factor = (cfg.nplayers + 1 ) * enemy_power/6 - 2
	side.gold = side.gold + cfg.bonus_gold * factor
end

function enemy.init_data()
	if wml.variables.cc_enemy_army == nil then
		-- give eras an option to overwrite the enemy data.
		wesnoth.game_events.fire("cc_init_enemy")
	end
	if wml.variables.cc_enemy_army == nil then
		-- give eras an option to overwrite the enemy data.
		local enemy_army = wesnoth.dofile("./enemy_data.lua")
		wml.variables.cc_enemy_army = cc_convert.lon_to_wml(enemy_army, "cc_enemy")
	end
end

function wesnoth.wml_actions.cc_enemy(cfg)
	enemy.init_data()
	local side_num = cfg.side
	local side = wesnoth.sides[side_num]
	local scenario = cc_scenario.scenario_num()

	enemy.do_gold(cfg, side)

	local dummy_unit = wesnoth.units.find_on_map({side = side_num, canrecruit = true})[1]
	local loc = {dummy_unit.x,dummy_unit.y}
	dummy_unit:erase()
	local enemy_type_id = cc_utils.pick_random("cc_enemy_army.factions_available") - 1
	if enemy_type_id == nil then
		--should't happen, added for robustness.
		local n_groups = wml.variables["cc_enemy_army.group.length"]
		if n_groups > 0 then
			enemy_type_id = mathx.random(n_groups) - 1
		else
			error("no enemy groups defined")
		end
	end
	local leader_cfg = cc_utils.pick_random_t(("cc_enemy_army.group[%d].leader"):format(enemy_type_id))
	local unit = wesnoth.units.create {
		x = loc[1],
		y = loc[2],
		type = scenario == 1 and leader_cfg.level2 or leader_cfg.level3,
		side = side_num,
		canrecruit = true,
		generate_name = true,
		max_moves = 0,
		T.modifications { T.trait(cc_heroes.trait_heroic) },
	}
	if unit.name == "" then
		-- give names to undead
		unit.name = cc_random_names()
	end
	unit:to_map()
	wesnoth.add_known_unit(unit.type)
	wesnoth.wml_actions.set_recruit {
		side = side_num,
		recruit = wml.variables[("cc_enemy_army.group[%d].recruit"):format(enemy_type_id)]
	}
	wesnoth.wml_actions.allow_recruit {
		side = side_num,
		type = leader_cfg.recruit
	}

	enemy.do_training(cfg, enemy_type_id, loc)
	enemy.do_commander(cfg, enemy_type_id, loc)
	enemy.do_supply(cfg, enemy_type_id, loc, side_num)
	enemy.do_recall(cfg, enemy_type_id, loc)
	
	if (cfg.have_item > 0 and cfg.have_item <= (wml.variables["cc_difficulty.enemy_power"] or 6)) or scenario == 5 then
		side.variables["cc.random_items"] = 1
	end
end

return enemy
