using UnityEditor;
using UnityEngine;

namespace ImageCutter
{
    [CustomEditor(typeof(ImageCutter))]
    public class ImageCutterEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            DrawDefaultInspector();

            ImageCutter imageCutter = (ImageCutter)target;
        
            if(GUILayout.Button("Cut Image")) 
            {
                imageCutter.Cut();
            }
        }
    }
}

