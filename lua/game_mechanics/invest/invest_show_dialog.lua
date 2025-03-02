local _ = wesnoth.textdomain 'wesnoth-cc'

local dialog_wml = wml.load "campaigns/Custom_Conquest/gui/invest_dialog.cfg"

function cc_show_invest_dialog_impl(dialog_args)
	local side_num = wesnoth.current.side
	local available_artifacts = dialog_args.items_available
	local available_heroes = dialog_args.heroes_available
	local available_deserters = dialog_args.deserters_available
	local available_commanders = dialog_args.commanders_available
	local available_training = dialog_args.trainings_available

	local show_artifacts = dialog_args.items_available ~= nil
	local show_heroes = dialog_args.heroes_available ~= nil
	local show_training = dialog_args.trainings_available ~= nil
	local show_other = dialog_args.gold_available

	local cati_items, cati_heroes, cati_training, cati_other

	local res = nil

	local index_map = {}

	local function preshow(dialog)

		local details = dialog.details
		local root_node = dialog.left_tree

		function gui.widget.add_invest_category(parent_node, name)
			local node = parent_node:add_item_of_type("category")
			node.category_name.label = name
			node.unfolded = true
			return node
		end

		function gui.widget.add_invest_item(parent_node, item_args)
			local node_type = item_args.desc and "item_desc" or "item"
			local page_type = item_args.page_type or ""

			local node = parent_node:add_item_of_type(node_type)
			local details_page = details:add_item_of_type(page_type)

			node.image.label = item_args.icon
			node.name.label = item_args.name
			if item_args.desc then
				node.desc.label = item_args.desc
			end

			index_map[table.concat(node.path, "_")] = { page_num = details.item_count, res = item_args.result }
			return node, details_page
		end

		local cati_current = 0
		if show_artifacts then
			local node = root_node:add_invest_category(_ "Artifacts")

			for i,v in ipairs(available_artifacts) do
				local artifact_info = cc_artifacts.get_artifact(tonumber(v))
				if not artifact_info then
					error("invalid item id'" .. v .. "'")
				end

				local subnode, page = node:add_invest_item {
					icon = artifact_info.icon,
					name = artifact_info.name,
					desc = cc_color.tc_text(artifact_info.description),
					result = { pick = "item", type=v }
				}

				local help_text = artifact_info.info or ""
				local requirement = artifact_info.requirement or ""
				page.info_label.label = help_text .. "\n" .. cc_color.color_text('gray',requirement) 
			end
		end

		if show_heroes then
			local node = root_node:add_invest_category(_ "Mercenaries")

			if available_commanders then
				local desc = _ "Commanders will take your leader’s place when the leader dies, possible commanders:"
				for j,v in ipairs(available_commanders) do
					desc = desc .. "\n" .. wesnoth.unit_types[v].name
				end

				local subnode, page = node:add_invest_item {
					icon = cc_color.tc_image("units/unknown-unit.png"),
					name = _ "Commander" .. "\n" .. cc_color.tc_text(_ "promote to leader"),
					result = { pick = "hero", type= "cc_commander" }
				}
				page.info_label.label = desc
			end
			for j,v in ipairs(available_heroes) do
				local unit_type = wesnoth.unit_types[v]


				local subnode, page = node:add_invest_item {
					page_type = "hero",
					icon = cc_color.tc_image(unit_type.image),
					name = unit_type.name,
					result = { pick = "hero", type= v }
				}
				page.unit_info.unit = unit_type
			end
			if available_deserters then
				local desc = "<b>" .. _ "possible units:" .. "</b>"
				for j,v in ipairs(available_deserters) do
					desc = desc .. "\n" .. wesnoth.unit_types[v].name
				end

				local subnode, page = node:add_invest_item {
					icon = cc_color.tc_image("units/unknown-unit.png"),
					name = _ "Deserter" .. "\n" .. cc_color.tc_text("+15 gold"),
					result = { pick = "hero", type= "cc_deserter" }
				}
				page.info_label.label = desc
			end
		end

		if show_training then
			local node = root_node:add_invest_category(_ "Training")
			for i,v in ipairs(available_training) do
				local current_grade = cc_training.get_level(side_num, v)
				local training_info = cc_training.get_trainer(v)
				local train_message = cc_training.generate_message(v, current_grade + 1)
				local train_message_before = cc_training.generate_message(v, current_grade)

				local title = stringx.vformat(_ "$name", { name = training_info.name })
				local desc = cc_training.describe_training_level2(current_grade, #training_info.grade) .. cc_color.tc_text(" → ") .. cc_training.describe_training_level2(current_grade + 1, #training_info.grade)


				local subnode, page = node:add_invest_item {
					icon = training_info.image,
					name = title,
					desc = desc,
					result = { pick = "training", type=v }
				}

				local help = training_info.info or ""
				page.info_label.label  = help .. "\n" .. cc_color.tc_text("<big>" .. _ "Before:" .. "</big>\n") .. train_message_before.message .. cc_color.tc_text("\n<big>" .. _ "After:" .. "</big>\n") .. train_message.message
			end
		end

		if show_other then
			local node = root_node:add_invest_category(_ "Other (only one)")

			--gold
			local colored_galleon = cc_color.tc_image("units/transport/transport-galleon.png")
			local supplies_image = "misc/blank-hex.png~SCALE(90,80)~BLIT(" .. colored_galleon .. ",9,4)"
			local supplies_text = cc_color.tc_text(_ "+70 gold and +1 village")

			local subnode, page = node:add_invest_item {
				icon = supplies_image,
				name = _"Stock up supplies",
				desc = supplies_text,
				result = { pick = "gold" }
			}

			page.info_label.label = _"Gives 70 gold and places a village on your keep."

			if cc_scenario.scenario_num() > 2 then
				--fortify
				local ballista = cc_color.tc_image("units/buildings/ballistaturret.png")
				local fortify_image = "misc/blank-hex.png~SCALE(90,80)~BLIT(" .. ballista .. ",9,4)"
				local fortify_text = cc_color.tc_text(_ "+2 keep radius, +6 ballista")

				local subnode, fortify_page = node:add_invest_item {
					icon = fortify_image,
					name = _"Fortify keep",
					desc = fortify_text,
					result = { pick = "fortify" }
				}

				fortify_page.info_label.label = _"Increases radius of keep to two hexes, and installs 6 ballista on each cardinal endpoint."
			end

			-- teleport
			for i = 1, wml.variables.cc_player_count do

				if i ~= side_num then
					local ally_leader = wesnoth.units.find_on_map { side = i, canrecruit = true }[1]
					local unit_type = wesnoth.unit_types[ally_leader.type]

					local colored_leader = cc_color.tc_image(i, unit_type.image)
					local teleport_image = "misc/blank-hex.png~SCALE(90,80)~BLIT(" .. colored_leader .. ",9,4)"
					local teleport_text = cc_color.tc_text(i, ally_leader.name .. "'s keep")

					local subnode, teleport_page = node:add_invest_item {
						icon = teleport_image,
						name = _"Begin teleport to",
						desc = teleport_text,
						result = { pick = "teleport", side = i}
					}

					teleport_page.info_label.label = _"Teleports all units to an allied keep on turn " .. (cc_scenario.scenario_num()+1) .. "."
				end

			end
		end

		local function set_result()
			local selected = root_node.selected_item_path
			local selected_data = index_map[table.concat(selected, '_')]
			if selected_data ~= nil then
				details.selected_index = selected_data.page_num
			end
			res = selected_data.res
		end

		root_node.on_modified = set_result
		set_result()
	end
	local d_wml = wml.get_child(dialog_wml, 'resolution')
	local d_res = gui.show_dialog(d_wml, preshow)
	return d_res, res
end

function cc_show_invest_dialog(args)
	--do it in a loop to disable esc.
	while true do
		local d_res, res = cc_show_invest_dialog_impl(args)
		if d_res ~= -2 then
			return res
		end
	end
end

return cc_show_invest_dialog
