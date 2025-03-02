local _ = wesnoth.textdomain 'wesnoth-wc'

function wesnoth.wml_actions.grant_bexp(cfg)
	local units = wesnoth.units.find_on_map(cfg)
	for i, u in ipairs(units) do
		u.experience = u.experience+8
		u:advance(true, true)

		wesnoth.sides[u.side].variables["bonus_XP"] = wesnoth.sides[u.side].variables["bonus_XP"] - 8
	end
end

cc_utils.menu_item {
	id = "Bonus_XP",
	description = _ "Grant +8 BEXP to this unit",
	image= "misc/BEXP.png",
	filter = function(x, y)
		local u = wesnoth.units.get(x, y)
		local cmd = wesnoth.units.find_on_map { canrecruit = true , side = wesnoth.current.side }[1]

		local is_adjacent = false

		if u and cmd then
			if math.abs(u.x - cmd.x) <= 1 and math.abs(u.y - cmd.y) <= 1 then
				is_adjacent = true
			end
		end

		return u and u.side == wesnoth.current.side and not u:matches { canrecruit = true} and is_adjacent and wesnoth.sides[u.side].variables["bonus_XP"] >= 8 
	end,
	handler = function(cx)
		wesnoth.wml_actions.grant_bexp {
			x = cx.x1,
			y = cx.y1,
		}
		wesnoth.allow_undo(false)
	end
}
