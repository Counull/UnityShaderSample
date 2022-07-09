using System;
using UnityEngine;
using UnityEngine.Serialization;

namespace script.PostEffect
{
    public class MotionBlurWithDepthTexture : PostEffectBase
    {
        public Shader motionBlurMaterialShader = null;

        private Material _motionBlurMaterial;

        public Material motionBlurMaterial
        {
            get
            {
                _motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurMaterialShader, _motionBlurMaterial);
                return _motionBlurMaterial;
            }
        }

        private Camera _camera;

        public Camera mCamera
        {
            get
            {
                if (_camera == null)
                {
                    _camera = GetComponent<Camera>();
                }

                return _camera;
            }
        }

        private Matrix4x4 _previousViewProjectionMatrix;

        [Range(0.0f, 1.0f)] public float blurSize = 0.5f;
        private static readonly int BlurSize = Shader.PropertyToID("_BlurSize");
        private static readonly int PreviousViewProjectionMatrix = Shader.PropertyToID("_PreviousViewProjectionMatrix");

        private static readonly int CurrentViewProjectionInverseMatrix =
            Shader.PropertyToID("_CurrentViewProjectionInverseMatrix");

        private void OnEnable()
        {
            _camera.depthTextureMode |= DepthTextureMode.Depth;
            _previousViewProjectionMatrix = mCamera.projectionMatrix * mCamera.worldToCameraMatrix;
        }


        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            if (motionBlurMaterial == null)
            {
                Graphics.Blit(src, dest);
                return;
            }

            _motionBlurMaterial.SetFloat(BlurSize, blurSize);
            _motionBlurMaterial.SetMatrix(PreviousViewProjectionMatrix, _previousViewProjectionMatrix);
            Matrix4x4 currentViewProjectionMatrix = mCamera.projectionMatrix * mCamera.worldToCameraMatrix;
            Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse;
            _motionBlurMaterial.SetMatrix(CurrentViewProjectionInverseMatrix, currentViewProjectionInverseMatrix);
            _previousViewProjectionMatrix = currentViewProjectionMatrix;
            Graphics.Blit(src, dest, _motionBlurMaterial);
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