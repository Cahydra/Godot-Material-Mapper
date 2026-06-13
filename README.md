<p align="center">
<img src="https://raw.githubusercontent.com/Cahydra/Godot-Material-Mapper/refs/heads/main/images/MM_Banner.png" 
width="600" border="1"/>
</p>

<p align="center">
Automatically create fully configured materials from your texture sets in literal seconds.
</p>

### Installation
 
 1. Download this repository and place `addons/material_mapper` into your project's `res://addons`.
 2. Enable Material Mapper inside `Project Settings > Plugins`.



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
Does the textures you're trying to map not exist?
Simply change a few settings inside your `Project Settings > General > Material Mapper`

 - Example: 
 You need to map `Robot_Emission.png`
 - Do: 
 Find `Emission Texture` inside your `Project Settings > General > Material Mapper > Texture Suffixes > Emission Texture`
   Then simply seperate your texture suffix (_Emission) with a comma (,) 
  - Result: 
  `Emission Texture` = `_Emission,_emissive,_emit`

# Donate ♡
Feel free to donate if you find this useful!
