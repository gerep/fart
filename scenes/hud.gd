extends Control

@onready var buy_button: Button = $MarginContainer/HBoxContainer/BuyButton
@onready var base_health_label: Label = $MarginContainer/HBoxContainer/BaseHealthLabel


func _ready() -> void:
	buy_button.pressed.connect(_on_buy_button_pressed)
	GameManager.build_mode_changed.connect(_on_build_mode_changed)
	GameManager.base_health_changed.connect(_on_base_health_changed)
	_on_build_mode_changed(false)


func _on_buy_button_pressed() -> void:
	GameManager.build_mode.emit(true)


func _on_build_mode_changed(enabled: bool) -> void:
	buy_button.disabled = enabled


func _on_base_health_changed(value: int) -> void:
	base_health_label.text = "Base HP: %d" % value
