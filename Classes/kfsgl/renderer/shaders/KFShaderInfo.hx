package kfsgl.renderer.shaders;

import kfsgl.renderer.shaders.KFShaderReader;
import kfsgl.renderer.shaders.KFUniformLib;

class KFShaderInfo {
	public var vertexProgram:String;
	public var fragmentProgram:String;
	public var vertexDefines:Array<String>;
	public var fragmentDefines:Array<String>;
	public var uniforms:Map<String, KFUniformInfo>;
	public var commonUniforms:Map<String, KFUniform>;

	public function new(vertexShaderKey:String,
						fragmentShaderKey:String,
						vertexDefines:Array<String>,
						fragmentDefines:Array<String>,
						uniforms:Map<String, KFUniformInfo>,
						commonUniformGroups:Array<String>) {
		this.vertexProgram = KFShaderReader.instance().shaderWithKey(vertexShaderKey);
		this.fragmentProgram = KFShaderReader.instance().shaderWithKey(fragmentShaderKey);
		this.vertexDefines = vertexDefines;
		this.fragmentDefines = fragmentDefines;
		this.uniforms = uniforms;

		// Convert common uniform groups into uniforms
		this.commonUniforms = KFUniformLib.instance().uniformsFromGroups(commonUniformGroups);
	}


}