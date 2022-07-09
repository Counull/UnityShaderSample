using System;
using UnityEngine;
using UnityEngine.Serialization;

namespace script.PostEffect
{
    public class BrightnessSaturationAndContrast : PostEffectBase
    {
      
        private Material _briSatConMaterial;

        public Material Material
        {
            get
            {
                _briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader, _briSatConMaterial);
                return _briSatConMaterial;
            }
        }

        
        public Shader briSatConShader;
  
        [Range(0.0f, 3.0f)]
        public float brightness = 1.0f;
        [Range(0.0f, 3.0f)]
        public float saturation = 1.0f;
        [Range(0.0f, 3.0f)] 
        public float contrast = 1.0f;
        private static readonly int Contrast = Shader.PropertyToID("_Contrast");
        private static readonly int Saturation = Shader.PropertyToID("_Saturation");
        private static readonly int Brightness = Shader.PropertyToID("_Brightness");

        // Start is called before the first frame update

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            if (Material != null)
            {
                Material.SetFloat(Brightness, brightness);
                Material.SetFloat(Saturation, saturation);
                Material.SetFloat(Contrast, contrast);
                Graphics.Blit(src, dest, Material);
                return;
            }

            Graphics.Blit(src, dest);
        }

        void Start()
        {
        }

        // Update is called once per frame
        void Update()
        {
        }
    }
}