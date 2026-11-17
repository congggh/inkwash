// 《留白》序章动画资源 · 一键重建工具
// 菜单：Tools > InkWash > Rebuild Animation Assets
// 作用：扫描 Sprites 文件夹，按 manifest.json 生成 120FPS 的 AnimationClip 与 AnimatorController。
// 若手写的 .anim 因 Unity 版本差异导入异常，运行本脚本即可自动重建全部动画资源。
#if UNITY_EDITOR
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.Animations;
using UnityEngine;

namespace InkWashAnim
{
    [System.Serializable]
    public class AnimDef
    {
        public string character;
        public string name;
        public bool loop;
        public int frameCount;
        public float perFrameMs;
        public float durationMs;
        public int sourceFrames;
    }

    [System.Serializable]
    public class AnimManifest
    {
        public int sampleRate;
        public List<AnimDef> animations;
    }

    public static class InkWashAnimationSetup
    {
        const float SampleRate = 120f;
        const string Root = "Assets/InkWash_Animations";

        [MenuItem("Tools/InkWash/Rebuild Animation Assets")]
        public static void Rebuild()
        {
            string manifestPath = Root + "/manifest.json";
            if (!File.Exists(manifestPath))
            {
                Debug.LogError("[InkWash] manifest.json 未找到：" + manifestPath);
                return;
            }
            var manifest = JsonUtility.FromJson<AnimManifest>(File.ReadAllText(manifestPath));
            int built = 0;
            foreach (var group in manifest.animations.GroupBy(a => a.character))
            {
                BuildController(group.Key, group.ToList(), ref built);
            }
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            Debug.Log("[InkWash] 动画资源重建完成，共 " + built + " 个动画（120 FPS）。");
        }

        static void BuildController(string character, List<AnimDef> defs, ref int built)
        {
            string ctrlPath = Root + "/" + character + "/" + character + ".controller";
            var controller = AssetDatabase.LoadAssetAtPath<AnimatorController>(ctrlPath);
            if (controller == null)
                controller = AnimatorController.CreateAnimatorControllerAtPath(ctrlPath);
            var sm = controller.layers[0].stateMachine;
            foreach (var s in sm.states.ToList())
                sm.RemoveState(s.state);
            foreach (var def in defs)
            {
                var clip = BuildClip(def);
                if (clip == null) continue;
                var state = sm.AddState(def.name);
                state.motion = clip;
                state.writeDefaultValues = false;
                built++;
            }
            if (defs.Count > 0)
                sm.defaultState = sm.states[0].state;
            EditorUtility.SetDirty(controller);
        }

        static AnimationClip BuildClip(AnimDef def)
        {
            string clipPath = Root + "/" + def.character + "/Clips/" + def.name + ".anim";
            var clip = AssetDatabase.LoadAssetAtPath<AnimationClip>(clipPath);
            if (clip == null)
            {
                clip = new AnimationClip();
                AssetDatabase.CreateAsset(clip, clipPath);
            }
            clip.frameRate = SampleRate;
            var sprites = LoadSprites(def);
            if (sprites.Count == 0) return null;
            var binding = EditorCurveBinding.PPtrCurve("", typeof(SpriteRenderer), "m_Sprite");
            float frameDur = 1f / SampleRate;
            var keys = new ObjectReferenceKeyframe[sprites.Count];
            for (int i = 0; i < sprites.Count; i++)
                keys[i] = new ObjectReferenceKeyframe { time = i * frameDur, value = sprites[i] };
            AnimationUtility.SetObjectReferenceCurve(clip, binding, keys);
            var settings = AnimationUtility.GetAnimationClipSettings(clip);
            settings.loopTime = def.loop;
            AnimationUtility.SetAnimationClipSettings(clip, settings);
            EditorUtility.SetDirty(clip);
            return clip;
        }

        static List<Sprite> LoadSprites(AnimDef def)
        {
            var list = new List<Sprite>();
            for (int i = 0; i < def.frameCount; i++)
            {
                string p = string.Format("{0}/{1}/Sprites/{2}/{2}_{3:D3}.png",
                    Root, def.character, def.name, i);
                var s = AssetDatabase.LoadAssetAtPath<Sprite>(p);
                if (s == null) Debug.LogWarning("[InkWash] 缺少精灵：" + p);
                else list.Add(s);
            }
            return list;
        }
    }
}
#endif
