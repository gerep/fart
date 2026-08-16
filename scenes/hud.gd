extends Control

@onready var buy_button: Button = $MarginContainer/HBoxContainer/BuyButton


func _ready() -> void:
	buy_button.pressed.connect(_on_buy_button_pressed)
	GameManager.build_mode_changed.connect(_on_build_mode_changed)
	_on_build_mode_changed(false)


func _on_buy_button_pressed() -> void:
	GameManager.build_mode.emit(true)


func _on_build_mode_changed(enabled: bool) -> void:
	buy_button.disabled = enabled
