class_name Stats
extends Resource

var maxHP: int
@export var HP: int
var maxMP: int
@export var MP: int
@export var ATK: int
@export var MATK: int
@export var DEF: int
@export var MDEF: int
@export var SPD: int
@export var LUK: int

func _ready():
	maxHP = HP
	maxMP = MP
