using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace LcLTools
{
    public delegate void CallBack();

    public class BuildInToURPTool
    {

        /// <summary>
        /// 替换路径下shader文件
        /// </summary>
        /// <param name="fileList"></param>
        /// <param name="callBack"></param>
        public static void ReplaceShaderByPath(List<string> fileList, CallBack callBack = null)
        {
            foreach (var file in fileList)
            {
                ReadShaderFile(file);
            }
            if (callBack != null)
            {
                callBack();
            }
        }

        /// <summary>
        ///  读取shader文件 并开始替换
        /// </summary>
        private static void ReadShaderFile(string path)
        {
            StringBuilder outToStr = new StringBuilder();
            bool hasChange = false;
            using (var fs = new FileStream(path, FileMode.Open))
            {
                int fsLen = (int)fs.Length;
                byte[] txtByte = new byte[fsLen];
                int r = fs.Read(txtByte, 0, txtByte.Length);
                string oldShaderStr = System.Text.Encoding.UTF8.GetString(txtByte);
                //hasChange = CheckChangeTag(oldShaderStr);
                if (hasChange == false)
                {
                    Replace(ref oldShaderStr);
                    //AddTag(ref oldShaderStr);
                    outToStr.Append(oldShaderStr);
                }

                fs.Close();
                fs.Dispose();
            }

            if (hasChange == false)
            {
                using (System.IO.StreamWriter file = new System.IO.StreamWriter(path, false))
                {
                    file.Write(outToStr);
                    file.Close();
                    file.Dispose();
                }
            }
        }



        /// <summary>
        /// 开始执行替换
        /// </summary>
        private static void Replace(ref string oldShaderStr)
        {
            //CGPROGRAM 内容 （可以）
            BaseReplace(ref oldShaderStr, "CGPROGRAM", "HLSLPROGRAM");
            BaseReplace(ref oldShaderStr, "CGINCLUDE", "HLSLINCLUDE");
            BaseReplace(ref oldShaderStr, "ENDCG", "ENDHLSL");

            //include 部分
            ReplaceInclude(ref oldShaderStr);

            //Tag 部分
            ReplaceSubTag(ref oldShaderStr);

            //变体部分


            //CBUFFER  得手动加吧


            //常用函数
            //常用宏
            ReplaceHong(ref oldShaderStr);

            //内置光照参数
            ReplaceAboutLight(ref oldShaderStr);

            // 可以
            ReplaceSampler2D(ref oldShaderStr);

            // vert 下
            //雾效
            ReplaceFog(ref oldShaderStr);

            // 矩阵相关
            // UnityObjectToClipPos
            ReplaceTransform(ref oldShaderStr);

            ReplaceFunction(ref oldShaderStr);
            // tex2D 贴图部分
            ReplaceText2D(ref oldShaderStr);

            //深度图 
            ReplaceAboutDepth(ref oldShaderStr);
            //linear
            ReplaceLinear(ref oldShaderStr);

            // fixed修改
            BaseReplace(ref oldShaderStr, "fixed", "half");
        }

        static string ToUrpTagKey = "//ToUrpTagKey";

        /// <summary>
        /// 检测是否有添加已转换的标签
        /// </summary>
        /// <returns></returns>
        private static bool CheckChangeTag(string curStr)
        {
            if (curStr.Contains(ToUrpTagKey))
            {
                return true;
            }

            return false;
        }

        /// <summary>
        /// 添加标签
        /// </summary>
        /// <param name="oldShaderStr"></param>
        private static void AddTag(ref string oldShaderStr)
        {
            oldShaderStr = string.Format("{0} \n {1}", oldShaderStr, ToUrpTagKey);
        }

        /// <summary>
        /// SubShader 下的  Tags
        /// </summary>
        private static void ReplaceSubTag(ref string oldShaderStr)
        {
            BaseReplace(ref oldShaderStr, "ForwardBase", "UniversalForward");
            // 结尾添加 "RenderPipeline" = "UniversalPipeline"
        }

        /// <summary>
        /// include 部分的替换 (可以了一部分)
        /// </summary>
        private static void ReplaceInclude(ref string oldShaderStr)
        {
            // UnityCG.cginc
            BaseReplace(ref oldShaderStr, "#include \"UnityCG.cginc\"", "#include \"Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl\" \n            #include \"Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl\"");

            //AutoLight.cginc Lighting.cginc
            // BaseReplace(ref oldShaderStr,"","");
            // UnityUI.cginc
            BaseReplace(ref oldShaderStr, "#include \"Lighting.cginc\"", "#include \"Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl\" \n            #include \"Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl\"");
        }

        /// <summary>
        /// 替換添加Cbuff
        /// </summary>
        /// <param name="oldShaderStr"></param>
        private static void ReplacePro(ref string oldShaderStr)
        {

        }

        /// <summary>
        /// sampler2D 
        /// </summary>
        /// <param name="oldShaderStr"></param>
        private static void ReplaceSampler2D(ref string oldShaderStr)
        {
            BaseReplace(ref oldShaderStr, @"(sampler2D|sampler2D_float|uniform sampler2D|uniform sampler2D_float)\s?(.*);", "TEXTURE2D ($2);SAMPLER(sampler$2);");
        }

        /// <summary>
        /// text2D   text2DLod 等 贴图获取
        /// </summary>
        /// <param name="oldShaderStr"></param>
        private static void ReplaceText2D(ref string oldShaderStr)
        {
            // tex2D  -- ok
            // UNITY_SAMPLE_TEX2D  -- ok
            // tex2Dproj
            // tex2Dlod

            BaseReplace(ref oldShaderStr, @"tex2D\(([^,]*),(.*);", "SAMPLE_TEXTURE2D($1,sampler$1,$2;");
            BaseReplace(ref oldShaderStr, @"tex2Dlod\(([^,]*),(.*);", "SAMPLE_TEXTURE2D_LOD($1,sampler$1,$2;");
        }

        /// <summary>
        /// 雾效相关替换 (可以)
        /// </summary>
        private static void ReplaceFog(ref string oldShaderStr)
        {
            //雾 
            BaseReplace(ref oldShaderStr, @"UNITY_FOG_COORDS\(([^(,]+?)\)", "float fogCoord : TEXCOORD$1;");
            BaseReplace(ref oldShaderStr, @"UNITY_TRANSFER_FOG\(([^,]+?)\,([^,]+?)\)", "$1.fogCoord = ComputeFogFactor($2.z)");
            // UNITY_APPLY_FOG_COLOR -> MixFog   UNITY_APPLY_FOG_COLOR 的第三个参数先注释
            BaseReplace(ref oldShaderStr, @"UNITY_APPLY_FOG_COLOR\(\s?(?=.)([^,]+?)\,\s?([^,]+?)\,\s?([^,].*?)\);", "$2.rgb = MixFog($2.rgb,$1); //$3 ");

            //两个参数的替换
            BaseReplace(ref oldShaderStr, @"UNITY_APPLY_FOG\(\s?(?=.)([^,]+?)\,\s?([^,]+?)\);", "$2.rgb = MixFog($2.rgb,$1);");

        }

        /// <summary>
        ///  Linear01Depth LinearEyeDepth 替换  (可以)
        /// </summary>
        /// <param name="oldShaderStr"></param>
        private static void ReplaceLinear(ref string oldShaderStr)
        {
            // Linear01Depth(tex2D(_CameraDepthTexture, i.uv).x);
            //LinearEyeDepth (UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos))))
            // 还要区分是否已经转过了，不然会重复塞值  ~晚点补细节点的，这样不太好
            BaseReplace(ref oldShaderStr, @"Linear01Depth\s?\((.*)\);", "Linear01Depth($1,_ZBufferParams);");
            BaseReplace(ref oldShaderStr, @"LinearEyeDepth\s?\((.*)\);", "LinearEyeDepth($1,_ZBufferParams);");
        }


        /// <summary>
        ///  _CameraDepthTexture  深度图替换（深度相关内容）
        /// </summary>
        private static void ReplaceAboutDepth(ref string oldShaderStr)
        {
            BaseReplace(ref oldShaderStr, @"COMPUTE_EYEDEPTH\((.*?)\);", "$1 = -TransformWorldToView(TransformObjectToWorld(v.vertex)).z;");
        }

        /// <summary>
        /// 矩阵变换相关替换 (可以)
        /// </summary>
        private static void ReplaceTransform(ref string oldShaderStr)
        {
            // UnityObjectToClipPos
            BaseReplace(ref oldShaderStr, "UnityObjectToClipPos", "TransformObjectToHClip");
            BaseReplace(ref oldShaderStr, "UnityObjectToWorldNormal", "TransformObjectToWorldNormal");

            // 内置矩阵
            BaseReplace(ref oldShaderStr, "unity_ObjectToWorld", "UNITY_MATRIX_M");
            BaseReplace(ref oldShaderStr, "unity_WorldToObject", "UNITY_MATRIX_I_M");
            BaseReplace(ref oldShaderStr, "unity_MatrixV", "UNITY_MATRIX_V");
            BaseReplace(ref oldShaderStr, "unity_MatrixInvV", "UNITY_MATRIX_I_V");
            BaseReplace(ref oldShaderStr, "unity_MatrixVP", "UNITY_MATRIX_VP");
            BaseReplace(ref oldShaderStr, "unity_MatrixInvVP", "UNITY_MATRIX_I_VP");
        }


        /// <summary>
        /// 函数替换
        /// </summary>
        private static void ReplaceFunction(ref string oldShaderStr)
        {
            BaseReplace(ref oldShaderStr, "Unity_SafeNormalize", "SafeNormalize");
            BaseReplace(ref oldShaderStr, "UnityWorldToClipPos", "TransformWorldToHClip");
            BaseReplace(ref oldShaderStr, "UnityWorldSpaceViewDir", "GetWorldSpaceNormalizeViewDir");
            BaseReplace(ref oldShaderStr, "UnityObjectToWorldDir", "TransformObjectToWorldDir");
            BaseReplace(ref oldShaderStr, "UnpackNormalWithScale", "UnpackNormalScale");
            BaseReplace(ref oldShaderStr, "LerpOneTo", "LerpWhiteTo");
            BaseReplace(ref oldShaderStr, "TransformViewToProjection", "TransformWViewToHClip");

            BaseReplace(ref oldShaderStr, @"ObjSpaceViewDir\((.*)\)", "TransformWorldToObject(GetCameraPositionWS()) - $1");
        }

        /// <summary>
        /// 阴影替换
        /// </summary>
        private static void ReplaceShadow(ref string oldShaderStr)
        {
            //生成阴影    V2F_SHADOW_CASTER   TRANSFER_SHADOW_CASTER    SHADOW_CASTER_FRAGMENT
            //采样阴影   UNITY_SHADOW_COORDS  TRANSFER_SHADOW   UNITY_LIGHT_ATTENUATION

            // 手动换吧~ 还得研究下

        }

        /// <summary>
        /// 一些常用宏的替换
        /// </summary>
        private static void ReplaceHong(ref string oldShaderStr)
        {
            // UNITY_PROJ_COORD
            // ()还得配对识别
            // tex2Dproj(_tex,UNITY_PROJ_COORD(a))
            //  UNITY_PROJ_COORD(a)  把括号内的内容 取 a.xyw
            // tex2Dproj -> tex2D    a.xy/a.w
            // BaseReplace(ref oldShaderStr, @"UNITY_PROJ_COORD\((.*)\)", "($1).xy/($1).w");


            BaseReplace(ref oldShaderStr, "UNITY_PI", "PI");

        }

        // 常用内置变量  光照等
        /// <summary>
        /// 相关的光照内置内容
        /// </summary>
        private static void ReplaceAboutLight(ref string oldShaderStr)
        {
            BaseReplace(ref oldShaderStr, "_LightColor0", "_MainLightColor");
        }


        // FallBack 返回的默认材质





        // LIGHTING_COORDS  光照贴图

        // 重点是SBP batch





        /// <summary>
        /// 文本替换(纯替换)
        /// </summary>
        /// <param name="shaderStr">shader 内容</param>
        /// <param name="pattern">旧内容</param>
        /// <param name="replacement">新内容</param>

        private static void BaseReplace(ref string shaderStr, string pattern, string replacement)
        {
            shaderStr = Regex.Replace(shaderStr, pattern, replacement);
        }

        /// <summary>
        /// 文本替换(带参数替换)
        /// </summary>
        /// <param name="shaderStr">shader 内容</param>
        /// <param name="pattern">旧内容</param>
        /// <param name="replacement">新内容</param>
        /// <param name="options">带参数的替换</param>
        private static void BaseReplace(ref string shaderStr, string pattern, string replacement, RegexOptions options)
        {
            shaderStr = Regex.Replace(shaderStr, pattern, replacement, options);
        }
    }

}
