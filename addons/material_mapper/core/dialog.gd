@tool
extends Node

##TODO
##Make texture importing work every single time, it is a bit inconsistent for the moment.

## SETTINGS
## texture path
## material path
## create texture subfolder
## allowed extensions
## godot texture names

@onready var file_system: EditorFileSystem = EditorInterface.get_resource_filesystem()

@onready var file_selector: FileDialog = $FileSelector
@onready var dir_selector: FileDialog = $DirSelector

const allowed_material_extensions: Array = ['tres','res','material']
const default_allowed_extensions: String = 'png,jpg,jpeg,exr,hdr,dds,tga,svg,bmp,ktx,webp'
const default_texture_suffixes: Dictionary = {
	'albedo_texture': '_Color,_col,_diffuse,_diff,_albedo,_alb,_basecolor',
	'orm_texture': '_ORM,_rma,_mra,_arm,_mro',
	'metallic_texture': '_Metalness,_metal,_metallic,_mtl',
	'roughness_texture': '_Roughness,_rough,_rgh',
	'emission_texture': '_Emission,_emissive,_emiss,_emit',
	'normal_texture': '_NormalGL,_nor_gl,_normal,_normalmap,_nrm',
	'bent_normal_texture': '',
	'rim_texture': '',
	'clearcoat_texture': '',
	'anisotropy_flowmap': '',
	'ao_texture': '_AmbientOcclusion,_ao,_occlusion',
	'heightmap_texture': '_Displacement,_disp,_height,_depth',
	'subsurf_scatter_texture': '',
	'subsurf_scatter_transmittance_texture': '',
	'backlight_texture': '',
	'refraction_texture': '',
	'detail_mask': '',
	'detail_albedo': '',
	'detail_normal': '',
}

##CAUTION USING CACHED VARIABLES, THEY MIGHT LIE CAUTION
var cached_files: PackedStringArray = PackedStringArray()
var cached_options: Dictionary = {0: '', 1: '', 2: ''}

func _ready() -> void:
	#print(
		#"\n\nAUTOLOAD PATH= ",get_path(),
		#"\nNAME= ",name
	#)
	## INIT CREATE SETTINGS
	if not ProjectSettings.has_setting('material_mapper/mapping/general/texture_path'):
		set_setting('material_mapper/mapping/general/texture_path','',TYPE_STRING,PROPERTY_HINT_DIR)
	
	## Material
	if not ProjectSettings.has_setting('material_mapper/mapping/general/material_path'):
		set_setting('material_mapper/mapping/general/material_path','',TYPE_STRING,PROPERTY_HINT_DIR)
	
	if not ProjectSettings.has_setting('material_mapper/mapping/general/material_extension'):
		set_setting('material_mapper/mapping/general/material_extension','tres',TYPE_STRING,PROPERTY_HINT_ENUM,'tres,res,material')
	
	if not ProjectSettings.has_setting('material_mapper/mapping/general/material_presets_path'):
		set_setting('material_mapper/mapping/general/material_presets_path','res://addons/material_mapper/presets',TYPE_STRING,PROPERTY_HINT_DIR)
	
	if not ProjectSettings.has_setting('material_mapper/mapping/general/material_name_prefixes'):
		set_setting('material_mapper/mapping/general/material_name_prefixes','',TYPE_STRING)
	
	if not ProjectSettings.has_setting('material_mapper/mapping/general/material_name_suffixes'):
		set_setting('material_mapper/mapping/general/material_name_suffixes','',TYPE_STRING)
	
	if not ProjectSettings.has_setting('material_mapper/mapping/general/create_texture_subfolders'):
		set_setting('material_mapper/mapping/general/create_texture_subfolders',true,TYPE_BOOL)
	
	if not ProjectSettings.has_setting('material_mapper/mapping/general/case_sensitive_texture_suffixes'):
		set_setting('material_mapper/mapping/general/case_sensitive_texture_suffixes',true,TYPE_BOOL)
	
	if not ProjectSettings.has_setting('material_mapper/mapping/general/allowed_extensions'):
		set_setting('material_mapper/mapping/general/allowed_extensions',default_allowed_extensions,TYPE_STRING)
	
	##Godot compatible texture names.
	for texture_suffix: String in default_texture_suffixes.keys():
		if not ProjectSettings.has_setting('material_mapper/mapping/general/texture_suffixes/'+ texture_suffix):
			set_setting('material_mapper/mapping/texture_suffixes/'+ texture_suffix,default_texture_suffixes[texture_suffix],TYPE_STRING)
	
	ProjectSettings.save()
	file_selector.files_selected.connect(process_files)
	dir_selector.dir_selected.connect(texture_dir_selected)


## ERASE SETTINGS
func _exit_tree() -> void:
	set_setting('material_mapper/mapping/general/texture_path',null)
	
	## Material
	set_setting('material_mapper/mapping/general/material_path',null)
	
	set_setting('material_mapper/mapping/general/material_extension',null)
	
	set_setting('material_mapper/mapping/general/material_presets_path',null)
	
	set_setting('material_mapper/mapping/general/material_name_prefixes',null)
	
	set_setting('material_mapper/mapping/general/material_name_suffixes',null)
	
	set_setting('material_mapper/mapping/general/create_texture_subfolders',null)
	
	set_setting('material_mapper/mapping/general/case_sensitive_texture_suffixes',null)
	
	set_setting('material_mapper/mapping/general/allowed_extensions',null)
	
	##Godot compatible texture names.
	for texture_suffix: String in default_texture_suffixes.keys():
		set_setting('material_mapper/mapping/texture_suffixes/'+ texture_suffix,null)
	
	ProjectSettings.save()


##Calls when importing zip files.
func process_files(files: PackedStringArray) -> void:
	##print("\nProcessing files= ",files,' | Selected Options= ',file_selector.get_selected_options()," | current_dir= ",file_selector.current_dir)

	var selected_options: Dictionary = file_selector.get_selected_options()
	var options: Dictionary = {}

	##Convert selected options to usable options
	var index: int = 0
	for option_name: String in selected_options.keys():#print("\nOption name= ",option_name,' | Value= ',selected_options[option_name])
		file_selector.set_option_default(index, selected_options[option_name])
		options[index] = file_selector.get_option_values(index)[selected_options[option_name]]
		index += 1

	##Create materials from files & options
	create_materials_from_files(files,options)


##Creates materials from files & options.
func create_materials_from_files(files: PackedStringArray, options: Dictionary) -> void:
	#print("\ncreate_materials_from_files! Files= ",files,' | Options= ',options)
	##If texture path does not exist then let user create/choose one
	##Make sure there is a texture path and that it is valid!

	var textures: Dictionary = {}
	var material_path: String = ''
	var texture_path: String = ProjectSettings.get_setting('material_mapper/mapping/general/texture_path')
	##Texture path is empty or (texture path is not empty and texture directory exists) then select texture dir.
	if texture_path.length() == 0 or (texture_path.length() != 0 and not DirAccess.dir_exists_absolute(texture_path)):
		##Cache arguments
		cached_files = files
		cached_options = options
		dir_selector.popup_centered()##Select texture path
		return
	#print('texture_path= ',texture_path)

	##Extract all zip files.
	for path: String in files:#print("\nPath= ",path,' | ',path.get_basename().get_file())
		##If create texture subfolder then
		if ProjectSettings.get_setting('material_mapper/mapping/general/create_texture_subfolders'):
			textures[texture_path+ '/'+ path.get_basename().get_file()] = zip_extract(path, texture_path, path.get_basename().get_file())
		else:
			textures[texture_path] = zip_extract(path, texture_path)

	#region await godot reimport before creating materials
	await get_tree().create_timer(0.75).timeout##Random timer to hopefully make sure the created resources actually exist for godot.
	
	##Scan for files that are not yet imported.
	file_system.scan()
	file_system.scan_sources()
	
	await file_system.resources_reimported
	await get_tree().create_timer(0.75).timeout##Random timer to hopefully make sure the imported resources actually get reimported by godot properly.
	#endregion
	
	for path: String in textures.keys():
		#print('\nPath= ',path)
		for material_name: String in textures[path].keys():
			material_path = ProjectSettings.get_setting('material_mapper/mapping/general/material_path','')
			if material_path.length() == 0:##Use unique material path for each material.
				if ProjectSettings.get_setting('material_mapper/mapping/general/create_texture_subfolders'):
					material_path = texture_path+ '/'+ material_name
				else:material_path = texture_path
			#print(
				#'\nMaterial name= ',material_name,
				#'\nTextures= ',textures[path][material_name],
				#'\nmaterial_path= ',material_path,
				#'\noptions= ',options,
			#)
			create_material(material_name, textures[path][material_name], material_path, options[2], options[0], options[1])


##ProjectSettings.get_setting('material_mapper/mapping/general/texture_path'),
## Single! Mateiral Name, Texture Paths {'godot_albedo_name': res://texture_1_albedo, 'godot_normal_name': res://texture_1_normal}
func create_material(material_name: String, textures: Dictionary, path: String, preset: String = '', prefix: String = '', suffix: String = '') -> BaseMaterial3D:
	#print("\ncreate_material= ",material_name,' | path= ',path,' | preset= ',preset,' | prefix= ',prefix,' | suffix= ',suffix)
	#Create Material & save it to material_path.
	var extension: String = ProjectSettings.get_setting('material_mapper/mapping/general/material_extension','tres')
	var material: BaseMaterial3D

	#print("Preset selected?= ",preset.length() >0)
	if preset.length() >0:##Preset is selected.
		var presets_path: String = ProjectSettings.get_setting('material_mapper/mapping/general/material_presets_path')
		##Preset path is not empty and preset directory exists.
		#print("Preset path & preset dir?= ",presets_path.length() >0 and DirAccess.dir_exists_absolute(presets_path))
		if presets_path.length() >0 and DirAccess.dir_exists_absolute(presets_path):
			##Preset is of type StandardMaterial3D or ORMMaterial3D?
			var resource_preset: Resource = load(presets_path+ '/'+ preset)
			if resource_preset is StandardMaterial3D or resource_preset is ORMMaterial3D:
				material = resource_preset.duplicate_deep()
				extension = preset.get_extension()
			else:push_error('Selected preset was not of type ORMMaterial3D or StandardMaterial3D!= ',presets_path+ '/'+ preset)
		else:push_warning('Preset path or directory is invalid!= ',presets_path)


	##Create ORM if 'orm_texture' is detected as a texture.
	if material == null: material = ORMMaterial3D.new() if textures.has('orm_texture') else StandardMaterial3D.new()



	##Set material properties
	for texture_name: String in textures.keys():#print("\nTexture name= ",texture_name," | textures[texture_name]= ",textures[texture_name])
		material.set(texture_name, load(textures[texture_name]))
		match texture_name:
			'emission_texture':
				material.emission_enabled = true
			'normal_texture':
				material.normal_enabled = true
			'bent_normal_texture':
				material.bent_normal_enabled = true
			'rim_texture':
				material.rim_enabled = true
			'clearcoat_texture':
				material.clearcoat_enabled = true
			'anisotropy_flowmap':
				material.anisotropy_enabled = true
			'ao_texture':
				material.ao_enabled = true
			'heightmap_texture':
				material.heightmap_enabled = true
			'subsurf_scatter_texture':
				material.subsurf_scatter_enabled = true
			'subsurf_scatter_transmittance_texture':
				material.subsurf_scatter_transmittance_enabled = true
			'backlight_texture':
				material.backlight_enabled = true
			'refraction_texture':
				material.refraction_enabled = true
			'detail_mask','detail_albedo','detail_normal':
				material.detail_enabled = true
	
	#print('full path= ',path+ '/'+ prefix+ material_name+ suffix+ '.'+ extension)
	ResourceSaver.save(material, path+ '/'+ prefix+ material_name+ suffix+ '.'+ extension, ResourceSaver.FLAG_COMPRESS)
	return material


##Choose texture directory
func texture_dir_selected(dir: String) -> void:
	#print(
		#"\ntexture_dir_selected= ",dir,
		#"\ncached_files= ",cached_files,
		#"\ncached_options= ",cached_options,
	#)
	##Save texture folder path
	set_setting('material_mapper/mapping/general/texture_path',dir)
	##Create the materials from files & selected options.
	create_materials_from_files(cached_files,cached_options)


##Returns unziped textures array
func zip_extract(zip_path: String, extract_path: String, subfolder: String = '') -> Dictionary:
	#print("\n\nzip_extract= ",zip_path," | extract_path= ",extract_path," | subfolder= ",subfolder)
	var reader := ZIPReader.new()
	var err: Error = reader.open(zip_path)
	if err != OK:
		push_error("Failed to unzip zip_path!= ",zip_path," | Reason= ",error_string(err))
		return {}
		
	##textures = {'texture_name': 'res://Texture/Path'}
	var textures: Dictionary = {}
	
	var extensions: Array = ProjectSettings.get_setting('material_mapper/mapping/general/allowed_extensions',default_allowed_extensions).split(',')
	#print("extensions= ",extensions)
	
	var root_dir: DirAccess = DirAccess.open(extract_path)
	var file_path: String = ''
	var filter_result: Dictionary = {}

	##Create texture subfolder.
	if subfolder.length() != 0:
		root_dir.make_dir(subfolder)
		root_dir.change_dir(subfolder)


	##Loop over all files.
	for file: String in reader.get_files():
		filter_result = filter_files([root_dir.get_current_dir().path_join(file.get_file())], false)
		if filter_result.size() == 0: continue
		#print('\nFile= ',file)
		#print('Path= ',root_dir.get_current_dir().path_join(file.get_file()))
		#print('Filter result= ',filter_result)

		##Writes file to root_dir
		file_path = root_dir.get_current_dir().path_join(file.get_file())
		var file_access: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
		file_access.store_buffer(reader.read_file(file))##Write data to file.

		#Supply compatible texture name with path to texture.

		##Create material name inside textures.
		if !textures.has(filter_result['material_name']): textures[filter_result['material_name']] = {}

		textures[filter_result['material_name']][filter_result['texture_suffix']] = file_access.get_path()
		if file_system: file_system.update_file(file_path)
	reader.close()
	return textures


"""
Files:
	res://Texture_Female_Color.png
	res://Texture_Female_ORM.png
	res://Texture_Male_Color.png
	res://Texture_Male_ORM.png
Output = {
	Texture_Female: {
		directory is chosen by the first texture file path when texture name is created.
		directory: res://Texture_Female_Color.png,
		albedo_texture: res://Texture_Female_Color.png,
		orm_texture: res://Texture_Female_ORM.png
	}
	Texture_Male: {
		albedo_texture: res://Texture_Male_Color.png,
		orm_texture: res://Texture_Male_ORM.png
	}
}
"""
## Texture = Name + Type + Extension
## filter_files( files, include_directory? )
func filter_files(files: PackedStringArray = [], include_directory: bool = true)->Dictionary:
	#print('\nFilter files= ',files)
	var output: Dictionary = {}
	var extensions: Array = ProjectSettings.get_setting('material_mapper/mapping/general/allowed_extensions',default_allowed_extensions).split(',')
	var case_sensitive: bool = ProjectSettings.get_setting('material_mapper/mapping/general/case_sensitive_texture_suffixes', true)
	
	var compatible_texture_suffixes: Dictionary = {}
	for texture_suffix: String in default_texture_suffixes.keys():##Writes to compatible_texture_names
		compatible_texture_suffixes[texture_suffix] = ProjectSettings.get_setting('material_mapper/mapping/texture_suffixes/'+ texture_suffix,'')
	#print("compatible_texture_names= ",compatible_texture_names)
	
	##Reusable variables.
	var found_suffixes: Dictionary = {}
	var found_texture_name: String = ''
	var found_suffix_name: String = ''
	var file_name: String = ''
	var end_most_suffix_index: int = 0##Suffix closest to the end (highest index is closest to the end)
	
	for file: String in files:
		if not extensions.has(file.get_extension()): continue
		found_suffixes = {}
		found_texture_name = ''
		found_suffix_name = ''
		file_name = file.get_file().get_basename()
		end_most_suffix_index = 0
		#print('\nFile= ',file)
		#print('File Name= ',file_name)
		
		## Loop over all compatible texture suffixes
		for texture_name: String in compatible_texture_suffixes.keys():
			if compatible_texture_suffixes[texture_name].length() == 0: continue##Skip missing.
			##Check if file name has a compatible texture suffix key inside its name.
			for suffix: String in compatible_texture_suffixes[texture_name].split(','):
				#print('\nsuffix= ',suffix)
				var suffix_index: int = case(file_name, case_sensitive).rfind(case(suffix, case_sensitive))
				if suffix_index != -1:##Found suffix in file name?
					if !found_suffixes.has(texture_name): found_suffixes[texture_name] = {}
					found_suffixes[texture_name][suffix] = suffix_index
		if found_suffixes.size() == 0: continue##No suffixes found, skip.
		#print('\nfound_suffixes= ',found_suffixes)
		
		
		##Find highest index first
		##And use the biggest suffix name
		for texture_name: String in found_suffixes.keys():#print('\nTexture Name= ',texture_name)
			for suffix: String in found_suffixes[texture_name].keys():#print('\nSuffix= ',suffix,' | index= ',found_suffixes[texture_name][suffix])
				##Use highest index
				##or same index and new suffix name is longer.
				if found_suffixes[texture_name][suffix] > end_most_suffix_index or found_suffixes[texture_name][suffix] == end_most_suffix_index and suffix.length() > found_suffix_name.length():
					found_texture_name = texture_name
					end_most_suffix_index = found_suffixes[texture_name][suffix]
					found_suffix_name = suffix
		#print('\nfound_texture_name= ',found_texture_name)
		#print('found_suffix_name= ',found_suffix_name)
		
		##Remove suffix from texture name.
		var clean_file_name: String = file_name.erase(end_most_suffix_index,found_suffix_name.length())
		if include_directory:
			## Create Texture suffix dictionary for output.
			if !output.has(clean_file_name):
				output[clean_file_name] = {}
				output[clean_file_name]['directory'] = file.get_base_dir()
			## Add found_texture_name to material name (clean file name).
			output[clean_file_name][found_texture_name] = file
		else:
			output['texture_suffix'] = found_texture_name##texture suffix == godot compatible texture name
			output['material_name'] = clean_file_name##material name == TextureName - Type - Extension
	return output

##Returns string modified by case sensitivity.
func case(string: String, case_sensitive: bool) -> String: return string if case_sensitive else string.to_lower()

func set_setting(_name: String, value: Variant = '', type: Variant.Type = 0, hint: PropertyHint = 0, hint_string: String = '') -> void:
	#print("\nSet setting= ",_name,' | ',value,' | ',type,' | ',hint)
	ProjectSettings.set_setting(_name, value)
	if type != 0:##Add property info & set initial value. (aka default value)
		ProjectSettings.set_initial_value(_name, value)
		ProjectSettings.add_property_info({
			'name': _name,
			'type': type,
			'hint': hint,
			'hint_string': hint_string,
		})
