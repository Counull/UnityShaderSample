Shader "Custom/SingelTexture"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" { }
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {

        Pass{
        Tags { "LightMode" = "ForwardBase" }
      
        CGPROGRAM

  #pragma enable_d3d11_debug_symbols  
        #pragma vertex vert
        #pragma fragment frag
        #include "Lighting.cginc"
        fixed4 _Color;
        fixed4 _Specular;
        sampler2D _MainTex;
        float4 _MainTex_ST;
        float _Gloss;
        
        struct a2v
        {
            float4 vertex:POSITION;
            float3 normal:NORMAL;
            float4 texcoord :TEXCOORD0;
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
        o.pos=UnityObjectToClipPos(v.vertex);
        o.worldNormal=UnityObjectToWorldNormal(v.normal);
            o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
        o.uv=TRANSFORM_TEX(v.texcoord,_MainTex );
        //o.uv=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
        
        return o;
        }

        fixed4 frag(v2f i):SV_TARGET{

            fixed3 worldNormal =normalize(i.worldNormal);
            fixed3 worldLightDir =normalize(UnityWorldSpaceLightDir(i.worldPos));
            //混合纹理与默认颜色  //反照率

            fixed3 albedo =tex2D(_MainTex,i.uv).rgb *_Color.rgb;

            fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;

            fixed3 diffuse=_LightColor0*albedo*max(0,dot(worldNormal,worldLightDir));

            fixed3 viewDir=normalize(UnityWorldSpaceViewDir(i.worldPos));

            fixed3 halfDir =normalize(worldLightDir+viewDir);

            fixed3 specular = _LightColor0.rgb * _Specular.rgb *pow(max(0,dot(worldNormal,halfDir)),_Gloss);

            return fixed4(ambient+diffuse+specular,1.0);
        }
        ENDCG

    }
    }
    FallBack "specular"
}
