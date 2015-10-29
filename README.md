
Introduction
============

xTalk3d (or xt3d) is an open-source, cross-platform, 3D graphics and game-development framework built with Haxe and Lime.

xTalk3d aims to provide a simple means of developing 3D games and applications for multiple platforms with optimised performance. 
Depending on the target platform it uses OpenGL, OpenGL ES or WebGL for graphics capabilities. 

It is able to do this by taking advantage of [Lime](https://github.com/openfl/lime) which provides both graphics and user-input back-end support.
Compilation of xt3d projects is done through the lime command-line tools.


Platforms
=========

xTalk3d aims to support as many platforms as Lime does but is currently tested regularly on the following platforms:

 * Mac
 * HTML5
 * iOS
 
The following platforms are known to work but could require testing from those willing to help ;)

 * Windows
 * Linux
 * Android

Features
========

 * Scene-graph with 3D object transformations
 * OpenGL, OpenGL ES, WebGL Support
 * Dynamic lighting
 * Texture mapping
 * Meshes from built-in and custom geometries
 * Built in materials/shaders
 * Custom shader support
 * Object and geometry-face picking
 * Gesture handlers (mouse and touch events)
 * Render to texture

Installation
============

	haxelib install xt3d
 
Getting started
===============

There are sample projects (on their way... ;) ) available with xt3d-samples. They are easily installed through haxelib and the lime command line:

To view all sample projects:

	lime create xt3d 
	
To install the lighting demo project:

	lime create xt3d:Lighting
	
To install a sample to a specific location just do:

	lime create xt3d:Lighting /destination
 

Note...
=======

xt3d is currently in an unstable development stage and is far from complete. If you come across this framework then please give it a try
and send me feedback. Please be aware that the API is likely to change!