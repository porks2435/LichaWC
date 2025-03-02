local _ = wesnoth.textdomain 'wesnoth-cc'
local T = wml.tag
local on_event = wesnoth.require("on_event")

function apply_specials(u,v,active_specials)

	if not active_specials or v.hitpoints < 0 then
		return
	end
	
	if active_specials["poison"] and not v.status.unpoisonable then
		v.status.poisoned = true
    end
    if active_specials["slow"] then
		v.status.slowed = true
    end
    if active_specials["exhaust"] then
		wesnoth.interface.float_label(v.x, v.y, "exhausted", "196,196,128")
	    apply_exhaust(v)
    end
    if active_specials["stun"] then
		wesnoth.interface.float_label(v.x, v.y, "stunned", "196,196,128")
	    apply_stun(v)
    end
    if active_specials["scorch"] then
		wesnoth.interface.float_label(v.x, v.y, "scorched", "196,196,128")
	    apply_scorch(v)
    end
    if active_specials["curse"] then
		wesnoth.interface.float_label(v.x, v.y, "cursed", "196,196,128")
	    apply_curse(v)
    end
    if active_specials["sculpt"] then
		wesnoth.interface.float_label(v.x, v.y, "petrified", "196,196,128")
	    v.variables["stone_duration"] = 2
    end
    if active_specials["sleep"] then
    	if v.variables["sleepy"] then
    		v.variables["sleepy"] = v.variables["sleepy"] + 1
    	else
	    	v.variables["sleepy"] = 1
	    end

	    if v.variables["sleepy"] >= (v.level + 1) then
	    	v.variables["sleepy"] = nil
	    	wesnoth.interface.float_label(v.x, v.y, "sleep", "196,196,128")
		    apply_sleep(v)
	   	end
    end
    if active_specials["delirium"] then
    	if u.level >= v.level and not v:matches {trait = "mechanical", canrecruit = "yes"} then
			wesnoth.interface.float_label(v.x, v.y, "madness", "196,196,128")
		    apply_madness(v, u.side)
		end
    end
    if active_specials["knockback"] then
		if u.variables["to_knockback"] then
	    	u.variables["to_knockback"] = u.variables["to_knockback"] .. "," .. v.id
	    else
	    	u.variables["to_knockback"] = v.id
	    end
    end
end

-- have to do this because special_id_active falls off after harm_unit
function get_active_specials(u)

	local active_specials = {}

	-- status effects
	if u:matches { T.has_attack { special_id_active = "slow_cc"} } then
		active_specials["slow"] = true
    end

    if u:matches { T.has_attack { special_id_active = "poison_cc"} } then
		active_specials["poison"] = true
    end

    if u:matches { T.has_attack { special_id_active = "exhaust"} } then
		active_specials["exhaust"] = true
    end

    if u:matches { T.has_attack { special_id_active = "stun"} } then
    	active_specials["stun"] = true
    end

    if u:matches { T.has_attack { special_id_active = "scorch"} } then
		active_specials["scorch"] = true
    end

    if u:matches { T.has_attack { special_id_active = "curse"} } then
		active_specials["curse"] = true
    end

    if u:matches { T.has_attack { special_id_active = "sculpt"} } then
		active_specials["sculpt"] = true
    end

    if u:matches { T.has_attack { special_id_active = "sleep"} } then
    	active_specials["sleep"] = true
    end

    if u:matches { T.has_attack { special_id_active = "delirium"} } then
		active_specials["delirium"] = true
    end

    --displacement
    if u:matches { T.has_attack { special_type_active = "knockback"} } then
    	active_specials["knockback"] = true
    end

    if u:matches { T.has_attack { special_type_active = "pull"} } then
		active_specials["pull"] = true
    end

    return active_specials
end

function apply_damage(u,v,weapon_index,multiplier,active_specials,force_hit)

	if not v.valid then
		return
	end

	--simulate attack stats
	local a_stats, d_stats, w_stats = wesnoth.simulate_combat(u, weapon_index, v, nil)
   	local d_damage = w_stats.damage
   	local d_accuracy = w_stats.chance_to_hit
   	local d_type = wml.variables["weapon"].type
	local v_xp = v.level * 8
	local v_x = v.x
	local v_y = v.y
	local mult = multiplier or 0.5

	if force_hit then
		d_accuracy = 100
	end

	--roll for accuracy
	if mathx.random(100) < d_accuracy then
		wesnoth.wml_actions.harm_unit {
	        T.filter { id = v.id },
	        T.filter_second { id = u.id },
	        amount = math.floor(d_damage * mult),
	        experience = false,
	        kill = true,
	        animate = true,
	        delay = 25,
	        fire_event = "die"
	    }

	    --give xp if the unit died, won't advance until after combat ends
	    if not wesnoth.units.get(v_x, v_y) then
	    	--wesnoth.interface.add_chat_message("deaded")
	    	u.experience = u.experience + v_xp
	    else
	    	apply_specials(u,v,active_specials)
	    end
	end
end

function apply_aoe_damage(u,v,weapon_index,active_specials)

	-- line damage
	if u:matches { T.has_attack { special_id_active = "line_damage"} } then

	    local direction = u.facing
	    local adj = {};
		adj["n"], adj["ne"], adj["se"], adj["s"], adj["sw"], adj["nw"] = wesnoth.map.get_adjacent_hexes(v.x,v.y)

		local e = wesnoth.units.get(adj[direction][1], adj[direction][2])

	    if e then
	    	if cc_utils.is_an_enemy(u, e) then
	   	    	apply_damage(u,e,weapon_index,0.5,active_specials)
		    end
		end

		adj["n"], adj["ne"], adj["se"], adj["s"], adj["sw"], adj["nw"] = wesnoth.map.get_adjacent_hexes(adj[direction][1],adj[direction][2])

		local e2 = wesnoth.units.get(adj[direction][1], adj[direction][2])
		if e2 then
	    	if cc_utils.is_an_enemy(u, e2) then
	    		apply_damage(u,e2,weapon_index,0.5,active_specials)
		    end
		end
    end

    -- arc damage
    if u:matches { T.has_attack { special_id_active = "arc_damage"} } then
		local victims = wesnoth.units.find_on_map { { "filter_adjacent", { id = u.id, is_enemy = "yes"} }, { "filter_adjacent", { id = v.id} } }
		if #victims >= 1 then -- skip if only the target
            for _, e in ipairs(victims) do   
                apply_damage(u,e,weapon_index,0.5,active_specials)
            end
        end
    end

    -- blast damage
    if u:matches { T.has_attack { special_id_active = "blast_damage"} } then
		local victims = wesnoth.units.find_on_map { { "filter_adjacent", { id = v.id, is_enemy = "no"} } }
		if #victims > 0 then -- skip if only the target
            for _, e in ipairs(victims) do   
                if cc_utils.is_an_enemy(u, e) then
                    apply_damage(u,e,weapon_index,0.3,active_specials)
			    end
            end
        end
    end

    -- radial damage
    if u:matches { T.has_attack { special_id_active = "radial_damage"} } then
		local victims = wesnoth.units.find_on_map { { "filter_adjacent", { id = u.id, is_enemy = "yes"} } }
		if #victims > 0 then -- skip if only the target
            for _, e in ipairs(victims) do   
            	if e ~= v and cc_utils.is_an_enemy(u, e) then
	                apply_damage(u,e,weapon_index,0.3,active_specials)
            	end
            end
        end
    end
    
end

function apply_on_hit(u,v,weapon_index,active_specials,damage_inflicted)

	-- effects that cancel out everything else below
	if v then
		-- remove ward
		if v.status.warded and v.hitpoints > 0 then
			v.hitpoints = v.hitpoints + damage_inflicted
			v:remove_modifications({ id = "warded_instance" })
			v.status.warded = false
			return
		end
		-- remove illusion
		if v.status.illusion then
			v:remove_modifications({ id = "illusion_instance" })
			v.status.illusion = false
		end
		-- remove sleep
		if v.status.sleep and not active_specials["sleep"] then
			v:remove_modifications({ id = "sleep_instance" })
			v.status.sleep = false
			v.status.sleep_resist = true
		end
		-- benediction heal
	    if v.variables["benediction"] and v.hitpoints <= v.max_hitpoints/3 and v.hitpoints > 0 then
			local heal_amount = mathx.round(v.max_hitpoints * (v.variables["benediction"] / 100.0))
        	v.hitpoints = math.min(v.max_hitpoints, v.hitpoints + heal_amount)
		    v.status.benediction = false
		    v.variables["benediction"] = nil
		    v:remove_modifications({ id = "benediction_instance" })
	    end
	    -- undead-heal
	    if v:matches { ability = "oversoul" } then
	    	local allies = wesnoth.units.find_on_map { { "filter_adjacent", { id = v.id, is_enemy = "no"} }, trait = "undead" }
	    	if #allies > 0 then
		    	local bonus_heal = 0
		    	if u.status.heal_amp then
	    			bonus_heal = u.variables["stat_bonus"]["heal_boost"]
		    	end
				local heal_amount = cc_utils.apply_heal_boost(damage_inflicted/3,bonus_heal)
	        	
	        	for __, ux in ipairs(allies) do   
	        		ux.hitpoints = math.min(ux.max_hitpoints, ux.hitpoints + heal_amount)
	        	end
	        end
	    end
		-- vengeance
	    if u:matches { T.has_attack { special_id_active = "vengeance"} } then
	    	u.variables["vengeance"] = nil
	    end
	    if v:matches { T.has_attack { special_id = "vengeance"} } then
	    	if v.variables["vengeance"] then
	    		v.variables["vengeance"] = v.variables["vengeance"] + mathx.round(damage_inflicted/2)	    		
	    	else
	    		v.variables["vengeance"] = mathx.round(damage_inflicted/2)
	    	end
	    end
		-- reflect magic: nulls the rest
	    if v:matches { T.has_attack { special_id_active = "reflect_magic"} } then
	    	wesnoth.wml_actions.harm_unit {
		        T.filter { id = v.id },
		        T.filter_second { id = u.id },
		        amount = mathx.round(damage_inflicted * 0.8),
		        experience = false,
		        kill = true,
		        animate = true,
		        delay = 25,
		        fire_event = "die"
		    }
			apply_specials(u,u,active_specials)
		    return
	    end
		-- scorpion call: summons a friendly monster.
	    if u:matches { T.has_attack { special_id_active = "call_scorpion"} } then
	        -- standard land monster list
	        local x2,y2 = wesnoth.paths.find_vacant_hex(v.x, v.y, v)

	        local beast_roll = mathx.random(100)
	        local beast_type = ""

	        if beast_roll <= 3 then
	            beast_type = "Queen of the Dunes"
	        elseif beast_roll <= 15 * u.level then
	            beast_type = "Dune Reaver"
	        elseif beast_roll <= 30 * u.level then
	            beast_type = "Dune Scorpion"
	        else
	            beast_type = "Dune Stinger"
	        end

	        local u2 = wesnoth.units.create {
	            type = beast_type,
	            side = u.side,
	            random_traits = true
	        }
	        for i=1,u2.level do
		        cc_training.apply(u2)
		    end
	        u2:to_map(x2,y2)
	        apply_damage(u2,v,1,1,nil,true)
	        if v then
		        wesnoth.wml_actions.harm_unit {
			        T.filter { id = v.id },
			        T.filter_second { id = u2.id },
			        amount = 0,
			        poisoned = true
			    }
			end
	        u2:add_modification('object', {
	            duration = 'forever',
	            T.effect {
	                apply_to = "new_ability",
	                T.abilities {
	                    T.dummy {
	                        id = "do_not_recall",
	                    }
	                }
	            }
	        })
	    end
	    -- reprisal: offload all strikes
	    if u:matches { T.has_attack { special_id_active = "reprisal"} } and not u:matches {ability = "post_reprisal"} then
		   	for attacks=2,u.attacks[weapon_index].number do
		    	apply_damage(u,v,weapon_index,1,active_specials)
		    	apply_aoe_damage(u,v,weapon_index,active_specials)		        
	        end
	        if v.valid then
		        u:add_modification('object', {
		            duration = 'turn end',
		            id = 'reprisal_instance',
		            T.effect {
		                apply_to = "new_ability",
		                T.abilities {
		                	id = post_reprisal,
		                    T.chance_to_hit {
		                        value = 0,
		                    }
		                }
		            }
		        })
		    end
		end
	end
	-- effects that don't require enemy
	if u:matches { T.has_attack { special_type_active = "knockback"} } then
		u.variables["knockback"] = true
	end
	if u:matches { T.has_attack { special_type_active = "pull"} } then
		u.variables["pull"] = true
	end
	-- drain boost: increase by heal_boost%
	if (u:matches { T.has_attack { special_id_active = "drains"} } or u:ability("curse_drain")) then
		if not v:matches { status = "undrainable" } then
			if u.variables["stat_bonus"] then
				if u.variables["stat_bonus"]["heal_boost"] then			
					local drain_amount = math.floor(damage_inflicted/2 * (u.variables["stat_bonus"]["heal_boost"] * .01))
					u.hitpoints = math.min(u.hitpoints + drain_amount, u.max_hitpoints)
				end
			end
		end
	end
	apply_specials(u,v,active_specials)
	apply_aoe_damage(u,v,weapon_index,active_specials)
end

on_event("attacker_hits", function(ec)
	local u = wesnoth.units.get(ec.x1, ec.y1)
	local v = wesnoth.units.get(ec.x2, ec.y2)

	if not u then
		return
	end

	local weapon_index = cc_utils.get_weapon_index(u,ec[2][2].name)
	local active_specials = get_active_specials(u)
	local damage_inflicted = ec.damage_inflicted
	apply_on_hit(u,v,weapon_index,active_specials,damage_inflicted)
end)

on_event("defender_hits", function(ec)
	local v = wesnoth.units.get(ec.x1, ec.y1)
	local u = wesnoth.units.get(ec.x2, ec.y2)

	if not u then
		return
	end

	local weapon_index = cc_utils.get_weapon_index(u,ec[3][2].name)
	local active_specials = get_active_specials(u)
	local damage_inflicted = ec.damage_inflicted
	apply_on_hit(u,v,weapon_index,active_specials,damage_inflicted)
end)

on_event("attacker_misses", function(ec)
	local u = wesnoth.units.get(ec.x1, ec.y1)
	local v = wesnoth.units.get(ec.x2, ec.y2)

	if not u then
		return
	end

	local weapon_index = cc_utils.get_weapon_index(u,ec[2][2].name)
	local active_specials = get_active_specials(u)
	apply_aoe_damage(u,v,weapon_index,active_specials)

	--riposte: deal damage on enemy miss
    if v:matches { T.has_attack { special_id = "riposte"} } then
        local weapon_index = cc_utils.get_weapon_index(v,ec[3][2].name)
        apply_damage(v,u,weapon_index,0.5,active_specials)
    end

end)

on_event("defender_misses", function(ec)
	local v = wesnoth.units.get(ec.x1, ec.y1)
	local u = wesnoth.units.get(ec.x2, ec.y2)

	if not u then
		return
	end

	local weapon_index = cc_utils.get_weapon_index(u,ec[3][2].name)
	local active_specials = get_active_specials(u)
	apply_aoe_damage(u,v,weapon_index,active_specials)

    -- reprisal: offload all strikes
    if u:matches { T.has_attack { special_id_active = "reprisal"} } and not u:matches {ability = "post_reprisal"} then
	   	for attacks=2,u.attacks[weapon_index].number do
	    	apply_damage(u,v,weapon_index,1,active_specials)
	    	apply_aoe_damage(u,v,weapon_index,active_specials)		        
        end
        if v.valid then
	        u:add_modification('object', {
	            duration = 'turn end',
	            id = 'reprisal_instance',
	            T.effect {
	                apply_to = "new_ability",
	                T.abilities {
	                	id = post_reprisal,
	                    T.chance_to_hit {
	                        value = 0,
	                    }
	                }
	            }
	        })
	    end
	end

end)