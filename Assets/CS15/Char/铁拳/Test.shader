// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Test"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MaskMap("MaskMap", 2D) = "white" {}
		_BaseMap("BaseMap", 2D) = "white" {}
		_AoMap("AoMap", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "white" {}
		_Layer1_Offset("Layer1_Offset", Range( -1 , 1)) = 0
		_Layer2_Offset("Layer2_Offset", Range( -1 , 1)) = 0
		_TintColor1("TintColor1", Color) = (0,0,0,1)
		_TintColor2("TintColor2", Color) = (0,0,0,1)
		_Ramp("Ramp", 2D) = "white" {}
		_SpecShininess("SpecShininess", Float) = 100
		_Spec_Color("Spec_Color", Color) = (0,0,0,0)
		_SpecIntensity("SpecIntensity", Float) = 1
		_SpecMask("SpecMask", 2D) = "white" {}
		_FresnelMax("FresnelMax", Range( -1 , 2)) = 1
		_BaseColorScale("BaseColorScale", Float) = 1.2
		_FresnelMin("FresnelMin", Range( -1 , 2)) = 0.5
		_EnvColor("EnvColor", Color) = (1,1,1,0)
		_SideLightDir("SideLightDir", Vector) = (0,0,0,0)
		_SideLightThrehold("SideLightThrehold", Range( 0 , 1)) = 0.5
		_SideLightColor("SideLightColor", Color) = (1,1,1,0)
		[HDR]_MainLightColor("MainLightColor", Color) = (0.8742138,0.8742138,0.8742138,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
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
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
		};

		uniform float4 _MainLightColor;
		uniform float4 _TintColor1;
		uniform sampler2D _Ramp;
		uniform sampler2D _NormalMap;
		SamplerState sampler_NormalMap;
		uniform float4 _NormalMap_ST;
		uniform sampler2D _AoMap;
		SamplerState sampler_AoMap;
		uniform float4 _AoMap_ST;
		uniform float _Layer1_Offset;
		uniform sampler2D _BaseMap;
		uniform float4 _BaseMap_ST;
		uniform float _BaseColorScale;
		uniform float4 _TintColor2;
		uniform float _Layer2_Offset;
		uniform float _SpecShininess;
		uniform float4 _Spec_Color;
		uniform float _SpecIntensity;
		uniform sampler2D _SpecMask;
		SamplerState sampler_SpecMask;
		uniform float4 _SpecMask_ST;
		uniform float _FresnelMin;
		uniform float _FresnelMax;
		uniform float4 _EnvColor;
		uniform float3 _SideLightDir;
		uniform float _SideLightThrehold;
		uniform float4 _SideLightColor;
		uniform sampler2D _MaskMap;
		SamplerState sampler_MaskMap;
		uniform float4 _MaskMap_ST;
		uniform float _Cutoff = 0.5;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float3 appendResult71 = (float3(_TintColor1.r , _TintColor1.g , _TintColor1.b));
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float4 tex2DNode22 = tex2D( _NormalMap, uv_NormalMap );
			float3 appendResult104 = (float3(tex2DNode22.r , tex2DNode22.g , tex2DNode22.b));
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float4 ase_vertexTangent = mul( unity_WorldToObject, float4( ase_worldTangent, 0 ) );
			float4 appendResult74 = (float4(ase_vertexTangent.xyz , 0.0));
			float3 normalizeResult78 = normalize( (mul( appendResult74, unity_ObjectToWorld )).xyz );
			float3 TangentDir79 = normalizeResult78;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float4 transform40 = mul(unity_ObjectToWorld,float4( ase_vertexNormal , 0.0 ));
			float3 appendResult41 = (float3(transform40.x , transform40.y , transform40.z));
			float3 PreNormalDir18 = appendResult41;
			float3 normalizeResult85 = normalize( cross( PreNormalDir18 , TangentDir79 ) );
			float3 BinormalDir80 = normalizeResult85;
			float3 normalizeResult105 = normalize( mul( appendResult104, float3x3(TangentDir79, BinormalDir80, PreNormalDir18) ) );
			float3 NormalDir106 = normalizeResult105;
			float3 normalizeResult37 = normalize( _WorldSpaceLightPos0.xyz );
			float3 LightDir19 = normalizeResult37;
			float dotResult26 = dot( NormalDir106 , LightDir19 );
			float temp_output_29_0 = ( ( dotResult26 + 1.0 ) * 0.5 );
			float2 uv_AoMap = i.uv_texcoord * _AoMap_ST.xy + _AoMap_ST.zw;
			float temp_output_30_0 = ( temp_output_29_0 * tex2D( _AoMap, uv_AoMap ).g );
			float2 appendResult32 = (float2(( temp_output_30_0 + _Layer1_Offset ) , 0.5));
			float3 lerpResult43 = lerp( float3( 1,1,1 ) , appendResult71 , ( _TintColor1.a * tex2D( _Ramp, appendResult32 ).r ));
			float2 uv_BaseMap = i.uv_texcoord * _BaseMap_ST.xy + _BaseMap_ST.zw;
			float4 BaseColor42 = tex2D( _BaseMap, uv_BaseMap );
			float2 appendResult51 = (float2(( temp_output_30_0 + _Layer2_Offset ) , 0.5));
			float4 lerpResult56 = lerp( float4( 1,1,1,1 ) , _TintColor2 , ( _TintColor2.a * tex2D( _Ramp, appendResult51 ).r ));
			float4 Final_Diffuse64 = ( float4( lerpResult43 , 0.0 ) * ( BaseColor42 * _BaseColorScale ) * lerpResult56 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ViewDir91 = ase_worldViewDir;
			float3 normalizeResult113 = normalize( ( ViewDir91 + LightDir19 ) );
			float3 H118 = normalizeResult113;
			float dotResult120 = dot( TangentDir79 , H118 );
			float TdotH123 = dotResult120;
			float dotResult124 = dot( BinormalDir80 , H118 );
			float BdotHe129 = ( dotResult124 / _SpecShininess );
			float dotResult114 = dot( NormalDir106 , H118 );
			float NdotH119 = dotResult114;
			float SpecTerm138 = exp( ( -( pow( TdotH123 , 0.0 ) + pow( BdotHe129 , 2.0 ) ) / ( NdotH119 + 1.0 ) ) );
			float HalfLambert139 = temp_output_29_0;
			float dotResult109 = dot( NormalDir106 , ViewDir91 );
			float NdotV117 = max( dotResult109 , 0.0 );
			float SpecAtten146 = saturate( sqrt( max( ( HalfLambert139 / NdotV117 ) , 0.0 ) ) );
			float2 uv_SpecMask = i.uv_texcoord * _SpecMask_ST.xy + _SpecMask_ST.zw;
			float4 Final_Spec153 = ( SpecTerm138 * SpecAtten146 * _Spec_Color * _SpecIntensity * tex2D( _SpecMask, uv_SpecMask ).r * HalfLambert139 );
			float dotResult179 = dot( ViewDir91 , NormalDir106 );
			float smoothstepResult170 = smoothstep( _FresnelMin , _FresnelMax , ( 1.0 - dotResult179 ));
			float4 Final_Env175 = ( smoothstepResult170 * _EnvColor );
			float3 normalizeResult187 = normalize( mul( UNITY_MATRIX_I_V, float4( _SideLightDir , 0.0 ) ).xyz );
			float dotResult188 = dot( normalizeResult187 , NormalDir106 );
			float3 SideLight201 = saturate( ( ( ( ( ( dotResult188 + 1.0 ) * 0.5 ) - _SideLightThrehold ) * 20.0 ) * ( ( (_SideLightColor).rgb + (BaseColor42).rgb ) * 0.5 ) * _SideLightColor.a ) );
			o.Emission = ( ( _MainLightColor * Final_Diffuse64 ) + Final_Spec153 + Final_Env175 + float4( SideLight201 , 0.0 ) ).rgb;
			o.Alpha = 1;
			float2 uv_MaskMap = i.uv_texcoord * _MaskMap_ST.xy + _MaskMap_ST.zw;
			clip( tex2D( _MaskMap, uv_MaskMap ).r - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

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
				float2 customPack1 : TEXCOORD1;
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
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
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
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
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
1576;0.6666667;1106.667;691.6667;900.7131;386.9714;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;96;-3270.116,1950.332;Inherit;False;1094.092;1438.801;Comment;30;106;105;103;104;99;22;102;101;100;91;19;37;36;80;85;81;83;82;79;18;78;41;77;40;39;75;76;74;73;182;向量;0.4207547,0.609483,1,1;0;0
Node;AmplifyShaderEditor.TangentVertexDataNode;73;-3220.116,2260.098;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;76;-3038.132,2353.232;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.DynamicAppendNode;74;-2998.37,2260.313;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-2846.129,2260.433;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalVertexDataNode;39;-2968.91,2088.182;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;40;-2755.31,2088.182;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;77;-2715.73,2256.432;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;41;-2562.509,2111.382;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;78;-2559.421,2260.334;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;79;-2416.941,2254.094;Inherit;False;TangentDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;18;-2420.792,2108.982;Inherit;False;PreNormalDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;83;-3078.033,2500.915;Inherit;False;79;TangentDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;82;-3070.033,2431.314;Inherit;False;18;PreNormalDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CrossProductOpNode;81;-2829.233,2434.515;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;85;-2596.431,2432.115;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;36;-2877.314,2007.027;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-2412.433,2426.515;Inherit;False;BinormalDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;37;-2591.383,2005.427;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;182;-2641.847,2590.113;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;22;-3178.552,2890.559;Inherit;True;Property;_NormalMap;NormalMap;4;0;Create;True;0;0;False;0;False;-1;8b09c4e7352d7c54d86feb47c1b78749;8b09c4e7352d7c54d86feb47c1b78749;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;100;-3256.023,3104.831;Inherit;False;79;TangentDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;-3259.223,3183.231;Inherit;False;80;BinormalDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-3248.823,3256.031;Inherit;False;18;PreNormalDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;91;-2454.492,2583.967;Inherit;False;ViewDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.MatrixFromVectors;99;-2987.222,3105.631;Inherit;False;FLOAT3x3;True;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3x3;0
Node;AmplifyShaderEditor.DynamicAppendNode;104;-2874.424,2918.431;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;-2408.595,2000.332;Inherit;False;LightDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;167;-2122.988,1958.976;Inherit;False;1974.576;1131.406;Comment;43;111;107;112;113;118;108;126;121;128;124;115;109;120;110;127;129;123;117;114;142;140;131;130;132;141;119;134;135;143;144;136;145;137;138;146;160;148;163;161;149;151;152;153;Spec;1,0.5264151,0.8347293,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-2700.823,3080.831;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3x3;0,0,0,0,1,1,1,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;111;-2065.567,2576.371;Inherit;False;19;LightDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;-2072.988,2475.561;Inherit;False;91;ViewDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;105;-2554.424,3081.631;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;112;-1878.367,2557.171;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;72;-3278.699,1025.537;Inherit;False;2768.419;836.592;Comment;29;33;34;32;61;46;35;47;71;58;50;51;53;62;54;56;44;43;63;64;23;24;26;28;29;17;30;139;166;165;Diffuse;1,0.5641509,0.5641509,1;0;0
Node;AmplifyShaderEditor.NormalizeNode;113;-1729.566,2554.771;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;106;-2396.823,3076.031;Inherit;False;NormalDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;-3228.698,1228.43;Inherit;False;106;NormalDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;118;-1571.966,2549.17;Inherit;False;H;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-3228.006,1299.146;Inherit;False;19;LightDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;26;-3027.038,1281.723;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;126;-2069.496,2183.494;Inherit;False;80;BinormalDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;121;-2057.839,2088.977;Inherit;False;118;H;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;-2063.067,2304.801;Inherit;False;106;NormalDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-2895.973,1280.683;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;124;-1827.896,2154.693;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;109;-1887.168,2402.77;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;128;-1878.295,2251.493;Inherit;False;Property;_SpecShininess;SpecShininess;10;0;Create;True;0;0;False;0;False;100;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;-2067.443,2008.976;Inherit;False;79;TangentDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;120;-1826.639,2011.377;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-2758.452,1279.643;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;127;-1653.495,2154.693;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;110;-1764.767,2402.77;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.InverseViewMatrixNode;184;-937.8648,3239.967;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.Vector3Node;185;-931.2588,3318.632;Inherit;False;Property;_SideLightDir;SideLightDir;18;0;Create;True;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;139;-2615.159,1208.247;Inherit;False;HalfLambert;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-764.0541,3240.099;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;129;-1531.895,2150.694;Inherit;False;BdotHe;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;17;-2891.554,1386.332;Inherit;True;Property;_AoMap;AoMap;3;0;Create;True;0;0;False;0;False;-1;7a2f634aa5975254c853e03cd4cd4c2c;7a2f634aa5975254c853e03cd4cd4c2c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;123;-1691.896,2009.093;Inherit;False;TdotH;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;117;-1636.767,2397.97;Inherit;False;NdotV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-2378.413,1334.071;Inherit;False;Property;_Layer1_Offset;Layer1_Offset;5;0;Create;True;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-2699.71,1673.023;Inherit;False;Property;_Layer2_Offset;Layer2_Offset;6;0;Create;True;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;189;-645.5847,3310.677;Inherit;False;106;NormalDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;187;-626.2595,3240.1;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;140;-2010.487,2685.306;Inherit;False;139;HalfLambert;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;114;-1385.566,2310.77;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;142;-2007.624,2751.155;Inherit;False;117;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-2578.5,1276.964;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;131;-1307.115,2155.913;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;130;-1309.515,2012.713;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-1068.546,-126.0862;Inherit;True;Property;_BaseMap;BaseMap;2;0;Create;True;0;0;False;0;False;-1;231eaba430abe814c93b9a64aca83d5b;231eaba430abe814c93b9a64aca83d5b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-2106.161,1275.469;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;119;-1254.364,2305.171;Inherit;False;NdotH;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;-763.1201,-124.3523;Inherit;False;BaseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;132;-1127.874,2011.892;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;188;-466.6196,3239.259;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;141;-1815.624,2689.555;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;-2403.238,1654.431;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;134;-998.8667,2012.143;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;183;-2121.927,3151.886;Inherit;False;1024.209;465.0993;Comment;10;177;179;169;171;172;174;170;173;175;178;Env;0.3301886,1,0.366094,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;190;-348.99,3240.939;Inherit;False;2;2;0;FLOAT;1;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;61;-2101.103,1431.039;Inherit;True;Property;_Ramp;Ramp;9;0;Create;True;0;0;False;0;False;04aca538ef063d047beef63aaa058960;04aca538ef063d047beef63aaa058960;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.DynamicAppendNode;51;-2235.843,1655.473;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;135;-1054.968,2309.999;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;32;-1980.001,1275.469;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;195;-101.3201,3374.453;Inherit;False;Property;_SideLightColor;SideLightColor;20;0;Create;True;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;196;-68.07671,3547.584;Inherit;False;42;BaseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;143;-1687.624,2689.553;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;53;-1726.587,1438.17;Inherit;False;Property;_TintColor2;TintColor2;8;0;Create;True;0;0;False;0;False;0,0,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;62;-1801.681,1632.129;Inherit;True;Property;_TextureSample0;Texture Sample 0;10;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;35;-1805.387,1248.062;Inherit;True;Property;_RampMap;RampMap;7;0;Create;True;0;0;False;0;False;-1;04aca538ef063d047beef63aaa058960;04aca538ef063d047beef63aaa058960;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;177;-2071.927,3288.287;Inherit;False;106;NormalDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;178;-2070.328,3201.886;Inherit;False;91;ViewDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;46;-1722.226,1075.537;Inherit;False;Property;_TintColor1;TintColor1;7;0;Create;True;0;0;False;0;False;0,0,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;192;-379.2378,3338.404;Inherit;False;Property;_SideLightThrehold;SideLightThrehold;19;0;Create;True;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;203;133.371,3374.053;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;204;102.7242,3548.532;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SqrtOpNode;144;-1554.824,2691.153;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;191;-235.5614,3241.779;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;136;-778.5437,2014.48;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-1449.402,1639.41;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-1281.54,1290.73;Inherit;False;42;BaseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;71;-1452.526,1104.163;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;166;-1282.394,1362.397;Inherit;False;Property;_BaseColorScale;BaseColorScale;15;0;Create;True;0;0;False;0;False;1.2;1.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;193;-79.28204,3242.62;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-1425.245,1293.323;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;179;-1895.624,3206.637;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;198;315.8364,3377.839;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;145;-1429.223,2692.754;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;199;292.6539,3525.831;Inherit;False;Constant;_Float1;Float 1;20;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ExpOpNode;137;-654.1241,2018.609;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;171;-2051.267,3370.19;Inherit;False;Property;_FresnelMin;FresnelMin;16;0;Create;True;0;0;False;0;False;0.5;0;-1;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;165;-1111.195,1322.397;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;43;-1263.549,1170.874;Inherit;False;3;0;FLOAT3;1,1,1;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;56;-1262.014,1431.462;Inherit;False;3;0;COLOR;1,1,1,1;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;172;-2054.704,3443.226;Inherit;False;Property;_FresnelMax;FresnelMax;14;0;Create;True;0;0;False;0;False;1;0;-1;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;194;72.5555,3243.26;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;146;-1290.496,2687.602;Inherit;False;SpecAtten;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;197;466.1442,3375.243;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;138;-536.04,2016.284;Inherit;False;SpecTerm;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;169;-1784.159,3265.313;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;200;634.0435,3242.304;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;161;-1027.705,2773.194;Inherit;True;Property;_SpecMask;SpecMask;13;0;Create;True;0;0;False;0;False;-1;267cf0370ab4af64491322589c171b92;267cf0370ab4af64491322589c171b92;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;160;-937.2312,2509.325;Inherit;False;Property;_Spec_Color;Spec_Color;11;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;151;-911.6117,2689.515;Inherit;False;Property;_SpecIntensity;SpecIntensity;12;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;148;-909.1264,2342.686;Inherit;False;138;SpecTerm;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;174;-1702.807,3407.986;Inherit;False;Property;_EnvColor;EnvColor;17;0;Create;True;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;170;-1643.53,3266.952;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;163;-905.0248,2974.982;Inherit;False;139;HalfLambert;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-990.5703,1167.358;Inherit;True;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;-907.3364,2433.808;Inherit;False;146;SpecAtten;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;173;-1453.479,3266.952;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;-682.8117,2467.115;Inherit;False;6;6;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;205;789.6395,3248.249;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-738.2781,1162.299;Inherit;False;Final_Diffuse;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;153;-373.2113,2460.715;Inherit;False;Final_Spec;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-510.8469,-36.64919;Inherit;False;64;Final_Diffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;201;916.8351,3235.15;Inherit;False;SideLight;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;175;-1322.518,3262.755;Inherit;False;Final_Env;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;206;-542.7133,-217.6381;Inherit;False;Property;_MainLightColor;MainLightColor;21;1;[HDR];Create;True;0;0;False;0;False;0.8742138,0.8742138,0.8742138,0;0.8742138,0.8742138,0.8742138,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;207;-285.3798,-96.97144;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;-371.1223,225.8705;Inherit;False;201;SideLight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;176;-368.3964,147.4256;Inherit;False;175;Final_Env;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;154;-369.5983,74.18854;Inherit;False;153;Final_Spec;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;79.83762,526.014;Inherit;False;69;Debugg;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;155;-152.7571,56.44428;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;69;310.1008,527.1878;Inherit;False;Debugg;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-403.8193,314.6664;Inherit;True;Property;_MaskMap;MaskMap;1;0;Create;True;0;0;False;0;False;-1;e555252f1a084e4449c22e8cd8837951;e555252f1a084e4449c22e8cd8837951;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;67;38.40002,-38.1333;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Test;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;74;0;73;0
WireConnection;75;0;74;0
WireConnection;75;1;76;0
WireConnection;40;0;39;0
WireConnection;77;0;75;0
WireConnection;41;0;40;1
WireConnection;41;1;40;2
WireConnection;41;2;40;3
WireConnection;78;0;77;0
WireConnection;79;0;78;0
WireConnection;18;0;41;0
WireConnection;81;0;82;0
WireConnection;81;1;83;0
WireConnection;85;0;81;0
WireConnection;80;0;85;0
WireConnection;37;0;36;1
WireConnection;91;0;182;0
WireConnection;99;0;100;0
WireConnection;99;1;101;0
WireConnection;99;2;102;0
WireConnection;104;0;22;1
WireConnection;104;1;22;2
WireConnection;104;2;22;3
WireConnection;19;0;37;0
WireConnection;103;0;104;0
WireConnection;103;1;99;0
WireConnection;105;0;103;0
WireConnection;112;0;107;0
WireConnection;112;1;111;0
WireConnection;113;0;112;0
WireConnection;106;0;105;0
WireConnection;118;0;113;0
WireConnection;26;0;24;0
WireConnection;26;1;23;0
WireConnection;28;0;26;0
WireConnection;124;0;126;0
WireConnection;124;1;121;0
WireConnection;109;0;108;0
WireConnection;109;1;107;0
WireConnection;120;0;115;0
WireConnection;120;1;121;0
WireConnection;29;0;28;0
WireConnection;127;0;124;0
WireConnection;127;1;128;0
WireConnection;110;0;109;0
WireConnection;139;0;29;0
WireConnection;186;0;184;0
WireConnection;186;1;185;0
WireConnection;129;0;127;0
WireConnection;123;0;120;0
WireConnection;117;0;110;0
WireConnection;187;0;186;0
WireConnection;114;0;108;0
WireConnection;114;1;118;0
WireConnection;30;0;29;0
WireConnection;30;1;17;2
WireConnection;131;0;129;0
WireConnection;130;0;123;0
WireConnection;34;0;30;0
WireConnection;34;1;33;0
WireConnection;119;0;114;0
WireConnection;42;0;4;0
WireConnection;132;0;130;0
WireConnection;132;1;131;0
WireConnection;188;0;187;0
WireConnection;188;1;189;0
WireConnection;141;0;140;0
WireConnection;141;1;142;0
WireConnection;50;0;30;0
WireConnection;50;1;58;0
WireConnection;134;0;132;0
WireConnection;190;0;188;0
WireConnection;51;0;50;0
WireConnection;135;0;119;0
WireConnection;32;0;34;0
WireConnection;143;0;141;0
WireConnection;62;0;61;0
WireConnection;62;1;51;0
WireConnection;35;0;61;0
WireConnection;35;1;32;0
WireConnection;203;0;195;0
WireConnection;204;0;196;0
WireConnection;144;0;143;0
WireConnection;191;0;190;0
WireConnection;136;0;134;0
WireConnection;136;1;135;0
WireConnection;54;0;53;4
WireConnection;54;1;62;1
WireConnection;71;0;46;1
WireConnection;71;1;46;2
WireConnection;71;2;46;3
WireConnection;193;0;191;0
WireConnection;193;1;192;0
WireConnection;47;0;46;4
WireConnection;47;1;35;1
WireConnection;179;0;178;0
WireConnection;179;1;177;0
WireConnection;198;0;203;0
WireConnection;198;1;204;0
WireConnection;145;0;144;0
WireConnection;137;0;136;0
WireConnection;165;0;44;0
WireConnection;165;1;166;0
WireConnection;43;1;71;0
WireConnection;43;2;47;0
WireConnection;56;1;53;0
WireConnection;56;2;54;0
WireConnection;194;0;193;0
WireConnection;146;0;145;0
WireConnection;197;0;198;0
WireConnection;197;1;199;0
WireConnection;138;0;137;0
WireConnection;169;0;179;0
WireConnection;200;0;194;0
WireConnection;200;1;197;0
WireConnection;200;2;195;4
WireConnection;170;0;169;0
WireConnection;170;1;171;0
WireConnection;170;2;172;0
WireConnection;63;0;43;0
WireConnection;63;1;165;0
WireConnection;63;2;56;0
WireConnection;173;0;170;0
WireConnection;173;1;174;0
WireConnection;152;0;148;0
WireConnection;152;1;149;0
WireConnection;152;2;160;0
WireConnection;152;3;151;0
WireConnection;152;4;161;1
WireConnection;152;5;163;0
WireConnection;205;0;200;0
WireConnection;64;0;63;0
WireConnection;153;0;152;0
WireConnection;201;0;205;0
WireConnection;175;0;173;0
WireConnection;207;0;206;0
WireConnection;207;1;65;0
WireConnection;155;0;207;0
WireConnection;155;1;154;0
WireConnection;155;2;176;0
WireConnection;155;3;202;0
WireConnection;67;2;155;0
WireConnection;67;10;1;1
ASEEND*/
//CHKSM=377128DDACF8F234E72BFA31F6B99FF10391943E