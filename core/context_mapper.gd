@tool
extends EditorContextMenuPlugin

const context_icon: Texture2D = preload('res://addons/material_mapper/icons/context.svg')
var dialog: Node

##Map context action to open_file_system
func _init(dialogs_scene: Node, shortcut: Shortcut) -> void:
	dialog = dialogs_scene
	add_menu_shortcut(shortcut, mapped)


##Show context menu with shortcut and icon.
func _popup_menu(paths: PackedStringArray = []) -> void:
	#print("popup_menu dialog= ",dialog)
	add_context_menu_item_from_shortcut(
		'Map Materials',
		EditorInterface.get_editor_settings().get_shortcut('material_mapper/Map'),
		context_icon
		)

func mapped(paths: PackedStringArray):
	#print('\nMapped!= ',paths)
	var filtered_files: Dictionary = dialog.filter_files(paths)
	print_debug('\n\nMapped Materials= ',JSON.stringify(filtered_files,'\t'))
	
	##Filter out key texture names that are matched with godot texture names.
	var directory_path: String = ''
	for material_name: String in filtered_files.keys():
		directory_path = filtered_files[material_name]['directory']
		filtered_files[material_name].erase('directory')
		#print('\nmaterial_name= ',material_name)
		#print('directory= ',directory_path)
		#print('textures= ',JSON.stringify(filtered_files[material_name],'\t'))
		dialog.create_material(material_name, filtered_files[material_name], directory_path)
