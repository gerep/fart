extends Control

@onready var buy_button: Button = $MarginContainer/HBoxContainer/BuyButton
@onready var base_health_label: Label = $MarginContainer/HBoxContainer/BaseHealthLabel
@onready var wave_label: Label = $MarginContainer/HBoxContainer/WaveLabel
@onready var start_wave_button: Button = $MarginContainer/HBoxContainer/StartWaveButton


func _ready() -> void:
	buy_button.pressed.connect(_on_buy_button_pressed)
	start_wave_button.pressed.connect(_on_start_wave_button_pressed)
	GameManager.build_mode_changed.connect(_on_build_mode_changed)
	GameManager.base_health_changed.connect(_on_base_health_changed)
	GameManager.wave_number_changed.connect(_on_wave_number_changed)
	GameManager.wave_state_changed.connect(_on_wave_state_changed)
	_on_build_mode_changed(false)
	_on_wave_number_changed(0)
	_on_wave_state_changed(false)


func _on_buy_button_pressed() -> void:
	GameManager.build_mode.emit(true)


func _on_build_mode_changed(enabled: bool) -> void:
	buy_button.disabled = enabled


func _on_base_health_changed(value: int) -> void:
	base_health_label.text = "Base HP: %d" % value


func _on_wave_number_changed(value: int) -> void:
	wave_label.text = "Wave: %d" % value


func _on_wave_state_changed(active: bool) -> void:
	start_wave_button.disabled = active


func _on_start_wave_button_pressed() -> void:
	GameManager.wave_start_requested.emit()
