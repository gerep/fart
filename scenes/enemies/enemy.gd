class_name Enemy
extends Area2D

@export var speed: float = 100.0
@export var health: int = 1

signal escaped

@onready var health_label: Label = $HealthLabel

var path: Path2D
var distance: float = 0.0


func _ready() -> void:
	health_label.text = str(health)


func setup(new_path: Path2D) -> void:
	path = new_path
	global_transform = path.global_transform * path.curve.sample_baked_with_rotation(0.0)


func take_damage(amount: int) -> void:
	health -= amount
	health_label.text = str(health)
	if health <= 0:
		queue_free()


func _process(delta: float) -> void:
	distance += speed * delta

	var path_length := path.curve.get_baked_length()
	if distance >= path_length:
		escaped.emit()
		queue_free()
		return

	var path_transform: Transform2D = path.curve.sample_baked_with_rotation(distance)
	global_transform = path.global_transform * path_transform
