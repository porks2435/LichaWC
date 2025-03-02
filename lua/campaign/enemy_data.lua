
-- The rules for enemy recruitlist are as follows:
-- each side Has a 'faction' (here: group) a leader from that faction and maybe a leader from another faction.
-- the enemy side can then recruit all units from its faction and from all it's leaders, that why having
-- unit {recruit= that are already contained in {recruit= is not redundant.
local enemy_army = {}
enemy_army.group = {
	{
		id = "fae",
		recruit = {"Fae Sprite","Fae Pixie","Fae Seelie","Fae Songstress","Flower Fae"},
		recall = {
			level2 = {"Fae Bloomtender","Fae Silkwing","Fae Soul Guide","Fae Siren","Fae Rusalka","Fae Bristler","Fae Hermit"},
			level3 = {"Anthousai","Aurae","Lampade","Pleiade","Nereid","Limnaioi","Thyiade","Dryad","Oread","Anthousai","Aurae","Lampade","Pleiade","Nereid","Limnaioi","Thyiade","Dryad","Oread","Hamadryad"},
		},
		commander = {
			level1 = {"Fae Sprite","Fae Pixie","Fae Seelie","Fae Songstress","Flower Fae"},
			level2 = {"Fae Bloomtender","Fae Silkwing","Fae Soul Guide","Fae Siren","Fae Rusalka","Fae Bristler","Fae Hermit"},
			level3 = {"Anthousai","Aurae","Lampade","Pleiade","Nereid","Limnaioi","Thyiade","Dryad","Oread",},
		},
		leader = {
			{
				level2 = "Fae Silkwing",
				level3 = "Aurae",
				recruit = {"Fae Silkwing"},
			},
			{
				level2 = "Fae Siren",
				level3 = "Nereid",
				recruit = {"Fae Siren"},
			},
			{
				level2 = "Fae Bristler",
				level3 = "Hamadryad",
				recruit = {"Fae Bristler"},
			},
			{
				level2 = "Fae Hermit",
				level3 = "Oread",
				recruit = {"Fae Hermit"},
			},
			{
				level2 = "Fae Soul Guide",
				level3 = "Lampade",
				recruit = {"Fae Soul Guide"},
			}
		}
	},
	{
		id = "centaurs",
		recruit = {"Centaur Raider","Centaur Draugr","Centaur Draugr","Centaur Witness","Centaur Seer","Shadow of the Hunt","Fel Omen","Deadwood","Ancestral Protector","Fel Omen"},
		recall = {
			level2 = {"Centaur Reaver","Centaur Heedless","Centaur Eulogist","Centaur Soothsayer","Specter of the Hunt","Gravewaker","Ancestral Fury","Haunted Deadwood"},
			level3 = {"Centaur Einherjar","Centaur Skald","Centaur Valkyrie","Centaur Oracle","Cursed Deadwood","Centaur Dullahan","Centaur Heedless","Centaur Einherjar","Centaur Skald","Centaur Valkyrie","Centaur Oracle","Cursed Deadwood","Centaur Dullahan","Centaur Heedless","Underworld Tree"},
		},
		commander = {
			level1 = {"Centaur Raider","Centaur Draugr","Centaur Draugr","Centaur Witness","Centaur Seer","Shadow of the Hunt","Fel Omen","Deadwood","Ancestral Protector","Fel Omen"},
			level2 = {"Centaur Reaver","Centaur Heedless","Centaur Eulogist","Centaur Soothsayer","Specter of the Hunt","Gravewaker","Ancestral Fury","Haunted Deadwood"},
			level3 = {"Centaur Einherjar","Centaur Skald","Centaur Valkyrie","Centaur Oracle","Cursed Deadwood","Centaur Dullahan"},
		},
		leader = {
			{
				level2 = "Centaur Reaver",
				level3 = "Centaur Einherjar",
				recruit = {"Centaur Reaver"},
			},
			{
				level2 = "Haunted Deadwood",
				level3 = "Underworld Tree",
				recruit = {"Haunted Deadwood"},
			},
			{
				level2 = "Centaur Eulogist",
				level3 = "Centaur Valkyrie",
				recruit = {"Centaur Eulogist"},
			},
			{
				level2 = "Centaur Soothsayer",
				level3 = "Centaur Oracle",
				recruit = {"Centaur Soothsayer"},
			},
			{
				level2 = "Centaur Heedless",
				level3 = "Centaur Dullahan",
				recruit = {"Centaur Heedless"},
			}
		}
	},
	{
		id = "windsong",
		recruit = {"Seeker","Scribe","Weaver","Sky Shard","Courier","Gatekeeper"},
		recall = {
			level2 = {"Envoy","Skyrunner","Pathfinder","Heretic","Heretic","Lorekeeper","Emissary","Reaver","Reaver","Savant"},
			level3 = {"Herald","Stormbringer","Warmonger","Oathkeeper","Dreadnought","Arbiter","Herald","Stormbringer","Warmonger","Oathkeeper","Dreadnought","Arbiter","Rune Forger","Librarian"},
		},
		commander = {
			level1 = {"Seeker","Scribe","Weaver","Sky Shard","Courier","Gatekeeper"},
			level2 = {"Envoy","Skyrunner","Pathfinder","Heretic","Emissary","Reaver","Savant"},
			level3 = {"Stormbringer","Warmonger","Dreadnought","Arbiter","Herald"},
		},
		leader = {
			{
				level2 = "Lorekeeper",
				level3 = "Oathkeeper",
				recruit = {"Heretic"},
			},
			{
				level2 = "Envoy",
				level3 = "Herald",
				recruit = {"Envoy"},
			},
			{
				level2 = "Savant",
				level3 = "Librarian",
				recruit = {"Savant"},
			},
			{
				level2 = "Emissary",
				level3 = "Dreadnought",
				recruit = {"Reaver"},
			},
			{
				level2 = "Skyrunner",
				level3 = "Stormbringer",
				recruit = {"Skyrunner"},
			}
		}
	},
	{
		id = "celestials",
		recruit = {"Crusader","Legionnaire","Fire Nun","Zealot","Traveling Quack","Wizard","Messenger","Skylark"},
		recall = {
			level2 = {"Holy Knight","Holy Executor","Sister of the Flame","Keeper","Claimant","Traveling Healer","Traveling Surgeon","Battle Wizard","Mystic","Militant","Lantern Archon"},
			level3 = {"Holy Champion","Sentinel","Keeper of the Flame","Exalted","Traveling Doctor","Sage","Prophet","Sicarius","Holy Champion","Sentinel","Keeper of the Flame","Exalted","Traveling Doctor","Sage","Prophet","Sicarius","Savior"},
		},
		commander = {
			level1 = {"Crusader","Legionnaire","Fire Nun","Zealot","Traveling Quack","Wizard","Messenger"},
			level2 = {"Holy Knight","Holy Executor","Sister of the Flame","Keeper","Claimant","Traveling Healer","Traveling Surgeon","Battle Wizard","Mystic","Militant","Lantern Archon"},
			level3 = {"Holy Champion","Holy Inquisitor","Sentinel","Keeper of the Flame","Exalted","Traveling Doctor","Sage","Prophet","Sicarius"},
		},
		leader = {
			{
				level2 = "Sister of the Flame",
				level3 = "Keeper of the Flame",
				recruit = {"Holy Executor"},
			},
			{
				level2 = "Holy Knight",
				level3 = "Holy Champion",
				recruit = {"Holy Knight"},
			},
			{
				level2 = "Keeper",
				level3 = "Sentinel",
				recruit = {"Claimant"},
			},
			{
				level2 = "Battle Wizard",
				level3 = "Sage",
				recruit = {"Battle Wizard"},
			},
			{
				level2 = "Mystic",
				level3 = "Savior",
				recruit = {"Militant"},
			}
		}
	},
	{
		id = "steelhive",
		recruit = {"Steel Slasher","Steel Oculus","Steel Impaler","Steel Wyrm","Steel Hedron"},
		recall = {
			level2 = {"Steel Vector","Steel Cataract","Steel Skewer","Steel Serpent","Steel Choron","Steel Splicer","Steel Vector","Steel Cataract","Steel Skewer","Steel Serpent","Steel Splicer"},
			level3 = {"Steel Vorpal","Steel Fideliant","Steel Astigmatic","Steel Dreadnought","Steel Leviathan","Steel Syren","Steel Vorpal","Steel Fideliant","Steel Astigmatic","Steel Dreadnought","Steel Leviathan","Steel Syren","Steel Kataphrakt"},
		},
		commander = {
			level1 = {"Steel Slasher","Steel Oculus","Steel Impaler","Steel Wyrm","Steel Hedron"},
			level2 = {"Steel Vector","Steel Cataract","Steel Skewer","Steel Serpent","Steel Choron","Steel Splicer"},
			level3 = {"Steel Vorpal","Steel Fideliant","Steel Astigmatic","Steel Dreadnought","Steel Leviathan","Steel Syren"},
		},
		leader = {
			{
				level2 = "Steel Cataract",
				level3 = "Steel Astigmatic",
				recruit = {"Steel Cataract"},
			},
			{
				level2 = "Steel Vector",
				level3 = "Steel Vorpal",
				recruit = {"Steel Vector"},
			},
			{
				level2 = "Steel Skewer",
				level3 = "Steel Dreadnought",
				recruit = {"Steel Skewer"},
			},
			{
				level2 = "Steel Serpent",
				level3 = "Steel Leviathan",
				recruit = {"Steel Splicer"},
			},
			{
				level2 = "Steel Syren",
				level3 = "Steel Syren",
				recruit = {"Steel Vector"},
			}
		}
	},
	{
		id = "aberrant",
		recruit = {"Unhatched","Howling Darkness","Life Thief","Black Cat","Unstable Elemental","Scornful Watcher","Little Thing"},
		recall = {
			level2 = {"Angry One","Rash One","Cloud of Gloom","Jinx Beast","Nature Wrath","Shredder Spawn","Spiteful Watcher","Thing","False Thing","Soul Snatcher","Angry One","Rash One","Cloud of Gloom","Jinx Beast","Nature Wrath","Spiteful Watcher","Thing","False Thing"},
			level3 = {"Raging One","Reckless One","Eternal Night","Inquisitor","Ripper Beast","Calamity","Death Spectre","Raging One","Reckless One","Eternal Night","Inquisitor","Ripper Beast","Calamity","Big Thing","Death Spectre","The Thing"},
		},
		commander = {
			level1 = {"Unhatched","Howling Darkness","Life Thief","Black Cat","Unstable Elemental","Scornful Watcher","Little Thing"},
			level2 = {"Angry One","Rash One","Cloud of Gloom","Jinx Beast","Nature Wrath","Shredder Spawn","Spiteful Watcher","Thing","False Thing","Soul Snatcher"},
			level3 = {"Raging One","Reckless One","Eternal Night","Inquisitor","Ripper Beast","Calamity","Big Thing","Death Spectre"},
		},
		leader = {
			{
				level2 = "Angry One",
				level3 = "Raging One",
				recruit = {"Angry One"},
			},
			{
				level2 = "Jinx Beast",
				level3 = "Calamity",
				recruit = {"Nature Wrath"},
			},
			{
				level2 = "Spiteful Watcher",
				level3 = "Inquisitor",
				recruit = {"Spiteful Watcher"},
			},
			{
				level2 = "False Thing",
				level3 = "The Thing",
				recruit = {"False Thing"},
			},
			{
				level2 = "Soul Snatcher",
				level3 = "Death Spectre",
				recruit = {"Soul Snatcher"},
			}
		}
	},
	{
		id = "quenoth",
		recruit = {"Quenoth Scout","Quenoth Fighter","Tauroch Rider","Quenoth Mystic","Quenoth Irregular"},
		recall = {
			level2 = {"Quenoth Warrior","Tauroch Vanguard","Tauroch Stalwart","Quenoth Sun Singer","Quenoth Shaman","Quenoth Archer","Quenoth Pathfinder","Quenoth Viper","Naga Shield Guard","Naga Ringcaster","Quenoth Warrior","Tauroch Vanguard","Tauroch Stalwart","Quenoth Sun Singer","Quenoth Shaman","Quenoth Archer","Quenoth Pathfinder","Quenoth Viper"},
			level3 = {"Quenoth Champion","Quenoth Reaver","Tauroch Protector","Tauroch Flagbearer","Quenoth Marksman","Quenoth Outrider","Quenoth Druid","Quenoth Wraith","Quenoth Scourge","Naga High Guard","Naga Zephyr","Quenoth Champion","Quenoth Reaver","Tauroch Protector","Tauroch Flagbearer","Quenoth Sun Sylph","Quenoth Marksman","Quenoth Outrider","Quenoth Druid","Quenoth Wraith","Quenoth Scourge","Naga High Guard","Naga Zephyr","Quenoth Shyde"},
		},
		commander = {
			level1 = {"Quenoth Scout","Quenoth Fighter","Tauroch Rider","Quenoth Mystic","Quenoth Irregular"},
			level2 = {"Quenoth Warrior","Tauroch Vanguard","Tauroch Stalwart","Quenoth Sun Singer","Quenoth Shaman","Quenoth Archer","Quenoth Pathfinder","Quenoth Viper","Naga Shield Guard","Naga Ringcaster"},
			level3 = {"Quenoth Champion","Quenoth Reaver","Tauroch Protector","Tauroch Flagbearer","Quenoth Sun Sylph","Quenoth Marksman","Quenoth Outrider","Quenoth Druid","Quenoth Wraith","Quenoth Scourge"},
		},
		leader = {
			{
				level2 = "Quenoth Warrior",
				level3 = "Quenoth Champion",
				recruit = {"Quenoth Warrior"},
			},
			{
				level2 = "Tauroch Vanguard",
				level3 = "Tauroch Flagbearer",
				recruit = {"Tauroch Vanguard"},
			},
			{
				level2 = "Quenoth Sun Singer",
				level3 = "Quenoth Sun Sylph",
				recruit = {"Quenoth Sun Singer"},
			},
			{
				level2 = "Quenoth Archer",
				level3 = "Quenoth Marksman",
				recruit = {"Quenoth Archer"},
			},
			{
				level2 = "Quenoth Druid",
				level3 = "Quenoth Shyde",
				recruit = {"Quenoth Pathfinder"},
			}
		}
	},
	{
		id = "mandate",
		recruit = {"Terracotta Warrior","Kobold","Jiangshi","Mangus","Jorogumo","Vixen Witch", "Worm"},
		recall = {
			level2 = {"Terracotta Sergeant","Kobold Cannoneer","Kobold Chukonu","Kobold Fire Lancer","Kheshig","Umbral Mandarin","Death Weaver","Vixen Shaman","Vixen Huntress","Hydra","Terracotta Sergeant","Kobold Cannoneer","Kobold Chukonu","Kobold Fire Lancer","Kheshig","Death Weaver","Vixen Shaman","Vixen Huntress","Hydra"},
			level3 = {"Eye of Abyss","Kobold Bombardier","Kobold Arrowstorm","Yelbeghen","Chthonic Empress","Terracotta Bannerlord","Vixen Predator","Avraga Mogoi","Eye of Abyss","Kobold Bombardier","Kobold Arrowstorm","Yelbeghen","Chthonic Empress","Terracotta Bannerlord","Vixen Fangshi","Vixen Predator","Avraga Mogoi","Ruinator Dynast"},
		},
		commander = {
			level1 = {"Terracotta Warrior","Kobold","Jiangshi","Mangus","Jorogumo","Vixen Witch", "Worm"},
			level2 = {"Terracotta Sergeant","Kobold Cannoneer","Kobold Chukonu","Kobold Fire Lancer","Kheshig","Umbral Mandarin","Death Weaver","Vixen Shaman","Vixen Huntress","Hydra"},
			level3 = {"Eye of Abyss","Kobold Bombardier","Kobold Arrowstorm","Yelbeghen","Chthonic Empress","Terracotta Bannerlord","Vixen Fangshi","Vixen Predator","Avraga Mogoi"},
		},
		leader = {
			{
				level2 = "Terracotta Sergeant",
				level3 = "Terracotta Bannerlord",
				recruit = {"Terracotta Sergeant"},
			},
			{
				level2 = "Kobold Cannoneer",
				level3 = "Kobold Bombardier",
				recruit = {"Kobold Chukonu"},
			},
			{
				level2 = "Kheshig",
				level3 = "Yelbeghen",
				recruit = {"Kheshig"},
			},
			{
				level2 = "Vixen Shaman",
				level3 = "Vixen Fangshi",
				recruit = {"Vixen Shaman"},
			},
			{
				level2 = "Hydra",
				level3 = "Avraga Mogoi",
				recruit = {"Hydra"},
			}
		}
	},
	{
		id = "harpies",
		recruit = {"Harpy Falconeer","Harpy Fighter","Harpy Minstrel","Harpy Rockthrower","Harpy Traveller","Night Harpy"},
		recall = {
			level2 = {"Harpy Flagbearer","Harpy Raptortongue","Harpy Pirate","Harpy Captivator","Harpy Galesinger","Harpy Bomber","Harpy Messenger","Harpy Stalkerwing","Harpy Parader","Harpy Raptortongue","Harpy Pirate","Harpy Galesinger","Harpy Bomber","Harpy Parader"},
			level3 = {"Harpy Featherlord","Harpy Flockmaster","Harpy Raider","Harpy Enchantress","Harpy Ashtail","Harpy Emissary","Harpy Phantom","Harpy Shrieker","Resplendent Harpy","Harpy Featherlord","Harpy Flockmaster","Harpy Raider","Harpy Enchantress","Harpy Stormcaller","Harpy Ashtail","Harpy Emissary","Harpy Phantom","Harpy Shrieker","Resplendent Harpy","Harpy Siren"},
		},
		commander = {
			level1 = {"Harpy Falconeer","Harpy Fighter","Harpy Minstrel","Harpy Rockthrower","Harpy Traveller","Night Harpy"},
			level2 = {"Harpy Flagbearer","Harpy Raptortongue","Harpy Pirate","Harpy Captivator","Harpy Galesinger","Harpy Bomber","Harpy Messenger","Harpy Stalkerwing"},
			level3 = {"Harpy Featherlord","Harpy Flockmaster","Harpy Raider","Harpy Enchantress","Harpy Stormcaller","Harpy Ashtail","Harpy Emissary","Harpy Phantom","Harpy Shrieker"},
		},
		leader = {
			{
				level2 = "Harpy Stalkerwing",
				level3 = "Harpy Featherlord",
				recruit = {"Harpy Stalkerwing"},
			},
			{
				level2 = "Harpy Raptortongue",
				level3 = "Harpy Flockmaster",
				recruit = {"Harpy Raptortongue"},
			},
			{
				level2 = "Harpy Pirate",
				level3 = "Harpy Raider",
				recruit = {"Harpy Pirate"},
			},
			{
				level2 = "Harpy Galesinger",
				level3 = "Harpy Enchantress",
				recruit = {"Harpy Galesinger"},
			},
			{
				level2 = "Harpy Bomber",
				level3 = "Harpy Ashtail",
				recruit = {"Harpy Bomber"},
			}
		}
	},
	{
		id = "uruk",
		recruit = {"Orcish Knave","Orcish Rider","Orcish Slinger","Orcish Drifter","Rat Rider","Stork Rider"},
		recall = {
			level2 = {"Orcish Cavalry","Orcish Hunter","Orcish Fireline","Orcish Foreman","Orcish Raider","Orcish Wanderer","Stork Master","Rat Lancer","Orcish Hunter","Orcish Fireline","Orcish Foreman","Orcish Raider","Orcish Wanderer"},
			level3 = {"Orcish Destrier","Orcish Stalker","Orcish Firebreather","Orcish Overseer","Orcish Terror","Orcish Traveler","Rat Dragoon","Orcish Stalker","Orcish Firebreather","Orcish Overseer","Orcish Terror","Orcish Traveler","Rat Dragoon","Orcish Beorn"},
		},
		commander = {
			level1 = {"Orcish Knave","Orcish Rider","Orcish Slinger","Orcish Drifter","Rat Rider","Stork Rider"},
			level2 = {"Orcish Cavalry","Orcish Hunter","Orcish Fireline","Orcish Foreman","Orcish Raider","Orcish Wanderer","Stork Master","Rat Lancer"},
			level3 = {"Orcish Destrier","Orcish Stalker","Orcish Firebreather","Orcish Overseer","Orcish Terror","Orcish Traveler","Rat Dragoon"},
		},
		leader = {
			{
				level2 = "Orcish Cavalry",
				level3 = "Orcish Destrier",
				recruit = {"Orcish Cavalry"},
			},
			{
				level2 = "Orcish Hunter",
				level3 = "Orcish Stalker",
				recruit = {"Orcish Hunter"},
			},
			{
				level2 = "Orcish Fireline",
				level3 = "Orcish Overseer",
				recruit = {"Orcish Fireline"},
			},
			{
				level2 = "Orcish Raider",
				level3 = "Orcish Beorn",
				recruit = {"Orcish Raider"},
			},
			{
				level2 = "Rat Lancer",
				level3 = "Rat Dragoon",
				recruit = {"Rat Lancer"},
			}
		}
	},
	{
		id = "clockwork_dwarves",
		recruit = {"Dwarvish Soldier","Dwarvish Triggerman","Dwarvish Greaser","Dwarvish Wanderer","Wooden Bird","Steam Ulfserker","Clockwork Automata"},
		recall = {
			level2 = {"Dwarvish Marshal","Dwarvish Miasmist","Dwarvish Gunner","Dwarvish Rambler","Steel Eagle","Dwarvish Oiler","Steam Berserker","Clockwork Secutor","Clockwork Salvager","Clockwork Ballista","Dwarvish Marshal","Dwarvish Miasmist","Dwarvish Gunner","Dwarvish Rambler"},
			level3 = {"Dwarvish Mechanic","Dwarvish Blazer","Dwarvish General","Dwarvish Gas Baron","Dwarvish Artillery","Steam Turboserker","Dwarvish Mechanic","Dwarvish Blazer","Dwarvish General","Dwarvish Gas Baron","Dwarvish Artillery","Dwarvish Itinerant","Steam Turboserker","Clockwork Centurion","Dwarvish Titan Pilot"},
		},
		commander = {
			level1 = {"Dwarvish Soldier","Dwarvish Triggerman","Dwarvish Greaser","Dwarvish Wanderer","Wooden Bird","Steam Ulfserker"},
			level2 = {"Dwarvish Marshal","Dwarvish Miasmist","Dwarvish Gunner","Dwarvish Rambler","Steel Eagle","Dwarvish Oiler","Steam Berserker"},
			level3 = {"Dwarvish Mechanic","Dwarvish Blazer","Dwarvish General","Dwarvish Gas Baron","Dwarvish Artillery","Dwarvish Itinerant","Steam Turboserker"},
		},
		leader = {
			{
				level2 = "Dwarvish Marshal",
				level3 = "Dwarvish General",
				recruit = {"Dwarvish Marshal"},
			},
			{
				level2 = "Dwarvish Rambler",
				level3 = "Dwarvish Itinerant",
				recruit = {"Dwarvish Rambler"},
			},
			{
				level2 = "Dwarvish Miasmist",
				level3 = "Dwarvish Gas Baron",
				recruit = {"Dwarvish Miasmist"},
			},
			{
				level2 = "Dwarvish Gunner",
				level3 = "Dwarvish Artillery",
				recruit = {"Dwarvish Gunner"},
			},
			{
				level2 = "Dwarvish Oiler",
				level3 = "Dwarvish Blazer",
				recruit = {"Dwarvish Oiler"},
			}
		}
	},
	-- VANILLA DEFINITIONS BELOW
	{
		id = "northerners",
		recruit = {"Orcish Grunt","Orcish Archer","Wolf Rider","Orcish Assassin","Troll Whelp"},
		recall = {
			level2 = {"Orcish Ruler","Orcish Slayer","Orcish Crossbowman","Troll Rocklobber","Troll","Orcish Warrior","Goblin Pillager","Goblin Knight","Orcish Crossbowman","Troll","Orcish Warrior","Troll Hero"},
			level3 = {"Orcish Warlord","Troll Warrior","Orcish Slurbow","Orcish Nightblade","Orcish Sovereign","Direwolf Rider","Orcish Warlord","Troll Warrior","Orcish Slurbow","Great Troll","Direwolf Rider","Orcish High Warlord"},
		},
		commander = {
			level1 = {"Orcish Leader","Orcish Grunt","Orcish Archer","Orcish Assassin"},
			level2 = {"Orcish Ruler","Troll Hero","Orcish Slayer","Orcish Crossbowman","Troll Rocklobber","Troll","Orcish Warrior"},
			level3 = {"Orcish Warlord","Troll Warrior","Orcish Slurbow","Orcish Nightblade","Orcish Sovereign","Great Troll"},
		},
		leader = {
			{
				level2 = "Orcish Warrior",
				level3 = "Orcish High Warlord",
				recruit = {"Orcish Warrior"},
			},
			{
				level2 = "Troll",
				level3 = "Troll Warrior",
				recruit = {"Troll"},
			},
			{
				level2 = "Troll Rocklobber",
				level3 = "Great Troll",
				recruit = {"Troll"},
			},
			{
				level2 = "Orcish Crossbowman",
				level3 = "Orcish Slurbow",
				recruit = {"Orcish Crossbowman"},
			},
			{
				level2 = "Orcish Slayer",
				level3 = "Orcish Nightblade",
				recruit = {"Orcish Slayer"},
			},
			{
				level2 = "Goblin Knight",
				level3 = "Direwolf Rider",
				recruit = {"Goblin Knight"},
			},
			{
				level2 = "Orcish Ruler",
				level3 = "Orcish Sovereign",
				recruit = {"Orcish Warrior"},
			},
		}
	},
	{
		id = "loyalists",
		recruit = {"Spearman","Bowman","Cavalryman","Fencer","Mage"},
		recall = {
			level2 = {"White Mage","Red Mage","Duelist","Longbowman","Shock Trooper","Pikeman","Swordsman","Lieutenant","Dragoon","Knight","Javelineer","Pikeman","Swordsman","Longbowman"},
			level3 = {"Royal Warrior","General","Halberdier","Royal Guard","Javelin Master","Silver Mage","Iron Mauler","Master Bowman","Master at Arms","Arch Mage","Mage of Light","Paladin","Grand Knight","Cavalier","General","Halberdier","Royal Guard","Iron Mauler","Master Bowman","Master at Arms","Titanium Decimator","Javelin Master"},
		},
		commander = {
			level1 = {"Sergeant","Spearman","Bowman","Mage","Fencer","Heavy Infantryman"},
			level2 = {"White Mage","Red Mage","Duelist","Longbowman","Shock Trooper","Pikeman","Swordsman","Lieutenant","Javelineer"},
			level3 = {"Royal Warrior","General","Halberdier","Royal Guard","Javelin Master","Silver Mage","Iron Mauler","Master Bowman","Master at Arms","Arch Mage","Mage of Light"},
		},
		leader = {
			{
				level2 = "Lieutenant",
				level3 = "General",
				recruit = {"Pikeman"},
			},
			{
				level2 = "Swordsman",
				level3 = "Royal Guard",
				recruit = {"Swordsman"},
			},
			{
				level2 = "Pikeman",
				level3 = "Halberdier",
				recruit = {"Javelineer"},
			},
			{
				level2 = "Javelineer",
				level3 = "Royal Warrior",
				recruit = {"Knight"},
			},
			{
				level2 = "Shock Trooper",
				level3 = "Titanium Decimator",
				recruit = {"Shock Trooper"},
			},
			{
				level2 = "Longbowman",
				level3 = "Master Bowman",
				recruit = {"Longbowman"},
			},
			{
				level2 = "Duelist",
				level3 = "Master at Arms",
				recruit = {"Dragoon"},
			},
			{
				level2 = "Red Mage",
				level3 = "Arch Mage",
				recruit = {"Red Mage"},
			},
			{
				level2 = "White Mage",
				level3 = "Mage of Light",
				recruit = {"White Mage"},
			},
		}
	},
	{
		id = "elves",
		recruit = {"Elvish Fighter","Elvish Archer","Elvish Shaman","Elvish Scout","Wose"},
		recall = {
			level2 = {"Elder Wose","Elvish Sorceress","Elvish Druid","Elvish Marksman","Elvish Ranger","Elvish Hero","Elvish Captain","Elvish Rider","Elder Wose","Elvish Hero","Elder Wose","Elvish Sorceress","Red Mage","Elvish Marksman","Elvish Ranger","Elvish Hero","Elvish Captain","Elvish Rider","Elvish Ranger","Elvish Hero","Wose Shaman"},
			level3 = {"Elvish Marshal","Elvish Champion","Elvish Avenger","Elvish Sharpshooter","Elvish Shyde","Elvish Enchantress","Ancient Wose","Elvish Outrider","Ancient Wose","Elvish Champion","Elvish Marshal","Elvish Champion","Elvish Avenger","Elvish Sharpshooter","Arch Mage","Elvish Enchantress","Ancient Wose","Elvish Outrider","Elvish Avenger","Elvish Champion","Elvish Sylph"},
		},
		commander = {
			level1 = {"Elvish Shaman","Elvish Fighter","Elvish Archer","Wose"},
			level2 = {"Elder Wose","Elvish Sorceress","Elvish Druid","Elvish Marksman","Elvish Ranger","Elvish Hero","Elvish Captain","Elvish Lord"},
			level3 = {"Elvish Marshal","Elvish Champion","Elvish Avenger","Elvish Sharpshooter","Elvish Shyde","Elvish Enchantress","Ancient Wose","Arch Mage","Elvish High Lord"},
		},
		leader = {
			{
				level2 = "Elvish Captain",
				level3 = "Elvish Marshal",
				recruit = {"Elvish Hero"},
			},
			{
				level2 = "Elvish Hero",
				level3 = "Elvish Champion",
				recruit = {"Elvish Hero"},
			},
			{
				level2 = "Elvish Ranger",
				level3 = "Elvish Avenger",
				recruit = {"Elvish Ranger"},
			},
			{
				level2 = "Elvish Marksman",
				level3 = "Elvish Sharpshooter",
				recruit = {"Elvish Marksman"},
			},
			{
				level2 = "Elvish Druid",
				level3 = "Elvish Shyde",
				recruit = {"Elvish Sorceress"},
			},
			{
				level2 = "Elvish Sorceress",
				level3 = "Elvish Sylph",
				recruit = {"Elvish Sorceress"},
			},
			{
				level2 = "Elder Wose",
				level3 = "Ancient Wose",
				recruit = {"Elder Wose"},
			},
		}
	},
	{
		id = "knalgans",
		recruit = {"Dwarvish Fighter","Dwarvish Thunderer","Thief","Footpad","Poacher"},
		recall = {
			level2 = {"Dwarvish Stalwart","Dwarvish Thunderguard","Dwarvish Steelclad","Rogue","Trapper","Gryphon Master","Bandit","Outlaw","Dwarvish Stalwart","Dwarvish Thunderguard","Dwarvish Steelclad","Dwarvish Berserker","Dwarvish Runesmith"},
			level3 = {"Dwarvish Lord","Dwarvish Dragonguard","Dwarvish Sentinel","Assassin","Huntsman","Fugitive","Highwayman","Dwarvish Lord","Dwarvish Dragonguard","Dwarvish Sentinel","Gryphon Thunderlord","Dwarvish Arcanister","Dwarvish Runemaster"},
		},
		commander = {
			level1 = {"Dwarvish Thunderer","Dwarvish Fighter","Dwarvish Guardsman","Dwarvish Scout","Thief","Poacher"},
			level2 = {"Dwarvish Stalwart","Dwarvish Thunderguard","Dwarvish Steelclad","Dwarvish Pathfinder","Rogue","Trapper"},
			level3 = {"Dwarvish Lord","Dwarvish Dragonguard","Dwarvish Sentinel","Assassin","Huntsman","Highwayman","Dwarvish Explorer","Gryphon Thunderlord"},
		},
		leader = {
			{
				level2 = "Dwarvish Steelclad",
				level3 = "Dwarvish Lord",
				recruit = {"Dwarvish Steelclad"},
			},
			{
				level2 = "Dwarvish Thunderguard",
				level3 = "Dwarvish Dragonguard",
				recruit = {"Dwarvish Thunderguard"},
			},
			{
				level2 = "Dwarvish Stalwart",
				level3 = "Dwarvish Sentinel",
				recruit = {"Dwarvish Stalwart"},
			},
			{
				level2 = "Rogue",
				level3 = "Assassin",
				recruit = {"Outlaw"},
			},
			{
				level2 = "Trapper",
				level3 = "Huntsman",
				recruit = {"Trapper"},
			},
			{
				level2 = "Bandit",
				level3 = "Highwayman",
				recruit = {"Bandit"},
			},
		}
	},
	{
		id = "drakes",
		recruit = {"Drake Fighter","Drake Clasher","Drake Glider","Drake Burner","Saurian Augur"},
		recall = {
			level2 = {"Drake Arbiter","Drake Thrasher","Drake Warrior","Fire Drake","Drake Flare","Saurian Oracle","Saurian Soothsayer","Saurian Ambusher","Drake Warrior","Drake Thrasher","Sky Drake"},
			level3 = {"Drake Flameheart","Inferno Drake","Drake Blademaster","Drake Blademaster","Drake Enforcer","Drake Warden","Saurian Flanker","Saurian Warden","Saurian Seer","Saurian Prophet","Saurian Javelineer","Hurricane Drake","Armageddon Drake"},
		},
		commander = {
			level1 = {"Drake Burner","Drake Fighter","Drake Clasher","Saurian Augur","Saurian Skirmisher"},
			level2 = {"Drake Arbiter","Drake Thrasher","Drake Warrior","Fire Drake","Drake Flare","Saurian Ambusher","Saurian Oracle"},
			level3 = {"Drake Flameheart","Inferno Drake","Drake Blademaster","Drake Enforcer","Drake Warden","Saurian Flanker"},
		},
		leader = {
			{
				level2 = "Drake Flare",
				level3 = "Drake Flameheart",
				recruit = {"Fire Drake"},
			},
			{
				level2 = "Fire Drake",
				level3 = "Inferno Drake",
				recruit = {"Fire Drake"},
			},
			{
				level2 = "Drake Warrior",
				level3 = "Drake Blademaster",
				recruit = {"Drake Warrior"},
			},
			{
				level2 = "Drake Thrasher",
				level3 = "Drake Enforcer",
				recruit = {"Drake Thrasher"},
			},
			{
				level2 = "Drake Arbiter",
				level3 = "Drake Warden",
				recruit = {"Drake Arbiter"},
			},
			{
				level2 = "Saurian Oracle",
				level3 = "Saurian Flanker",
				recruit = {"Saurian Oracle"},
			},
			{
				level2 = "Saurian Soothsayer",
				level3 = "Hurricane Drake",
				recruit = {"Sky Drake"},
			},
		}
	},
	{
		id = "undead",
		recruit = {"Skeleton","Skeleton Archer","Ghost","Ghoul","Dark Adept"},
		recall = {
			level2 = {"Revenant","Deathblade","Bone Shooter","Dark Sorcerer","Necrophage","Wraith","Shadow","Revenant","Bone Shooter","Dark Sorcerer","Necrophage","Chocobone"},
			level3 = {"Draug","Death Knight","Necromancer","Lich","Ghast","Banebow","Spectre","Nightgaunt","Draug","Ghast","Banebow","Apparition"},
		},
		commander = {
			level1 = {"Dark Adept","Skeleton Archer","Skeleton","Ghoul"},
			level2 = {"Revenant","Deathblade","Bone Shooter","Dark Sorcerer","Necrophage"},
			level3 = {"Draug","Death Knight","Necromancer","Lich","Ghast","Banebow"},
		},
		leader = {
			{
				level2 = "Revenant",
				level3 = "Draug",
				recruit = {"Revenant"},
			},
			{
				level2 = "Death Squire",
				level3 = "Death Knight",
				recruit = {"Deathblade"},
			},
			{
				level2 = "Bone Shooter",
				level3 = "Banebow",
				recruit = {"Bone Shooter"},
			},
			{
				level2 = "Dark Sorcerer",
				level3 = "Lich",
				recruit = {"Dark Sorcerer"},
			},
			{
				level2 = "Dark Sorcerer",
				level3 = "Necromancer",
				recruit = {"Chocobone"},
			},
			{
				level2 = "Necrophage",
				level3 = "Ghast",
				recruit = {"Necrophage"},
			},
			{
				level2 = "Wraith",
				level3 = "Apparition",
				recruit = {"Wraith"},
			},
		}
	},
	{
		id = "dunefolk",
		recruit = {"Dune Soldier","Dune Burner","Dune Rider","Dune Skirmisher","Dune Rover","Naga Dirkfang"},
		recall = {
			level2 = {"Dune Captain","Dune Strider","Dune Scorcher","Dune Alchemist","Dune Falconer","Dune Swordsman","Dune Horse Archer","Dune Sunderer","Dune Scorcher","Dune Apothecary","Dune Swordsman","Dune Spearguard"},
			level3 = {"Dune Blademaster","Dune Sky Hunter","Dune Firetrooper","Dune Warmaster","Dune Cataphract","Dune Blademaster","Dune Luminary","Dune Firetrooper","Dune Spearmaster","Dune Cataphract","Dune Paragon"},
		},
		commander = {
			level1 = {"Dune Soldier","Dune Soldier","Dune Burner","Dune Skirmisher"},
			level2 = {"Dune Captain","Dune Spearguard","Dune Strider","Dune Scorcher","Dune Alchemist","Dune Apothecary","Dune Swordsman"},
			level3 = {"Dune Blademaster","Dune Luminary","Dune Firetrooper","Dune Warmaster","Dune Spearmaster"},
		},
		leader = {
			{
				level2 = "Dune Swordsman",
				level3 = "Dune Blademaster",
				recruit = {"Dune Swordsman"},
			},
			{
				level2 = "Dune Apothecary",
				level3 = "Dune Luminary",
				recruit = {"Dune Alchemist"},
			},
			{
				level2 = "Dune Spearguard",
				level3 = "Dune Spearmaster",
				recruit = {"Dune Sunderer"},
			},
			{
				level2 = "Dune Scorcher",
				level3 = "Dune Firetrooper",
				recruit = {"Dune Scorcher"},
			},
			{
				level2 = "Dune Strider",
				level3 = "Dune Harrier",
				recruit = {"Dune Horse Archer"},
			},
			{
				level2 = "Dune Raider",
				level3 = "Dune Marauder",
				recruit = {"Dune Raider"},
			},
			{
				level2 = "Dune Captain",
				level3 = "Dune Paragon",
				recruit = {"Dune Spearguard"},
			},
		}
	},
}
enemy_army.factions_available = {}
-- each faction can be picked up to 4 times along campaign
for i = 1, #enemy_army.group do
	for j = 1, 4 do
		table.insert(enemy_army.factions_available, i)
	end
end
-- each faction pick any faction as ally just 1 time
for i = 1, #enemy_army.group do
	local ally = {}
	enemy_army.group[i].allies_available = ally
	for j = 1, #enemy_army.group do
		if j ~= i then
			table.insert(ally, j)
		end
	end
end

return enemy_army
