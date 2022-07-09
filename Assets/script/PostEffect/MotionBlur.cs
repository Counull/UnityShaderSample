using System;
using UnityEngine;

namespace script.PostEffect
{
    public class MotionBlur : PostEffectBase
    {
        public Shader motionBlurShader;

        private Material _motionBlurMaterial;

        public Material motionBlurMaterial
        {
            get
            {
                _motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, _motionBlurMaterial);
                return _motionBlurMaterial;
            }
        }

        [Range(0.0f, 0.9f)] public float blurAmount = 0.5f;

        private RenderTexture _accumulationTexture;
        private static readonly int BlurAmount = Shader.PropertyToID("_BlurAmount");

        private void OnDisable()
        {
            DestroyImmediate(_accumulationTexture);
        }


        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            if (motionBlurMaterial == null)
            {
                Graphics.Blit(src, dest);
                return;
            }

            if (_accumulationTexture == null || _accumulationTexture.width != src.width ||
                _accumulationTexture.height != src.height)
            {
                DestroyImmediate(_accumulationTexture);
                _accumulationTexture = new RenderTexture(src.width, src.height, 0);
                _accumulationTexture.hideFlags = HideFlags.HideAndDontSave;
                Graphics.Blit(src, _accumulationTexture);
            }

            _accumulationTexture.MarkRestoreExpected();
            _motionBlurMaterial.SetFloat(BlurAmount, 1.0f - blurAmount);
            Graphics.Blit(src, _accumulationTexture, _motionBlurMaterial);
            Graphics.Blit(_accumulationTexture, dest);
        }

        // Start is called before the first frame update
        void Start()
        {
        }

        // Update is called once per frame
        void Update()
        {
        }
    }
}