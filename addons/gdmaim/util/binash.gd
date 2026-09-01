## https://github.com/CodeNameTwister/maim/
extends RefCounted

var debug : bool = true
var _buffer : Dictionary = {}

class Formo extends ResourceFormatLoader:
	var _buffer : Dictionary = {}
	
	const SCBOYS : PackedStringArray = [
		"gd", "cs"
		]
		
	const PESCEN : PackedStringArray = [
		"tscn", "scn"
		]
	
	var _resor : RefCounted = null
	var _pathor : String = ""
	var _noud : Node = null
	
	func _init() -> void:
		_resor = RefCounted.new()
		_noud = Node.new()
		
	func _notification(what: int) -> void:
		if what != NOTIFICATION_PREDELETE:
			return
			
		if is_instance_valid(_noud):
			_noud.queue_free()
	
	func _exists(path: String) -> bool:
		return true
		
	func _get_recognized_extensions() -> PackedStringArray:
		return ["tres", "res", "tscn", "scn", "gd", "sc"]
		
	func _recognize_path(path: String, _type: StringName) -> bool:
		return path != _pathor
		
	func _handles_type(type: StringName) -> bool:
		return true
		
	func _get_cryptor() -> GDScript:
		var sc : GDScript = GDScript.new()
		sc.source_code = " pass"
		return sc
		
	func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
		if path == _pathor:
			return null
			
		var exto : String = path.get_extension()
				
		if exto in SCBOYS:
			if !_buffer.has(path):
				_buffer[path] = _get_cryptor()
			return _buffer[path]
		
		elif exto in PESCEN:
			return _noud
		
		return _resor
		
	func _get_resource_uid(path: String) -> int:
		return 0
		
	func set_pathor(jao_pathor : String) -> void:
		_pathor = jao_pathor
	
	func reset() -> void:
		_pathor = ""

var formo : Formo = Formo.new()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		for x : String in _buffer.keys():
			if FileAccess.file_exists(x):
				DirAccess.remove_absolute(x)
				
func get_text(path_file : String) -> String:
	var xout : String = ""
	var pout : bool = Engine.print_error_messages
	
	ResourceLoader.set_abort_on_missing_resources(false)
	ResourceLoader.add_resource_format_loader(formo, true)
	
	if !debug:
		Engine.print_error_messages = false
	
	var res : Resource = ResourceLoader.load(path_file)
	if res:
		var xfout : String = "user://xtmp.tres"
		if path_file.ends_with(".scn"):
			xfout = "user://xtmp.tscn"
		
		_buffer[xfout] = true
		if ResourceSaver.save(res, xfout, ResourceSaver.FLAG_NONE) == OK:
			xout = FileAccess.get_file_as_string(xfout)
			
	#ResourceLoader.remove_resource_format_loader(formo)
	#ResourceLoader.set_abort_on_missing_resources(true)
	
	if !debug:
		Engine.print_error_messages = pout
	
	return xout
				
func get_bytes_from_text(data : String, ext_type : String, compressed : bool = false) -> PackedByteArray:
	if ext_type.is_empty():
		ext_type = "tres"
		
	var tmp : String = "user://itmp." + ext_type
	var f : FileAccess = FileAccess.open(tmp, FileAccess.WRITE)
	f.store_string(data)
	f.close()
	
	_buffer[tmp] = true
	
	return get_bytes(tmp, compressed)
		
func get_bytes(path_file : String, compressed) -> PackedByteArray:
	var shtout : PackedByteArray = []
	
	if FileAccess.file_exists(path_file):
		formo.set_pathor(path_file)
		ResourceLoader.set_abort_on_missing_resources(false)
		ResourceLoader.add_resource_format_loader(formo, true)
		
		var resort : Resource = ResourceLoader.load(path_file, "", ResourceLoader.CACHE_MODE_IGNORE_DEEP)
		var flag : int = ResourceSaver.FLAG_NONE
		
		var xfout : String = "user://xtmp.res"
		
		if path_file.ends_with(".tscn"):
			xfout = "user://xtmp13.scn"
			
		if compressed:
			flag = ResourceSaver.FLAG_COMPRESS
		
		_buffer[xfout] = true
		
		if ResourceSaver.save(resort, xfout, flag) == OK:
			shtout = FileAccess.get_file_as_bytes(xfout)
		
		ResourceLoader.remove_resource_format_loader(formo)
		ResourceLoader.set_abort_on_missing_resources(true)
		
	return shtout
