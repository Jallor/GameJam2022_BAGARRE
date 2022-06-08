// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_Color_Swapper"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		_MainTex("_MainTex", 2D) = "white" {}
		_Color01("Color 01", Color) = (1,0,0,0)
		_Color02("Color 02", Color) = (0,0.04827571,1,0)
		_Color03("Color 03", Color) = (1,0.6827588,0,0)
		_Color04("Color 04", Color) = (0.1376267,0.8676471,0,0)
		_Color05("Color 05", Color) = (0.8620691,0,1,0)
		_Startclipvalue("Start clip value", Float) = 0.02
		[Toggle(_R_TRUE_G_FALSE_ON)] _R_True_G_False("R_True_G_False", Float) = 0
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

			#pragma shader_feature_local _R_TRUE_G_FALSE_ON


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

			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainTex_ST;
			float _Startclipvalue;
			float4 _Color01;
			float4 _Color02;
			float4 _Color03;
			float4 _Color04;
			float4 _Color05;
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
				float2 uv_MainTex = IN.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode81 = tex2D( _MainTex, uv_MainTex );
				#ifdef _R_TRUE_G_FALSE_ON
				float staticSwitch114 = tex2DNode81.r;
				#else
				float staticSwitch114 = tex2DNode81.g;
				#endif
				float temp_output_25_0_g118 = _Startclipvalue;
				float temp_output_22_0_g118 = step( staticSwitch114 , temp_output_25_0_g118 );
				float4 tex2DNode84 = tex2D( _MainTex, uv_MainTex );
				#ifdef _R_TRUE_G_FALSE_ON
				float staticSwitch117 = tex2DNode84.r;
				#else
				float staticSwitch117 = tex2DNode84.g;
				#endif
				float temp_output_25_0_g119 = ( temp_output_25_0_g118 + 0.2 );
				float temp_output_22_0_g119 = step( staticSwitch117 , temp_output_25_0_g119 );
				float4 tex2DNode86 = tex2D( _MainTex, uv_MainTex );
				#ifdef _R_TRUE_G_FALSE_ON
				float staticSwitch118 = tex2DNode86.r;
				#else
				float staticSwitch118 = tex2DNode86.g;
				#endif
				float temp_output_25_0_g120 = ( temp_output_25_0_g119 + 0.2 );
				float temp_output_22_0_g120 = step( staticSwitch118 , temp_output_25_0_g120 );
				float4 tex2DNode87 = tex2D( _MainTex, uv_MainTex );
				#ifdef _R_TRUE_G_FALSE_ON
				float staticSwitch119 = tex2DNode87.r;
				#else
				float staticSwitch119 = tex2DNode87.g;
				#endif
				float temp_output_25_0_g121 = ( temp_output_25_0_g120 + 0.2 );
				float temp_output_22_0_g121 = step( staticSwitch119 , temp_output_25_0_g121 );
				float4 tex2DNode95 = tex2D( _MainTex, uv_MainTex );
				#ifdef _R_TRUE_G_FALSE_ON
				float staticSwitch120 = tex2DNode95.r;
				#else
				float staticSwitch120 = tex2DNode95.g;
				#endif
				float temp_output_25_0_g122 = ( temp_output_25_0_g121 + 0.2 );
				float temp_output_22_0_g122 = step( staticSwitch120 , temp_output_25_0_g122 );
				
				#ifdef _R_TRUE_G_FALSE_ON
				float staticSwitch115 = tex2DNode81.b;
				#else
				float staticSwitch115 = (float)1;
				#endif
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( ( temp_output_22_0_g118 - 0.0 ) * _Color01 ) + ( ( temp_output_22_0_g119 - temp_output_22_0_g118 ) * _Color02 ) + ( _Color03 * ( temp_output_22_0_g120 - temp_output_22_0_g119 ) ) + ( _Color04 * ( temp_output_22_0_g121 - temp_output_22_0_g120 ) ) + ( _Color05 * ( temp_output_22_0_g122 - temp_output_22_0_g121 ) ) ).rgb;
				float Alpha = staticSwitch115;
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

			#pragma shader_feature_local _R_TRUE_G_FALSE_ON


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

			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainTex_ST;
			float _Startclipvalue;
			float4 _Color01;
			float4 _Color02;
			float4 _Color03;
			float4 _Color04;
			float4 _Color05;
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

				float2 uv_MainTex = IN.ase_texcoord2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode81 = tex2D( _MainTex, uv_MainTex );
				#ifdef _R_TRUE_G_FALSE_ON
				float staticSwitch115 = tex2DNode81.b;
				#else
				float staticSwitch115 = (float)1;
				#endif
				
				float Alpha = staticSwitch115;
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

			#pragma shader_feature_local _R_TRUE_G_FALSE_ON


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

			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _MainTex_ST;
			float _Startclipvalue;
			float4 _Color01;
			float4 _Color02;
			float4 _Color03;
			float4 _Color04;
			float4 _Color05;
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

				float2 uv_MainTex = IN.ase_texcoord2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode81 = tex2D( _MainTex, uv_MainTex );
				#ifdef _R_TRUE_G_FALSE_ON
				float staticSwitch115 = tex2DNode81.b;
				#else
				float staticSwitch115 = (float)1;
				#endif
				
				float Alpha = staticSwitch115;
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
Version=17800
0;6;1280;653;2529.981;-1092.883;2.860709;True;False
Node;AmplifyShaderEditor.CommentaryNode;79;-1232.499,1433.288;Inherit;False;3616.619;1259.05;Convert a single greyscale mask into 5 different B/W masks;20;101;95;93;89;88;87;86;85;84;83;82;80;113;114;115;116;117;118;119;120;Create colour masks;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;80;-1210.991,1633.009;Inherit;False;415.1407;302.3209;Must be linear (untick sRGB in import settings);1;81;Main texture sample;1,1,1,1;0;0
Node;AmplifyShaderEditor.IntNode;116;1924.212,1981.138;Inherit;False;Constant;_Int0;Int 0;12;0;Create;True;0;0;False;0;1;0;0;1;INT;0
Node;AmplifyShaderEditor.SamplerNode;81;-1135.991,1697.009;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;False;0;-1;1dec99e62d279584590a443a0c9e2030;ae0e8ec300b8a7c478936b1b33b60a38;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;88;-689.9913,2143.009;Inherit;False;2942;468;;20;112;111;110;109;108;107;106;105;104;103;102;100;99;98;97;96;94;92;91;90;Colour all the masks;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;87;448.0085,1521.009;Inherit;True;Property;_Mask03Instance;Mask 03 (Instance);0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Instance;81;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;112;2016.01,2225.008;Inherit;True;5;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;97;1408.01,2209.008;Float;False;Property;_Color05;Color 05;9;0;Create;True;0;0;False;0;0.8620691,0,1,0;1,0.5586207,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;106;383.6055,2472.259;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;89;320.0095,1729.009;Inherit;True;MaskingFunction;-1;;120;571aab6f8c08f1c4d9bd4012d2958d88;0;3;21;FLOAT;0;False;30;FLOAT;0;False;25;FLOAT;0;False;3;FLOAT;0;FLOAT;32;FLOAT;28
Node;AmplifyShaderEditor.ColorNode;92;-127.9914,2193.008;Float;False;Property;_Color02;Color 02;6;0;Create;True;0;0;False;0;0,0.04827571,1,0;1,1,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;115;2318.628,2035.198;Inherit;False;Property;_R_True_G_False;R_True_G_False;11;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Reference;114;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;114;-843.5218,1531.397;Inherit;False;Property;_R_True_G_False;R_True_G_False;11;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;118;272.3318,1530.012;Inherit;False;Property;_R_True_G_False;R_True_G_False;11;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Reference;114;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;111;1870.103,2525.427;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;120;1354.309,1543.037;Inherit;False;Property;_R_True_G_False;R_True_G_False;11;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Reference;118;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;93;832.0095,1729.009;Inherit;True;MaskingFunction;-1;;121;571aab6f8c08f1c4d9bd4012d2958d88;0;3;21;FLOAT;0;False;30;FLOAT;0;False;25;FLOAT;0.75;False;3;FLOAT;0;FLOAT;32;FLOAT;28
Node;AmplifyShaderEditor.SamplerNode;95;960.0095,1521.009;Inherit;True;Property;_Mask04Instance;Mask 04 (Instance);0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Instance;81;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;108;1828.049,2466.502;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;109;1859.474,2488.055;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;119;728.2679,1554.317;Inherit;False;Property;_R_True_G_False;R_True_G_False;11;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Reference;118;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;90;880.0095,2193.008;Float;False;Property;_Color04;Color 04;8;0;Create;True;0;0;False;0;0.1376267,0.8676471,0,0;0.1376266,0.8676471,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;113;-1072.069,2230.817;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;138.5675,2210.822;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;103;1384.646,2427.656;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-386.1278,2207.195;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;102;-122.6192,2457.497;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;110;1831.054,2415.102;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;1169.823,2225.008;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;107;1854.219,2365.681;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;83;-709.0603,1727.542;Inherit;True;MaskingFunction;-1;;118;571aab6f8c08f1c4d9bd4012d2958d88;0;3;21;FLOAT;0;False;30;FLOAT;0;False;25;FLOAT;0;False;3;FLOAT;0;FLOAT;32;FLOAT;28
Node;AmplifyShaderEditor.RangedFloatNode;82;-958.0476,1956.457;Float;False;Property;_Startclipvalue;Start clip value;10;0;Create;True;0;0;False;0;0.02;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;91;384.0095,2193.008;Float;False;Property;_Color03;Color 03;7;0;Create;True;0;0;False;0;1,0.6827588,0,0;0.03448248,0,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;84;-575.9913,1521.009;Inherit;True;Property;_Mask01Instance;Mask 01 (Instance);0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Instance;81;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;117;-240.0312,1505.687;Inherit;False;Property;_R_True_G_False;R_True_G_False;11;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Reference;114;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;86;-63.99133,1521.009;Inherit;True;Property;_Mask02Instance;Mask 02 (Instance);0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Instance;81;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;105;848.9775,2447.075;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;1643.738,2210.176;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;85;-191.9914,1729.009;Inherit;True;MaskingFunction;-1;;119;571aab6f8c08f1c4d9bd4012d2958d88;0;3;21;FLOAT;0;False;30;FLOAT;0;False;25;FLOAT;0;False;3;FLOAT;0;FLOAT;32;FLOAT;28
Node;AmplifyShaderEditor.ColorNode;94;-639.9913,2193.008;Float;False;Property;_Color01;Color 01;5;0;Create;True;0;0;False;0;1,0,0,0;1,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;101;1344.01,1729.009;Inherit;True;MaskingFunction;-1;;122;571aab6f8c08f1c4d9bd4012d2958d88;0;3;21;FLOAT;0;False;30;FLOAT;0;False;25;FLOAT;0;False;3;FLOAT;0;FLOAT;32;FLOAT;28
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;619.7365,2217.754;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;42;527.5616,-299.1543;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;40;2598.486,2225.385;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;M_Color_Swapper;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;1;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;True;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;41;527.5616,-299.1543;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;43;527.5616,-299.1543;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;39;527.5616,-299.1543;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;112;0;111;0
WireConnection;112;1;109;0
WireConnection;112;2;108;0
WireConnection;112;3;110;0
WireConnection;112;4;107;0
WireConnection;106;0;99;0
WireConnection;89;21;118;0
WireConnection;89;30;85;32
WireConnection;89;25;85;28
WireConnection;115;1;116;0
WireConnection;115;0;81;3
WireConnection;114;1;81;2
WireConnection;114;0;81;1
WireConnection;118;1;86;2
WireConnection;118;0;86;1
WireConnection;111;0;102;0
WireConnection;120;1;95;2
WireConnection;120;0;95;1
WireConnection;93;21;119;0
WireConnection;93;30;89;32
WireConnection;93;25;89;28
WireConnection;108;0;105;0
WireConnection;109;0;106;0
WireConnection;119;1;87;2
WireConnection;119;0;87;1
WireConnection;113;0;81;1
WireConnection;99;0;85;0
WireConnection;99;1;92;0
WireConnection;103;0;96;0
WireConnection;100;0;83;0
WireConnection;100;1;94;0
WireConnection;102;0;100;0
WireConnection;110;0;103;0
WireConnection;96;0;90;0
WireConnection;96;1;93;0
WireConnection;107;0;104;0
WireConnection;83;21;114;0
WireConnection;83;25;82;0
WireConnection;117;1;84;2
WireConnection;117;0;84;1
WireConnection;105;0;98;0
WireConnection;104;0;97;0
WireConnection;104;1;101;0
WireConnection;85;21;117;0
WireConnection;85;30;83;32
WireConnection;85;25;83;28
WireConnection;101;21;120;0
WireConnection;101;30;93;32
WireConnection;101;25;93;28
WireConnection;98;0;91;0
WireConnection;98;1;89;0
WireConnection;40;2;112;0
WireConnection;40;3;115;0
ASEEND*/
//CHKSM=84E417E66D7E91D4055A4079735D485F13C9B231