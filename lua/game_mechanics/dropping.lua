-- general code related to dropping items, code taken from 'scenario with robots' add-on.
-- todo: maybe we coudl mainline this and merge it with the iterms.lua code ( this means
-- adding a mainline "pickup item" event that fires when a unit steops on an [item] and
-- would have the same features as this here)
local on_event = wesnoth.require("on_event")

local dropping = {}

dropping.remove_current_item = function(ec)
	wesnoth.interface.remove_item(ec.x1, ec.y1, dropping.current_item.name)
	dropping.item_taken = true
end

on_event("moveto", function(ec)
	local x = ec.x1
	local y = ec.y1
	local items = wesnoth.interface.get_items(x, y)
	for i, item in ipairs(items) do
		dropping.current_item = item
		dropping.item_taken = nil
		wesnoth.game_events.fire("cc_drop_pickup", x, y)
		if dropping.item_taken then
			wesnoth.interface.remove_item(x,y, item.name)
		end
		dropping.current_item = nil
		dropping.item_taken = nil
	end
end)

return dropping
