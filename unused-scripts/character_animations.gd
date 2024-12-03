class_name CharacterAnimations extends AnimatedSprite2D

signal attack_frame
signal move_frame

@export_group("Attack")
@export var attack_frame_1 = -1
@export var attack_frame_2 = -1
@export var attack_frame_3 = -1
@export var attack_frame_4 = -1
@export var attack_frame_5 = -1

@export_group("Move")
@export var move_frame_1 = -1
@export var move_frame_2 = -1
@export var move_frame_3 = -1
@export var move_frame_4 = -1
@export var move_frame_5 = -1

var attack_frames;
var move_frames;

func _ready() -> void:
	attack_frames = [
		attack_frame_1,
		attack_frame_2,
		attack_frame_3,
		attack_frame_4,
		attack_frame_5,
	]
	
	move_frames = [
		move_frame_1,
		move_frame_2,
		move_frame_3,
		move_frame_4,
		move_frame_5,
	]

func _process(_delta: float) -> void:
	if frame in attack_frames:
		attack_frame.emit(frame)
	elif frame in move_frames:
		move_frame.emit(frame)
	
