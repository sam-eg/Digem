extends Node2D

signal game_over

@onready var game_over_control = $UI/GameOverControl

@export var playing = true

func _on_player_out_of_fuel():
	playing = false
	game_over.emit()
	game_over_control.show()


func _on_restart_button_pressed():
	get_tree().reload_current_scene()
