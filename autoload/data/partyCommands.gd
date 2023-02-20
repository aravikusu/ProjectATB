extends Node

# A list of party exclusive commans.

var HOLY = {
	"name": "Holy",
	"alternativeDisplayText": null,
	"description": "Attack an enemy and anything around it with a powerful blast of light.",
	"icon": "dummy",
	"hits": 1,
	"hitPower": [1.0],
	"cost": 15,
	"target": Enums.TARGET_TYPE.SHAPE,
	"additionalTargetInfo": [Enums.TARGET_SHAPE.CIRCLE, 0.5],
	"multitech": Enums.MULTITECH_TYPE.NONE,
	"useInMenu": false
}

var ORAORA = {
	"name": "Oraoraora",
	"alternativeDisplayText": null,
	"description": "I just wanted to test 100 hits.",
	"icon": "dummy",
	"hits": 100,
	"hitPower": [],
	"cost": 25,
	"target": Enums.TARGET_TYPE.ANY,
	"additionalTargetInfo": [],
	"multitech": Enums.MULTITECH_TYPE.NONE,
	"useInMenu": false
}

var HEAL = {
	"name": "Heal",
	"alternativeDisplayText": null,
	"description": "Channel a stream of anima into your target, healing their wounds moderately.",
	"icon": "dummy",
	"hits": 1,
	"hitPower": [1.0],
	"cost": 35,
	"target": Enums.TARGET_TYPE.ANY,
	"additionalTargetInfo": [],
	"multitech": Enums.MULTITECH_TYPE.NONE,
	"useInMenu": true
}
