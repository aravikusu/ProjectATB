extends MarginContainer

@onready var frames = $"%StatusFrames".get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	var party = Global.get_all_party_members()
	
	var idx = 0
	for member in party:
		if !member.active:
			frames[idx].hide()
		idx += 1
