extends Node

func getEnemyStats(enemy: String):
	match enemy:
		"spicelord":
			return {
				"STR": 1,
				"INT": 1,
				"SPD": 1
			}
		"dummy":
			return {
				"STR": 1,
				"INT": 1,
				"SPD": 0
			}

# Called in enemy.gd's _ready function to get their list of commands.
func getEnemyCommands(enemy: String):
	match enemy:
		"spicelord":
			return [EnemyCommands.SPICE_UP]
		"dummy":
			return []

func decideEnemyAction(enemy, _actors):
	var commandToUse = {
		"actor": enemy,
		"command": null,
		"target": [],
		"partner": null
	}
	match enemy.displayName:
		"spicelord":
			commandToUse.command = enemy.commands[0]
	
	match commandToUse.command.target:
		Enums.TARGET_TYPE.SELF:
			commandToUse.target.append(enemy)
	
	return commandToUse
