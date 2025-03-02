local _ = wesnoth.textdomain 'wesnoth-cc'
local on_event = wesnoth.require "on_event"

local training = {}


function training.add_training_data(a)
	training.trainers = training.trainers or {}
	table.insert(training.trainers, a)
end

function training.read_wml_data(cfg)
	for i, t in ipairs(cc_convert.wml_to_lon(cfg, "cc_trainer_list").trainer or {}) do
		training.add_training_data(t)
	end
end

function training.get_list()
	if not training.trainers then
		training.init_data()
	end
	return training.trainers
end

function training.init_data()
	local cfg = cc_utils.get_cc_data("trainer")
	for i, t in ipairs(cc_convert.wml_to_lon(cfg, "cc_trainer_list").trainer or {}) do
		training.add_training_data(t)
	end
end

function training.get_trainer(trainer)
	return training.get_list()[trainer]
end


function training.get_chances(trainer, grade)
	return training.get_trainer(trainer).grade[grade + 1].chance
end

function training.apply_trait(u, trait, check)
	if u:matches(check) and u:matches( wml.tag.filter_wml { wml.tag.modifications { wml.tag.trait { id = trait.id } } } ) then
		u:add_modification("trait", trait)
	else
		u:add_modification("object", { wml.tag.effect { apply_to  = "hitpoints", increase_total = 1, heal_full = true}})
	end
end


--the current level of a certain traing, a value of 0 means this skill wasn't trained yet.
function training.get_level(side_num, trainer)
	return wesnoth.sides[side_num].variables["cc.training[" .. trainer - 1 .. "].level"] or 0
end

function training.set_level(side_num, trainer, level)
	wesnoth.sides[side_num].variables["cc.training[" .. trainer - 1 .. "].level"] = level
end

function training.inc_level(side, trainer, level)
	local new_level = training.get_level(side, trainer) + (level or 1)
	if new_level < 0 or new_level >= #training.get_trainer(trainer).grade then
		error("training level out of range")
	end
	training.set_level(side, trainer, new_level)
end

-- to be used by bonus points chance to extra taining.
function training.get_level_sum(side)
	local res = 0
	for i = 1, #training.get_list() do
		res = res + training.get_level(side, i)
	end
	return res
end

function training.trainings_left(side_num, trainer)
	return (#training.get_trainer(trainer).grade - 1) - training.get_level(side_num, trainer)
end

function training.available(side_num, trainer, amount)
	return training.trainings_left(side_num, trainer) >= (amount or 1)
end

function training.has_max_training(side_num, trainer, amount)
	return training.available(side_num, trainer) == 0
end

function training.list_available(side_num, among, amount)
	local av = among or cc_utils.range(#training.get_list())
	local res = {}
	for i,v in ipairs(av) do
		local j = tonumber(v)
		if training.available(side_num, j, amount) then
			table.insert(res, j)
		end
	end
	return res
end

function training.find_available(side_num, among, amount)
	local possible_traintypes = training.list_available(side_num, among, amount)
	if #possible_traintypes == 0 then
		return
	else
		return possible_traintypes[mathx.random(#possible_traintypes)]
	end
end

function training.describe_training_level(name, level, max_level)
	if level == max_level then
		return tostring(stringx.vformat(_ "$name <span color='yellow'>[☆]</span>", {
			name = name
		}))
	else
		return tostring(stringx.vformat(_ "$name [$level]", {
			name = name,
			level = level
		}))
	end
end

function training.describe_training_level2(level, max_level)
	if level == max_level then
		return _ "Maximum Level"
	else
		return tostring(stringx.vformat(_ "level $level", {
			level = level
		}))
	end
end

function training.generate_message(n_trainer, n_grade)
	local c_trainer = training.get_trainer(n_trainer)
	local c_grade = c_trainer.grade[n_grade + 1]
	if c_grade == nil then
		return { message = "" }
	end
	local caption = training.describe_training_level(c_trainer.name, n_grade, #c_trainer.grade - 1)
	local messages = {}
	for unused, chance in ipairs(c_grade.chance) do
		local vchance = chance.variable_substitution ~= false and wml.tovconfig(chance) or chance
		if (chance.value or 0) <= 100 then
			local str = stringx.vformat(_ "$chance|%</span> $arrow $desc", {
				--chance = ("%d%%"):format(vchance.value),
				chance = string.format("<span font_family='DejaVu Sans Mono' font_weight='bold'>%4d",vchance.value),
				desc = cc_utils.get_fstring(chance, "info"),
				arrow = cc_color.tc_text(" → ")
			})
			table.insert(messages, tostring(str))
		else
			table.insert(messages, tostring(cc_utils.get_fstring(chance, "info")))
		end
	end
	return {
		caption = caption,
		message = table.concat(messages, "\n"),
		speaker = "narrator",
		image = c_trainer.image,
	}
end

on_event("recruit,post advance", function(ec)
	training.apply(wesnoth.units.get(ec.x1, ec.y1), 1.0)
end)

on_event("recall", function(ec)
	training.apply(wesnoth.units.get(ec.x1, ec.y1), 0.5)
end)

function training.apply(u, modifier)
	if not u then
		return
	end

	local train_mod = modifier or 1

	local side = u.side
	local trait = {}	
	local descriptions = {}
	trait.generate_description = false
	trait.id = "trained"
	--local stat_table = cc_utils.verify_stat_block(u)

	if not u.variables["train_bonus"] then
		u.variables["train_bonus"] = ""
	end

	local update_table = u.variables["stat_bonus"] or {}
	local compensation = 0

	for i, trainer in ipairs(training.get_list()) do
		local level = training.get_level(side, i) or 0
		for unused, chance in ipairs(training.get_chances(i, level)) do
			--some effects use expressions like $(5+{GRADE}) so we want variable_substitution there
			local vchance = wml.tovconfig(chance)
			local filter = wml.get_child(vchance, "filter")
			local matches_filter = (not filter) or u:matches(filter)
			if mathx.random(100) <= vchance.value * train_mod then
				-- if it matches filter, add training effect
				if matches_filter then
					-- if stat bonus, don't bother adding to trait
					if vchance.apply_to then
						local bonus = tostring(vchance.apply_to)
						if update_table[bonus] then
							update_table[bonus] = update_table[bonus] + vchance.increase
						else
							update_table[bonus] = vchance.increase
						end
					else
						u.variables["train_bonus"] = u.variables["train_bonus"] .. "\n" .. cc_utils.get_fstring(chance, "info")
						for effect in wml.child_range(vchance, "effect") do
							table.insert(trait, {"effect", effect })
						end
					end
				-- otherwise compensate with +2 in a random stat category
				else
					compensation = compensation + 1
				end
			end
		end
	end
	trait.description = cc_utils.concat(descriptions, "\n")
	if #trait > 0 then
		u:add_modification("trait", trait)
	end

	u.variables["stat_bonus"] = update_table
	cc_utils.grant_random_stats(u, compensation)
	--u.variables["stat_bonus"] = table.concat(stat_table, ",")

	cc_utils.rebuild_stat_block(u)
	u.variables.cc_trained = true
	u.hitpoints = u.max_hitpoints
end

function wesnoth.wml_actions.cc_apply_training(cfg)
	for i,u in ipairs(wesnoth.units.find_on_map(cfg)) do
		training.apply(u)
	end
end

function wesnoth.wml_actions.cc_give_random_training(cfg)
	local side_num = cfg.side
	local amount = cfg.amount or 1
	local among = cfg.among and stringx.split(cfg.among or "")
	for i = 1, amount do
		local traintype = training.find_available(side_num, among)
		if traintype == nil then error("cc_give_random_training: everything already maxed") end
		training.inc_level(side_num, traintype, 1)
	end
end

function training.describe_bonus(side, traintype)
	local traintype_data = training.get_trainer(traintype)
	local cur_level = training.get_level(side, traintype)
	local max_level = #traintype_data.grade - 1
	local image = wesnoth.unit_types[traintype_data.type].__cfg.image
	local message = nil
	if cur_level == max_level then
		message = _"Nothing to learn here"
	else
		message = stringx.vformat(_"From $level_before to $level_after", {
			level_before = training.describe_training_level(traintype_data.name, cur_level, max_level),
			level_after = training.describe_training_level(traintype_data.name, cur_level + 1, max_level)
		})
	end
	return message, image
end

return training
