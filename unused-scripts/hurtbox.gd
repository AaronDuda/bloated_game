class_name Hurtbox extends CollisionShape2D

@onready var animation = $"../CharacterAnimations"
@onready var normal_shape;
@onready var small_shape;

var state_functions = {
	"idle": _no_movement,
	"jump": _jumping,
	"fground": _fground,
	"fair": _fground,
	"uair": _no_movement,
	"dair": _dair,
	"nair": _no_movement,
	"duck_idle": _duck_idle,
	"duck": _duck,
	"duck_attack": _duck_idle
}


@export var NORMAL_POSITION = Vector2(0, 15)
@export var JUMP_POSITION   = Vector2(0, 22)
@export var DUCK_POSITION   = Vector2(0, 29)
@export var F_POSITION      = Vector2(-12, 11)
@export var DAIR_POSITION   = Vector2(0, -9)
@export var NORMAL_SIZE     = Vector2(28, 33)
@export var DUCK_SCALE      = Vector2(1, 0.5)

func _ready() -> void:
	normal_shape = RectangleShape2D.new()
	normal_shape.size = NORMAL_SIZE
	small_shape = RectangleShape2D.new()
	small_shape.size = DUCK_SCALE

func flip() -> void:
	F_POSITION.x = -F_POSITION.x


func _no_movement():
	pass
	
func _jumping():
	if animation.get_frame() == 6:
		position = JUMP_POSITION
	else:
		position = NORMAL_POSITION

func _fground():
	if animation.get_frame() == 5:
		position = F_POSITION
	else:
		position = NORMAL_POSITION

func _dair():
	if animation.get_frame() == 5:
		position = DAIR_POSITION
	else:
		position = NORMAL_POSITION

func _duck():
	if animation.get_frame() >= 7:
		position = DUCK_POSITION
		shape = small_shape
	else:
		position = NORMAL_POSITION
		shape = normal_shape

func _duck_idle():
	position = DUCK_POSITION
	shape = small_shape
	
func _on_attack_frame(frame: int):
	pass
	

func _on_animations_frame_changed() -> void:
	if not state_functions.has(animation.animation):
		return;
	state_functions[animation.animation].call()

func _on_animations_animation_changed() -> void:
	if animation.animation not in ["duck", "duck_idle", "duck_attack"]:
		shape = normal_shape
