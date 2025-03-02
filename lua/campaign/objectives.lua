--creates the objectives of the cc scenarios.

local _ = wesnoth.textdomain 'wesnoth-cc'
local _lib = wesnoth.textdomain 'wesnoth-lib'
local strings = {
	cc_victory_condition = _"Defeat all enemy leaders and commanders",
	turns = _"Turns run out",
	cc_defeat_condition = _ "Lose your leader and all your commanders",
	difficulty = _lib("Difficulty: "),
	help_available = _ "An in-game help is available: right-click on any empty hex.",
}

function wesnoth.wml_actions.cc_objectives(cfg)
	wesnoth.wml_actions.objectives {
		wml.tag.objective {
			description = strings.cc_victory_condition,
			condition = "win",
		},
		wml.tag.objective {
			description = strings.turns,
			condition = "lose",
		},
		wml.tag.objective {
			description = strings.cc_defeat_condition,
			condition = "lose",
		},
		wml.tag.note {
			description = strings.difficulty .. wml.variables["cc_difficulty.name"],
		},
		note = cc_color.help_text(strings.help_available)
	}
end
