local _ = wesnoth.textdomain 'wesnoth-cc'

type_infos = {
	["default"] = {
		founddialogue = _"You look like you could use some help. Mind if I join in? It’s been a while since I had a good fight!",
		reply = _ "Excellent. We could always use more help.",
	},
	["Orcish Grunt"] = {
		-- po: an Orcish Grunt joins a player's side
		founddialogue=_"’bout time. Been forever since I had a good fight, eh?",
		image="units/orcs/grunt.png",
		name="Orcish Grunt",
	},
	["Troll Whelp"] = {
		-- po: a Troll Whelp joins a player's side
		founddialogue=_"Who you? I help you smash!",
		image="units/trolls/whelp.png",
		name="Troll Whelp",
	},
	["Orcish Archer"] = {
		-- po: an Orcish Archer joins a player's side
		founddialogue=_"My clan was destroyed long ago, leaving me to fend for myself. Let me join your army and I will fight as though your clan was my own!",
		image="units/orcs/archer.png",
		name="Orcish Archer",
	},
	["Orcish Assassin"] = {
		-- po: an Orcish Assassin joins a player's side
		founddialogue=_"Hey boss. Looks like you’ve got some prey that need killing.",
		image="units/orcs/assassin.png",
		name="Orcish Assassin",
	},
	["Wolf Rider"] = {
		-- po: a Wolf Rider joins a player's side
		founddialogue=_"I hunts. I join you, I hunts good for you!",
		image="units/goblins/wolf-rider.png",
		name="Wolf Rider",
		alt_reply = { {
			race="wose",
			-- po: speaker is a Wose, just after a Wolf Rider joins their side
			reply=_"Very well. But take care where your dog does its stuff.",
		} }
	},
	["Orcish Leader"] = {
		-- po: an Orcish Leader joins a player's side
		founddialogue=_"Heh, looks like you whelps might be getting in over your heads. Good thing I’m here now to win this fight for ya, huh?",
		image="units/orcs/leader.png",
		name="Orcish Leader",
	},
	["Naga Fighter"] = {
		-- po: a Naga Fighter joins a player's side
		founddialogue=_"I too have come a long way to this strange land. Perhaps we were destined to join blades here.",
		image="units/nagas/fighter.png",
		name="Naga Fighter",
		alt_reply = { {
			race="gryphon",
			-- po: speaker is a Gryphon, just after a naga or merfolk joins their side
			reply=_"Looks like we fished some tasty help.",
		} }
	},
	["Elvish Fighter"] = {
		-- po: an Elvish Fighter joins a player's side
		founddialogue=_"Need a friendly blade?",
		image="units/elves-wood/fighter/fighter.png",
		name="Elvish Fighter",
	},
	["Elvish Archer"] = {
		-- po: an Elvish Archer joins a player's side
		founddialogue=_"You look like you could use some help. Mind if I join in? It’s been a while since I had a good fight!",
		image="units/elves-wood/archer.png",
		name="Elvish Archer",
	},
	["Elvish Shaman"] = {
		-- po: an Elvish Shaman joins a player's side
		founddialogue=_"The mother forest sends you her blessings. Let us join together against her foes.",
		image="units/elves-wood/shaman.png",
		name="Elvish Shaman",
		alt_reply = { {
			race="elf,wose",
			-- po: speaker is an elf or wose, just after a shaman joins their side
			reply=_"Yeah, flower power!",
		} }
	},
	["Elvish Scout"] = {
		-- po: an Elvish Scout joins a player's side
		founddialogue=_"I offer you the service of my arrows and my steed. You will find none that fly faster than either.",
		image="units/elves-wood/scout/scout.png",
		name="Elvish Scout",
	},
	["Wose"] = {
		-- po: a Wose joins a player's side
		founddialogue=_"Hmm! Welcome, tree-friends. We will pound our enemies into dust!",
		image="units/woses/wose.png",
		name="Wose",
	},
	["Merman Hunter"] = {
		-- po: a Merman Hunter joins a player's side
		founddialogue=_"Greetings, friends. I am a lone hunter and have no legions of warriors to offer you, but I will gladly lend my arms to your cause.",
		image="units/merfolk/hunter.png",
		name="Merman Hunter",
		alt_reply = { {
			race="gryphon",
			reply=_"Looks like we fished some tasty help.",
		} }
	},
	["Mermaid Initiate"] = {
		-- po: a Mermaid Initiate joins a player's side
		founddialogue=_"You have come a long way over the ocean, yet I see that you know little of her ways. Let me show you.",
		image="units/merfolk/initiate.png",
		name="Mermaid Initiate",
		alt_reply = { {
			race="gryphon",
			reply=_"Looks like we fished some tasty help.",
		} }
	},
	["Cavalryman"] = {
		-- po: a Cavalryman joins a player's side
		founddialogue=_"You’re not from around here, but I seem to find myself between employers at the moment and I’m not picky. I’ll fight for you, if you’ll have me.",
		image="units/human-loyalists/cavalryman/cavalryman.png~CROP(14,14,72,72)",
		name="Cavalryman",
		alt_reply = { {
			gender="female",
			-- po: speaker is female, just after a Cavalryman or Horseman joins their side
			reply=_"Of course. How could a girl say no to a man riding a horse?",
		} }
	},
	["Horseman"] = {
		-- po: a Horseman joins a player's side
		founddialogue=_"Hurrah! Now THIS is a battle too grand to be missed. Save some for me, eh?",
		image="units/human-loyalists/horseman/horseman.png",
		name="Horseman",
		alt_reply = { {
			gender="female",
			reply=_"Of course. How could a girl say no to a man riding a horse?",
		} }
	},
	["Spearman"] = {
		-- po: a Spearman joins a player's side
		founddialogue=_"Ho there, friends! I am but a soldier of humble circumstances, yet long have I dreamed of joining great wars beyond our shores. Let me join your mission!",
		image="units/human-loyalists/spearman.png",
		name="Spearman",
	},
	["Fencer"] = {
		-- po: a Fencer joins a player's side
		founddialogue=_"Looks like you’re a bit down on your luck, my friends. But now that I am here, there’s nothing to worry about!",
		image="units/human-loyalists/fencer.png",
		name="Fencer",
	},
	["Heavy Infantryman"] = {
		-- po: a Heavy Infantryman joins a player's side
		founddialogue=_"Finally reinforcements are here! I’ve been pinned down for days. Help me fight my way out of here and I’ll gladly follow you!",
		image="units/human-loyalists/heavyinfantry.png",
		name="Heavy Infantryman",
	},
	["Bowman"] = {
		-- po: a Bowman joins a player's side
		founddialogue=_"Greetings, my lords. I have watched your battle from afar and yearn to join such a glorious campaign. I pledge myself to your service!",
		image="units/human-loyalists/bowman.png",
		name="Bowman",
	},
	["Sergeant"] = {
		-- po: a Sergeant joins a player's side
		founddialogue=_"You’re not from around here, but I seem to find myself between employers at the moment and I’m not picky. I’ll fight for you, if you’ll have me.",
		image="units/human-loyalists/sergeant.png",
		name="Sergeant",
	},
	["Mage"] = {
		-- po: a Mage joins a player's side
		founddialogue=_"Long have I studied the ways of lore, and I have much wisdom to offer. Allow me to guide you on your quest and together we will accomplish great things!",
		image="units/human-magi/mage.png",
		name="Mage",
	},
	["Merman Fighter"] = {
		-- po: a Merman Fighter joins a player's side
		founddialogue=_"I bring greetings from the merfolk. We have heard your plight, and though we have few warriors to spare among us, I would gladly lend my trident to your cause.",
		image="units/merfolk/fighter.png",
		name="Merman Fighter",
		alt_reply = { {
			race="gryphon",
			reply=_"Looks like we fished some tasty help.",
		} }
	},
	["Dwarvish Fighter"] = {
		-- po: a Dwarvish Fighter joins a player's side
		founddialogue=_"Having trouble, eh? Never worry, lads, we’ll sort ’em out soon enough!",
		image="units/dwarves/fighter.png",
		name="Dwarvish Fighter",
	},
	["Thief"] = {
		-- po: a Thief joins a player's side. This one's British slang for "you've caught me stealing, let me work for you instead", with extra words that are just parts of the idiom.
		founddialogue=_"You’ve got me, guv, it’s a fair cop! Just lemme work for you instead. You won’t regret it, guv, I promise!",
		image="units/human-outlaws/thief.png",
		name="Thief",
	},
	["Dwarvish Thunderer"] = {
		-- po: a Dwarvish Thunderer joins a player's side
		founddialogue=_"Listen up, ye primitive screwheads! This... is me BOOM STICK. Lemme show you what this baby can do!",
		image="units/dwarves/thunderer/thunderer.png",
		name="Dwarvish Thunderer",
	},
	["Poacher"] = {
		-- po: a Poacher joins a player's side
		founddialogue=_"What, you want my help? A guy like me? Huh, that’s rich. Oh well... let’s give it a shot, eh?",
		image="units/human-outlaws/poacher.png",
		name="Poacher",
	},
	["Dwarvish Guardsman"] = {
		-- po: a Dwarvish Guardsman joins a player's side
		founddialogue=_"A soldier is no good without something to fight for. Let me fight for you!",
		image="units/dwarves/guard.png",
		name="Dwarvish Guardsman",
	},
	["Footpad"] = {
		-- po: a Footpad joins a player's side. The first half is "please don’t attack me", the second is "you seem to be in a difficult situation too, I’m good at talking or fighting my way out".
		founddialogue=_"Hey, hey, easy there! I done nothin’ to hurt you. We’re all friends here, right? Looks like you might be in a tight spot, but don’t worry. No one’s better at getting out of tight spots than me, boss!",
		image="units/human-outlaws/footpad.png",
		name="Footpad",
	},
	["Dwarvish Ulfserker"] = {
		-- po: an Ulfserker joins a player's side
		founddialogue=_"Chin up, lads. Today is a good day to die!",
		image="units/dwarves/ulfserker.png",
		name="Dwarvish Ulfserker",
		alt_reply = { {
			race="dwarf",
			-- po: the speaker is another dwarf, after an Ulf joins their side
			reply=_"Brave words. Welcome to The Fight Club...",
		} }
	},
	["Gryphon Rider"] = {
		-- po: a Gryphon Rider joins a player's side
		founddialogue=_"Need a hand? Me an’ me bird can get just about anywheres you need.",
		image="units/dwarves/gryphon-rider.png",
		name="Gryphon Rider",
		alt_reply = { {
			race="merman,naga",
			-- po: the speaker is a naga or merfolk, after a Gryphon Rider joins their side
			reply=_"Sounds good. You scared me for a moment.",
			}, {
			race="gryphon,bats",
			-- po: the speaker is a bat or a gryphon, after a Gryphon Rider or Drake Glider joins their side
			reply=_"Cool. We could always need more air power.",
		} }
	},
	["Dwarvish Scout"] = {
		-- po: a Dwarvish Scout joins a player's side
		founddialogue=_"Having trouble, eh? Never worry, lads, we’ll sort ’em out soon enough!",
		image="units/dwarves/scout.png",
		name="Dwarvish Scout",
	},
	["Drake Fighter"] = {
		-- po: a Drake Fighter joins a player's side; they will have their standard weapon (a "war blade" in English)
		founddialogue=_"The ancient spirits tell me my destiny lies with yours. My blade is at your command.",
		image="units/drakes/fighter.png",
		name="Drake Fighter",
	},
	["Drake Clasher"] = {
		-- po: a Drake Clasher joins a player's side
		founddialogue=_"Stand fast, for I bring you the strength of dragons to assist you in your battle!",
		image="units/drakes/clasher.png",
		name="Drake Clasher",
	},
	["Drake Burner"] = {
		-- po: a Drake Burner joins a player's side
		founddialogue=_"Today is a most auspicious day for you, for I deem you worthy of the power of dragonfire. Show me your foes and I will incinerate them!",
		image="units/drakes/burner.png",
		name="Drake Burner",
		alt_reply = { {
			race="drake",
			-- po: the speaker is another drake, after a Drake Burner joins their side
			reply=_"Perfect. We can always use more firepower.",
		} }
	},
	["Saurian Augur"] = {
		-- po: a Saurian Augur joins a player's side
		founddialogue=_"You no fight good enough, no have saurian way. I show you way of saurian!",
		image="units/saurians/augur/augur.png",
		name="Saurian Augur",
		alt_reply = { {
			race="lizard",
			-- po: the speaker is another saurian, after a Saurian Augur joins their side
			reply=_"Sure, bro...",
		} }
	},
	["Drake Glider"] = {
		-- po: a Drake Glider joins a player's side
		founddialogue=_"You may be out to take over the land and the seas, but you’ll never get anywhere without control of the skies. Fortunately I’m here to help you!",
		image="units/drakes/glider.png",
		name="Drake Glider",
		alt_reply = { {
			race="gryphon,bats",
			reply=_"Cool. We could always need more air power.",
		} }
	},
	["Saurian Skirmisher"] = {
		-- po: a Saurian Skirmisher joins a player's side
		founddialogue=_"Tribe fall long time ago, now tribe lost. This last fight of tribe. I fight with you, make last very great!",
		image="units/saurians/skirmisher/skirmisher.png",
		name="Saurian Skirmisher",
	},
	["Skeleton"] = {
		-- po: a Skeleton joins a player's side
		founddialogue=_"Don’t hit me! I’m just your average regular friendly talking skeleton, see? Looks like you fellows could use some help!",
		image="units/undead-skeletal/skeleton/skeleton.png",
		name="Skeleton",
	},
	["Skeleton Archer"] = {
		-- po: a Skeleton Archer joins a player's side
		founddialogue=_"I am called forth from eternal rest, bound to follow he who called me. Show me the enemy, master!",
		image="units/undead-skeletal/archer/archer.png",
		name="Skeleton Archer",
	},
	["Ghoul"] = {
		-- po: a Ghoul joins a player's side, and this line does not fit a Ghoul at all, it’s a pantomime-level stereotype of a British hero.
		-- The unit that found the Ghoul is going to get a line of surprised response.
		founddialogue=_"I say, old sport! It looks like you’ve got a spot of bother. Well, chin up, I say! I’m sure we’ll make a simply smashing team-up. We can sort this lot out and be done by tea, what?",
		image="units/undead/ghoul.png",
		name="Ghoul",
		-- po: response to the Ghoul’s introduction line
		reply=_"Have at thee, unholy abomin... wait, huh?",
		alt_reply = { {
			race="undead,bats",
			reply=_"Excellent. We could always use more help.",
		} }
	},
	["Dark Adept"] = {
		-- po: a Dark Adept joins a player's side
		founddialogue=_"You may not trust me or my reasons, but it seems you are not in a position to be choosy about your allies. Let me assist you and you just may survive.",
		image="units/undead-necromancers/adept.png",
		name="Dark Adept",
	},
	["Ghost"] = {
		-- po: a Ghost joins a player's side
		founddialogue=_"Who calls me from my slumber? I sense a great battle being joined. Point me towards the enemy and I will feast upon their very souls!",
		image="units/undead/ghost-s-2.png",
		name="Ghost",
	},
	["Vampire Bat"] = {
		-- po: a Vampire Bat joins a player's side
		founddialogue=_"Skreeeeeeee!",
		image="units/undead/bat-se-3.png",
		name="Vampire Bat",
		-- po: after a Vampire Bat joins the player's side
		reply=_"This creature seems unusually intelligent for its kind. Perhaps it will help us!",
		alt_reply = { {
			race="undead,bats",
			reply=_"Excellent. We could always use more help.",
		} }
	},
	["Young Ogre"] = {
		-- po: a Young Ogre joins a player's side
		founddialogue=_"You friend are? I friend help!",
		image="units/ogres/young-ogre.png",
		name="Young Ogre",
		alt_reply = { {
			race="ogre,troll",
			-- po: the speaker is an ogre or troll, after a Young Ogre joins their side
			reply=_"Me friend. We can play together.",
		} }
	},
	["Thug"] = {
		-- po: a Thug joins a player's side
		founddialogue=_"What, you want my help? A guy like me? Huh, that’s rich. Oh well... let’s give it a shot, eh?",
		image="units/human-outlaws/thug.png",
		name="Thug",
	},
	["Goblin Spearman"] = {
		-- po: a Goblin Spearman joins a player's side
		founddialogue=_"Ah, please no hurtings me! I helps you, see?",
		image="units/goblins/spearman.png",
		name="Goblin Spearman",
		-- po: after a Goblin Spearman joins a player's side
		reply=_"Fine. We could need a small help.",
		alt_reply = { {
			race="orc,troll,dwarf,ogre,gryphon,wolf",
			-- po: after a Goblin Spearman joins a player's side
			reply=_"Excellent. We could always need cannon fodder.",
		}, {
			race="goblin",
			reply=_"Excellent. We could always use more help.",
		} }
	},
	["Walking Corpse"] = {
		-- po: a Walking Corpse joins a player’s side
		founddialogue=_"...",
		image="units/undead/zombie.png",
		name="Walking Corpse",
		-- po: after a Walking Corpse joins the player’s side
		reply=_"Odd, it doesn’t seem to attack. I wonder if we can use it?",
		alt_reply = { {
			race="undead,bats",
			reply=_"Excellent. We could always use more help.",
			type="Dark Adept,Dark Sorcerer,Necromancer,Lich",
		} }
	},
	["Ruffian"] = {
		-- po: a Peasant or Ruffian joins a player's side. This line is the speech of an overeager schoolchild.
		founddialogue=_"Oooh oooh oooh! I want to help! Pick me, pick me!",
		name="Ruffian",
		-- po: after a Peasant or Ruffian joins the player’s side
		reply=_"...fine. I guess.",
		alt_reply = { {
			race="human",
			reply=_"Excellent. We could always use more help.",
		} }
	},
	["Peasant"] = {
		founddialogue=_"Oooh oooh oooh! I want to help! Pick me, pick me!",
		name="Peasant",
		reply=_"...fine. I guess.",
		alt_reply = { {
			race="human",
			reply=_"Excellent. We could always use more help.",
		} }
	},
	["Woodsman"] = {
		-- po: a Woodsman joins a player's side
		founddialogue=_"Ho there, friends! I am but a soldier of humble circumstances, yet long have I dreamed of joining great wars beyond our shores. Let me join your mission!",
		name="Woodsman",
	},
	["Dune Herbalist"] = {
		-- po: a Dune Herbalist joins a player's side
		founddialogue=_"Long have I studied the ways of lore, and I have much wisdom to offer. Allow me to guide you on your quest and together we will accomplish great things!",
		image="units/dunefolk/herbalist/herbalist.png",
		name="Dune Herbalist",
	},
	["Dune Soldier"] = {
		-- po: a Dune Soldier joins a player's side
		founddialogue=_"I too have come a long way to this strange land. Perhaps we were destined to join blades here.",
		image="units/dunefolk/soldier/soldier.png",
		name="Dune Soldier",
	},
	["Dune Rover"] = {
		-- po: a Dune Rover joins a player's side
		founddialogue=_"Ho there, friends! I am but a soldier of humble circumstances, yet long have I dreamed of joining great wars beyond our shores. Let me join your mission!",
		image="units/dunefolk/rover/rover.png",
		name="Dune Rover",
	},
	["Dune Burner"] = {
		-- po: a Dune Burner joins a player's side
		founddialogue=_"You may not trust me or my reasons, but it seems you are not in a position to be choosy about your allies. Let me assist you and you just may survive.",
		image="units/dunefolk/burner/burner.png",
		name="Dune Burner",
	},
	["Dune Rider"] = {
		-- po: a Dune Rider joins a player's side
		founddialogue=_"A soldier is no good without something to fight for. Let me fight for you!",
		image="units/dunefolk/rider/rider.png",
		name="Dune Rider",
	},
}
return type_infos
