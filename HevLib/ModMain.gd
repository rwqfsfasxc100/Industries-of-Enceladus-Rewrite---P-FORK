extends Node

const MOD_PRIORITY = INF
const MOD_NAME = "HevLib - P Fork"
const MOD_VERSION_MAJOR = 1
const MOD_VERSION_MINOR = 6
const MOD_VERSION_BUGFIX = 5
const MOD_VERSION_METADATA = ""
const MOD_IS_LIBRARY = true
const LIBRARY_HIDDEN_BY_DEFAULT = false
var modPath:String = get_script().resource_path.get_base_dir() + "/"
var _savedObjects := []
var modConfig = {}
var HevLibModMain = true
func _init(modLoader = ModLoader):
	l("Initializing DLC")
	loadDLC()
	loadSettings()
	installScriptExtension("events/TheRing.gd")
func _ready():
	l("Readying")
#	replaceScene("scenes/scene_replacements/MouseLayer.tscn", "res://menu/MouseLayer.tscn")
	if ModLoader.is_debugged:
		replaceScene("scenes/scene_replacements/TitleScreen.tscn", "res://TitleScreen.tscn")
#	var mouse = load("res://HevLib/scenes/scene_replacements/MouseLayer.tscn").instance()
	var CRoot = get_tree().get_root()
#	CRoot.call_deferred("add_child",mouse)
	replaceScene("scenes/scene_replacements/TheRing.tscn", "res://story/TheRing.tscn")
	replaceScene("scenes/scene_replacements/Game.tscn", "res://Game.tscn")
	var dir = Directory.new()
	dir.make_dir_recursive("user://cache/.HevLib_Cache/")
	var file = File.new()
	file.open("user://cache/.HevLib_Cache/library_documentation.json", File.WRITE)
	file.store_string(load("res://HevLib/pointers/HevLib.gd").__get_library_functionality(true))
	file.close()
	file.open("user://cache/.HevLib_Cache/currently_installed_mods.json", File.WRITE)
	file.store_string(str(load("res://HevLib/pointers/ManifestV2.gd").__get_mod_data(true,true)))
	file.close()
	var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
	var cache_folder = "user://cache/.HevLib_Cache/Equipment_Driver/"
#	var CRoot = get_tree().get_root()
	var conv := []
	var paths = []
	FolderAccess.__check_folder_exists(cache_folder)
	var mods = ModLoader.get_children()
	l("Scanning installed mods for applicable mods")
	for mod in mods:
		var variants = mod.get_property_list()
		var dict = {}
		var does = false
		for it in variants:
			var iname = it.get("name")
			match iname:
				"ADD_EQUIPMENT_SLOTS":
					does = true
					var arr = mod.ADD_EQUIPMENT_SLOTS
					var arr2 = []
					for item in arr:
						arr2.append(item.duplicate(7))
					dict.merge({"ADD_EQUIPMENT_SLOTS":arr2})
				"ADD_EQUIPMENT_ITEMS":
					does = true
					var arr = mod.ADD_EQUIPMENT_ITEMS
					var arr2 = []
					for item in arr:
						arr2.append(item.duplicate(7))
					dict.merge({"ADD_EQUIPMENT_ITEMS":arr2})
				"EQUIPMENT_TAGS":
					does = true
					var item = mod.EQUIPMENT_TAGS
					dict.merge({"EQUIPMENT_TAGS":item.duplicate(true)})
					pass
				"SLOT_TAGS":
					does = true
					var item = mod.SLOT_TAGS
					dict.merge({"SLOT_TAGS":item.duplicate(true)})
					pass
		if does:
			var mPath = mod.get_script().get_path()
			var mHash = mPath.hash()
			conv.append([dict,mPath,mHash,mod.name])
			paths.append(mPath)
			l("Found mod at %s, labelling as %s" % [mPath, str(mHash)])
	var vNode = load("res://HevLib/scenes/equipment/var_nodes/EquipmentDriver.tscn").instance()
	vNode.conv = conv
	vNode.paths = paths
	vNode.name = "EquipmentDriver"
	CRoot.call_deferred("add_child",vNode)
	
	
	
	l("Ready")
func installScriptExtension(path:String):
	var childPath:String = str(modPath + path)
	var childScript:Script = ResourceLoader.load(childPath)
	childScript.new()
	var parentScript:Script = childScript.get_base_script()
	var parentPath:String = parentScript.resource_path
	l("Installing script extension: %s <- %s" % [parentPath, childPath])
	childScript.take_over_path(parentPath)
func replaceScene(newPath:String, oldPath:String = ""):
	l("Updating scene: %s" % newPath)
	if oldPath.empty():
		oldPath = str("res://" + newPath)
	newPath = str(modPath + newPath)
	var scene := load(newPath)
	scene.take_over_path(oldPath)
	_savedObjects.append(scene)
	l("Finished updating: %s" % oldPath)
func loadDLC():
	l("Preloading DLC as workaround")
	var DLCLoader:Settings = preload("res://Settings.gd").new()
	DLCLoader.loadDLC()
	DLCLoader.queue_free()
	l("Finished loading DLC")
func l(msg:String, title:String = MOD_NAME, version:String = str(MOD_VERSION_MAJOR) + "." + str(MOD_VERSION_MINOR) + "." + str(MOD_VERSION_BUGFIX)):
	if not MOD_VERSION_METADATA == "":
		version = version + "-" + MOD_VERSION_METADATA
	Debug.l("[%s V%s]: %s" % [title, version, msg])
func loadSettings():
	installScriptExtension("Settings.gd")
	l(MOD_NAME + ": Loading mod settings")
	var settings = load("res://Settings.gd").new()
	settings.load_HevLib_FromFile()
	settings.save_HevLib_ToFile()
	modConfig = settings.HevLib
	l(MOD_NAME + ": Current settings: %s" % modConfig)
	settings.queue_free()
	l(MOD_NAME + ": Finished loading settings")
