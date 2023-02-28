extends Node

# Level one stats for each party member.
var aravixStats = load("res://actors/party/defaults/aravix-stats.tres")
var aylikStats = load("res://actors/party/defaults/aylik-stats.tres")
var tastyStats = load("res://actors/party/defaults/tasty-stats.tres")

func getPartyMemberCommands(player: Dictionary) -> Array:
	var commands = []
	
	match player.type:
		Enums.CHARACTER.ARAVIX:
			commands = getUnlockedAravixCommands(player.level)
		Enums.CHARACTER.AYLIK:
			commands = getUnlockedAylikCommands(player.level)
		Enums.CHARACTER.TASTY:
			commands = getUnlockedTastyCommands(player.level)
	return commands

func getUnlockedAravixCommands(level: int) -> Array:
	var commands = []
	
	if level > 0:
		commands.append(PartyCommands.ORAORA)
	
	return commands

func getUnlockedAylikCommands(level: int) -> Array:
	var commands = []
	
	if level > 0:
		commands.append(MultitechCommands.X_STRIKE)
	
	return commands

func getUnlockedTastyCommands(level: int) -> Array:
	var commands = []
	
	if level > 0:
		commands.append(PartyCommands.HOLY)
		commands.append(PartyCommands.HEAL)
	
	return commands

func getPartnerForMultitech(user, command):
	var partner = null
	match command.multitech:
		Enums.MULTITECH_TYPE.ARA_AYL:
			if user.characterType == Enums.CHARACTER.ARAVIX:
				partner = Global.get_party_member_by_type(Enums.CHARACTER.AYLIK)
			else:
				partner = Global.get_party_member_by_type(Enums.CHARACTER.ARAVIX)
		Enums.MULTITECH_TYPE.ARA_TAS:
			if user.characterType == Enums.CHARACTER.ARAVIX:
				partner = Global.get_party_member_by_type(Enums.CHARACTER.TASTY)
			else:
				partner = Global.get_party_member_by_type(Enums.CHARACTER.ARAVIX)
		Enums.MULTITECH_TYPE.AYL_TAS:
			if user.characterType == Enums.CHARACTER.AYLIK:
				partner = Global.get_party_member_by_type(Enums.CHARACTER.AYLIK)
			else:
				partner = Global.get_party_member_by_type(Enums.CHARACTER.TASTY)
		Enums.MULTITECH_TYPE.TRIPLE:
			pass
	return partner

func getPartyMemberStats(level: int, type: Enums.CHARACTER) -> Stats:
	var stats = {}
	match type:
		Enums.CHARACTER.ARAVIX:
			stats = getAravixStats(level)
		Enums.CHARACTER.AYLIK:
			stats = getAylikStats(level)
		Enums.CHARACTER.TASTY:
			stats = getTastyStats(level)
		Enums.CHARACTER.MONSTER:
			stats = getMonsterStats()
	return stats

func getAravixStats(_level: int) -> Stats:
	return aravixStats

func getAylikStats(_level: int) -> Stats:
	return aylikStats

func getTastyStats(_level: int) -> Stats:
	return tastyStats

func getMonsterStats() -> Stats:
	return load("res://actors/party/monsters/dummy-stats.tres")
