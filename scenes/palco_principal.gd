extends Node2D


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
	pass
