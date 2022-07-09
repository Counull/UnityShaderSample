using UnityEngine;

namespace script.PostEffect
{
    [ExecuteInEditMode]
    [RequireComponent(typeof(Camera))]
    public class PostEffectBase : MonoBehaviour
    {
        protected void CheckResources()
        {
            if (!CheckSupport())
            {
                enabled = false;
            }
        }


        private bool CheckSupport()
        {
            if (SystemInfo.supportsImageEffects != false && SystemInfo.supportsRenderTextures != false) return true;
            Debug.LogWarning("Not Support in " + this.ToString());
            return false;
        }


        protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
        {
            if (shader == null)
            {
                return null;
            }

            if (!shader.isSupported)
            {
                return null;
            }

            if (material && material.shader == shader)
            {
                return material;
            }

            material = new Material(shader)
            {
                hideFlags = HideFlags.DontSave
            };
            return material ? material : null;
        }

        // Start is called before the first frame update
        void Start()
        {
            CheckResources();
        }

        // Update is called once per frame
        void Update()
        {
        }
    }
}