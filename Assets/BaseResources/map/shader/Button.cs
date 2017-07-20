using UnityEngine;
using System.Collections;

public class Button : MonoBehaviour
{

    public Texture img;
    private Texture img0;
    private string info;//显示的信息/  
    private int frameTime;//记录按下的时间/  
    MaterialPropertyBlock props;
    private Renderer myRenderer;

    void Start()
    {
        //初始化/  
        info = "请您点击按钮";
        frameTime = 0;
        props = new MaterialPropertyBlock();
        myRenderer = GetComponent<Renderer>();
    }

    void OnGUI()
    {
        //标签/  
        GUI.Label(new Rect(50, 10, 200, 20), info);
        //普通按钮，点击后显示Hello World  
        if (GUI.Button(new Rect(150, 100, 200, 20), "lyg设为0"))
        {
            //info = "Hello World";
            props.SetFloat("_ColliderForce", 0);
            myRenderer.SetPropertyBlock(props);
            info = "您点击了图片按钮,shewei0";
            Debug.Log("设置为0");
        }
        //标签/  
        //GUI.Label(new Rect(280, 10, 200, 200), img0);
        //图片按钮,点击后显示图片/  
        //if (GUI.Button(new Rect(280, 250, 200, 200), img))
        //{
        //    img0 = img;
            
        //    props.SetFloat("_ColliderForce", 1);
        //    myRenderer.SetPropertyBlock(props);
        //    info = "您点击了图片按钮,shewei1";
        //}
        //标签/  
        //GUI.Label(new Rect(500, 10, 200, 20), "持续按下的时间：" + frameTime);
        //连续按钮，点击后显示按下的时间/  
        if (GUI.Button(new Rect(380, 100, 200, 20), "lyg设为1"))
        {
            //frameTime++;
            props.SetFloat("_ColliderForce", 1);
            myRenderer.SetPropertyBlock(props);
            //info = "您点击了图片按钮,shewei1";
            info = "您按下了连续按钮,shewei0";
            Debug.Log("设置为1");

        }
        //每当鼠标按下时将frameTime重置，一遍进行下次记录/  
        if (Input.GetMouseButtonDown(0))
        {
            frameTime = 0;
        }
    }
}