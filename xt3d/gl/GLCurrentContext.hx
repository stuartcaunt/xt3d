package xt3d.gl;

import lime.graphics.WebGLRenderContext;
import xt3d.core.Director;

class GLCurrentContext {

    public static var GL(get, null):WebGLRenderContext;

    public static function get_GL() {
        return Director.current.glView.gl;
    }
}