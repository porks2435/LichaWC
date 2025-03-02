local _ = wesnoth.textdomain 'wesnoth-cc'
local dialog_wml = wml.load "campaigns/Custom_Conquest/gui/help_dialog.cfg"

local function make_caption(text)
	return ("<big><b>%s</b></big>"):format(text)
end

local function help_page_text(caption, description)
	return caption, ("%s\n\n%s"):format(make_caption(caption), description)
end

function wesnoth.wml_actions.cc_show_wocopedia(cfg)

	local show_help_mechanics = cfg.show_mechanics ~= false
	local show_help_training = cfg.show_training ~= false
	local show_help_factions = cfg.show_factions ~= false
	local show_help_artifacts = cfg.show_artifacts ~= false
	local show_help_settings = cfg.show_settings ~= false
	-- maps the treeview rows to pagenumber in the help page.
	local index_map = {}

	local current_side = wesnoth.interface.get_viewing_side()
	local preshow = function(dialog)
		local str_cat_mechnics = _ "Game Mechanics"
		local str_des_mechnics = cfg.mechanics_text or
			make_caption( _ "Game Mechanics") .. "\n\n" ..
			_ "<b>Gold</b>\n" ..
			_ "Carryover rate is 15% and split evenly among players. Negative amounts will not carry over. Early finish bonus is superior to village control, but it is not directly related to the carryover amount.\n\n" ..
			_ "<b>Autorecall</b>\n" ..
			_ "Units with the <b>heroic</b> trait are recalled at the start of each scenario with no cost (up to castle size).\n\n" ..
			_ "<b>Recall Cost</b>\n" ..
			_ "Units costing less than 17 gold are cheaper to recall.\n\n" ..
			_ "<b>Training</b>\n" ..
			_ "Every time you recruit a new unit, your training levels will be applied. If a unit gains training benefits, you can see them with the trait \"trained\". Each unit’s chance of gaining training benefits is independent of another’s.\n\n" ..
			_ "<b>Upkeep</b>\n" ..
			_ "Units with the <b>heroic</b> trait or holding any magic <b>item</b> have free upkeep.\n\n" ..
			_ "<b>Bonus Points</b>\n" ..
			_ "In every scenario the game generates as many bonus points on the map as there are players in the game, the bonus points can be picked up by player units and either contain artifacts, loyal units, or training.\n\n" ..
			_ "<b>Army discipline</b>\n" ..
			_ "At scenarios 1 to 3, for each training level players already own, trainers found have 2% to 4% chance to become advanced trainers (provide 2 levels). Becomes irrelevant from scenario 4 onwards because all trainers will always be advanced.\n\n" ..
			""
		local str_cat_training, str_des_training = help_page_text( _ "Training", _ "Training improves newly recruited units, it has no effect on already recruited units. The following list shows all available training, the training you currently have is marked in green.")
		local str_cat_era, str_des_era = help_page_text( _ "Factions" , _ "The World Conquest era consists of factions that are built from pairs of mainline factions. One faction will have a healer available (Drakes, Dunefolk, Rebels and Loyalists) and one will not (Orcs, Dwarves and Undead). The recruit list is also organized in pairs so that sometimes you will have to recruit a different unit before you can recruit the units that you want. The available heroes, deserters, and random leaders also depend on your factions; the items you can get do not depend on the faction you choose.")
		local str_cat_settings = _ "Settings"

		local root_node = dialog:find("treeview_topics")
		local details = dialog:find("details")

		function gui.widget.add_help_page(parent_node, args)
			local node_type = args.node_type or "category"
			local page_type = args.page_type or "simple"

			local node = parent_node:add_item_of_type(node_type)
			local details_page = details:add_item_of_type(page_type)
			if args.title then
				node.label_topic.label = args.title
				node.unfolded = true
			end
			index_map[table.concat(node.path, "_")] = details.item_count
			return node, details_page
		end

		---- add general topic ----
		if show_help_mechanics then
			local node, page = root_node:add_help_page {
				title = str_cat_mechnics
			}
			page.label_content.marked_up_text = str_des_mechnics

			local sub_node, page = node:add_help_page {
				title = "Status",
				page_type = "status_effects",
				node_type = "subcategory"
			}

			local buffs = {
				{"artifact", "status/artifact.png", _ "In posession of an artifact.", _ "permanent, bonus points"},
				{"heal+", "status/heal_amp.png", _ "Healing effectiveness increased.", _ "permanent, trainings"},
				{"bonus XP", "status/BEXP.png", _ "Bonus XP available to distribute.", _ "right-click menu, from various sources"},
				{"rally", "status/rally.png", _ "+25% damage/level difference.", _ "until next turn"},
				{"zeal", "status/zeal.png", _ "Offensively extends combat by one round.", _ "until next turn"},
				{"resurgence", "status/home-ice.png", _ "Regenerates and gains 'elusive' on turn start.", _ "while on preferred terrain"},
				{"extra attack", "status/extra_attack.png", _ "User has an additional attack available.", _ "varies depending on ability/special"},
				{"recall", "status/recall.png", _ "Marked for teleportation at turn's end.", _ "until end of turn"},
				{"ward", "status/ward.png", _ "Blocks one non-lethal instance of damage.", _ "until hit or next turn"},
				{"illusion", "status/illusion.png", _ "Increases evasion by 20% (multiplicative).", _ "until hit or next turn"},
				{"benediction", "status/benediction.png", _ "Will be healed upon HP being reduced under 33%.", _ "until battle end"},
			}

			local debuffs = {
				{"poisoned", "status/poisoned.png", _ "8 HP nonlethal damage on turn start.", _ "until healed (cure or village)."},
				{"scorched", "status/scorched.png", _ "15% max HP lethal damage on turn start until cured.", _ "until healed (cure, village, or water)."},
				{"targeted", "status/targeted.png", _ "Defenses are reduced by 20.", _ "for one battle or until afflicted's end of turn"},
				{"vulnerable", "status/vulnerable.png", _ "All resistances decreased by 20.", _ "for one battle or until afflicted's end of turn"},
				{"slowed", "status/slowed.png", _ "Damage and movement halved.", _ "until afflicted's end of turn"},
				{"exhausted", "status/exhausted.png", _ "Reduces strikes proportional to afflicted's hitpoints.", _ "until afflicted's end of turn"},
				{"stunned", "status/stunned.png", _ "Accuracy reduced by 10 and ZoC/accuracy modifiers disabled.", _ "until afflicted's end of turn"},
				{"fear", "status/fear.png", _ "-15% damage, plus additional -15%/level difference.", _ "until afflicted's end of turn."},
				{"cursed", "status/cursed.png", _ "Drained for 50% of damage taken.", _ "until afflicted's end of turn."},
				--{"petrified", "status/petrified.png", _ "Cannot move, act, or exert ZoC.", _ "for two turns: slowed after duration ends"},
				{"sleep", "status/sleep.png", _ "Cannot move or act. 100% accuracy against this unit.", _ "for two turns or until attacked."},
				{"madness", "status/madness.png", _ "Switches sides and attacks adjacent ally.", _ "for one turn, cannot be inflicted again."},
			}

			for i=1, #buffs do
				local page_element = page.treeview_status:add_item_of_type("status")

				local status_name = buffs[i][1] or ""
				local status_icon = buffs[i][2] or ""
				local status_desc = buffs[i][3] or ""
				local status_dur = buffs[i][4] or ""

				page_element.buff_image.label = status_icon
				page_element.buff_label.marked_up_text = "<b>" .. status_name .. "</b>  <span color='gray' size='x-small'><i>".. status_dur .. "</i></span>\n" .. "<span size='small'>" .. status_desc .. "</span>"

				local status_name = debuffs[i][1] or ""
				local status_icon = debuffs[i][2] or ""
				local status_desc = debuffs[i][3] or ""
				local status_dur = debuffs[i][4] or ""

				page_element.debuff_image.label = status_icon
				page_element.debuff_label.marked_up_text = "<b>" .. status_name .. "</b>  <span color='gray' size='x-small'><i>".. status_dur .. "</i></span>\n" .. "<span size='small'>" .. status_desc .. "</span>"
			end

			if show_help_artifacts then
				local sub_node, page = node:add_help_page {
					title = "Artifacts",
					page_type = "artifacts",
					node_type = "subcategory"
				}
				for i, artifact in ipairs(cc_artifacts.get_artifact_list()) do
					local artifact_icon = artifact.icon or ""
					local artifact_name = artifact.name or ""
					local artifact_desc = artifact.description or ""
					local not_available = stringx.map_split(artifact.not_available or "")

					local page_element = page.treeview_artifacts:add_item_of_type("artifact")
					page_element.image.label = artifact_icon
					page_element.label_name.marked_up_text = "<b>" .. artifact_name .. "</b>" .. "\n<span color='gray'>" .. artifact_desc .. "</span>"
				end
			end
		end

		-- add general training topic.
		if show_help_training then
			local node, root_page = root_node:add_help_page {
				title = str_cat_training
			}
			root_page.label_content.marked_up_text = str_des_training
			-- add specific training pages
			for i = 1, #cc_training.get_list() do
				local current_level = cc_training.get_level(current_side, i)

				if current_level > 0 then
					local trainer = cc_training.get_trainer(i)

					local subnode, sub_page = node:add_help_page {
						title = trainer.name,
						page_type = "training",
						node_type = "subcategory",
					}

					local function set_description(train_num, j)
						local desc = cc_training.generate_message(i, train_num)
						
						if train_num == current_level then
							desc.caption = "<span color='#00FF00'>" .. desc.caption .. "</span>"
							desc.message = "<span color='#00FF00'>" .. desc.message .. "</span>"
						end

						if train_num == 1 then
							local help = trainer.info or ""
							desc.caption = "<b>" .. trainer.name .. "</b>\n<span size='small'>" .. help .. "</span>\n\n" .. desc.caption
						end

						local page_element = sub_page.treeview_details:add_item_of_type("training_details")
						page_element.training_caption.marked_up_text = desc.caption
						page_element.training_description.marked_up_text = desc.message
					end

					set_description(1)
					for j = 2, #trainer.grade - 1, 1 do
						sub_page.treeview_details:add_item_of_type("seperator")
						set_description(j)
					end
				end
			end
		end

		if show_help_factions then
			local function type_icon(ut)
				if ut=="placeholder" then
					return ""
				end
				local icon = ut.icon
				if icon and icon ~= "" then
					return icon
				else
					return cc_color.tc_image(current_side, ut.image)
				end
			end

			local function type_desc(ut)
				if ut=="placeholder" then
					return ""
				end
				local desc = "<span weight='thin' size='x-small'>L" .. ut.level .. " </span>" .. ut.name .. "\n"				
				desc = desc .. "<span size='x-small'><span color='#21e100'>HP: " .. ut.max_hitpoints .. "</span> | <span color='#00a0e1'> XP: " .. ut.max_experience .. " </span> | MP: " .. ut.max_moves .. "</span>\n"
				if #ut.abilities > 0 then
					desc = desc .. "<span size='x-small' weight='semibold'>"
					local abil_string = ""


					for a=1,#ut.abilities do
						if string.len(abil_string) > 0 then
							abil_string = abil_string .. ","
						end
						abil_string = abil_string .. " " .. ut.abilities[a]:gsub("_"," ")
					end 
					desc = desc .. abil_string .. "</span>"
				end
				return desc
			end

			local function type_weps(ut)
				if ut=="placeholder" then
					return ""
				end
				local desc = "<span size='x-small'>"
				for w=1, #ut.attacks do
					local attack = ut.attacks[w]
					local format_string = "<span font_family='DejaVu Sans Mono'><b>%2i - %-2i</b></span>  %-6s %s"

					desc = desc .. "\n" .. string.format(format_string,attack.damage,attack.number,attack.range,attack.type)
					if #attack.specials > 0 then
						for s=1, #attack.specials do
							--debug_utils.dbms()
							desc = desc .. "\n                     <span color='gray'>" .. attack.specials[s][2].name .."</span>"
						end
					end
				end
				desc = desc .. "</span>"
				return desc 
			end

			local function add_branch(ut, start_level,page_to_add)
				local page_element = page_to_add.treeview_unit:add_item_of_type("recruit_line")
				local line = {}

				--adds placeholders for branching then adds the unit
				for i=1, start_level do
					table.insert(line, "placeholder")
				end
				table.insert(line,ut)
			
				local level = start_level

				--recursively form unit tree
				while #ut.advances_to > 0 do
					local new_advance = wesnoth.unit_types[ut.advances_to[1]]
					table.insert(line, new_advance)
					level = level+1
					if #ut.advances_to > 1 then
						for j=2, #ut.advances_to do
							add_branch(wesnoth.unit_types[ut.advances_to[j]],level,page_to_add)
						end
					end
					ut = new_advance
				end

				-- finishes out the rest of the row
				while #line < 4 do
					table.insert(line,"placeholder")
				end

				page_element.icon_1.label = type_icon(line[1])
				page_element.label_1.marked_up_text = type_desc(line[1])
				page_element.weapon_1.marked_up_text = type_weps(line[1])
				page_element.icon_2.label = type_icon(line[2])
				page_element.label_2.marked_up_text = type_desc(line[2])
				page_element.weapon_2.marked_up_text = type_weps(line[2])
				page_element.icon_3.label = type_icon(line[3])
				page_element.label_3.marked_up_text = type_desc(line[3])
				page_element.weapon_3.marked_up_text = type_weps(line[3])
				page_element.icon_4.label = type_icon(line[4])
				page_element.label_4.marked_up_text = type_desc(line[4])
				page_element.weapon_4.marked_up_text = type_weps(line[4])
			end

			---- add general factions topic ----
			local era_wml = wesnoth.scenario.era

			local node, root_page = root_node:add_help_page {
				title = str_cat_era
			}

			root_page.label_content.marked_up_text = str_des_era

			for i, faction_info in ipairs(cc_era.factions_wml) do
				local faction_wml = wml.get_child(era_wml, "multiplayer_side", faction_info.id)

				local subnode, sub_page = node:add_help_page {
					title = faction_info.name,
					page_type = "unit_tree",
					node_type = "subcategory",
				}

				local recruits = {}

				for p_wml in wml.child_range(faction_info, "pair") do
					local p = stringx.split(p_wml.types or "")

					table.insert(recruits,p[1])
					table.insert(recruits,p[2])
					--table.insert(recruits,p[2])
					
					--page_element.image1.label = type_icon(ut1)
					--page_element.label2.marked_up_text = ut2.name
					--page_element.image2.label = type_icon(ut2)

				end

				cc_utils.remove_duplicates(recruits)

				--debug_utils.dbms(recruits)
				for i=1, #recruits do
				
					local base_unit = wesnoth.unit_types[recruits[i]]

					add_branch(base_unit,0,sub_page)		
				end
				
			end
		end

		if show_help_settings then
			local node, page = root_node:add_help_page {
				title = str_cat_settings,
				page_type = "settings",
			}

			page.checkbox_use_markers.selected = not not wml.variables["cc_config_enable_unitmarker"]
			page.checkbox_use_markers.enabled = false
			page.checkbox_use_pickup.selected = not not wml.variables["cc_config_experimental_pickup"]
			page.checkbox_use_pickup.enabled = false
			page.checkbox_show_pickup_confirmation.selected = not cc_utils.global_vars.skip_pickup_dialog
			page.checkbox_show_pickup_confirmation.enabled = true

			page.label_difficulty.marked_up_text = wml.variables["cc_difficulty.name"] or "unknown"

			function page.checkbox_show_pickup_confirmation.on_modified()
				cc_utils.global_vars.skip_pickup_dialog = not page.checkbox_show_pickup_confirmation.selected
			end
		end

		root_node:focus()

		function root_node.on_modified()
			local selected_index = index_map[table.concat(root_node.selected_item_path, '_')]
			if selected_index ~= nil then
				details.selected_index = selected_index
			end
		end
	end

	gui.show_dialog(wml.get_child(dialog_wml, 'resolution'), preshow)
end

cc_utils.menu_item {
	id = "5_CC_Wocopedia_Option",
	description = _ "WoCopedia",
	image= "help/closed_section.png~SCALE(18,17)",
	synced = false,
	filter = function(x, y)
		local u = wesnoth.units.get(x, y)
		if cc_artifacts.is_item_at(x, y) then
			return false
		end
		return not (u and u.side == wesnoth.current.side)
	end,
	handler = function(ec)
		wesnoth.wml_actions.cc_show_wocopedia {
			x = ec.x1,
			y = ec.y1,
		}
	end
}
