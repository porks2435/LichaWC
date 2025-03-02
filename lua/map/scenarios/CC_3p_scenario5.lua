world_conquest_tek_scenario_res(3, 6, 44)
local generators = {
	cc_map_generator("classic", "6a", 75, 23, 10, 17000, 8, 9, 7),
	cc_map_generator("maritime", "6b", 75, 23, 10, 17000, 8, 9, 7),
	cc_map_generator("industrial", "6c", 75, 23, 10, 19125, 7, 9, 7),
	cc_map_generator("feudal", "6d", 75, 23, 10, 17000, 8, 9, 7),
}

local function get_enemy_data(enemy_power)
	return {
		gold = 350,
		bonus_gold = 175,
		sides = {
			cc_enemy(4, 3, 9, 2, 0, 21, "$($cc_difficulty.enemy_power+1)"),
			cc_enemy(5, 2, 8, 0, 0, "$(3+$cc_difficulty.enemy_power*2)", "$($cc_difficulty.enemy_power+2)"),
			cc_enemy(6, 3, 1, 7, 0, "$(3+$cc_difficulty.enemy_power*2)", "$($cc_difficulty.enemy_power+1)"),
			cc_enemy(7, 2, 1, 0, 0, "$(3+$cc_difficulty.enemy_power*2)", "$($cc_difficulty.enemy_power+1)"),
			cc_enemy(8, 2, 0, 2, 1, "$(3+$cc_difficulty.enemy_power*2)", 11),
			cc_enemy(9, 2, 1, 4, 1, 21, "$($cc_difficulty.enemy_power+1)"),
		}
	}
end
return { generators = generators, get_enemy_data = get_enemy_data, turns = 44, player_gold = 375 }
