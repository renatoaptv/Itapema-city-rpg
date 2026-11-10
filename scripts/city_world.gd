extends Node3D
## Cenario de orla estilizado, sem representar edificacoes especificas.
## Conceito: primeira quadra de Meia Praia (predios / passeio / ciclovia / areia / mar).
## Gerado proceduralmente para facilitar edicao no Godot 4 e futura troca por modelos GLB reais.

const SKY = Color("#82c8eb")
const SEA = Color("#29a0be")
const STONE = Color("#cfc9be")
const WOOD = Color("#826e55")
const LEAF = Color("#3b8250")
const GLASS = Color("#81bbcb")
var seed_color := 0

func _ready() -> void:
	_build_sky_and_sun()
	_build_ground()
	_build_towers()
	_build_promenade()
	_build_beach()
	_build_people()

func _mat(c: Color, metal: float = 0.0, rough: float = 0.74) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.metallic = metal
	m.roughness = rough
	return m

func _cube(p: Vector3, s: Vector3, c: Color, metal: float = 0.0) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = s
	n.mesh = mesh
	n.material_override = _mat(c, metal)
	n.position = p
	add_child(n)
	return n

func _round(p: Vector3, scale_value: Vector3, c: Color) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var sp := SphereMesh.new()
	sp.radius = 1.0
	sp.height = 2.0
	n.mesh = sp
	n.position = p
	n.scale = scale_value
	n.material_override = _mat(c)
	add_child(n)
	return n

func _batch(points: Array[Vector3], size: Vector3, color_value: Color, metallic_value: float = 0.0) -> void:
	if points.is_empty():
		return
	var batch := MultiMesh.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE
	batch.mesh = mesh
	batch.transform_format = MultiMesh.TRANSFORM_3D
	batch.instance_count = points.size()
	for i in range(points.size()):
		batch.set_instance_transform(i, Transform3D(Basis().scaled(size), points[i]))
	var n := MultiMeshInstance3D.new()
	n.multimesh = batch
	n.material_override = _mat(color_value, metallic_value, 0.32 if metallic_value > 0 else 0.8)
	add_child(n)

func _cylinder(p: Vector3, height: float, radius: float, c: Color) -> void:
	var n := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.height = height
	mesh.top_radius = radius * 0.78
	mesh.bottom_radius = radius
	n.mesh = mesh
	n.position = p
	n.material_override = _mat(c)
	add_child(n)

func _label(t: String, p: Vector3, fs: int, col: Color = Color.WHITE, rot: float = 90.0) -> void:
	var n := Label3D.new()
	n.text = t
	n.position = p
	n.font_size = fs
	n.pixel_size = 0.009
	n.rotation_degrees.y = rot
	n.modulate = col
	n.shaded = false
	add_child(n)

func _build_sky_and_sun() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#e7f1fa")
	env.ambient_light_energy = 1.05
	world_env.environment = env
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -26, 0)
	sun.light_energy = 1.55
	sun.light_color = Color("#fff1db")
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 65
	add_child(sun)
	# Morros em tonalidade atmosferica na linha do horizonte.
	_round(Vector3(63, 5, -264), Vector3(36, 12, 26), Color("#7c9c9d"))
	_round(Vector3(108, 3, -290), Vector3(53, 18, 29), Color("#67908e"))

func _build_ground() -> void:
	_cube(Vector3(25, -0.52, -135), Vector3(230, 0.9, 375), Color("#ddcfb2"))
	# Edificios acabam no calcadao. Nao ha avenida de carros entre predios e a areia aqui.
	_cube(Vector3(-1.5, -0.03, -136), Vector3(13.9, 0.21, 365), Color("#e9e3d9"))
	_cube(Vector3(7.5, -0.015, -136), Vector3(3.5, 0.25, 365), Color("#b95050"))
	_cube(Vector3(12.9, -0.05, -136), Vector3(7.3, 0.17, 365), Color("#d7c7ab"))
	_cube(Vector3(38, -0.20, -136), Vector3(44, 0.20, 365), Color("#efd9a8"))
	_cube(Vector3(108, -0.28, -136), Vector3(104, 0.2, 365), SEA, 0.13)
	# Faixas de espuma no mar.
	for j in range(3):
		_cube(Vector3(59 + j * 6.0, -0.153, -136), Vector3(0.28, 0.02, 360), Color("#b5e7ea"))
	# Piso: faixas e juntas das placas (pouco contraste, nao quadriculado).
	var grout: Array[Vector3] = []
	var borders: Array[Vector3] = []
	for i in range(80):
		var z := 25.0 - float(i) * 4.3
		grout.append(Vector3(-1.6, 0.079, z))
		borders.append(Vector3(4.65, 0.08, z))
	_batch(grout, Vector3(12.3, 0.011, 0.065), Color("#c6bdae"))
	_batch(borders, Vector3(0.06, 0.01, 3.8), Color("#c5bcb0"))
	# Piso ciclovia, marcações de sentido e faixas de segurança.
	var lane: Array[Vector3] = []
	var sidewalk: Array[Vector3] = []
	for i in range(34):
		var z := 22.0 - float(i) * 10.5
		lane.append(Vector3(7.5, 0.12, z))
		sidewalk.append(Vector3(6.0, 0.115, z))
	_batch(lane, Vector3(0.08, 0.018, 5.1), Color("#fae2d6"))
	_batch(sidewalk, Vector3(0.08, 0.018, 9.5), Color("#e7a4a1"))

func _build_towers() -> void:
	for i in range(10):
		_tower(i, Vector3(-20.4, 0.0, 9.0 - float(i) * 29.5))

func _tower(idx: int, at: Vector3) -> void:
	var floors := 10 + (idx * 7) % 10
	var height := float(floors) * 3.05 + 3.5
	var facade: Color = [Color("#dfdcd7"), Color("#ddd1bf"), Color("#e4e5e3"), Color("#c5d2d3")][idx % 4]
	var accent: Color = [Color("#faf7f0"), Color("#c1a794"), Color("#f0ece5")][idx % 3]
	var core_x := at.x
	var z := at.z
	_cube(Vector3(core_x, height / 2.0, z), Vector3(24.3, height, 23.9), facade)
	# Loja / hall envidracado em vez de grande bloco opaco.
	_cube(Vector3(-8.17, 1.65, z), Vector3(0.15, 3.08, 23.2), Color("#405961"), 0.3)
	var panes: Array[Vector3] = []
	var mullions: Array[Vector3] = []
	for bay in range(5):
		var zz := z - 9.0 + float(bay) * 4.5
		panes.append(Vector3(-8.02, 1.75, zz))
		mullions.append(Vector3(-7.88, 1.75, zz + 2.0))
	_batch(panes, Vector3(0.12, 2.65, 3.85), Color("#6da8b3"), 0.55)
	_batch(mullions, Vector3(0.13, 2.9, 0.12), Color("#eae8df"), 0.2)
	_cube(Vector3(-7.6, 3.35, z), Vector3(1.25, 0.32, 23.3), Color("#c9b5a1"))
	# Molduras, sacadas, guarda-corpos em 3 batches.
	var windows: Array[Vector3] = []
	var slabs: Array[Vector3] = []
	var rails: Array[Vector3] = []
	var rails_left: Array[Vector3] = []
	var planks: Array[Vector3] = []
	for floor_id in range(floors):
		var y := 5.0 + float(floor_id) * 3.05
		for bay in range(4):
			var zz := z - 8.6 + float(bay) * 5.55
			windows.append(Vector3(-8.1, y, zz))
			slabs.append(Vector3(-7.20, y - 1.5, zz))
			rails.append(Vector3(-6.58, y - 0.77, zz))
			rails_left.append(Vector3(-7.13, y - 0.76, zz - 2.6))
			rails_left.append(Vector3(-7.13, y - 0.76, zz + 2.6))
		planks.append(Vector3(-7.20, y - 1.56, z))
	_batch(windows, Vector3(0.14, 2.4, 4.25), Color("#6da9b9"), 0.43)
	_batch(slabs, Vector3(1.75, 0.25, 5.30), accent)
	_batch(rails, Vector3(0.11, 1.17, 5.15), Color("#a9d5dc"), 0.55)
	_batch(rails_left, Vector3(1.21, 1.17, 0.11), Color("#a8cbd0"), 0.55)
	_batch(planks, Vector3(1.72, 0.075, 23.3), Color("#f0e7da"))
	# Coroamento e ritmos verticais da fachada.
	_cube(Vector3(-8.6, height + 0.25, z), Vector3(2.5, 0.55, 24.1), accent)
	var fins: Array[Vector3] = []
	for bay in range(5):
		fins.append(Vector3(-8.02, height / 2.0 + 1.5, z - 11.5 + float(bay) * 5.7))
	_batch(fins, Vector3(0.27, height - 1.8, 0.22), Color("#e9e5da"))
	# Elementos no passeio em frente das lojas.
	_cube(Vector3(-6.78, 0.30, z + 8.6), Vector3(0.83, 0.6, 2.2), Color("#a49b8a"))
	_round(Vector3(-6.78, 0.88, z + 8.6), Vector3(0.73, 0.65, 1.1), Color("#467d52"))
	if idx % 2 == 0:
		_cube(Vector3(-8.06, 3.26, z), Vector3(0.35, 1.05, 8.2), Color("#272f33"), 0.2)
		_label(["CAFETERIA", "IMOVEIS", "SERVICOS", "LOJA MODELO", "RECEPCAO"][int(idx / 2) % 5],
			Vector3(-7.79, 3.28, z), 57, Color("#f3d8a1"))

func _build_promenade() -> void:
	var rails: Array[Vector3] = []
	var posts: Array[Vector3] = []
	for i in range(27):
		var z := 20.0 - float(i) * 13.0
		_palm(Vector3(13.25, 0, z), 5.4 + (i % 3) * 0.65)
		if i % 2 == 0:
			_palm(Vector3(-5.8, 0, z - 5.3), 4.3)
		posts.append(Vector3(16.8, 0.58, z))
		rails.append(Vector3(16.8, 0.93, z - 6.5))
		if i % 3 == 0:
			_bench(Vector3(12.5, 0.11, z + 5.4))
			_lamp(Vector3(11.1, 0, z - 5))
	_batch(posts, Vector3(0.19, 1.12, 0.21), Color("#8f7660"))
	_batch(rails, Vector3(0.17, 0.17, 13.1), Color("#8c765d"))
	_batch([Vector3(16.8, 0.42, -150)], Vector3(0.11, 0.11, 346), Color("#957d68"))
	# Lixeiras, canteiros, bancos e quiosques simples.
	for i in range(8):
		var z := 3.0 - float(i) * 43.0
		_cube(Vector3(11.5, 0.58, z), Vector3(0.53, 1.1, 0.51), Color("#3d4845"))
		_cube(Vector3(11.5, 1.16, z), Vector3(0.65, 0.09, 0.6), Color("#d5d2c7"))

func _palm(at: Vector3, height: float) -> void:
	_cylinder(at + Vector3(0, height / 2.0, 0), height, 0.23, Color("#8f7755"))
	_round(at + Vector3(0, height + 0.05, 0), Vector3(0.44, 0.37, 0.44), Color("#4f7d4a"))
	for i in range(8):
		var angle := TAU * float(i) / 8.0
		var blade := _round(at + Vector3(sin(angle) * 1.3, height + 0.06, cos(angle) * 1.3),
			Vector3(0.29, 0.10, 1.95), Color("#317347") if i % 2 == 0 else Color("#478f50"))
		blade.rotation.y = angle

func _lamp(at: Vector3) -> void:
	_cylinder(at + Vector3(0, 2.9, 0), 5.8, 0.085, Color("#53636a"))
	_cube(at + Vector3(0.5, 5.7, 0), Vector3(1.0, 0.14, 0.14), Color("#56666d"))
	_cube(at + Vector3(1.0, 5.63, 0), Vector3(0.5, 0.10, 0.3), Color("#fff1ca"))

func _bench(at: Vector3) -> void:
	_cube(at + Vector3(0, 0.46, 0), Vector3(0.65, 0.12, 1.65), WOOD)
	_cube(at + Vector3(0.29, 0.75, 0), Vector3(0.12, 0.55, 1.65), WOOD)
	for k in [-0.55, 0.55]:
		_cube(at + Vector3(0, 0.20, k), Vector3(0.1, 0.39, 0.12), Color("#454b51"))

func _build_beach() -> void:
	# Praia, guarda-sóis e quiosques. Nao criamos pista de carros ao lado da agua.
	for i in range(29):
		var z := 10.0 - float(i) * 11.0
		var x := 25.0 + float((i * 7) % 19)
		_cylinder(Vector3(x, 0.65, z), 1.5, 0.055, Color("#e7d7bd"))
		var umbrella: Color = [Color("#de7560"), Color("#55a9c0"), Color("#e6d191"), Color("#f2f2e8")][i % 4]
		_round(Vector3(x, 1.48, z), Vector3(2.5, 0.26, 2.5), umbrella)
		_cube(Vector3(x - 1.0, 0.08, z + 1.2), Vector3(0.95, 0.08, 1.5), Color("#75b4bd"))
	# Ondas na borda da areia.
	for i in range(27):
		var z := 9.0 - float(i) * 12.2
		_cube(Vector3(59.5, -0.13, z), Vector3(0.5, 0.03, 7.4), Color("#b7e2e1"))
	# Visada turquesa e areia clara.

func _build_people() -> void:
	var body_colors := [Color("#ebc59b"), Color("#254e66"), Color("#d68a5f"), Color("#ededdf"), Color("#bf5e66")]
	for i in range(11):
		var z := 0.0 - float(i) * 24.5
		var x := -1.4 + float(i % 3) * 2.0
		_cube(Vector3(x, 1.25, z), Vector3(0.56, 0.85, 0.31), body_colors[i % 5])
		_round(Vector3(x, 1.92, z), Vector3(0.28, 0.31, 0.28), Color("#b6815d"))
		for sign in [-1.0, 1.0]:
			_cube(Vector3(x + sign * 0.15, 0.47, z), Vector3(0.18, 0.8, 0.24), Color("#303e48"))
