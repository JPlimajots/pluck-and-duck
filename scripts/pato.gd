extends Area2D

@export var textura_tabua_quebrada: Texture2D
@export var textura_pato_costas: Texture2D
@export var amplitude_onda: float = 10.0
@export var velocidade_onda: float = 5.0
@export var angulo_pendulo: float = 15.0
@export var velocidade_pendulo: float = 4.0
@export var velocidade: float = 150.0 
@export var pontos_abate: int = 10
var tempo_decorrido: float = 0.0
var y_inicial = 0.0
var tem_onda: bool = false
var tem_pendulo: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	y_inicial = position.y
	tem_onda = randf() > 0.5
	tem_pendulo = randf() > 0.5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += delta * velocidade
	tempo_decorrido += delta
	if tem_onda:
		position.y = y_inicial + (sin(tempo_decorrido * velocidade_onda) * amplitude_onda)
	if tem_pendulo:
		$DobradicaPivo.rotation_degrees = sin(tempo_decorrido * velocidade_pendulo) * angulo_pendulo 


func morrer():
	$CollisionShape2D.set_deferred("disabled", true)
	$DobradicaPivo/AreaTabua/CollisionShape2D.set_deferred("disabled", true)
	if randf() > 0.5:
		animar_giro_180()
	else:
		animar_queda_tras()
	remove_from_group("patos")
	await get_tree().create_timer(0.6).timeout
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func quebrar_tabua():
	$DobradicaPivo/AreaTabua/Sprite2D.texture = textura_tabua_quebrada
	$CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D2.set_deferred("disabled", true)
	$DobradicaPivo/AreaTabua/CollisionShape2D.set_deferred("disabled", true)
	var tween = create_tween()
	tween.tween_property($DobradicaPivo/Sprite2D, "position:y", $DobradicaPivo/Sprite2D.position.y - 100, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($DobradicaPivo/Sprite2D, "position:y", $DobradicaPivo/Sprite2D.position.y + 400, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property($DobradicaPivo/Sprite2D, "rotation_degrees", 90.0, 0.8)


func virar_de_costas():
	$DobradicaPivo/Sprite2D.texture = textura_pato_costas
	$DobradicaPivo/AreaTabua.show_behind_parent = false


func animar_giro_180():
	var tamanho_origianl = abs(scale.x)
	var tween = create_tween()
	tween.tween_property(self, "scale:x", 0.0, 0.10).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(virar_de_costas)
	tween.tween_property(self, "scale:x", -tamanho_origianl, 0.10).set_trans(Tween.TRANS_SINE)


func animar_queda_tras():
	var tween = create_tween()
	tween.tween_property($DobradicaPivo, "scale:y", 0.0, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "modulate", Color(0.15, 0.15, 0.15, 1.0), 0.2)
