Welcome to AllSky Free!

This is a small sample edition of the full version of Allsky.
It contains a set of 10 skyboxes for use in your environments.
I hope you find them useful!

You can Buy the full version of AllSky here : 

https://assetstore.unity.com/packages/2d/textures-materials/sky/allsky-200-sky-skybox-set-10109

The full version has 200 skies for Unity! Provided as 6 sided cubemaps sized from x1024 to x2048 per-side along with an equirectangular cubemap texture ranging from 4k to 16k in size. Each has an example lighting setup scene!

Various styles: Day, Night, Cartoon, Fantasy, Hazy, Epic, Space, Sunless and Moonless!

For lighting artists, environment artists and indie developers looking for a wide suite of skies to light their environments.

Lighting from day to night: Twilight, sunset, multiple times of day, multiple times of night, skyglow.

Many weather and cloud types: Clear, overcast, summery, stormy, autumnal, hazy, epic, foggy, cumulus.


TECHNICAL

	Texture format: Each sky is a 6 sided cubemap. Source PNG texture resolution per-side ranges from x1024 to x2048.  Equirectangular images vary in size up to 16k textures.  

	Skies are sorted by time of day or style in folders. 
	Each individual sky has a folder which contains the textures and a material with those textures assigned. 
	There is also a demo scene with example lighting and fog pass for reference.

	Each sky has its own 6 sided skybox material which you can set to your scene's current skybox. 
	Please consult the Unity documentation if you are unsure how to do this.
	http://docs.unity3d.com/Manual/HOWTO-UseSkybox.html

	There is also an equirectangular material. Some users report that this is preferable in their use-case or build platform.

	The materials are mostly set as /mobile/skyboxes shaders - which should be fastest - but you can change them to the other skybox shaders that ship with Unity and set the required textures. Some add tint, exposure and rotation controls.

	The import resolution and type of compression used on the sky textures is entirely up to you.  It should be set at a level which you feel utilises appropriate amounts of memory for your game amd platform, taking into account the amount of compression artifacts that you feel are acceptable.

DEMO SCENE

	Each sky folder also has a demo scene. This shows a simple low-poly environment to demonstrate lighting and fog settings for that sky.  

	It was lit in the Forward Lighting Rendering Path with Linear lighting Color Space. 
	For intended demo scene lighting values and fog to be visible you will need a project with those settings.
	(Under Edit->Project Settings->Player)
	If you have to change these settings it may be necessary to re-import the sky textures.

	The demo scene can benefit from increasing the Pixel light count in quality settings, and the Shadow Distance.

WHO

	This asset pack is by Richard Whitelock.
	A game developer, digital artist & photographer.
	15+ years in the games industry working in a variety of senior art roles on 20+ titles. 
	Particularly experienced in environment art, lighting & special FX.
	Currently working on various indie game & personal projects. 

	http://www.richardwhitelock.com

