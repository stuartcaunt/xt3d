package kfsgl.gl.shaders;


import kfsgl.utils.KF;

typedef ShaderInfo = {
	vertexProgram:String,
	fragmentProgram:String,
	?vertexDefines:Array<String>,
	?fragmentDefines:Array<String>,
	?commonUniformGroups:Array<String>,
	?uniforms:Map<String, UniformInfo>,
	?attributes:Map<String, AttributeInfo>,
}

typedef ShaderExtensionInfo = {
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

class ShaderTypedefUtils {

	public static function cloneShaderInfo(shaderInfo:ShaderInfo):ShaderInfo {
		var clone:ShaderInfo = {
			vertexProgram: shaderInfo.vertexProgram,
			fragmentProgram: shaderInfo.fragmentProgram,
			vertexDefines: shaderInfo.vertexDefines != null ? shaderInfo.vertexDefines.slice(0) : [],
			fragmentDefines: shaderInfo.fragmentDefines != null ? shaderInfo.fragmentDefines.slice(0) : [],
			commonUniformGroups: shaderInfo.commonUniformGroups != null ? shaderInfo.commonUniformGroups.slice(0) : []
		};

		if (shaderInfo.uniforms != null) {
			clone.uniforms = new Map<String, UniformInfo>();
			for (uniformName in shaderInfo.uniforms.keys()) {
				clone.uniforms.set(uniformName, cloneUniformInfo(shaderInfo.uniforms.get(uniformName)));
			}
		}

		if (shaderInfo.attributes != null) {
			clone.attributes = new Map<String, AttributeInfo>();
			for (attributeName in shaderInfo.attributes.keys()) {
				clone.attributes.set(attributeName, cloneAttributeInfo(shaderInfo.attributes.get(attributeName)));
			}
		}

		return clone;
	}


	public static function cloneUniformInfo(uniformInfo:UniformInfo):UniformInfo {
		var clone:UniformInfo = {
			name: uniformInfo.name,
			type: uniformInfo.type,
			shader: uniformInfo.shader,
			defaultValue: uniformInfo.defaultValue,
			global: uniformInfo.global,
			slot: uniformInfo.slot
		};
		return clone;
	}

	public static function cloneAttributeInfo(attributeInfo:AttributeInfo):AttributeInfo {
		var clone:AttributeInfo = {
			name: attributeInfo.name,
			type: attributeInfo.type
		};
		return clone;
	}

	public static function extendShaderInfo(shaderInfo:ShaderInfo, shaderExtensionInfo:ShaderExtensionInfo, shaderName:String, extensionName:String) {
		if (shaderExtensionInfo.vertexDefines != null) {
			if (shaderInfo.vertexDefines == null) {
				shaderInfo.vertexDefines = new Array<String>();
			}

			for (vertexDefine in shaderExtensionInfo.vertexDefines) {
				if (shaderInfo.vertexDefines.indexOf(vertexDefine) == -1) {
					shaderInfo.vertexDefines.push(vertexDefine);
				} else {
					KF.Warn("Duplicate vertex define \"" + vertexDefine + "\" for shader \"" + shaderName + "\" with extension \"" + extensionName + "\"");
				}
			}
		}

		if (shaderExtensionInfo.fragmentDefines != null) {
			if (shaderInfo.fragmentDefines == null) {
				shaderInfo.fragmentDefines = new Array<String>();
			}

			for (fragmentDefine in shaderExtensionInfo.fragmentDefines) {
				if (shaderInfo.fragmentDefines.indexOf(fragmentDefine) == -1) {
					shaderInfo.fragmentDefines.push(fragmentDefine);
				} else {
					KF.Warn("Duplicate fragment define \"" + fragmentDefine + "\" for shader \"" + shaderName + "\" with extension \"" + extensionName + "\"");
				}
			}
		}

		if (shaderExtensionInfo.commonUniformGroups != null) {
			if (shaderInfo.commonUniformGroups == null) {
				shaderInfo.commonUniformGroups = new Array<String>();
			}

			for (commonUniformGroup in shaderExtensionInfo.commonUniformGroups) {
				if (shaderInfo.commonUniformGroups.indexOf(commonUniformGroup) == -1) {
					shaderInfo.commonUniformGroups.push(commonUniformGroup);
				}
			}
		}

		if (shaderExtensionInfo.uniforms != null) {
			if (shaderInfo.uniforms == null) {
				shaderInfo.uniforms = new Map<String, UniformInfo>();
			}

			for (uniformName in shaderExtensionInfo.uniforms.keys()) {
				if (!shaderInfo.uniforms.exists(uniformName)) {

					var uniformInfoClone = cloneUniformInfo(shaderExtensionInfo.uniforms.get(uniformName));
					shaderInfo.uniforms.set(uniformName, uniformInfoClone);
				} else {
					KF.Warn("Duplicate uniform \"" + uniformName + "\" for shader \"" + shaderName + "\" with extension \"" + extensionName + "\"");
				}
			}
		}

		if (shaderExtensionInfo.attributes != null) {
			if (shaderInfo.attributes == null) {
				shaderInfo.attributes = new Map<String, AttributeInfo>();
			}

			for (attributeName in shaderExtensionInfo.attributes.keys()) {
				if (!shaderInfo.attributes.exists(attributeName)) {

					var attributeInfoClone = cloneAttributeInfo(shaderExtensionInfo.attributes.get(attributeName));
					shaderInfo.attributes.set(attributeName, attributeInfoClone);
				} else {
					KF.Warn("attribute \"" + attributeName + "\" for shader \"" + shaderName + "\" with extension \"" + extensionName + "\"");
				}
			}
		}

	}
}