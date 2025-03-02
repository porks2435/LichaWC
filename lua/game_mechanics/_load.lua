
-- Loads the CC 'engine' that is making bonus points, items, training etc work.

cc_convert = wesnoth.require("./../shared_utils/wml_converter.lua")

cc_ability_events = wesnoth.require("./events_abilities.lua")
cc_damage_events = wesnoth.require("./events_damage.lua")
cc_terraforming_events = wesnoth.require("./events_terraforming.lua")
cc_artifacts = wesnoth.require("./artifacts.lua")
cc_bonus = wesnoth.require("./bonus.lua")
cc_color = wesnoth.require("./color.lua")
cc_dropping = wesnoth.require("./dropping.lua")
cc_effects = wesnoth.require("./effects.lua")
cc_heroes = wesnoth.require("./heroes.lua")
cc_pickup_confirmation_dialog = wesnoth.require("./pickup_confirmation_dialog.lua")
cc_random_names = wesnoth.require("./random_names.lua")
cc_recall = wesnoth.require("./recall.lua")
cc_supply = wesnoth.require("./supply.lua")
cc_training = wesnoth.require("./training.lua")
cc_unittypedata = wesnoth.require("./unittypedata.lua")
cc_utils = wesnoth.require("./utils.lua")
cc_interface = wesnoth.require("./interface.lua")
cc_status_effects = wesnoth.require("./status_effects.lua")


bonus_xp = wesnoth.require "./bexp.lua"
debug_utils = wesnoth.require "./debug_utils.lua"

cc_wiki = wesnoth.require("./wocopedia/help.lua")

cc_invest = wesnoth.require("./invest/invest.lua")
cc_invest_show_dialog = wesnoth.require("./invest/invest_show_dialog.lua")
cc_invest_tellunit = wesnoth.require("./invest/invest_tellunit.lua")

wesnoth.require("./promote_commander.lua")
