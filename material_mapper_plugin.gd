@tool
extends EditorPlugin

const DIALOGS_SCENE = preload('res://addons/material_mapper/core/dialogs.tscn')
const CONTEXT_IMPORT_PLUGIN = preload('res://addons/material_mapper/core/context_importer.gd')
const CONTEXT_MAP_PLUGIN = preload("res://addons/material_mapper/core/context_mapper.gd")


var EMPTY_SHORTCUT: Shortcut = Shortcut.new()

var context_import_plugin: EditorContextMenuPlugin
var context_map_plugin: EditorContextMenuPlugin
var file_dialogs: Node


## Plugin Initialization.
func _enter_tree() -> void:
	##Create file_dialogs scene
	file_dialogs = DIALOGS_SCENE.instantiate()
	get_tree().get_root().add_child(file_dialogs)
	
	##Create shortcut references.
	var import_shortcut: Shortcut = Shortcut.new()
	var map_shortcut: Shortcut = Shortcut.new()
	
	##Set direct references to file_dialogs for context_import_plugin
	context_import_plugin = CONTEXT_IMPORT_PLUGIN.new(file_dialogs,import_shortcut)
	context_map_plugin = CONTEXT_MAP_PLUGIN.new(file_dialogs,map_shortcut)
	
	EditorInterface.get_editor_settings().add_shortcut('material_mapper/Import',import_shortcut)##Add Importer Shortcut
	EditorInterface.get_editor_settings().add_shortcut('material_mapper/Map',map_shortcut)##Add Mapper Shortcut
	
	
	add_context_menu_plugin(1, context_import_plugin)##Add Importer
	add_context_menu_plugin(1, context_map_plugin)##Add Mapper


## Plugin Clean-up.
func _exit_tree() -> void:
	##Remove file_dialogs scene
	if file_dialogs: file_dialogs.queue_free()
	
	
	remove_context_menu_plugin(context_import_plugin)##Remove Importer
	remove_context_menu_plugin(context_map_plugin)##Remove Mapper
	
	
	EditorInterface.get_editor_settings().remove_shortcut('material_mapper/Import')##Remove Importer Shortcut
	EditorInterface.get_editor_settings().remove_shortcut('material_mapper/Map')##Remove Mapper Shortcut
