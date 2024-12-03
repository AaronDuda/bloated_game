extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.play("default")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("SPACE"):
		get_tree().change_scene_to_file("res://controls_screen.tscn")