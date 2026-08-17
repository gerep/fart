extends Node

signal build_mode(b: bool)
signal build_mode_changed(enabled: bool)
signal base_health_changed(value: int)
signal wave_start_requested
signal wave_state_changed(active: bool)
signal wave_number_changed(value: int)
signal money_changed(value: int)
signal turret_affordability_changed(can_afford: bool)
