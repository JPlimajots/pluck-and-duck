extends Area2D

@export var textura_tabua_quebrada: Texture2D

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


func quebrar_tabua():
	$AreaTabua/Sprite2D.texture = textura_tabua_quebrada
	$CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D2.set_deferred("disabled", true)
	$AreaTabua/CollisionShape2D.set_deferred("disabled", true)
	var tween = create_tween()
	tween.tween_property($Sprite2D, "position:y", $Sprite2D.position.y - 100, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($Sprite2D, "position:y", $Sprite2D.position.y + 400, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property($Sprite2D, "rotation_degrees", 90.0, 0.8)
