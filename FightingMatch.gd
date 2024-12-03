extends Node2D

@onready var health_bar1 = $healthbar/HealthBar2D
@onready var health_bar2 = $healthbar2/HealthBar2D2
@onready var player1 = $Player
@onready var player2 = $Player2
@onready var p1win = $p1win
@onready var p2win = $p2win
signal health_changed1(health: int)
signal health_changed2(health: int)

var game_states = {
	"playing": _do_nothing,
	"gameover": _gameover
}

var current_state = "playing"

func _ready() -> void:
	health_bar1.initialize("health_changed1", 100)
	health_bar2.initialize("health_changed2", 100)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	game_states[current_state].call()

func _do_nothing():
	pass

func _gameover():
	if Input.is_action_pressed("SPACE"):
		get_tree().change_scene_to_file("res://controls_screen.tscn")

func _on_player2_health_changed(health: int) -> void:
	emit_signal("health_changed2", health)


func _on_player1_health_changed(health: int) -> void:
	emit_signal("health_changed1", health)


func _on_player_died(is_player1: bool) -> void:
	current_state = "gameover"
	freeze_character(is_player1)
	if is_player1:
		p2win.visible = true
	else:
		p1win.visible = true
	
	
func freeze_character(is_player1: bool):
	if is_player1:
		player2.set_physics_process(false)
	else:
		player1.set_physics_process(false)
