extends Node

# All the in-game items.

var DUMMY = {
	"name": "MaterialDummy",
	"description": "Test item. Used in Alchemy.",
	"icon": "dummy",
	"category": Enums.ITEM_TYPE.MATERIAL,
	"useInCombat": false,
	"useInMenu": false
}

var DUMMY2 = {
	"name": "ItemDummy",
	"description": "Test item. Can be used in the menu to do nothing.",
	"icon": "dummy",
	"category": Enums.ITEM_TYPE.USABLE,
	"useInCombat": false,
	"useInMenu": true
}
