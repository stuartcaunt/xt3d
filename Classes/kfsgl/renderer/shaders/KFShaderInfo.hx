package kfsgl.renderer.shaders;

import kfsgl.renderer.shaders.KFUniformInfo;

class KFShaderInfo {
	//public var unforms:Array;
	public var vertexShader:String;
	public var fragmentShader:String;
	public var uniforms:Array<KFUniformInfo>;

	public function new(vertexShader:String, fragmentShader:String, uniforms:Array<KFUniformInfo>) {
		this.vertexShader = vertexShader;
		this.fragmentShader = fragmentShader;
		this.uniforms = uniforms;
	}
}