Shader "Custom/ImageSequenceShader"
{
    Properties
    {
    
        _MainTex ("Base Layer", 2D) = "white" {}
        _DetailTex ("2nd Layer ", 2D) = "white" {}
        _ScrollX("Base Scrool Speed", float) = 1.0
        _Scroll2X ("2nd Scrool Speed", float) = 1.0
        _Multiplier ("Layer Multiplier", float) =1
    }
    SubShader
    {
        	Tags { "RenderType"="Opaque" "Queue"="Geometry"}
      
        Pass
        {
           	Tags { "LightMode"="ForwardBase" }
           
            CGPROGRAM
          
            #pragma enable_d3d11_debug_symbols
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "UnityCG.cginc"
          

           
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DetailTex;
            float4 _DetailTex_ST;
            float _ScrollX;
            float _Scroll2X;
            float _Multiplier;

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
            };


            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) +frac(float2 (_ScrollX,0.0)*_Time.y);
                o.uv.zw=TRANSFORM_TEX(v.texcoord, _DetailTex)+frac(float2 (_Scroll2X,0.0)*_Time.y);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 first =tex2D(_MainTex,i.uv.xy);
                fixed4 sec= tex2D(_DetailTex,i.uv.zw);
                fixed4 c = lerp(first,sec,sec.a);
                c.rgb *=_Multiplier;
                return c;
            }
            ENDCG
        }
    }
    FallBack "VertexLit"
}