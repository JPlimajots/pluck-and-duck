extends Area2D

var velocidade: float = 150.0 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += delta * velocidade


func morrer():
	remove_from_group("patos")
	$Sprite2D.texture = load("res://assets/Objects/duck_outline_back.png")
	await get_tree().create_timer(0.6).timeout
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
