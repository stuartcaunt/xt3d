package kfsgl.gl.shaders;


typedef ShaderVariable = {
	name: String,
	value: String
}

typedef ShaderInfo = {
	vertexProgram:String,
	fragmentProgram:String,
	?variables:Array<ShaderVariable>,
	?types:Map<String, Map<String, String>>,
	?vertexDefines:Array<String>,
	?fragmentDefines:Array<String>,
	?commonUniformGroups:Array<String>,
	?uniforms:Map<String, UniformInfo>,
	?attributes:Map<String, AttributeInfo>,
}

typedef ShaderExtensionInfo = {
	?variables:Array<ShaderVariable>,
	?types:Map<String, Map<String, String>>,
	?vertexDefines:Array<String>,
	?fragmentDefines:Array<String>,
	?commonUniformGroups:Array<String>,
	?uniforms:Map<String, UniformInfo>,
	?attributes:Map<String, AttributeInfo>,
}

typedef UniformInfo = {
	name:String,
	type:String,
	shader:String,
	?defaultValue:String,
	?global:Bool,
	?slot:String
}

typedef AttributeInfo = {
	name: String,
	type: String,
}
