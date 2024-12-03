class_name Hitbox extends CollisionShape2D

@onready var animation = $"../Animations"

var current_state = Enums.States.IDLE
var current_frame = 0

func set_state(state: Enums.States):
	current_state = state

func _no_movement():
	pass
	
func _jumping():
	pass
	
func _fground():
	pass

func _uair():
	pass
	
func _dair():
	pass

func _duck():
	pass

func _duck_idle():
	pass
	
func _duck_attack():
	pass
	
