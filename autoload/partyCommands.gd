extends Node

# A list of party exclusive commans.

var HOLY = {
	"name": "Holy",
	"alternativeDisplayText": null,
	"description": "Attack an enemy and anything around it with a powerful blast of light.",
	"hits": 1,
	"hitPower": [1.0],
	"target": Enums.TARGET_TYPE.SHAPE,
	"additionalTargetInfo": [Enums.TARGET_SHAPE.CIRCLE, 120],
	"multitech": Enums.MULTITECH_TYPE.NONE
}

var ORAORA = {
	"name": "Oraoraora",
	"alternativeDisplayText": null,
	"description": "I just wanted to test 100 hits.",
	"hits": 100,
	"hitPower": [],
	"target": Enums.TARGET_TYPE.ANY,
	"additionalTargetInfo": [],
	"multitech": Enums.MULTITECH_TYPE.NONE
}
