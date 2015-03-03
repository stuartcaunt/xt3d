package kfsgl.renderer.shaders;

import kfsgl.renderer.shaders.ShaderReader;
import kfsgl.renderer.shaders.UniformLib;

class ShaderInfo {
	public var vertexProgram:String;
	public var fragmentProgram:String;
	public var vertexDefines:Array<String>;
	public var fragmentDefines:Array<String>;
	public var uniforms:Map<String, KFUniformInfo>;
	public var commonUniforms:Map<String, Uniform>;

	public function new(vertexShaderKey:String,
						fragmentShaderKey:String,
						vertexDefines:Array<String>,
						fragmentDefines:Array<String>,
						uniforms:Map<String, KFUniformInfo>,
						commonUniformGroups:Array<String>) {
		this.vertexProgram = ShaderReader.instance().shaderWithKey(vertexShaderKey);
		this.fragmentProgram = ShaderReader.instance().shaderWithKey(fragmentShaderKey);
		this.vertexDefines = vertexDefines;
		this.fragmentDefines = fragmentDefines;
		this.uniforms = uniforms;

		// Convert common uniform groups into uniforms
		this.commonUniforms = UniformLib.instance().uniformsFromGroups(commonUniformGroups);
	}


}