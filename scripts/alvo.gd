extends Area2D


@export var textura_tabua_quebrada = Texture2D
@export var tempo_de_vida: float = 3.0
@export var pontos_abate: int = 50
@export var explosivo: bool = false
@export var congelante: bool = false
@export var recarrega_municao: bool = false
@export var ativa_frenzy: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DobradicaPivo.scale.y = 0.0
	modulate = Color(0.2, 0.2, 0.2, 1.0)
	var tween = create_tween()
	tween.tween_property($DobradicaPivo, "scale:y", 1.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)
	tween.tween_interval(tempo_de_vida)
	tween.tween_callback(fugir)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func morrer():
	desativar_colisoes()
	animar_queda_tras()


func quebrar_tabua():
	desativar_colisoes()
	$DobradicaPivo/AreaTabua/SpriteTabua.texture = textura_tabua_quebrada
	var tween = create_tween()
	tween.tween_property($DobradicaPivo/SpriteAlvo, "position:y", $DobradicaPivo/SpriteAlvo.position.y - 100, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($DobradicaPivo/SpriteAlvo, "position:y", $DobradicaPivo/SpriteAlvo.position.y + 400, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property($DobradicaPivo/SpriteAlvo, "rotation_degrees", 90.0, 0.8)
	tween.tween_callback(queue_free)


func fugir():
	desativar_colisoes()
	animar_queda_tras()


func animar_queda_tras():
	var tween = create_tween()
	tween.tween_property($DobradicaPivo, "scale:y", 0.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "modulate", Color(0.2, 0.2, 0.2, 1.0), 0.3)
	tween.tween_callback(queue_free)


func desativar_colisoes():
	$ColisaoAlvo.set_deferred("disabled", true)
	$DobradicaPivo/AreaTabua/ColisaoTabua.set_deferred("disabled", true)
