package kfsgl.renderer.shaders;

import kfsgl.renderer.shaders.KFShaderReader;
import kfsgl.renderer.shaders.KFUniformLib;

class KFShaderInfo {
	public var vertexProgram:String;
	public var fragmentProgram:String;
	public var uniforms:Map<String, KFUniformInfo>;

	public function new(vertexShaderKey:String, fragmentShaderKey:String, uniformGroups:Array<String>) {
		this.vertexProgram = KFShaderReader.getInstance().shaderWithKey(vertexShaderKey);
		this.fragmentProgram = KFShaderReader.getInstance().shaderWithKey(fragmentShaderKey);
		this.uniforms = KFUniformLib.getInstance().uniformsFromGroups(uniformGroups);
	}


}