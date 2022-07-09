Shader "Custom/ShadowWaterShader"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _Magnitude ("Distortion Magnitude", Float) = 1
        _Frequency ("Distortion Frequency", Float) = 1
        _InvWaveLength ("Distortion Inverse Wave Length", Float) = 10
        _Speed ("Speed", Float) = 0.5
    }
    SubShader
    {
        // Need to disable batching because of the vertex animation
    	Tags {"DisableBatching"="True"}
        Pass
        {
            Tags
            {
                "LightMode"="ForwardBase"
            }

           
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _Magnitude;
            float _Frequency;
            float _InvWaveLength;
            float _Speed;

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };


            v2f vert(a2v v)
            {
                v2f o;


                // offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;	
                float res = dot(v.vertex.xyz, float3(_InvWaveLength, _InvWaveLength, _InvWaveLength));
                float offset = sin(_Frequency * _Time.y + res) * _Magnitude;

                v.vertex.x += offset;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv += float2(0.0, _Time.y * _Speed);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex, i.uv.xy);
                c.rgb *= _Color.rgb;
                return c;
            }
            ENDCG
        }


        Pass
        {
           Tags { "LightMode" = "ShadowCaster" }
            CGPROGRAM
            #pragma enable_d3d11_debug_symbols

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"

         

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            float _Magnitude;
            float _Frequency;
            float _InvWaveLength;

            v2f vert(appdata_base  v)
            {
                v2f o;
                float res = dot(v.vertex.xyz, float3(_InvWaveLength, _InvWaveLength, _InvWaveLength));
                float offset = sin(_Frequency * _Time.y + res) * _Magnitude;

                v.vertex.x += offset;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return  o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG

        }
    }
    FallBack "VertexLit"
}