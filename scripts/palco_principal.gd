extends Node2D

@onready var cena_pato = preload("res://scenes/pato.tscn")
@onready var cena_pato_branco = preload("res://scenes/pato_branco.tscn")
@onready var cena_alvo = preload("res://scenes/alvo.tscn")
@export var texture_bala_cheia: Texture2D
@export var texture_bala_vazia: Texture2D

var pontuacao_atual: int = 0
var tempo_restante: float = 60.0
var jogo_ativo: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Cenario/BGwood.z_index = GameLayers.Layers.PAREDE
	$Cenario/tree_oak.z_index = GameLayers.Layers.ARVORE_OAK
	$Cenario/grass.z_index = GameLayers.Layers.GRAMA
	$Cenario/tree_pine.z_index = GameLayers.Layers.ARVORE_PINE
	$Cenario/water_back.z_index = GameLayers.Layers.AGUA_TRAS
	$Cenario/water_front.z_index = GameLayers.Layers.AGUA_FRENTE
	$Cenario/balcao.z_index = GameLayers.Layers.BALCAO
	$Cenario/curtain_top.z_index = GameLayers.Layers.CORTINA_TOP
	$Cenario/curtain_left.z_index = GameLayers.Layers.CORTINA_LEFT
	$Cenario/curtain_right.z_index = GameLayers.Layers.CORTINA_RIGHT
	$Cenario/curtain_straight.z_index = GameLayers.Layers.CORTINA_STRAIGHT
	$Cenario/curtain_rope_left.z_index = GameLayers.Layers.CORTINA_ROPE
	$Cenario/curtain_rope_right.z_index = GameLayers.Layers.CORTINA_ROPE
	$Mira.municao_alterada.connect(atualizar_interface_municao)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_position = get_viewport().get_mouse_position()
	var tela_y = get_viewport_rect().size.y
	var centro_x = get_viewport_rect().size.x / 2.0
	var escala_alvo = -1.0 if mouse_position.x > centro_x else 1.0
	$HUD/RifleVisual.scale.x = lerp($HUD/RifleVisual.scale.x, escala_alvo, 15.0 * delta)
	var angulo_alvo = remap(mouse_position.y, 0, tela_y, 15.0, -10.0)
	if escala_alvo == -1.0:
		angulo_alvo = -angulo_alvo
	$HUD/RifleVisual.rotation_degrees = lerp($HUD/RifleVisual.rotation_degrees, angulo_alvo, 10.0 * delta)	
	if jogo_ativo:
		tempo_restante -= delta
		var segundos = int(ceil(tempo_restante))
		$Interface/TextoTempo.text = "%02d" % segundos
		if $GeradorAlvosGrama.is_stopped():
			$GeradorAlvosGrama.start(randf_range(3.0, 8.0))
		if $GeradorAlvosTeto.is_stopped():
			$GeradorAlvosTeto.start(randf_range(3.0, 8.0))
		if tempo_restante <= 0:
			finaliza_jogo()


func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_gerador_de_patos_timeout() -> void:
	var novo_pato = null
	var chance = randf()
	if chance <= 0.75:
		novo_pato = cena_pato.instantiate()
	else:
		novo_pato = cena_pato_branco.instantiate()
	novo_pato.position = $PontoDeSpawn.position
	var velocidade_dificil = remap(tempo_restante, 60.0, 0.0, 150.0, 350.0)
	novo_pato.velocidade = velocidade_dificil
	add_child(novo_pato)
	var base = remap(tempo_restante, 60.0, 0.0, 3.0, 0.8)
	$GeradorDePatos.wait_time = randf_range(base * 0.7, base * 1.3)


func _on_mira_alvo_atingido(pontos_ganhos: int) -> void:
	pontuacao_atual += pontos_ganhos
	$Interface/TextoPontos.text = str(pontuacao_atual)


func finaliza_jogo():
	jogo_ativo = false
	tempo_restante = 0
	$Interface/TextoTempo.text = "00"
	$GeradorDePatos.stop()
	$GeradorDePatosFundo.stop()
	$GeradorAlvosGrama.stop()
	$GeradorAlvosTeto.stop()
	print("FIM DE JOGO! Pontuação Final: ", pontuacao_atual)


func _on_gerador_de_patos_fundo_timeout() -> void:
	var novo_pato = null
	var chance = randf()
	if chance <= 0.75:
		novo_pato = cena_pato.instantiate()
	else:
		novo_pato = cena_pato_branco.instantiate()
	novo_pato.position = $PontoDeSpawnFundo.position
	novo_pato.scale = Vector2(0.7, 0.7)
	novo_pato.z_index = GameLayers.Layers.PATO_TRAS
	var velocidade_fundo = remap(tempo_restante, 60.0, 0.0, 100.0, 250.0)
	novo_pato.velocidade = velocidade_fundo
	add_child(novo_pato)
	var base_fundo = remap(tempo_restante, 60.0, 0.0, 4.0, 1.2)
	$GeradorDePatosFundo.wait_time = randf_range(base_fundo * 0.8, base_fundo * 1.5)


func _on_gerador_alvos_grama_timeout() -> void:
	var novo_alvo = cena_alvo.instantiate()
	var x_aleatorio = randf_range(280.0, 1000.0)
	novo_alvo.position = Vector2(x_aleatorio, $LinhaSpawnAlvosGrama.position.y)
	novo_alvo.scale = Vector2(0.6, 0.6)
	novo_alvo.z_index = GameLayers.Layers.ALVO
	novo_alvo.tempo_de_vida = remap(tempo_restante, 60.0, 0.0, 3.0, 1.0)
	add_child(novo_alvo)
	var tempo_base_spawn = remap(tempo_restante, 60.0, 0.0, 10.0, 4.0)
	$GeradorAlvosGrama.wait_time = randf_range(tempo_base_spawn * 0.8, tempo_base_spawn * 1.5)


func _on_gerador_alvos_teto_timeout() -> void:
	var novo_alvo = cena_alvo.instantiate()
	var x_aleatorio = randf_range(280.0, 1000.0)
	novo_alvo.position = Vector2(x_aleatorio, $LinhaSpawnAlvosTeto.position.y)
	novo_alvo.scale = Vector2(0.6, 0.6)
	novo_alvo.z_index = GameLayers.Layers.ALVO
	novo_alvo.rotation_degrees = 180.0
	novo_alvo.de_cabeca_para_baixo = true
	novo_alvo.tempo_de_vida = remap(tempo_restante, 60.0, 0.0, 3.0, 1.0)
	add_child(novo_alvo)
	var tempo_base_spawn = remap(tempo_restante, 60.0, 0.0, 10.0, 4.0)
	$GeradorAlvosTeto.wait_time = randf_range(tempo_base_spawn * 0.8, tempo_base_spawn * 1.5)


func atualizar_interface_municao(quantidade: int):
	var container = $HUD/MarginContainer/MunicaoUI
	for i in range(container.get_child_count()):
		var icone_bala = container.get_child(i)
		if i < quantidade:
			icone_bala.texture = texture_bala_cheia
		else:
			icone_bala.texture = texture_bala_vazia
