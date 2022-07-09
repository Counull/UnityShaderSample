using script.PostEffect;
using UnityEngine;

namespace script.DepthNormal {
    public class EdgeDetectNormalsAndDepth : PostEffectBase {
        // Start is called before the first frame update
        public Shader edgeDetectShader;
        private Material _material;

        public Material material {
            get {
                _material = CheckShaderAndCreateMaterial(edgeDetectShader, _material);
                return _material;
            }
        }


        [Range(0.0f, 1.0f)] public float edgesOnly = 0.0f;
        public Color edgeColor = Color.black;
        public Color backgroundColor = Color.white;
        public float sampleDistance = 1.0f;
        public float sensitivityDepth = 1.0f;
        public float sensitivityNormals = 1.0f;
        private static readonly int EdgeOnly = Shader.PropertyToID("_EdgeOnly");
        private static readonly int EdgeColor = Shader.PropertyToID("_EdgeColor");
        private static readonly int BackgroundColor = Shader.PropertyToID("_BackgroundColor");
        private static readonly int SampleDistance = Shader.PropertyToID("_SampleDistance");
        private static readonly int Sensitivity = Shader.PropertyToID("_Sensitivity");

        private void OnEnable() {
            GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
        }

        [ImageEffectOpaque]
        private void OnRenderImage(RenderTexture src, RenderTexture dest) {
            if (material == null) {
                Graphics.Blit(src,dest);
                return;
            }
        
            material.SetFloat(EdgeOnly, edgesOnly);
            material.SetColor(EdgeColor, edgeColor);
            material.SetColor(BackgroundColor, backgroundColor);
            material.SetFloat(SampleDistance, sampleDistance);
            material.SetVector(Sensitivity, new Vector4(sensitivityNormals, sensitivityDepth, 0.0f, 0.0f));

            Graphics.Blit(src, dest, material);
        }

        void Start() { }

        // Update is called once per frame
        void Update() { }
    }
}