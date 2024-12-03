class_name Attack extends Resource

@export var damage: int
@export var knockback: Vector2
@export var state_function: Callable

func _do_nothing():
	pass

func _init(sf: Callable = Callable(self, "_do_nothing"), dmg: int = 0, kb: Vector2 = Vector2.ZERO) -> void:
	self.damage = dmg
	self.knockback = kb
	self.state_function = sf
