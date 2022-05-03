using UnityEngine;
public class playerShadow : MonoBehaviour {
    public GameObject shadow;
    void Start () {
        if (!shadow) {
            return;
        }
        // 获取纹理并传递到shader
        var shadowMat = shadow.GetComponent<SpriteRenderer> ().material;
        var playerTex = GetComponent<SpriteRenderer> ().sprite.texture;
        shadowMat.SetTexture ("_PlayerTex", playerTex);
    }

}