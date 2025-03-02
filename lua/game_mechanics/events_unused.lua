
function apply_command_lifetaker(u)
    u:add_modification('object', {
        duration = 'turn end',
        T.effect {
            apply_to = "new_ability",
            T.abilities { T.dummy { id = "lifetaker" } }
        },
        T.effect{ apply_to = 'status', add = 'mentored' }
    })
end

function apply_command_skilltaker(u)
    u:add_modification('object', {
        duration = 'turn end',
        T.effect {
            apply_to = "new_ability",
            T.abilities { T.dummy { id = "skilltaker" } }
        },
        T.effect{ apply_to = 'status', add = 'mentored' }
    })
end

function apply_command_speedtaker(u)
    u:add_modification('object', {
        duration = 'turn end',
        T.effect {
            apply_to = "new_ability",
            T.abilities { T.dummy { id = "speedtaker" } }
        },
        T.effect{ apply_to = 'status', add = 'mentored' }
    })
end

function apply_command_xptaker(u)
    u:add_modification('object', {
        duration = 'turn end',
        T.effect {
            apply_to = "new_ability",
            T.abilities { T.dummy { id = "xptaker" } }
        },
        T.effect{ apply_to = 'status', add = 'mentored' }
    })
end


-- damage event

    -- fury: heal back up immediate damage taken
    if u:matches {status = "fury"} then
        if u.variables["fury_gauge"] > 0 then
            local heal_amount = math.max(math.round(ec.damage_inflicted/2 * (u.variables["stat_bonus"]["heal_boost"] * .01)),u.variables["fury_gauge"])
            u.variables["fury_gauge"] = u.variables["fury_gauge"] - heal_amount
            u.hitpoints = math.max(u.hitpoints + heal_amount, u.max_hitpoints)
        end
    end

    -- sets the healable amount
    if v:matches {status = "fury"} then
        v.variables["fury_gauge"] = ec.damage_inflicted
    end





    -- misfortune: hits allies and enemies with vuln debuff
    local kodamas = wesnoth.units.find_on_map { ability = "misfortune", side = wesnoth.current.side }
    
    for i, kodama in ipairs(kodamas) do
        local units = wesnoth.units.find_on_map { { "filter_adjacent", { id = kodama.id } } }

        if #units > 0 then -- don't divide by zero and skip if nothing adjacent
            wesnoth.interface.scroll_to_hex(kodama.x, kodama.y)
            for i, u in ipairs(units) do
                apply_vulnerable(u)
            end
        end
    end





    -- lifetaker: +LVL% HP
    if u_killer:matches { ability = "lifetaker" } then
        local stat_table = cc_utils.verify_stat_block(u_killer)
        stat_table[1] = stat_table[1] + u_victim.level
        u_killer.variables["stat_bonus"] = table.concat(stat_table, ",")
        cc_utils.rebuild_stat_block(u_killer)
    end

    -- speedtaker: +LVL% MP
    if u_killer:matches { ability = "speedtaker" } then
        local stat_table = cc_utils.verify_stat_block(u_killer)
        stat_table[3] = stat_table[3] + u_victim.level
        u_killer.variables["stat_bonus"] = table.concat(stat_table, ",")
        cc_utils.rebuild_stat_block(u_killer)
    end

    -- xptaker: +25% XP to bonus XP
    if u_killer:matches { ability = "xptaker" } then
        local side = wesnoth.sides[u_killer.side]
        side.variables["bonus_XP"] = side.variables["bonus_XP"] + (2 * u_victim.level)
    end

    -- paragon: +50% on kill
    if u_killer:matches { ability = "paragon" } then
        u_killer.experience = u_killer.experience + (4 * u_victim.level)
        u_killer:advance(true, true)
    end


    -- recycle: +3g on death
    if u_victim:matches { trait = "recyclable" } then

        local side = wesnoth.sides[u_victim.side]
        side.gold = side.gold + 3
        wesnoth.interface.float_label(ec.x2, ec.y2, "recycled: +3g", "120,120,0")
    end

-- obsession: +1 max HP to adjacent allies
on_event("die", function(ec)

    if not ec.x1 or not ec.y1 or not ec.x2 or not ec.y2 then
        return
    end

    local u_victim = wesnoth.units.get(ec.x1, ec.y1)

    if not u_victim then
        return
    end

    if u_victim:matches { trait = "obsession" } then

        local allies = wesnoth.units.find_on_map { { "filter_adjacent", { id = u_victim.id , is_enemy = "no"} } }
        
        for j, u in ipairs(allies) do 
            if u:matches { trait = "obsession"} then 
                local u_cfg = u.__cfg
                local has_absorbed = false
                for i,v in ipairs(wml.get_child(u_cfg, "modifications"))do
                    if v[1] == "object" and v[2].absorbed == true then
                        local effect = wml.get_child(v[2], "effect")
                        effect.increase_total = effect.increase_total + 1
                        wesnoth.units.to_map(u_cfg)
                        u:transform(u.type)
                        has_absorbed = true
                        u.variables["absorbed"] = u.variables["absorbed"] + 1
                    end
                end

                if not has_absorbed then
                    -- reaching this point means that the unit didn't have the stacking object yet.
                    u:add_modification("object", {
                        absorbed = true,
                        T.effect {
                            apply_to = "hitpoints",
                            increase_total = 1,
                        },
                    })
                    u:transform(u.type)
                    u.variables["absorbed"] = 1
                end
            end
        end     
    end
end)


-- refurbished implementation
on_event("last breath", function(ec)
    local u = wesnoth.units.get(ec.x1, ec.y1)

    if not u then
        return
    end

    if u:matches { ability = "refurbish" } then
        if not u:matches { status = "refurbished" } then
            u.hitpoints=0
            wesnoth.wml_actions.heal_unit {
                T.filter { id = u.id },
                amount = u.max_hitpoints/4,
                animate = true,
                restore_status = false
            }
            u.max_hitpoints = u.max_hitpoints/2
            apply_refurbished(u)
        end
    elseif u:matches { ability = "guts" } and u:matches { status = "guts" } then
        u.hitpoints=0
        wesnoth.wml_actions.heal_unit {
            T.filter { id = u.id },
            amount = 1,
            animate = true,
            restore_status = false
        }
        u:remove_modifications({ id = "guts_instance" })
        u.status.guts = false
    elseif u:matches {ability = "cheat_death"} then
        u:to_recall()
    end


end)


  -- yokai obsession
  if u:matches { trait = "obsession" } then
    if u.variables["absorbed"] then
      if u.max_hitpoints >= 100 and u:matches { ability = "soul_materialization"} then
        table.insert(s, { "element", {
          image = "status/info.png",
          tooltip = _"Has absorbed the souls of " .. u.variables["absorbed"] .. " yokai allies. Having absorbed so many power, this yokai deals +40% damage." 
        } })
      else
        table.insert(s, { "element", {
          image = "status/info.png",
          tooltip = _"Has absorbed the souls of " .. u.variables["absorbed"] .. " yokai allies." 
        } })
      end
    end
  end
