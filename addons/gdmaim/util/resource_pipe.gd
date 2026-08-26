extends RefCounted

const PATH : String = "res://.gdmaim/tmp."

const EXTENSIONS : Dictionary = {
	"tscn" : "scn",
	"tres" : "res"
}

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for x in EXTENSIONS.keys():
			var kp : String = PATH + x
			var vp : String = PATH + EXTENSIONS[x]
			
			if FileAccess.file_exists(kp):
				DirAccess.remove_absolute(kp)
				
			if FileAccess.file_exists(vp):
				DirAccess.remove_absolute(vp)
				
func res2text(path : String) -> String:
	var out : String = ""
	
	if ResourceLoader.exists(path):
		var oe : bool = Engine.print_error_messages
		Engine.print_error_messages = false
		ResourceLoader.set_abort_on_missing_resources(false)
		
		var res : Resource = ResourceLoader.load(path)
		
		if res:
			var ext : Variant = EXTENSIONS.find_key(path.get_extension())
			
			path = PATH + ext
			if ext == null:
				ext = "tres"
				
			if ResourceSaver.save(res, path) == OK:
				out = FileAccess.get_file_as_string(path)
			else:
				printerr("[GDMaim] Error on parse text resource!")
				
		ResourceLoader.set_abort_on_missing_resources(true)
		Engine.print_error_messages = oe
				
	return out

func text2bin(txt : String, ext : String = "res", compressed : bool = false) -> PackedByteArray:
	var res : Resource = null
	var to : Variant = EXTENSIONS.find_key(ext)
	
	if to == null:
		to = "tres"
	
	var file : FileAccess = FileAccess.open(PATH + to, FileAccess.WRITE)
	
	if file:
		var path : String = PATH + to
		var err : int = ERR_CANT_CREATE
		
		file.store_string(txt)
		file.close()
		
		var oe : bool = Engine.print_error_messages
		Engine.print_error_messages = false
		ResourceLoader.set_abort_on_missing_resources(false)
		res = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
		
		if res:
			path = PATH + EXTENSIONS.get(to, "res")
			if compressed:
				err = ResourceSaver.save(res, path, ResourceSaver.FLAG_COMPRESS)
			else:
				err = ResourceSaver.save(res, path, ResourceSaver.FLAG_NONE)
		
		ResourceLoader.set_abort_on_missing_resources(true)
		Engine.print_error_messages = oe
		
		if err == OK:
			return FileAccess.get_file_as_bytes(path)
		
		printerr("[GDMaim] Error parse bin resource! ", txt)
		
	return txt.to_utf8_buffer()
