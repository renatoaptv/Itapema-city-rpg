extends Node3D
## ITAPEMA CITY RPG — prototipo 3D mobile.
## Mundo ficticio inspirado na orla de Meia Praia. Nao representa enderecos reais.

const SKY := Color("#85cbef")
const DARK := Color("#132336")
const GOLD := Color("#f6c44d")
const GLASS := Color("#74b2c8")

var player: Node3D
var camera: Camera3D
var leg_l: MeshInstance3D
var leg_r: MeshInstance3D
var hud: Control
var joystick_dot: Panel
var xp_label: Label
var location_label: Label
var pop: Panel
var pop_title: Label
var pop_body: VBoxContainer
var chat_input: LineEdit
var chat_messages: Array[String] = []
var xp := 0
var traveled := 0.0
var yaw := 0.0
var joystick := Vector2.ZERO
var joy_pointer := -1
var camera_pointer := -1
var camera_touch := Vector2.ZERO
var mouse_joy := false
var sprint := false
var walking_time := 0.0
var demo_building_z := -42.0

func _ready() -> void:
	DisplayServer.window_set_title("ITAPEMA CITY RPG - prototipo")
	_make_world()
	_make_player()
	_make_interface()
	_update_hud()

func _material(color: Color, metallic: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.metallic = metallic
	m.roughness = 0.26 if metallic > 0.0 else 0.78
	return m

func _box(pos: Vector3, size: Vector3, color: Color, metallic: float = 0.0, parent: Node3D = null) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.material_override = _material(color, metallic)
	if parent == null:
		add_child(mesh)
	else:
		parent.add_child(mesh)
	mesh.position = pos
	return mesh

func _ball(pos: Vector3, r: float, color: Color, parent: Node3D = null) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = r
	sphere.height = r * 2.0
	mi.mesh = sphere
	mi.material_override = _material(color)
	if parent == null:
		add_child(mi)
	else:
		parent.add_child(mi)
	mi.position = pos
	return mi

func _trunk(pos: Vector3, radius: float, height: float, color: Color) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius * 0.65
	cyl.bottom_radius = radius
	cyl.height = height
	mesh.mesh = cyl
	mesh.material_override = _material(color)
	add_child(mesh)
	mesh.position = pos
	return mesh

func _make_world() -> void:
	var env_node := WorldEnvironment.new()
	add_child(env_node)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#d3e5f4")
	env.ambient_light_energy = 0.95
	env_node.environment = env
	var sun := DirectionalLight3D.new()
	add_child(sun)
	sun.rotation_degrees = Vector3(-53, -33, 0)
	sun.light_energy = 1.35
	sun.light_color = Color("#fff2dc")
	sun.shadow_enabled = false

	# Calçada, ciclovia, avenida, faixa de areia e mar.
	_box(Vector3(0, -0.35, -135), Vector3(220, 0.6, 380), Color("#9cb99a"))
	_box(Vector3(-5, -0.09, -135), Vector3(12, 0.2, 380), Color("#d7cec0"))
	_box(Vector3(3, -0.085, -135), Vector3(3.8, 0.2, 380), Color("#bd4b52"))
	_box(Vector3(13, -0.12, -135), Vector3(16, 0.2, 380), Color("#494e53"))
	_box(Vector3(22.5, -0.08, -135), Vector3(3.2, 0.2, 380), Color("#d8cfc1"))
	_box(Vector3(39, -0.16, -135), Vector3(30, 0.2, 380), Color("#efdbad"))
	_box(Vector3(98, -0.23, -135), Vector3(88, 0.2, 380), Color("#32a5c1"), 0.15)
	# Bordas e marcações de pista.
	for i in range(30):
		var z := 26.0 - float(i) * 12.0
		_box(Vector3(13.0, 0.015, z), Vector3(0.15, 0.03, 5), Color("#f3ebd3"))
		_box(Vector3(3.15, 0.025, z), Vector3(0.1, 0.025, 5), Color("#f4c3ba"))
		_box(Vector3(4.85, 0.025, z), Vector3(0.1, 0.025, 5), Color("#f4c3ba"))
		if i % 3 == 0:
			for stripe in range(6):
				_box(Vector3(6.3 + stripe * 2.2, 0.025, z - 4), Vector3(1.35, 0.03, 1.9), Color("#faf9f0"))
	# Torres individualizadas de exemplo com sacadas e vitrines.
	for i in range(9):
		_make_building(i, -11.0 - float(i % 2) * 1.1, 11.0 - float(i) * 31.0)
	# Paisagismo e guarda-corpos.
	for i in range(19):
		var z := 15.0 - float(i) * 16.0
		_make_palm(25.0, z, 6.4 + float(i % 3))
		if i % 2 == 0:
			_make_palm(-9.5, z - 7.0, 4.8)
		_box(Vector3(26.1, 0.48, z), Vector3(0.12, 1, 0.15), Color("#897b69"))
		_box(Vector3(26.1, 0.93, z - 8.0), Vector3(0.10, 0.12, 16.0), Color("#96816b"))
	# Marcador 3D na rua (nao e anuncio real).
	var marker := Label3D.new()
	marker.text = "LANCAMENTO\nDEMONSTRATIVO"
	marker.position = Vector3(-8.7, 5.7, demo_building_z)
	marker.font_size = 64
	marker.pixel_size = 0.012
	marker.modulate = GOLD
	marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(marker)

func _make_building(i: int, frontage_x: float, z: float) -> void:
	var levels := 8 + (i % 5)
	var height := float(levels) * 3.1 + 4.0
	var facade := Color("#e9ded2") if i % 3 == 0 else (Color("#d2d6d4") if i % 3 == 1 else Color("#e4e7e5"))
	_box(Vector3(frontage_x - 10.0, height / 2.0, z), Vector3(19.6, height, 22), facade)
	_box(Vector3(frontage_x + 0.1, 2.0, z), Vector3(0.3, 4, 20.6), Color("#343b47"), 0.25)
	_box(Vector3(frontage_x + 0.3, 2.1, z), Vector3(0.18, 3.25, 15), GLASS, 0.42)
	for level in range(levels):
		var y := 5.25 + float(level) * 3.1
		for j in range(3):
			var wz := z - 7.2 + float(j) * 7.2
			_box(Vector3(frontage_x + 0.19, y, wz), Vector3(0.21, 2.35, 4.45), GLASS, 0.4)
			_box(Vector3(frontage_x + 0.85, y - 1.32, wz), Vector3(1.6, 0.22, 5.4), Color("#d8d5d1"))
			_box(Vector3(frontage_x + 1.58, y - 0.72, wz), Vector3(0.11, 1.0, 5.4), Color("#b7e1e6", 0.77), 0.55)
		_box(Vector3(frontage_x + 0.08, y - 1.52, z), Vector3(0.2, 0.22, 21.3), Color("#f8efe4"))
	# Letreiro sem associar edificio ficticio a condominio real.
	if i < 4:
		var label := Label3D.new()
		label.text = ["RESIDENCIAL", "IMOVEIS", "CAFE DA PRAIA", "EDIFICIO MODELO"][i]
		label.font_size = 62
		label.pixel_size = 0.008
		label.position = Vector3(frontage_x + 0.47, 3.5, z)
		label.rotation_degrees = Vector3(0, 90, 0)
		label.modulate = Color("#fff0cd")
		add_child(label)

func _make_palm(x: float, z: float, height: float) -> void:
	_trunk(Vector3(x, height / 2.0, z), 0.27, height, Color("#907250"))
	_ball(Vector3(x, height + 0.3, z), 0.55, Color("#376d3f"))
	for a in range(8):
		var angle := float(a) * TAU / 8.0
		var leaf := _box(Vector3(x + sin(angle) * 1.65, height + 0.2, z + cos(angle) * 1.65), Vector3(0.65, 0.16, 4.1), Color("#347946"))
		leaf.rotation.y = angle
		leaf.rotation.x = -0.22

func _make_player() -> void:
	player = Node3D.new()
	player.position = Vector3(-4, 0.32, 14)
	add_child(player)
	_box(Vector3(0, 1.32, 0), Vector3(0.83, 1.05, 0.39), Color("#15242a"), 0.15, player)
	_ball(Vector3(0, 2.12, 0), 0.34, Color("#c58c63"), player)
	_box(Vector3(0, 2.35, 0), Vector3(0.67, 0.16, 0.65), Color("#202326"), 0, player)
	_box(Vector3(0, 1.3, 0.25), Vector3(0.45, 0.32, 0.11), GOLD, 0.1, player)
	for side in [-1.0, 1.0]:
		_box(Vector3(side * 0.56, 1.24, 0), Vector3(0.3, 0.91, 0.36), Color("#b98764"), 0, player)
	leg_l = _box(Vector3(-0.21, 0.43, 0), Vector3(0.34, 0.83, 0.38), Color("#ceb9a2"), 0, player)
	leg_r = _box(Vector3(0.21, 0.43, 0), Vector3(0.34, 0.83, 0.38), Color("#ceb9a2"), 0, player)
	camera = Camera3D.new()
	camera.current = true
	camera.fov = 76
	add_child(camera)
	camera.position = player.position + Vector3(0, 4.1, 7.8)
	camera.look_at(player.position + Vector3(0, 1.5, -4.0), Vector3.UP)

func _style(background: Color, border: Color = Color("#ffffff46"), radius: int = 16) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.set_content_margin_all(8)
	return style

func _label(parent: Node, text_value: String, pos: Vector2, sz: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = pos
	label.size = sz
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _button(parent: Node, caption: String, pos: Vector2, sz: Vector2, action: String) -> Button:
	var button := Button.new()
	button.text = caption
	button.position = pos
	button.size = sz
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _style(Color("#142331df")))
	button.add_theme_stylebox_override("hover", _style(Color("#294259")))
	button.add_theme_stylebox_override("pressed", _style(Color("#34566f")))
	parent.add_child(button)
	if action != "":
		button.pressed.connect(_open_menu.bind(action))
	return button

func _make_interface() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Control.new()
	hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hud)
	var header := Panel.new()
	header.position = Vector2(15, 16)
	header.size = Vector2(270, 87)
	header.add_theme_stylebox_override("panel", _style(Color("#112334e8")))
	hud.add_child(header)
	_label(header, "ITAPEMA CITY RPG", Vector2(18, 9), Vector2(220, 29), 23, GOLD)
	_label(header, "Visitante  |  Corretor / Morador", Vector2(18, 40), Vector2(244, 22), 15, Color.WHITE)
	xp_label = _label(header, "NIVEL 1  -  0 XP", Vector2(18, 62), Vector2(225, 19), 14, Color("#b9aeff"))
	var loc := Panel.new()
	loc.position = Vector2(442, 17)
	loc.size = Vector2(365, 46)
	loc.add_theme_stylebox_override("panel", _style(Color("#122c44dc"), GOLD, 20))
	hud.add_child(loc)
	location_label = _label(loc, "ITAPEMA / SC  -  MEIA PRAIA", Vector2(17, 8), Vector2(340, 26), 19, Color.WHITE)
	_label(hud, "125.000 MOEDAS  |  2.540 GEMAS", Vector2(895, 25), Vector2(368, 32), 17, Color.WHITE)
	for i in range(5):
		var names := ["Imoveis", "Corretores", "Missoes", "Eventos", "Loja"]
		_button(hud, names[i], Vector2(15, 128 + i * 57), Vector2(155, 48), names[i])
	_label(hud, "CIDADE DEMONSTRATIVA • 3a PESSOA", Vector2(480, 77), Vector2(365, 24), 14, Color("#ffffffdd"))
	_label(hud, "ARASTE A TELA PARA OLHAR", Vector2(949, 527), Vector2(290, 20), 14, Color.WHITE)
	var joy_base := Panel.new()
	joy_base.position = Vector2(42, 527)
	joy_base.size = Vector2(172, 172)
	joy_base.add_theme_stylebox_override("panel", _style(Color("#182d426a"), Color("#d4f1ee88"), 90))
	joy_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(joy_base)
	joystick_dot = Panel.new()
	joystick_dot.position = Vector2(55, 55)
	joystick_dot.size = Vector2(62, 62)
	joystick_dot.add_theme_stylebox_override("panel", _style(Color("#76d8ce"), Color("#e4fffd"), 48))
	joystick_dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	joy_base.add_child(joystick_dot)
	_label(hud, "ANDAR", Vector2(88, 695), Vector2(100, 24), 15, Color.WHITE)
	var chat := _button(hud, "CHAT LOCAL  •  DEMO", Vector2(300, 636), Vector2(390, 52), "Chat")
	chat.add_theme_color_override("font_color", GOLD)
	var run := _button(hud, "CORRER", Vector2(1041, 611), Vector2(107, 72), "")
	run.button_down.connect(func(): sprint = true)
	run.button_up.connect(func(): sprint = false)
	_button(hud, "INTERAGIR", Vector2(1155, 591), Vector2(115, 96), "Imoveis")
	# Modal demonstrativo.
	pop = Panel.new()
	pop.position = Vector2(353, 131)
	pop.size = Vector2(575, 440)
	pop.add_theme_stylebox_override("panel", _style(Color("#111c2cf5"), GOLD, 20))
	pop.visible = false
	hud.add_child(pop)
	pop_title = _label(pop, "ITAPEMA CITY", Vector2(24, 16), Vector2(480, 34), 28, GOLD)
	var close := _button(pop, "X", Vector2(516, 13), Vector2(43, 43), "")
	close.pressed.connect(func(): pop.hide())
	var margin := ScrollContainer.new()
	margin.position = Vector2(23, 74)
	margin.size = Vector2(527, 337)
	pop.add_child(margin)
	pop_body = VBoxContainer.new()
	pop_body.custom_minimum_size = Vector2(505, 0)
	margin.add_child(pop_body)

func _update_hud() -> void:
	if xp_label:
		xp_label.text = "NIVEL %d  •  %d XP" % [1 + int(xp / 100), xp]

func _explanation(name: String) -> String:
	match name:
		"Imoveis":
			return "EMPREENDIMENTOS DE DEMONSTRACAO\n\nOs predios sao modelos ficticios. Mais adiante vamos cadastrar edificios reais, seus enderecos e os corretores responsaveis."
		"Corretores":
			return "REDE DE CORRETORES\n\nAqui cada corretor tera perfil, cadastro verificado e canal de contato. Ainda nao existem usuarios reais conectados."
		"Missoes":
			return "MISSAO 01 — PASSEIO PELA ORLA\n\nAnde 60 metros para ganhar 100 XP.\nProgresso: %d / 60 metros." % mini(60, int(traveled))
		"Eventos":
			return "EVENTOS IMOBILIARIOS\n\nEspaco reservado para lancamentos, visitas, encontros e eventos cadastrados."
		"Loja":
			return "LOJA DO JOGO\n\nNo futuro: roupas, itens cosmeticos e personalizacao do personagem. Nao existem compras reais."
		"Chat":
			return "CHAT LOCAL DEMONSTRATIVO\n\nAs mensagens so aparecem neste aparelho. Nao ha outros jogadores reais online.\n\n" + "\n".join(chat_messages.slice(-7))
	return ""

func _open_menu(name: String) -> void:
	pop.show()
	pop_title.text = name.to_upper()
	for child in pop_body.get_children():
		child.queue_free()
	var body := Label.new()
	body.text = _explanation(name)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD
	body.custom_minimum_size = Vector2(487, 190)
	body.add_theme_font_size_override("font_size", 19)
	body.add_theme_color_override("font_color", Color("#eef5fa"))
	pop_body.add_child(body)
	if name == "Chat":
		chat_input = LineEdit.new()
		chat_input.placeholder_text = "Digite uma mensagem..."
		chat_input.custom_minimum_size = Vector2(485, 44)
		pop_body.add_child(chat_input)
		chat_input.text_submitted.connect(func(_t): _send_chat())
		var send := Button.new()
		send.text = "ENVIAR MENSAGEM"
		send.custom_minimum_size = Vector2(485, 42)
		pop_body.add_child(send)
		send.pressed.connect(_send_chat)
	else:
		var close := Button.new()
		close.text = "VOLTAR A CIDADE"
		close.custom_minimum_size = Vector2(485, 46)
		pop_body.add_child(close)
		close.pressed.connect(func(): pop.hide())

func _send_chat() -> void:
	if chat_input == null:
		return
	var message := chat_input.text.strip_edges()
	if message == "":
		return
	chat_messages.append("Voce: " + message.left(150))
	chat_input.clear()
	_open_menu("Chat")

func _move_joystick(point: Vector2) -> void:
	var offset := (point - Vector2(128, 613)) / 68.0
	joystick = offset.limit_length(1.0)
	if joystick_dot:
		joystick_dot.position = Vector2(55, 55) + joystick * 49.0

func _reset_joystick() -> void:
	joystick = Vector2.ZERO
	if joystick_dot:
		joystick_dot.position = Vector2(55, 55)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < 270 and event.position.y > 490:
				joy_pointer = event.index
				_move_joystick(event.position)
			elif event.position.x > 365 and event.position.y > 105:
				camera_pointer = event.index
				camera_touch = event.position
		else:
			if joy_pointer == event.index:
				joy_pointer = -1
				_reset_joystick()
			if camera_pointer == event.index:
				camera_pointer = -1
	elif event is InputEventScreenDrag:
		if event.index == joy_pointer:
			_move_joystick(event.position)
		elif event.index == camera_pointer and not pop.visible:
			yaw = clampf(yaw - event.relative.x * 0.005, -1.0, 1.0)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and event.position.x < 270 and event.position.y > 490:
				mouse_joy = true
				_move_joystick(event.position)
			elif not event.pressed:
				mouse_joy = false
				_reset_joystick()
	elif event is InputEventMouseMotion:
		if mouse_joy:
			_move_joystick(event.position)
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and not pop.visible:
			yaw = clampf(yaw - event.relative.x * 0.005, -1.0, 1.0)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			pop.hide()
		if event.keycode == KEY_E and not pop.visible:
			_open_menu("Imoveis")

func _physics_process(delta: float) -> void:
	var axis := joystick
	var focus := get_viewport().gui_get_focus_owner()
	if not (focus is LineEdit):
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
			axis.x -= 1.0
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
			axis.x += 1.0
		if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
			axis.y -= 1.0
		if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
			axis.y += 1.0
	axis = axis.limit_length(1.0)
	var forward := Vector3(-sin(yaw), 0, -cos(yaw))
	var right := Vector3(cos(yaw), 0, -sin(yaw))
	var displacement: Vector3 = (right * axis.x - forward * axis.y) * (9.4 if sprint or Input.is_key_pressed(KEY_SHIFT) else 5.3) * delta
	if pop.visible:
		displacement = Vector3.ZERO
	var before := player.position
	player.position += displacement
	player.position.x = clampf(player.position.x, -8.3, 23.0)
	player.position.z = clampf(player.position.z, -310.0, 22.0)
	traveled += before.distance_to(player.position)
	if traveled >= 60.0 and xp < 100:
		xp += 100
		_update_hud()
		_open_menu("Missoes")
	player.rotation.y = yaw
	if displacement.length() > 0.005:
		walking_time += delta * (14 if sprint else 9)
		leg_l.rotation.x = sin(walking_time) * 0.36
		leg_r.rotation.x = -sin(walking_time) * 0.36
	else:
		leg_l.rotation.x = lerpf(leg_l.rotation.x, 0, delta * 8)
		leg_r.rotation.x = lerpf(leg_r.rotation.x, 0, delta * 8)
	var behind := Vector3(sin(yaw) * 7.0, 4.6, cos(yaw) * 7.0)
	camera.position = camera.position.lerp(player.position + behind, minf(1.0, delta * 7.0))
	camera.look_at(player.position + Vector3(-sin(yaw) * 3.3, 1.7, -cos(yaw) * 3.3), Vector3.UP)
