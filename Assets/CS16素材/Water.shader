// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Water"
{
	Properties
	{
		_ReflectionTex("ReflectionTex", 2D) = "white" {}
		_WaterNormnal("WaterNormnal", 2D) = "white" {}
		_NormalIntensity("NormalIntensity", Float) = 1
		_NormalTilling("NormalTilling", Float) = 8
		_NoisyIntensity("NoisyIntensity", Float) = 1
		_WaterSpeed("WaterSpeed", Float) = 1
		_SpecTint("SpecTint", Color) = (0.9240692,0.4056603,1,0)
		_SpecTintIntensity("SpecTintIntensity", Float) = 1
		_SpecStart("SpecStart", Float) = 0
		_SpecEnd("SpecEnd", Float) = 200
		_SpecSmoothness("SpecSmoothness", Range( 0.0001 , 1)) = 0.1
		_UnderWaterTex("UnderWaterTex", 2D) = "white" {}
		_UnderWaterTilling("UnderWaterTilling", Float) = 4
		_UnderwaterScale("UnderwaterScale", Float) = 1
		_WaterDepth("WaterDepth", Float) = -1
		_BlinkColor("BlinkColor", Color) = (0.9917453,0.9339622,1,0)
		_BlinkNoise("BlinkNoise", Float) = 1
		_BlinkTilling("BlinkTilling", Float) = 8
		_BlinkSpeed("BlinkSpeed", Float) = 1
		_BlinkIntensity("BlinkIntensity", Float) = 5
		_BlinkThreashold("BlinkThreashold", Float) = 2
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float3 viewDir;
			float4 screenPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _UnderWaterTex;
		uniform float _UnderWaterTilling;
		uniform sampler2D _WaterNormnal;
		uniform float _NormalTilling;
		uniform float _WaterSpeed;
		uniform float _NormalIntensity;
		uniform float _WaterDepth;
		uniform sampler2D _ReflectionTex;
		uniform float _NoisyIntensity;
		uniform float _BlinkTilling;
		uniform float _BlinkSpeed;
		uniform float _BlinkNoise;
		uniform float _BlinkThreashold;
		uniform float _BlinkIntensity;
		uniform float4 _BlinkColor;
		uniform float _UnderwaterScale;
		uniform float _SpecSmoothness;
		uniform float4 _SpecTint;
		uniform float _SpecTintIntensity;
		uniform float _SpecEnd;
		uniform float _SpecStart;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float2 temp_output_7_0 = ( (ase_worldPos).xz / _NormalTilling );
			float temp_output_13_0 = ( _Time.y * 0.1 * _WaterSpeed );
			float2 temp_output_26_0 = ( (( UnpackScaleNormal( tex2D( _WaterNormnal, ( temp_output_7_0 + temp_output_13_0 ) ), _NormalIntensity ) + UnpackScaleNormal( tex2D( _WaterNormnal, ( ( temp_output_7_0 * 1.5 ) + ( temp_output_13_0 * -1.0 ) ) ), _NormalIntensity ) )).xy * 0.5 );
			float dotResult28 = dot( temp_output_26_0 , temp_output_26_0 );
			float3 appendResult31 = (float3(temp_output_26_0 , sqrt( ( 1.0 - dotResult28 ) )));
			float3 WaterNormal33 = normalize( (WorldNormalVector( i , appendResult31 )) );
			float2 paralaxOffset93 = ParallaxOffset( 0 , _WaterDepth , i.viewDir );
			float4 UnderWaterColor80 = tex2D( _UnderWaterTex, ( ( (ase_worldPos).xz / _UnderWaterTilling ) + ( (WaterNormal33).xy * 0.1 ) + paralaxOffset93 ) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 unityObjectToClipPos37 = UnityObjectToClipPos( ase_vertex3Pos );
			float4 ReflectColor42 = tex2D( _ReflectionTex, ( (ase_screenPosNorm).xy + ( ( (WaterNormal33).xz / ( 1.0 + unityObjectToClipPos37.w ) ) * _NoisyIntensity ) ) );
			float2 temp_output_110_0 = ( (ase_worldPos).xz / _BlinkTilling );
			float temp_output_112_0 = ( _Time.y * 0.1 * _BlinkSpeed );
			float2 temp_output_123_0 = ( (( UnpackNormal( tex2D( _WaterNormnal, ( temp_output_110_0 + temp_output_112_0 ) ) ) + UnpackNormal( tex2D( _WaterNormnal, ( ( temp_output_110_0 * 1.5 ) + ( temp_output_112_0 * -1.0 ) ) ) ) )).xy * 0.5 );
			float dotResult124 = dot( temp_output_123_0 , temp_output_123_0 );
			float3 appendResult127 = (float3(temp_output_123_0 , sqrt( ( 1.0 - dotResult124 ) )));
			float3 WaterNormalBlink129 = normalize( (WorldNormalVector( i , appendResult127 )) );
			float4 temp_cast_0 = (4.0).xxxx;
			float4 ReflectBlink144 = pow( ( max( ( tex2D( _ReflectionTex, ( (ase_screenPosNorm).xy + ( (WaterNormalBlink129).xz * _BlinkNoise ) ) ).r - _BlinkThreashold ) , 0.0 ) * _BlinkIntensity * _BlinkColor ) , temp_cast_0 );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult84 = dot( ase_worldNormal , ase_worldViewDir );
			float clampResult85 = clamp( dotResult84 , 0.0 , 1.0 );
			float4 lerpResult87 = lerp( UnderWaterColor80 , ( ReflectColor42 + ReflectBlink144 ) , pow( ( 1.0 - clampResult85 ) , _UnderwaterScale ));
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult49 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult50 = dot( WaterNormal33 , normalizeResult49 );
			float clampResult73 = clamp( ( ( _SpecEnd - distance( ase_worldPos , _WorldSpaceCameraPos ) ) / ( _SpecEnd - _SpecStart ) ) , 0.0 , 1.0 );
			float4 SpecColor60 = ( ( pow( max( dotResult50 , 0.0 ) , ( _SpecSmoothness * 256.0 ) ) * _SpecTint * _SpecTintIntensity ) * clampResult73 );
			c.rgb = ( lerpResult87 + SpecColor60 ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 screenPos : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
1536;2;1284;796.3334;653.1012;155.124;1.138954;True;False
Node;AmplifyShaderEditor.CommentaryNode;102;-5430.835,-822.6777;Inherit;False;2719.134;745.0173;Comment;26;129;128;127;126;125;124;123;122;121;120;119;118;116;115;114;113;112;111;110;109;108;107;106;105;104;103;Blink;0.2999999,0.4349623,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;103;-5380.835,-768.678;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;105;-5322.201,-324.4839;Inherit;False;Constant;_Float7;Float 7;3;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;108;-5199.235,-772.6777;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-5303.234,-596.678;Inherit;False;Property;_BlinkTilling;BlinkTilling;18;0;Create;True;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;106;-5345.4,-406.084;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-5335.924,-250.2402;Inherit;False;Property;_BlinkSpeed;BlinkSpeed;19;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;-5060.607,-193.0605;Inherit;False;Constant;_Float9;Float 9;4;0;Create;True;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;110;-5040.036,-711.8779;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;-5090.201,-434.0841;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-5105.41,-539.2499;Inherit;False;Constant;_Float8;Float 8;4;0;Create;True;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;34;-2512.134,-809.0096;Inherit;False;2719.134;745.0173;Comment;27;15;26;28;29;30;31;32;33;27;25;4;19;100;10;24;21;20;13;23;7;22;6;8;11;12;14;5;;0.2999999,0.4349623,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-4799.949,-412.9922;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;-4799.949,-546.3774;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;5;-2462.134,-755.0099;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;115;-4621.766,-524.9952;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-2417.223,-236.5721;Inherit;False;Property;_WaterSpeed;WaterSpeed;6;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;11;-2426.7,-392.4159;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;6;-2280.535,-759.0096;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-2384.534,-583.0098;Inherit;False;Property;_NormalTilling;NormalTilling;4;0;Create;True;0;0;False;0;False;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-2403.5,-310.8158;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;116;-4625.521,-711.8152;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-2171.5,-420.416;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-2141.907,-179.3924;Inherit;False;Constant;_Float2;Float 2;4;0;Create;True;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;7;-2121.335,-698.2097;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;118;-4476.613,-552.8771;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Instance;4;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;119;-4489.521,-740.6152;Inherit;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;False;0;False;-1;fa6ddf2e9ef43f648826bea11bf9a4c9;fa6ddf2e9ef43f648826bea11bf9a4c9;True;0;False;white;Auto;True;Instance;4;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;22;-2186.709,-525.5818;Inherit;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-1881.248,-532.7092;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-1881.248,-399.3241;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;120;-4146.206,-735.1932;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-1706.821,-698.1471;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;24;-1703.065,-511.3271;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;121;-4000.363,-736.353;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-1776.656,-596.5662;Inherit;False;Property;_NormalIntensity;NormalIntensity;3;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-4155.265,-621.6699;Inherit;False;Constant;_Float10;Float 10;4;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-3837.777,-733.093;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;4;-1570.821,-726.9471;Inherit;True;Property;_WaterNormnal;WaterNormnal;1;0;Create;True;0;0;False;0;False;-1;fa6ddf2e9ef43f648826bea11bf9a4c9;fa6ddf2e9ef43f648826bea11bf9a4c9;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;19;-1557.912,-539.2089;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Instance;4;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-1227.505,-721.5251;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;124;-3688.367,-672.6746;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;125;-3558.23,-664.0109;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1236.564,-608.0018;Inherit;False;Constant;_Float3;Float 3;4;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;15;-1081.662,-722.6848;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SqrtOpNode;126;-3402.24,-670.3973;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-919.0759,-719.4248;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;127;-3271.515,-738.7349;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;28;-769.6666,-659.0065;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;29;-639.5292,-650.3428;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;128;-3119.222,-735.8008;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SqrtOpNode;30;-483.5394,-656.7292;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;129;-2936.5,-736.5588;Inherit;False;WaterNormalBlink;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;130;-4937.043,-47.35085;Inherit;False;2366.052;671.5231;Comment;17;151;150;144;155;152;143;149;142;141;140;139;138;135;133;159;160;161;ReflectColorBlink;0.7301887,1,0.8224763,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;133;-4890.179,243.9836;Inherit;False;129;WaterNormalBlink;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;-352.8148,-725.0668;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;139;-4772.17,24.24912;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;32;-200.5214,-722.1326;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;135;-4672.76,243.9834;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;138;-4710.305,392.2954;Inherit;False;Property;_BlinkNoise;BlinkNoise;17;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;44;-2496.967,-19.33478;Inherit;False;1763.3;590.5356;Comment;14;42;1;18;3;17;2;16;38;40;36;37;35;41;39;ReflectColor;0.7301887,1,0.8224763,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;-4491.319,245.7106;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;141;-4556.171,25.04911;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-17.79955,-722.8906;Inherit;False;WaterNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;61;-2510.258,615.762;Inherit;False;1563.749;736.5068;Comment;25;60;74;73;72;71;70;58;66;67;69;57;53;59;64;65;52;56;54;55;50;49;51;48;45;46;SpecColor;1,0.3075471,0.3075471,1;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;39;-2446.967,349.0332;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;37;-2266.167,349.0332;Inherit;False;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;46;-2460.258,822.6354;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;35;-2181.726,269.2601;Inherit;False;33;WaterNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;45;-2409.378,671.814;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;41;-2079.766,346.6331;Inherit;False;Constant;_Float4;Float 4;5;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;142;-4355.013,119.2875;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;96;-648.7366,684.9648;Inherit;False;1559.403;798.296;Comment;14;80;79;88;93;78;91;76;77;90;92;94;95;75;89;UnderWater;0.8716981,0.7016522,0.320719,1;0;0
Node;AmplifyShaderEditor.SamplerNode;143;-4204.394,-12.75045;Inherit;True;Property;_TextureSample3;Texture Sample 3;0;0;Create;True;0;0;False;0;False;-1;e29df72e292af63489146e06dfc79ae9;e29df72e292af63489146e06dfc79ae9;True;0;False;white;Auto;False;Instance;1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;149;-4110.144,204.8876;Inherit;False;Property;_BlinkThreashold;BlinkThreashold;21;0;Create;True;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;36;-1964.307,269.26;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-2238.125,740.1622;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;-1946.167,350.6331;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;75;-541.6323,738.9646;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;16;-1768.995,420.3114;Inherit;False;Property;_NoisyIntensity;NoisyIntensity;5;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;49;-2126.926,740.9618;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;150;-3813.07,31.15401;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;2;-1830.86,52.26519;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;89;-598.7366,985.5865;Inherit;False;33;WaterNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-2167.725,665.762;Inherit;False;33;WaterNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;38;-1692.567,274.6331;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;64;-2346.475,1057.482;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceCameraPos;65;-2419.275,1197.481;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;95;-572.0939,1285.841;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;152;-3622.77,132.8949;Inherit;False;Property;_BlinkIntensity;BlinkIntensity;20;0;Create;True;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;3;-1614.861,53.06518;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-2231.726,835.3621;Inherit;False;Property;_SpecSmoothness;SpecSmoothness;11;0;Create;True;0;0;False;0;False;0.1;0;0.0001;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-1550.009,273.7266;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-564.5732,1205.861;Inherit;False;Property;_WaterDepth;WaterDepth;15;0;Create;True;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;159;-3656.177,213.285;Inherit;False;Property;_BlinkColor;BlinkColor;16;0;Create;True;0;0;False;0;False;0.9917453,0.9339622,1,0;0.9240692,0.4056603,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;76;-464.0322,910.9646;Inherit;False;Property;_UnderWaterTilling;UnderWaterTilling;13;0;Create;True;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;90;-402.7366,984.7866;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;151;-3578.004,36.47379;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-2088.076,1191.882;Inherit;False;Property;_SpecStart;SpecStart;9;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-390.7366,1073.586;Inherit;False;Constant;_Float6;Float 6;12;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-2113.326,913.7623;Inherit;False;Constant;_Float5;Float 5;6;0;Create;True;0;0;False;0;False;256;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;77;-360.0331,734.9648;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DistanceOpNode;66;-2079.275,1100.682;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;50;-1978.926,671.3616;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-2096.875,1027.082;Inherit;False;Property;_SpecEnd;SpecEnd;10;0;Create;True;0;0;False;0;False;200;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;70;-1901.675,1032.682;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;-1413.703,147.3036;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;83;-719.746,364.9319;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;78;-200.8332,795.7648;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;-3439.421,113.8912;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;161;-3354.664,271.693;Inherit;False;Constant;_Float11;Float 11;22;0;Create;True;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-250.7366,987.1865;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;71;-1903.275,1174.282;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;82;-721.346,214.5321;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ParallaxOffsetHlpNode;93;-357.9041,1177.878;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-1962.126,839.3618;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;52;-1864.526,671.3618;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1274.861,30.66521;Inherit;True;Property;_ReflectionTex;ReflectionTex;0;0;Create;True;0;0;False;0;False;-1;e29df72e292af63489146e06dfc79ae9;e29df72e292af63489146e06dfc79ae9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;59;-1790.926,951.3629;Inherit;False;Property;_SpecTintIntensity;SpecTintIntensity;8;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;53;-1737.326,694.5619;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;57;-1794.126,788.962;Inherit;False;Property;_SpecTint;SpecTint;7;0;Create;True;0;0;False;0;False;0.9240692,0.4056603,1,0;0.9240692,0.4056603,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;72;-1762.475,1083.881;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;160;-3255.997,122.3597;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;84;-530.1459,279.3322;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;-80.33667,968.6266;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;144;-3043.406,117.5782;Inherit;False;ReflectBlink;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;73;-1644.875,1084.682;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;-976.6354,33.73228;Inherit;False;ReflectColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-1559.727,773.7621;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;79;36.76378,943.0615;Inherit;True;Property;_UnderWaterTex;UnderWaterTex;12;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;85;-410.9457,280.1322;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-1391.275,767.8815;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;437.9677,952.5294;Inherit;False;UnderWaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-269.9598,130.0611;Inherit;False;42;ReflectColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;-269.4008,197.6777;Inherit;False;144;ReflectBlink;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;86;-271.7457,279.3323;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;98;-271.1871,366.5592;Inherit;False;Property;_UnderwaterScale;UnderwaterScale;14;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;158;-90.94348,131.1423;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;97;-61.87798,314.7324;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-1220.504,762.491;Inherit;False;SpecColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;81;-285.7448,48.73817;Inherit;False;80;UnderWaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;87;173.665,55.04262;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;234.2898,321.2953;Inherit;False;60;SpecColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;437.4899,300.4954;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;563.5492,57.07584;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Water;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;108;0;103;0
WireConnection;110;0;108;0
WireConnection;110;1;107;0
WireConnection;112;0;106;0
WireConnection;112;1;105;0
WireConnection;112;2;104;0
WireConnection;114;0;112;0
WireConnection;114;1;111;0
WireConnection;113;0;110;0
WireConnection;113;1;109;0
WireConnection;115;0;113;0
WireConnection;115;1;114;0
WireConnection;6;0;5;0
WireConnection;116;0;110;0
WireConnection;116;1;112;0
WireConnection;13;0;11;0
WireConnection;13;1;12;0
WireConnection;13;2;14;0
WireConnection;7;0;6;0
WireConnection;7;1;8;0
WireConnection;118;1;115;0
WireConnection;119;1;116;0
WireConnection;20;0;7;0
WireConnection;20;1;22;0
WireConnection;21;0;13;0
WireConnection;21;1;23;0
WireConnection;120;0;119;0
WireConnection;120;1;118;0
WireConnection;10;0;7;0
WireConnection;10;1;13;0
WireConnection;24;0;20;0
WireConnection;24;1;21;0
WireConnection;121;0;120;0
WireConnection;123;0;121;0
WireConnection;123;1;122;0
WireConnection;4;1;10;0
WireConnection;4;5;100;0
WireConnection;19;1;24;0
WireConnection;19;5;100;0
WireConnection;25;0;4;0
WireConnection;25;1;19;0
WireConnection;124;0;123;0
WireConnection;124;1;123;0
WireConnection;125;0;124;0
WireConnection;15;0;25;0
WireConnection;126;0;125;0
WireConnection;26;0;15;0
WireConnection;26;1;27;0
WireConnection;127;0;123;0
WireConnection;127;2;126;0
WireConnection;28;0;26;0
WireConnection;28;1;26;0
WireConnection;29;0;28;0
WireConnection;128;0;127;0
WireConnection;30;0;29;0
WireConnection;129;0;128;0
WireConnection;31;0;26;0
WireConnection;31;2;30;0
WireConnection;32;0;31;0
WireConnection;135;0;133;0
WireConnection;140;0;135;0
WireConnection;140;1;138;0
WireConnection;141;0;139;0
WireConnection;33;0;32;0
WireConnection;37;0;39;0
WireConnection;142;0;141;0
WireConnection;142;1;140;0
WireConnection;143;1;142;0
WireConnection;36;0;35;0
WireConnection;48;0;45;0
WireConnection;48;1;46;0
WireConnection;40;0;41;0
WireConnection;40;1;37;4
WireConnection;49;0;48;0
WireConnection;150;0;143;1
WireConnection;150;1;149;0
WireConnection;38;0;36;0
WireConnection;38;1;40;0
WireConnection;3;0;2;0
WireConnection;17;0;38;0
WireConnection;17;1;16;0
WireConnection;90;0;89;0
WireConnection;151;0;150;0
WireConnection;77;0;75;0
WireConnection;66;0;64;0
WireConnection;66;1;65;0
WireConnection;50;0;51;0
WireConnection;50;1;49;0
WireConnection;70;0;67;0
WireConnection;70;1;66;0
WireConnection;18;0;3;0
WireConnection;18;1;17;0
WireConnection;78;0;77;0
WireConnection;78;1;76;0
WireConnection;155;0;151;0
WireConnection;155;1;152;0
WireConnection;155;2;159;0
WireConnection;91;0;90;0
WireConnection;91;1;92;0
WireConnection;71;0;67;0
WireConnection;71;1;69;0
WireConnection;93;1;94;0
WireConnection;93;2;95;0
WireConnection;56;0;54;0
WireConnection;56;1;55;0
WireConnection;52;0;50;0
WireConnection;1;1;18;0
WireConnection;53;0;52;0
WireConnection;53;1;56;0
WireConnection;72;0;70;0
WireConnection;72;1;71;0
WireConnection;160;0;155;0
WireConnection;160;1;161;0
WireConnection;84;0;82;0
WireConnection;84;1;83;0
WireConnection;88;0;78;0
WireConnection;88;1;91;0
WireConnection;88;2;93;0
WireConnection;144;0;160;0
WireConnection;73;0;72;0
WireConnection;42;0;1;0
WireConnection;58;0;53;0
WireConnection;58;1;57;0
WireConnection;58;2;59;0
WireConnection;79;1;88;0
WireConnection;85;0;84;0
WireConnection;74;0;58;0
WireConnection;74;1;73;0
WireConnection;80;0;79;0
WireConnection;86;0;85;0
WireConnection;158;0;43;0
WireConnection;158;1;145;0
WireConnection;97;0;86;0
WireConnection;97;1;98;0
WireConnection;60;0;74;0
WireConnection;87;0;81;0
WireConnection;87;1;158;0
WireConnection;87;2;97;0
WireConnection;62;0;87;0
WireConnection;62;1;63;0
WireConnection;0;13;62;0
ASEEND*/
//CHKSM=9DBA68AEB33E4471B990ADB0F03E68B8B4D2B2C0