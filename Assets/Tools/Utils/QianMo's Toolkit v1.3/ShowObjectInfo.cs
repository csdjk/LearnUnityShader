
//-----------------------------------------------【脚本说明】-------------------------------------------------------
//      脚本功能：    在场景中和游戏窗口中分别显示给任意物体附加的文字标签信息
//      使用语言：   C#
//      开发所用IDE版本：Unity4.5 06f 、Visual Studio 2010    
//      2014年10月 Created by 浅墨    
//      更多内容或交流，请访问浅墨的博客：http://blog.csdn.net/poem_qianmo
//---------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------【使用方法】-------------------------------------------------------
//      第一步：在Unity中拖拽此脚本到某物体之上，或在Inspector中[Add Component]->[浅墨's Toolkit v1.0]->[ShowObjectInfo]
//      第二步：在Inspector里,Show Object Info 栏中的TargetCamera参数中选择需面向的摄像机,如MainCamera
//      第三步：在text参数里填需要显示输出的文字。
//      第四步：完成。运行游戏或在场景编辑器Scene中查看显示效果。

//      PS：默认情况下文本信息仅在游戏运行时显示。
//      若需要在场景编辑时在Scene中显示，请勾选Show Object Info 栏中的[Show Info In Scene Editor]参数。
//      同理,勾选[Show Info In Game Play]参数也可以控制是否在游戏运行时显示文本信息
//---------------------------------------------------------------------------------------------------------------------


//预编译指令，检测到UNITY_EDITOR的定义，则编译后续代码
#if UNITY_EDITOR    


//------------------------------------------【命名空间包含部分】----------------------------------------------------
//  说明：命名空间包含
//----------------------------------------------------------------------------------------------------------------------
using UnityEngine;
using UnityEditor;
using System.Collections;

//添加组件菜单
[AddComponentMenu("浅墨's Toolkit v1.0/ShowObjectInfo")]

[ExecuteInEditMode]
//开始ShowObjectInfo类
public class ShowObjectInfo : MonoBehaviour
{

    //------------------------------------------【变量声明部分】----------------------------------------------------
    //  说明：变量声明部分
    //------------------------------------------------------------------------------------------------------------------
    public string text="键入你自己的内容 by浅墨";//文本内容
    public Camera TargetCamera;//面对的摄像机
    public bool ShowInfoInGamePlay = true;//是否在游戏运行时显示此信息框的标识符
    public bool ShowInfoInSceneEditor = false;//是否在场景编辑时显示此信息框的标识符
    private static GUIStyle style;//GUI风格



    //------------------------------------------【GUI 风格的设置】--------------------------------------------------
    //  说明：设定GUI风格
    //------------------------------------------------------------------------------------------------------------------
    private static GUIStyle Style
    {
        get
        {
            if (style == null)
            {
                //新建一个largeLabel的GUI风格
                style = new GUIStyle(EditorStyles.largeLabel);
                //设置文本居中对齐
                style.alignment = TextAnchor.MiddleCenter;
                //设置GUI的文本颜色
                style.normal.textColor = new Color(0.9f, 0.9f, 0.9f);
                //设置GUI的文本字体大小
                style.fontSize = 26;
            }
            return style;
        }

    }


    void Start()
    {
        TargetCamera = GameObject.FindWithTag("MainCamera").GetComponent<Camera>();
        if (!gameObject.GetComponent<Collider>())
        {
            gameObject.AddComponent<SphereCollider>();
        }
    }




    //-----------------------------------------【OnGUI()函数】-----------------------------------------------------
    // 说明：游戏运行时GUI的显示
    //------------------------------------------------------------------------------------------------------------------
    void OnGUI( )
    {
        //ShowInfoInGamePlay为真时，才进行绘制
        if (ShowInfoInGamePlay)
        {
            //---------------------------------【1.光线投射判断&计算位置坐标】-------------------------------
            //定义一条射线
            Ray ray = new Ray(transform.position + TargetCamera.transform.up * 6f, -TargetCamera.transform.up);
            //定义光线投射碰撞
            RaycastHit raycastHit;
            //进行光线投射操作,第一个参数为光线的开始点和方向，第二个参数为光线碰撞器碰到哪里的输出信息，第三个参数为光线的长度
            GetComponent<Collider>().Raycast(ray, out raycastHit, Mathf.Infinity);
            
            //计算距离，为当前摄像机位置减去碰撞位置的长度
            float distance = (TargetCamera.transform.position - raycastHit.point).magnitude;
            //设置字体大小，在26到12之间插值
            float fontSize = Mathf.Lerp(26, 12, distance / 10f);
            //将得到的字体大小赋给Style.fontSize
            Style.fontSize = (int)fontSize;
            //将文字位置取为得到的光线碰撞位置上方一点
            Vector3 worldPositon = raycastHit.point + TargetCamera.transform.up * distance * 0.03f;
            //世界坐标转屏幕坐标
            Vector3 screenPosition = TargetCamera.WorldToScreenPoint(worldPositon);
            //z坐标值的判断，z值小于零就返回
            if (screenPosition.z <= 0){return;}
            //翻转Y坐标值
            screenPosition.y = Screen.height - screenPosition.y;
            
            //获取文本尺寸
            Vector2 stringSize = Style.CalcSize(new GUIContent(text));
            //计算文本框坐标
            Rect rect = new Rect(0f, 0f, stringSize.x + 6, stringSize.y + 4);
            //设定文本框中心坐标
            rect.center = screenPosition - Vector3.up * rect.height * 0.5f;


            //----------------------------------【2.GUI绘制】---------------------------------------------
            //开始绘制一个简单的文本框
            Handles.BeginGUI();
            //绘制灰底背景
            GUI.color = new Color(0f, 0f, 0f, 0.8f);
            GUI.DrawTexture(rect, EditorGUIUtility.whiteTexture);
            //绘制文字
            GUI.color = new Color(1, 1, 1, 0.8f);
            GUI.Label(rect, text, Style);
            //结束绘制
            Handles.EndGUI();
        }
    }

    //-------------------------------------【OnDrawGizmos()函数】---------------------------------------------
    // 说明：场景编辑器中GUI的显示
    //------------------------------------------------------------------------------------------------------------------
    void OnDrawGizmos()
    {
        //ShowInfoInSeneEditor为真时，才进行绘制
        if (ShowInfoInSceneEditor)
        {
            //----------------------------------------【1.光线投射判断&计算位置坐标】----------------------------------
            //定义一条射线
            Ray ray = new Ray(transform.position + Camera.current.transform.up * 6f, -Camera.current.transform.up);
            //定义光线投射碰撞
            RaycastHit raycastHit;
            //进行光线投射操作,第一个参数为光线的开始点和方向，第二个参数为光线碰撞器碰到哪里的输出信息，第三个参数为光线的长度
            GetComponent<Collider>().Raycast(ray, out raycastHit, Mathf.Infinity);
            
            //计算距离，为当前摄像机位置减去碰撞位置的长度
            float distance = (Camera.current.transform.position - raycastHit.point).magnitude;
            //设置字体大小，在26到12之间插值
            float fontSize = Mathf.Lerp(26, 12, distance / 10f);
            //将得到的字体大小赋给Style.fontSize
            Style.fontSize = (int)fontSize;
            //将文字位置取为得到的光线碰撞位置上方一点
            Vector3 worldPositon = raycastHit.point + Camera.current.transform.up * distance * 0.03f;
            //世界坐标转屏幕坐标
            Vector3 screenPosition = Camera.current.WorldToScreenPoint(worldPositon);
            //z坐标值的判断，z值小于零就返回
            if (screenPosition.z <= 0) { return; }
            //翻转Y坐标值
            screenPosition.y = Screen.height - screenPosition.y;
            
            //获取文本尺寸
            Vector2 stringSize = Style.CalcSize(new GUIContent(text));
            //计算文本框坐标
            Rect rect = new Rect(0f, 0f, stringSize.x + 6, stringSize.y + 4);
            //设定文本框中心坐标
            rect.center = screenPosition - Vector3.up * rect.height * 0.5f;



            //----------------------------------【2.GUI绘制】---------------------------------------------
            //开始绘制一个简单的文本框
            Handles.BeginGUI();
            //绘制灰底背景
            GUI.color = new Color(0f, 0f, 0f, 0.8f);
            GUI.DrawTexture(rect, EditorGUIUtility.whiteTexture);
            //绘制文字
            GUI.color = new Color(1, 1, 1, 0.8f);
            GUI.Label(rect, text, Style);
            //结束绘制
            Handles.EndGUI();

        }

    }

}

//预编译命令结束
#endif
