local _ = wesnoth.textdomain 'wesnoth-cc'

-- check if user has a terraforming ability, and if they've already terraformed once.
function has_terraform_ability(x,y)
    local u = wesnoth.units.get(x, y)

    if not u then
    	return false
   	end

    if u:matches{ability_type = "terraforming"} and not u.variables["terraformed"] and u.side == wesnoth.current.side then
        return true
    else
        return false
    end
end

-- shows an information [message] about the item laying at position
-- @a cfg.x, cfg.y
function wesnoth.wml_actions.terraform(x,y)
    local u = wesnoth.units.get(x, y)

    local terrain_type = ""
    local second_terrain = nil

    if u:matches{ability = "shifting_sands"} then
        terrain_type = "Dd"
        second_terrain = "Hd"
        u:add_modification('object', {
            duration = 'forever',
            T.effect{
                apply_to = 'remove_ability',
                T.abilities{
                    T.terraforming{
                        id = "shifting_sands"
                    }
                }
            }
        })
    elseif u:matches{ability = "inundate"} then
        terrain_type = "Ww"
        second_terrain = "Wwr"
    elseif u:matches{ability = "glaciate"} then
        terrain_type = "Ai"
        second_terrain = "Ha"
    elseif u:matches{ability = "heavenfall"} then
        terrain_type = "Rb"
        second_terrain = "Rb^Edb"
    else
        wesnoth.message("invalid terraform type")
    end

    local to_terraform = wesnoth.map.get_hexes_in_radius({u.x,u.y},3)

    -- add the hex the unit is standing on too
    to_terraform[#to_terraform+1] = {u.x,u.y}

    for a=1, #to_terraform do
        wesnoth.wml_actions.terrain {
            x = to_terraform[a][1],
            y = to_terraform[a][2],
            terrain = terrain_type,
            layer = "both",
            wml.tag["not"] {
                terrain = "C*^*,*^C*,K*^*,*^K*,*^Xm,*^Xo,*^Qov,Q*^*"
            },
        }
    end

    if second_terrain then
    	for a= 1, 5 do
    		local random_hex = math.random(#to_terraform)
	        wesnoth.wml_actions.terrain {
	            x = to_terraform[random_hex][1],
	            y = to_terraform[random_hex][2],
	            terrain = second_terrain,
	            layer = "both",
	            wml.tag["not"] {
	                terrain = "C*^*,*^C*,K*^*,*^K*,*^Xm,*^Xo,*^Qov,Q*^*"
	            },
	        }
	    end
    end


    u.variables["terraformed"] = true
end

cc_utils.menu_item {
    id="CC_Terraform",
    description = _ "Terraform",
    image = "misc/map.png",
    synced = true,
    filter = has_terraform_ability,
    handler = function(ec)

        local u = wesnoth.units.get(ec.x1, ec.y1)
        local to_terraform = wesnoth.map.get_hexes_in_radius({ec.x1,ec.y1},3)

        for i,l in ipairs(to_terraform) do
            if wesnoth.map.matches(l.x, l.y, {
                    wml.tag["not"] {
                    terrain = "C*^*,*^C*,K*^*,*^K*,*^Xm,*^Xo,*^Qov,Q*^*"
                }}) then
                wesnoth.interface.add_hex_overlay(l.x, l.y, { image = "overlays/terraform.png" })
            end
        end
        wml.fire("redraw")

        if gui.show_prompt("Terraform","Use terraformation ability? You can only have a unit terraform once per campaign.","yes_no") then
            wesnoth.wml_actions.terraform {
                x = ec.x1,
                y = ec.y1,
            }
        end

        for i,l in ipairs(to_terraform) do
            wesnoth.interface.remove_hex_overlay(l.x,l.y, { image = "overlays/terraform.png" })
        end

        wml.fire("redraw")
    end
}