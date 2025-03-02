--#textdomain wesnoth-cc
_ = wesnoth.textdomain "wesnoth-cc"

local function status_readout(u)

  local status_readout = ""
  local heal_readout = "<b> healing</b>"

  local has_melee = false
  local has_ranged = false
  local has_heal = false

  local stat_cap = 50

  local stat_table = u.variables["stat_bonus"] or {}
  local reference_table = {
    {id = "hp", label = "<b>HP</b>: +", cap = 50},
    {id = "xp", label = "<b>XP</b>: -", cap = 50},
    {id = "mp", label = "<b>MP</b>: +", cap = 50},
    {id = "melee", label = "      melee: +", cap = 50},
    {id = "ranged", label = "      ranged: +", cap = 50},
    {id = "strikes", label = "      strikes: +", cap = 50},
    {id = "accuracy", label = "      accuracy: +", cap = 20},
    {id = "parry", label = "      parry: +", cap = 20},
    {id = "heal_boost", label = "      boost: +", cap = 50},
    {id = "heal_range", label = "      range: +", cap = 3},
  }

  for i=1,#reference_table do

    local t = reference_table[i].id

    if stat_table[t] then
      if t:match("^heal_") then
        if t == "heal_range" then
          heal_readout = heal_readout .. "\n" .. reference_table[i].label .. cc_color.intensity_text(stat_table[t],reference_table[i].cap)
        else
          heal_readout = heal_readout .. "\n" .. reference_table[i].label .. cc_color.intensity_text(stat_table[t],reference_table[i].cap) .. "%"
        end
        has_heal = true
      else
        status_readout = status_readout .. "\n" .. reference_table[i].label .. cc_color.intensity_text(stat_table[t],reference_table[i].cap) .. "%"
      end
    end
  end

  if has_heal then
    status_readout = status_readout .. "\n" .. heal_readout
  end

  status_readout = status_readout .. "\n<b>Total: " .. u.variables["stat_total"] .. "</b>" 

  if u.variables["train_bonus"] then
    status_readout = status_readout .. "<i>" .. u.variables["train_bonus"] .. "</i>"
  end

  return status_readout
end

-- rearranging UI elements
local old_unit_abilities = wesnoth.interface.game_display.unit_abilities
local old_unit_status = wesnoth.interface.game_display.unit_status
local old_unit_level = wesnoth.interface.game_display.unit_level
local old_unit_traits = wesnoth.interface.game_display.unit_traits
local old_unit_weapons = wesnoth.interface.game_display.unit_weapons



-- now being used to display traits
function wesnoth.interface.game_display.unit_weapons()
  local u = wesnoth.interface.get_displayed_unit()
  if not u then return {} end
  local w = old_unit_weapons()

  local s = {}

  for i=1,#w do
    if i == 1 then

      local extra_string = "<span color='gray' weight='semibold' size='small'>Attack"
      if #u.attacks > 1 then
        extra_string = extra_string .. "s"
      end

      if u.variables["stat_bonus"] then
        local accuracy_mod = u.variables["stat_bonus"]["accuracy"] or 0
        local parry_mod = u.variables["stat_bonus"]["parry"] or 0
        if parry_mod > 0 then
          extra_string = extra_string .. " <span color='white' weight='bold' size='x-small'>(+" .. accuracy_mod .. "%/+" .. parry_mod .. "%)</span>"
        elseif accuracy_mod > 0 then
          extra_string = extra_string .. " <span color='white' weight='bold' size='x-small'>(+" .. accuracy_mod .. "%)</span>"
        end
      end

      extra_string = extra_string .. "</span>\n"
      table.insert(s, { "element", { text = extra_string } } )
    else
      table.insert(s, w[i])
    end


  end


  return s
end

-- now being used to display side number / if this unit is being affected by leadership
function wesnoth.interface.game_display.unit_status()
  local u = wesnoth.interface.get_displayed_unit()
  if not u then return {} end
  local s = {}

  local side_image = "misc/side.png"

  -- leadership buff indicator
  if u:matches { ability = "rally_boost" } then
    side_image = "misc/side_rallied.png"
  end

  table.insert(s, { "element", { text = "  " } } )
  table.insert(s, { "element", { image = cc_color.tc_image(u.side, side_image),
      tooltip = _ "Side: <span weight='bold'>" .. u.side .. "</span>"
  } } )

  return s
end

-- now being used to display traits
function wesnoth.interface.game_display.unit_abilities()
  local u = wesnoth.interface.get_displayed_unit()
  if not u then return {} end
  
  return old_unit_traits()
end

-- no longer being used
function wesnoth.interface.game_display.unit_side()
  local u = wesnoth.interface.get_displayed_unit()
  if not u then return {} end
  return nil
end

--now displays statuses
function wesnoth.interface.game_display.unit_race()
  local u = wesnoth.interface.get_displayed_unit()
  if not u then return {} end
  local s = {}

  -- spacing-
  table.insert(s, { "element", { text = "  " } } )
        
  -- faction specific info
  if u:matches { canrecruit = "yes" } then

      local bonusXP = wesnoth.sides[u.side].variables["bonus_XP"]

      if bonusXP then
        if bonusXP > 0 then
          table.insert(s, { "element", {
            image = "status/BEXP.png",
            tooltip = _"<b>Bonus XP</b>: " .. wesnoth.sides[u.side].variables["bonus_XP"] .. "\n\nBonus XP that can be distributed through right-click menu to adjacent allies, 8 XP at a time."
          } })
        end
      end

  end

  -- has an artifact
  if u.variables["artifact"] then
    table.insert(s, { "element", {
      image = "status/artifact.png",
      tooltip = u.variables["artifact"]
    } })
  end

  -- positive buffs
  -- has heal amp
  if u.status.heal_amp and (u:matches{ability_type="heals,regenerate,benediction,conditional_heal"} or u:matches{trait="ravenous"} or u:matches{T.has_attack { special_type = "drains"}}) then
    local description = "This unit's healing capabilities are boosted. \n\n"
    description = description .. "Boost: +" .. cc_color.intensity_text(u.variables["stat_bonus"]["heal_boost"],80) .. "%\n"

    if u:matches {ability_type="heals"} then
      local heal_ability = cc_utils.get_heal_ability(u)
      local heal_value = cc_utils.apply_heal_boost(heal_ability.value,u.variables["stat_bonus"]["heal_boost"])
      description = description .. "    " .. heal_ability.name .. " (<b>" .. cc_color.color_text("#00FF00",heal_value).."</b>)\n"
    end
    if u:matches {ability_type="regenerate"} then
      local regen_ability = wml.get_child(wml.get_child(u.__cfg, "abilities"), "regenerate")
      local heal_value = cc_utils.apply_heal_boost(regen_ability.value,u.variables["stat_bonus"]["heal_boost"])

      description = description .. "    " .. regen_ability.name .. " (<b>" .. cc_color.color_text("#00FF00",heal_value).."</b>)\n"
    end
    if u:matches {ability_type="benediction"} then
      local heal_ability = wml.get_child(wml.get_child(u.__cfg, "abilities"), "benediction")
      local heal_value = cc_utils.apply_heal_boost(heal_ability.value,u.variables["stat_bonus"]["heal_boost"])

      description = description .. "    " .. heal_ability.name .. " (<b>" .. cc_color.color_text("#00FF00",heal_value).."%</b>)\n"
    end
    if u:matches {ability_type="conditional_heal"} then
      local heal_ability = wml.get_child(wml.get_child(u.__cfg, "abilities"), "conditional_heal")
      local heal_value = cc_utils.apply_heal_boost(heal_ability.value,u.variables["stat_bonus"]["heal_boost"])

      description = description .. "    " .. heal_ability.name .. " (<b>" .. cc_color.color_text("#00FF00",heal_value).."%</b>)\n"
    end
    if u:matches {trait="ravenous"} then

      local heal_value = cc_utils.apply_heal_boost(15,u.variables["stat_bonus"]["heal_boost"])
      if u:matches {ability="devour"} then
        heal_value = cc_utils.apply_heal_boost(35,u.variables["stat_bonus"]["heal_boost"])
      end
      description = description .. "    ravenous (<b>" .. cc_color.color_text("#00FF00",heal_value).."%</b>)\n"
    end
    if u:matches {T.has_attack { special_type = "drains"}} then
      description = description .. "    drains (<b>" .. cc_color.color_text("#00FF00",cc_utils.apply_heal_boost(50,u.variables["stat_bonus"]["heal_boost"])).."%</b>)\n"
    end
    if u.status.heal_amp_range and u:matches {ability_type="heals"} then
      description = description .. "Range: +" .. cc_color.intensity_text(u.variables["stat_bonus"]["heal_range"],3)
    end
    table.insert(s, { "element", {
      image = "status/heal_amp.png",
      tooltip = description
    } })
  end

  -- galeforce
  if u:matches {ability="galeforce"} then
    if not u.variables["galeforce"] then
      table.insert(s, { "element", {
        image = "status/extra_attack.png",
        tooltip = _"<b>Galeforce</b>: Will recieve a turn refresh on kill."
      } })
    else
      table.insert(s, { "element", {
        image = "status/extra_attack_disabled.png",
        tooltip = _"<b>" .. cc_color.color_text("gray","Galeforce").."</b>: Already got an extra turn."
      } })
    end
  end

  -- relentless
  if u:matches {ability="relentless"} then
    if not u.variables["relentless"] then
      table.insert(s, { "element", {
        image = "status/extra_attack.png",
        tooltip = _"<b>Relentless</b>: Will recieve an attack refresh on kill."
      } })
    else
      table.insert(s, { "element", {
        image = "status/extra_attack_disabled.png",
        tooltip = _"<b>" .. cc_color.color_text("gray","Relentless").."</b>: Already got an extra attack."
      } })
    end
  end

  -- pursuit
  if u:matches { T.has_attack { special_type = "pursuit"} } then

    local num_attacks = 1
    local attacks = u.variables["pursuit_attacks"] or 0

    if u:matches { T.has_attack { special_id = "pursuit_2"} } then
      num_attacks = 2
    elseif u:matches { T.has_attack { special_id = "pursuit_3"} } then
      num_attacks = 3
    elseif u:matches { T.has_attack { special_id = "pursuit_4"} } then
      num_attacks = 4
    end


    if attacks < num_attacks then
        table.insert(s, { "element", {
          image = "status/extra_attack.png",
          tooltip = _"<b>Pursuit: " .. attacks .. "</b>/".. num_attacks .. "\nAfter using a pursuit attack, will be refunded " .. mathx.round(u.max_moves * 0.25) .. " moves."
        } })
    else
        table.insert(s, { "element", {
          image = "status/extra_attack_disabled.png",
          tooltip = _"<b>" .. cc_color.color_text("gray","Pursuit: ") .. "</b>" .. attacks .. "/".. num_attacks .. "\nNo more pursuit attacks available."
        } })
    end
  end

  if u.status.rallied then
      table.insert(s, { "element", { image = "status/rally.png",
          tooltip = _ "<b>rallied</b>: +leadership damage bonus this turn."
      } } )
  end

  if u.status.warded then
      table.insert(s, { "element", { image = "status/ward.png",
          tooltip = _ "<b>warded</b>: blocks one instance of non-lethal damage until struck or next turn."
      } } )
  end

  if u.status.illusion then
      table.insert(s, { "element", { image = "status/illusion.png",
          tooltip = _ "<b>illusion</b>: increases evasion by 20% (multiplicative) until struck or next turn."
      } } )
  end

  if u.status.benediction then
      table.insert(s, { "element", { image = "status/benediction.png",
          tooltip = _ "<b>benediction</b>: will be healed for " .. cc_color.color_text("#00FF00",mathx.round(u.variables["benediction"]/100 * u.max_hitpoints)) .. " HP upon falling below " .. cc_color.color_text("#FF0000",mathx.round(u.max_hitpoints/3)) .. " HP."
      } } )
  end

  if u:matches {ability_id_active = "resurgence"} then

      local heal_amount = 8
      local image = "status/home-inactive.png"

      if u.status.heal_amp then
          heal_amount = cc_utils.apply_heal_boost(heal_amount,u.variables["stat_bonus"]["heal_boost"])
      end
      local tooltip = _"<b>resurgence</b>: If this unit starts their turn on this terrain, they will regenerate " .. cc_color.color_text("#00FF00",mathx.round(heal_amount)) .. " HP and gain 'elusive'.\n<i>Elusive</i>: Ignores enemy zone of control and regains remaining movement after combat."

      if u:matches {ability = "elusive"} then
        tooltip = _"<b>resurgence</b>: This unit is regenerating 8 HP and has the effects of the 'elusive' ability.\n<i>Elusive</i>: Ignores enemy zone of control and regains remaining movement after combat."
        if u:matches {type = "Fae Bristler, Dryad, Hamadryad"} then
          image = "status/home-forest.png"
        elseif u:matches {type = "Fae Hermit, Oread"} then
          image = "status/home-mountain.png"
        elseif u:matches {type = "Fae Soul Guide, Lampade"} then
          image = "status/home-dark.png"
        elseif u:matches {type = "Fae Siren, Fae Rusalka, Nereid, Limnaioi"} then
          image = "status/home-water.png"
        --elseif u:matches {type = ""} then
        --  image = "status/home-sand.png"
        --elseif u:matches {type = ""} then
        --  image = "status/home-ice.png"
        end
      end

      table.insert(s, { "element", { image = image,
          tooltip = tooltip
      } } )
  end

  if u.status.zeal then
      table.insert(s, { "element", { image = "status/zeal.png",
          tooltip = _ "<b>zeal</b>: offensively, +1 rounds of combat this turn."
      } } )
  end

  if u.status.recall then
    if wesnoth.units.get(u.variables["beacon"]) then
      table.insert(s, { "element", { image = "status/recall.png",
          tooltip = _ "<b>recall</b>: will be teleported back to " .. cc_utils.getName(wesnoth.units.get(u.variables["beacon"])) .. " on turn's end."
      } } )
    else
      table.insert(s, { "element", { image = "status/info.png",
          tooltip = _ "<b>recall</b>: Beacon no longer exists."
      } } )
    end
  end

  -- status effects
  if u.variables["madness"] then
      if u.status.madness then
        table.insert(s, { "element", { image = "status/madness.png",
            tooltip = _ "<b>madness</b>: temporarily defected in confusion."
        } } )
      else
        table.insert(s, { "element", { image = "status/madness-disabled.png",
            tooltip = _ "<b>madness</b>: has been afflicted with madness, cannot be afflicted again."
        } } )
      end
  end

  if u.status.fear then
      table.insert(s, { "element", { image = "status/fear.png",
          tooltip = _ "<b>fear</b>: -leadership damage penalty this turn."
      } } )
  end
  if u.status.poisoned then
      table.insert(s, { "element", { image = "status/poisoned.png",
          tooltip = _ "<b>poisoned</b>: 8 HP damage until cured. Cannot be lethal.\n This can be removed by any healer or recovering in a village."
      } } )
  end
  if u.status.scorched then
      table.insert(s, { "element", { image = "status/scorched.png",
          tooltip = _ "<b>scorched</b>:" .. cc_color.color_text('#FF0000', (u.max_hitpoints * 0.15)) .. "(15% max HP) damage until cured. Can be lethal.\n This can be removed by any healer, recovering in a village, or by standing in any body of water."
      } } )
  end
  if u.status.slowed then
      table.insert(s, { "element", { image = "status/slowed.png",
          tooltip = _ "<b>slowed</b>: damage and movement halved this turn."
      } } )
  end
  if u.status.exhausted then
    table.insert(s, { "element", { image = "status/exhausted.png",
      tooltip = _ "<b>exhausted</b>: strikes proportionately reduced by current HP."
    } } )
  end
  if u.status.targeted then
    table.insert(s, { "element", { image = "status/targeted.png",
      tooltip = _ "<b>targeted</b>: -20% defense for one combat."
    } } )
  end
  if u.status.vulnerable then
      table.insert(s, { "element", { image = "status/vulnerable.png",
          tooltip = _ "<b>vulnerable</b>: -20 resists for one combat."
      } } )
  end
  if u.status.sleep then
    table.insert(s, { "element", { image = "status/sleep.png",
      tooltip = _ "<b>sleep</b>: Cannot act. Any attacks made against this unit will have 100% accuracy, and wake it up. If the unit wakes up without being attacked, it is slowed for one turn.\nTurns remaining: " .. cc_color.color_text("#FF0000", u.variables["sleep_duration"])
    } } )
  end
  if u.status.stunned then
    table.insert(s, { "element", { image = "status/stunned.png",
      tooltip = _ "<b>stunned</b>: -10% accuracy, -ZoC/accuracy modifiers (such as magical)."
    } } )
  end
  if u.status.cursed then
    table.insert(s, { "element", { image = "status/cursed.png",
      tooltip = _ "<b>cursed</b>: drained for 50% of the damage taken, even if normally undrainable."
    } } )
  end
  if u.status.petrified then
    table.insert(s, { "element", { image = "status/petrified.png",
      tooltip = _ "<b>petrified</b>: Turned to stone. Will be slowed upon exiting petrifaction. \nTurns remaining: " .. cc_color.color_text("#FF0000", u.variables["stone_duration"])
    } } )
  end
  
  return s
end

--no longer being used
function wesnoth.interface.game_display.unit_level()
  local u = wesnoth.interface.get_displayed_unit()
  if not u then return {} end
  return nil
end

-- displays level, alignment, and race. Stat bonuses will change race hover
function wesnoth.interface.game_display.unit_alignment()
  local u = wesnoth.interface.get_displayed_unit()
  if not u then return {} end
  local l = old_unit_level()
  local display = {}

  -- level element
  table.insert(display, { "element", { text = "<b>L</b>" } } )
  table.insert(display, l[1])
  table.insert(display, { "element", { text = " " } } )

  -- alignment --
  if u:matches { alignment = "lawful"} then
    table.insert(display, { "element", { image = "misc/lawful.png" , tooltip = "Alignment: <b>" .. u.alignment .. "</b>"} } )
  elseif u:matches { alignment = "chaotic"} then
    table.insert(display, { "element", { image = "misc/chaotic.png" , tooltip = "Alignment: <b>" .. u.alignment .. "</b>"} } )
  elseif u:matches { alignment = "liminal"} then
    table.insert(display, { "element", { image = "misc/liminal.png" , tooltip = "Alignment: <b>" .. u.alignment .. "</b>"} } )
  else
    table.insert(display, { "element", { image = "misc/neutral.png" , tooltip = "Alignment: <b>" .. u.alignment .. "</b>"} } )
  end
  table.insert(display, { "element", { text = " " } } )

  -- race and stat bonuses --

  local stat_text = "Race: <b>".. tostring(wesnoth.races[u.race].name) .. "</b>"
  local stat_color = "#f5e6c1"
  local race = tostring(wesnoth.races[u.race].name)

  -- display stat bonuses
  if u.variables["stat_total"] then
      if u.variables["stat_total"] > 0 then
        stat_text = stat_text .. "\n" .. status_readout(u)

        if u.variables["stat_total"] < 30 then
          stat_color = "#00a6c9"
        elseif 
          u.variables["stat_total"] < 60 then
          stat_color = "#00d12f"
        elseif 
          u.variables["stat_total"] < 90 then
          stat_color = "#a75df9"
        elseif 
          u.variables["stat_total"] < 120 then
          stat_color = "#ffff00"
        else
          stat_color = "#ff7a0e"
        end
      end
  end

  table.insert(display, { "element", { text = cc_color.color_text(stat_color, cc_utils.firstToUpper(race)), tooltip = stat_text } } )

  return display
end


--now for abilities
function wesnoth.interface.game_display.unit_traits()
  local u = wesnoth.interface.get_displayed_unit()
  if not u then return {} end
  local s = old_unit_abilities()
  return s
end