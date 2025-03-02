local on_event = wesnoth.require "on_event"
local _ = wesnoth.textdomain 'wesnoth-cc'
local T = wml.tag
local cc_utils = {}

function cc_utils.set_to_array(s, res)
	res = res or {}
	for k,v in pairs(s) do
		table.insert(res, k)
	end
	table.sort( res )
	return res
end


function cc_utils.remove_duplicates(t)
	local found = {}
	for i = #t, 1, -1 do
		local v = t[i]
		if found[v] then
			table.remove(t, i)
		else
			found[v] = true
		end
	end
end

--comma seperated list
function cc_utils.pick_random(str, generator)
	local s2 = wml.variables[str]
	if s2 ~= nil or generator then
		local array = s2 and stringx.split(s2) or {}
		if #array == 0 and generator then
			array = generator()
		end
		local index  = mathx.random(#array)
		local res = array[index]
		table.remove(array, index)
		wml.variables[str] = table.concat(array, ",")
		return res
	end
end

local function filtered_from_array(array, filter)
	local possible_indicies = {}
	for i, v in ipairs(array) do
		if filter(v) then
			table.insert(possible_indicies, i)
		end
	end
	if #possible_indicies == 0 then
		return nil
	end
	local index  = possible_indicies[mathx.random(#possible_indicies)]
	return index
end

function cc_utils.pick_random_filtered(str, generator, filter)
	local s2 = wml.variables[str]
	if s2 == nil and generator == nil then
		return
	end

	local array = s2 and stringx.split(s2 or "") or {}
	if #array == 0 and generator then
		array = generator()
	end
	local index  = filtered_from_array(array, filter)
	if index == nil then
		array = generator()
		index = filtered_from_array(array, filter)
	end
	local res = array[index]
	table.remove(array, index)
	wml.variables[str] = table.concat(array, ",")
	return res
end

--wml array
function cc_utils.pick_random_t(str)
	local size = wml.variables[str .. ".length"]
	if size ~= 0 then
		local index = mathx.random(size) - 1
		local res = wml.variables[str .. "[" ..  index .. "]"]
		wml.variables[str .. "[" ..  index .. "]"] = nil
		return res
	end
end

--like table concat but for tstrings.
function cc_utils.concat(t, sep)
	local res = t[1]
	if not res then
		return ""
	end
	for i = 2, #t do
		-- uses .. so we dont hae to call tostring. so this function can still return a tstring.
		res = res .. sep .. t[i]
	end
	return res
end

function cc_utils.range(a1,a2)
	if a2 == nil then
		a2 = a1
		a1 = 1
	end
	local res = {}
	for i = a1, a2 do
		res[i] = i
	end
	return res
end

function cc_utils.firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end


function cc_utils.facing_each_other(u1,u2)
	u1.facing = wesnoth.map.get_relative_dir(u1.x, u1.y, u2.x, u2.y)
	u2.facing = wesnoth.map.get_relative_dir(u2.x, u2.y, u1.x, u1.y)
	wesnoth.wml_actions.redraw {}
end

function cc_utils.getName(u)
    if #u.name > 1 then
		return u.name
	else
		return tostring(wesnoth.unit_types[u.type].name)
	end
end

function cc_utils.get_heal_ability(u)
    local abilities = wml.get_child(u.__cfg, "abilities")

    --if it's grabbing vanilla unpoison, instead return the second heal ability 
    if not wml.get_child(abilities, "heals").value then
    	return wml.get_nth_child(abilities, "heals", 2)
    end

    return wml.get_child(abilities, "heals")
end

function cc_utils.apply_heal_boost(heal, boost)
    local multiplier = 1+(boost*0.01)
    return math.floor((heal * multiplier) + 0.5)
end

function cc_utils.moved_five_hexes(u)
	return wesnoth.map.distance_between(u.variables["start_loc"],{u.x,u.y}) >= 5
end

function cc_utils.has_no_advances(u)
	return #u.advances_to == 0
end

function cc_utils.has_one_attack(u)
	return #u.attacks == 1
end

function cc_utils.low_resist_filter(u)

	local neg_resists = 0
	local sum_resists = 0

	local resists = {"blade","impact","pierce","fire","cold","arcane"}

	for i=1,#resists do
		if u:resistance_against(resists[i]) < 0 then
			neg_resists = neg_resists + u:resistance_against(resists[i])
		end
		sum_resists = sum_resists + u:resistance_against(resists[i])
	end

	return math.abs(neg_resists) >= 30 and math.abs(neg_resists) > sum_resists
end

function cc_utils.is_an_enemy(u, v)
    if u.side <= wml.variables.cc_player_count then
        return v.side > wml.variables.cc_player_count
    else
        return v.side <= wml.variables.cc_player_count
    end
end

function cc_utils.get_weapon_index(u, str)
    for i=1, #u.attacks do
    	if u.attacks[i].name == str then
    		return i
    	end
    end
    --shouldn't get here, but last resort for semi-functionality, use primary weapon
    return 1
end

function find_special_by_tag(attack,special_tag)
   local specials = wml.get_child(attack, "specials")
   local special = wml.get_child(specials, special_tag)
   return special
end

function cc_utils.grant_random_stats(u, amount)
	local valid_fields = {"hp","xp","mp","melee","ranged","heal_boost"}
	local updated_table = u.variables["stat_bonus"] or {}

	for i=1, amount do
		local rand = mathx.random(#valid_fields)

		if updated_table[valid_fields[rand]] then
			updated_table[valid_fields[rand]] = updated_table[valid_fields[rand]] + 2
		else
			updated_table[valid_fields[rand]] = 2
		end
	end

	u.variables["stat_bonus"] = updated_table
end

function cc_utils.max_parry_defense(u, terrain, parry)

	local defense = u:defense_on(terrain)
	local parry_percent = 1.0 + (parry * 0.01)

	return math.max(10, 100 - (defense * parry_percent))
end

function cc_utils.rebuild_stat_block(u)
	
	local stat_caps = {
		{hp = 50},
		{xp = 50},
		{mp = 50},
		{melee = 50},
		{ranged = 50},
		{strikes = 50},
		{accuracy = 50},
		{parry = 50},
		{heal_boost = 50},
		{heal_range = 3},
	}

	local updated_table = u.variables["stat_bonus"]
	local updated_total = 0

    for key, value in pairs(updated_table) do

    	for _, cap in ipairs(stat_caps) do
	        if cap[key] then
	            if value > cap[key] then
	                updated_table[key] = cap[key]
	            end
	            updated_total = updated_total + value
	            break  
	        end
	    end
    end
	u.variables["stat_bonus"] = updated_table
	u.variables["stat_total"] = updated_total

	if u.variables["stat_bonus"]["heal_boost"] then
		u.status.heal_amp = true
	end

	if u.variables["stat_bonus"]["heal_range"] then
		u.status.heal_amp_range = true
	end
	
	if u.variables["stat_total"] then 
	    if u.variables["stat_total"] > 0 then 

			-- remove existing stat block
			local u_cfg = u.__cfg
		    for i,v in ipairs(wml.get_child(u_cfg, "modifications")) do
		        if v[1] == "object" and v[2].id == "stat_bonus" then
		            u:remove_modifications({id = "stat_bonus"})
		            break
		        end
		    end

		    local hp = updated_table["hp"] or 0
		    local xp = updated_table["xp"] or 0
		    local mp = updated_table["mp"] or 0

		    local melee = updated_table["melee"] or 0
		    local ranged = updated_table["ranged"] or 0
		    local strikes = updated_table["strikes"] or 0
		    local accuracy = updated_table["accuracy"] or 0
		    local parry = updated_table["parry"] or 0

			u:add_modification("object", {
		        id = "stat_bonus",
		        T.effect {
		            apply_to = "hitpoints",
		            increase_total = hp .. "%"
		        },
				T.effect {
		            apply_to = "max_experience",
		            increase = (-1 * xp) .. "%"
		        },
		        T.effect {
		            apply_to = "movement",
		            increase = mp .. "%"
		        },
		        T.effect {
		            apply_to = "attack",
		            range = "melee",
		            increase_damage = melee .. "%"
		        },
		        T.effect {
		            apply_to = "attack",
		            range = "ranged",
		            increase_damage = ranged .. "%"
		        },
		        T.effect {
		            apply_to = "attack",
		            increase_attacks = strikes .. "%",
		        },    
		        T.effect {
	                apply_to = "new_ability",
	                T.abilities {
	                    T.chance_to_hit {
	                        multiply = 1.0 + (accuracy * 0.01),
	                        active_on='offense',
	                        T.filter_attacker{
	                        	T.filter_weapon{
		                        	T["not"]{
		                        		special_id='magical'
		                        	}
		                        }
	                        },
	                        T.filter_opponent{
	                        	T["not"]{
	                        		ability='elusive'
	                        	}
	                        },
	                    },
	                    T.chance_to_hit {
	                        multiply = 1.0 + (accuracy * 0.01),
	                        active_on='defense',
	                        T.filter_defender{
	                        	T.filter_weapon{
		                        	T["not"]{
		                        		special_id='magical'
		                        	}
		                        }
	                        },
	                        T.filter_opponent{
	                        	T["not"]{
	                        		ability='elusive'
	                        	}
	                        },
	                    }
	                }
	            },
	            T.effect {
	                apply_to = "defense",
	                replace = true,
	                T.defense {
	                    fungus = cc_utils.max_parry_defense(u,'Tt',parry),
	                    cave = cc_utils.max_parry_defense(u,'Ut',parry),
	                    deep_water = cc_utils.max_parry_defense(u,'Wdt',parry),
	                    shallow_water = cc_utils.max_parry_defense(u,'Wst',parry),
	                    swamp_water = cc_utils.max_parry_defense(u,'St',parry),
	                    sand = cc_utils.max_parry_defense(u,'Dt',parry),
	                    forest = cc_utils.max_parry_defense(u,'Ft',parry),
	                    flat = cc_utils.max_parry_defense(u,'Gt',parry),
	                    hills = cc_utils.max_parry_defense(u,'Ht',parry),
	                    mountains = cc_utils.max_parry_defense(u,'Mt',parry),
	                    village = cc_utils.max_parry_defense(u,'Vt',parry),
	                    castle = cc_utils.max_parry_defense(u,'Ct',parry),
	                    frozen = cc_utils.max_parry_defense(u,'At',parry),
	                    unwalkable = cc_utils.max_parry_defense(u,'Xt',parry),
	                    reef = cc_utils.max_parry_defense(u,'Wrt',parry),
	                },
	            },
		    })

		    u:transform(u.type)
		end
	end
	
end

cc_utils.global_vars = wesnoth.experimental.wml.global_vars.cc

if rawget(_G, "cc_menu_filters") == nil then
	cc_menu_filters = {}
end

function cc_utils.menu_item(t)
	local id_nospace = string.gsub(t.id, " ", "_")
	local cfg = {}
	on_event("start", function()
		wesnoth.wml_actions.set_menu_item {
			id = t.id,
			description = t.description,
			image = t.image,
			synced = t.synced,
			T.filter_location {
				lua_function="cc_menu_filters." .. id_nospace,
			},
		}
	end)
	if t.handler then
		on_event("menu_item_" .. t.id, t.handler)
	end
	cc_menu_filters[id_nospace] = t.filter
end


function cc_utils.get_fstring(t, key)
	local args = wml.get_child(t, key .. "_data")
	if args then
		args = cc_utils.get_fstring_all(args)
	else
		args = {}
	end
	return stringx.vformat(t[key], args)
end

function cc_utils.get_fstring_all(t)
	local res = {}
	for k,v in pairs(t) do
		res[k] = cc_utils.get_fstring(t, k)
	end
	return res
end

-- populates cc_utils.world_conquest_data, reads [world_conquest_data] from all [resource]s and [era]
function cc_utils.load_cc_data()
	if cc_utils.world_conquest_data == nil then
		local data_dict = {}
		local ignore_list = {}
		for i,resource in ipairs(wesnoth.scenario.resources) do
			local world_conquest_data = wml.get_child(resource, "world_conquest_data")
			if world_conquest_data then
				for ignore in wml.child_range(world_conquest_data, "ignore") do
					ignore_list[ignore.id] = true
				end
				table.insert(data_dict, {id=resource.id, data = world_conquest_data})
			end
		end

		table.insert(data_dict, {id="era", data = wesnoth.scenario.era})


		-- make sure the result does not depend on the order in which these addons are loaded.
		table.sort(data_dict, function(a,b) return a.id<b.id end)


		cc_utils.world_conquest_data = {}
		for i, v in ipairs(data_dict) do
			if not ignore_list[v.id] then
				for i2, tag in ipairs(v.data) do
					local tagname = tag[1]
					cc_utils.world_conquest_data[tagname] = cc_utils.world_conquest_data[tagname] or {}
					table.insert( cc_utils.world_conquest_data[tagname], tag )
				end
			end
		end
	end
end

-- reads the tag @a tagnaem from [world_conquest_data] provided by any of the ressoucrs or eras used in the game.
-- returns a wml table that contains only tagname subtags.
function cc_utils.get_cc_data(tagname)
	cc_utils.load_cc_data()
	--todo: maybe we shoudl clear cc_utils.world_conquest_data[tagname] afterwards ?
	return cc_utils.world_conquest_data[tagname]
end

--knockback
function cc_utils.knockback(knocker,knocked,distance)
	local max_distance = distance or 1
	
	if knocked.valid then
		if knocked.max_moves == 0 then
			return
		end

		local direction = knocked.facing
		if knocker.valid then
			direction = wesnoth.map.get_relative_dir(knocker, knocked)
		end
		local target = wesnoth.map.get(knocked)
		local last_acceptable_target = target
		for distance = 1, max_distance do --luacheck: no unused
			local adj = {};
			adj["n"], adj["ne"], adj["se"], adj["s"], adj["sw"], adj["nw"] = wesnoth.map.get_adjacent_hexes(target)
			local potential_target = adj[direction]
			if wesnoth.current.map:on_board(potential_target) then
				local terrain = wesnoth.map.get(potential_target).terrain
				if knocked:movement_on(terrain) > knocked.max_moves then
					break -- Impassable, can't be knocked through
				end
				local occupier = wesnoth.units.find_on_map{x = potential_target.x, y = potential_target.y}
				if #occupier > 0 then
					break -- occupied by somebody, can't knock through
				end
			else
				break -- Can't be knocked out of the map
			end
			target = potential_target
			local occupier = wesnoth.units.find_on_map{x = potential_target.x, y = potential_target.y}
			if #occupier == 0 then
				last_acceptable_target = potential_target
			end
		end
		knocked:to_map(last_acceptable_target.x, last_acceptable_target.y)
	end
end

--pull
function cc_utils.pull(puller,pulled,distance)
	local max_distance = distance or 1
	
	if puller.valid and pulled.valid then
		if pulled.max_moves == 0 then
			return
		end
		local direction = pulled.facing
		direction = wesnoth.map.get_relative_dir(puller, pulled)

		--invert direction
		local inverted = {
		    n = "s",   -- north -> south
		    nw = "se", -- northwest -> southeast
		    ne = "sw", -- northeast -> southwest
		    s = "n",   -- south -> north
		    sw = "ne", -- southwest -> northeast
		    se = "nw"  -- southeast -> northwest
		}

		direction = inverted[direction]

		local target = wesnoth.map.get(puller)
		local target2 = wesnoth.map.get(pulled)
		local cur_terrain = wesnoth.map.get(pulled).terrain
		if pulled:movement_on(cur_terrain) > pulled.max_moves then
			return
		end

		local last_acceptable_target = target
		local last_acceptable_target2 = target2
		for distance = 1, max_distance do --luacheck: no unused
			local adj = {};
			adj["n"], adj["ne"], adj["se"], adj["s"], adj["sw"], adj["nw"] = wesnoth.map.get_adjacent_hexes(target)
			local potential_target = adj[direction]
			if wesnoth.current.map:on_board(potential_target) then
				local terrain = wesnoth.map.get(potential_target).terrain
				if puller:movement_on(terrain) > puller.max_moves then
					break -- Impassable, can't be pulled through
				end
				local occupier = wesnoth.units.find_on_map{x = potential_target.x, y = potential_target.y}
				if #occupier > 0 then
					break -- occupied by somebody, can't pull through
				end
			else
				break -- Can't be pulled out of the map
			end
			target2 = target
			target = potential_target
			local occupier = wesnoth.units.find_on_map{x = potential_target.x, y = potential_target.y}
			if #occupier == 0 then
				last_acceptable_target2 = last_acceptable_target
				last_acceptable_target = potential_target
			end
		end
		puller:to_map(last_acceptable_target.x, last_acceptable_target.y)
		pulled:to_map(last_acceptable_target2.x, last_acceptable_target2.y)
	end
end

return cc_utils
