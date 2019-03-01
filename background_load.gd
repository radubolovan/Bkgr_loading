extends Control

var m_thread = null
var m_path = ""
var m_scene = null

signal set_total_stage_count
signal set_current_stage

signal scene_begin_load
signal scene_loaded

func _thread_load(path):
	print("Loading map: " + path)
	var ril = ResourceLoader.load_interactive(path)
	assert( ril )

	var total = ril.get_stage_count()
	emit_signal("set_total_stage_count", total)
	#print("total: " + str(total))

	var res = null
	
	while (true): #iterate until we have a resource
		#print("loading: " + str(ril.get_stage()))

		var current = ril.get_stage()
		emit_signal("set_current_stage", current)

		# Poll (does a load step)
		var err = ril.poll()
		# if OK, then load another one. If EOF, it' s done. Otherwise there was an error.
		if ( err == ERR_FILE_EOF):
			#loading done, fetch resource
			res = ril.get_resource()
			break
		elif (err != OK):
			#Not OK, there was an error
			print("There was an error loading")
			break
	
	# Send whathever we did (or not) get
	call_deferred("_thread_done",res)

func _thread_done(resource):
	assert( resource )

	# Always wait for threads to finish, this is required on Windows
	m_thread.wait_to_finish()
	
	# Instantiate new scene
	m_scene = resource.instance()
	emit_signal("scene_begin_load", m_scene)

	# Free current scene
	get_tree().current_scene.free()
	get_tree().current_scene = null
	# Add new one to root
	get_tree().root.add_child( m_scene ) 
	# Set as current scene
	get_tree().current_scene = m_scene

	print("scene loaded!")
	emit_signal("scene_loaded", m_scene)

	m_thread = null

func load_scene(path):
	m_path = path
	m_scene = null
	m_thread = Thread.new()
	m_thread.start( self, "_thread_load", path)
	raise() #show on top
