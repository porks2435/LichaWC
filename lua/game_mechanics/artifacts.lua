local on_event = wesnoth.require("on_event")

local _ = wesnoth.textdomain 'wesnoth-cc'

local artifacts = {}
artifacts.list = {}

function artifacts.add_artifact_data(a)
	table.insert(artifacts.list, a)
end

function artifacts.read_wml_data(cfg)
	for i, artifact in ipairs(cc_convert.wml_to_lon(wml.literal(cfg), "cc_artifact_list").artifact or {}) do
		artifacts.add_artifact_data(artifact)
	end
end

function artifacts.init_data()
	local cfg = cc_utils.get_cc_data("artifact")
	for i, a in ipairs(cc_convert.wml_to_lon(cfg, "cc_artifact_list").artifact or {}) do
		artifacts.add_artifact_data(a)
	end
end

function artifacts.get_artifact(id)
	return artifacts.list[id]
end

function artifacts.get_artifact_list()
	return artifacts.list
end

function artifacts.drop_message(index)
	local artifact_data = artifacts.get_artifact(index)

	local help_message = artifact_data.info or nil
	local description = cc_color.bonus_text(artifact_data.description)

	if help_message then
		description = help_message .. "\n" .. description
	end

	wesnoth.wml_actions.message {
		speaker = "narrator",
		caption = artifact_data.name,
		message = description,
		image = artifact_data.icon,
	}
end

function cc_artifact_needs_compensation(side)
	return not cc_scenario.is_human_side(side.side)
end

-- place an artifact with id @a index on the map at position @a x, y.
-- can be used from the bug console as `lua cc_artifacts.place_item(30,20,1)`
function artifacts.place_item(x, y, index)
	wesnoth.wml_actions.item {
		x = x,
		y = y,
		image = artifacts.get_artifact(index).icon,
		z_order = 20,
		wml.tag.variables { cc_artifact_id = index },
	}
end

-- give an item to a unit
function artifacts.give_item(unit, index)
	local artifact_data = artifacts.get_artifact(index)
	local make_holder_loyal = wml.variables["cc_config_items_make_loyal"] ~= false
	if make_holder_loyal and (not unit.canrecruit) and (unit.upkeep ~= 0) and (unit.upkeep ~= "loyal") then
		if not unit:matches {trait = "heroic"} then
			unit:add_modification("object", { wml.tag.effect { apply_to = "cc_overlay", add = "misc/loyal-icon.png" }})
		else
			unit:add_modification("object", { wml.tag.effect { apply_to = "cc_overlay", add = "misc/hero-icon.png" }})
		end
	end

	local object = {
		cc_artifact_id = index,
		cc_is_artifact = true,
	}
	if make_holder_loyal then
		table.insert(object, wml.tag.effect { apply_to= "loyal" })
	end

	for i, effect in ipairs(artifact_data.effect) do
		table.insert(object, wml.tag.effect (effect) )
	end
	unit:add_modification("object", object)
	local unit_initial_hp = unit.hitpoints
	--rebuild unit, to reduce savefile size.
	unit:transform(unit.type)
	-- restore unit hitpoints to before they picked up the artifact
	unit.hitpoints = unit_initial_hp

	-- slot in traits if any artifacts grant any
	for trait in wml.child_range(artifacts.list[index], "trait") do
		if not unit:matches { wml.tag.filter_wml { wml.tag.modifications { wml.tag.trait { id = trait.id } } } } then
			unit:add_modification("trait", trait)
		end
	end

	-- inform owner what artifact was recieved
	if unit.side <= wml.variables.cc_player_count then
		wesnoth.interface.add_chat_message(cc_utils.getName(unit), "acquired " .. artifact_data.name .. " (" .. artifact_data.description .. ")")
	end

	local help_text = artifact_data.info or ""
	unit.variables["artifact"] = "<span weight='bold'>" .. artifact_data.name .. "</span>\n" .. artifact_data.description  .. "\n<span size='small'>" .. cc_color.color_text('gray', help_text) .. "</span>"
	
	-- the artifact might reduce the max xp.
	unit:advance(true, true)
end

-- give a random suitable item to a unit
function artifacts.get_suitable_items(u, rarity_filter)

	--enemy only filters the ones that might be problematic being given automatically
	local valid_items = artifacts.fresh_artifacts_list(rarity_filter)
	local possible_artifacts = {}
	for l, v in ipairs(valid_items) do
		local filter = artifacts.get_artifact(tonumber(v)).filter

		if not filter or u:matches(filter) then
			table.insert(possible_artifacts, tonumber(v))
		end
	end

	return possible_artifacts
	
end

-- unit picking up artifacts
on_event("cc_drop_pickup", function(ec)
	local item = cc_dropping.current_item
	local unit = wesnoth.units.get(ec.x1, ec.y1)
	if not item.variables.cc_artifact_id then
		return
	end

	if not unit then
		return
	end

	local side_num = unit.side
	local is_human = cc_scenario.is_human_side(side_num)
	if not wml.variables["cc_config_experimental_pickup"] and not is_human  then
		return
	end

	if unit.variables["artifact"] then
		if is_human then
			wesnoth.wml_actions.message {
				id = unit.id,
				message = _"I already have an artifact.",
			}
		end
		return
	end

	local index = item.variables.cc_artifact_id
	local filter = artifacts.get_artifact(index).filter
	if filter and not unit:matches(filter) then
		if is_human then
			wesnoth.wml_actions.message {
				id = unit.id,
				message = _"I cannot pick up that item.",
			}
		end
		return
	end

	if is_human and not wml.variables["cc_config_disable_pickup_confirm"] then
		if not cc_pickup_confirmation_dialog.promt_synced(unit, artifacts.get_artifact(index).icon) then
			return
		end
	end

	cc_dropping.item_taken = true
	artifacts.give_item(unit, index)
	wesnoth.allow_undo(false)
end)

-- returns a list of artifact ids based on rarity
function artifacts.fresh_artifacts_list()
	local res = {}
	local scenario_num = cc_scenario.scenario_num()

	for i,v in ipairs(artifacts.get_artifact_list()) do
		local rarity = v.rarity or 0
		if rarity < scenario_num then
			table.insert(res, i)
		end
	end

	return res
end

-- drop all items a dying unit carries.
on_event("die", function(ec)
	local unit = wesnoth.units.get(ec.x1, ec.y1)
	if not unit then
		return
	end
	if not wml.variables["cc_config_experimental_pickup"] and cc_scenario.is_human_side(unit.side) then
		return
	end
	for object in wml.child_range(wml.get_child(unit.__cfg, "modifications") or {}, "object") do
		if object.cc_artifact_id then
			artifacts.place_item(unit.x, unit.y, object.cc_artifact_id)
			artifacts.drop_message(object.cc_artifact_id)
			wesnoth.allow_undo(false)
		end
	end

	-- remove the item from the unit, just in case the unit is somehow brought back to life by another addons code. (for example 'besieged druid' can do such a thing)
	unit:remove_modifications { cc_is_artifact = true }
end)

-- returns true if there is an item in the map at the given position,
-- used to determine whether to show the artifact info menu at that position.
function artifacts.is_item_at(x,y)
	for i,item in ipairs(wesnoth.interface.get_items(x,y)) do
		if item.variables.cc_artifact_id then
			return true
		end
	end
	return false
end

-- shows an information [message] about the item laying at position
-- @a cfg.x, cfg.y
function wesnoth.wml_actions.cc_show_item_info(cfg)
	local x = cfg.x
	local y = cfg.y
	for i,item in ipairs(wesnoth.interface.get_items(x,y)) do
		if item.variables.cc_artifact_id then
			local artifact_info = artifacts.get_artifact(item.variables.cc_artifact_id)

				local help_text = artifact_info.info or nil
				local requirement = artifact_info.requirement or nil

				local message = cc_color.help_text(artifact_info.description)

				if help_text then
					message = message .. "\n" .. help_text
				end
				if requirement then
					message = message .. "\n" .. cc_color.color_text('gray', requirement)
				end

			wesnoth.wml_actions.message {
				scroll = false,
				image = artifact_info.icon,
				caption = artifact_info.name,
				message= message,
			}
		end
	end
end

cc_utils.menu_item {
	id="4_CC_Item_Info_Option",
	description = _ "Remind me what this item does",
	image = "icons/terrain/terrain_type_info.png",
	synced = false,
	filter = artifacts.is_item_at,
	handler = function(ec)
		wesnoth.wml_actions.cc_show_item_info {
			x = ec.x1,
			y = ec.y1,
		}
	end
}

function wesnoth.wml_actions.cc_place_item(cfg)
	artifacts.place_item(cfg.x, cfg.y, cfg.item_index)
	if cfg.message then
		artifacts.drop_message(cfg.item_index)
	end
end

artifacts.init_data()

return artifacts
