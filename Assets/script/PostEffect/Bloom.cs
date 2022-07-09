using UnityEngine;

namespace script.PostEffect
{
    public class Bloom : PostEffectBase
    {
        public Shader bloomShader;
        private Material _bloomMaterial;

        public Material BloomMaterial
        {
            get
            {
                _bloomMaterial = CheckShaderAndCreateMaterial(bloomShader, _bloomMaterial);
                return _bloomMaterial;
            }
        }

        [Range(0, 4)] public int iterations = 3;
        [Range(0.2f, 3.0f)] public float blurSpread = 0.6f;
        [Range(1, 8)] public int downSample = 2;
        [Range(0.0f, 4.0f)] public float luminanceThreshold = 0.6f;
        private static readonly int LuminanceThreshold = Shader.PropertyToID("_LuminanceThreshold");
        private static readonly int BlurSize = Shader.PropertyToID("_BlurSize");
        private static readonly int Bloom1 = Shader.PropertyToID("_Bloom");

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            if (BloomMaterial == null)
            {
                Graphics.Blit(src, dest);
                return;
            }

            BloomMaterial.SetFloat(LuminanceThreshold, luminanceThreshold);
            int rtW = src.width / downSample;
            int rtH = src.height / downSample;
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;
            Graphics.Blit(src, buffer0, BloomMaterial, 0);
            for (int i = 0; i < iterations; i++)
            {
                BloomMaterial.SetFloat(BlurSize, 1.0f + i * blurSpread);

                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(buffer0, buffer1, BloomMaterial, 1);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer0, buffer1, BloomMaterial, 2);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            BloomMaterial.SetTexture(Bloom1, buffer0);
            Graphics.Blit(src, dest, BloomMaterial, 3);
            RenderTexture.ReleaseTemporary(buffer0);
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