extends Area2D
class_name  Arma

static var municao_max: int = 3
static var municao_atual: int = municao_max

signal alvo_atingido(pontos_ganhos: int)

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
				$SomTiro.play()
				acertou_tiro_pato()
			else:
				$SomVazio.play()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			municao_atual = municao_max
			$SomRecarga.play()


func acertou_tiro_pato():
	var areas = get_overlapping_areas()
	for area in areas:
		if area.is_in_group("patos"):
			area.morrer()
			alvo_atingido.emit(10)
			break
