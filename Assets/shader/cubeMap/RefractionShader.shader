// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/RefractionShader"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
          _RefractColor ("Refraction Color", Color) = (1, 1, 1, 1)
        _RefractAmount ("Refraction Amount", Range(0, 1)) = 1
         _RefractRatio("Refraction Ratio",Range(0.1,1))=0.5
        _Cubemap ("Reflect Cubemap", Cube) = "_Skybox" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM

            #pragma enable_d3d11_debug_symbols
            
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            
            fixed4 _Color;
            fixed4 _RefractColor;
            fixed _RefractAmount;
            fixed _RefractRatio;
            samplerCUBE _Cubemap;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldViewDir : TEXCOORD2;
                float3 worldRefr : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //unity_WorldToObject 向量要乘的矩阵是原矩阵逆的转置
                //mul(矩阵, 向量)改成mul(向量, 矩阵)相当于转置
                //Obj2World到World2Obj相当于逆
                
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                //     o.worldPos = UnityObjectToWorldDir(v.vertex).xyz;  这个被归一化了不能用
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.worldRefr = refract(-normalize(o.worldViewDir), normalize( o.worldNormal),_RefractRatio);

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
               
               //我会说这个东西它完全没有用可以注释掉嘛？
                fixed3 worldViewDir = normalize(i.worldViewDir);
                
                fixed3 diffuse = _LightColor0. rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));
                fixed3 refraction = texCUBE(_Cubemap, i.worldRefr).rgb *_RefractColor.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                
                return fixed4((ambient + lerp(diffuse, refraction, _RefractAmount) * atten), 1.0);
            }
            ENDCG

        }
    }
  	FallBack "Reflective/VertexLit"
}
