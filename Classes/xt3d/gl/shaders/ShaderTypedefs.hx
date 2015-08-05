package xt3d.gl.shaders;


typedef ShaderVariable = {
	name: String,
	value: String,
}

typedef BaseTypeInfo = {
	name: String,
	type: String,
	?defaultValue: String,
}

typedef ShaderInfo = {
	vertexProgram:String,
	fragmentProgram:String,
	?variables:Array<ShaderVariable>,
	?types:Map<String, Array<BaseTypeInfo>>,
	?vertexDefines:Array<String>,
	?fragmentDefines:Array<String>,
	?vertexIncludes:Array<String>,
	?fragmentIncludes:Array<String>,
	?commonUniformGroups:Array<String>,
	?uniforms:Map<String, UniformInfo>,
	?attributes:Map<String, AttributeInfo>,
}

typedef ShaderExtensionInfo = {
	?variables:Array<ShaderVariable>,
	?types:Map<String, Array<BaseTypeInfo>>,
	?vertexDefines:Array<String>,
	?fragmentDefines:Array<String>,
	?vertexIncludes:Array<String>,
	?fragmentIncludes:Array<String>,
	?commonUniformGroups:Array<String>,
	?uniforms:Map<String, UniformInfo>,
	?attributes:Map<String, AttributeInfo>,
}

typedef UniformGroupInfo = {
	?variables:Array<ShaderVariable>,
	?types:Map<String, Array<BaseTypeInfo>>,
	?vertexDefines:Array<String>,
	?fragmentDefines:Array<String>,
	uniforms:Map<String, UniformInfo>,
}

typedef UniformInfo = {
	name:String,
	type:String,
	shader:String,
	?defaultValue:String,
	?global:Bool,
	?slot:String,
}

typedef AttributeInfo = {
	name: String,
	type: String,
}
