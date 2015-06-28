package kfsgl.gl.shaders;

import kfsgl.gl.shaders.ShaderTypedefs;
import kfsgl.utils.StringFunctions;
import kfsgl.utils.KF;

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

		if (shaderInfo.uniforms != null) {
			clone.uniforms = new Map<String, UniformInfo>();
			for (uniformName in shaderInfo.uniforms.keys()) {
				clone.uniforms.set(uniformName, cloneUniformInfo(shaderInfo.uniforms.get(uniformName)));
			}
		}

		if (shaderInfo.variables != null) {
			clone.variables = new Array<ShaderVariable>();
			for (shaderVariable in shaderInfo.variables) {
				clone.variables.push(cloneShaderVariable(shaderVariable));
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

	public static function cloneShaderVariable(shaderVariable:ShaderVariable):ShaderVariable {
		var clone:ShaderVariable = {
			name: shaderVariable.name,
			value: shaderVariable.value
		};
		return clone;
	}

	public static function extendShaderInfo(shaderInfo:ShaderInfo, shaderExtensionInfo:ShaderExtensionInfo, shaderName:String, extensionName:String) {
		if (shaderExtensionInfo.variables != null) {
			if (shaderInfo.variables == null) {
				shaderInfo.variables = new Array<ShaderVariable>();
			}

			for (shaderVariable in shaderExtensionInfo.variables) {
				var variableName = shaderVariable.name;

				var existsAlready:Bool = false;
				for (existingVariables in shaderInfo.variables) {
					if (existingVariables.name == variableName) {
						existsAlready = true;
					}
				}

				if (!existsAlready) {
					shaderInfo.variables.push(shaderVariable);

				} else {
					KF.Warn("Duplicate shader variable \"" + variableName + "\" for shader \"" + shaderName + "\" with extension \"" + extensionName + "\"");
				}
			}
		}

		if (shaderExtensionInfo.types != null) {
			if (shaderInfo.types == null) {
				shaderInfo.types = new Map<String, Map<String, String>>();
			}

			for (typeName in shaderInfo.types.keys()) {
				if (shaderInfo.types.exists(typeName)) {
					var typeDefinition = shaderInfo.types.get(typeName);

					var clonedTypeDef = new Map<String, String>();
					shaderInfo.types.set(typeName, clonedTypeDef);

					for (elementName in typeDefinition.keys()) {
						clonedTypeDef.set(elementName, typeDefinition.get(elementName));
					}
				} else {
					KF.Warn("Duplicate shader type \"" + typeName + "\" for shader \"" + shaderName + "\" with extension \"" + extensionName + "\"");
				}
			}
		}

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

	public static function processVarable(shaderConfig:ShaderInfo, shaderVariable:ShaderVariable):Void {
		var variableName = "$" + shaderVariable.name;
		var value = shaderVariable.value;

		var preProcessed = StringFunctions.replace_all(shaderConfig.vertexProgram, variableName, value);
		shaderConfig.vertexProgram = preProcessed;
		preProcessed = StringFunctions.replace_all(shaderConfig.fragmentProgram, variableName, value);
		shaderConfig.fragmentProgram = preProcessed;

		if (shaderConfig.vertexDefines != null) {
			var processedDefined = new Array<String>();
			for (vertexDefine in shaderConfig.vertexDefines) {
				preProcessed = StringFunctions.replace_all(vertexDefine, variableName, value);
				processedDefined.push(preProcessed);
				shaderConfig.vertexDefines = processedDefined;
			}
		}

		if (shaderConfig.fragmentDefines != null) {
			var processedDefined = new Array<String>();
			for (fragmentDefine in shaderConfig.fragmentDefines) {
				preProcessed = StringFunctions.replace_all(fragmentDefine, variableName, value);
				processedDefined.push(preProcessed);
				shaderConfig.fragmentDefines = processedDefined;
			}
		}

		if (shaderConfig.uniforms != null) {
			for (uniform in shaderConfig.uniforms) {
				preProcessed = StringFunctions.replace_all(uniform.type, variableName, value);
				uniform.type = preProcessed;
				if (uniform.defaultValue != null) {
					preProcessed = StringFunctions.replace_all(uniform.defaultValue, variableName, value);
					uniform.defaultValue = preProcessed;
				}
				if (uniform.slot != null) {
					preProcessed = StringFunctions.replace_all(uniform.slot, variableName, value);
					uniform.slot = preProcessed;
				}
			}
		}
	}
}
