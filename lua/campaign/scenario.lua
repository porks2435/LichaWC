--<<
local cc_scenario = {}
local on_event = wesnoth.require("on_event")

function cc_scenario.is_human_side(side_num)
	return side_num <= wml.variables.cc_player_count
end

function cc_scenario.scenario_num()
	return wml.variables["cc_scenario"] or 1
end

function cc_scenario.experience_penalty()
	return  wml.tag.effect {
		apply_to = "max_experience",
		increase = wml.variables["cc_difficulty.experience_penalty"] .. "%",
	}
end

-- happens before training events.
on_event("recruit", 1, function(ec)
	local u = wesnoth.units.get(ec.x1, ec.y1)
	if (not u) or (not cc_scenario.is_human_side(u.side)) then
		return
	end
	u:add_modification("advancement", { cc_scenario.experience_penalty() })
end)

function wesnoth.wml_actions.cc_start_units(cfg)
	local u = wesnoth.units.find_on_map({ side = cfg.side, canrecruit = true })[1]
	if not u then error("[cc_start_units] no leader found") end
	u:add_modification("advancement", { cc_scenario.experience_penalty() })
	cc_heroes.heroize(u)
	--u:add_modification("trait", cc_heroes.trait_heroic )
	u.hitpoints = u.max_hitpoints
	u.moves = u.max_moves
	for i = 1, wml.variables["cc_difficulty.heroes"] do
		wesnoth.wml_actions.cc_random_hero {
			x = u.x,
			y = u.y,
			side = u.side,
		}
	end
end

function wesnoth.wml_actions.cc_store_carryover(cfg)
	local human_sides = wesnoth.sides.find(wml.get_child(cfg, "sides"))
	--use an the average amount of villages for this scenario to stay independent of map generator results.
	local nvillages = cfg.nvillages
	local turns_left = math.max(wesnoth.scenario.turns - wesnoth.current.turn, 0)
	local player_gold = 0

	for side_num, side in ipairs(human_sides) do
		player_gold = player_gold + side.gold
	end
	player_gold = math.max(player_gold / #human_sides, 0)
	wml.variables.cc_carryover = math.ceil( (nvillages*turns_left + player_gold) * 0.15)
end

-- carryover handling: we use a custom carryover machnics that
-- splits the carryover gold evenly to all players
on_event("prestart", function(ec)
	wesnoth.game_events.fire("cc_start")
end)

-- we need to do this also after difficulty selection.
on_event("cc_start", function(ec)
	if wml.variables.cc_scenario == 1 then
		for side_num = 1, wml.variables.cc_player_count do
			wesnoth.wml_actions.cc_start_units {
				side = side_num
			}
			--set side variables like BEXP
			wesnoth.sides[side_num].variables["bonus_XP"] = 0
			wesnoth.sides[side_num].gold = wesnoth.sides[side_num].gold + 100
		end

		for side_num = 1, wml.variables.cc_player_count do
			if wml.variables.cc_scenario == 1 then
				wesnoth.wml_actions.cc_give_random_training {
					among="1",
					side = side_num,
				}
			else 
				wesnoth.wml_actions.cc_give_random_training {
					among="2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37",
					side = side_num,
				}
			end
		end
	end

	local gold = (wml.variables.cc_carryover or 0) + (wml.variables["cc_difficulty.extra_gold"] or 0)
	for i = 1, wml.variables.cc_player_count do
		wesnoth.sides[i].gold = wesnoth.sides[i].gold + gold
		local leader = wesnoth.units.find_on_map { side = i, canrecruit = true }
		local x,y = leader[1].x, leader[1].y

		wesnoth.sides[i].variables["keep_loc"] = {x=x, y=y}

	end
	wml.variables.cc_carryover = nil
end)

-- our victory condition
on_event("enemies defeated", function(ec)
	if wml.variables.cc_scenario > 4 then
		return
	end
	wesnoth.audio.play("ambient/ship.ogg")
	wesnoth.wml_actions.endlevel {
		result = "victory",
		carryover_percentage = 0,
		carryover_add = false,
		carryover_report = false,
	}
end)

on_event("victory", function(ec)
	if wml.variables.cc_scenario > 5 then
		return
	end
	wesnoth.wml_actions.cc_set_recall_cost { }
	--{CLEAR_VARIABLE bonus.theme,bonus.point,items}
	wml.variables.cc_scenario = (wml.variables.cc_scenario or 1) + 1
end)

on_event("start", function(ec)
	wesnoth.wml_actions.cc_objectives({})
end)

return cc_scenario
-->>
