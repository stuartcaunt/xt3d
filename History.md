0.2.6 / 2016-05-20
===================

 * Tangent Space Normal Mapping in generic shader. 
 * Added Tangent Data to Geometries (with calculator from positions and UV data). 
 * Refactoring of InterleavedVertexData into FloatVertexData subclass. 
 * Bug fix on vertex data index calculations.

0.2.5 / 2016-05-02
===================

 * Fix picking with transparent materials.

0.2.4 / 2016-04-02
===================

 * Default number of vertices for cube.
 * Separate alpha blending from color blending to fix alpha problems with view filters.

0.2.3 / 2016-03-23
===================

 * Added Basic2DView initialiser to View (ortho projection). Improved setting of position in Node3D.

0.2.2 / 2016-03-18
===================

 * Configurable blur shader/material/filter.
 * Correctly render transparent filtered views.
 * Various bug fixes for filters and render textures.
 * Refactoring locations of filter materials and shaders.
 * Improved performance of DoF filters by using 50% scaled depth texture.

0.2.1 / 2016-03-10
===================

 * Fix DepthOfFieldBokeh shader for webGL.
 * Use true depth in DepthOfField and DepthOfFieldBokeh filter/material/shaders.
 * Added 'true' DepthMaterial/shader and conversion function to obtain world space z (distance from camera).
 * Move DepthMaterial to LogDepthMaterial (and shaders).
 
0.2.0 / 2016-03-09
===================

 * DepthOfField with two-pass blur function.
 * DepthOfField using blur/sharp image blurring.
 * DepthOfField with Bokeh filter.
 * Allow ViewFilters to be scaled from original (used in BlurFilter).
 * Depth rendering shader.
 * Fixed Node3D scaling issues.
 * BlurViewFilter added.
 * Added ViewFilter to provide post-processing functionalities
 * Simplification of RenderTexture to render View objects.
 * Refactoring render stage to allow for customisations.
 * Added billboard node.

0.1.11 / 2016-02-12
===================

 * Fix specular phong lighting.

0.1.10 / 2016-02-09
===================

 * Verify for vertex and fragment shaders that the number of textures doesn't exceed max for each.
 * For max textures active, use max combined texture image units. 
 * Use 4-component vectors for ambient, diffuse and specular colors (lights and materials) to allow for more control, 
 *  specifically useful for reducing specular intensity.
 * Handle opaque/transparent views.
 * Handle gestures within views: 
 *   only pass gestures to handlers in view under the mouse; 
 *   convert screen coordinates to viewport coordinates including different orientations; 
 *   modify gesture coordinates so the y=0 is at the bottom of the viewport; 
 *   Remove mouseMoveRelative handling;
 * Handle different view orientations.
 * Add margin parameters to viewport constraints.
 * Fix background/clear color not being initialised correctly. 
 * Add scissor test to view if viewport smaller than display size.
 * Add rectangle constraints to view to allow more configuration with display size resizing. 
 * Refactor core.View to view.View. 


0.1.9 / 2015-12-24
===================

 * Update to Lime 2.8.2
 * Added GLExtensionManager to handle opengl extensions enabling 
 * Added Floating point texture support (OES_texture_float + OES_texture_float_linear) 
 * Fix texture slot handling in ShaderProgram
 * Scale handling in Node3D
 * Add viewProjection matrix global uniform
 * Simplify adding and using custom shaders
 * Fix bug on geometry size test and indexed data length (remove count property)

0.1.8 / 2015-11-30
===================

 * Fix geometry bug : zero size and increasing size of already created buffer.
 * Added Long Press gesture recognizer. 
 * Added Swipe gesture recognizer. 

0.1.7 / 2015-11-17
===================

 * Various bug fixes (UVs in cube, camera controller setup, base material properties). 
 * BasicApplication utility. 
 * Other small changes.

0.1.6 / 2015-11-11
===================

 * Fix syntax error in html5 texture cache

0.1.5 / 2015-11-08
===================

 * Fix installation of samples using lime create xt3d:<sample>
 * Remove default XT_DEBUG
 * Typed Materials implementation : ColorMaterial and TextureMaterial
 * Start of a Collada exporter
 
0.1.4 / 2015-10-31
===================

 * xt3d Vector4 and Matrix4 types (typedefed to lime) for library coherency
 * Refactoring of xt3d.utils.math to xt3d.math
 * ScreenCapture utility with save to file for desktop and download for html5
 
0.1.3 / 2015-10-29
===================

 * Update Lime to 2.7.0
 
0.1.2 / 2015-10-29
===================

 * More haxelib integration
 * Split of tests to separate project and remove unnecessary assets and scripts.
 * Refactoring: remove Classes folder
 * Modify include.xml to use Lime 
 
0.1.1 / 2015-10-28
===================

 * Integration of xt3d into a haxelib library
 

