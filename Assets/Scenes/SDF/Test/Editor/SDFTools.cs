using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.UIElements;
using UnityEngine;
using UnityEngine.UIElements;
public class Pixel
{
    public bool isIn;
    public float distance;
}


public class SDFTools : EditorWindow
{

    [MenuItem("LcLTools/SDFTools")]
    private static void ShowWindow()
    {
        var window = GetWindow<SDFTools>();
        window.titleContent = new GUIContent("SDFTools");
        window.Show();
    }

    public void CreateGUI()
    {
        VisualElement root = rootVisualElement;

        var objectField = new ObjectField("Source")
        {
            objectType = typeof(Texture2D)
        };

        var outputSizeField = new Vector2IntField("Output Size")
        {
            value = new Vector2Int(64, 64)
        };



        var pathField = new TextField("Path")
        {
            value = "Assets/Scenes/SDF/Output/sdf.tga"
        };
        pathField.RegisterValueChangedCallback((evt) =>
        {
            Debug.Log(evt.newValue);
        });

        var button = new Button(() =>
        {
            Texture2D source = objectField.value as Texture2D;
            Vector2Int outputSize = outputSizeField.value;
            Texture2D destination = new Texture2D(outputSize.x, outputSize.y, TextureFormat.RGBA32, false);
            GenerateSDF(source, destination);
            // 判断文件夹是否存在
            string path = pathField.value;
            string folderPath = path.Substring(0, path.LastIndexOf('/'));
            if (!System.IO.Directory.Exists(folderPath))
            {
                System.IO.Directory.CreateDirectory(folderPath);
            }
            // 保存图片
            byte[] bytes = destination.EncodeToTGA();
            System.IO.File.WriteAllBytes(path, bytes);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        });

        root.Add(objectField);
        root.Add(outputSizeField);
        root.Add(pathField);
        root.Add(button);
    }

    private static Pixel[,] pixels;
    private static Pixel[,] targetPixels;


    public static void GenerateSDF(Texture2D source, Texture2D destination)
    {
        int sourceWidth = source.width;
        int sourceHeight = source.height;
        int targetWidth = destination.width;
        int targetHeight = destination.height;

        pixels = new Pixel[sourceWidth, sourceHeight];
        targetPixels = new Pixel[targetWidth, targetHeight];
        Debug.Log("sourceWidth" + sourceWidth);
        Debug.Log("sourceHeight" + sourceHeight);
        int x, y;
        Color targetColor = Color.white;
        for (y = 0; y < sourceWidth; y++)
        {
            for (x = 0; x < sourceHeight; x++)
            {
                pixels[x, y] = new Pixel();
                if (source.GetPixel(x, y) == Color.white)
                    pixels[x, y].isIn = true;
                else
                    pixels[x, y].isIn = false;
            }
        }


        int gapX = sourceWidth / targetWidth;
        int gapY = sourceHeight / targetHeight;
        int MAX_SEARCH_DIST = 512;
        int minx, maxx, miny, maxy;
        float max_distance = -MAX_SEARCH_DIST;
        float min_distance = MAX_SEARCH_DIST;

        for (x = 0; x < targetWidth; x++)
        {
            for (y = 0; y < targetHeight; y++)
            {
                targetPixels[x, y] = new Pixel();
                int sourceX = x * gapX;
                int sourceY = y * gapY;
                int min = MAX_SEARCH_DIST;
                minx = sourceX - MAX_SEARCH_DIST;
                if (minx < 0)
                {
                    minx = 0;
                }
                miny = sourceY - MAX_SEARCH_DIST;
                if (miny < 0)
                {
                    miny = 0;
                }
                maxx = sourceX + MAX_SEARCH_DIST;
                if (maxx > (int)sourceWidth)
                {
                    maxx = sourceWidth;
                }
                maxy = sourceY + MAX_SEARCH_DIST;
                if (maxy > (int)sourceHeight)
                {
                    maxy = sourceHeight;
                }
                int dx, dy, iy, ix, distance;
                bool sourceIsInside = pixels[sourceX, sourceY].isIn;
                if (sourceIsInside)
                {
                    for (iy = miny; iy < maxy; iy++)
                    {
                        dy = iy - sourceY;
                        dy *= dy;
                        for (ix = minx; ix < maxx; ix++)
                        {
                            bool targetIsInside = pixels[ix, iy].isIn;
                            if (targetIsInside)
                            {
                                continue;
                            }
                            dx = ix - sourceX;
                            distance = (int)Mathf.Sqrt(dx * dx + dy);
                            if (distance < min)
                            {
                                min = distance;
                            }
                        }
                    }

                    if (min > max_distance)
                    {
                        max_distance = min;
                    }
                    targetPixels[x, y].distance = min;
                }
                else
                {
                    for (iy = miny; iy < maxy; iy++)
                    {
                        dy = iy - sourceY;
                        dy *= dy;
                        for (ix = minx; ix < maxx; ix++)
                        {
                            bool targetIsInside = pixels[ix, iy].isIn;
                            if (!targetIsInside)
                            {
                                continue;
                            }
                            dx = ix - sourceX;
                            distance = (int)Mathf.Sqrt(dx * dx + dy);
                            if (distance < min)
                            {
                                min = distance;
                            }
                        }
                    }

                    if (-min < min_distance)
                    {
                        min_distance = -min;
                    }
                    targetPixels[x, y].distance = -min;
                }
            }
        }

        //EXPORT texture
        float clampDist = max_distance - min_distance;
        for (x = 0; x < targetWidth; x++)
        {
            for (y = 0; y < targetHeight; y++)
            {
                targetPixels[x, y].distance -= min_distance;
                float value = targetPixels[x, y].distance / clampDist;
                destination.SetPixel(x, y, new Color(value, 0, 0, 1));
            }
        }
    }
}
