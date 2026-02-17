extends Node

var currency: int = 0
var rod_level: int = 1
var show_level_select_on_main: bool = false
var music_volume: float = 0.8
var sfx_volume: float = 0.8
var music_enabled: bool = true
var vibration_enabled: bool = true

func get_fish_chances() -> Dictionary:
	var base_blue := 0.85
	var base_orange := 0.13
	var base_red := 0.02

	var orange_bonus := rod_level * 0.01
	var red_bonus := rod_level * 0.002

	var blue := base_blue - orange_bonus - red_bonus
	var orange := base_orange + orange_bonus
	var red := base_red + red_bonus

	return {
		"blue": max(blue, 0.0),
		"orange": max(orange, 0.0),
		"red": max(red, 0.0)
	}
