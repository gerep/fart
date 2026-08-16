class_name Bullet
extends Area2D

@export var speed: float = 500.0
@export var lifetime: float = 2.0

var _velocity := Vector2.ZERO


func _ready() -> void:
	area_entered.connect(_area_entered)


func setup(target_position: Vector2) -> void:
	var direction := global_position.direction_to(target_position)
	_velocity = direction * speed
	rotation = direction.angle() + PI / 2.0


func _process(delta: float) -> void:
	global_position += _velocity * delta
	lifetime -= delta

	if lifetime <= 0.0:
		queue_free()


func _area_entered(area: Area2D) -> void:
	if area.collision_layer & 2 == 0:
		return

	area.call_deferred("queue_free")
	call_deferred("queue_free")
