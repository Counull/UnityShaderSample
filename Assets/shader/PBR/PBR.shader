// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PBR"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Albedo", 2D) = "white" {}
		_Glossiness ("Smoothess", Range(0.0, 1.0)) = 0.5
		_SpecularColor ("Specular", Color) = (0.2, 0.2, 0.2)
		_SpecGlossMap ("Specular (RGB) Smoothness (A)", 2D) = "white" {}
		_BumpScale ("Bump Scale", Float) = 1.0
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_EmissionColor ("Color", Color) = (0, 0, 0)
		_EmissionMap ("Emission", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 300

		Pass
		{
			Tags { "LightMode"="ForwardBase" }
			
			CGPROGRAM
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#include "HLSLSupport.cginc"
			
			#pragma target 3.0
			
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			
			#pragma vertex vert
			#pragma fragment frag
			
			#define UNITY_INV_PI 0.31830988618f
			
			fixed4 _Color;
			sampler2D _MainTex;
			fixed _Glossiness;
			fixed4 _SpecularColor;
			sampler2D _SpecGlossMap;
			float _BumpScale;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			fixed4 _EmissionColor;
			sampler2D _EmissionMap;
			
			float4 _MainTex_ST;
			float4 _SpecGlossMap_ST;
			float4 _EmissionMap_ST;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCOORD2;
				float4 TtoW2 : TEXCOORD3;
				SHADOW_COORDS(4)		//Defined in AutoLight.cginc
				UNITY_FOG_COORDS(5)		//Defined in UnityCG.cginc
			};
			
			v2f vert(a2v v) {
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);	//Defined in HLSLSupport.cginc
				
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);		//Defined in UnityCG.cginc
				
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
				
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);  
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);  
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  
				
				//We need this for shadow receving
				TRANSFER_SHADOW(o);		//Defined in AutoLight.cginc
				
				//We need this for fog rendering
				UNITY_TRANSFER_FOG(o, o.pos);	//Defined in UnityCG.cginc
				
				return o;
				
			}
			
			inline half3 CustomDisneyDiffuseTerm(half NdotV, half NdotL, half LdotH, half roughness, half3 baseColor) {
				half fd90 = 0.5 + 2 * LdotH * LdotH * roughness;
				
				//Two schlick fresnel term
				half lightScatter = (1 + (fd90 - 1) * pow(1 - NdotL, 5));
				half viewScatter = (1 + (fd90 - 1) * pow(1 - NdotV, 5));
				
				return baseColor * UNITY_INV_PI * lightScatter * viewScatter;
			}
			
			inline half CustomSmithJointGGXVisibilityTerm(half NdotL, half NdotV, half roughness) {
				//Original formulation
				//lambda_v = (-1 + sqrt(a2 * (1 - NdotL2) / NdotL2 + 1)) * 0.5f;
				//lambda_l = (-1 + sqrt(a2 * (1 - NdotV2) / NdotV2 + 1)) * 0.5f;
				//G = 1 / (1 + lambda_v + lambda_l);
				
				//Approximation of the above (simplify the sqrt, not mathematically correct but close enough)
				half a = roughness * roughness;
				half lambdaV = NdotL * (NdotV * (1 - a) + a);
				half lambdaL = NdotV * (NdotL * (1 - a) + a);
				
				return 0.5f / (lambdaV + lambdaL + 1e-5f);
				
			}
			
			inline half CustomGGXTerm(half NdotH, half roughness) {
				half a = roughness * roughness;
				half a2 = a * a;
				half d = (a2 - 1.0f) * NdotH * NdotH + 1.0f;
				return UNITY_INV_PI * a2 / (d * d + 1e-7f);
			}
			
			inline half3 CustomFresnelTerm(half3 c, half cosA) {
				half t = pow(1 - cosA, 5);
				return c + (1 - c) * t;
			}
			
			inline half3 CustomFresnelLerp(half3 c0, half3 c1, half cosA) {
				half t = pow(1 - cosA, 5);
				return lerp(c0, c1, t);
			}
			
			half4 frag(v2f i) : SV_Target {
				//Prepare all the inputs
				half4 specGloss = tex2D(_SpecGlossMap, i.uv);
				specGloss.a *= _Glossiness;
				half3 specColor = specGloss.rgb * _SpecularColor.rgb;
				half roughness = 1 - specGloss.a;
				
				half oneMinusReflectivity = 1 - max(max(specColor.r, specColor.g), specColor.b);
				
				half3 diffColor = _Color.rgb * tex2D(_MainTex, i.uv).rgb * oneMinusReflectivity;
				
				half3 normalTangent = UnpackNormal(tex2D(_BumpMap, i.uv));
				normalTangent.xy *= _BumpScale;
				normalTangent.z = sqrt(1.0 - saturate(dot(normalTangent.xy, normalTangent.xy)));
				half3 normalWorld = normalize(half3(dot(i.TtoW0.xyz, normalTangent), dot(i.TtoW1.xyz, normalTangent), dot(i.TtoW2.xyz, normalTangent)));
				
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				half3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));		//Defined in UnityCG.cginc
				half3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));		//Defined in UnityCG.cginc
				
				half3 reflDir = reflect(-viewDir, normalWorld);
				
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);		//Defined in AutoLight.cginc
				
				//Compute BRDF terms
				half3 halfDir = normalize(lightDir + viewDir);
				half nv = saturate(dot(normalWorld, viewDir));
				half nl = saturate(dot(normalWorld, lightDir));
				half nh = saturate(dot(normalWorld, halfDir));
				half lv = saturate(dot(lightDir, viewDir));
				half lh = saturate(dot(lightDir, halfDir));
				
				//Diffuse term
				half3 diffuseTerm = CustomDisneyDiffuseTerm(nv, nl, lh, roughness, diffColor);
				
				//Specular term
				half V = CustomSmithJointGGXVisibilityTerm(nl, nv, roughness);
				half D = CustomGGXTerm(nh, roughness * roughness);
				half3 F = CustomFresnelTerm(specColor, lh);
				half3 specularTerm = F * V * D;
				
				//Emission term
				half3 emisstionTerm = tex2D(_EmissionMap, i.uv).rgb * _EmissionColor.rgb;
				
				//IBL
				half perceptualRoughness = roughness * (1.7 - 0.7 * roughness);
				half mip = perceptualRoughness * 6;
				half4 envMap = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflDir, mip);		//Defined in HLSLSupport.cginc
				//Decode the 4 channels HDR data to RGB format. Otherwise the indirectLight will be too bright because the cube
				//map contains high dynamic range colors, which allows the values greater than 1.
				half3 decodeEnvMap = DecodeHDR(envMap, unity_SpecCube0_HDR);	//Defined in UnityCG.cginc
				half grazingTerm = saturate((1 - roughness) + (1 - oneMinusReflectivity));
				half surfaceReduction = 1.0 / (roughness * roughness + 1.0);
				half3 indirectSpecular = surfaceReduction * decodeEnvMap.rgb * CustomFresnelLerp(specColor, grazingTerm, nv);
				
				//Combine all togather
				half3 col = emisstionTerm + UNITY_PI * (diffuseTerm + specularTerm) * _LightColor0.rgb * nl * atten + indirectSpecular;
				
				UNITY_APPLY_FOG(i.fogCoord, c.rgb);		//Defined in UnityCG.cginc
				
				return half4(col, 1);
			}
			
			ENDCG
		}
	}
	FallBack Off
}