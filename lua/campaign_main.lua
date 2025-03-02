-- the main file for the CC mp campaign

T = wml.tag
on_event = wesnoth.game_events.add_repeating

wesnoth.dofile("./game_mechanics/_load.lua")

cc_era = wesnoth.require("./era/era.lua")

cc_enemy = wesnoth.dofile("./campaign/enemy.lua")

cc_scenario = wesnoth.dofile("./campaign/scenario.lua")
wesnoth.dofile("./campaign/autorecall.lua")
wesnoth.dofile("./campaign/objectives.lua")
wesnoth.dofile("./campaign/enemy_themed.lua")

on_event("prestart", function(ec)
	wesnoth.wml_actions.cc_fix_colors {
		T.player_sides {
			side="1,2,3,4",
			T.has_unit {
				canrecruit = true,
			}
		}
	}
end)
