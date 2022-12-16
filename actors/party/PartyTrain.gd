extends Node2D

# The PartyTrain is a node that houses all party members
# that follow the leader (Player.tscn).

@export_node_path(CharacterBody2D) var leader

@onready var firstAnchor = $FirstFollower
@onready var secondAnchor = $SecondFollower

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
