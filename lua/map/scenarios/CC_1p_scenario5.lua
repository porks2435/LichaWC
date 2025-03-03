world_conquest_tek_scenario_res(1, 6, 56)
local generators = {
	cc_map_generator("classic", "6a", 66, 14, 10, 16320, 8, 7, 7),
	cc_map_generator("maritime", "6b", 66, 14, 10, 16320, 8, 7, 7),
	cc_map_generator("industrial", "6c", 66, 14, 10, 18360, 7, 7, 7),
	cc_map_generator("feudal", "6d", 66, 14, 10, 16320, 8, 7, 7),
}

local function get_enemy_data(enemy_power)
	return {
		gold = 350,
		bonus_gold = 175,
		sides = {
			cc_enemy(4, 3, 9, 2, 0, 14, "$($cc_difficulty.enemy_power-4)"),
			cc_enemy(5, 2, 8, 0, 0, "$($cc_difficulty.enemy_power*2-4)", "$($cc_difficulty.enemy_power-3)"),
			cc_enemy(6, 3, 1, 7, 0, "$($cc_difficulty.enemy_power*2-5)", "$($cc_difficulty.enemy_power-3)"),
			cc_enemy(7, 2, 1, 0, 0, "$($cc_difficulty.enemy_power*2-5)", "$($cc_difficulty.enemy_power-3)"),
			cc_enemy(8, 2, 0, 2, 1, "$($cc_difficulty.enemy_power*2-5)", 7),
			cc_enemy(9, 2, 1, 4, 1, 13, "$($cc_difficulty.enemy_power-3)"),
		}
	}
end
return { generators = generators, get_enemy_data = get_enemy_data, turns = 56, player_gold = 450 }
