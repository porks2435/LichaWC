local _ = wesnoth.textdomain 'wesnoth-cc'
local on_event = wesnoth.require("on_event")

local strings = {
	enemy_pet = _ "$name|'s pet"
}
-- in the later scenarios there is a small chance that a scenario will be themed for an enemy
-- which means in paticular changing the castle of the enemy accorign to the unit type of that
-- enemy, and giving him an extra unit.
local function cc_map_enemy_themed(race, pet, castle, village, chance)
	if mathx.random(100) > chance then
		return
	end
	local boss = wesnoth.units.find_on_map {
		side="4,5,6,7,8,9",
		canrecruit=true,
		race=race,
		-- human means only outlaw
		wml.tag["not"] {
			race="human",
			wml.tag["not"] {
				wml.tag.filter_wml {
					alignment="chaotic",
				}
			}
		}

	}
	boss = boss[1]
	if boss == nil then
		return
	end
	--give themed castle
	wesnoth.current.map[boss] = wesnoth.map.replace_base("K" .. castle)
	wesnoth.wml_actions.terrain {
		terrain="C" .. castle,
		wml.tag["and"] {
			terrain = "C*,*^C*",
			wml.tag["and"] {
				wml.tag.filter {
					x=boss.x,
					y=boss.y,
				},
				radius=999,
				wml.tag.filter_radius {
					terrain="K*^*,C*^*,*^K*,*^C*"
				},
			},
		},
	}
	local elvish_castle = wesnoth.map.find {
		terrain="Cv",
		wml.tag.filter_adjacent_location {
			terrain="Kv^*"
		}
	}
	-- extra tweak with trees to elvish castle
	for i, tile in ipairs(elvish_castle) do
		if mathx.random(10) <= 4 then
			wesnoth.current.map[tile] = "Cv^Fet"
		end
	end
	-- adjacent themed villages
	wesnoth.wml_actions.terrain {
		terrain=village,
		wml.tag["and"] {
			terrain="*^V*",
			wml.tag.filter_adjacent_location {
				terrain="C" .. castle .. ",K" .. castle .. "^*",
			},
		},
	}
	-- give pet
	local u = wesnoth.wml_actions.unit {
		x = boss.x,
		y = boss.y,
		type=pet,
		side = boss.side,
		name= stringx.vformat(strings.enemy_pet, { name = boss.name }),
		role = "hero",
		overlays = "misc/hero-icon.png",
		wml.tag.modifications {
			cc_heroes.trait_heroic,
			cc_heroes.trait_expert
		}
	}
	cc_heroes.heroize(u)
	cc_heroes.heroize(u)
end

function wesnoth.wml_actions.cc_enemy_themed(cfg)
	cc_map_enemy_themed(cfg.race, cfg.pet, cfg.castle, cfg.village, cfg.chance)
end
