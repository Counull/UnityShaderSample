Shader "Custom/WorldNormal"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" { }
        _BumpMap ("Normal map", 2D) = "bump" { }
        _BumpScale ("Bump Scale", Float) = 1.0
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Smoothness", Range(8.0, 256)) = 20
    }
    
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
         #pragma enable_d3d11_debug_symbols  
            #pragma vertex vert
            #pragma fragment frag
          
            #include "Lighting.cginc"
      
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            fixed4 _Specular;
            float _BumpScale;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
            };

            v2f vert(a2v v)
            {
                v2f o;
                
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                
                o.pos = UnityObjectToClipPos(v.vertex);
                
                fixed3 worldPos = UnityObjectToWorldDir(v.vertex);
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 tangentW = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, tangentW) * v.tangent.w;
                
                o.TtoW0 = float4(tangentW.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(tangentW.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(tangentW.z, worldBinormal.z, worldNormal.z, worldPos.z);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {

                float3 worldPos =fixed3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);

                fixed3 LightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 ViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
            
          
                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                 bump.xy *= _BumpScale;
                bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
              
               bump =normalize(half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));
           //    fixed3x3 rotation = fixed3x3(i.TtoW0.xyz,i.TtoW1.xyz,i.TtoW2.xyz);
             //  bump=normalize( mul(rotation,bump));
               
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump,  LightDir));
                fixed3 halfDir = normalize( LightDir + ViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)), _Gloss);
                return fixed4(ambient + diffuse + specular, 1.0);
            }

            ENDCG

        }
    }
    FallBack "specular"
}
