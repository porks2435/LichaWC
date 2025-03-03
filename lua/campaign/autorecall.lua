local on_event = wesnoth.require("on_event")
-- players get recalled by free all heroes up to castle size
local function cc_autorecall()
	for side_num = 1, wml.variables.cc_player_count do
		local castle_tiles = wesnoth.map.find {
			terrain = "C*",
			wml.tag["and"] {
				radius = 3,
				wml.tag.filter_radius {
					terrain = "C*,K*"
				},
				wml.tag.filter {
					side = side_num,
					canrecruit = true,
				}
			}
		}
		for i, loc in ipairs(castle_tiles) do
			wesnoth.wml_actions.recall {
				x = loc[1],
				y = loc[2],
				show = false,
				side = side_num,
				wml.tag.filter_wml {
					wml.tag.modifications {
						wml.tag.trait {
							id = "heroic"
						}
					}
				}
			}
		end

		local units = wesnoth.units.find{side = side_num}
	    for i, u in ipairs(units) do
			cc_training.apply(u)
		end
	end
end

on_event("start", function(ec)
	local scenario_num = cc_scenario.scenario_num()
	if (scenario_num or 1) > 1 then
		cc_autorecall()
	end
end)
