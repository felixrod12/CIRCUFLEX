extends Node2D

# Variables eléctricas globales
var voltaje_bateria : float = 12.0
var resistencia_foco : float = 6.0

# Almacena la fase de experimentación actual: 1 = Estable, 2 = Interruptor, 3 = Falla
var fase_actual : int = 1

# Variable para rastrear si el fusible operó y se abrió físicamente
var fusible_quemado : bool = false

# Variable para evitar que la explosión suene repetidas veces en bucle
var explosion_reproducida : bool = false

# Variable para animar el movimiento de los electrones y chispas
var desfase_animacion : float = 0.0

# Referencias visuales
@onready var bateria_visual: Sprite2D = $Batería
@onready var foco_visual: Sprite2D = $Foco
@onready var interruptor_visual: Sprite2D = $Interruptor
@onready var texto_amperios: Label = $TextoAmperios
@onready var circuito_dibuja: Node2D = $CircuitoDibuja

# REFERENCIAS DE AUDIO (Coincidentes con tus nodos en mayúsculas)
@onready var audio_clic: AudioStreamPlayer2D = $SONBOTON
@onready var audio_explosion: AudioStreamPlayer2D = $SONALERTA

# Etiquetas de datos locales
var label_bateria : Label
var label_foco : Label
var label_interruptor : Label

func _ready() -> void:
	# 1. ALINEACIÓN Y ESCALA AUTOMÁTICA DE LOS COMPLEMENTOS
	var altura_diagrama = 360.0
	bateria_visual.scale = Vector2(0.5, 0.5)
	interruptor_visual.scale = Vector2(0.5, 0.5)
	foco_visual.scale = Vector2(0.5, 0.5)
	
	bateria_visual.position = Vector2(250, altura_diagrama)
	interruptor_visual.position = Vector2(576, altura_diagrama) 
	foco_visual.position = Vector2(902, altura_diagrama)
	
	# 2. INICIALIZACIÓN DE LAS ETIQUETAS DE TEXTO
	label_bateria = Label.new()
	label_foco = Label.new()
	label_interruptor = Label.new()
	
	add_child(label_bateria)
	add_child(label_foco)
	add_child(label_interruptor)
	
	label_bateria.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_foco.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_interruptor.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	label_bateria.add_theme_font_size_override("font_size", 16)
	label_foco.add_theme_font_size_override("font_size", 16)
	label_interruptor.add_theme_font_size_override("font_size", 16)
	
	# Centrado absoluto del panel de instrucciones superior
	var ancho_total_pantalla = get_viewport().get_visible_rect().size.x
	texto_amperios.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto_amperios.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto_amperios.custom_minimum_size = Vector2(ancho_total_pantalla, 100)
	texto_amperios.global_position = Vector2(0, 40)
	
	cambiar_fase(1)
	$MUSICAFONDO.play() 

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1 or event.keycode == KEY_KP_1:
			audio_clic.play() 
			cambiar_fase(1)
		elif event.keycode == KEY_2 or event.keycode == KEY_KP_2:
			audio_clic.play()
			cambiar_fase(2)
		elif event.keycode == KEY_3 or event.keycode == KEY_KP_3:
			audio_clic.play()
			cambiar_fase(3)
			
	if fase_actual == 2:
		if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
			audio_clic.play() 
			conmutar_interruptor()
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var distancia = event.position.distance_to(interruptor_visual.global_position)
			if distancia < 60.0: 
				audio_clic.play() 
				conmutar_interruptor()
	
		# CONTROLES INTERACTIVOS DEL MODO 3 (CORREGIDO CON AUDIO DE ALERTA FORZADO)
	if fase_actual == 3:
		# Incrementar Voltaje con la Flecha Arriba para provocar la falla
		if event is InputEventKey and event.pressed and event.keycode == KEY_UP:
			if resistencia_foco > 0.5 and not fusible_quemado: 
				voltaje_bateria += 4.0
				audio_clic.play() 
				
				if voltaje_bateria >= 36.0: 
					resistencia_foco = 0.1 
					# SOLUCIÓN: Dispara el sonido de alerta/explosión en el instante exacto del impacto
					if not explosion_reproducida:
						audio_explosion.play()
						explosion_reproducida = true
						
				actualizar_fisica()
				
		# Reparar circuito con la tecla C tras la falla
		if event is InputEventKey and event.pressed and event.keycode == KEY_C:
			if resistencia_foco == 0.1 and not fusible_quemado:
				audio_clic.play() 
				fusible_quemado = true
				voltaje_bateria = 0.0 
				actualizar_fisica()


func conmutar_interruptor() -> void:
	if resistencia_foco == 999.0:
		resistencia_foco = 6.0
	else:
		resistencia_foco = 999.0
	actualizar_fisica()

func cambiar_fase(nueva_fase: int) -> void:
	fase_actual = nueva_fase
	voltaje_bateria = 12.0
	resistencia_foco = 6.0
	fusible_quemado = false 
	explosion_reproducida = false 
	
	bateria_visual.modulate = Color(1, 1, 1)
	foco_visual.modulate = Color(1, 1, 1)
	interruptor_visual.modulate = Color(1, 1, 1)
	
	if fase_actual == 2:
		resistencia_foco = 999.0 
		
	actualizar_fisica()

func _process(delta: float) -> void:
	var corriente = 0.0
	if resistencia_foco > 0.0:
		corriente = voltaje_bateria / resistencia_foco
	
	if corriente > 0.0 and not fusible_quemado:
		var velocidad = 20.0 if fase_actual == 3 and resistencia_foco == 0.1 else 5.0
		desfase_animacion += velocidad * delta
	else:
		desfase_animacion += 5.0 * delta
		
	# Redibuja el nodo hijo que está al frente de la pantalla
	circuito_dibuja.queue_redraw() 
	
	if fase_actual == 3 and resistencia_foco == 0.1 and not fusible_quemado:
		bateria_visual.position.x = 250.0 + randf_range(-3.0, 3.0)
		bateria_visual.position.y = 360.0 + randf_range(-3.0, 3.0)
	else:
		bateria_visual.position = Vector2(250.0, 360.0)
		
	label_bateria.global_position = bateria_visual.position + Vector2(-60, 65)
	label_interruptor.global_position = interruptor_visual.position + Vector2(-60, 65)
	label_foco.global_position = foco_visual.position + Vector2(-60, 65)

func actualizar_fisica() -> void:
	var corriente = 0.0
	if resistencia_foco > 0.0:
		corriente = voltaje_bateria / resistencia_foco
	
	label_bateria.text = "Voltaje: " + str(voltaje_bateria) + " V"
	
	if fusible_quemado:
		label_foco.text = "¡SISTEMA SALVADO!"
		label_interruptor.text = "Estado: ABIERTO (FUSIBLE)"
	elif resistencia_foco > 500.0:
		label_foco.text = "Resistencia: ∞ (Infinita)"
		label_interruptor.text = "Estado: ABIERTO"
	elif resistencia_foco == 0.1:
		label_foco.text = "¡FOCO DESTRUIDO!"
		label_interruptor.text = "Estado: CERRADO"
	else:
		label_foco.text = "Resistencia: " + str(resistencia_foco) + " Ohm"
		label_interruptor.text = "Estado: CERRADO"
	
	var guia_modos = "\n[Presiona 1, 2 o 3 para conmutar los Modos de Simulación en cualquier momento]"
	
	if fase_actual == 1:
		texto_amperios.text = "MODO 1: Régimen Permanente Lineal (Ley de Ohm)\nIntensidad de Corriente Estable: " + str(corriente) + " A" + guia_modos
		bateria_visual.modulate = Color(1, 1, 1) 
		foco_visual.modulate = Color(1, 1, 1)
		interruptor_visual.modulate = Color(1, 1, 1)
		
	elif fase_actual == 2:
		if resistencia_foco > 500.0:
			texto_amperios.text = "MODO 2: Análisis de Maniobra de Interrupción\nCircuito Abierto | Corriente: 0.0 A\n-> Haz CLIC en el Interruptor o presiona ESPACIO para cerrarlo." + guia_modos
			bateria_visual.modulate = Color(0.3, 0.3, 0.3) 
			foco_visual.modulate = Color(0.3, 0.3, 0.3)    
			interruptor_visual.modulate = Color(0.0, 0.7, 1.0) 
		else:
			texto_amperios.text = "MODO 2: Análisis de Maniobra de Interrupción\nCircuito Cerrado | Corriente: " + str(corriente) + " A\n-> Haz CLIC en el Interruptor o presiona ESPACIO para abrirlo." + guia_modos
			bateria_visual.modulate = Color(1, 1, 1) 
			foco_visual.modulate = Color(1, 1, 1)
			interruptor_visual.modulate = Color(1, 1, 1) 
			
	elif fase_actual == 3:
		if not fusible_quemado:
			if resistencia_foco == 6.0:
				texto_amperios.text = "MODO 3: Estado de Falla Crítica (Sobrecarga de Línea)\nSistema Estable a " + str(corriente) + " A. \n-> ¡Presiona la FLECHA ARRIBA para inyectar sobrevoltaje y forzar la ruptura!" + guia_modos
				bateria_visual.modulate = Color(1, 1, 1) 
				foco_visual.modulate = Color(1, 1, 1)
				interruptor_visual.modulate = Color(1, 1, 1)
			else:
				texto_amperios.text = "MODO 3: ¡EXPLOSIÓN POR SOBRETENSIÓN! Cortocircuito Desatado\n¡PELIGRO! Corriente a " + str(corriente) + " A. El filamento se fundió violentamente.\n-> Presiona la tecla C para fundir el Fusible y proteger la línea." + guia_modos
				bateria_visual.modulate = Color(1, 0, 0) 
				foco_visual.modulate = Color(0.15, 0.15, 0.15) 
				interruptor_visual.modulate = Color(0.2, 0.2, 0.2)
				
				if not explosion_reproducida:
					audio_explosion.play()
					explosion_reproducida = true
		else:
			texto_amperios.text = "MODO 3: Estado de Falla Crítica (Sistema Mitigado)\nCorriente Estabilizada: 0.0 A\n¡El fusible se fundió con éxito abriendo la línea y salvando la instalación!" + guia_modos
			bateria_visual.modulate = Color(1, 1, 1) 
			foco_visual.modulate = Color(0.15, 0.15, 0.15) 
			interruptor_visual.modulate = Color(0.3, 0.3, 0.3)
