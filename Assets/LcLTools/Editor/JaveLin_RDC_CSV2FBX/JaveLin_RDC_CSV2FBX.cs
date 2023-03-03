using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEditor.Formats.Fbx.Exporter;
using UnityEngine;
namespace LcLTools
{
    public class JaveLin_RDC_CSV2FBX : EditorWindow
    {
        [MenuItem("LcLTools/CSV To FBX")]
        private static void _Show()
        {
            var win = EditorWindow.GetWindow<JaveLin_RDC_CSV2FBX>();
            win.titleContent = new GUIContent("JaveLin_RDC_CSV2FBX");
            win.Show();
        }

        // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰跨€碉拷?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔锯偓楣冩⒑閸濓拷??妞ゎ厾鍏橀悰顔跨疀濞戞瑧鍙嗛柣搴岛閺呮繄绮堥埀锟�
        public class VertexIDInfo
        {
            public int IDX;                 // 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵鍋撶€氾拷
            public VertexInfo vertexInfo;   // 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺闁革拷?闁稿繑锕㈠銊︽綇閵婏拷?婵傚憡鏅搁柨锟�?
        }

        // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰跨€碉拷?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔惧綒闂備胶鎳撻崵鏍箯?
        public enum SemanticType
        {
            Unknown,

            VTX,

            IDX,

            POSITION_X,
            POSITION_Y,
            POSITION_Z,
            POSITION_W,

            NORMAL_X,
            NORMAL_Y,
            NORMAL_Z,
            NORMAL_W,

            TANGENT_X,
            TANGENT_Y,
            TANGENT_Z,
            TANGENT_W,

            TEXCOORD0_X,
            TEXCOORD0_Y,
            TEXCOORD0_Z,
            TEXCOORD0_W,

            TEXCOORD1_X,
            TEXCOORD1_Y,
            TEXCOORD1_Z,
            TEXCOORD1_W,

            TEXCOORD2_X,
            TEXCOORD2_Y,
            TEXCOORD2_Z,
            TEXCOORD2_W,

            TEXCOORD3_X,
            TEXCOORD3_Y,
            TEXCOORD3_Z,
            TEXCOORD3_W,

            TEXCOORD4_X,
            TEXCOORD4_Y,
            TEXCOORD4_Z,
            TEXCOORD4_W,

            TEXCOORD5_X,
            TEXCOORD5_Y,
            TEXCOORD5_Z,
            TEXCOORD5_W,

            TEXCOORD6_X,
            TEXCOORD6_Y,
            TEXCOORD6_Z,
            TEXCOORD6_W,

            TEXCOORD7_X,
            TEXCOORD7_Y,
            TEXCOORD7_Z,
            TEXCOORD7_W,

            COLOR0_X,
            COLOR0_Y,
            COLOR0_Z,
            COLOR0_W,
        }

        // jave.lin : Semantic 闂傚倷绀侀幖顐も偓锟�?婵犵數鍋愰崑鎾绘⒑鏉炴壆鍔嶉柟鐟版搐??妞ゆ帒瀚洿闂佺硶鍓�?婵犱胶澶勯梻鍌氬€峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵鍋撶€氾拷
        public enum SemanticMappingType
        {
            Default,            // jave.lin : 婵犵數鍋犻幓顏嗗緤閽橈拷?绾绡€鐎碉拷?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨碍纭炬い顐ｎ殔閳藉鈻庡▎鎺嗗亾閸ф鐓涘ù锝堫潐鐏忕増绻涢悡搴ｇ鐎规洘锕�?韫囨挾校婵炲牅鍗冲娲偡閺夋寧顔€闂佺懓鍤栭幏锟�
            ManuallyMapping,    // jave.lin : 婵犵數鍋犻幓顏嗗緤閽橈拷?绾绡€鐎碉拷?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔句簽婵＄偑鍊戦崹铏瑰垝鎼淬劌绠悗锟�?闁瑰弶鎸冲畷鐔碱敃?濞村吋鎹囧缁樻媴閼恒儳銆婇梺鍝ュУ閸旀瑥顕ｉ崨濠勭瘈婵拷?缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕�??濞寸厧鐡ㄩ崑鎰磽娴ｈ偂鎴濃枍閵忋倖鈷戦柛婵嗗閳ь剙鐖煎畷鎰板冀?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜為梺绋挎湰缁嬫垿顢�?
        }

        // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰跨€碉拷?闂佺懓澧界划顖炲磿濡や降浜滈柟鎵虫櫅閳ь剚鐗犻幃楣冩焼瀹ュ棛鍘遍梺鐟扮摠閻熴儵鍩€?闁猴拷?闁筹拷?婵ǹ椴搁崵鈧銈嗘穿缂嶄線寮幘缁樻櫢闁匡拷?
        public enum MaterialSetType
        {
            CreateNew,
            UsingExsitMaterialAsset,
        }

        // jave.lin : application to vertex shader 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鑹邦暰闂佺ǹ顑嗛幐鎼侊綖濠靛鍤嬮柛锟�?婵炲懌鍨藉娲传閸曨偀鍋撻崼鏇炵９闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰跨€碉拷?闂佺懓澧界划顖炴偂閳ь剛绱掗悙顒佺凡妞わ箒浜划鏃堝醇閺囩喓鍘垫俊鐐差儏妤犳悂宕㈤幘顔界厸濞达綀顫夊畷宀€鈧拷?妞ゆ帒瀚洿闂佺硶鍓�?婵犱胶澶勯梻鍌氬€峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備焦鐪归崐銈夊垂鏉堚晝鐭堟い鏇楀亾婵﹨娅ｉ幑鍕Ω閵夛妇鈧箖姊洪崫锟�??妞ゎ厾鍏橀悰顔跨疀濞戞瑥鈧鏌ら幁鎺戝姕婵炲懌鍨藉鍝劽虹拠鎻掑闂佺ǹ顑嗛幐鍓ф閻愬搫鐐婃い鎺嗗亾缂侊拷?闂備浇娉曢崳锕傚箯?
        public class VertexInfo
        {
            public int VTX;
            public int IDX;

            public float POSITION_X;
            public float POSITION_Y;
            public float POSITION_Z;
            public float POSITION_W;

            public float NORMAL_X;
            public float NORMAL_Y;
            public float NORMAL_Z;
            public float NORMAL_W;

            public float TANGENT_X;
            public float TANGENT_Y;
            public float TANGENT_Z;
            public float TANGENT_W;

            public float TEXCOORD0_X;
            public float TEXCOORD0_Y;
            public float TEXCOORD0_Z;
            public float TEXCOORD0_W;

            public float TEXCOORD1_X;
            public float TEXCOORD1_Y;
            public float TEXCOORD1_Z;
            public float TEXCOORD1_W;

            public float TEXCOORD2_X;
            public float TEXCOORD2_Y;
            public float TEXCOORD2_Z;
            public float TEXCOORD2_W;

            public float TEXCOORD3_X;
            public float TEXCOORD3_Y;
            public float TEXCOORD3_Z;
            public float TEXCOORD3_W;

            public float TEXCOORD4_X;
            public float TEXCOORD4_Y;
            public float TEXCOORD4_Z;
            public float TEXCOORD4_W;

            public float TEXCOORD5_X;
            public float TEXCOORD5_Y;
            public float TEXCOORD5_Z;
            public float TEXCOORD5_W;

            public float TEXCOORD6_X;
            public float TEXCOORD6_Y;
            public float TEXCOORD6_Z;
            public float TEXCOORD6_W;

            public float TEXCOORD7_X;
            public float TEXCOORD7_Y;
            public float TEXCOORD7_Z;
            public float TEXCOORD7_W;

            public float COLOR0_X;
            public float COLOR0_Y;
            public float COLOR0_Z;
            public float COLOR0_W;

            public Vector3 POSITION
            {
                get
                {
                    return new Vector3(
                    POSITION_X,
                    POSITION_Y,
                    POSITION_Z);
                }
            }

            // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰跨€碉拷?闂佺懓澧界划顖炲疾閹间焦鐓ラ柣鏇炲€圭€氾拷
            public Vector4 POSITION_H
            {
                get
                {
                    return new Vector4(
                    POSITION_X,
                    POSITION_Y,
                    POSITION_Z,
                    1);
                }
            }

            public Vector4 NORMAL
            {
                get
                {
                    return new Vector4(
                    NORMAL_X,
                    NORMAL_Y,
                    NORMAL_Z,
                    NORMAL_W);
                }
            }
            public Vector4 TANGENT
            {
                get
                {
                    return new Vector4(
                    TANGENT_X,
                    TANGENT_Y,
                    TANGENT_Z,
                    TANGENT_W);
                }
            }

            public Vector4 TEXCOORD0
            {
                get
                {
                    return new Vector4(
                    TEXCOORD0_X,
                    TEXCOORD0_Y,
                    TEXCOORD0_Z,
                    TEXCOORD0_W);
                }
            }

            public Vector4 TEXCOORD1
            {
                get
                {
                    return new Vector4(
                    TEXCOORD1_X,
                    TEXCOORD1_Y,
                    TEXCOORD1_Z,
                    TEXCOORD1_W);
                }
            }

            public Vector4 TEXCOORD2
            {
                get
                {
                    return new Vector4(
                    TEXCOORD2_X,
                    TEXCOORD2_Y,
                    TEXCOORD2_Z,
                    TEXCOORD2_W);
                }
            }

            public Vector4 TEXCOORD3
            {
                get
                {
                    return new Vector4(
                    TEXCOORD3_X,
                    TEXCOORD3_Y,
                    TEXCOORD3_Z,
                    TEXCOORD3_W);
                }
            }

            public Vector4 TEXCOORD4
            {
                get
                {
                    return new Vector4(
                    TEXCOORD4_X,
                    TEXCOORD4_Y,
                    TEXCOORD4_Z,
                    TEXCOORD4_W);
                }
            }

            public Vector4 TEXCOORD5
            {
                get
                {
                    return new Vector4(
                    TEXCOORD5_X,
                    TEXCOORD5_Y,
                    TEXCOORD5_Z,
                    TEXCOORD5_W);
                }
            }

            public Vector4 TEXCOORD6
            {
                get
                {
                    return new Vector4(
                    TEXCOORD6_X,
                    TEXCOORD6_Y,
                    TEXCOORD6_Z,
                    TEXCOORD6_W);
                }
            }

            public Vector4 TEXCOORD7
            {
                get
                {
                    return new Vector4(
                    TEXCOORD7_X,
                    TEXCOORD7_Y,
                    TEXCOORD7_Z,
                    TEXCOORD7_W);
                }
            }

            public Color COLOR0
            {
                get
                {
                    return new Color(
                    COLOR0_X,
                    COLOR0_Y,
                    COLOR0_Z,
                    COLOR0_W);
                }
            }
        }

        private const string GO_Parent_Name = "Models_From_CSV";

        // jave.lin : on_gui 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?婵犫偓鏉堚晛鍨濋柛顐ｇ贩濞诧拷?韫囨挻鍣烘繛鍛灪缁绘盯骞橀弶鎴炴儧闂佺ǹ瀛╅幐鎶姐€佸▎鎾崇疀闁哄娉�??闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵鍋撶€氾拷
        private TextAsset RDC_Text_Asset;
        private string fbxName;
        private string outputDir;
        private string outputFullName;

        // jave.lin : on_gui - options
        private Vector2 optionsScrollPos;
        private static bool options_show = true;
        private static bool is_from_DX_CSV = true;
        private static Vector3 vertexOffset = Vector3.zero;
        private static Vector3 vertexRotation = Vector3.zero;
        private static Vector3 vertexScale = Vector3.one;
        private static bool is_reverse_vertex_order = false; // jave.lin : for reverse normal
        private static bool is_recalculate_bound = true;
        private static SemanticMappingType semanticMappingType = SemanticMappingType.Default;
        private static bool has_uv0 = true;
        private static bool has_uv1 = false;
        private static bool has_uv2 = false;
        private static bool has_uv3 = false;
        private static bool has_uv4 = false;
        private static bool has_uv5 = false;
        private static bool has_uv6 = false;
        private static bool has_uv7 = false;
        private static bool has_color0 = false;
        private static bool useAutoMapping = false;
        private static bool useAllComponent = true;
        private ModelImporterNormals normalImportType = ModelImporterNormals.Import;
        private ModelImporterTangents tangentImportType = ModelImporterTangents.Import;
        private bool show_mat_toggle = true;
        private MaterialSetType materialSetType = MaterialSetType.CreateNew;
        private Shader shader;
        private Texture texture;
        private Material material;

        // jave.lin : helper 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵鍋撶€氾拷
        private Dictionary<string, SemanticType> semanticTypeDict_key_name_helper;
        private Dictionary<string, SemanticType> semanticManullyMappingTypeDict_key_name_helper;
        private static Dictionary<string, SemanticType> semanticManullyMappingTypeDict_Cache = new Dictionary<string, SemanticType>();


        private SemanticType[] semanticsIDX_helper;
        private int[] semantics_check_duplicated_helper;
        private List<string> stringListHelper;

        private int[] GetSemantics_check_duplicated_helper()
        {
            if (semantics_check_duplicated_helper == null)
            {
                var vals = Enum.GetValues(typeof(SemanticType));
                semantics_check_duplicated_helper = new int[vals.Length];
                for (int i = 0; i < vals.Length; i++)
                {
                    semantics_check_duplicated_helper[i] = 0;
                }
            }
            return semantics_check_duplicated_helper;
        }

        private void ClearSemantics_check_duplicated_helper(int[] arr)
        {
            if (arr != null)
            {
                Array.Clear(arr, 0, arr.Length);
            }
        }

        private List<string> GetStringListHelper()
        {
            if (stringListHelper == null)
            {
                stringListHelper = new List<string>();
            }
            return stringListHelper;
        }

        // jave.lin : 闂傚倷绀侀幉锛勬暜閻愬绠鹃柍锟�?闂備浇妗ㄩ悞锕傚箲閸ワ拷??妞ゆ帒瀚洿闂佺硶鍓�?婵犱胶澶勯梻鍌欑濠€杈ㄧ仚濠电偛妯婇崣鍐嚕?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨挾鍩ｉ柡宀嬬秮閸┾剝绻濋崒娑氫邯缂傚倸鍊哥粙鍕箯?+闂傚倷鑳堕崕鐢稿疾閳哄懎绐楅柡锟�?缂佽京鍋�?閵夛拷?鐎ｎ剙寮抽梻浣虹帛閺屻劑宕ョ€ｎ喖绠犲璺虹灱濡垶鏌℃径锟�?閻愵儷褔鏌ｆ惔銏ｅ缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰跨€碉拷?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔锯偓娲⒑閼测晛甯舵繛鏉戝槻閳藉鎮介崨濠勫弳闁诲函缍嗘禍鑸靛?
        private void DelectDir(string dir)
        {
            try
            {
                if (!Directory.Exists(outputDir))
                    return;

                DirectoryInfo dirInfo = new DirectoryInfo(dir);
                // 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕獮鍡涘礋?妞ゃ垺鐟╅幊鏍煛閸愶拷?闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰跨€碉拷?闂佽鍎�?閸濄儲鍤岄梻渚€娼ч敍蹇旀媴閹绘帊澹曢柣搴秵閸犳牜绮�?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺闁革拷?闁稿繑锕㈣棢闁规崘绉ú顏勭閻忕偠顔婂Ч妤呮⒑鐠恒劌娅愰柟锟�?
                FileSystemInfo[] fileInfos = dirInfo.GetFileSystemInfos();
                foreach (FileSystemInfo fileInfo in fileInfos)
                {
                    if (fileInfo is DirectoryInfo)
                    {
                        // 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅幖娣€戞禍褰掓煏婵炑冨?婵傚憡鍋℃繛鍡楃箰??濡炪倕绻愰悥鐓庮潖閾忚宕夐柕濞垮劜閻忓棗顪冮妶搴′簼妞ゃ劌锕ら悾宄扳枎閹炬緞褔鏌涢埄锟�?婵犱胶澶勯梻鍌氬€峰ù鍥р枖閺囥垹绐楃€广儱顦伴崵鎴﹀箹鏉堝墽绋婚柛蹇旂矒濮婃椽宕�?妞ゆ垵鎳�?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔锯偓楣冩⒑閸濓拷??妞ゎ厾鍏橀悰顔跨疀濞戞瑦娅㈤梺璺ㄥ櫐閹凤拷
                        DirectoryInfo subDir = new DirectoryInfo(fileInfo.FullName);
                        subDir.Delete(true);            // 闂傚倷绀侀幉锛勬暜閻愬绠鹃柍锟�?闂備浇妗ㄩ悞锕傚箲閸ワ拷??妞ゆ帒瀚洿闂佺硶鍓�?婵犱胶澶勯梻鍌氬€峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?濠碉紕鍋�??閻庢稈鏅濈划锝呂旈崘鈺佹瀾闂佺粯顨呴悧濠勭矆鐎ｎ喗鐓涘ù锝堫潐瀹曞瞼鈧拷?妞ゆ帒瀚洿闂佺硶鍓�?婵犱胶澶勯梻鍌氬€峰ù鍥р枖閺囥垹绐楃€广儱顦伴崵鎴﹀箹鏉堝墽绋婚柛蹇旂矒濮婃椽宕�?妞ゆ垵鎳�?韫囥儲瀚�
                    }
                    else
                    {
                        File.Delete(fileInfo.FullName);      // 闂傚倷绀侀幉锛勬暜閻愬绠鹃柍锟�?闂備浇妗ㄩ悞锕傚箲閸ワ拷??妞ゆ帒瀚洿闂佺硶鍓�?婵犱胶澶勯梻鍌欑濠€杈ㄧ仚濠电偛妯婇崣鍐嚕?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔锯偓娲⒑閼测晛甯舵繛鏉戝槻閳藉鎮介崨濠勫弳闁诲函缍嗘禍鑸靛?
                    }
                }
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕ら悾宄拔旈崨顓団晠鏌曟繛褍鎳庨弫鍫曟⒒閸屾瑦绁版繛澶嬫礋瀹曚即骞囬弶鍨殤婵犵數濮甸懝鍓х不?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵鍋撶€氾拷 闂備礁鎼�?鐏炶棄澹夐梺鍛婃尵閸犳牕顕�?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨碍纭鹃柍钘夘樀楠炴瑩宕�?閻庯拷? assets 闂傚倷鑳堕崕鐢稿疾閳哄懎绐楅柡锟�?缂佽京鍋�?閵夛拷?鐎ｎ剙寮抽梻浣虹帛閺屻劑宕ョ€ｎ喖绠犲璺虹灱濡垶鏌℃径锟�?閻愵儷褔鏌ｆ惔銏ｅ缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰跨€碉拷?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囥儲瀚�
        private string GetAssetPathByFullName(string fullName)
        {
            fullName = fullName.Replace("\\", "/");
            var dataPath_prefix = Application.dataPath.Replace("Assets", "");
            dataPath_prefix = dataPath_prefix.Replace(dataPath_prefix + "/", "");
            var mi_path = fullName.Replace(dataPath_prefix, "");
            return mi_path;
        }

        private void OnGUI()
        {
            Output_RDC_CSV_Handle();
        }

        /// <summary>
        /// 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滃┑鐐跺皺缁垶寮�?闂傚倷绀侀幉锟犲垂?闂佺ǹ锕ラ悧婊堝焵?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰跨€碉拷?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔锯偓楣冩煟閵忊晛鐏犻柣掳鍔�?閻撳海绠婚柟顔界懇?閹哄棗浜惧銈呯箰閻栫厧顫忛搹瑙勫磯闁靛ǹ鍎查悗楣冩⒑閸濓拷??妞ゎ厾鍏橀悰顔跨疀濞戞瑥鈧鏌ら幁鎺戝姕婵炲懌鍨介弻锝夋倷鐎电硶濮囧銈冨妼閻楀棝鍩㈤幘璇茬闁绘劕顕粔鍫曟⒑缂佹ê濮﹂柛鎾寸懇?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔锯偓楣冩⒑閸濓拷??妞ゎ厾鍏橀悰顔跨疀濞戞瑦娅㈤梺璺ㄥ櫐閹凤拷
        /// </summary>
        /// <param name="str">闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柡锟�?闁靛棔绀�?婵犲倻澧曠紒鈧崟顖涚厪闁割偅绻�?濡わ拷?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔锯偓楣冩⒑閸濓拷??妞ゎ厾鍏橀悰顔跨疀濞戞瑦娅㈤梺璺ㄥ櫐閹凤拷</param>
        /// <param name="substring">闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟锟�?闁猴拷?闁诲孩绋掕摫缂傚秴娲弻锝夊箛闂堟稑顫╁銈呴獜閹凤拷</param>
        /// <returns>闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閸嬬姵绻涢幋鐐垫噽婵炲牊蓱缁绘盯宕奸悢椋庝桓濠电偟鍘х换姗€骞冨▎锟�?閹哄棗浜惧銈呯箰閻栫厧顫忛搹瑙勫磯闁靛ǹ鍎查悗楣冩⒑閸濓拷??妞ゎ厾鍏橀悰顔跨疀濞戞瑦娅㈤梺璺ㄥ櫐閹凤拷</returns>
        static int SubstringCount(string str, string substring)
        {
            if (str.Contains(substring))
            {
                string strReplaced = str.Replace(substring, "");
                return (str.Length - strReplaced.Length) / substring.Length;
            }

            return 0;
        }

        bool IsEquals(string semantic, string target)
        {
            semantic = semantic.ToLower();
            string type, component;
            if (semantic.Contains("_x"))
            {
                type = semantic.Replace("_x", "");
                component = ".x";
            }
            else if (semantic.Contains("_y"))
            {
                type = semantic.Replace("_y", "");
                component = ".y";
            }
            else if (semantic.Contains("_z"))
            {
                type = semantic.Replace("_z", "");
                component = ".z";
            }
            else if (semantic.Contains("_w"))
            {
                type = semantic.Replace("_w", "");
                component = ".w";
            }
            else
            {
                type = semantic;
                component = semantic;
            }

            return target.Contains(type) && target.Contains(component);
        }

        SemanticType TryGetSemanticType(string str)
        {
            var lowStr = str.ToLower();
            foreach (SemanticType st in Enum.GetValues(typeof(SemanticType)))
            {
                if (IsEquals(st.ToString(), lowStr))
                {
                    return st;
                }
            }
            return SemanticType.Unknown;
        }


        private bool refresh_data = false;
        private bool csv_asset_changed = false;
        private void Output_RDC_CSV_Handle()
        {
            var new_textAsset = EditorGUILayout.ObjectField("RDC_CSV", RDC_Text_Asset, typeof(TextAsset), false) as TextAsset;

            // RDC_Text_Asset = EditorGUILayout.ObjectField("RDC_CSV", RDC_Text_Asset, typeof(TextAsset), false) as TextAsset;

            csv_asset_changed = false;
            if (RDC_Text_Asset != new_textAsset)
            {
                csv_asset_changed = true;
                RDC_Text_Asset = new_textAsset;
            }

            if (RDC_Text_Asset == null)
            {
                var srcCol = GUI.contentColor;
                GUI.contentColor = Color.red;
                EditorGUILayout.LabelField("Have no setting the RDC_CSV yet!");
                GUI.contentColor = srcCol;
                return;
            }

            if (refresh_data || csv_asset_changed)
            {
                material = null;
                semanticManullyMappingTypeDict_key_name_helper = null;
                if (refresh_data)
                {
                    semanticManullyMappingTypeDict_Cache.Clear();
                }
                ClearSemantics_check_duplicated_helper(semantics_check_duplicated_helper);
            }

            fbxName = EditorGUILayout.TextField("FBX Name", fbxName);
            if (RDC_Text_Asset != null && (refresh_data || csv_asset_changed || string.IsNullOrEmpty(fbxName)))
            {
                fbxName = GenerateGOName(RDC_Text_Asset);
            }

            // jave.lin : output path
            EditorGUILayout.BeginHorizontal();
            outputDir = EditorGUILayout.TextField("Output Path(Dir)", outputDir);
            if (refresh_data || csv_asset_changed || string.IsNullOrEmpty(outputDir))
            {
                // jave.lin : 闂傚倷鑳堕幊鎾诲床閺屻儱围闁归棿绀侀弸渚€鏌熼幑锟�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔锯偓楣冩⒑閸濓拷??妞ゎ厾鍏橀悰顔跨疀濞戞瑥鈧鏌ら幁鎺戝姕婵炲懌鍨藉娲传閸曨偀鍋撻崼鏇炵９闁猴拷?闁筹拷?婵拷?婵犫偓闁秴绠查柛锟�?妞ゃ垺鐩幃娆戔偓娑櫳�?閵忋倖鈷戦柛婵嗗閳ь剙鐖煎畷鎰板冀?闁筹拷?婵鍋撶€氾拷
                outputDir = Path.Combine(Application.dataPath, $"Models_From_CSV/{fbxName}");
                outputDir = outputDir.Replace("\\", "/");
            }
            if (GUILayout.Button("Browser...", GUILayout.Width(100)))
            {
                outputDir = EditorUtility.OpenFolderPanel("Select an output path", outputDir, "");
            }
            EditorGUILayout.EndHorizontal();
            // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?濠碉紕鍋�??缂併劎鍎ょ粋鎺戔槈閵忊檧鎷洪柣鐘充航閸斿矂寮搁幋锔界厸閻庯拷?妞ゎ厾鍏橀悰顔跨疀濞戞瑥鈧鏌ら幁鎺戝姕婵炲懌鍨藉娲传閸曨偀鍋撻崼鏇炵９闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺闁荤喐婢樺▓鈺呮煙閸戙倖瀚� full name
            GUI.enabled = false;
            outputFullName = Path.Combine(outputDir, fbxName + ".fbx");
            outputFullName = outputFullName.Replace("\\", "/");
            EditorGUILayout.TextField("Output Full Name", outputFullName);
            GUI.enabled = true;

            GUILayout.BeginHorizontal();
            {
                refresh_data = false;
                if (GUILayout.Button("Reset Settings"))
                {
                    refresh_data = true;
                }
                if (GUILayout.Button("Export FBX"))
                {
                    ExportHandle();
                }
            }
            GUILayout.EndHorizontal();

            // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?濠碉紕鍋�??缂併劎鍎ょ粋鎺楁晸? scroll view
            optionsScrollPos = EditorGUILayout.BeginScrollView(optionsScrollPos);

            // jave.lin : options 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵鍋撶€氾拷
            EditorGUILayout.Space(10);
            options_show = EditorGUILayout.BeginFoldoutHeaderGroup(options_show, "Model Options");
            if (options_show)
            {
                EditorGUI.indentLevel++;
                is_from_DX_CSV = EditorGUILayout.Toggle("Is From DirectX CSV", is_from_DX_CSV);
                is_reverse_vertex_order = EditorGUILayout.Toggle("Is Reverse Normal", is_reverse_vertex_order);
                is_recalculate_bound = EditorGUILayout.Toggle("Is Recalculate AABB", is_recalculate_bound);
                vertexOffset = EditorGUILayout.Vector3Field("Vertex Offset", vertexOffset);
                vertexRotation = EditorGUILayout.Vector3Field("Vertex Rotation", vertexRotation);
                vertexScale = EditorGUILayout.Vector3Field("Vertex Scale", vertexScale);
                // jave.lin : has_uv0,1,2,3,4,5,6,7
                has_uv0 = EditorGUILayout.Toggle("Has UV0", has_uv0);
                has_uv1 = EditorGUILayout.Toggle("Has UV1", has_uv1);
                has_uv2 = EditorGUILayout.Toggle("Has UV2", has_uv2);
                has_uv3 = EditorGUILayout.Toggle("Has UV3", has_uv3);
                has_uv4 = EditorGUILayout.Toggle("Has UV4", has_uv4);
                has_uv5 = EditorGUILayout.Toggle("Has UV5", has_uv5);
                has_uv6 = EditorGUILayout.Toggle("Has UV6", has_uv6);
                has_uv7 = EditorGUILayout.Toggle("Has UV7", has_uv7);
                // jave.lin : has_color0
                has_color0 = EditorGUILayout.Toggle("Has Color0", has_color0);
                normalImportType = (ModelImporterNormals)EditorGUILayout.EnumPopup("Normal Import Type", normalImportType);
                tangentImportType = (ModelImporterTangents)EditorGUILayout.EnumPopup("Tangent Import Type", tangentImportType);
                semanticMappingType = (SemanticMappingType)EditorGUILayout.EnumPopup("Semantic Mapping Type", semanticMappingType);
                if (semanticMappingType == SemanticMappingType.ManuallyMapping)
                {
                    var refreshCSVSemanticTitle = false;
                    if (GUILayout.Button("Refresh Analysis CSV Semantic Title"))
                    {
                        refreshCSVSemanticTitle = true;
                    }

                    if (semanticManullyMappingTypeDict_key_name_helper == null)
                    {
                        refreshCSVSemanticTitle = true;
                    }

                    if (refreshCSVSemanticTitle)
                    {
                        Analysis_CSV_SemanticTitle();
                    }

                    var keys = semanticManullyMappingTypeDict_key_name_helper.Keys;
                    var stringList = GetStringListHelper();
                    stringList.Clear();
                    stringList.AddRange(keys);

                    // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰跨€碉拷?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔锯偓楣冩⒑閸濓拷??妞ゎ厾鍏橀悰顔跨疀濞戞瑥鈧鏌ら幁鎺戝姕婵炲懌鍨藉娲传閸曨偀鍋撻崼鏇炵９闁猴拷?闁筹拷?婵ɑ鍓氬鎰磼鐎ｏ拷?閹邦剛鍔﹀銈嗗笒鐎氼參鎮￠妷鈺傜厽闁哄倹瀵ч崯鐐烘煟韫囷絽娅嶉柡宀€鍠栧畷娆撳Χ閸★拷??
                    stringList.Sort();

                    var check_duplicated_helper = GetSemantics_check_duplicated_helper();
                    for (int i = 0; i < stringList.Count; i++)
                    {
                        if (semanticManullyMappingTypeDict_key_name_helper.TryGetValue(stringList[i], out SemanticType mappedST))
                        {
                            var idx = (int)mappedST;
                            check_duplicated_helper[idx]++;
                        }
                    }

                    // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?濠碉紕鍋�??缂併劎鍎ょ粋鎺楁晸? semantic manually mapping data 闂傚倸鍊峰ù鍥р枖閺囥垹绐楃€广儱顦伴崵鎴﹀箹濞ｎ剙濡肩紒鐘茬－閹叉瓕绠涘☉妯溿儵鎮楅敐搴℃灈缂侊拷?闂備浇娉曢崳锕傚箯? 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備浇娉曢崳锕傚箯? title
                    EditorGUILayout.BeginHorizontal();
                    {
                        var src_col = GUI.contentColor;
                        GUI.contentColor = Color.yellow;
                        EditorGUILayout.LabelField("CSV Seman Name");
                        useAllComponent = EditorGUILayout.Toggle("鑷姩閫夋嫨鎵€鏈夊垎閲�", useAllComponent);
                        useAutoMapping = EditorGUILayout.Toggle("Auto Mapping", useAutoMapping);
                        GUI.contentColor = src_col;
                    }
                    EditorGUILayout.EndHorizontal();

                    // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?濠碉紕鍋�??缂併劎鍎ょ粋鎺楁晸? semantic manually mapping data 闂傚倸鍊峰ù鍥р枖閺囥垹绐楃€广儱顦伴崵鎴﹀箹濞ｎ剙濡肩紒鐘茬－閹叉瓕绠涘☉妯溿儵鎮楅敐搴℃灈缂侊拷?闂備浇娉曢崳锕傚箯?
                    for (int i = 0; i < stringList.Count; i++)
                    {
                        var semantic_name = stringList[i];
                        EditorGUILayout.BeginHorizontal();
                        EditorGUILayout.LabelField(semantic_name);


                        if (!semanticManullyMappingTypeDict_key_name_helper.TryGetValue(semantic_name, out SemanticType mappedST))
                        {
                            Debug.LogError($"un mapped semantic name : {semantic_name}");
                            continue;
                        }

                        if (useAutoMapping)
                        {
                            mappedST = TryGetSemanticType(semantic_name);
                        }
                        mappedST = (SemanticType)EditorGUILayout.EnumPopup(mappedST);

                        if (useAllComponent)
                        {
                            // 鍊煎彉鍖栨椂
                            if (mappedST != semanticManullyMappingTypeDict_key_name_helper[semantic_name])
                            {
                                SetAttrName(semantic_name, mappedST.ToString());
                                Debug.Log(1);
                            }
                            mappedST = TryGetSemanticType2(semantic_name,mappedST);
                        }


                        semanticManullyMappingTypeDict_key_name_helper[semantic_name] = mappedST;
                        StoreKeyDict();
                        if (check_duplicated_helper[(int)mappedST] > 1)
                        {
                            var src_col = GUI.contentColor;
                            GUI.contentColor = Color.red;
                            EditorGUILayout.LabelField("Duplicated Options");
                            GUI.contentColor = src_col;
                        }

                        EditorGUILayout.EndHorizontal();
                    }

                    ClearSemantics_check_duplicated_helper(check_duplicated_helper);
                }

                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndFoldoutHeaderGroup();

            // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柡锟�?闁挎繄鍋涜灃闁革拷?缂佲偓閸曨垱鐓忛柛顐ｇ箖?濡わ拷?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔句簴婵犵數鍋涢悧濠偯哄⿰鍫濈閻庯拷?闁瑰弶鎸冲畷鐔碱敃?濞村吋鎹囧缁樻媴閼恒儳銆婇梺鍝ュУ閸旀瑥顕ｉ崨濠勭瘈婵拷?缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰跨€碉拷?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囥儲瀚�
            EditorGUILayout.Space(10);
            show_mat_toggle = EditorGUILayout.BeginFoldoutHeaderGroup(show_mat_toggle, "Material Options");
            if (show_mat_toggle)
            {
                EditorGUI.indentLevel++;
                var newMaterialSetType = (MaterialSetType)EditorGUILayout.EnumPopup("Material Set Type", materialSetType);
                if (material == null || materialSetType != newMaterialSetType)
                {
                    materialSetType = newMaterialSetType;
                    // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵鍋撶€氾拷
                    if (materialSetType == MaterialSetType.CreateNew)
                    {
                        // jave.lin : shader 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵ɑ鍓氬鎰磼鐎ｏ拷?婵炴帗妞�?韫囨挻鍣烘繛鍛灲濮婃椽宕崟顐熷亾閸洖纾归柡锟�?闁筹拷?婵鍋撶€氾拷
                        if (shader == null)
                        {
                            shader = Shader.Find("Universal Render Pipeline/Lit");
                        }
                        material = new Material(shader);
                    }
                    else
                    {
                        // jave.lin : 婵狅拷?闁圭儤鎸鹃埊鏇㈡煥閺囨ê鐏茬€碉拷?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨碍纭鹃棁澶愭煥濠靛棙鍣洪柛瀣ㄥ劦閺屸剝鎷呯憴鍕３閻庯拷?妞ゆ帒瀚洿闂佺硶鍓�?婵犱胶澶� 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕獮鍡涘礋?妞ゃ垺鐟╅幊鏍煛閸愶拷?闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柡锟�?妤犵偞顨�?韫囨挻顥滈柡瀣墕?閵忥絾纭炬い鎴濇嚇?韫囥儲瀚� mat 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵鍋撶€氾拷
                        var mat_path = Path.Combine(outputDir, fbxName + ".mat").Replace("\\", "/");
                        mat_path = GetAssetPathByFullName(mat_path);
                        var mat_asset = AssetDatabase.LoadAssetAtPath<Material>(mat_path);
                        if (mat_asset != null) material = mat_asset;
                    }
                }

                if (materialSetType == MaterialSetType.CreateNew)
                {
                    // jave.lin : 婵犵數鍋犻幓顏嗗緤閽橈拷?绾绡€鐎碉拷?闂佺懓澧界划顖炲磿濡や降浜滈柟鎵虫櫅閳ь兙鍊濆鍐测堪閸喓鍘甸梺鍛婂灟閸婃牜鈧拷? shader
                    shader = EditorGUILayout.ObjectField("Shader", shader, typeof(Shader), false) as Shader;
                    // jave.lin : 婵犵數鍋犻幓顏嗗緤閽橈拷?绾绡€鐎碉拷?闂佺懓澧界划顖炲磿濡や降浜滈柟鎵虫櫅閳ь兙鍊濆鍐测堪閸喓鍘甸梺鍛婂灟閸婃牜鈧拷? 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺闁荤喐婢樺▓鈺呮煙閸戙倖瀚�
                    texture = EditorGUILayout.ObjectField("Main Texture", texture, typeof(Texture), false) as Texture;
                }
                // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵鍋撶€氾拷
                else // MaterialSetType.UseExsitMaterialAsset
                {
                    material = EditorGUILayout.ObjectField("Material Asset", material, typeof(Material), false) as Material;
                }

                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndFoldoutHeaderGroup();

            EditorGUILayout.EndScrollView();
        }


        private void StoreKeyDict()
        {
            semanticManullyMappingTypeDict_Cache.Clear();
            foreach (var item in semanticManullyMappingTypeDict_key_name_helper)
            {
                semanticManullyMappingTypeDict_Cache[item.Key] = item.Value;
            }
        }

        private Dictionary<string, string> attrNameDict;

        private void SetAttrName(string csvAttrName, string semanticName)
        {
            if (attrNameDict == null)
            {
                attrNameDict = new Dictionary<string, string>();
            }
            csvAttrName = csvAttrName.Split('.')[0];
            semanticName = semanticName.Split('_')[0];

            if (!attrNameDict.TryAdd(csvAttrName, semanticName))
            {
                attrNameDict[csvAttrName] = semanticName;
            }
        }

        SemanticType TryGetSemanticType2(string csvAttrName, SemanticType mappedST)
        {
            if (attrNameDict == null)
            {
                return mappedST;
            }

            var csvAttrNames = csvAttrName.Split('.');
            if (csvAttrNames.Length < 2) return mappedST;

            var componentName = csvAttrNames[1].ToUpper();
            if (attrNameDict.TryGetValue(csvAttrNames[0], out string semantic))
            {

                foreach (SemanticType type in Enum.GetValues(typeof(SemanticType)))
                {
                    var typeStr = type.ToString().ToUpper();
                    if (typeStr.Contains(semantic) && typeStr.Contains(componentName))
                    {
                        return type;
                    }
                }
            }
            return mappedST;
        }


        private void Analysis_CSV_SemanticTitle()
        {
            if (semanticManullyMappingTypeDict_key_name_helper != null)
            {
                semanticManullyMappingTypeDict_key_name_helper.Clear();
            }
            else
            {
                semanticManullyMappingTypeDict_key_name_helper = new Dictionary<string, SemanticType>();
            }
            var text = RDC_Text_Asset.text;
            var firstLine = text.Substring(0, text.IndexOf("\n")).Trim();
            var line_element_splitor = new string[] { "," };
            var semanticTitles = firstLine.Split(line_element_splitor, StringSplitOptions.RemoveEmptyEntries);

            MappingSemanticsTypeByNames(ref semanticTypeDict_key_name_helper);

            for (int i = 0; i < semanticTitles.Length; i++)
            {
                var title = semanticTitles[i];
                var semantics = title.Trim();
                if (semanticTypeDict_key_name_helper.TryGetValue(semantics, out SemanticType semanticType))
                {
                    semanticManullyMappingTypeDict_key_name_helper[semantics] = semanticType;
                }
                else
                {
                    // 璇诲彇缂撳瓨
                    if (semanticManullyMappingTypeDict_Cache.TryGetValue(semantics, out semanticType))
                    {
                        semanticManullyMappingTypeDict_key_name_helper[semantics] = semanticType;
                    }
                    else
                    {
                        semanticManullyMappingTypeDict_key_name_helper[semantics] = SemanticType.Unknown;
                    }
                }
            }
        }

        private void ExportHandle()
        {
            if (RDC_Text_Asset != null)
            {
                try
                {
                    MappingSemanticsTypeByNames(ref semanticTypeDict_key_name_helper);
                    var parent = GetParentTrans();
                    var outputGO = GameObject.Find($"{GO_Parent_Name}/{fbxName}");
                    if (outputGO != null)
                    {
                        GameObject.DestroyImmediate(outputGO);
                    }
                    outputGO = GenerateGOWithMeshRendererFromCSV(RDC_Text_Asset.text, is_from_DX_CSV);
                    outputGO.transform.SetParent(parent);
                    outputGO.name = fbxName;

                    if (!Directory.Exists(outputDir))
                    {
                        Directory.CreateDirectory(outputDir);
                    }

                    if (materialSetType == MaterialSetType.CreateNew)
                    {
                        var create_mat = outputGO.GetComponent<MeshRenderer>().sharedMaterial;
                        create_mat.mainTexture = texture;

                        var mat_created_path = Path.Combine(outputDir, fbxName + ".mat").Replace("\\", "/");
                        mat_created_path = GetAssetPathByFullName(mat_created_path);
                        Debug.Log($"mat_created_path : {mat_created_path}");
                        var src_mat = AssetDatabase.LoadAssetAtPath<Material>(mat_created_path);
                        if (src_mat == create_mat)
                        {
                            // nop
                        }
                        else
                        {
                            AssetDatabase.DeleteAsset(mat_created_path);
                            AssetDatabase.CreateAsset(create_mat, mat_created_path);
                        }
                    }

                    ModelExporter.ExportObject(outputFullName, outputGO);
                    AssetDatabase.SaveAssets();
                    AssetDatabase.Refresh();

                    string mi_path = GetAssetPathByFullName(outputFullName);
                    ModelImporter mi = ModelImporter.GetAtPath(mi_path) as ModelImporter;
                    mi.importNormals = normalImportType;
                    mi.importTangents = tangentImportType;
                    mi.importAnimation = false;
                    mi.importAnimatedCustomProperties = false;
                    mi.importBlendShapeNormals = ModelImporterNormals.None;
                    mi.importBlendShapes = false;
                    mi.importCameras = false;
                    mi.importConstraints = false;
                    mi.importLights = false;
                    mi.importVisibility = false;
                    mi.animationType = ModelImporterAnimationType.None;
                    mi.materialImportMode = ModelImporterMaterialImportMode.None;
                    mi.SaveAndReimport();

                    // jave.lin : replace outputGO from model prefab
                    var src_parent = outputGO.transform.parent;
                    var src_local_pos = outputGO.transform.localPosition;
                    var src_local_rot = outputGO.transform.localRotation;
                    var src_local_scl = outputGO.transform.localScale;
                    DestroyImmediate(outputGO);
                    // jave.lin : new model prefab
                    var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(mi_path);
                    outputGO = PrefabUtility.InstantiatePrefab(prefab) as GameObject;
                    outputGO.transform.SetParent(src_parent);
                    outputGO.transform.localPosition = src_local_pos;
                    outputGO.transform.localRotation = src_local_rot;
                    outputGO.transform.localScale = src_local_scl;
                    outputGO.name = fbxName;
                    // jave.lin : set material
                    var mat_path = Path.Combine(outputDir, fbxName + ".mat").Replace("\\", "/");
                    mat_path = GetAssetPathByFullName(mat_path);
                    var mat = AssetDatabase.LoadAssetAtPath<Material>(mat_path);
                    outputGO.GetComponent<MeshRenderer>().sharedMaterial = mat;
                    // jave.lin : new real prefab
                    var prefab_created_path = Path.Combine(outputDir, fbxName + ".prefab").Replace("\\", "/");
                    prefab_created_path = GetAssetPathByFullName(prefab_created_path);
                    Debug.Log($"prefab_created_path : {prefab_created_path}");
                    PrefabUtility.SaveAsPrefabAssetAndConnect(outputGO, prefab_created_path, InteractionMode.AutomatedAction);

                    // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闁诲海鎳撶€氼厼顭垮Ο鑲╃焾妞ゅ繐鐗婇埛鎴︽偣閹帒濡奸柡瀣灴閺岋紕鈧拷?妞ゎ厾鍏橀悰顔跨疀濞戞瑥鈧鏌ら幁鎺戝姕婵炲懌鍨藉娲传閸曨偀鍋撻崼鏇炵９闁猴拷?闁筹拷?婵拷?缂傚秴锕�??闁哄被鍎辩粻铏繆閵堝嫮鍔嶆繛鍛灲濮婃椽宕崟顐熷亾閸洖纾归柡锟�?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰跨€碉拷?闂佽鍎抽悺銊х礊閸ヮ剚鐓曢柟锟�?閻庣瑳鍛亾濮樼偓瀚�
                    Debug.Log($"Export FBX Successfully! outputPath : {outputFullName}");
                }
                catch (Exception er)
                {
                    Debug.LogError($"Export FBX Failed! er: {er}");
                }
            }
        }

        // jave.lin : 闂傚倷绀侀幖顐も偓锟�?婵犵數鍋愰崑鎾绘⒑鏉炴壆鍔嶉柟鐟版搐??妞ゆ帒瀚洿闂佺硶鍓�?婵犱胶澶� semantics 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備浇娉曢崳锕傚箯? name 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備浇娉曢崳锕傚箯? type
        private void MappingSemanticsTypeByNames(ref Dictionary<string, SemanticType> container)
        {
            if (container == null)
            {
                container = new Dictionary<string, SemanticType>();
            }
            else
            {
                container.Clear();
            }
            container["VTX"] = SemanticType.VTX;
            container["IDX"] = SemanticType.IDX;
            container["SV_POSITION.x"] = SemanticType.POSITION_X;
            container["SV_POSITION.y"] = SemanticType.POSITION_Y;
            container["SV_POSITION.z"] = SemanticType.POSITION_Z;
            container["SV_POSITION.w"] = SemanticType.POSITION_W;
            container["SV_Position.x"] = SemanticType.POSITION_X;
            container["SV_Position.y"] = SemanticType.POSITION_Y;
            container["SV_Position.z"] = SemanticType.POSITION_Z;
            container["SV_Position.w"] = SemanticType.POSITION_W;
            container["POSITION.x"] = SemanticType.POSITION_X;
            container["POSITION.y"] = SemanticType.POSITION_Y;
            container["POSITION.z"] = SemanticType.POSITION_Z;
            container["POSITION.w"] = SemanticType.POSITION_W;
            container["NORMAL.x"] = SemanticType.NORMAL_X;
            container["NORMAL.y"] = SemanticType.NORMAL_Y;
            container["NORMAL.z"] = SemanticType.NORMAL_Z;
            container["NORMAL.w"] = SemanticType.NORMAL_W;
            container["TANGENT.x"] = SemanticType.TANGENT_X;
            container["TANGENT.y"] = SemanticType.TANGENT_Y;
            container["TANGENT.z"] = SemanticType.TANGENT_Z;
            container["TANGENT.w"] = SemanticType.TANGENT_W;
            container["TEXCOORD0.x"] = SemanticType.TEXCOORD0_X;
            container["TEXCOORD0.y"] = SemanticType.TEXCOORD0_Y;
            container["TEXCOORD0.z"] = SemanticType.TEXCOORD0_Z;
            container["TEXCOORD0.w"] = SemanticType.TEXCOORD0_W;
            container["TEXCOORD1.x"] = SemanticType.TEXCOORD1_X;
            container["TEXCOORD1.y"] = SemanticType.TEXCOORD1_Y;
            container["TEXCOORD1.z"] = SemanticType.TEXCOORD1_Z;
            container["TEXCOORD1.w"] = SemanticType.TEXCOORD1_W;
            container["TEXCOORD2.x"] = SemanticType.TEXCOORD2_X;
            container["TEXCOORD2.y"] = SemanticType.TEXCOORD2_Y;
            container["TEXCOORD2.z"] = SemanticType.TEXCOORD2_Z;
            container["TEXCOORD2.w"] = SemanticType.TEXCOORD2_W;
            container["TEXCOORD3.x"] = SemanticType.TEXCOORD3_X;
            container["TEXCOORD3.y"] = SemanticType.TEXCOORD3_Y;
            container["TEXCOORD3.z"] = SemanticType.TEXCOORD3_Z;
            container["TEXCOORD3.w"] = SemanticType.TEXCOORD3_W;
            container["TEXCOORD4.x"] = SemanticType.TEXCOORD4_X;
            container["TEXCOORD4.y"] = SemanticType.TEXCOORD4_Y;
            container["TEXCOORD4.z"] = SemanticType.TEXCOORD4_Z;
            container["TEXCOORD4.w"] = SemanticType.TEXCOORD4_W;
            container["TEXCOORD5.x"] = SemanticType.TEXCOORD5_X;
            container["TEXCOORD5.y"] = SemanticType.TEXCOORD5_Y;
            container["TEXCOORD5.z"] = SemanticType.TEXCOORD5_Z;
            container["TEXCOORD5.w"] = SemanticType.TEXCOORD5_W;
            container["TEXCOORD6.x"] = SemanticType.TEXCOORD6_X;
            container["TEXCOORD6.y"] = SemanticType.TEXCOORD6_Y;
            container["TEXCOORD6.z"] = SemanticType.TEXCOORD6_Z;
            container["TEXCOORD6.w"] = SemanticType.TEXCOORD6_W;
            container["TEXCOORD7.x"] = SemanticType.TEXCOORD7_X;
            container["TEXCOORD7.y"] = SemanticType.TEXCOORD7_Y;
            container["TEXCOORD7.z"] = SemanticType.TEXCOORD7_Z;
            container["TEXCOORD7.w"] = SemanticType.TEXCOORD7_W;
            container["COLOR0.x"] = SemanticType.COLOR0_X;
            container["COLOR0.y"] = SemanticType.COLOR0_Y;
            container["COLOR0.z"] = SemanticType.COLOR0_Z;
            container["COLOR0.w"] = SemanticType.COLOR0_W;
            container["COLOR.x"] = SemanticType.COLOR0_X;
            container["COLOR.y"] = SemanticType.COLOR0_Y;
            container["COLOR.z"] = SemanticType.COLOR0_Z;
            container["COLOR.w"] = SemanticType.COLOR0_W;
        }

        // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闁诲海鎳撶€氼厼顭垮Ο鐓庣筏闁匡拷? parent transform 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵鍋撶€氾拷
        private Transform GetParentTrans()
        {
            var parentGO = GameObject.Find(GO_Parent_Name);
            if (parentGO == null)
            {
                parentGO = new GameObject(GO_Parent_Name);
                parentGO.transform.position = Vector3.zero;
                parentGO.transform.localRotation = Quaternion.identity;
                parentGO.transform.localScale = Vector3.one;
            }
            return parentGO.transform;
        }

        // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰跨€碉拷?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔锯偓楣冩⒑閸濓拷??妞ゎ厾鍏橀悰顔跨疀濞戞瑥鈧鏌ら幁鎺戝姕婵炲懌鍨藉娲传閸曨偀鍋撻崼鏇炵９闁猴拷?闁筹拷?婵鍋撶€氾拷 GO Name
        private string GenerateGOName(TextAsset ta)
        {
            //return $"From_CSV_{ta.text.GetHashCode()}";
            //return $"From_CSV_{ta.name}";
            return ta.name;
        }

        // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵鍋撶€氾拷 CSV 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰跨€碉拷?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囥儲瀚� MeshRenderer 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闁诲海鎳撶€氼厽绔熼崱娆屽亾閻燂拷?閹邦厸鎷洪柣鐘充航閸斿矂寮搁幋锔界厸閻庯拷?妞ゎ厾鍏橀悰顔跨疀濞戞瑦娅㈤梺璺ㄥ櫐閹凤拷 GO
        private GameObject GenerateGOWithMeshRendererFromCSV(string csv, bool is_from_DX_CSV)
        {
            var ret = new GameObject();

            var mesh = new Mesh();

            // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵鍋撶€氾拷 csv 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜為梺绋挎湰缁嬫垿顢�? mesh 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂傚倷绀侀悘婵嬵敄閸曨厽顫曢柨锟�?
            FillMeshFromCSV(mesh, csv, is_from_DX_CSV);

            var meshFilter = ret.AddComponent<MeshFilter>();
            meshFilter.sharedMesh = mesh;

            var meshRenderer = ret.AddComponent<MeshRenderer>();

            // jave.lin : 婵狅拷?闁圭儤鎸鹃埊鏇㈡煥閺囨ê鐏茬€碉拷?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨碍纭鹃棁澶愭煥濠靛棙鍣洪柛瀣ㄥ劦閺屸剝鎷呯憴鍕３閻庯拷?妞ゆ帒瀚洿闂佺硶鍓�?婵犱胶澶� URP 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備浇娉曢崳锕傚箯? PBR Shader
            meshRenderer.sharedMaterial = material;

            ret.transform.position = Vector3.zero;
            ret.transform.localRotation = Quaternion.identity;
            ret.transform.localScale = Vector3.one;

            return ret;
        }

        // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵鍋撶€氾拷 semantic type 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備浇娉曢崳锕傚箯? data 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵ǹ椴搁崵鈧梺瀹犳?閹邦厼鈧鏌涢妷锝呭妞わ拷? 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滃┑鐐跺皺缁垶寮�?闂備浇宕垫慨鍐裁归崶顒婄稏濠㈣泛澶囬崑鎾愁潩閻愵剙顏�
        private void FillVertexFieldInfo(VertexInfo info, SemanticType semanticType, string data, bool is_from_DX_CSV)
        {
            switch (semanticType)
            {
                // jave.lin : VTX
                case SemanticType.VTX:
                    info.VTX = int.Parse(data);
                    break;

                // jave.lin : IDX
                case SemanticType.IDX:
                    info.IDX = int.Parse(data);
                    break;

                // jave.lin : position
                case SemanticType.POSITION_X:
                    info.POSITION_X = float.Parse(data);
                    break;
                case SemanticType.POSITION_Y:
                    info.POSITION_Y = float.Parse(data);
                    break;
                case SemanticType.POSITION_Z:
                    info.POSITION_Z = float.Parse(data);
                    break;
                case SemanticType.POSITION_W:
                    info.POSITION_W = float.Parse(data);
                    Debug.LogWarning("WARNING: unity mesh cannot transfer position.w to shader program.");
                    break;

                // jave.lin : normal
                case SemanticType.NORMAL_X:
                    info.NORMAL_X = float.Parse(data);
                    break;
                case SemanticType.NORMAL_Y:
                    info.NORMAL_Y = float.Parse(data);
                    break;
                case SemanticType.NORMAL_Z:
                    info.NORMAL_Z = float.Parse(data);
                    break;
                case SemanticType.NORMAL_W:
                    info.NORMAL_W = float.Parse(data);
                    break;

                // jave.lin : tangent
                case SemanticType.TANGENT_X:
                    info.TANGENT_X = float.Parse(data);
                    break;
                case SemanticType.TANGENT_Y:
                    info.TANGENT_Y = float.Parse(data);
                    break;
                case SemanticType.TANGENT_Z:
                    info.TANGENT_Z = float.Parse(data);
                    break;
                case SemanticType.TANGENT_W:
                    info.TANGENT_W = float.Parse(data);
                    break;

                // jave.lin : texcoord0
                case SemanticType.TEXCOORD0_X:
                    info.TEXCOORD0_X = float.Parse(data);
                    break;
                case SemanticType.TEXCOORD0_Y:
                    info.TEXCOORD0_Y = float.Parse(data);
                    if (is_from_DX_CSV) info.TEXCOORD0_Y = 1 - info.TEXCOORD0_Y;
                    break;
                case SemanticType.TEXCOORD0_Z:
                    info.TEXCOORD0_Z = float.Parse(data);
                    break;
                case SemanticType.TEXCOORD0_W:
                    info.TEXCOORD0_W = float.Parse(data);
                    break;

                // jave.lin : texcoord1
                case SemanticType.TEXCOORD1_X:
                    info.TEXCOORD1_X = float.Parse(data);
                    break;
                case SemanticType.TEXCOORD1_Y:
                    info.TEXCOORD1_Y = float.Parse(data);
                    if (is_from_DX_CSV) info.TEXCOORD1_Y = 1 - info.TEXCOORD1_Y;
                    break;
                case SemanticType.TEXCOORD1_Z:
                    info.TEXCOORD1_Z = float.Parse(data);
                    break;
                case SemanticType.TEXCOORD1_W:
                    info.TEXCOORD1_W = float.Parse(data);
                    break;

                // jave.lin : texcoord2
                case SemanticType.TEXCOORD2_X:
                    info.TEXCOORD2_X = float.Parse(data);
                    break;
                case SemanticType.TEXCOORD2_Y:
                    info.TEXCOORD2_Y = float.Parse(data);
                    if (is_from_DX_CSV) info.TEXCOORD2_Y = 1 - info.TEXCOORD2_Y;
                    break;
                case SemanticType.TEXCOORD2_Z:
                    info.TEXCOORD2_Z = float.Parse(data);
                    break;
                case SemanticType.TEXCOORD2_W:
                    info.TEXCOORD2_W = float.Parse(data);
                    break;

                // jave.lin : texcoord3
                case SemanticType.TEXCOORD3_X:
                    info.TEXCOORD3_X = float.Parse(data);
                    break;
                case SemanticType.TEXCOORD3_Y:
                    info.TEXCOORD3_Y = float.Parse(data);
                    if (is_from_DX_CSV) info.TEXCOORD3_Y = 1 - info.TEXCOORD3_Y;
                    break;
                case SemanticType.TEXCOORD3_Z:
                    info.TEXCOORD3_Z = float.Parse(data);
                    break;
                case SemanticType.TEXCOORD3_W:
                    info.TEXCOORD3_W = float.Parse(data);
                    break;

                // jave.lin : texcoord4
                case SemanticType.TEXCOORD4_X:
                    info.TEXCOORD4_X = float.Parse(data);
                    break;
                case SemanticType.TEXCOORD4_Y:
                    info.TEXCOORD4_Y = float.Parse(data);
                    if (is_from_DX_CSV) info.TEXCOORD4_Y = 1 - info.TEXCOORD4_Y;
                    break;
                case SemanticType.TEXCOORD4_Z:
                    info.TEXCOORD4_Z = float.Parse(data);
                    break;
                case SemanticType.TEXCOORD4_W:
                    info.TEXCOORD4_W = float.Parse(data);
                    break;

                // jave.lin : texcoord5
                case SemanticType.TEXCOORD5_X:
                    info.TEXCOORD5_X = float.Parse(data);
                    break;
                case SemanticType.TEXCOORD5_Y:
                    info.TEXCOORD5_Y = float.Parse(data);
                    if (is_from_DX_CSV) info.TEXCOORD5_Y = 1 - info.TEXCOORD5_Y;
                    break;
                case SemanticType.TEXCOORD5_Z:
                    info.TEXCOORD5_Z = float.Parse(data);
                    break;
                case SemanticType.TEXCOORD5_W:
                    info.TEXCOORD5_W = float.Parse(data);
                    break;

                // jave.lin : texcoord6
                case SemanticType.TEXCOORD6_X:
                    info.TEXCOORD6_X = float.Parse(data);
                    break;
                case SemanticType.TEXCOORD6_Y:
                    info.TEXCOORD6_Y = float.Parse(data);
                    if (is_from_DX_CSV) info.TEXCOORD6_Y = 1 - info.TEXCOORD6_Y;
                    break;
                case SemanticType.TEXCOORD6_Z:
                    info.TEXCOORD6_Z = float.Parse(data);
                    break;
                case SemanticType.TEXCOORD6_W:
                    info.TEXCOORD6_W = float.Parse(data);
                    break;

                // jave.lin : texcoord7
                case SemanticType.TEXCOORD7_X:
                    info.TEXCOORD7_X = float.Parse(data);
                    break;
                case SemanticType.TEXCOORD7_Y:
                    info.TEXCOORD7_Y = float.Parse(data);
                    if (is_from_DX_CSV) info.TEXCOORD7_Y = 1 - info.TEXCOORD7_Y;
                    break;
                case SemanticType.TEXCOORD7_Z:
                    info.TEXCOORD7_Z = float.Parse(data);
                    break;
                case SemanticType.TEXCOORD7_W:
                    info.TEXCOORD7_W = float.Parse(data);
                    break;

                // jave.lin : color0
                case SemanticType.COLOR0_X:
                    info.COLOR0_X = float.Parse(data);
                    break;
                case SemanticType.COLOR0_Y:
                    info.COLOR0_Y = float.Parse(data);
                    break;
                case SemanticType.COLOR0_Z:
                    info.COLOR0_Z = float.Parse(data);
                    break;
                case SemanticType.COLOR0_W:
                    info.COLOR0_W = float.Parse(data);
                    break;
                case SemanticType.Unknown:
                    // jave.lin : nop
                    break;
                // jave.lin : un-implements
                default:
                    Debug.LogError($"Fill_A2V_Common_Type_Data un-implements SemanticType : {semanticType}");
                    break;
            }
        }

        // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵鍋撶€氾拷 csv 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜為梺绋挎湰缁嬫垿顢�? mesh 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂傚倷绀侀悘婵嬵敄閸曨厽顫曢柨锟�?
        private void FillMeshFromCSV(Mesh mesh, string csv, bool is_from_DX_CSV)
        {
            var line_splitor = new string[] { "\n" };
            var line_element_splitor = new string[] { "," };

            var lines = csv.Split(line_splitor, StringSplitOptions.RemoveEmptyEntries);

            // jave.lin : lines[0] == "VTX, IDX, POSITION.x, POSITION.y, POSITION.z, NORMAL.x, NORMAL.y, NORMAL.z, NORMAL.w, TANGENT.x, TANGENT.y, TANGENT.z, TANGENT.w, TEXCOORD0.x, TEXCOORD0.y"

            // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵鍋撶€氾拷 vertex buffer format 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備浇娉曢崳锕傚箯? semantics 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備浇娉曢崳锕傚箯? idx 闂傚倸鍊峰ù鍥р枖閺囥垹绐楃€广儱顦伴崵鎴﹀箹鏉堝墽绋诲┑顖氥偢閹嘲鈻庤箛锟�??濡炪倕绻愰悥濂哥嵁閺嶎偀鍋撳☉娅虫垿藟閸儲鐓涘ù锝堫潐瀹曞瞼鈧拷?妞ゆ帒瀚洿闂佺硶鍓�?婵犱胶澶勭紓鍌氬€风欢锟犲垂娴犲绠柨锟�?
            var semanticTitles = lines[0].Split(line_element_splitor, StringSplitOptions.RemoveEmptyEntries);

            Dictionary<string, SemanticType> semantic_type_map_key_name;
            if (semanticMappingType == SemanticMappingType.Default)
            {
                semantic_type_map_key_name = semanticTypeDict_key_name_helper;
            }
            else
            {
                semantic_type_map_key_name = semanticManullyMappingTypeDict_key_name_helper;
            }

            semanticsIDX_helper = new SemanticType[semanticTitles.Length];
            Debug.Log($"semanticTitles : {lines[0]}");
            for (int i = 0; i < semanticTitles.Length; i++)
            {
                var title = semanticTitles[i];
                var semantics = title.Trim();
                if (semantic_type_map_key_name.TryGetValue(semantics, out SemanticType semanticType))
                {
                    semanticsIDX_helper[i] = semanticType;
                    //Debug.Log($"semantics : {semantics}, type : {semanticType}");
                }
                else
                {
                    Debug.LogWarning($"un-implements semantic : {semantics}");
                }
            }

            // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柡锟�?濠德ゆ硾鐓ゆい蹇撴媼濡啴姊洪崘鍙夋儓闁稿﹥鎮�?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔锯偓楣冩⒑閸濓拷??妞ゎ厾鍏橀悰顔跨疀濞戞瑦娅㈤梺璺ㄥ櫐閹凤拷 IDX 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺闁荤喐婢樺Σ濠氭煕閵忥絽鐨洪柡锟�?闂佽法鍣﹂幏锟� vertex buffer 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺闁荤喐婢樺▓鈺呮煙閸戙倖瀚�
            // lines[1~count-1] : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撶喖鏌ㄥ┑鍡樺櫧闁绘帟娉曠槐鎺楀箟鐎ｎ偄顏� 0, 0,  0.0402, -1.57095E-17,  0.12606, -0.97949,  0.00, -0.20056,  0.00,  0.1098,  0.83691, -0.53613,  1.00, -0.06058,  0.81738

            Dictionary<int, VertexInfo> vertex_dict_key_idx = new Dictionary<int, VertexInfo>();

            var indices = new List<int>();

            var min_idx = int.MaxValue;
            for (int i = 1; i < lines.Length; i++)
            {
                var line = lines[i];
                var linesElements = line.Split(line_element_splitor, StringSplitOptions.RemoveEmptyEntries);

                // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柡鍥╁枍缁诲棙銇勯幘璺盒ｉ柛蹇旂矒濮婃椽宕�?妞ゆ垵鎳�?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔锯偓楣冩⒑閸濓拷??妞ゎ厾鍏橀悰顔跨疀濞戞瑥鈧鏌ら幁鎺戝姕婵炲懌鍨藉娲传閸曨偀鍋撻崼鏇炵９闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰跨€碉拷?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔锯偓楣冩⒑閸濓拷??妞ゎ厾鍏橀悰顔跨疀濞戞瑥鈧鏌ら幁鎺戝姕婵炲懌鍨藉娲传閸曨偀鍋撻崼鏇炵９闁猴拷?闁筹拷?婵鍋撶€氾拷0~count-1)
                var idx = int.Parse(linesElements[1]);
                if (min_idx > idx)
                {
                    min_idx = idx;
                }
            }

            for (int i = 1; i < lines.Length; i++)
            {
                var line = lines[i];
                var linesElements = line.Split(line_element_splitor, StringSplitOptions.RemoveEmptyEntries);

                // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柡鍥╁枍缁诲棙銇勯幘璺盒ｉ柛蹇旂矒濮婃椽宕�?妞ゆ垵鎳�?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔锯偓楣冩⒑閸濓拷??妞ゎ厾鍏橀悰顔跨疀濞戞瑥鈧鏌ら幁鎺戝姕婵炲懌鍨藉娲传閸曨偀鍋撻崼鏇炵９闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰跨€碉拷?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔锯偓楣冩⒑閸濓拷??妞ゎ厾鍏橀悰顔跨疀濞戞瑥鈧鏌ら幁鎺戝姕婵炲懌鍨藉娲传閸曨偀鍋撻崼鏇炵９闁猴拷?闁筹拷?婵鍋撶€氾拷0~count-1)
                var idx = int.Parse(linesElements[1]) - min_idx;

                // jave.lin : indices 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰跨€碉拷?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔锯偓楣冩⒑閸濓拷??妞ゎ厾鍏橀悰顔跨疀濞戞瑥鈧鏌ら幁鎺戝姕婵炲懌鍨藉娲偡閹殿喚楔濡炪們鍎查幑鍥Υ閸岋拷?閺囨浜惧Δ鐘靛仜缁绘﹢骞冨⿰鍫熷殟闁靛闄�?閵忋倖鈷戦柛婵嗗閳ь剙鐖煎畷鎰板冀?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺闁荤喐婢樺▓鈺呮煙閸戙倖瀚�
                indices.Add(idx);

                // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜為梺绋挎湰缁嬫垿顢�? vertex 濠电姷鏁搁崑娑㈡儗婢跺本宕叉繝闈涱儏閺嬩線鏌熼幑锟�?閼碱剛鍘俊鐐€栭崝鎴﹀磿閼艰翰浜圭憸鏃堝蓟閻旓拷?鐎ｎ亪顎楅柛妯绘尦閺屸剝鎷呯憴鍕３閻庯拷?妞ゆ帒瀚洿闂佺硶鍓�?婵犱胶澶勯梻鍌氬€峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺闁革拷?闁哄苯顦妴鎺楀捶?缂侇喖顭烽幃娆撴倻濡厧寮抽梻浣虹帛閺屻劑骞夐敓鐘冲€舵い鏇楀亾闁哄瞼鍠庨悾锟犲级閹稿巩鈺佄旈悩闈涗沪闁圭懓娲濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰跨€碉拷?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囥儲瀚�
                if (!vertex_dict_key_idx.TryGetValue(idx, out VertexInfo info))
                {
                    info = new VertexInfo();
                    vertex_dict_key_idx[idx] = info;

                    // jave.lin : loop to fill the a2v field
                    for (int j = 0; j < linesElements.Length; j++)
                    {
                        var semanticType = semanticsIDX_helper[j];
                        FillVertexFieldInfo(info, semanticType, linesElements[j], is_from_DX_CSV);
                    }
                }
            }

            // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撶娀鎮楀☉娅亪鎮炵憴鍕箚闁圭粯甯�?娴煎宓侀煫鍥ㄧ⊕閸婂鏌ら幁鎺戝姕婵炲懌鍨藉娲传閸曨偀鍋撻崼鏇炵９闁猴拷?闁筹拷?婵ɑ鍓氬鎰箾绾板彉閭い銏☆殜瀹曠喖顢楁担锟�?閵忋倖鈷戦柛婵嗗閳ь剙鐖煎畷鎰板冀?闁筹拷?婵拷?缂傚秴锕幃浼搭敋閳ь剟鐛惔銊﹀殟闁靛闄�?閵忋倖鈷戦柛婵嗗閳ь剙鐖煎畷鎰板冀?闁筹拷?婵鍋撶€氾拷
            var rotation = Quaternion.Euler(vertexRotation);
            var TRS_mat = Matrix4x4.TRS(vertexOffset, rotation, vertexScale);
            // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柛婵勫劤绾惧ジ鏌￠崘鈺佺仴妤犵偞鐗滈幉鎼佸级濞嗙偓鈻堝Δ鐘靛仦閸ㄦ寧鎱ㄩ埀顒勬煏閸繃顥炴繛鍛灲濮婃椽宕崟顐熷亾閸洖纾归柡锟�?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰跨€碉拷?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨挾鍩ｉ柟顔惧厴瀵潙顫濇潏鈺冨床闂備浇妗ㄩ悞锕傚箲閸ワ拷??妞ゆ帒瀚洿闂佺硶鍓�?婵犱胶澶勯梻鍌氬€峰ù鍥р枖閺囥垹绐楅柡鍥ｆ閺嗘澘鈹戦悩顔肩伇婵炲绋撻埀顒佺煯閸楀啿顕�?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔锯偓楣冩⒑閸濓拷??妞ゎ厾鍏橀悰顔跨疀濞戞瑥鈧鏌ら幁鎺戝姕婵炲懌鍨藉娲传閸曨偀鍋撻崼鏇炵９闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜為梺绋挎湰缁嬫垿顢�? vertex scale 婵犵數鍋為崹鍫曞箰鐠囷拷?閻愭壆鐭欑€碉拷?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囥儲瀚� uniform scale 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜為梺绋挎湰缁嬫垿顢�?
            // ref : LearnGL - 11.5 - 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵鍋撶€氾拷04 - 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柛婵勫劤绾惧ジ鏌￠崘鈺佺仴妤犵偞甯炵槐鎺楊敊閹灝銉╂煙瀹勶拷??闁瑰弶鎸冲畷鐔碱敃?濞村吋鎹囧缁樻媴閼恒儳銆婇梺鍝ュУ閸旀瑥顕ｉ崨濠勭瘈婵拷?缂侊拷?闁诲海鎳撶€氼厼顭垮Ο鑲╃幓婵°倕鎳忛埛鎴︽偣閹帒濡奸柡瀣灴閺屾盯濡搁敂鍓х杽濡ょ姷鍋為崹鎸庢叏閳ь剟鏌曢崼婵囶棡婵炲懌鍨藉娲传閸曨偀鍋撻崼鏇炵９闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰跨€碉拷?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨挾鍩ｉ柡灞剧☉铻栭柛鎰╁妷閺嬪懘姊烘潪鎵妽闁圭懓娲顐﹀箻缂佹ɑ娅㈤梺璺ㄥ櫐閹凤拷
            // https://blog.csdn.net/linjf520/article/details/107501215
            var M_IT_mat = Matrix4x4.TRS(Vector3.zero, rotation, vertexScale).inverse.transpose;

            // jave.lin : composite the data 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰跨€碉拷?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔锯偓楣冩⒑閸濓拷??妞ゎ厾鍏橀悰顔跨疀濞戞瑥鈧鏌ら幁鎺戝姕婵炲懌鍨藉娲传閸曨偀鍋撻崼鏇炵９闁猴拷?闁筹拷?婵拷?婵犫偓闁秴绠熼柣妤€鐗忛悷褰掓煃瑜滈崜鐔奉嚕?闂佽宕�?閸欙拷?濮椻偓閺屾洟宕煎┑锟�?濡わ拷?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔锯偓楣冩⒑閸濓拷??妞ゎ厾鍏橀悰顔跨疀濞戞瑥鈧鏌ら幁鎺戝姕婵炲懌鍨藉娲传閸曨偀鍋撻崼鏇炵９闁猴拷?闁筹拷?婵拷?缂傚秴锕獮濠囨晸閻樿尙鍘搁梺鍛婁緱閸犳鈻嶉姀銈嗏拻濞达絿鎳�?閸℃稑鏋佸┑鐘崇閸嬫ɑ淇�?閻犲洤妯婇崵銈呪攽閻愬弶顥為柛鏃€娲�?韫囨挾鍩ｆ慨濠呮閹瑰嫰濡搁妷锔句簽婵＄偑鍊戦崹铏瑰垝鎼淬劌绐楀┑鐘插暙缁剁偤鎮楅敐搴濇喚濞村吋鎹囧缁樻媴閼恒儳銆婇梺闈╃秶缁犳捇鐛箛娑欐櫢闁匡拷? mesh闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備浇娉曢崳锕傚箯?
            var vertices = new Vector3[vertex_dict_key_idx.Count];
            var normals = new Vector3[vertex_dict_key_idx.Count];
            var tangents = new Vector4[vertex_dict_key_idx.Count];
            var uv = new Vector2[vertex_dict_key_idx.Count];
            var uv2 = new Vector2[vertex_dict_key_idx.Count];
            var uv3 = new Vector2[vertex_dict_key_idx.Count];
            var uv4 = new Vector2[vertex_dict_key_idx.Count];
            var uv5 = new Vector2[vertex_dict_key_idx.Count];
            var uv6 = new Vector2[vertex_dict_key_idx.Count];
            var uv7 = new Vector2[vertex_dict_key_idx.Count];
            var uv8 = new Vector2[vertex_dict_key_idx.Count];
            var color0 = new Color[vertex_dict_key_idx.Count];

            // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵鍋撶€氾拷 0~count 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵拷?缂傚秴锕濠氬Ω閳哄倸浜滈梺鍛婄☉閿曪附瀵奸崟顖涒拺鐟滅増甯╁Λ鎴︽煕韫囨棑鑰垮┑鈥崇摠閹棃濡搁敂鎯у汲闂備胶绮弻銊╁箟閿熺姵鍊舵い鏇楀亾闁哄瞼鍠�?鐎ｎ亪顎楅柛妯绘尦閺屸剝鎷呯憴鍕３閻庯拷?妞ゆ帒瀚洿闂佺硶鍓�?婵犱胶澶勯梻鍌氬€峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?濠碉紕鍋�??婵炲鍏橀幆宀冪疀濞戞瑢鎷洪柣鐘充航閸斿矂寮搁幋锔界厸閻庯拷?妞ゎ厾鍏橀悰顔跨疀濞戞瑧鍙嗛柣搴秵閸撴岸鎯侀弮鍫熲拻濞达綀濮ょ涵鍫曟煕閿濆繒鐣垫鐐茬箻閺佹捇鏁�? vertex 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵鍋撶€氾拷
            for (int idx = 0; idx < vertices.Length; idx++)
            {
                var info = vertex_dict_key_idx[idx];
                vertices[idx] = TRS_mat * info.POSITION_H;
                normals[idx] = M_IT_mat * info.NORMAL;
                tangents[idx] = info.TANGENT;
                uv[idx] = info.TEXCOORD0;
                uv2[idx] = info.TEXCOORD1;
                uv3[idx] = info.TEXCOORD2;
                uv4[idx] = info.TEXCOORD3;
                uv5[idx] = info.TEXCOORD4;
                uv6[idx] = info.TEXCOORD5;
                uv7[idx] = info.TEXCOORD6;
                uv8[idx] = info.TEXCOORD7;
                color0[idx] = info.COLOR0;
            }

            // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴盯鏌涚仦涔咁亪鍩€?闁猴拷?闁筹拷?婵鍋撶€氾拷 mesh 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂傚倷绀侀悘婵嬵敄閸曨厽顫曢柨锟�?
            mesh.vertices = vertices;

            // jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柡锟�?闁挎繄鍋涜灃闁革拷?缂佲偓閸曨垱鐓忛柛顐ｇ箖?濡わ拷?韫囥儲瀚� reverse idx
            if (is_reverse_vertex_order) indices.Reverse();
            mesh.triangles = indices.ToArray();

            // jave.lin : unity 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闂備胶绮崹鍏兼叏閵堝鐤鹃柟闂寸劍閻撴稑顭跨捄锟�??妞ゃ儱顑嗛妵鍕箳閹捐泛寮ㄥΔ鐘靛仜缁绘﹢骞冨⿰鍫熷殟闁靛闄�?閵忋倖鈷戦柛婵嗗閳ь剙鐖煎畷鎰板冀?闁筹拷?婵鍋撶€氾拷 uv[0~7]
            mesh.uv = has_uv0 ? uv : null;
            mesh.uv2 = has_uv1 ? uv2 : null;
            mesh.uv3 = has_uv2 ? uv3 : null;
            mesh.uv4 = has_uv3 ? uv4 : null;
            mesh.uv5 = has_uv4 ? uv5 : null;
            mesh.uv6 = has_uv5 ? uv6 : null;
            mesh.uv7 = has_uv6 ? uv7 : null;
            mesh.uv8 = has_uv7 ? uv8 : null;

            mesh.colors = has_color0 ? color0 : null;

            // jave.lin : AABB
            if (is_recalculate_bound)
            {
                mesh.RecalculateBounds();
            }

            // jave.lin : NORMAL
            switch (normalImportType)
            {
                case ModelImporterNormals.None:
                    // nop
                    break;
                case ModelImporterNormals.Import:
                    mesh.normals = normals;
                    break;
                case ModelImporterNormals.Calculate:
                    mesh.RecalculateNormals();
                    break;
                default:
                    break;
            }

            // jave.lin : TANGENT
            switch (tangentImportType)
            {
                case ModelImporterTangents.None:
                    // nop
                    break;
                case ModelImporterTangents.Import:
                    mesh.tangents = tangents;
                    break;
                case ModelImporterTangents.CalculateLegacy:
                case ModelImporterTangents.CalculateLegacyWithSplitTangents:
                case ModelImporterTangents.CalculateMikk:
                    mesh.RecalculateTangents();
                    break;
                default:
                    break;
            }

            //// jave.lin : 闂傚倸鍊峰ù鍥р枖閺囥垹绐楅柟鐗堟緲閸戠姴鈹戦悩瀹犲缂侊拷?闁诲海鎳撶€氼厼顭垮Ο鑲╃焾妞ゅ繐瀚уΣ鍫ユ煙缂併垹鐏犲ù婊堢畺濮婄粯鎷呴懞銉с€婇梺鍝ュУ閸旀瑥顕ｉ崨濠勭瘈婵拷?缂侊拷?闂備浇娉曢崳锕傚箯?
            //Debug.Log("FillMeshFromCSV done!");
        }
    }
}
