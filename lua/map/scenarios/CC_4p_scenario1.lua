world_conquest_tek_scenario_res(4, 1, 23)
local generators = {
	cc_map_generator("classic", "1a", 40, 20, 5, 9000, 3, 5, 2),
}

local function get_enemy_data(enemy_power)
	return {
		gold = 300,
		bonus_gold = 150,
		sides = {
			cc_enemy(5, 1, 0, 0, 0, 4, 0),
		}
	}
end
return { generators = generators, get_enemy_data = get_enemy_data, turns = 23, player_gold = 100 }

-- [[
-- cc_enemy, 7 Werte
--  1-2 cc_enemy_group_recall
--  3-5 cc_enemy_group_commander
--   6  cc_enemy_group_leader
-- ]]


-- [[
-- cc_map_generator
-- VORLETZTER WERT = ANZAHL DER SPIELERSEITEN (PARTEIEN)


--]]
