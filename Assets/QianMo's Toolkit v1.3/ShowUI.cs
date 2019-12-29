//-----------------------------------------------【脚本说明】-------------------------------------------------------
//      脚本功能：   在游戏运行时显示简单的UI
//      使用语言：   C#
//      开发所用IDE版本：Unity4.5 06f 、Visual Studio 2010    
//      2014年10月 Created by 浅墨    
//      更多内容或交流，请访问浅墨的博客：http://blog.csdn.net/poem_qianmo
//---------------------------------------------------------------------------------------------------------------------

using UnityEngine;
using System.Collections;

//添加组件菜单
[AddComponentMenu("浅墨's Toolkit/ShowUI")]
public class ShowUI : MonoBehaviour
{
    public Texture2D midBottomPic;//用于修饰的横条

    void OnGUI()
    {
        if (midBottomPic)
        {
            //--------------------------【中下方横条的绘制】-------------------------
            GUI.DrawTexture(new Rect(Screen.width / 2 - midBottomPic.width / 2, 0, midBottomPic.width, midBottomPic.height), midBottomPic);
        }

    }
}
