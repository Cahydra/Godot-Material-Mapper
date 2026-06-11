@tool
extends EditorContextMenuPlugin

const default_empty: String = ''
const context_icon: Texture2D = preload('res://addons/material_mapper/icons/context.svg')
var dialog: Node

##Map context action to open_file_system
func _init(dialogs_scene: Node, shortcut: Shortcut) -> void:
	dialog = dialogs_scene
	add_menu_shortcut(shortcut, open_file_system)


##Show context menu with shortcut and icon.
func _popup_menu(paths: PackedStringArray = []) -> void:
	#print("popup_menu dialog= ",dialog)
	add_context_menu_item_from_shortcut(
		'Import Materials',
		EditorInterface.get_editor_settings().get_shortcut('material_mapper/Import'),
		context_icon
		)


func open_file_system(paths: PackedStringArray) -> void:
	#print("\nopen_file_system!= ",paths)
	
	##Get, add, remove presets from options.
	var presets_path: String = ProjectSettings.get_setting('material_mapper/mapping/general/material_presets_path')
	if presets_path.length() >0:#print("presets_path= ",presets_path)
		##Make sure presets directory is valid!
		if DirAccess.dir_exists_absolute(presets_path):
			var clean_presets: PackedStringArray = PackedStringArray([default_empty])
			##Gets presets with 'tres' extensions only.
			for preset: String in Array(DirAccess.get_files_at(presets_path)).filter(func(file: String): return dialog.allowed_material_extensions.has(file.get_extension())):
				var resource_type: Resource = load(presets_path+ '/'+ preset)
				if resource_type is StandardMaterial3D or resource_type is ORMMaterial3D:##Make sure preset is of type StandardMaterial3D or ORMMaterial3D.
					clean_presets.append(preset)
			dialog.file_selector.set_option_values(2, clean_presets)
		else:
			push_warning('Preset directory is invalid!= ',presets_path)
	else: dialog.file_selector.set_option_values(2, [default_empty])
	
	
	##Get, add, remove prefixes from options.
	var prefixes: String = ProjectSettings.get_setting('material_mapper/mapping/general/material_name_prefixes')
	if prefixes.length() >0:#print("prefixes= ",prefixes)
		var clean_prefixes: PackedStringArray = prefixes.split(',')
		clean_prefixes.insert(0,default_empty)
		dialog.file_selector.set_option_values(0, clean_prefixes)
	else: dialog.file_selector.set_option_values(0, [default_empty])
	
	
	##Get, add, remove suffixes from options.
	var suffixes: String = ProjectSettings.get_setting('material_mapper/mapping/general/material_name_suffixes')
	if suffixes.length() >0:#print("\nsuffixes= ",suffixes)
		var clean_suffixes: PackedStringArray = suffixes.split(',')
		clean_suffixes.insert(0,default_empty)
		##print("Same?= ",clean_suffixes,' == ',dialog.file_selector.get_option_values(1)," ?= ",clean_suffixes == dialog.file_selector.get_option_values(1))
		##if clean_suffixes != dialog.file_selector.get_option_values(1):
		dialog.file_selector.set_option_values(1, clean_suffixes)
	else: dialog.file_selector.set_option_values(1, [default_empty])
	
	##Show file_selector dialog.
	##print("\nOpen from Current dir= ",dialog.file_selector.current_dir)
	dialog.file_selector.popup_centered()
