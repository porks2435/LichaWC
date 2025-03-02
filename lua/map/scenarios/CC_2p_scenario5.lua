world_conquest_tek_scenario_res(2, 6, 50)
local generators = {
	cc_map_generator("classic", "6a", 71, 19, 10, 16660, 8, 8, 7),
	cc_map_generator("maritime", "6b", 71, 19, 10, 16660, 8, 8, 7),
	cc_map_generator("industrial", "6c", 71, 19, 10, 18742, 7, 8, 7),
	cc_map_generator("feudal", "6d", 71, 19, 10, 16660, 8, 8, 7),
}

local function get_enemy_data(enemy_power)
	return {
		gold = 350,
		bonus_gold = 175,
		sides = {
			cc_enemy(4, 3, 9, 2, 0, 18, "$($cc_difficulty.enemy_power-2)"),
			cc_enemy(5, 2, 8, 0, 0, "$($cc_difficulty.enemy_power*2-1)", "$($cc_difficulty.enemy_power-0)"),
			cc_enemy(6, 3, 1, 7, 0, "$($cc_difficulty.enemy_power*2-1)", "$($cc_difficulty.enemy_power-1)"),
			cc_enemy(7, 2, 1, 0, 0, "$($cc_difficulty.enemy_power*2-1)", "$($cc_difficulty.enemy_power-1)"),
			cc_enemy(8, 2, 0, 2, 1, "$($cc_difficulty.enemy_power*2-1)", 9),
			cc_enemy(9, 2, 1, 4, 1, 17, "$($cc_difficulty.enemy_power-1)"),
		}
	}
end
return { generators = generators, get_enemy_data = get_enemy_data, turns = 50, player_gold = 400 }
