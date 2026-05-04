extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	$UI/VBoxContainer/BotaoJogar.pressed.connect(_on_jogar_pressed)
	$UI/VBoxContainer/BotaoSair.pressed.connect(_on_sair_pressed)


func _on_jogar_pressed():
	get_tree().change_scene_to_file("res://scenes/palco_principal.tscn")


func _on_sair_pressed():
	get_tree().quit()
