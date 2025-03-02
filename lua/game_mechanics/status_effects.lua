local _ = wesnoth.textdomain 'wesnoth-cc'
local T = wml.tag
local on_event = wesnoth.require("on_event")

-- actual status implementations
function apply_exhaust(u)
    if not u:matches {status = "exhausted"} then
        u:add_modification('object', {
            duration = 'turn end',
            T.effect{
                apply_to = 'overlay',
                add = 'overlays/exhaust.png~O(50%)'
            },
            T.effect {
                apply_to = "new_ability",
                T.abilities {
                    T.swarm {
                        swarm_attacks_min = 1,
                        T.filter_self{
                            formula="self.hitpoints < self.max_hitpoints *0.7"
                        }
                    }
                }
            },
            T.effect{ apply_to = 'status', add = 'exhausted' }
        })
    end
end

function apply_targeted(u)
    if not u:matches {status = "targeted"} then
        u:add_modification('object', {
            id = 'targeted_instance',
            duration = 'turn end',
            T.effect{
                apply_to = 'overlay',
                add = 'overlays/target.png~O(50%)'
            },
            T.effect {
                apply_to = "defense",
                replace = false,
                T.defense {
                    fungus = 20,
                    cave = 20,
                    deep_water = 20,
                    shallow_water = 20,
                    swamp_water = 20,
                    sand = 20,
                    forest = 20,
                    flat = 20,
                    hills = 20,
                    mountains = 20,
                    village = 20,
                    castle = 20,
                    frozen = 20,
                    unwalkable = 20,
                    reef = 20,
                },
            },
            T.effect{ apply_to = 'status', add = 'targeted' }
        })
    end
end

function apply_stun(u)
    if not u:matches {status = "stunned"} then
        u:add_modification('object', {
            duration = 'turn end',
            T.effect{
                apply_to = 'overlay',
                add = 'overlays/stun.png'
            },
            T.effect{
                apply_to = 'zoc',
                value = false
            },
            T.effect {
                apply_to = "new_ability",
                T.abilities {
                    T.chance_to_hit {
                        id = "dazed",
                        sub = 10,
                    }
                }
            },
            T.effect {
                apply_to = "attack",
                remove_specials = "magical,focused"
            },
            T.effect{ apply_to = 'status', add = 'stunned' }
        })
    end
end

function apply_scorch(u, level)
    if not u:matches {status = "scorched"} then
        u:add_modification('object', {
            duration = 'scenario end',
            id = "scorched_instance",
            T.effect{
                apply_to = 'overlay',
                add = 'overlays/scorch.png~O(50%)'
            },
            T.effect{
                apply_to = 'image_mod',
                replace = 'CS(100,-100,-100)'
            },
            T.effect{ apply_to = 'status', add = 'scorched' }
        })
    end
end

function apply_vulnerable(u)
    if not u:matches {status = "vulnerable"} then
        u:add_modification('object', {
            id = 'vuln_instance',
            duration = 'turn end',
            T.effect{
                apply_to = 'overlay',
                add = 'overlays/vulnerable.png'
            },
            T.effect {
                apply_to = "new_ability",
                T.abilities {
                    T.resistance {
                        sub = 20
                    }
                }
            },
            T.effect{ apply_to = 'status', add = 'vulnerable' }
        })
    end
end

function apply_curse(u)
    if not u:matches { status = "cursed"} then
        u:add_modification('object', {
            duration = 'turn end',
            T.effect{
                apply_to = 'overlay',
                add = 'overlays/curse.png'
            },
            T.effect {
    			apply_to = "new_ability",
    			T.abilities {
    				T.drains {
    					id = "curse_drain",
    					apply_to = "opponent"
    				}
    			}
    		},
            T.effect{ apply_to = 'status', add = 'cursed' },
            T.effect{ apply_to = 'status', remove = 'undrainable'}
        })
    end
end

function apply_ward(u, cmd)
    local duration = 'turn'

    if cmd == nil or u.side ~= cmd.side then
        duration = 'turn end'
    end

    if not u:matches { status = "warded" } then 
        u:add_modification('object', {
            id = 'warded_instance',
            duration = duration,
            T.effect{
                apply_to = 'overlay',
                add = 'overlays/ward.png~O(30%)'
            },
            T.effect{ apply_to = 'status', add = 'warded' }
        })
    end
end

function apply_illusion(u)
    if not u:matches { status = "illusion" } then 
        u:add_modification('object', {
            id = 'illusion_instance',
            duration = 'turn',
            T.effect{
                apply_to = 'overlay',
                add = 'overlays/illusion.png'
            },
            T.effect {
                apply_to = "new_ability",
                T.abilities {
                    T.chance_to_hit {
                        id = "illusion",
                        multiply = 0.8,
                        apply_to = "opponent",
                    }
                }
            },
            T.effect{ apply_to = 'status', add = 'illusion' }
        })
    end
end

function apply_recall(u, id)
    if not u:matches { status = "recall" } then 
        u:add_modification('object', {
            id = 'recall_instance',
            duration = 'turn',
            T.effect{
                apply_to = 'overlay',
                add = 'overlays/recall.png~O(50%)'
            },
            T.effect{ apply_to = 'status', add = 'recall' }
        })
        u.variables["beacon"] = id
    end
end

function apply_benediction(u, amount)
    if u.hitpoints < u.max_hitpoints / 3 then
        local heal_amount = math.ceil(u.max_hitpoints * (amount / 100.0))
        u.hitpoints = math.min(u.max_hitpoints, u.hitpoints + heal_amount)
        u.status.benediction = false
        u.variables["benediction"] = nil
        return
    end
    if not u:matches { status = "benediction" } then 
        u:add_modification('object', {
            id = 'benediction_instance',
            duration = 'scenario end',
            T.effect{
                apply_to = 'overlay',
                add = 'overlays/benediction.png'
            },
            T.effect{ apply_to = 'status', add = 'benediction' }
        })
        u.variables["benediction"] = amount
    end
end

function apply_zeal(u, cmd)
    u:add_modification('object', {
        id = 'zeal_instance',
        duration = 'turn end',
        T.effect{
                apply_to = 'overlay',
                add = 'overlays/zeal.png'
            },
        T.effect {
            apply_to = "new_ability",
            T.abilities {
                T.berserk {
                    id = "zeal",
                    value = 2,
                    cumulative = "no",
                    active_on = "offense"
                }
            }
        },
        T.effect{ apply_to = 'status', add = 'zeal' }
    })
end

function apply_rally(u, cmd)
    local damage_mult = 25
    local level_difference = math.max(0, cmd.level-u.level)
    local duration = 'turn'

    if u.side ~= cmd.side then
        duration = 'turn end'
    end

    u:add_modification('object', {
        id = 'rally_instance',
        duration = duration,
        T.effect {
            apply_to = "new_ability",
            T.abilities {
                T.leadership {
                    id = "rally_boost",
                    value = damage_mult * level_difference,
                    cumulative = "no",
                    affect_self = "yes"
                }
            }
        },
        T.effect{ apply_to = 'status', add = 'rallied' }
    })
end

function apply_call_raven(u, num_ravens)
    u:add_modification('object', {
        id = 'call_raven_attacks',
        duration = 'turn end',
        T.effect {
            apply_to = "attack",
            special_id = "call_raven",
            increase_attacks = num_ravens 
        },
    })    
end

function apply_elusive(u)
    u:add_modification('object', {
        duration = 'turn end',
        T.effect {
            apply_to = "new_ability",
            T.abilities {
                T.skirmisher {
                    id = "elusive"
                }
            }
        },
        T.effect{ apply_to = 'status', add = 'resurgence' }
    })    
end

function apply_fear(u, cmd)
    local damage_mult = 15
    local level_difference = math.max(0, u.level-cmd.level)
    local damage_mod = damage_mult + (damage_mult * level_difference)
    u:add_modification('object', {
        id = 'fear_instance',
        duration = 'turn end',
        T.effect {
            apply_to = "new_ability",
            T.abilities {
                T.leadership {
                    id = "fear_debuff",
                    sub = damage_mod,
                    cumulative = "no",
                    affect_self = "yes"
                }
            }
        },
        T.effect{ apply_to = 'status', add = 'fear' }
    })
end


function apply_sleep(u)
    if not u:matches { status = "sleep,sleep_resist" } or not u:matches{ canrecruit = "yes"} then 
        u:add_modification('object', {
            duration = 'scenario end',
            id = "sleep_instance",
            T.effect{
                apply_to = 'overlay',
                add = 'overlays/sleep.png~O(70%)'
            },
            T.effect {
                apply_to = "movement",
                set = 0
            },
            T.effect{
                apply_to = "attack",
                T.set_specials {
                    mode = "append",
                    T.disable{},
                    T.damage{
                        value = 0
                    }
                }
            },
            T.effect {
                apply_to = "new_ability",
                T.abilities {
                    T.chance_to_hit {
                        value = 100,
                        apply_to = "opponent",
                    }
                }
            },
            T.effect {
                apply_to = "new_ability",
                T.abilities {
                    T.damage {
                        value = 0,
                        apply_to = "opponent",
                        T.filter_opponent{
                            T.filter_weapon{
                                special='sleep'
                            }
                        }
                    }
                }
            },
            T.effect{ apply_to = 'status', add = 'sleep' }
        })
        u.variables["sleep_duration"] = 2
    end
end

function apply_madness(u, temp_side)

    if not u:matches { status = "madness" } and not u.variables["madness"] and not u:matches { canrecruit = "yes" } then 
        local original_side = u.side
        u.side = temp_side

        local victims = wesnoth.units.find_on_map { { "filter_adjacent", { id = u.id, is_enemy = "yes"} } }

        if #victims > 0 then

            local e = victims[mathx.random(#victims)]
            local rand_weapon = mathx.random(#u.attacks)

            wesnoth.interface.add_chat_message(cc_utils.getName(u), "Attacked " .. cc_utils.getName(e) .. " in a fit of madness!")

            for attacks=1,u.attacks[rand_weapon].number do
                apply_damage(u,e,rand_weapon,1)
            end
        end

        u:add_modification('object', {
            duration = 'turn end',
            T.effect {
                apply_to = "movement",
                set = 1
            },
            T.effect{ apply_to = 'status', add = 'madness' }
        })
        u.variables["madness"] = original_side
        u.attacks_left = 0
    end
end

function apply_pursuit(u,v)
    u.moves = math.ceil(u.max_moves * 0.25)
    u.attacks_left = u.attacks_left + 1

     u:add_modification('object', {
        duration = 'turn end',
        T.effect{
            apply_to = "attack",
            T["not"] {
                special_type = "pursuit"
            },
            T.set_specials {
                mode = "append",
                T.disable{}
            }
        },
        T.effect{
            apply_to = "attack",
            special_type = "pursuit",
            T.set_specials {
                mode = "append",
                T.disable{
                    T.filter_opponent{
                        id = v.id
                    }
                }
            }
        }
    })
end
