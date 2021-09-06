// Toony Colors Pro+Mobile 2
// (c) 2014-2020 Jean Moreno

using System.Collections.Generic;
using UnityEngine;

// Play-mode utilities for Toony Colors Pro 2

namespace ToonyColorsPro
{
	namespace Runtime
	{
		public static class TCP2_RuntimeUtils
		{
			private const string BASE_SHADER_PATH = "Toony Colors Pro 2/";
			private const string VARIANT_SHADER_PATH = "Hidden/Toony Colors Pro 2/Variants/";
			private const string BASE_SHADER_NAME = "Desktop";
			private const string BASE_SHADER_NAME_MOB = "Mobile";

			private static List<string[]> ShaderVariants = new List<string[]>
	{
		new[]{ "Specular", "TCP2_SPEC" },
		new[]{ "Reflection", "TCP2_REFLECTION", "TCP2_REFLECTION_MASKED" },
		new[]{ "Matcap", "TCP2_MC" },
		new[]{ "Rim", "TCP2_RIM" },
		new[]{ "RimOutline", "TCP2_RIMO" },
		new[]{ "Outline", "OUTLINES" },
		new[]{ "OutlineBlending", "OUTLINE_BLENDING" }
	};

			// Returns the appropriate shader according to the supplied Material's keywords
			//
			// Note that if the shader wasn't assigned on any material it will not be included in the build
			// You can force shaders to be included in the build in "Edit > Project Settings > Graphics"
			public static Shader GetShaderWithKeywords(Material material)
			{
				var isMobileShader = material.shader != null && material.shader.name.ToLower().Contains("mobile");
				var baseName = isMobileShader ? BASE_SHADER_NAME_MOB : BASE_SHADER_NAME;

				var newShader = baseName;
				foreach (var variantKeywords in ShaderVariants)
				{
					foreach (var keyword in material.shaderKeywords)
					{
						for (var i = 1; i < variantKeywords.Length; i++)
						{
							if (keyword == variantKeywords[i])
							{
								newShader += " " + variantKeywords[0];
							}
						}
					}
				}
				newShader = newShader.TrimEnd();

				//If variant shader
				var basePath = BASE_SHADER_PATH;
				if (newShader != baseName)
				{
					basePath = VARIANT_SHADER_PATH;
				}

				var shader = Shader.Find(basePath + newShader);
				return shader;
			}
		}
	}
}