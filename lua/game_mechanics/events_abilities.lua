local _ = wesnoth.textdomain 'wesnoth-cc'
local T = wml.tag
local on_event = wesnoth.require("on_event")


----- removes temporary units from recall lists -----
on_event("start", function(ec)
    wesnoth.wml_actions.kill {
        x="recall",
        y="recall",
        ability="do_not_recall",
        fire_event= false,
        animate = false,
    }

    local units = wesnoth.units.find{}
    for _, u in ipairs(units) do
        u.status.idled = false
        u.variables["idle_count"] = nil
        u.variables["pursuit_attacks"] = nil
        u.status.exhausted = false
        u.status.targeted = false
        u.status.stunned = false
        u.status.vulnerable = false
        u.status.cursed = false
        u.status.fear = false
        u.status.recall = nil
        u.status.sleep = nil
        u.status.sleep_resist = nil
        u.variables["beacon"] = nil
        u.status.rallied = false
        u.status.warded = false
        u.status.zeal = false
        u.status.illusion = false
        u.status.benediction = false
        u.variables["benediction"] = nil
    end
end)

----- the 'haste' ability implementation -----
on_event("recruit,recall", -1, function(ec)
    local u = wesnoth.units.get(ec.x1, ec.y1)
    if not u then
        return
    end
    
    if u:matches {status = "haste"} then
        u.attacks_left = 1
        u.moves = u.max_moves
    end
end)

----- to catch plague events -----
on_event("unit placed", function(ec)
    local u = wesnoth.units.get(ec.x1, ec.y1)

    if u:matches {T.has_attack { special_id = "charge"}} then
        u:add_modification('object', {
            duration = 'forever',
            T.effect{
                apply_to = "attack",
                special_id = "charge",
                remove_specials = "charge",
                T.set_specials {
                    mode = "append",
                    T.damage{
                        id = "charge_cc",
                        multiply = 2,
                        name = "charge",
                        description = "When used offensively, the user deals and takes double damage and restores half of maximum movement if this unit has moved at least 5 hexes beforehand. The hexes at which charge is enabled can be viewed through a right-click menu option.",
                        active_on="offense",
                        apply_to="both",
                        T.filter_self{
                            lua_function = "cc_utils.moved_five_hexes"
                        }
                    }
                }
            }
        })
        u.variables["start_loc"] = {x=u.x, y=u.y}
    end

    if u:matches {T.has_attack { special_id = "charge_cc"}} then
        u.variables["start_loc"] = {x=u.x, y=u.y}
    end
end)


----- terrain events -----
on_event("new turn", function()

    -- filter for unit with terrain link
    local terrain_linked_units = wesnoth.units.find_on_map { ability = "terrain_link" }

    -- set up a for loop
    for i, u in ipairs(terrain_linked_units) do

        -- check for the terrain
        if wesnoth.map.matches(u.x, u.y, { terrain = "A*^*,Ha*^*,Ms*^*" }) then
            -- Frost - Snow/Ice
            u:add_modification("object", { id="terrain_link_frost", T.effect{ apply_to = "variation", name = "frost" } })
        elseif wesnoth.map.matches(u.x, u.y, { terrain = "S*^*,Chs*^*" }) then
            -- Swamp-whirlpool - Swampwater/Quagmire
            u:add_modification("object", { id="terrain_link_swamp", T.effect{ apply_to = "variation", name = "swamp" } })
        elseif wesnoth.map.matches(u.x, u.y, { terrain = "W*^*,Chw*^*,Cm*^*,Km*^*" }) then
            -- Whirlpool - Water/Deepwater/Fords
            u:add_modification("object", { id="terrain_link_whirlpool", T.effect{ apply_to = "variation", name = "whirlpool"} })
        elseif wesnoth.map.matches(u.x, u.y, { terrain = "Ql*^*,Mv*^*,D*^*,Hd*^*,Mdd*^*" }) then
            -- SandStorm - Desert/Sand/Dunes
            u:add_modification("object", { id="terrain_link_sandstorm", T.effect{ apply_to = "variation", name = "sandstorm" } })
        elseif wesnoth.map.matches(u.x, u.y, { terrain = "M*^*,Xu*^*,H*^*,Uh*^*,Uu^*,*^Dr" }) then
            -- Rock - Mountains/Hills/Caves
            u:add_modification("object", { id="terrain_link_quake", T.effect{ apply_to = "variation", name = "quake"} })
        elseif wesnoth.map.matches(u.x, u.y, { terrain = "*^F*,Tb*^*,*^Tf*,*^Gvs, *^Efm" }) then
            -- Bramble - Forests
            u:add_modification("object", { id="terrain_link_bramble", T.effect{ apply_to = "variation", name = "bramble" } })
        else
            -- Base - flat/castle/keeps/village
            u:add_modification("object", { id="terrain_link_base", T.effect{ apply_to = "variation", name = "tornado" } })
        end
    end
end)

----- post advance XP and variable setting -----
on_event("post advance", function(ec)

    local u = wesnoth.units.get(ec.x1, ec.y1)
    if not u then
        return
    end

    -- clockwork build
    if u:matches {ability = "clockwork_build" } and not u.variables["clockwork_built"] then
        local level_1 = {"Clockwork Automata"}
        local level_2 = {"Clockwork Secutor","Clockwork Salvager","Clockwork Ballista"}
        local level_3 = {"Clockwork Centurion"}
        local level_4 = {"Clockwork Dragon"}
        
        local build_roll = mathx.random(100)
        local build_type = ""

        if build_roll <= 1 then
            build_type = "Clockwork Dragon"
        elseif build_roll <= 5 * u.level then
            build_type = "Clockwork Centurion"
        elseif build_roll <= 15 * u.level then
            build_type = level_2[mathx.random(#level_2)]
        else
            build_type = level_1[mathx.random(#level_1)]
        end

        local u2 = wesnoth.units.create {
            type = build_type,
            side = u.side,
            random_traits = true
        }
        cc_training.apply(u2)
        local x2,y2 = wesnoth.paths.find_vacant_hex(u.x, u.y, u2)
        u2:to_map(x2,y2)
        u.variables["clockwork_built"] = true
    end
    -- set max XP to LVL*50 if relevant
    if #u.advances_to == 0 and u.max_experience > (50 * u.level) then
        u.max_experience = 50 * u.level
        u:advance(true, true)
    end

    -- remove traits on advance
    if u.type=="Centaur Draugr" then
        wesnoth.remove_modifications(u, {id = "strong"}, "trait")
        wesnoth.remove_modifications(u, {id = "resilient"}, "trait")
        wesnoth.remove_modifications(u, {id = "quick"}, "trait")
        wesnoth.remove_modifications(u, {id = "intelligent"}, "trait")
    end

    -- start tracking moveranges if aren't already
    if u:matches {T.has_attack { special_id = "charge_cc"}} and not u.variables["start_loc"] then
        u.variables["start_loc"] = {x=u.x, y=u.y}
    end


end)

----- preheals and status effects -----
on_event("side turn", function(ec)
    
    -- teleport out 
    if wesnoth.current.turn == (1 + cc_scenario.scenario_num()) then
        local side = wesnoth.sides[wesnoth.current.side]
        if side.variables["teleport"] then
            cc_invest.do_teleport(side.variables["teleport"])
        end
    end

    -- scorched - deal 15% max HP damage unless next to healer/village/water
    local scorched_units = wesnoth.units.find_on_map { status = "scorched", side = wesnoth.current.side }

    for i, u in ipairs(scorched_units) do
        local allies = wesnoth.units.find_on_map { { "filter_adjacent", { id = u.id , is_enemy = "no" } } }
        local healer_present = false

        for _, healer in ipairs(allies) do
            if healer:matches { ability_type = "heals" } then
                healer_present = true
            end
        end
        if wesnoth.map.matches(u.x, u.y, { terrain = "*^V*,W*^*,Chw*^*,Cm*^*,Km*^*,S*^*,Chs*^*" }) or healer_present then
            u:remove_modifications({ id = "scorched_instance" })
            u.status.scorched = false
        else
            wesnoth.wml_actions.harm_unit {
                T.filter { id = u.id },
                amount = math.floor(u.max_hitpoints * 0.15),
                kill = true,
                animate = true,
                delay = 25
            }
        end
    end

    -- petrified - 2 turns then slowed
    local petrified_units = wesnoth.units.find_on_map { status = "petrified", side = wesnoth.current.side }

    for _, u in ipairs(petrified_units) do
        u.variables["stone_duration"] = u.variables["stone_duration"] - 1

        if u.variables["stone_duration"] == 0 then
            wesnoth.wml_actions.unpetrify { T.filter { id = u.id }}
            wesnoth.wml_actions.harm_unit { T.filter { id = u.id }, amount = 0, slowed = true }
        end
    end

    -- sleep - 2 turns
    local sleeping_units = wesnoth.units.find_on_map { status = "sleep", side = wesnoth.current.side }

    for _, u in ipairs(sleeping_units) do
        u.variables["sleep_duration"] = u.variables["sleep_duration"] - 1

        if u.variables["sleep_duration"] == 0 then
            u.variables["sleep_duration"] = nil
            u.status.sleep = false
            u:remove_modifications({ id = "sleep_instance" })
        end
    end

    -- sleep_resist
    local sleeping_units = wesnoth.units.find_on_map { status = "sleep_resist", side = wesnoth.current.side }

    for _, u in ipairs(sleeping_units) do
        u.status.sleep_resist = false
    end

    -- madness - revert control
    local mad_units = wesnoth.units.find_on_map { status = "madness", side = wesnoth.current.side }

    for _, u in ipairs(mad_units) do
        u.side = u.variables["madness"]
        u.status.madness = false
    end

    -- preheal
    local units = wesnoth.units.find_on_map { side = wesnoth.current.side }

    --get pre-heal numbers
    for _, u in ipairs(units) do
        u.variables["preheal"] = u.hitpoints
        if u:matches {status = "poisoned"} then
            u.variables["was_poisoned"] = true
        else
            u.variables["was_poisoned"] = nil
        end
    end

end)


--turn refresh abilities
on_event("turn_refresh", function(ec)

    --buffs expire
    local buffed_units = wesnoth.units.find_on_map { status = "rallied,zeal,warded,illusion", side = wesnoth.current.side }
    for _, u in ipairs(buffed_units) do
        u.status.rallied = false
        u.status.warded = false
        u.status.zeal = false
        u.status.illusion = false
    end
    
    -- time of day effects
    local time = wesnoth.schedule.get_time_of_day(nil, wesnoth.current.turn)

    -- apply aoe heals
    local aoe_healers = wesnoth.units.find_on_map { ability_type = "heals", side = wesnoth.current.side }

    for _, h in ipairs(aoe_healers) do

        if not h.status.heal_amp then
            break
        end

        local heal_ability = cc_utils.get_heal_ability(h)
        local heal_radius = heal_ability.range or 0

        if h.status.heal_amp_range then
            heal_radius = heal_radius + h.variables["stat_bonus"]["heal_range"]
        end
        
        local allies = wesnoth.units.find_on_map { { "filter_location", { x = h.x, y = h.y, radius = heal_radius } } }

        if #allies > 0 then

            local bonus_heal = h.variables["stat_bonus"]["heal_boost"] or 0
            local heal_value = cc_utils.apply_heal_boost(heal_ability.value,bonus_heal)
            local filter = wml.get_child(wml.get_child(heal_ability, "affect_adjacent"), "filter")

            for __, u in ipairs(allies) do   
                local matches_filter = (not filter) or u:matches(filter)
                if not cc_utils.is_an_enemy(h, u) and h.id ~= u.id and matches_filter and not u.variables["was_poisoned"] then     
                    local heal_amount = math.max(0, heal_value - (u.hitpoints - u.variables["preheal"]))

                    wesnoth.wml_actions.heal_unit {
                        T.filter { id = u.id },
                        amount = heal_amount,
                        animate = true,
                        restore_status = false
                    }
                end
            end
        end
    end

    -- apply boosted regens
    local regen_units = wesnoth.units.find_on_map { ability_type = "regenerate", side = wesnoth.current.side }

    for _, h in ipairs(regen_units) do

        if not h.status.heal_amp then
            break
        end

        local regen_ability = wml.get_child(wml.get_child(h.__cfg, "abilities"), "regenerate")
        local filter = wml.get_child(regen_ability, "filter")
        local matches_filter = (not filter) or h:matches(filter)

        if matches_filter then
            local bonus_heal = h.variables["stat_bonus"]["heal_boost"]
            local heal_value = cc_utils.apply_heal_boost(regen_ability.value,bonus_heal)
            local heal_amount = math.max(0, heal_value - (h.hitpoints - h.variables["preheal"]))

            wesnoth.wml_actions.heal_unit {
                T.filter { id = h.id },
                amount = heal_amount,
                animate = true,
                restore_status = false
            }
        end
    end

    -- apply aoe heals
    local aoe_healers = wesnoth.units.find_on_map { ability_type = "benediction", side = wesnoth.current.side }

    for _, h in ipairs(aoe_healers) do

        local heal_ability = wml.get_child(wml.get_child(h.__cfg, "abilities"), "benediction")
        local heal_radius = heal_ability.range or 1
        local heal_count = heal_ability.number


        if h.status.heal_amp_range then
            heal_radius = heal_radius + h.variables["stat_bonus"]["heal_range"]
        end

        local allies = wesnoth.units.find_on_map { { "filter_location", { x = h.x, y = h.y, radius = heal_radius } } }

        if #allies > 0 then

            local bonus_heal = 0

            if h.status.heal_amp then
                bonus_heal = h.variables["stat_bonus"]["heal_boost"]
            end
        
            local heal_value = cc_utils.apply_heal_boost(heal_ability.value,bonus_heal)

            local allies_to_heal = {}

            for __, u in ipairs(allies) do   
                if not cc_utils.is_an_enemy(h, u) and h.id ~= u.id and not u:matches{status = "benediction"} and not u:matches{trait = "mechanical"} then     
                    local health_percent = u.hitpoints/u.max_hitpoints
                    table.insert(allies_to_heal, {id = u.id, health = health_percent})
                end
            end

            table.sort(allies_to_heal, function(a,b)
                return a.health < b.health
            end)

            for i = 1, math.min(heal_count,#allies_to_heal) do
                apply_benediction(wesnoth.units.get(allies_to_heal[i].id), heal_value)
            end

        end
    end

    -- AoE nonhealing effects
    local leaders = wesnoth.units.find_on_map { ability = "rally,glory,illusory_veil,shelter", side = wesnoth.current.side }
    for _, leader in ipairs(leaders) do
        local students = wesnoth.units.find_on_map { { "filter_location", { x = leader.x, y = leader.y, radius = 2 } } }
        if #students > 0 then
            wesnoth.interface.scroll_to_hex(leader.x, leader.y)
            for __, u in ipairs(students) do   
                if not cc_utils.is_an_enemy(u,leader) then
                    if leader:matches { ability = "shelter" } then
                        apply_ward(u,leader)
                    end  
                    if leader:matches { ability = "glory" } and u.level < leader.level then
                        apply_zeal(u)
                    end      
                    if leader:matches { ability = "illusory_veil" } then
                        apply_illusion(u)
                    end          
                    if leader:matches { ability = "rally" } and u.level < leader.level then
                        apply_rally(u,leader)
                    end    
                end
            end
        end
    end

    -- beacon
    local teachers = wesnoth.units.find_on_map { ability = "beacon", side = wesnoth.current.side }
    for _, teacher in ipairs(teachers) do
        local students = wesnoth.units.find_on_map { { "filter_adjacent", { id = teacher.id , is_enemy = "no"} } }
        if #students > 0 then
            wesnoth.interface.scroll_to_hex(teacher.x, teacher.y)
            for __, u in ipairs(students) do   
                if u.side == teacher.side and u.max_moves > 0 then
                    apply_recall(u, teacher.id)
                end     
                
            end
        end
    end

    -- raven queen
    local queen_of_ravens = wesnoth.units.find_on_map { ability = "queen_of_ravens", side = wesnoth.current.side }
    for _, queen in ipairs(queen_of_ravens) do
        local raven_range = (queen:matches { ability = "spectral_flight" } and 2) or 1
        local ravens = wesnoth.units.find_on_map { { "filter_location", { x = queen.x, y = queen.y, radius = raven_range } } }
        if #ravens > 0 then
            wesnoth.interface.scroll_to_hex(queen.x, queen.y)
            local raven_count = 0
            for __, u in ipairs(ravens) do   
                if u.side == queen.side and u:matches { type = "Carrion Feeder,Fel Omen,Gravewaker" } then
                    apply_recall(u, queen.id)
                    raven_count = raven_count + 1
                end                
            end

            if raven_count > 0 then
                apply_call_raven(queen,raven_count)
            end
        end
    end

    -- spiritcall
    if time.id == "dawn" or time.id == "dusk" then
        wesnoth.wml_actions.kill {
            type="Spirit of the Woods",
            side=wesnoth.current.side,
            fire_event= false,
            animate = false,
        }
        if wesnoth.current.side <= wml.variables.cc_player_count then
            local oracles = wesnoth.units.find_on_map { ability = "spiritcall", side = wesnoth.current.side }
            for _, oracle in ipairs(oracles) do
                wesnoth.interface.scroll_to_hex(oracle.x, oracle.y)
                for i=1,2 do
                    local u2 = wesnoth.units.create {
                        type = "Spirit of the Woods",
                        side = oracle.side,
                        random_traits = true
                    }
                    cc_training.apply(u2)
                    local x2,y2 = wesnoth.paths.find_vacant_hex(oracle.x, oracle.y, u2)
                    u2:to_map(x2,y2)
                end
            end
        end        
    end

    -- resurgence
    local units = wesnoth.units.find_on_map { ability_id_active = "resurgence", side = wesnoth.current.side }    
    for _, u in ipairs(units) do
       apply_elusive(u)
    end

    -- hides
    local units = wesnoth.units.find_on_map { ability_type_active = "hides", side = wesnoth.current.side }    
    for _, u in ipairs(units) do
        local adj = wesnoth.units.find_on_map { { "filter_adjacent", { id = u.id , is_enemy = "yes"} } }
        if #adj == 0 then
           apply_illusion(u)
        end
    end

    -- reset extra attacks
    local extra_attackers = wesnoth.units.find_on_map { ability_type = "extra_attack", side = wesnoth.current.side }
    for _, u in ipairs(extra_attackers) do
        u.variables["galeforce"] = nil
        u.variables["relentless"] = nil
    end

    -- set starting position of chargers
    local chargers = wesnoth.units.find_on_map { T.has_attack { special_id = "charge_cc"} }
    for _, u in ipairs(chargers) do
        u.variables["start_loc"] = {x=u.x, y=u.y}
    end

    -- set idle tracking
    local units = wesnoth.units.find_on_map { T.has_attack { special_id = "accelerate,volley,lock_on"}, side = wesnoth.current.side}
    for _, u in ipairs(units) do
        u.status.idled = true
    end

    -- autotarget
    local target_lock = wesnoth.units.find_on_map { trait = "autotarget", side = wesnoth.current.side}
    for _, u in ipairs(target_lock) do
        local adj = wesnoth.units.find_on_map { { "filter_adjacent", { id = u.id , is_enemy = "yes"} } }
        for _, v in ipairs(adj) do
            apply_targeted(v)
        end
    end
        
end)

on_event("pre attack", function(ec)
    local u = wesnoth.units.get(ec.x1, ec.y1)

    if not u then
        return
    end

    if u:matches { ability = "elusive" } then
        u.variables["precombat_moves"] = u.moves
    end
end)

----- post-attack events -----
on_event("attack_end", function(ec)
    local u = wesnoth.units.get(ec.x1, ec.y1)
    local v = wesnoth.units.get(ec.x2, ec.y2)

    if not u then
        return
    end

    -- pursuit: gain up to a certain number of attacks.
    if u:matches { T.has_attack { special_type_active = "pursuit"} } then
        
        local num_attacks = find_special_by_tag(ec[2][2],"pursuit").number or 1
        
        if not u.variables["pursuit_attacks"] then
            u.variables["pursuit_attacks"] = 1
            apply_pursuit(u,v)
        else
            u.variables["pursuit_attacks"] = u.variables["pursuit_attacks"] + 1

            if u.variables["pursuit_attacks"] < num_attacks then
                apply_pursuit(u,v)
            else
                -- get one last movement but no attacks
                u.moves = mathx.round(u.max_moves * 0.25)
            end
        end
    end

    -- charge: x2 damage and half movement back if >=5 hexes
    if u:matches { T.has_attack { special_id_active = "charge_cc"} } then
        local distance = wesnoth.map.distance_between(u.variables["start_loc"],{u.x,u.y})
        if distance>=5 then
            u.moves = mathx.round(u.max_moves * 0.5)
        end
    end

    -- elusive: regains remaining movement
    if u:matches { ability = "elusive" } or u:matches {trait = "fey" } then
        u.moves = u.variables["precombat_moves"]
    end

    -- tunneler: mark for teleportation
    if u:matches { ability = "tunneler" } then
        local tunneled = wesnoth.units.find_on_map { { "filter_adjacent", { id = u.id , is_enemy = "no"} } }
        if #tunneled > 0 then
            for j, t in ipairs(tunneled) do   
                apply_recall(t, u.id)
                
            end
        end
        u.moves = mathx.round(u.max_moves * 0.5)
    end
    
    -- nimble/hit and away: +1 MP back after attacking
    if u:matches { trait = "nimble" } or u:matches { ability = "hit_and_away" } then
        u.moves = u.moves + 1
    end

    -- targeted: remove targeted instance
    if u:matches { status = "targeted" } then
        u:remove_modifications({ id = "targeted_instance" })
        u.status.targeted = false
    end

    -- vuln: remove vuln instance
    if u:matches { status = "vulnerable" } then
        u:remove_modifications({ id = "vuln_instance" })
        u.status.vulnerable = false
    end
    
    u.status.idled = false
    u.variables["idle_count"] = nil
    u.variables["sleepy"] = nil

    if v.valid then
        if v.hitpoints > 0 then
            -- targeted: remove targeted instance
            if v:matches { status = "targeted" } then
                v:remove_modifications({ id = "targeted_instance" })
                v.status.targeted = false
            end

            -- vuln: remove vuln instance
            if v:matches { status = "vulnerable" } then
                v:remove_modifications({ id = "vuln_instance" })
                v.status.vulnerable = false
            end

            -- exploit weakness: apply vulnerable
            if u:matches { T.has_attack { special_id_active = "sunder"} } then
                apply_vulnerable(v)
            end

            -- pin down: apply targeted
            if u:matches { T.has_attack { special_id_active = "pin_down"} } then
                apply_targeted(v)
            end

            -- reprisal: remove the 0 accuracy
            if v:matches { T.has_attack { special_id_active = "reprisal"} } then
                v:remove_modifications({ id = "reprisal_instance" })
            end

            -- knockback: gets knocked back if hit    
            if u:matches { T.has_attack { special_type_active = "knockback"} } then
                
                local distance = find_special_by_tag(ec[2][2],"knockback").distance or 1
                if u.variables["knockback"] then
                    cc_utils.knockback(u,v,distance)
                    u.variables["knockback"] = nil
                end
                if u.variables["to_knockback"] then
                    local to_knockback = stringx.split(u.variables["to_knockback"] or "")
                    local processed = {}

                    for _, eid in ipairs(to_knockback) do
                        if not processed[eid] then
                            local e = wesnoth.units.get(eid)
                            if e ~= v then
                                cc_utils.knockback(u,e,distance)
                            end
                            processed[eid]=true
                        end
                    end

                    u.variables["to_knockback"] = nil
                    processed = nil
                end
            end

            -- pull: pull target towards user and back
            if u:matches { T.has_attack { special_type_active = "pull"} } then
                if u.variables["pull"] then
                    local distance = find_special_by_tag(ec[2][2],"pull").distance or 1
                    cc_utils.pull(u,v,distance)
                    u.variables["pull"] = nil
                end
            end
        end

        v.status.idled = false
        v.variables["idle_count"] = nil
        v.variables["sleepy"] = nil
    end

    -- apply negative leadership intimidate
    if u:matches { ability = "intimidate" } then
        local enemies = wesnoth.units.find_on_map { { "filter_location", { x = u.x, y = u.y, radius = 2 } } }
        if #enemies > 0 then
            wesnoth.interface.scroll_to_hex(u.x, u.y)
            for _, e in ipairs(enemies) do   
                if cc_utils.is_an_enemy(u,e) and not e:matches {trait = "mechanical"} then
                    apply_fear(e,u)
                end
            end
        end
    end

end)

-- death trigger abilities
on_event("die", function(ec)

    if not ec.x1 or not ec.y1 or not ec.x2 or not ec.y2 then
        return
    end

    local u_killer = wesnoth.units.get(ec.x2, ec.y2)
    local u_victim = wesnoth.units.get(ec.x1, ec.y1)

    if not u_killer then
        return
    end

    -- ravenous: heal yaoguai near dying enemy for 15% of the dead unit's max HP
    local yaoguai = wesnoth.units.find_on_map { { "filter_location", { x = u_victim.x, y = u_victim.y, radius = u_victim.level } } }
    for _, y in ipairs(yaoguai) do 
        if cc_utils.is_an_enemy(u_victim, y) and (y:matches { trait = "ravenous" } or y:matches {ability = "scavenger"} ) then 
            local heal_amount = u_victim.max_hitpoints * 0.15
            if y:matches {ability = "devour"} then
                heal_amount = u_victim.max_hitpoints * 0.35
            end
            if y.status.heal_amp then
                heal_amount = cc_utils.apply_heal_boost(heal_amount,y.variables["stat_bonus"]["heal_boost"])
            end
            y.hitpoints = math.min(y.hitpoints+heal_amount, y.max_hitpoints)
        end
    end

    -- galeforce: turn refresh on kill (1x per turn)
    if u_killer:matches { ability = "galeforce" } then
        if not u_killer.variables["galeforce"] then
            u_killer.moves = u_killer.max_moves
            u_killer.attacks_left = u_killer.attacks_left + 1
            u_killer.variables["galeforce"] = true
        end
    end

    -- relentless: attack refresh on kill (1x per turn), +ward
    if u_killer:matches { ability = "relentless" } then
        if not u_killer.variables["relentless"] then
            u_killer.attacks_left = u_killer.attacks_left + 1
            apply_ward(u_killer,u_killer)
            u_killer.variables["relentless"] = true
        end
    end

    -- warcry: +25% HP after kill
    if u_killer:matches { ability = "warcry" } then
        heal_amount = u_killer.max_hitpoints * 0.25

        if u_killer.status.heal_amp then
            heal_amount = cc_utils.apply_heal_boost(heal_amount,u_killer.variables["stat_bonus"]["heal_boost"])
        end
        u_killer.hitpoints = math.min(u_killer.hitpoints+heal_amount, u_killer.max_hitpoints)
    end

    -- covetous: +25% XP on kill
    if u_killer:matches { trait = "covetous" } then
        u_killer.experience = u_killer.experience + (2 * u_victim.level)
        u_killer:advance(true, true)
    end

    -- looter: +2g on kill
    if u_killer:matches { ability = "looter" } then

        local side = wesnoth.sides[u_killer.side]
        side.gold = side.gold + 2
    end

    if u_killer.side <= 3 then
        -- lead by example: add 100% kill XP to bonus XP pool
        if u_killer:matches { ability = "lead_by_example" } then
            local side = wesnoth.sides[u_killer.side]
            side.variables["bonus_XP"] = side.variables["bonus_XP"] + (8 * u_victim.level)
        end
        -- mentor: add 25% kill XP to bonus XP pool
        if u_killer:matches { ability = "mentor" } then
            local side = wesnoth.sides[u_killer.side]
            side.variables["bonus_XP"] = side.variables["bonus_XP"] + (2 * u_victim.level)
        end

        -- martyr: +4g/+4BXP
        if u_victim:matches { ability = "martyr" } then
            local side = wesnoth.sides[u_victim.side]
            side.gold = side.gold + 4
            side.variables["bonus_XP"] = side.variables["bonus_XP"] + 4
        end
    end
end)

-- death trigger abilities, pt.2 - need to be seperated due to using returns
-- absorb power: +level damage on killing attack
on_event("die", function(ec)

    if not ec.x1 or not ec.y1 or not ec.x2 or not ec.y2 then
        return
    end

    local u_killer = wesnoth.units.get(ec.x2, ec.y2)
    local u_victim = wesnoth.units.get(ec.x1, ec.y1)

    if not u_killer then
        return
    end

    if u_killer:matches { T.has_attack { special_id_active = "absorb_power"} } then
        
        local u_killer_cfg = u_killer.__cfg
        for _,v in ipairs(wml.get_child(u_killer_cfg, "modifications"))do
            if v[1] == "object" and v[2].absorbing == true then
                local effect = wml.get_child(v[2], "effect")

                if u_victim.level > 0  then
                    effect.increase_damage = effect.increase_damage + u_victim.level
                    wesnoth.units.to_map(u_killer_cfg)
                    u_killer:transform(u_killer.type)
                end
                return
            end
        end
        -- reaching this point means that the unit didn't have the stacking object yet.
        u_killer:add_modification("object", {
            absorbing = true,
            T.effect {
                apply_to = "attack",
                name = "absorb_power",
                increase_damage = u_victim.level,
            },
        })
        wesnoth.interface.float_label(ec.x2, ec.y2, "+"..u_victim.level.."damage", "120,120,0")
        u_killer:transform(u_killer.type)
    end
end)

-- debuff expiration
on_event("side turn end", function(ec)

    local units = wesnoth.units.find{side = wesnoth.current.side}
    for _, u in ipairs(units) do

        if u.status.idled then
            if u:matches {T.has_attack { special_id = "accelerate,volley,lock_on"} } then
                if u.variables["idle_count"] then
                    u.variables["idle_count"] = math.min(u.variables["idle_count"] + 1, u.level)
                else
                    u.variables["idle_count"] = 1
                end
            end
        else
            u.status.idled = false
            u.variables["idle_count"] = nil
        end

        -- conditional resets
        if u.variables["pursuit_attacks"] then
            u.variables["pursuit_attacks"] = nil
        end

        u.status.exhausted = false
        u.status.targeted = false
        u.status.stunned = false
        u.status.vulnerable = false
        u.status.cursed = false
        u.status.fear = false

        -- beacon recall --
        if u.status.recall then
            local beacon = wesnoth.units.get(u.variables["beacon"])
            if beacon then
                local x2,y2 = wesnoth.paths.find_vacant_hex(beacon.x, beacon.y, u)
                wesnoth.wml_actions.teleport {
                    wml.tag.filter { id = u.id },
                    x = x2,
                    y = y2
                }
            end
            u:remove_modifications({ id = "recall_instance" })
            u.status.recall = nil
            u.variables["beacon"] = nil
        end
    end
end)

cc_utils.menu_item {
    id="CC_Charge",
    description = _ "View charge range",
    image = "misc/map.png",
    synced = false,
    filter = function(x, y)
        local u = wesnoth.units.get(x, y)

        if not u then
            return false
        end

        if not u:matches{T.has_attack { special_id = "charge_cc"}} then
            return false
        end
        return u
    end,
    handler = function(ec)
        
        local u = wesnoth.units.get(ec.x1, ec.y1)
        local t = wesnoth.paths.find_reach(u)

        for i,l in ipairs(t) do
            local dist = wesnoth.map.distance_between(u.variables["start_loc"],{l.x,l.y}) 
            if dist >= 5 then
                wesnoth.interface.add_hex_overlay(l.x, l.y, { image = "overlays/charge.png" })
            end
        end
        wml.fire("redraw")
        wesnoth.interface.delay(5000)

        for i,l in ipairs(t) do
            wesnoth.interface.remove_hex_overlay(l.x,l.y, { image = "overlays/charge.png" })
        end
        wml.fire("redraw")
    end
}

cc_utils.menu_item {
    id="CC_Recall",
    description = _ "Remove recall tether",
    image = "misc/map.png",
    synced = true,
    filter = function(x, y)
        local u = wesnoth.units.get(x, y)

        if not u then
            return false
        end

        if not u.variables["beacon"] then
            return false
        end
        return u
    end,
    handler = function(ec)
        local u = wesnoth.units.get(ec.x1, ec.y1)
        u:remove_modifications({ id = "recall_instance" })
        u.variables["beacon"] = nil
        u.status.recall = nil
    end
}