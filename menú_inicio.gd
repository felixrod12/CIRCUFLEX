extends Control 

# Referencias exactas a tus dos nodos de la escena
@onready var titulo_menu: Label = $Label
@onready var boton_jugar: Button = $Button
@onready var sonido_boton_menu = $SonidoBotonMenu

func _ready() -> void:
	# 1. CONFIGURACIÓN Y CENTRADO DEL TÍTULO
	titulo_menu.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo_menu.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	titulo_menu.custom_minimum_size = Vector2(1000, 150)
	titulo_menu.add_theme_font_size_override("font_size", 48)
	
	# Cálculo para centrar el título horizontalmente
	var ancho_pantalla = get_viewport().get_visible_rect().size.x
	titulo_menu.global_position = Vector2((ancho_pantalla - 1000) / 2, 120)
	
	# 2. CONFIGURACIÓN Y CENTRADO DEL BOTÓN ¡JUGAR!
	# Le damos un tamaño más grande y cómodo para hacer clic (ancho 300, alto 80)
	boton_jugar.custom_minimum_size = Vector2(300, 80)
	boton_jugar.add_theme_font_size_override("font_size", 28)
	
	# Lo centramos matemáticamente justo debajo del título
	boton_jugar.global_position = Vector2((ancho_pantalla - 300) / 2, 380)


func _on_button_pressed() -> void:
	# 1. Reproduce el efecto de sonido del clic de inmediato
	$SonidoBotonMenu.play()

	
	# 2. Le ordena a Godot esperar 0.15 segundos para que el oído humano escuche el sonido
	await get_tree().create_timer(0.15).timeout
	
	# 3. Una vez escuchado el clic, cambia limpiamente al laboratorio
	get_tree().change_scene_to_file("res://mundo.tscn")
