extends Control

@onready var buy_button: Button = $MarginContainer/HBoxContainer/BuyButton

var _build_state: bool = false


func _ready() -> void:
	buy_button.pressed.connect(_on_buy_button_pressed)


func _on_buy_button_pressed() -> void:
	_build_state = !_build_state
	GameManager.build_mode.emit(_build_state)
