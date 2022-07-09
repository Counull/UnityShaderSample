using UnityEngine;

namespace script.PostEffect
{
    public class EdgeDetection : PostEffectBase
    {
        public Shader edgeDetectShader;
        private Material _briSatConMaterial;

        public Material Material
        {
            get
            {
                _briSatConMaterial = CheckShaderAndCreateMaterial(edgeDetectShader, _briSatConMaterial);
                return _briSatConMaterial;
            }
        }

        [Range(0.0f, 1.0f)] public float edgesOnly = 0.0f;
        public Color edgeColor = Color.black;
        public Color backgroundColor = Color.white;
        private static readonly int EdgeOnly = Shader.PropertyToID("_EdgeOnly");
        private static readonly int EdgeColor = Shader.PropertyToID("_EdgeColor");
        private static readonly int BackgroundColor = Shader.PropertyToID("_BackgroundColor");

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            if (Material != null)
            {
                Material.SetFloat(EdgeOnly, edgesOnly);
                Material.SetColor(EdgeColor, edgeColor);
                Material.SetColor(BackgroundColor, backgroundColor);
                Graphics.Blit(src, dest, Material);
                return;
            }

            Graphics.Blit(src, dest);
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