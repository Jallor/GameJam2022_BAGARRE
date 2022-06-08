// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_VFX_ChargeDash"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_Main_texture_RGBBase_AlphaDissolve__("Main_texture_RGB (Base_AlphaDissolve_-_)", 2D) = "white" {}
		_Main_color("Main_color", Color) = (0,0,0,0)
		_Main_emissive("Main_emissive", Range( 0 , 200)) = 0
		_Main_tile_X("Main_tile_X", Float) = 1
		_Main_tile_Y("Main_tile_Y", Float) = 1
		_Main_speed_X("Main_speed _X", Float) = 0
		_Main_speed_Y("Main_speed_Y", Float) = 1
		_emissive_Color("emissive_Color", Color) = (0,0,0,0)
		_emissive_Intensity("emissive_Intensity", Range( 0 , 200)) = 0
		_emissive_Treshold("emissive_Treshold", Range( 0 , 200)) = 0
		_fresnel_Color("fresnel_Color", Color) = (0,0,0,0)
		_fresnel_Emissive_Intensity("fresnel_Emissive_Intensity", Range( 0 , 200)) = 1
		_fresnel_Power("fresnel_Power", Float) = 0
		_Fresnel_Scale("Fresnel_Scale", Float) = 0
		_fresnel_Biais("fresnel_Biais", Float) = 0
		_dissolve_Hardness("dissolve_Hardness", Range( 0 , 10)) = 0
		_alpha_Treshold("alpha_Treshold", Float) = 0
		_sizeAnimateThroughShader("size - Animate Through Shader", Range( 0 , 1)) = 0

	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull Back
		HLSLINCLUDE
		#pragma target 2.0
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend SrcAlpha OneMinusSrcAlpha , One OneMinusSrcAlpha
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#define _RECEIVE_SHADOWS_OFF 1
			#pragma multi_compile_instancing
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _Main_texture_RGBBase_AlphaDissolve__;
			CBUFFER_START( UnityPerMaterial )
			float _sizeAnimateThroughShader;
			float _Main_speed_X;
			float _Main_speed_Y;
			float _Main_tile_X;
			float _Main_tile_Y;
			float4 _Main_color;
			float _Main_emissive;
			float _emissive_Treshold;
			float _emissive_Intensity;
			float4 _emissive_Color;
			float _fresnel_Emissive_Intensity;
			float _dissolve_Hardness;
			float4 _fresnel_Color;
			float _fresnel_Biais;
			float _Fresnel_Scale;
			float _fresnel_Power;
			float _alpha_Treshold;
			CBUFFER_END


			
			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float Size_Animatethroughshader77 = _sizeAnimateThroughShader;
				
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord4.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( v.ase_normal * ( Size_Animatethroughshader77 / 50.0 ) );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float2 appendResult4_g1 = (float2(_Main_speed_X , _Main_speed_Y));
				float2 uv011 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g1 = (float2(_Main_tile_X , _Main_tile_Y));
				float2 panner6_g1 = ( _TimeParameters.x * appendResult4_g1 + ( uv011 * appendResult12_g1 ));
				float4 tex2DNode5 = tex2D( _Main_texture_RGBBase_AlphaDissolve__, panner6_g1 );
				float R58 = tex2DNode5.r;
				float Size_Animatethroughshader77 = _sizeAnimateThroughShader;
				float temp_output_6_0_g3 = pow( tex2DNode5.r , _emissive_Treshold );
				float temp_output_82_0 = ( Size_Animatethroughshader77 + _fresnel_Emissive_Intensity );
				float lerpResult95 = lerp( 0.0 , 3.0 , _sizeAnimateThroughShader);
				float Dissolve63 = ( _dissolve_Hardness + ( _sizeAnimateThroughShader * lerpResult95 ) );
				float temp_output_47_0 = ( Dissolve63 / 10.0 );
				float lerpResult51 = lerp( 1.0 , 10.0 , temp_output_47_0);
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float fresnelNdotV25 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode25 = ( _fresnel_Biais + _Fresnel_Scale * pow( 1.0 - fresnelNdotV25, _fresnel_Power ) );
				float Fresnel66 = fresnelNode25;
				float4 lerpResult26 = lerp( ( ( ( R58 * _Main_color ) * ( _Main_emissive + ( Size_Animatethroughshader77 * 20.0 ) ) ) + ( ( temp_output_6_0_g3 * ( ( Size_Animatethroughshader77 * 10.0 ) + _emissive_Intensity ) ) * _emissive_Color ) ) , ( ( ( temp_output_82_0 * ( saturate( Dissolve63 ) * lerpResult51 ) ) + temp_output_82_0 ) * _fresnel_Color ) , Fresnel66);
				
				float G59 = tex2DNode5.g;
				float lerpResult5_g2 = lerp( saturate( pow( G59 , Dissolve63 ) ) , 0.0 , 0.0);
				float lerpResult41 = lerp( 1.0 , 0.0 , temp_output_47_0);
				float4 temp_cast_1 = (lerpResult41).xxxx;
				float4 lerpResult39 = lerp( saturate( saturate( ( lerpResult5_g2 * float4( 1,1,1,0 ) ) ) ) , temp_cast_1 , Fresnel66);
				
				float lerpResult103 = lerp( 0.25 , 2.0 , Size_Animatethroughshader77);
				float lerpResult102 = lerp( _alpha_Treshold , ( ( Size_Animatethroughshader77 / 2.0 ) * lerpResult103 ) , Size_Animatethroughshader77);
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult26.rgb;
				float Alpha = saturate( lerpResult39 ).r;
				float AlphaClipThreshold = lerpResult102;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0

			HLSLPROGRAM
			#define _RECEIVE_SHADOWS_OFF 1
			#pragma multi_compile_instancing
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _Main_texture_RGBBase_AlphaDissolve__;
			CBUFFER_START( UnityPerMaterial )
			float _sizeAnimateThroughShader;
			float _Main_speed_X;
			float _Main_speed_Y;
			float _Main_tile_X;
			float _Main_tile_Y;
			float4 _Main_color;
			float _Main_emissive;
			float _emissive_Treshold;
			float _emissive_Intensity;
			float4 _emissive_Color;
			float _fresnel_Emissive_Intensity;
			float _dissolve_Hardness;
			float4 _fresnel_Color;
			float _fresnel_Biais;
			float _Fresnel_Scale;
			float _fresnel_Power;
			float _alpha_Treshold;
			CBUFFER_END


			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float Size_Animatethroughshader77 = _sizeAnimateThroughShader;
				
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( v.ase_normal * ( Size_Animatethroughshader77 / 50.0 ) );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 appendResult4_g1 = (float2(_Main_speed_X , _Main_speed_Y));
				float2 uv011 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g1 = (float2(_Main_tile_X , _Main_tile_Y));
				float2 panner6_g1 = ( _TimeParameters.x * appendResult4_g1 + ( uv011 * appendResult12_g1 ));
				float4 tex2DNode5 = tex2D( _Main_texture_RGBBase_AlphaDissolve__, panner6_g1 );
				float G59 = tex2DNode5.g;
				float lerpResult95 = lerp( 0.0 , 3.0 , _sizeAnimateThroughShader);
				float Dissolve63 = ( _dissolve_Hardness + ( _sizeAnimateThroughShader * lerpResult95 ) );
				float lerpResult5_g2 = lerp( saturate( pow( G59 , Dissolve63 ) ) , 0.0 , 0.0);
				float temp_output_47_0 = ( Dissolve63 / 10.0 );
				float lerpResult41 = lerp( 1.0 , 0.0 , temp_output_47_0);
				float4 temp_cast_0 = (lerpResult41).xxxx;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float fresnelNdotV25 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode25 = ( _fresnel_Biais + _Fresnel_Scale * pow( 1.0 - fresnelNdotV25, _fresnel_Power ) );
				float Fresnel66 = fresnelNode25;
				float4 lerpResult39 = lerp( saturate( saturate( ( lerpResult5_g2 * float4( 1,1,1,0 ) ) ) ) , temp_cast_0 , Fresnel66);
				
				float Size_Animatethroughshader77 = _sizeAnimateThroughShader;
				float lerpResult103 = lerp( 0.25 , 2.0 , Size_Animatethroughshader77);
				float lerpResult102 = lerp( _alpha_Treshold , ( ( Size_Animatethroughshader77 / 2.0 ) * lerpResult103 ) , Size_Animatethroughshader77);
				
				float Alpha = saturate( lerpResult39 ).r;
				float AlphaClipThreshold = lerpResult102;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

	
	}
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18000
1152;-107;1600;815;-2781.44;-284.0786;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;73;-1714.667,394.6512;Inherit;False;1224.433;506.9878;;7;14;93;95;54;77;63;79;VAR;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;74;-1731.526,-238.565;Inherit;False;1190.329;289.4887;;6;11;8;10;9;7;6;SPEED control;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-1582.852,596.003;Inherit;False;Property;_sizeAnimateThroughShader;size - Animate Through Shader;17;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1104.164,-112.8894;Inherit;False;Property;_Main_tile_X;Main_tile_X;3;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1266.947,-163.6192;Inherit;False;Property;_Main_speed_X;Main_speed _X;5;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1391.594,-140.043;Inherit;False;Property;_Main_speed_Y;Main_speed_Y;6;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-980.0103,-89.88284;Inherit;False;Property;_Main_tile_Y;Main_tile_Y;4;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1681.526,-188.565;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;95;-1271.165,729.6262;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;3;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;75;-321.5846,-562.7039;Inherit;False;1729.937;1026.75;;21;20;61;24;72;50;5;59;16;21;17;23;22;58;12;18;65;2;4;0;3;51;MAIN COLOR;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;6;-798.1974,-180.0763;Inherit;False;MF_Tiles;-1;;1;2fa329d2d99691549897442d611b24f3;0;6;14;FLOAT2;0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;10;FLOAT;1;False;13;FLOAT;1;False;11;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-1049.082,706.3153;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1574.97,441.6512;Inherit;False;Property;_dissolve_Hardness;dissolve_Hardness;15;0;Create;True;0;0;False;0;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;70;1423.472,-1029.448;Inherit;False;1284.362;261.1447;;5;29;32;33;25;66;Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;5;86.79017,-207.7196;Inherit;True;Property;_Main_texture_RGBBase_AlphaDissolve__;Main_texture_RGB (Base_AlphaDissolve_-_);0;0;Create;True;0;0;False;0;-1;1f396e2dd9d093c4fa5d1379fc1247fb;1f396e2dd9d093c4fa5d1379fc1247fb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;79;-901.399,450.4415;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-771.0583,444.9323;Inherit;False;Dissolve;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;1676.629,-884.3029;Inherit;False;Property;_fresnel_Power;fresnel_Power;12;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;71;1419.758,581.3013;Inherit;False;1418.274;686.4662;;9;43;44;41;35;39;13;60;64;69;ALPHA Handler;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;32;1874.494,-913.2136;Inherit;False;Property;_Fresnel_Scale;Fresnel_Scale;13;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;492.8917,-101.8923;Inherit;False;G;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;1473.472,-939.8389;Inherit;False;Property;_fresnel_Biais;fresnel_Biais;14;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;-768.1862,596.8721;Inherit;False;Size_Animatethroughshader;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;1469.758,683.3522;Inherit;False;59;G;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;62;445.1722,1148.227;Inherit;False;63;Dissolve;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;25;2216.991,-977.2065;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;1473.583,766.172;Inherit;False;63;Dissolve;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;2945.871,364.6248;Inherit;False;77;Size_Animatethroughshader;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;2109.627,1128.448;Inherit;False;Constant;_Nothing;Nothing;18;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;13;1770.596,631.3012;Inherit;False;MF_Alpha_handler;-1;;2;9ba53a059d6724547ba534bf0c40c79e;0;4;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;13;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;43;1941.297,1103.195;Inherit;False;Constant;_GoingToFULL;Going To FULL;18;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;47;705.9039,1153.844;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;2483.835,-979.4476;Inherit;False;Fresnel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;2475.797,849.1721;Inherit;False;66;Fresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;3228.046,941.2206;Inherit;False;77;Size_Animatethroughshader;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;35;2435.573,635.2564;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;103;3285.303,525.2195;Inherit;False;3;0;FLOAT;0.25;False;1;FLOAT;2;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;105;3316.562,427.9446;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;41;2476.376,1108.768;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;3297.709,314.1881;Inherit;False;Property;_alpha_Treshold;alpha_Treshold;16;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;3473.426,427.3192;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;57;3499.602,834.965;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;50;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;39;2656.031,807.6395;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalVertexDataNode;53;3281.135,668.9836;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;102;3617.675,318.9865;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;21;46.894,-485.5004;Inherit;False;Property;_Main_color;Main_color;1;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;2260.621,-250.5909;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;2026.742,-486.0677;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;40;2855.63,229.3442;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;707.9072,-226.495;Inherit;False;63;Dissolve;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;210.3091,-512.7039;Inherit;False;58;R;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;378.5193,-504.9099;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;243.422,581.8615;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;31;2017.531,-181.8327;Inherit;False;Property;_fresnel_Color;fresnel_Color;10;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;12;437.7484,232.5923;Inherit;False;MF_Emissive_handler;-1;;3;4c2d144224f39b24a93af8da62996f6d;0;4;11;FLOAT;0;False;9;COLOR;0,0,0,0;False;10;FLOAT;0;False;12;FLOAT;0;False;2;COLOR;0;FLOAT;13
Node;AmplifyShaderEditor.RangedFloatNode;18;-38.36711,304.0174;Inherit;False;Property;_emissive_Treshold;emissive_Treshold;9;0;Create;True;0;0;False;0;0;0;0;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;2918.454,-191.3468;Inherit;False;66;Fresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;72;895.6111,-222.0974;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;1246.352,-220.6335;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;49;2388.046,-354.4959;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;1799.934,-336.0269;Inherit;False;Property;_fresnel_Emissive_Intensity;fresnel_Emissive_Intensity;11;0;Create;True;0;0;False;0;1;0;0;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;51;853.6855,288.7917;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;10;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;91;813.3765,-855.4127;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;3666.393,668.2609;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;85;411.3331,583.9229;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;488.4008,-417.6219;Inherit;False;Property;_Main_emissive;Main_emissive;2;0;Create;True;0;0;False;0;0;0;0;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-126.0803,580.5488;Inherit;False;77;Size_Animatethroughshader;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;1733.555,-567.5079;Inherit;False;77;Size_Animatethroughshader;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;16;-271.5846,252.0459;Inherit;False;Property;_emissive_Color;emissive_Color;7;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;24;1139.646,-317.721;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-32.5302,182.9075;Inherit;False;Property;_emissive_Intensity;emissive_Intensity;8;0;Create;True;0;0;False;0;0;0;0;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;2584.141,-202.2529;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;82;2201.653,-452.0063;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;490.1846,-183.5953;Inherit;False;R;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;566.5067,-828.9577;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;244.384,-834.9839;Inherit;False;77;Size_Animatethroughshader;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;980.8544,-514.6415;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;26;3140.799,-305.6619;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;3798.17,200.3932;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;M_VFX_ChargeDash;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;False;True;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;95;2;54;0
WireConnection;6;14;11;0
WireConnection;6;7;9;0
WireConnection;6;8;10;0
WireConnection;6;10;7;0
WireConnection;6;13;8;0
WireConnection;93;0;54;0
WireConnection;93;1;95;0
WireConnection;5;1;6;0
WireConnection;79;0;14;0
WireConnection;79;1;93;0
WireConnection;63;0;79;0
WireConnection;59;0;5;2
WireConnection;77;0;54;0
WireConnection;25;1;33;0
WireConnection;25;2;32;0
WireConnection;25;3;29;0
WireConnection;13;7;64;0
WireConnection;13;8;60;0
WireConnection;47;0;62;0
WireConnection;66;0;25;0
WireConnection;35;0;13;0
WireConnection;103;2;96;0
WireConnection;105;0;96;0
WireConnection;41;0;43;0
WireConnection;41;1;44;0
WireConnection;41;2;47;0
WireConnection;104;0;105;0
WireConnection;104;1;103;0
WireConnection;57;0;76;0
WireConnection;39;0;35;0
WireConnection;39;1;41;0
WireConnection;39;2;69;0
WireConnection;102;0;38;0
WireConnection;102;1;104;0
WireConnection;102;2;96;0
WireConnection;48;0;82;0
WireConnection;48;1;50;0
WireConnection;84;0;89;0
WireConnection;40;0;39;0
WireConnection;20;0;61;0
WireConnection;20;1;21;0
WireConnection;87;0;88;0
WireConnection;12;11;5;1
WireConnection;12;9;16;0
WireConnection;12;10;85;0
WireConnection;12;12;18;0
WireConnection;72;0;65;0
WireConnection;50;0;72;0
WireConnection;50;1;51;0
WireConnection;49;0;48;0
WireConnection;49;1;82;0
WireConnection;51;2;47;0
WireConnection;91;0;23;0
WireConnection;91;1;92;0
WireConnection;52;0;53;0
WireConnection;52;1;57;0
WireConnection;85;0;87;0
WireConnection;85;1;17;0
WireConnection;24;0;22;0
WireConnection;24;1;12;0
WireConnection;27;0;49;0
WireConnection;27;1;31;0
WireConnection;82;0;89;0
WireConnection;82;1;28;0
WireConnection;58;0;5;1
WireConnection;92;0;90;0
WireConnection;22;0;20;0
WireConnection;22;1;91;0
WireConnection;26;0;24;0
WireConnection;26;1;27;0
WireConnection;26;2;68;0
WireConnection;1;2;26;0
WireConnection;1;3;40;0
WireConnection;1;4;102;0
WireConnection;1;5;52;0
ASEEND*/
//CHKSM=1B88EBA587BE3039770B86E22ABD39469DAB14B1