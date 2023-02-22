extends Node

# A list of all commands available.

var ATTACK = {
	"name": "Attack",
	"alternativeDisplayText": null,
	"description": "I know you're upset that this text can't be read, but you shouldn't attack me.",
	"icon": "dummy",
	"hits": 1,
	"hitPower": [0.8],
	"cost": 0,
	"target": Enums.TARGET_TYPE.ANY,
	"additionalTargetInfo": [],
	"multitech": Enums.MULTITECH_TYPE.NONE,
	"useInMenu": false,
	"animOverride": null
}

var DEFEND = {
	"name": "Defend",
	"alternativeDisplayText": null,
	"description": "If you see this, you should prepare yourself. It'll hurt otherwise.",
	"icon": "dummy",
	"hits": 0,
	"hitPower": null,
	"cost": 0,
	"target": Enums.TARGET_TYPE.SELF,
	"additionalTargetInfo": [],
	"multitech": Enums.MULTITECH_TYPE.NONE,
	"useInMenu": false,
	"animOverride": null
}

var RUN = {
	"name": "Run",
	"alternativeDisplayText": "%a tries to make a run for it!",
	"description": "You might escape the battle, but you can't escape the impending dread of assured mutual destruction.",
	"icon": "dummy",
	"hits": 1,
	"hitPower": null,
	"cost": 0,
	"target": Enums.TARGET_TYPE.NONE,
	"additionalTargetInfo": [],
	"multitech": Enums.MULTITECH_TYPE.NONE,
	"useInMenu": false,
	"animOverride": null
}
