using System;
using System.Collections;
using System.Collections.Generic;
using script.PostEffect;
using UnityEngine;

public class GaussianBlur : PostEffectBase
{
    public Shader gaussianBlurShader;

    private Material _gaussianBlurMaterial;

    public Material GaussianBlurMaterial
    {
        get
        {
            _gaussianBlurMaterial = CheckShaderAndCreateMaterial(gaussianBlurShader, _gaussianBlurMaterial);
            return _gaussianBlurMaterial;
        }
    }


    [Range(0, 20)] public int iterations = 3;
    [Range(0.2f, 200.0f)] public float blurSpread;
    [Range(1, 200)] public int downSample = 2;
    private static readonly int BlurSize = Shader.PropertyToID("_BlurSize");


    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (GaussianBlurMaterial != null)
        {
            int rtW = src.width / downSample;
            int rtH = src.height / downSample;

            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;
            Graphics.Blit(src, buffer0);

            for (int i = 0; i < iterations; i++)
            {
                _gaussianBlurMaterial.SetFloat(BlurSize, 1.0f + i * blurSpread);

                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(buffer0, buffer1, _gaussianBlurMaterial, 0);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer0, buffer1, _gaussianBlurMaterial, 1);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            Graphics.Blit(buffer0, dest);
            RenderTexture.ReleaseTemporary(buffer0);
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