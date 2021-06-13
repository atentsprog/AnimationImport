using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Reflection;

public class EditorClipLister
{
    const string ExportAnimationFrame = "Assets/Export animation frame";
    const string ImportAnimationFrame = "Assets/Import animation frame";

    [MenuItem(ExportAnimationFrame, isValidateFunction: true)]
    static bool ValidateExportSelectedObjectsChildAnimationToTextInfo()
    {
        foreach (var item in Selection.objects)
        {
            if (AssetDatabase.GetAssetPath(item).EndsWith(".max"))
                return true;
        }

        return false;
    }

    [MenuItem(ExportAnimationFrame, false, 35)]
    static void ExportSelectedObjectsChildAnimationToTextInfo()
    {
        AssetDatabase.SaveAssets();

        foreach (Object obj in Selection.objects)
        {
            if (obj is GameObject == false)
                return;

            GameObject go = obj as GameObject;

            ExportSelectedObjectsChildAnimationToTextInfo(go);
        }

        Debug.Log("Finish exporting the selected object child animation to Text Info");

        AssetDatabase.Refresh();
    }
    [MenuItem(ImportAnimationFrame, false, 34)]
    static void RevertAnimationInfo()
    {
        foreach (Object obj in Selection.objects)
        {
            if (obj is GameObject == false)
                return;

            //obj
            string assetPath = AssetDatabase.GetAssetPath(obj);
            Debug.Log(assetPath);


            string dataParentPath = Application.dataPath.Replace("Assets", string.Empty);
            string animationInfoFileName = string.Format("{0}{1}AnimationInfo.txt", dataParentPath, AssetDatabase.GetAssetPath(obj));

            if (File.Exists(animationInfoFileName) == false)
                return;

            ModelImporter modelImporter = AssetImporter.GetAtPath(assetPath) as ModelImporter;
            modelImporter.importAnimation = true;
            Dictionary<string, ModelImporterClipAnimation> childAni = new Dictionary<string, ModelImporterClipAnimation>();
            foreach (var item in modelImporter.clipAnimations)
            {
                childAni[item.name] = item;
            }

            string[] reads = File.ReadAllLines(animationInfoFileName);

            for (int i = 0 ; i < reads.Length ; i++)
            {
                string[] word = reads[i].Split(',');

                if( word.Length != 3)
                {
                    Debug.Log(string.Format("word.Length != 3 , {0}", word.Length));
                    continue;
                }

                ModelImporterClipAnimation ani = null;
                string clipName = word[0];
                if (childAni.ContainsKey(word[0]))
                    ani = childAni[clipName];
                else
                {
                    ani = new ModelImporterClipAnimation();
                    ani.name = clipName;
                    childAni[clipName] = ani;
                }

                ani.firstFrame = float.Parse(word[1]);
                ani.lastFrame = float.Parse(word[2]);
            }
            List<ModelImporterClipAnimation> newList = new List<ModelImporterClipAnimation>(childAni.Values);
            modelImporter.clipAnimations = newList.ToArray();

            AssetDatabase.ImportAsset(assetPath);

            Debug.Log(string.Format("{0} import complete", obj.name ));
        }
    }

    [MenuItem(ImportAnimationFrame, isValidateFunction: true)]
    static bool ValidateImportSelectedObjectsChildAnimationToTextInfo()
    {
        foreach (var item in Selection.objects)
        {
            if(AssetDatabase.GetAssetPath(item).EndsWith(".max"))
                return true;
        }

        return false;
    }

    static void ExportSelectedObjectsChildAnimationToTextInfo(GameObject go)
    {
        if (go == null)
            return;

        string path = AssetDatabase.GetAssetPath(go);

        ModelImporter modelImporter = AssetImporter.GetAtPath(path) as ModelImporter;

        if(modelImporter == null)
            return;

        string dataParentPath = Application.dataPath.Replace("Assets", string.Empty);
        string animationInfoFileName = string.Format("{0}{1}AnimationInfo.txt", dataParentPath, AssetDatabase.GetAssetPath(go));


        List<string> contents = new List<string>();
        foreach (ModelImporterClipAnimation clipAnimations in modelImporter.clipAnimations)
        {
            string content = string.Format("{0},{1},{2}", clipAnimations.name, clipAnimations.firstFrame, clipAnimations.lastFrame);
            contents.Add( content);
        }


        File.WriteAllLines(animationInfoFileName, contents.ToArray());
    }
}
