<img width="1436" height="789" alt="image" src="https://github.com/user-attachments/assets/865071a9-c402-4c8e-a653-5e3b9d695dc5" /><p align="center">
<img src="https://raw.githubusercontent.com/Cahydra/Godot-Material-Mapper/refs/heads/main/images/MM_Banner.png" 
width="600" border="1"/>
</p>

<p align="center">
Automatically create fully configured materials from your texture sets in literal seconds.
</p>

### Installation
 
 1. Download this repository and place `addons/material_mapper` into your project's `res://addons`
 2. Enable Material Mapper inside `Project Settings > Plugins`



# Usage
Simply select multiple textures with matching names (Diffuse, Normal, Roughness, Metallic, and more), or import one or multiple ZIP files containing your textures. The addon detects the map types, creates a new material and fills the correct texture slots for you automatically.

Perfect for artists and developers working with large texture libraries, saving time and speeding up repetitive setup work.

<p align="center">
<img src="https://raw.githubusercontent.com/Cahydra/Godot-Material-Mapper/refs/heads/main/images/MM_Description1.png" 
width="100%" border="1"/>
<br>
<img src="https://raw.githubusercontent.com/Cahydra/Godot-Material-Mapper/refs/heads/main/images/MM_Description2.png" 
width="100%" border="1"/>
</p>



# Customize
## Texture
Does the textures you're trying to map not exist?
Simply change a few settings inside your `Project Settings > General > Material Mapper`

 - Example: 
 You need to map `Robot_Emission.png`
 - Do: 
 Find `Emission Texture` inside your `Project Settings > General > Material Mapper > Texture Suffixes > Emission Texture`
   Then simply seperate your texture suffix (_Emission) with a comma (,) 
  - Result: 
  `Emission Texture` = `_Emission,_emissive,_emit`

## Preset
When importing you can choose which material resource to use as a preset.
- To change presets create a new material inside your material presets path or change it inside your `Project Settings > General > Material Mapper > Material Presets Path`

## Prefix / Suffix
When importing you can choose which prefix or suffix to apply to your materials.
Prefix is added before the material name. Suffix is added after the material name.
- To change prefix/suffix go to your `Project Settings > General > Material Mapper > Material Name Prefixes/Suffixes`
- Add your prefix/suffix seperated with a comma (,)
- Result Prefix: `Material Name Prefix` = `MyPrefix_,OtherPrefix_`
- Result Suffix: `Material Name Suffix` = `_MySuffix,_OtherSuffix`


# Donate ♡
Feel free to donate if you find this useful!
