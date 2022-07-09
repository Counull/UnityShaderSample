using System;
using script.PostEffect;
using Unity.VisualScripting;
using UnityEngine;

namespace script.DepthNormal {
    public class FogWithDepthTexture : PostEffectBase {
        public Shader fogShader;
        private Material _fogMaterial = null;
        private Camera _myCamera;
        private Transform _myCameraTransform;
        [Range(0.0f, 3.0f)] public float fogDensity = 1.0f;
        public Color fogColor = Color.white;
        public float fogStart = 0.0f;
        public float fogEnd = 2.0f;
        [Range(-0.5f, 0.5f)] public float fogXSpeed = 0.1f;
        [Range(-0.5f, 0.5f)] public float fogYSpeed = 0.1f;
        [Range(-0.0f, 3.0f)] public float noiseAmount = 1.0f;
        public Texture noiseTex;

        private static readonly int FrustumCornersRay = Shader.PropertyToID("_FrustumCornersRay");
        private static readonly int FogDensity = Shader.PropertyToID("_FogDensity");
        private static readonly int FogColor = Shader.PropertyToID("_FogColor");
        private static readonly int FogStart = Shader.PropertyToID("_FogStart");
        private static readonly int FogEnd = Shader.PropertyToID("_FogEnd");
        private static readonly int NoiseTex = Shader.PropertyToID("_NoiseTex");
        private static readonly int FogXSpeed = Shader.PropertyToID("_FogXSpeed");
        private static readonly int FogYSpeed = Shader.PropertyToID("_FogYSpeed");
        private static readonly int NoiseAmount = Shader.PropertyToID("_NoiseAmount");

        public Material fogMaterial {
            get {
                _fogMaterial = CheckShaderAndCreateMaterial(fogShader, _fogMaterial);
                return _fogMaterial;
            }
        }

        private Camera myCamera {
            get {
                if (_myCamera == null) {
                    _myCamera = GetComponent<Camera>();
                }

                return _myCamera;
            }
        }

        public Transform myCameraTransform {
            get {
                if (_myCameraTransform == null) {
                    _myCameraTransform = myCamera.transform;
                }

                return _myCameraTransform;
            }
        }

        private void OnEnable() {
            myCamera.depthTextureMode |= DepthTextureMode.Depth;
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest) {
            if (fogMaterial == null) {
                Graphics.Blit(src, dest);
                return;
            }

            Matrix4x4 frustumCorners = Matrix4x4.identity;
            float fov = myCamera.fieldOfView;
            float near = myCamera.nearClipPlane;
            float far = myCamera.farClipPlane;
            float aspect = myCamera.aspect;

            float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
            Vector3 toTop = myCameraTransform.up * halfHeight;
            Vector3 toRight = myCameraTransform.right * halfHeight * aspect;

            var forward = myCameraTransform.forward;
            Vector3 topLeft = forward * near + toTop - toRight;
            float scale = topLeft.magnitude / near;

            topLeft.Normalize();
            topLeft *= scale;

            Vector3 topRight = forward * near + toRight + toTop;
            topRight.Normalize();
            topRight *= scale;

            Vector3 bottomLeft = forward * near - toTop - toRight;
            bottomLeft.Normalize();
            bottomLeft *= scale;

            Vector3 bottomRight = forward * near + toRight - toTop;
            bottomRight.Normalize();
            bottomRight *= scale;

            frustumCorners.SetRow(0, bottomLeft);
            frustumCorners.SetRow(1, bottomRight);
            frustumCorners.SetRow(2, topRight);
            frustumCorners.SetRow(3, topLeft);

            fogMaterial.SetMatrix(FrustumCornersRay, frustumCorners);

            fogMaterial.SetFloat(FogDensity, fogDensity);
            fogMaterial.SetColor(FogColor, fogColor);
            fogMaterial.SetFloat(FogStart, fogStart);
            fogMaterial.SetFloat(FogEnd, fogEnd);
            fogMaterial.SetTexture(NoiseTex,noiseTex);
            fogMaterial.SetFloat(FogXSpeed,fogXSpeed);
            fogMaterial.SetFloat(FogYSpeed,fogYSpeed);
            fogMaterial.SetFloat(NoiseAmount,noiseAmount);
             
                 
                    

            Graphics.Blit(src, dest, fogMaterial);
        }

        // Start is called before the first frame update
        void Start() { }

        // Update is called once per frame
        void Update() { }
    }
}