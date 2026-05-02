extends Area2D
class_name  Arma

static var municao_max: int = 3
static var municao_atual: int = municao_max

signal alvo_atingido(pontos_ganhos: int)
signal municao_alterada(quantidade_atual: int)
signal tempo_adicionado(tempo_ganho: float)
signal vida_perdida()
signal explosao_acionada()
signal congelamento_acionado()
signal frenzy_acionado()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	z_index = GameLayers.Layers.MIRA


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		global_position = event.position
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if municao_atual > 0:
				municao_atual -= 1
				municao_alterada.emit(municao_atual)
				$SomTiro.play()
				acertou_tiro_pato()
			else:
				$SomVazio.play()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			recarregar_arma()


func acertou_tiro_pato():
	var areas = get_overlapping_areas()
	for area in areas:
		if area.is_in_group("patos"):
			var pontos = area.get("pontos_abate") if area.get("pontos_abate") != null else 10
			var bonus = area.get("tempo_bonus") if area.get("tempo_bonus") != null else 0.0
			if area.get("penaliza_vida") == true:
				vida_perdida.emit()
			else:
				alvo_atingido.emit(pontos)
				if bonus > 0.0:
					tempo_adicionado.emit(bonus)
			area.morrer()
		elif area.is_in_group("alvos"):
			var pontos_alvo = area.get("pontos_abate") if area.get("pontos_abate") != null else 10
			if area.get("explosivo") == true:
				explosao_acionada.emit()
			elif area.get("congelante") == true:
				congelamento_acionado.emit()
			elif area.get("recarrega_municao") == true:
				recarregar_arma()
			elif area.get("ativa_frenzy") == true:
				frenzy_acionado.emit()
			else:
				alvo_atingido.emit(pontos_alvo)
			area.morrer()
		elif area.is_in_group("tabuas"):
			area.get_parent().get_parent().quebrar_tabua()


func recarregar_arma():
	municao_atual = municao_max
	municao_alterada.emit(municao_atual)
	$SomRecarga.play()
