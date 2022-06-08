// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_Dissolve_Basic"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		_Base_tiles_x("Base_tiles_x", Float) = 0.5
		_Base_tiles_y("Base_tiles_y", Float) = 1
		_Base_speed_x("Base_speed_x", Float) = 0.5
		_Base_color("Base_color", Color) = (1,0,0,0)
		_Base_speed_y("Base_speed_y", Float) = 1
		_Alpha_texture("Alpha_texture", 2D) = "white" {}
		[X]_Dissolve_hardness("Dissolve_hardness", Range( 0 , 50)) = 5
		_Alpha_global("Alpha_global", Float) = 0
		_Alpha_Treshold("Alpha_Treshold", Float) = 0
		[Toggle(_MASKLIMITS_ON)] _MaskLimits("Mask Limits ?", Float) = 0

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
			#define _ALPHATEST_ON 1
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

			#pragma shader_feature_local _MASKLIMITS_ON


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

			sampler2D _Alpha_texture;
			CBUFFER_START( UnityPerMaterial )
			float _Base_speed_x;
			float _Base_speed_y;
			float _Base_tiles_x;
			float _Base_tiles_y;
			float4 _Base_color;
			float _Dissolve_hardness;
			float _Alpha_global;
			float _Alpha_Treshold;
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
				float2 appendResult4_g4 = (float2(_Base_speed_x , _Base_speed_y));
				float2 uv03_g4 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g4 = (float2(_Base_tiles_x , _Base_tiles_y));
				float2 panner6_g4 = ( _TimeParameters.x * appendResult4_g4 + ( uv03_g4 * appendResult12_g4 ));
				float4 tex2DNode12 = tex2D( _Alpha_texture, panner6_g4 );
				float Base_B59 = tex2DNode12.b;
				
				float lerpResult5_g7 = lerp( saturate( pow( Base_B59 , _Dissolve_hardness ) ) , 0.0 , _Alpha_global);
				float Base_R66 = tex2DNode12.r;
				#ifdef _MASKLIMITS_ON
				float staticSwitch63 = 0;
				#else
				float staticSwitch63 = (float)1;
				#endif
				float Alpha68 = ( lerpResult5_g7 * staticSwitch63 );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( Base_B59 * _Base_color ).rgb;
				float Alpha = Alpha68;
				float AlphaClipThreshold = _Alpha_Treshold;

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
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 70108

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#pragma shader_feature_local _MASKLIMITS_ON


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

			sampler2D _Alpha_texture;
			CBUFFER_START( UnityPerMaterial )
			float _Base_speed_x;
			float _Base_speed_y;
			float _Base_tiles_x;
			float _Base_tiles_y;
			float4 _Base_color;
			float _Dissolve_hardness;
			float _Alpha_global;
			float _Alpha_Treshold;
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

				float2 appendResult4_g4 = (float2(_Base_speed_x , _Base_speed_y));
				float2 uv03_g4 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g4 = (float2(_Base_tiles_x , _Base_tiles_y));
				float2 panner6_g4 = ( _TimeParameters.x * appendResult4_g4 + ( uv03_g4 * appendResult12_g4 ));
				float4 tex2DNode12 = tex2D( _Alpha_texture, panner6_g4 );
				float Base_B59 = tex2DNode12.b;
				float lerpResult5_g7 = lerp( saturate( pow( Base_B59 , _Dissolve_hardness ) ) , 0.0 , _Alpha_global);
				float Base_R66 = tex2DNode12.r;
				#ifdef _MASKLIMITS_ON
				float staticSwitch63 = 0;
				#else
				float staticSwitch63 = (float)1;
				#endif
				float Alpha68 = ( lerpResult5_g7 * staticSwitch63 );
				
				float Alpha = Alpha68;
				float AlphaClipThreshold = _Alpha_Treshold;

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
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 70108

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#pragma shader_feature_local _MASKLIMITS_ON


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

			sampler2D _Alpha_texture;
			CBUFFER_START( UnityPerMaterial )
			float _Base_speed_x;
			float _Base_speed_y;
			float _Base_tiles_x;
			float _Base_tiles_y;
			float4 _Base_color;
			float _Dissolve_hardness;
			float _Alpha_global;
			float _Alpha_Treshold;
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

				float2 appendResult4_g4 = (float2(_Base_speed_x , _Base_speed_y));
				float2 uv03_g4 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g4 = (float2(_Base_tiles_x , _Base_tiles_y));
				float2 panner6_g4 = ( _TimeParameters.x * appendResult4_g4 + ( uv03_g4 * appendResult12_g4 ));
				float4 tex2DNode12 = tex2D( _Alpha_texture, panner6_g4 );
				float Base_B59 = tex2DNode12.b;
				float lerpResult5_g7 = lerp( saturate( pow( Base_B59 , _Dissolve_hardness ) ) , 0.0 , _Alpha_global);
				float Base_R66 = tex2DNode12.r;
				#ifdef _MASKLIMITS_ON
				float staticSwitch63 = 0;
				#else
				float staticSwitch63 = (float)1;
				#endif
				float Alpha68 = ( lerpResult5_g7 * staticSwitch63 );
				
				float Alpha = Alpha68;
				float AlphaClipThreshold = _Alpha_Treshold;

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
0;6;1280;653;4122.234;1558.549;5.322836;True;False
Node;AmplifyShaderEditor.RangedFloatNode;6;-1696.324,339.2679;Inherit;False;Property;_Base_tiles_x;Base_tiles_x;0;0;Create;True;0;0;False;0;0.5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-2118.508,316.2397;Inherit;False;Property;_Base_speed_y;Base_speed_y;4;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1851.377,365.5962;Inherit;False;Property;_Base_tiles_y;Base_tiles_y;1;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-1941.051,294.2702;Inherit;False;Property;_Base_speed_x;Base_speed_x;2;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;42;-1333.658,298.4335;Inherit;False;MF_Tiles;-1;;4;2fa329d2d99691549897442d611b24f3;0;5;7;FLOAT;0;False;8;FLOAT;0;False;10;FLOAT;1;False;13;FLOAT;1;False;11;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;12;-928.636,273.2058;Inherit;True;Property;_Alpha_texture;Alpha_texture;5;0;Create;True;0;0;False;0;-1;009ff81c0b3a7704f873ac7ceef2a4be;501bf83ae75581a4f94f6942675f413f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;-172.9066,294.8428;Inherit;False;Base_R;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;64;113.9234,698.8444;Inherit;False;Constant;_int;int;10;0;Create;True;0;0;False;0;1;0;0;1;INT;0
Node;AmplifyShaderEditor.GetLocalVarNode;67;-200.249,721.0151;Inherit;False;66;Base_R;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;-550.812,345.7785;Inherit;False;Base_B;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-175.2635,583.2892;Inherit;False;Property;_Dissolve_hardness;Dissolve_hardness;6;0;Create;True;0;0;False;1;X;5;1;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;63;328.4323,698.7294;Inherit;False;Property;_MaskLimits;Mask Limits ?;9;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;131.2406,557.7595;Inherit;False;Property;_Alpha_global;Alpha_global;7;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;62;358.2992,612.8155;Inherit;False;59;Base_B;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;53;586.3978,570.6716;Inherit;True;MF_Alpha_handler;-1;;7;9ba53a059d6724547ba534bf0c40c79e;0;4;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;13;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;71;-2635.316,-594.0522;Inherit;False;1206.044;391.8071;[HACK];4;57;38;58;46;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;1020.092,566.0249;Inherit;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;-369.5105,-39.75239;Inherit;False;59;Base_B;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;10;-597.4957,-20.15805;Inherit;False;Property;_Base_color;Base_color;3;0;Create;True;0;0;False;0;1,0,0,0;0.2358491,0.2358491,0.2358491,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-106.831,-32.44926;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;58;-2585.316,-544.0522;Inherit;True;Property;_TextureSample0;Texture Sample 0;5;0;Create;True;0;0;False;0;-1;009ff81c0b3a7704f873ac7ceef2a4be;501bf83ae75581a4f94f6942675f413f;True;0;False;white;Auto;False;Instance;12;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-1887.275,-488.473;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;1020.421,-1.447173;Inherit;False;68;Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;820.5759,22.27533;Inherit;False;Property;_Alpha_Treshold;Alpha_Treshold;8;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;57;-1664.272,-456.2451;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;38;-2106.206,-515.7219;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-361.8041,327.5702;Inherit;False;Base_G;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;33;1445.736,-20.92768;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;M_Dissolve_Basic;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;1;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;True;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;32;781.947,-20.64511;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;34;781.947,-20.64511;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;35;781.947,-20.64511;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;36;781.947,-20.64511;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;42;7;1;0
WireConnection;42;8;2;0
WireConnection;42;10;6;0
WireConnection;42;13;7;0
WireConnection;12;1;42;0
WireConnection;66;0;12;1
WireConnection;59;0;12;3
WireConnection;63;1;64;0
WireConnection;63;0;67;0
WireConnection;53;6;17;0
WireConnection;53;7;15;0
WireConnection;53;8;62;0
WireConnection;53;13;63;0
WireConnection;68;0;53;0
WireConnection;13;0;61;0
WireConnection;13;1;10;0
WireConnection;46;0;58;2
WireConnection;57;0;58;3
WireConnection;38;0;58;1
WireConnection;65;0;12;2
WireConnection;33;2;13;0
WireConnection;33;3;69;0
WireConnection;33;4;37;0
ASEEND*/
//CHKSM=2166E48381D621AE7C514BD9C79B1C1CE6DA9FDC