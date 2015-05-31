package kfsgl.gl.shaders;

import kfsgl.gl.shaders.ShaderReader;
import kfsgl.gl.shaders.UniformInfo;

class ShaderInfo {
	public var vertexProgram:String;
	public var fragmentProgram:String;
	public var vertexDefines:Array<String>;
	public var fragmentDefines:Array<String>;
	public var uniforms:Map<String, UniformInfo>;
	public var commonUniformGroups:Array<String>;
	public var attributes:Map<String, AttributeInfo>;

	public function new(vertexShaderKey:String,
						fragmentShaderKey:String,
						vertexDefines:Array<String>,
						fragmentDefines:Array<String>,
						uniforms:Map<String, UniformInfo>,
						commonUniformGroups:Array<String>,
						attributes:Map<String, AttributeInfo>) {
		this.vertexProgram = ShaderReader.instance().shaderWithKey(vertexShaderKey);
		this.fragmentProgram = ShaderReader.instance().shaderWithKey(fragmentShaderKey);
		this.vertexDefines = vertexDefines;
		this.fragmentDefines = fragmentDefines;
		this.uniforms = uniforms;
		this.commonUniformGroups = commonUniformGroups;
		this.attributes = attributes;
	}


}