Shader "Custom/rampShader"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _RampTex ("Ramp Tex", 2D) = "white" { }
        _Gloss ("Gloss", Range(8.0, 256)) = 20
        _Specular ("Specular", Color) = (1, 1, 1, 1)
    }
    SubShader
    {

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            // Physically based Standard lighting model, and enable shadows on all light types
            

            // Use shader model 3.0 target, to get nicer looking lighting
            
            fixed4 _Color;
            sampler2D _RampTex;
            float4 _RampTex_ST;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };
            
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = UnityObjectToWorldDir(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);
                return o;
            }
   fixed4 frag(v2f i):SV_TARGET{

            fixed3 worldNormal =normalize(i.worldNormal);
            fixed3 worldLightDir =normalize(UnityWorldSpaceLightDir(i.worldPos));
            //混合纹理与默认颜色  //反照率
         
            fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
            fixed halfLambert = 0.5*dot(worldNormal,worldLightDir)+0.5;

            fixed3 diffuse=  tex2D (_RampTex,fixed2( halfLambert,halfLambert)).rgb * _Color.rgb * _LightColor0;

           fixed3 viewDir = normalize( UnityWorldSpaceViewDir(i.worldPos));
            fixed3 halfDir =normalize (viewDir+worldLightDir);
            fixed3 specular = _LightColor0.rgb * _Specular.rgb *pow(max(0,dot(worldNormal,halfDir)),_Gloss);
            return fixed4(ambient+diffuse+specular,1.0);
        }
          
            ENDCG

        }
    }
    FallBack "Diffuse"
}
