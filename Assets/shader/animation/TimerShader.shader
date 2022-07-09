Shader "Custom/TimerShader"
{
  
    SubShader
    {
        Tags { "RenderType"="Opaque" }
    Pass{
        CGPROGRAM
     #pragma enable_d3d11_debug_symbols
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"

         float4 vert(float4 v:POSITION) :SV_POSITION {
            float3x3 M = float3x3(_Time.y,0.0f,0.0f,
                    0.0f,_Time.z,0.0f,
                    0.0f,0.0f,_Time.w);
             
             return UnityObjectToClipPos(mul (M,v));
            }

            fixed4 frag():SV_TARGET {
                return fixed4 (1,1,1,1);
            }
        ENDCG
        }
    }
    FallBack "Diffuse"
}
