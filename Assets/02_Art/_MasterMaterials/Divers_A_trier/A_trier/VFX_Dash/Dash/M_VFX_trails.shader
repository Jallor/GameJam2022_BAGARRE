// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_VFX_trails"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_Main_Texture_Trail("Main_Texture_Trail", 2D) = "white" {}
		_Main_alpha_VisibilitySharpnessRCHANNEL("Main_alpha_Visibility/Sharpness  (R CHANNEL)", Range( 0 , 10)) = 1
		_Main_ColorRCHANNEL("Main_Color (R CHANNEL)", Color) = (0,1,0.8853862,0)
		_Main_emissive_IntensityRCHANNEL("Main_emissive_Intensity (R CHANNEL)", Range( 0 , 200)) = 0
		_Main_speed_X("Main_speed_X", Range( -10 , 10)) = 1.75
		_Main_speed_Y("Main_speed_Y", Range( -10 , 10)) = 0
		_Second_alpha_VisibilitySharpnessGCHANNEL("Second_alpha_Visibility/Sharpness (G CHANNEL)", Range( 0 , 10)) = 1
		_Second_ColorGCHANNEL("Second_Color (G CHANNEL)", Color) = (1,0,0,0)
		_Second_emissive_IntensityGCHANNEL("Second_emissive_Intensity (G CHANNEL)", Range( 0 , 200)) = 2
		_Second_speed_X("Second_speed_X", Range( -10 , 10)) = 1
		_Second_speed_Y("Second_speed_Y", Range( -10 , 10)) = 0
		_Third_alpha_VisibilitySharpnessBCHANNEL("Third_alpha_Visibility/Sharpness (B CHANNEL)", Range( 0 , 10)) = 1
		_Third_ColorBCHANNEL("Third_Color (B CHANNEL)", Color) = (0.2823446,1,0,0)
		_Third_emissive_IntensityBCHANNEL("Third_emissive_Intensity (B CHANNEL)", Range( 0 , 200)) = 2
		_Third_speed_X("Third_speed_X", Range( -10 , 10)) = 1
		_Third_speed_Y("Third_speed_Y", Range( -10 , 10)) = 0
		_ErosionTexture("Erosion Texture", 2D) = "white" {}
		_dissolve_Intensity("dissolve_Intensity", Float) = 1
		_dissolve_invert("dissolve_invert ?", Float) = -0.2
		_alpha_Treshold("alpha_Treshold", Range( 0 , 1)) = 0

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

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
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
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _Main_Texture_Trail;
			sampler2D _ErosionTexture;
			CBUFFER_START( UnityPerMaterial )
			float _Second_speed_X;
			float _Second_speed_Y;
			float4 _Second_ColorGCHANNEL;
			float _Second_emissive_IntensityGCHANNEL;
			float4 _Main_ColorRCHANNEL;
			float _Main_speed_X;
			float _Main_speed_Y;
			float _Main_emissive_IntensityRCHANNEL;
			float _Main_alpha_VisibilitySharpnessRCHANNEL;
			float4 _Third_ColorBCHANNEL;
			float _Third_speed_X;
			float _Third_speed_Y;
			float _Third_emissive_IntensityBCHANNEL;
			float _Third_alpha_VisibilitySharpnessBCHANNEL;
			float _Second_alpha_VisibilitySharpnessGCHANNEL;
			float _dissolve_Intensity;
			float _dissolve_invert;
			float _alpha_Treshold;
			CBUFFER_END


			
			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
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
				float2 appendResult4_g4 = (float2(_Second_speed_X , _Second_speed_Y));
				float2 uv07 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 Texturecoord99 = uv07;
				float2 appendResult12_g4 = (float2(1.0 , 1.0));
				float2 panner6_g4 = ( _TimeParameters.x * appendResult4_g4 + ( Texturecoord99 * appendResult12_g4 ));
				float2 temp_output_97_0 = panner6_g4;
				float4 tex2DNode59 = tex2D( _Main_Texture_Trail, temp_output_97_0 );
				float4 Second_GREEN_CHANNEL105 = ( ( tex2DNode59.g * _Second_ColorGCHANNEL ) * _Second_emissive_IntensityGCHANNEL );
				float2 appendResult4_g3 = (float2(_Main_speed_X , _Main_speed_Y));
				float2 appendResult12_g3 = (float2(1.0 , 1.0));
				float2 panner6_g3 = ( _TimeParameters.x * appendResult4_g3 + ( Texturecoord99 * appendResult12_g3 ));
				float2 temp_output_96_0 = panner6_g3;
				float4 tex2DNode5 = tex2D( _Main_Texture_Trail, temp_output_96_0 );
				float4 Main_RED_CHANNEL107 = ( ( _Main_ColorRCHANNEL * tex2DNode5.r ) * _Main_emissive_IntensityRCHANNEL );
				float MainAlpha_RED_CHANNEL109 = saturate( ( tex2DNode5.r * _Main_alpha_VisibilitySharpnessRCHANNEL ) );
				float4 lerpResult55 = lerp( Second_GREEN_CHANNEL105 , Main_RED_CHANNEL107 , MainAlpha_RED_CHANNEL109);
				float2 appendResult4_g5 = (float2(_Third_speed_X , _Third_speed_Y));
				float2 appendResult12_g5 = (float2(1.0 , 1.0));
				float2 panner6_g5 = ( _TimeParameters.x * appendResult4_g5 + ( Texturecoord99 * appendResult12_g5 ));
				float4 tex2DNode73 = tex2D( _Main_Texture_Trail, panner6_g5 );
				float4 Third_BLUE_CHANNEL103 = ( ( _Third_ColorBCHANNEL * tex2DNode73.b ) * _Third_emissive_IntensityBCHANNEL );
				float ThirdAlpha_BLUE_CHANNEL110 = saturate( ( tex2DNode73.b * _Third_alpha_VisibilitySharpnessBCHANNEL ) );
				float4 lerpResult80 = lerp( lerpResult55 , Third_BLUE_CHANNEL103 , ThirdAlpha_BLUE_CHANNEL110);
				float4 Albedo120 = lerpResult80;
				
				float SecondAlpha_GREEN_CHANNEL111 = saturate( ( tex2DNode59.g * _Second_alpha_VisibilitySharpnessGCHANNEL ) );
				float Alpha_From_GlobalTex93 = saturate( ( ThirdAlpha_BLUE_CHANNEL110 + ( MainAlpha_RED_CHANNEL109 + SecondAlpha_GREEN_CHANNEL111 ) ) );
				float2 Erosion_Tiles_and_Speed122 = ( ( temp_output_97_0 + temp_output_96_0 ) / 2 );
				float2 uv025 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_18_0 = (( _dissolve_Intensity * _dissolve_invert ) + (uv025.x - 0.0) * (1.0 - ( _dissolve_Intensity * _dissolve_invert )) / (1.0 - 0.0));
				float GlobalAlpha94 = saturate( ( IN.ase_color.a * ( Alpha_From_GlobalTex93 * saturate( ( ( tex2D( _ErosionTexture, Erosion_Tiles_and_Speed122 ).r - temp_output_18_0 ) / ( ( temp_output_18_0 + _dissolve_Intensity ) - temp_output_18_0 ) ) ) ) ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = Albedo120.rgb;
				float Alpha = GlobalAlpha94;
				float AlphaClipThreshold = _alpha_Treshold;

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

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_color : COLOR;
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
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _Main_Texture_Trail;
			sampler2D _ErosionTexture;
			CBUFFER_START( UnityPerMaterial )
			float _Second_speed_X;
			float _Second_speed_Y;
			float4 _Second_ColorGCHANNEL;
			float _Second_emissive_IntensityGCHANNEL;
			float4 _Main_ColorRCHANNEL;
			float _Main_speed_X;
			float _Main_speed_Y;
			float _Main_emissive_IntensityRCHANNEL;
			float _Main_alpha_VisibilitySharpnessRCHANNEL;
			float4 _Third_ColorBCHANNEL;
			float _Third_speed_X;
			float _Third_speed_Y;
			float _Third_emissive_IntensityBCHANNEL;
			float _Third_alpha_VisibilitySharpnessBCHANNEL;
			float _Second_alpha_VisibilitySharpnessGCHANNEL;
			float _dissolve_Intensity;
			float _dissolve_invert;
			float _alpha_Treshold;
			CBUFFER_END


			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_color = v.ase_color;
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

				float2 appendResult4_g5 = (float2(_Third_speed_X , _Third_speed_Y));
				float2 uv07 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 Texturecoord99 = uv07;
				float2 appendResult12_g5 = (float2(1.0 , 1.0));
				float2 panner6_g5 = ( _TimeParameters.x * appendResult4_g5 + ( Texturecoord99 * appendResult12_g5 ));
				float4 tex2DNode73 = tex2D( _Main_Texture_Trail, panner6_g5 );
				float ThirdAlpha_BLUE_CHANNEL110 = saturate( ( tex2DNode73.b * _Third_alpha_VisibilitySharpnessBCHANNEL ) );
				float2 appendResult4_g3 = (float2(_Main_speed_X , _Main_speed_Y));
				float2 appendResult12_g3 = (float2(1.0 , 1.0));
				float2 panner6_g3 = ( _TimeParameters.x * appendResult4_g3 + ( Texturecoord99 * appendResult12_g3 ));
				float2 temp_output_96_0 = panner6_g3;
				float4 tex2DNode5 = tex2D( _Main_Texture_Trail, temp_output_96_0 );
				float MainAlpha_RED_CHANNEL109 = saturate( ( tex2DNode5.r * _Main_alpha_VisibilitySharpnessRCHANNEL ) );
				float2 appendResult4_g4 = (float2(_Second_speed_X , _Second_speed_Y));
				float2 appendResult12_g4 = (float2(1.0 , 1.0));
				float2 panner6_g4 = ( _TimeParameters.x * appendResult4_g4 + ( Texturecoord99 * appendResult12_g4 ));
				float2 temp_output_97_0 = panner6_g4;
				float4 tex2DNode59 = tex2D( _Main_Texture_Trail, temp_output_97_0 );
				float SecondAlpha_GREEN_CHANNEL111 = saturate( ( tex2DNode59.g * _Second_alpha_VisibilitySharpnessGCHANNEL ) );
				float Alpha_From_GlobalTex93 = saturate( ( ThirdAlpha_BLUE_CHANNEL110 + ( MainAlpha_RED_CHANNEL109 + SecondAlpha_GREEN_CHANNEL111 ) ) );
				float2 Erosion_Tiles_and_Speed122 = ( ( temp_output_97_0 + temp_output_96_0 ) / 2 );
				float2 uv025 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_18_0 = (( _dissolve_Intensity * _dissolve_invert ) + (uv025.x - 0.0) * (1.0 - ( _dissolve_Intensity * _dissolve_invert )) / (1.0 - 0.0));
				float GlobalAlpha94 = saturate( ( IN.ase_color.a * ( Alpha_From_GlobalTex93 * saturate( ( ( tex2D( _ErosionTexture, Erosion_Tiles_and_Speed122 ).r - temp_output_18_0 ) / ( ( temp_output_18_0 + _dissolve_Intensity ) - temp_output_18_0 ) ) ) ) ) );
				
				float Alpha = GlobalAlpha94;
				float AlphaClipThreshold = _alpha_Treshold;

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
7;1;1789;794;1125.355;1257.955;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;131;-3523.03,-489.5309;Inherit;False;527.2043;213.5834;;2;7;99;Var;0,1,0,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-3473.03,-434.9475;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;128;-2947.6,-1130.962;Inherit;False;1978.555;1555.862;;16;122;102;64;63;65;98;97;101;69;70;96;31;100;62;60;30;SPEED CONTROL ;0,0.2941177,0.4901961,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;-3219.826,-439.5309;Inherit;False;Texturecoord;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-2646.49,-446.8117;Inherit;False;Property;_Second_speed_Y;Second_speed_Y;10;0;Create;True;0;0;False;0;0;0;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2356.845,-469.5187;Inherit;False;Property;_Second_speed_X;Second_speed_X;9;0;Create;True;0;0;False;0;1;5;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-2640.798,232.1523;Inherit;False;Property;_Main_speed_Y;Main_speed_Y;5;0;Create;True;0;0;False;0;0;0;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2353.921,206.1559;Inherit;False;Property;_Main_speed_X;Main_speed_X;4;0;Create;True;0;0;False;0;1.75;3;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;100;-2070.247,-494.3999;Inherit;False;99;Texturecoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-2058.85,180.2181;Inherit;False;99;Texturecoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;-2082.127,-1080.962;Inherit;False;99;Texturecoord;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;97;-1867.808,-488.8717;Inherit;False;MF_Tiles;-1;;4;2fa329d2d99691549897442d611b24f3;0;6;14;FLOAT2;0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;10;FLOAT;1;False;13;FLOAT;1;False;11;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-2656.617,-1031.566;Inherit;False;Property;_Third_speed_Y;Third_speed_Y;15;0;Create;True;0;0;False;0;0;0;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;96;-1864.86,189.2104;Inherit;False;MF_Tiles;-1;;3;2fa329d2d99691549897442d611b24f3;0;6;14;FLOAT2;0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;10;FLOAT;1;False;13;FLOAT;1;False;11;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;127;-698.1642,-1255.092;Inherit;False;1850.133;1780.368;Color, Emissive, Alpha Sharpness ;34;87;5;88;59;84;86;89;73;83;116;117;118;111;109;110;57;77;50;107;38;35;11;103;58;56;105;76;75;51;78;4;3;2;0;CREATION & LAYERING;0.1730798,1,0,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-2353.981,-1055.608;Inherit;False;Property;_Third_speed_X;Third_speed_X;14;0;Create;True;0;0;False;0;1;1.15;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;98;-1875.085,-1075.156;Inherit;False;MF_Tiles;-1;;5;2fa329d2d99691549897442d611b24f3;0;6;14;FLOAT2;0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;10;FLOAT;1;False;13;FLOAT;1;False;11;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-500.8267,-244.6544;Inherit;False;Property;_Second_alpha_VisibilitySharpnessGCHANNEL;Second_alpha_Visibility/Sharpness (G CHANNEL);6;0;Create;True;0;0;False;0;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-494.2931,160.3215;Inherit;True;Property;_Main_Texture_Trail;Main_Texture_Trail;0;0;Create;True;0;0;False;0;-1;6f2db230e8b7fdc4ca51eeb024e58604;6f2db230e8b7fdc4ca51eeb024e58604;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;88;-485.7356,409.2762;Inherit;False;Property;_Main_alpha_VisibilitySharpnessRCHANNEL;Main_alpha_Visibility/Sharpness  (R CHANNEL);1;0;Create;True;0;0;False;0;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;59;-498.6828,-517.947;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;5;ef2e21409b9fed846b44912603f3f386;ef2e21409b9fed846b44912603f3f386;True;0;False;white;Auto;False;Instance;5;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-116.2894,389.1925;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-117.657,-262.0295;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-499.4327,-838.3024;Inherit;False;Property;_Third_alpha_VisibilitySharpnessBCHANNEL;Third_alpha_Visibility/Sharpness (B CHANNEL);11;0;Create;True;0;0;False;0;1;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;73;-503.7053,-1096.916;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;False;0;5;ef2e21409b9fed846b44912603f3f386;ef2e21409b9fed846b44912603f3f386;True;0;False;white;Auto;False;Instance;5;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;63;-1606.493,-144.3134;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.IntNode;65;-1608.055,-48.94393;Inherit;False;Constant;_2;2;13;0;Create;True;0;0;False;0;2;0;0;1;INT;0
Node;AmplifyShaderEditor.CommentaryNode;125;-667.6237,1352.196;Inherit;False;3199.051;804.4775;Handle dissolve, add global texture alpha, and add vertex alpha along U ;18;94;24;23;22;25;123;18;17;8;19;16;15;92;14;12;26;27;28;ALPHA & Dissolve Handler;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-89.897,-854.9713;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;117;33.13237,-263.2606;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;116;65.88381,390.1296;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;64;-1472.708,-112.1706;Inherit;False;2;0;FLOAT2;0,0;False;1;INT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;109;229.124,383.226;Inherit;False;MainAlpha_RED_CHANNEL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;118;96.17165,-854.6839;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-400.6755,1924.186;Inherit;False;Property;_dissolve_Intensity;dissolve_Intensity;17;0;Create;True;0;0;False;0;1;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-221.2313,2040.674;Inherit;False;Property;_dissolve_invert;dissolve_invert ?;18;0;Create;True;0;0;False;0;-0.2;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;199.7761,-270.1539;Inherit;False;SecondAlpha_GREEN_CHANNEL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;126;-686.7762,742.3718;Inherit;False;1847.527;380.4055;Mix alpha from all textures and layers;7;93;54;66;53;114;113;112;ALPHA_mixer;0.3915094,1,0.6862745,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;25;-617.6237,1633.118;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-90.49911,1881.207;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;110;232.0322,-859.9139;Inherit;False;ThirdAlpha_BLUE_CHANNEL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;122;-1285.849,-117.2728;Inherit;False;Erosion_Tiles_and_Speed;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;-609.6468,815.1002;Inherit;False;109;MainAlpha_RED_CHANNEL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;-636.7762,893.7169;Inherit;False;111;SecondAlpha_GREEN_CHANNEL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;-279.8525,792.3718;Inherit;False;110;ThirdAlpha_BLUE_CHANNEL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;123;-133.2366,1426.917;Inherit;False;122;Erosion_Tiles_and_Speed;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-222.9624,874.2568;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;18;160.2492,1665.543;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;342.7951,1904.744;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;8;143.1684,1402.196;Inherit;True;Property;_ErosionTexture;Erosion Texture;16;0;Create;True;0;0;False;0;-1;6c146ff0f15371b458baae42e53ac446;6c146ff0f15371b458baae42e53ac446;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;66;42.30646,850.4513;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;54;382.9253,849.1378;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;19;497.2026,1644.516;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;16;484.2029,1775.815;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;555.0177,845.2247;Inherit;False;Alpha_From_GlobalTex;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;15;661.0029,1667.915;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;1020.9,1639.125;Inherit;False;93;Alpha_From_GlobalTex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;14;804.8574,1668.565;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;26;1748.903,1409.853;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;1555.917,1645.782;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;1957.109,1623.557;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;28;2125.833,1622.818;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;2307.426,1617.51;Inherit;False;GlobalAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;129;2571.046,-226.9904;Inherit;False;1363.151;475.0334;;8;104;108;106;55;120;80;115;119;COLOR_mixer;1,1,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;130;4107.873,-218.86;Inherit;False;849.6094;469.9986;;4;1;13;95;121;OUTPUT;0.07035923,1,0,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;642.8812,-1039.71;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;105;683.8958,-462.9186;Inherit;False;Second_GREEN_CHANNEL;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;50;-126.8581,2.9974;Inherit;False;Property;_Main_ColorRCHANNEL;Main_Color (R CHANNEL);2;0;Create;True;0;0;False;0;0,1,0.8853862,0;0.2282166,1,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;51;-134.5117,-643.844;Inherit;False;Property;_Second_ColorGCHANNEL;Second_Color (G CHANNEL);7;0;Create;True;0;0;False;0;1,0,0,0;0.07168005,0,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;201.0992,-462.4189;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;75;202.4401,-942.3801;Inherit;False;Property;_Third_emissive_IntensityBCHANNEL;Third_emissive_Intensity (B CHANNEL);13;0;Create;True;0;0;False;0;2;59.1;0;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;4157.874,-66.41955;Inherit;False;Property;_alpha_Treshold;alpha_Treshold;19;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;2914.339,132.0429;Inherit;False;110;ThirdAlpha_BLUE_CHANNEL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;80;3388.817,-93.53214;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;58;198.3247,-369.0061;Inherit;False;Property;_Second_emissive_IntensityGCHANNEL;Second_emissive_Intensity (G CHANNEL);8;0;Create;True;0;0;False;0;2;8;0;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;2621.046,-95.72147;Inherit;False;105;Second_GREEN_CHANNEL;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;2628.389,62.95285;Inherit;False;109;MainAlpha_RED_CHANNEL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;2657.623,-18.60561;Inherit;False;107;Main_RED_CHANNEL;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;120;3710.197,-99.2493;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;107;701.4283,162.857;Inherit;False;Main_RED_CHANNEL;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;490.3887,166.3536;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;95;4427.266,-88.86932;Inherit;False;94;GlobalAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;194.2923,272.19;Inherit;False;Property;_Main_emissive_IntensityRCHANNEL;Main_emissive_Intensity (R CHANNEL);3;0;Create;True;0;0;False;0;0;20;0;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;104;2939.106,-176.9904;Inherit;False;103;Third_BLUE_CHANNEL;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;192.326,165.0416;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;201.1684,-1039.197;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;103;888.969,-1047.288;Inherit;False;Third_BLUE_CHANNEL;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;484.1447,-459.4828;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;55;2940.865,-91.58401;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;121;4440.124,-168.86;Inherit;False;120;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;78;-95.35393,-1205.092;Inherit;False;Property;_Third_ColorBCHANNEL;Third_Color (B CHANNEL);12;0;Create;True;0;0;False;0;0.2823446,1,0,0;0.2823445,1,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;4679.874,-108.4449;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;M_VFX_trails;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;False;True;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;99;0;7;0
WireConnection;97;14;100;0
WireConnection;97;7;62;0
WireConnection;97;8;60;0
WireConnection;96;14;102;0
WireConnection;96;7;30;0
WireConnection;96;8;31;0
WireConnection;98;14;101;0
WireConnection;98;7;69;0
WireConnection;98;8;70;0
WireConnection;5;1;96;0
WireConnection;59;1;97;0
WireConnection;89;0;5;1
WireConnection;89;1;88;0
WireConnection;86;0;59;2
WireConnection;86;1;87;0
WireConnection;73;1;98;0
WireConnection;63;0;97;0
WireConnection;63;1;96;0
WireConnection;83;0;73;3
WireConnection;83;1;84;0
WireConnection;117;0;86;0
WireConnection;116;0;89;0
WireConnection;64;0;63;0
WireConnection;64;1;65;0
WireConnection;109;0;116;0
WireConnection;118;0;83;0
WireConnection;111;0;117;0
WireConnection;22;0;23;0
WireConnection;22;1;24;0
WireConnection;110;0;118;0
WireConnection;122;0;64;0
WireConnection;53;0;112;0
WireConnection;53;1;113;0
WireConnection;18;0;25;1
WireConnection;18;3;22;0
WireConnection;17;0;18;0
WireConnection;17;1;23;0
WireConnection;8;1;123;0
WireConnection;66;0;114;0
WireConnection;66;1;53;0
WireConnection;54;0;66;0
WireConnection;19;0;8;1
WireConnection;19;1;18;0
WireConnection;16;0;17;0
WireConnection;16;1;18;0
WireConnection;93;0;54;0
WireConnection;15;0;19;0
WireConnection;15;1;16;0
WireConnection;14;0;15;0
WireConnection;12;0;92;0
WireConnection;12;1;14;0
WireConnection;27;0;26;4
WireConnection;27;1;12;0
WireConnection;28;0;27;0
WireConnection;94;0;28;0
WireConnection;76;0;77;0
WireConnection;76;1;75;0
WireConnection;105;0;56;0
WireConnection;57;0;59;2
WireConnection;57;1;51;0
WireConnection;80;0;55;0
WireConnection;80;1;104;0
WireConnection;80;2;119;0
WireConnection;120;0;80;0
WireConnection;107;0;38;0
WireConnection;38;0;35;0
WireConnection;38;1;11;0
WireConnection;35;0;50;0
WireConnection;35;1;5;1
WireConnection;77;0;78;0
WireConnection;77;1;73;3
WireConnection;103;0;76;0
WireConnection;56;0;57;0
WireConnection;56;1;58;0
WireConnection;55;0;106;0
WireConnection;55;1;108;0
WireConnection;55;2;115;0
WireConnection;1;2;121;0
WireConnection;1;3;95;0
WireConnection;1;4;13;0
ASEEND*/
//CHKSM=940B5ED85DD72106387D0D258AB7A170138FF6ED