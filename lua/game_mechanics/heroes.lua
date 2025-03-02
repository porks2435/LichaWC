local T = wml.tag
local _ = wesnoth.textdomain 'wesnoth-cc'

local cc_heroes = {}
-- an array of wml tables, usually containing type,
cc_heroes.commander_overlay = "misc/wct-commander.png"
cc_heroes.hero_overlay = "misc/hero-icon.png"
cc_heroes.dialogues = {}
cc_heroes.trait_heroic = nil
cc_heroes.trait_expert = nil

if filesystem.have_file("./unittypedata.lua") then
	local data = wesnoth.require("./unittypedata.lua")
	for v,k in pairs(data) do
		cc_heroes.dialogues[v] = k
	end
end

function cc_heroes.find_dialogue(t)
	return cc_heroes.dialogues[t] or cc_heroes.dialogues.default
end

function cc_heroes.init_data()
	local cfg_heroic = cc_utils.get_cc_data("trait_heroic")
	local cfg_expert = cc_utils.get_cc_data("trait_expert")
	cc_heroes.trait_heroic = wml.get_child(wml.get_child(cfg_heroic, "trait_heroic"), "trait")
	cc_heroes.trait_expert = wml.get_child(wml.get_child(cfg_expert, "trait_expert"), "trait")
end

function cc_heroes.heroize(u)
	if not u then
		return
	end
	-- grab existing stat modifications if it exists
	local stat_table = cc_utils.grant_random_stats(u,40)
	cc_utils.rebuild_stat_block(u)
	u.hitpoints = u.max_hitpoints

	if not u:matches{ canrecruit = "yes" } then
		u:add_modification('trait', cc_heroes.trait_heroic)
	end
end

function cc_heroes.commander_overlay_object()
	return T.object {
		id = "cc_commander_overlay",
		T.effect {
			apply_to="overlay",
			add = cc_heroes.commander_overlay
		}
	}
end

function cc_heroes.hero_overlay_object()
	return T.object {
		id = "cc_hero_overlay",
		T.effect {
			apply_to="overlay",
			add = cc_heroes.hero_overlay
		}
	}
end
-- @a t the unit type id
-- @returns the content of [modifications] for a unit.
function cc_heroes.generate_traits(t)
	local res = {}

	if cc_heroes.trait_heroic then
		table.insert(res, T.trait (cc_heroes.trait_heroic))
	end
	for k,v in ipairs(cc_era.hero_traits) do
		if v.types[t] then
			table.insert(res, T.trait (v.trait))
		end
	end
	return res
end

-- @a t the unit type
function cc_heroes.place(t, side, x, y, is_commander)
	--print("cc_heroes.place type=" .. t .. " side=" .. side)

	local u = wesnoth.units.create {
		type = t,
		side = side,
		random_traits = true,
		role = is_commander and "commander" or nil,
		--T.modifications (modifications),
	}
	if is_commander then
		u.variables["cc.is_commander"] = true
		cc_heroes.heroize(u)
	end
	local x2,y2 = wesnoth.paths.find_vacant_hex(x, y, u)
	u:to_map(x2,y2)
	return u
end

function wesnoth.wml_actions.cc_random_hero(cfg)
	local side_num = cfg.side or wml.error("missing side= attribute in [cc_initial_hero]")
	local x = cfg.x or wml.error("missing x= attribute in [cc_initial_hero]")
	local y = cfg.y or wml.error("missing y= attribute in [cc_initial_hero]")
	local t = cc_era.pick_deserter(side_num)

	if t == nil then
		print("No deserter available for side", side_num)
		return
	end
	cc_heroes.place(t, side_num, x, y)
end

-- prints the dialoge when @finder finds @found from a unit type, both parameters are lua unit objects.
function cc_heroes.founddialouge(finder, found)
	local type_dialogue = cc_heroes.find_dialogue(found.type)
	wesnoth.wml_actions.message {
		id = found.id,
		message = type_dialogue.founddialogue,
	}
	local reply = type_dialogue.reply or cc_heroes.dialogues.default.reply

	for i, alt_replay in ipairs(type_dialogue.alt_reply or {}) do
		local function matches(attr)
			return string.match(alt_replay[attr] or "", finder[attr])
		end
		if matches("race") or matches("gender") or matches("type") then
			reply = alt_replay.reply
		end
	end
	wesnoth.wml_actions.message {
		id = finder.id,
		message = reply,
	}
end

cc_heroes.init_data()

return cc_heroes
