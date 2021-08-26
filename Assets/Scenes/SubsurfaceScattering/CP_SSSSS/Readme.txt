Custom Phase Screen-Space Subsurface Scattering

Naive screen-space subsurface scattering solution for Unity 5.

==========

How to use:

1) Put the files into any folder in your .../Assets/Resources 
folder.

2) Attach the CP_SSSSS_Main script to your main camera.

3) Attach CP_SSSSS_Object script to any Renderer object that you 
want to have subsurface scattering on.

==========

Basic idea behind algorithm:

1) Blur the source image separably, based on the distance from the
camera, and attenuate surrounding sample's influence based on the 
depth difference between this sample and the center sample (Soft 
Depth Bias parameter controls the maximum depth difference allowed).

2) Render the scene with replaced shader, using the mask set in 
CP_SSSSS_Object script multiplied by the subsurface color.

3) Composite the blurred stuff on top of the original, multiplying 
it by mask from step 2, and substracting the original based on the 
Affect Direct parameter.

==========

https://twitter.com/CustomPhase
https://www.youtube.com/customphase
https://vk.com/customphase
http://customphase.ru/

==========

v. 1.3
03.02.2017

==========