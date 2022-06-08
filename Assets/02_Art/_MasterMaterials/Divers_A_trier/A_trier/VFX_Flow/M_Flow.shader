// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_Flow"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		_Base_texture("Base_texture", 2D) = "white" {}
		_Base_tiles_x("Base_tiles_x", Float) = 0.5
		_Base_tiles_y("Base_tiles_y", Float) = 1
		_Base_color("Base_color", Color) = (0.2917078,1,0,0)
		_Base_speed_x("Base_speed_x", Float) = 0.5
		_Base_speed_y("Base_speed_y", Float) = 1
		_Emissive_color("Emissive_color", Color) = (1,0,0,0)
		_Emissive_intensity("Emissive_intensity", Float) = 10
		_Emissive_treshold("Emissive_treshold", Float) = 10
		_Dissolve_hardness("Dissolve_hardness", Float) = 30
		_GlobalAlpha("Global Alpha", Float) = 0
		[Toggle(_MASK_LIMITS_ON)] _Mask_limits("Mask_limits?", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

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
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 70108

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

			#pragma shader_feature_local _MASK_LIMITS_ON


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _Base_texture;
			CBUFFER_START( UnityPerMaterial )
			float _Base_speed_x;
			float _Base_speed_y;
			float _Base_tiles_x;
			float _Base_tiles_y;
			float4 _Base_color;
			float _Emissive_treshold;
			float _Emissive_intensity;
			float4 _Emissive_color;
			float _Dissolve_hardness;
			float _GlobalAlpha;
			float4 _Base_texture_ST;
			CBUFFER_END


			
			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
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
				float2 appendResult4_g2 = (float2(_Base_speed_x , _Base_speed_y));
				float2 uv03_g2 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g2 = (float2(_Base_tiles_x , _Base_tiles_y));
				float2 panner6_g2 = ( _TimeParameters.x * appendResult4_g2 + ( uv03_g2 * appendResult12_g2 ));
				float Base77 = tex2D( _Base_texture, panner6_g2 ).r;
				float temp_output_2_0_g10 = ( pow( Base77 , _Emissive_treshold ) * _Emissive_intensity );
				float4 lerpResult106 = lerp( ( Base77 * _Base_color ) , ( temp_output_2_0_g10 * _Emissive_color ) , temp_output_2_0_g10);
				
				float lerpResult5_g8 = lerp( saturate( pow( Base77 , _Dissolve_hardness ) ) , 0.0 , _GlobalAlpha);
				float2 uv_Base_texture = IN.ase_texcoord3.xy * _Base_texture_ST.xy + _Base_texture_ST.zw;
				#ifdef _MASK_LIMITS_ON
				float staticSwitch91 = tex2D( _Base_texture, uv_Base_texture ).g;
				#else
				float staticSwitch91 = (float)1;
				#endif
				float temp_output_102_0 = ( lerpResult5_g8 * staticSwitch91 );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult106.rgb;
				float Alpha = temp_output_102_0;
				float AlphaClipThreshold = 0.5;

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
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 70108

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#pragma shader_feature_local _MASK_LIMITS_ON


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _Base_texture;
			CBUFFER_START( UnityPerMaterial )
			float _Base_speed_x;
			float _Base_speed_y;
			float _Base_tiles_x;
			float _Base_tiles_y;
			float4 _Base_color;
			float _Emissive_treshold;
			float _Emissive_intensity;
			float4 _Emissive_color;
			float _Dissolve_hardness;
			float _GlobalAlpha;
			float4 _Base_texture_ST;
			CBUFFER_END


			
			float3 _LightDirection;

			VertexOutput ShadowPassVertex( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
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

				float3 normalWS = TransformObjectToWorldDir( v.ase_normal );

				float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = clipPos;

				return o;
			}

			half4 ShadowPassFragment(VertexOutput IN  ) : SV_TARGET
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

				float2 appendResult4_g2 = (float2(_Base_speed_x , _Base_speed_y));
				float2 uv03_g2 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g2 = (float2(_Base_tiles_x , _Base_tiles_y));
				float2 panner6_g2 = ( _TimeParameters.x * appendResult4_g2 + ( uv03_g2 * appendResult12_g2 ));
				float Base77 = tex2D( _Base_texture, panner6_g2 ).r;
				float lerpResult5_g8 = lerp( saturate( pow( Base77 , _Dissolve_hardness ) ) , 0.0 , _GlobalAlpha);
				float2 uv_Base_texture = IN.ase_texcoord2.xy * _Base_texture_ST.xy + _Base_texture_ST.zw;
				#ifdef _MASK_LIMITS_ON
				float staticSwitch91 = tex2D( _Base_texture, uv_Base_texture ).g;
				#else
				float staticSwitch91 = (float)1;
				#endif
				float temp_output_102_0 = ( lerpResult5_g8 * staticSwitch91 );
				
				float Alpha = temp_output_102_0;
				float AlphaClipThreshold = 0.5;

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

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 70108

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#pragma shader_feature_local _MASK_LIMITS_ON


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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _Base_texture;
			CBUFFER_START( UnityPerMaterial )
			float _Base_speed_x;
			float _Base_speed_y;
			float _Base_tiles_x;
			float _Base_tiles_y;
			float4 _Base_color;
			float _Emissive_treshold;
			float _Emissive_intensity;
			float4 _Emissive_color;
			float _Dissolve_hardness;
			float _GlobalAlpha;
			float4 _Base_texture_ST;
			CBUFFER_END


			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
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

				float2 appendResult4_g2 = (float2(_Base_speed_x , _Base_speed_y));
				float2 uv03_g2 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g2 = (float2(_Base_tiles_x , _Base_tiles_y));
				float2 panner6_g2 = ( _TimeParameters.x * appendResult4_g2 + ( uv03_g2 * appendResult12_g2 ));
				float Base77 = tex2D( _Base_texture, panner6_g2 ).r;
				float lerpResult5_g8 = lerp( saturate( pow( Base77 , _Dissolve_hardness ) ) , 0.0 , _GlobalAlpha);
				float2 uv_Base_texture = IN.ase_texcoord2.xy * _Base_texture_ST.xy + _Base_texture_ST.zw;
				#ifdef _MASK_LIMITS_ON
				float staticSwitch91 = tex2D( _Base_texture, uv_Base_texture ).g;
				#else
				float staticSwitch91 = (float)1;
				#endif
				float temp_output_102_0 = ( lerpResult5_g8 * staticSwitch91 );
				
				float Alpha = temp_output_102_0;
				float AlphaClipThreshold = 0.5;

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
0;6;1280;653;484.455;1180.521;4.584827;True;False
Node;AmplifyShaderEditor.CommentaryNode;84;-871.1425,-67.94369;Inherit;False;1948.585;488.4522;Base;7;55;56;77;9;96;51;52;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-668.2203,83.37289;Inherit;False;Property;_Base_tiles_y;Base_tiles_y;2;0;Create;True;0;0;False;0;1;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-825.4173,53.72977;Inherit;False;Property;_Base_tiles_x;Base_tiles_x;1;0;Create;True;0;0;False;0;0.5;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-365.1158,4.766998;Inherit;False;Property;_Base_speed_x;Base_speed_x;4;0;Create;True;0;0;False;0;0.5;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-530.3027,30.04956;Inherit;False;Property;_Base_speed_y;Base_speed_y;5;0;Create;True;0;0;False;0;1;-2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;96;139.4495,16.11628;Inherit;False;MF_Tiles;-1;;2;2fa329d2d99691549897442d611b24f3;0;5;7;FLOAT;0;False;8;FLOAT;0;False;10;FLOAT;1;False;13;FLOAT;1;False;11;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;86;1209.146,590.1814;Inherit;False;2212.157;750.5326;Alpha;9;25;22;39;92;80;91;102;82;26;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;9;553.4825,-14.89056;Inherit;True;Property;_Base_texture;Base_texture;0;0;Create;True;0;0;False;0;-1;3a13eb772f717e4438e43156387014e6;3a13eb772f717e4438e43156387014e6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;870.8691,8.270119;Inherit;False;Base;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;92;1943.803,749.8495;Inherit;False;Constant;_Int;Int;16;0;Create;True;0;0;False;0;1;0;0;1;INT;0
Node;AmplifyShaderEditor.SamplerNode;39;1464.68,725.1047;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;-1;3a13eb772f717e4438e43156387014e6;3a13eb772f717e4438e43156387014e6;True;0;False;white;Auto;False;Instance;9;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;91;2230.573,748.3586;Inherit;False;Property;_Mask_limits;Mask_limits?;15;0;Create;True;0;0;False;0;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;2080.421,693.9985;Inherit;False;Property;_Dissolve_hardness;Dissolve_hardness;13;0;Create;True;0;0;False;0;30;0.31;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;1783.333,720.0778;Inherit;False;77;Base;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;83;1721.953,-363.1122;Inherit;False;1786.151;524.9719;Color;13;106;78;14;107;12;65;69;68;67;11;79;20;16;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;25;1918.817,665.8311;Inherit;False;Property;_GlobalAlpha;Global Alpha;14;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;87;-1772.306,14;Inherit;False;604.7035;338.9463;Var;4;7;73;10;71;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;85;-843.9161,867.9753;Inherit;False;1925.17;436.7697;Mask;7;37;62;58;59;61;81;95;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;14;1774.125,5.087047;Inherit;False;Property;_Emissive_treshold;Emissive_treshold;8;0;Create;True;0;0;False;0;10;3.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;10;-1659.965,68.86613;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;12;2532.545,-301.0124;Inherit;False;Property;_Base_color;Base_color;3;0;Create;True;0;0;False;0;0.2917078,1,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;59;-446.7213,932.3364;Inherit;False;Property;_Mask_speed_x;Mask_speed_x;11;0;Create;True;0;0;False;0;0.5;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;3006.069,-319.7925;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;102;2454.507,675.9406;Inherit;True;MF_Alpha_handler;-1;;8;9ba53a059d6724547ba534bf0c40c79e;0;4;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;13;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-741.9442,983.0077;Inherit;False;Property;_Mask_tiles_x;Mask_tiles_x;9;0;Create;True;0;0;False;0;0.5;0.59;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-287.8405,960.28;Inherit;False;Property;_Mask_speed_y;Mask_speed_y;12;0;Create;True;0;0;False;0;1;-0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;107;2697.261,-71.14082;Inherit;False;MF_Emissive_handler;-1;;10;4c2d144224f39b24a93af8da62996f6d;0;4;11;FLOAT;0;False;9;COLOR;0,0,0,0;False;10;FLOAT;0;False;12;FLOAT;0;False;2;COLOR;0;FLOAT;13
Node;AmplifyShaderEditor.RangedFloatNode;16;2328.747,-23.72383;Inherit;False;Property;_Emissive_intensity;Emissive_intensity;7;0;Create;True;0;0;False;0;10;11.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;2067.863,-75.97072;Inherit;False;77;Base;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;20;2324.856,-211.2943;Inherit;False;Property;_Emissive_color;Emissive_color;6;0;Create;True;0;0;False;0;1,0,0,0;0,0.9062204,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;37;529.4353,917.9753;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;False;0;-1;3a13eb772f717e4438e43156387014e6;3a13eb772f717e4438e43156387014e6;True;0;False;white;Auto;False;Instance;9;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;71;-1408.083,64;Inherit;False;TIMEglobal;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;81;872.098,935.9581;Inherit;False;Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;82;2796.444,692.9423;Inherit;False;81;Mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;95;131.3794,942.6552;Inherit;False;MF_Tiles;-1;;3;2fa329d2d99691549897442d611b24f3;0;5;7;FLOAT;0;False;8;FLOAT;0;False;10;FLOAT;1;False;13;FLOAT;1;False;11;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;2838.974,-228.0657;Inherit;False;77;Base;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;3002.593,673.9604;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-570.2802,1008.153;Inherit;False;Property;_Mask_tiles_y;Mask_tiles_y;10;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;-1414.603,190.7126;Inherit;False;texturecoordinates;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-1719.706,195.2463;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;106;3238.613,-95.582;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;67;3124.57,19.53975;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;66;3946.433,649.8242;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;M_Flow;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;1;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;True;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;69;3124.57,19.53975;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;68;3124.57,19.53975;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;65;3081.695,-312.4705;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;96;7;51;0
WireConnection;96;8;52;0
WireConnection;96;10;55;0
WireConnection;96;13;56;0
WireConnection;9;1;96;0
WireConnection;77;0;9;1
WireConnection;91;1;92;0
WireConnection;91;0;39;2
WireConnection;11;0;79;0
WireConnection;11;1;12;0
WireConnection;102;6;25;0
WireConnection;102;7;22;0
WireConnection;102;8;80;0
WireConnection;102;13;91;0
WireConnection;107;11;78;0
WireConnection;107;9;20;0
WireConnection;107;10;16;0
WireConnection;107;12;14;0
WireConnection;37;1;95;0
WireConnection;71;0;10;0
WireConnection;81;0;37;3
WireConnection;95;7;59;0
WireConnection;95;8;58;0
WireConnection;95;10;61;0
WireConnection;95;13;62;0
WireConnection;26;0;102;0
WireConnection;26;1;82;0
WireConnection;73;0;7;0
WireConnection;106;0;11;0
WireConnection;106;1;107;0
WireConnection;106;2;107;13
WireConnection;66;2;106;0
WireConnection;66;3;102;0
ASEEND*/
//CHKSM=FE4853EACA660AC720CCB0BC18A97D525A876EAC