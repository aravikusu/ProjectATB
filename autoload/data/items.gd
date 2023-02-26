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
	"alternativeDisplayText": null,
	"description": "Test item. Can be used to heal some HP.",
	"icon": "dummy",
	"hits": 1,
	"element": Enums.ELEMENT.ANIMA,
	"effectType": Enums.COMMAND_EFFECT_TYPE.STATIC_HP_HEAL,
	"effectValues": [[100.0]],
	"target": Enums.TARGET_TYPE.ANY,
	"additionalTargetInfo": [],
	"category": Enums.ITEM_TYPE.USABLE,
	"useInCombat": true,
	"useInMenu": true,
	"animOverride": "HealGlimmer"
}

# Weapons

var ARMMODIFIER = {
	"name": "ArmModifierDummy",
	"description": "Test weapon for Aravix.",
	"icon": "dummy",
	"category": Enums.ITEM_TYPE.WEAPON,
	"useInCombat": false,
	"useInMenu": true,
	"canWear": [Enums.CHARACTER.ARAVIX]
}

var STAFF = {
	"name": "StaffDummy",
	"description": "Test weapon for Tasty.",
	"icon": "dummy",
	"category": Enums.ITEM_TYPE.WEAPON,
	"useInCombat": false,
	"useInMenu": true,
	"canWear": [Enums.CHARACTER.TASTY]
}

var SWORD = {
	"name": "SwordDummy",
	"description": "Test weapon for Aylik.",
	"icon": "dummy",
	"category": Enums.ITEM_TYPE.WEAPON,
	"useInCombat": false,
	"useInMenu": true,
	"canWear": [Enums.CHARACTER.AYLIK]
}

# ARMOR

var ARMOR = {
	"name": "ArmorDummy",
	"description": "Test armor.",
	"icon": "dummy",
	"category": Enums.ITEM_TYPE.ARMOR,
	"useInCombat": false,
	"useInMenu": true,
	"canWear": [Enums.CHARACTER.EVERYONE]
}

# ACCESSORY

var ACCESSORY = {
	"name": "AcessoryDummy",
	"description": "Test accessory.",
	"icon": "dummy",
	"category": Enums.ITEM_TYPE.ACCESSORY,
	"useInCombat": false,
	"useInMenu": true,
	"canWear": [Enums.CHARACTER.EVERYONE]
}

var TESTACC2 = {
	"name": "TheCoolerAccessoryDummy",
	"description": "You heard the man.",
	"icon": "dummy",
	"category": Enums.ITEM_TYPE.ACCESSORY,
	"useInCombat": false,
	"useInMenu": true,
	"canWear": [Enums.CHARACTER.EVERYONE]
}
