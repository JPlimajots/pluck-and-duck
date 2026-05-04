extends Node2D

@onready var cena_pato = preload("res://scenes/pato.tscn")
@onready var cena_pato_branco = preload("res://scenes/pato_branco.tscn")
@onready var cena_pato_amarelo = preload("res://scenes/pato_amarelo.tscn")
@onready var cena_pato_inocente = preload("res://scenes/pato_inocente.tscn")
@onready var cena_alvo = preload("res://scenes/alvo.tscn")
@onready var cena_alvo_explosivo = preload("res://scenes/alvo_explosivo.tscn")
@onready var cena_alvo_branco = preload("res://scenes/alvo_branco.tscn")
@onready var cena_alvo_municao = preload("res://scenes/alvo_municao.tscn")
@onready var cena_alvo_frenzy = preload("res://scenes/alvo_frenzy.tscn")
@export var texture_bala_cheia: Texture2D
@export var texture_bala_vazia: Texture2D
@export var text_ready: Texture2D
@export var text_go: Texture2D
@export var text_timeup: Texture2D
@export var text_gameover: Texture2D
@export var text_score: Texture2D

var pontuacao_atual: int = 0
var tempo_restante: float = 60.0
var jogo_ativo: bool = false
var vidas_atuais: int = 3
var relogio_congelado: bool = false
var multiplicador_de_pontos: int = 1
var pode_reiniciar: bool = false

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
	$TimerQuack.timeout.connect(_on_timer_quack_timeout)
	$TimerQuack.start(randf_range(3.0, 7.0))
	$Mira.municao_alterada.connect(atualizar_interface_municao)
	$Mira.tempo_adicionado.connect(_on_tempo_adicionado)
	$Mira.vida_perdida.connect(_on_vida_perdida)
	$Mira.explosao_acionada.connect(_on_explosao_acionada)
	$Mira.congelamento_acionado.connect(_on_congelamento_acionado)
	$Mira.frenzy_acionado.connect(_on_frenzy_acionado)
	$Mira.combo_atualizado.connect(_on_mira_combo_atualizado)
	$Mira.arma_travada = true
	var visor_msg = $HUD/MensagemCentroUI
	visor_msg.texture = text_ready
	visor_msg.show()
	await get_tree().create_timer(1.5).timeout
	visor_msg.texture = text_go
	await  get_tree().create_timer(1.0).timeout
	visor_msg.hide()
	jogo_ativo = true
	$Mira.arma_travada = false

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
		if not relogio_congelado:
			tempo_restante -= delta
			var segundos = int(ceil(tempo_restante))
			$Interface/TextoTempo.text = "%02d" % segundos
			if $GeradorAlvosGrama.is_stopped():
				$GeradorAlvosGrama.start(randf_range(1.5, 4.0))
			if tempo_restante <= 0:
				finaliza_jogo()


func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	elif event is InputEventKey and event.keycode == KEY_R and event.pressed:
		if  pode_reiniciar:
			get_tree().reload_current_scene()


func _on_gerador_de_patos_timeout() -> void:
	var novo_pato = null
	var chance = randf()
	if chance <= 0.60:
		novo_pato = cena_pato.instantiate()
	elif chance <= 0.80:
		novo_pato = cena_pato_branco.instantiate()
	else:
		novo_pato = cena_pato_inocente.instantiate()
	novo_pato.position = $PontoDeSpawn.position
	var velocidade_base = novo_pato.velocidade
	var velocidade_dificil = remap(tempo_restante, 60.0, 0.0, velocidade_base, velocidade_base + 150.0)
	novo_pato.velocidade = velocidade_dificil
	add_child(novo_pato)
	var base = remap(tempo_restante, 60.0, 0.0, 1.5, 0.4)
	$GeradorDePatos.wait_time = randf_range(base * 0.7, base * 1.3)


func _on_mira_alvo_atingido(pontos_ganhos: int) -> void:
	var pontos_finais = pontos_ganhos * multiplicador_de_pontos
	pontuacao_atual += pontos_finais
	$HUD/ContadorPontosUI/TextoPontos.text = str(pontuacao_atual)


func finaliza_jogo(vitoria: bool = true):
	jogo_ativo = false
	tempo_restante = 0
	$Interface/TextoTempo.text = "00"
	$Mira.arma_travada = true
	$GeradorDePatos.stop()
	$GeradorDePatosFundo.stop()
	$GeradorAlvosGrama.stop()
	if vitoria:
		var visor_msg = $HUD/MensagemCentroUI
		visor_msg.texture = text_timeup
		visor_msg.show()
		await get_tree().create_timer(2.5).timeout
		visor_msg.hide()
		$HUD/ContadorPontosUI.hide()
		$HUD/ResultadoFinal/PontosFinalLabel.text = str(pontuacao_atual)
		$HUD/ResultadoFinal.show()
		var container_final = $HUD/ResultadoFinal
		container_final.scale = Vector2.ZERO
		container_final.pivot_offset = container_final.size
		var tween = create_tween()
		tween.tween_property(container_final, "scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(container_final, "scale", Vector2.ONE, 0.1)
	else:
		$HUD/ResultadoFinal/ScoreTituloUI.hide()
		$HUD/ResultadoFinal/PontosFinalLabel.hide()
		$HUD/ResultadoFinal/TextoReiniciar.show()
		$HUD/ResultadoFinal.show()
		$HUD/ResultadoFinal.scale = Vector2.ONE
	pode_reiniciar = true
	var tween_som = create_tween()
	tween_som.tween_property($MusicaFundo, "volume_db", -20.0, 1.5)


func _on_gerador_de_patos_fundo_timeout() -> void:
	var novo_pato = null
	var chance = randf()
	if chance <= 0.60:
		novo_pato = cena_pato.instantiate()
	elif chance <= 0.75:
		novo_pato = cena_pato_branco.instantiate()
	elif chance <= 0.90:
		novo_pato = cena_pato_inocente.instantiate()
	else:
		novo_pato = cena_pato_amarelo.instantiate()
	novo_pato.position = $PontoDeSpawnFundo.position
	novo_pato.scale = Vector2(0.7, 0.7)
	novo_pato.z_index = GameLayers.Layers.PATO_TRAS
	var velocidade_base = novo_pato.velocidade
	var velocidade_fundo = remap(tempo_restante, 60.0, 0.0, velocidade_base, velocidade_base + 200.0)
	novo_pato.velocidade = velocidade_fundo
	add_child(novo_pato)
	var base_fundo = remap(tempo_restante, 60.0, 0.0, 2.0, 0.6)
	$GeradorDePatosFundo.wait_time = randf_range(base_fundo * 0.8, base_fundo * 1.5)


func _on_gerador_alvos_grama_timeout() -> void:
	var novo_alvo = null
	var chance = randf()
	if chance <= 0.50:
		novo_alvo = cena_alvo.instantiate()
	elif chance <= 0.65:
		novo_alvo = cena_alvo_branco.instantiate()
	elif chance <= 0.80:
		novo_alvo = cena_alvo_explosivo.instantiate()
	elif chance <= 0.90:
		novo_alvo = cena_alvo_municao.instantiate()
	else:
		novo_alvo = cena_alvo_frenzy.instantiate()
	var x_aleatorio = randf_range(280.0, 1000.0)
	novo_alvo.position = Vector2(x_aleatorio, $LinhaSpawnAlvosGrama.position.y)
	novo_alvo.scale = Vector2(0.6, 0.6)
	novo_alvo.z_index = GameLayers.Layers.ALVO
	novo_alvo.tempo_de_vida = remap(tempo_restante, 60.0, 0.0, 3.0, 1.0)
	add_child(novo_alvo)
	var tempo_base_spawn = remap(tempo_restante, 60.0, 0.0, 3.0, 1.0)
	$GeradorAlvosGrama.wait_time = randf_range(tempo_base_spawn * 0.8, tempo_base_spawn * 1.5)


func atualizar_interface_municao(quantidade: int):
	var container = $HUD/MarginContainer/MunicaoUI
	for i in range(container.get_child_count()):
		var icone_bala = container.get_child(i)
		if i < quantidade:
			icone_bala.texture = texture_bala_cheia
		else:
			icone_bala.texture = texture_bala_vazia


func _on_tempo_adicionado(bonus: float):
	tempo_restante += bonus


func _on_vida_perdida():
	vidas_atuais -= 1
	if vidas_atuais >= 0 and vidas_atuais < 3:
		var patinho_ui = $HUD/ContainerVidas.get_child(vidas_atuais)
		patinho_ui.visible = false
	if vidas_atuais <= 0:
		$HUD/MensagemCentroUI.texture = text_gameover
		$HUD/MensagemCentroUI.show()
		finaliza_jogo(false)
		


func _on_explosao_acionada():
	$SomExplosao.play()
	var flash = $HUD/FlashExplosao
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.4, 0.05)
	tween.tween_property(flash, "modulate:a", 0.0, 0.2)
	var todos_os_patos = get_tree().get_nodes_in_group("patos")
	for pato in todos_os_patos:
		if pato.get("penaliza_vida") == true:
			_on_vida_perdida()
		else:
			var pontos = pato.get("pontos_abate") if pato.get("pontos_abate") != null else 10
			var bonus = pato.get("tempo_bonus") if pato.get("tempo_bonus") != null else 0.0
			_on_mira_alvo_atingido(pontos)
			if bonus > 0.0:
				_on_tempo_adicionado(bonus)
		if pato.has_method("morrer"):
			pato.morrer()


func _on_congelamento_acionado():
	$SomTimeStop.play()
	var label_tempo = $Interface/TextoTempo
	label_tempo.modulate = Color(0.3, 0.5, 1.0)
	relogio_congelado = true
	$GeradorDePatos.paused = true
	$GeradorDePatosFundo.paused = true
	$GeradorAlvosGrama.paused = true
	get_tree().call_group("patos", "congelar")
	await get_tree().create_timer(2.5).timeout
	var tween = create_tween()
	tween.tween_property(label_tempo, "modulate:a", 0.3, 0.2)
	tween.tween_property(label_tempo, "modulate:a", 1.0, 0.2)
	tween.set_loops(2)
	$SomTimeStopReverse.play()
	await get_tree().create_timer(1.0).timeout
	label_tempo.modulate = Color(1, 1, 1)
	relogio_congelado = false
	$GeradorDePatos.paused = false
	$GeradorDePatosFundo.paused = false
	$GeradorAlvosGrama.paused = false
	get_tree().call_group("patos", "descongelar")


func _on_frenzy_acionado():
	$SomFrenzy.play()
	$Mira.frenzy_ativo = true
	$HUD/ContadorPontosUI/TextoPontos.modulate = Color(1, 0.2, 0.2)
	await get_tree().create_timer(5.0).timeout
	$Mira.frenzy_ativo = false
	var nivel_atual = floor($Mira.combo_atual / 6)
	$HUD/ContadorPontosUI/TextoPontos.modulate = $Mira.obter_cor_combo(nivel_atual)


func _on_mira_combo_atualizado(valor: int, _multiplicador: int):
	var label_pontos = $HUD/ContadorPontosUI/TextoPontos
	@warning_ignore("integer_division")
	var nivel = floor(valor / 6)
	var cor_alvo = $Mira.obter_cor_combo(nivel)
	label_pontos.modulate = cor_alvo
	if nivel > 0:
		tremer_score(nivel)


func tremer_score(intensidade: int):
	var label = $HUD/ContadorPontosUI
	var original_pos = label.position
	var forca = intensidade * 5.0
	var tween = create_tween()
	for i in range(5):
		var offset = Vector2(randf_range(-forca, forca), randf_range(-forca, forca))
		tween.tween_property(label, "position", original_pos + offset, 0.03)
	tween.tween_property(label, "position", original_pos, 0.03)


func _on_timer_quack_timeout():
	if jogo_ativo:
		$SomQuack.play()
	$TimerQuack.start(randf_range(4.0, 10.0))
