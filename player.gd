class_name Player extends CharacterBody2D

@export_group("Configuration")
@export var IS_PLAYER_1 = true
@export var HEALTH = 100
@export var SPEED = 600.0
@export var JUMP_VELOCITY = -900.0
@export var STARTING_STATE = "idle"
@export var RIGHT_FACING = true

@export_group("Inputs")
@export var SHIELD = "P1_SHIELD"
@export var NORMAL_ATTACK = "P1_NORMAL_ATTACK"
@export var DOWN = "P1_DOWN"
@export var JUMP = "P1_JUMP"
@export var LEFT = "P1_LEFT"
@export var RIGHT = "P1_RIGHT"

@onready var animations = $AnimationPlayer
@onready var player = $"."
@onready var hitbox = $Area2D

signal died(player1: bool)
signal health_changed(health: int)
var prev_direction = 1
var jump_count = 1
var shield_poke = 0
var cur_speed = SPEED
var MAX_SPEED = 2400
var SLOW_DOWN = 40
var current_state = STARTING_STATE

var player_states = {
	"idle": Attack.new(_idle),
	"idle-air": Attack.new(_idle_air),
	"fground": Attack.new(_action, 15, Vector2(1000, -500)),
	"duck_attack": Attack.new(_duck_action, 7, Vector2(300, -100)),
	"fair": Attack.new(_air_action, 12, Vector2(400, 200)),
	"dair": Attack.new(_air_action, 25, Vector2(0, 500)),
	"uair": Attack.new(_air_action, 20, Vector2(0, -500)),
	"air_dodge": Attack.new(_air_action),
	"duck": Attack.new(_duck_action),
	"duck_idle": Attack.new(_duck_idle),
	"en-shield": Attack.new(_action),
	"un-shield": Attack.new(_action),
	"stunned": Attack.new(_stunned),
	"shield": Attack.new(_shield)
}

func _ready() -> void:
	hitbox.connect("body_entered", _on_body_entered)
	if not RIGHT_FACING:
		set_orientation(-1)
		
	if IS_PLAYER_1:
		player.set_collision_layer_value(1, true)
		hitbox.set_collision_layer_value(2, true)
		hitbox.set_collision_mask_value(4, true)
	else:
		player.set_collision_layer_value(4, true)
		hitbox.set_collision_layer_value(8, true)
		hitbox.set_collision_mask_value(1, true)

func _on_body_entered(body):
	if body is Player and body != self:
		body.attacked(player_states[current_state], RIGHT_FACING)

func attacked(attack: Attack, right: bool):
	# handle shield
	if current_state == "shield":
		shield_poke += 1
		if shield_poke < 4:
			return

	# take damage
	HEALTH -= attack.damage
	
	# calculate knockback
	if right:
		player.velocity += attack.knockback
	else:
		player.velocity.x -= attack.knockback.x
		player.velocity.y += attack.knockback.y
	
	# die and change health bar
	if HEALTH <= 0:
		emit_signal("health_changed", 0)
		die()
	else:
		emit_signal("health_changed", HEALTH)
	animations.play("stunned")
	$AudioStreamPlayer2D.play(0.0)
	current_state = "stunned"
	player.move_and_slide()
	

func die():
	emit_signal("died", IS_PLAYER_1)
	queue_free()

func _idle():
	if Input.is_action_pressed(SHIELD):
		animations.play("en-shield")
		current_state = "en-shield"
	elif Input.is_action_pressed(NORMAL_ATTACK):
		animations.play("fground")
		current_state = "fground"
	elif Input.is_action_pressed(DOWN):
		animations.play("duck")
		current_state = "duck"
	elif Input.is_action_pressed(JUMP):
		animations.play("jump")
		current_state = "idle-air"
	else:
		animations.play("idle")

func _idle_air():
	# land
	if player.is_on_floor():
		jump_count = 1
		animations.play("idle")
		current_state = "idle"
		
	# dodge
	elif Input.is_action_pressed(SHIELD):
		return # dodge
		
	# attack
	elif Input.is_action_pressed(NORMAL_ATTACK):
		if Input.is_action_pressed(DOWN):
			animations.play("dair")
			current_state = "dair"
		elif Input.is_action_pressed(JUMP):
			animations.play("uair")
			current_state = "uair"
		elif Input.is_action_pressed(LEFT) or Input.is_action_pressed(RIGHT):
			animations.play("fground")
			current_state = "fair"
		else:
			animations.play("fground")
			current_state = "fair" # nair

# uninterruptable sequence
func _action():
	pass
func _duck_action():
	pass
func _stunned():
	pass

# interruptable
func _air_action():
	if player.is_on_floor():
		jump_count = 1
		animations.play("idle")
		current_state = "idle"

func _duck_idle():
	if not Input.is_action_pressed(DOWN):
		animations.play("idle")
		current_state = "idle"
	elif Input.is_action_pressed(NORMAL_ATTACK):
		animations.play("duck_attack")
		current_state = "duck_attack"

func _shield():
	if not Input.is_action_pressed(SHIELD):
		current_state = "un-shield"
		animations.play("un-shield")

func _animation_unlock(_anim_name: StringName) -> void:
	if current_state == "en-shield":
		animations.play("shield")
		current_state = "shield"
	elif current_state == "stunned":
		animations.play("idle")
		current_state = "idle-air"
	elif player_states[current_state].state_function == _action:
		animations.play("idle")
		current_state = "idle"
	elif player_states[current_state].state_function == _air_action:
		animations.play("idle")
		current_state = "idle-air"
	elif player_states[current_state].state_function == _duck_action:
		animations.play("duck_idle")
		current_state = "duck_idle"

# run function of current state
func _process(_delta: float) -> void:
	player_states[current_state].state_function.call()

func set_orientation(direction: float) -> void:
	if direction != prev_direction and direction != 0:
		RIGHT_FACING = !RIGHT_FACING
		player.scale.x *= -1
		prev_direction = direction

func shake_body(duration: float, intensity: float):
	var elapsed = 0.0
	while elapsed < duration:
		elapsed += 0.05
		player.position.x += randf_range(-intensity, intensity)
		player.position.y += randf_range(-intensity, intensity)
		player.move_and_slide()
		await get_tree().create_timer(0.05).timeout
	position = Vector2(0, 0)
	current_state = "idle"

func _physics_process(delta: float) -> void:
	# apply gravity
	if not player.is_on_floor():
		if not Input.is_action_pressed(DOWN):
			player.velocity += player.get_gravity() * delta
		else:
			player.velocity += player.get_gravity() * delta * 5
	
	# apply horizontal velocity
	if player_states[current_state].state_function in  [_action, _duck_action]:
		player.velocity.x = 0 
	elif player_states[current_state].state_function in [_air_action, _stunned]:
		pass
	elif Input.is_action_just_pressed(JUMP):
		player.velocity.y = JUMP_VELOCITY / jump_count
		jump_count += 1
	elif current_state != "ducking":
		var direction := Input.get_axis(LEFT, RIGHT)
		if direction != 0:
			cur_speed += 20 if cur_speed < MAX_SPEED else 0
			player.velocity.x = direction * cur_speed if direction else move_toward(player.velocity.x, 0, cur_speed)
		else:
			cur_speed = SPEED
			if abs(player.velocity.x) < SLOW_DOWN:
				player.velocity.x = 0
			elif player.velocity.x < 0:
				player.velocity.x += SLOW_DOWN
			elif player.velocity.x > 0:
				player.velocity.x -= SLOW_DOWN
		set_orientation(direction)
	
	player.move_and_slide()
