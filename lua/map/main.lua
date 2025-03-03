_ = wesnoth.textdomain 'wesnoth-cc'
utils = wesnoth.require("wml-utils")
functional = wesnoth.require("functional")
cc_convert = wesnoth.dofile("./../shared_utils/wml_converter.lua")
wesnoth.dofile("./utility.lua")
wesnoth.dofile("./../shared_utils/pretty_print.lua")
wesnoth.dofile("./scenario_utils/bonus_points.lua")
wesnoth.dofile("./cc_map_generator.lua")
wesnoth.dofile("./scenario_utils/plot.lua")
wesnoth.dofile("./scenario_utils/side_definitions.lua")
settings = globals.settings or {}

local n_villages = {27, 40, 53, 63}

local function get_map_generator(scenario_data)
	if globals.settings.default_id then
		-- overwrite the random result, with a preset one (used by the editor)
		return cc_map_generator(
			globals.settings.default_id,
			globals.settings.postgen_id,
			globals.settings.length,
			globals.settings.villages,
			globals.settings.castle,
			globals.settings.iterations,
			globals.settings.hill_size,
			globals.settings.ncastles,
			globals.settings.island
		)
	else
		return scenario_data.generators[mathx.random(#scenario_data.generators)]
	end
end

local function get_scenario_data(nplayers, scenario_num)
	return wesnoth.dofile(string.format("./scenarios/CC_%dp_scenario%d.lua", nplayers, scenario_num))
end


function cc_ii_generate_scenario(nplayers, gen_args)
	nplayers = settings.nplayers or nplayers
	local scenario_extra = wml.get_child(gen_args, "scenario")
	local scenario_num = settings.scenario_num or wml.variables.cc_scenario or 1
	--todo: does this work properly in the first scenario?
	local enemy_stength = wml.variables["cc_difficulty.enemy_power"] or 6
	std_print("test_nplayers", wml.variables.test_nplayers)
	local scenario_data = get_scenario_data(nplayers, scenario_num)

	local prestart_event = { name = "prestart" }
	-- our [scenario] skeleton
	local scenario = {
		event = {
			prestart_event
		},
		lua = {},
		load_resource = {
			{
				id = "cc_era_res"
			},
			{
				id = "cc_scenario_res"
			},
			{
				id = "cc_scenario_res_extra"
			},
		},
		options = {
			wml.tag.checkbox {
				id="cc_config_enable_unitmarker",
				default=true,
				name="Enable unitmarker",
				description="enables the buildin mod to mark units, disable this to be compatible with other mods that do the same thing",
			},
		},
		variables = {
			cc_scenario = scenario_num,
			cc_player_count = nplayers,
		},
		side = {},
		id = gen_args.id,
		next_scenario = gen_args.id,
		description = "CC_" .. nplayers .. "p_desc",
		modify_placing = false,
		turns = scenario_data.turns,
	}

	-- add [side]s to the [scenario]
	local enemy_data = scenario_data.get_enemy_data(enemy_stength)
	cc_ii_generate_sides(scenario, prestart_event, nplayers, scenario_num, enemy_data, scenario_data)

	-- add plot (that is [event] with [message]s)
	add_plot(scenario, scenario_num, nplayers)

	-- add the gold carryover event
	if scenario_num < #n_villages then
		table.insert(scenario.event, {
			name = "victory",
			wml.tag.cc_store_carryover {
				nvillages = n_villages[scenario_num] + 2 * nplayers,
				wml.tag.sides {
					side="1,2,3",
					wml.tag.has_unit {
					}
				}
			}
		})
	end

	-- add some cc specific wml [event]s
	for side_num = 1, nplayers do
		table.insert(scenario.event, {
			name = "recruit,recall",
			wml.tag.filter {
				side = side_num
			},
			wml.tag.cc_invest {
			}
		})
	end

	-- generate the map. (this also adds certain events for example to create [item]s or [sound_source]s)
	local mapgen_func = get_map_generator(scenario_data)
	mapgen_func(scenario, nplayers)

	-- set the correct scenario name.
	if scenario_num == 1 then --first map
		scenario.name = "CC_" .. nplayers .. " - " .. _"Start"
	else
		local scenario_desc = _ "Scenario" .. scenario_num
		if scenario_num == 5 then
			scenario_desc = _"Final Battle"
		end
		scenario.name = "CC_" .. nplayers .. " " .. scenario_desc .. " - "--.. scenario.map_name
	end

	local res = cc_convert.lon_to_wml(scenario, "scenario")
	wesnoth.log("info", "[scenario]:\n" .. debug_wml(res))

	for i, v in ipairs(scenario_extra) do
		-- insert music and scedule tags. (these use code wml macros so they are defined in the .cfg file)
		table.insert(res, v)
	end
	return res
end
