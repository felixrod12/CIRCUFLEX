extends Node2D

@onready var principal = get_parent()

func _draw() -> void:
	var altura_cable_superior = 360.0
	var p_bateria_salida = Vector2(325, altura_cable_superior)   
	var p_interruptor_izq = Vector2(495, altura_cable_superior)  
	var p_interruptor_der = Vector2(656, altura_cable_superior)  
	var p_foco_entrada = Vector2(835, altura_cable_superior)     
	
	var p_bateria_abajo = Vector2(250, 395)                      
	var p_foco_abajo = Vector2(902, 420)                         
	var altura_retorno_y = 500.0                                 

	var color_cable = Color(0.3, 0.3, 0.3) 
	var corriente = 0.0
	if principal.resistencia_foco > 0.0:
		corriente = principal.voltaje_bateria / principal.resistencia_foco
	
	if principal.fusible_quemado:
		color_cable = Color(0.3, 0.3, 0.3) 
	elif corriente > 25.0 and principal.resistencia_foco == 0.1:
		color_cable = Color(1, 0.2, 0) 
	elif corriente > 0.0 and principal.resistencia_foco < 500.0:
		color_cable = Color(1, 0.8, 0.2) 

	var p_fusible_centro = Vector2(410, altura_cable_superior) 
	var p_fusible_izq = p_fusible_centro - Vector2(20, 0)
	var p_fusible_der = p_fusible_centro + Vector2(20, 0)

	draw_line(p_bateria_salida, p_fusible_izq, color_cable, 6.0)

	if principal.fusible_quemado:
		draw_rect(Rect2(p_fusible_centro - Vector2(20, 12), Vector2(40, 24)), Color(0.15, 0.15, 0.15), true)
		draw_rect(Rect2(p_fusible_centro - Vector2(20, 12), Vector2(40, 24)), Color(1, 1, 1), false, 2.5)
		var p_ruptura_levantada = p_interruptor_izq - Vector2(20, 30)
		draw_line(p_fusible_der, p_ruptura_levantada, color_cable, 6.0)
	else:
		draw_line(p_fusible_der, p_interruptor_izq, color_cable, 6.0)
		var color_fusible = Color(0.0, 0.9, 0.2) 
		if principal.fase_actual == 3 and principal.resistencia_foco == 0.1:
			color_fusible = Color(1, 0, 0) if Engine.get_frames_drawn() % 10 < 5 else Color(1, 0.8, 0)
		draw_rect(Rect2(p_fusible_centro - Vector2(20, 12), Vector2(40, 24)), color_fusible, true)
		draw_rect(Rect2(p_fusible_centro - Vector2(20, 12), Vector2(40, 24)), Color(1, 1, 1), false, 2.5)

	if principal.resistencia_foco > 500.0 and principal.fase_actual == 2:
		var p_puente_levantado = Vector2(p_foco_entrada.x - 30, altura_cable_superior - 40)
		draw_line(p_interruptor_der, p_puente_levantado, color_cable, 6.0)
		draw_circle(p_interruptor_der, 5.0, color_cable)
		draw_circle(p_foco_entrada, 5.0, color_cable)
	else:
		draw_line(p_interruptor_der, p_foco_entrada, color_cable, 6.0)
	
	var esquina_izq = Vector2(p_bateria_abajo.x, altura_retorno_y)
	var esquina_der = Vector2(p_foco_abajo.x, altura_retorno_y)
	draw_line(p_bateria_abajo, esquina_izq, color_cable, 6.0) 
	draw_line(esquina_izq, esquina_der, color_cable, 6.0)     
	draw_line(esquina_der, p_foco_abajo, color_cable, 6.0)     

	# ANIMACIÓN DE LOS ELECTRONES
	if corriente > 0.0 and principal.resistencia_foco < 500.0 and not principal.fusible_quemado:
		var cantidad_puntos = 8 
		for i in range(cantidad_puntos):
			var t = fmod((float(i) / cantidad_puntos) + principal.desfase_animacion * 0.2, 1.0)
			var pos1 = p_bateria_salida.lerp(p_fusible_izq, t)
			draw_circle(pos1, 4.0, Color(1, 1, 1))
			var pos2 = p_interruptor_der.lerp(p_foco_entrada, t)
			draw_circle(pos2, 4.0, Color(1, 1, 1))
			var pos3 = esquina_der.lerp(esquina_izq, t)
			draw_circle(pos3, 4.0, Color(1, 1, 1))

	# EFECTO DE EXPLOSIÓN Y CHISPAS
	if principal.fase_actual == 3 and principal.resistencia_foco == 0.1 and not principal.fusible_quemado:
		var centro_foco = principal.foco_visual.position
		var num_chispas = 12
		for i in range(num_chispas):
			var angulo = (float(i) / num_chispas) * TAU + randf_range(-0.2, 0.2)
			var longitud_chispa = fmod(principal.desfase_animacion * 15.0 + (i * 20), 70.0)
			var desp_chispa = Vector2(cos(angulo), sin(angulo)) * longitud_chispa
			var col_chispa = Color(1.0, 0.4, 0.0) if i % 2 == 0 else Color(1.0, 0.9, 0.1)
			draw_circle(centro_foco + desp_chispa, randf_range(2.0, 5.0), col_chispa)
			if i % 3 == 0:
				draw_line(centro_foco, centro_foco + Vector2(cos(angulo), sin(angulo)) * 45.0, Color(1, 1, 1, 0.4), 2.0)
