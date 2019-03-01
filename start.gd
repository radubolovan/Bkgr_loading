extends Node2D

const c_starting_scene = "res://3D_scene.tscn"
var m_start_scene = false

func _ready():
	$start_btn.connect("pressed", self, "on_start_btn_pressed")

	m_start_scene = false

func _process(delta):
	if(m_start_scene):
		m_start_scene = false
		g_background_load.load_scene(c_starting_scene)

func on_start_btn_pressed():
	m_start_scene = true
	$start_btn.set_disabled(true)
	$loading.show()
