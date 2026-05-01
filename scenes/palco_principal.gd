extends Node2D

@export var cena_pato: PackedScene

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
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if jogo_ativo:
		var tempo_base_frente = remap(tempo_restante, 60.0, 0.0, 3.0, 0.8)
		var tempo_base_fundo = remap(tempo_restante, 60.0, 0.0, 4.0, 1.2)
		tempo_restante -= delta
		var segundos = int(ceil(tempo_restante))
		$Interface/TextoTempo.text = "%02d" % segundos
		if tempo_restante <= 0:
			finaliza_jogo()


func _on_gerador_de_patos_timeout() -> void:
	var novo_pato = cena_pato.instantiate()
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
	print("FIM DE JOGO! Pontuação Final: ", pontuacao_atual)


func _on_gerador_de_patos_fundo_timeout() -> void:
	var pato_fundo = cena_pato.instantiate()
	pato_fundo.position = $PontoDeSpawnFundo.position
	pato_fundo.scale = Vector2(0.7, 0.7)
	pato_fundo.z_index = GameLayers.Layers.PATO_TRAS
	var velocidade_fundo = remap(tempo_restante, 60.0, 0.0, 100.0, 250.0)
	pato_fundo.velocidade = velocidade_fundo
	add_child(pato_fundo)
	var base_fundo = remap(tempo_restante, 60.0, 0.0, 4.0, 1.2)
	$GeradorDePatosFundo.wait_time = randf_range(base_fundo * 0.8, base_fundo * 1.5)
