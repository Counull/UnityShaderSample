Shader "Custom/test"
{
   
    SubShader
    {
     
    Pass{

        CGPROGRAM
     
        #pragma target 3.0
        #pragma fragment frag
       #pragma vertex vert 


        float4 vert(float4 v:POSITION) :SV_POSITION {
                 return UnityObjectToClipPos(v);
            }

            fixed4 frag():SV_TARGET {
                return fixed4 (cross( fixed3(0, 0,1) ,fixed3(1,0,5)),1);
            }
        ENDCG
        }
    }
   
}
