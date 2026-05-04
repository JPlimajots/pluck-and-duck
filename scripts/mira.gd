extends Area2D
class_name  Arma

@onready var cena_texto_flutuante = preload("res://scenes/texto_flutuante.tscn")

var municao_max: int = 3
var municao_atual: int = municao_max
var arma_travada: bool = true
var combo_atual: int = 0
var frenzy_ativo: bool = false

signal alvo_atingido(pontos_ganhos: int)
signal municao_alterada(quantidade_atual: int)
signal tempo_adicionado(tempo_ganho: float)
signal vida_perdida()
signal explosao_acionada()
signal congelamento_acionado()
signal frenzy_acionado()
signal combo_atualizado(valor_combo: int, multiplicador: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	z_index = GameLayers.Layers.MIRA


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		global_position = event.position
		$CamadaVisual/mira.global_position = event.position
	elif event is InputEventMouseButton:
		if not arma_travada:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if municao_atual > 0:
					municao_atual -= 1
					municao_alterada.emit(municao_atual)
					$SomTiro.play()
					var acertou = acertou_tiro_pato()
					if acertou:
						var nivel_antes = floor(combo_atual / 6)
						combo_atual += 1
						var nivel_depois = floor(combo_atual / 6)
						if nivel_depois > nivel_antes:
							$SomComboUp.play()
					else:
						if not frenzy_ativo:
							if combo_atual > 0:
								$SomComboLost.play()
						combo_atual = 0
					@warning_ignore("integer_division")
					var nivel_combo = floor(combo_atual / 6)
					var mult_combo = pow(2, nivel_combo)
					combo_atualizado.emit(combo_atual, mult_combo)
				else:
					$SomVazio.play()
			elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				recarregar_arma()


func acertou_tiro_pato():
	var areas = get_overlapping_areas()
	@warning_ignore("integer_division")
	var nivel_combo = floor(combo_atual / 6)
	var mult_combo = pow(2, nivel_combo)
	var mult_final = mult_combo * (2 if frenzy_ativo else 1)
	for area in areas:
		if area.is_in_group("patos"):
			var pontos_base = area.get("pontos_abate") if area.get("pontos_abate") != null else 10
			var pontos_totais = pontos_base * mult_final
			var bonus = area.get("tempo_bonus") if area.get("tempo_bonus") != null else 0.0
			if area.get("penaliza_vida") == true:
				vida_perdida.emit()
				mostrar_pontos_flutuantes(0, area.global_position, Color(1, 0, 0))
			else:
				alvo_atingido.emit(pontos_totais)
				mostrar_pontos_flutuantes(pontos_totais, area.global_position, obter_cor_combo(nivel_combo))
				if bonus > 0.0:
					tempo_adicionado.emit(bonus)
			area.morrer()
			return true
		elif area.is_in_group("alvos"):
			var pontos_base = area.get("pontos_abate") if area.get("pontos_abate") != null else 10
			var pontos_totais = pontos_base + mult_final
			if area.get("explosivo") == true:
				explosao_acionada.emit()
			elif area.get("congelante") == true:
				congelamento_acionado.emit()
			elif area.get("recarrega_municao") == true:
				recarregar_arma()
			elif area.get("ativa_frenzy") == true:
				frenzy_acionado.emit()
			else:
				alvo_atingido.emit(pontos_totais)
				mostrar_pontos_flutuantes(pontos_totais, area.global_position, obter_cor_combo(nivel_combo))
			area.morrer()
			return true
		elif area.is_in_group("tabuas"):
			area.get_parent().get_parent().quebrar_tabua()
			return true
	return false


func recarregar_arma():
	municao_atual = municao_max
	municao_alterada.emit(municao_atual)
	$SomRecarga.play()


func mostrar_pontos_flutuantes(pontos: int, pos: Vector2, cor:Color = Color(1, 1, 1)):
	var texto = cena_texto_flutuante.instantiate()
	texto.valor = "+" +str(pontos)
	texto.global_position = pos
	texto.modulate = cor
	get_tree().current_scene.add_child(texto)


func obter_cor_combo(nivel: int):
	match nivel:
		0: return Color(1, 1, 1)
		1: return Color(1, 0.9, 0.4)
		2: return Color(1, 0.8, 0)
		3: return Color(1, 0.4, 0)
		_: return Color(1, 0, 0.2)
