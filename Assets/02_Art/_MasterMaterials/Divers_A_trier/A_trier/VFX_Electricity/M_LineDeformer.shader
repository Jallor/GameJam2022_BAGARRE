// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_LineDeformer"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_Tiles_X_Secondary("Tiles_X_Secondary", Float) = -0.075
		_Tiles_Y_Secondary("Tiles_Y_Secondary", Float) = -0.075
		_Speed_X_Secondary("Speed_X_Secondary", Float) = -0.075
		_Speed_Y_Secondary("Speed_Y_Secondary", Float) = -0.075
		_Displace_Intensity("Displace_Intensity", Float) = 0.3
		_Color0("Color 0", Color) = (0,0.8124628,1,0)
		_Intensity("Intensity", Float) = 0
		_emissivetreshold("emissive treshold", Float) = 0
		_Mask("Mask", 2D) = "white" {}
		_SpeedY("Speed Y", Float) = 1
		_TileY("Tile Y", Float) = 1
		_TileX("Tile X", Float) = 0
		_SpeedX("Speed X", Float) = 0
		_alpha_treshold("alpha_treshold", Float) = 0
		_TextureSample2("Texture Sample 2", 2D) = "white" {}
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

			sampler2D _TextureSample2;
			sampler2D _TextureSample0;
			sampler2D _Mask;
			CBUFFER_START( UnityPerMaterial )
			float _SpeedX;
			float _SpeedY;
			float _Speed_X_Secondary;
			float _Speed_Y_Secondary;
			float _Tiles_X_Secondary;
			float _Tiles_Y_Secondary;
			float _Displace_Intensity;
			float _TileX;
			float _TileY;
			float _emissivetreshold;
			float _Intensity;
			float4 _Color0;
			float4 _Mask_ST;
			float _alpha_treshold;
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
				float2 appendResult4_g11 = (float2(_SpeedX , _SpeedY));
				float2 appendResult4_g9 = (float2(_Speed_X_Secondary , _Speed_Y_Secondary));
				float2 uv050 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g9 = (float2(_Tiles_X_Secondary , _Tiles_Y_Secondary));
				float2 panner6_g9 = ( _TimeParameters.x * appendResult4_g9 + ( uv050 * appendResult12_g9 ));
				float4 tex2DNode14 = tex2D( _TextureSample0, panner6_g9 );
				float2 uv011 = IN.ase_texcoord3.xy * float2( 1,1 ) + ( tex2DNode14 * _Displace_Intensity ).rg;
				float2 appendResult12_g11 = (float2(_TileX , _TileY));
				float2 panner6_g11 = ( _TimeParameters.x * appendResult4_g11 + ( uv011 * appendResult12_g11 ));
				float2 temp_output_49_0 = panner6_g11;
				float4 tex2DNode60 = tex2D( _TextureSample2, temp_output_49_0 );
				float temp_output_6_0_g15 = pow( tex2DNode60.r , _emissivetreshold );
				
				float2 uv_Mask = IN.ase_texcoord3.xy * _Mask_ST.xy + _Mask_ST.zw;
				float4 tex2DNode42 = tex2D( _Mask, uv_Mask );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( temp_output_6_0_g15 * _Intensity ) * _Color0 ).rgb;
				float Alpha = ( tex2DNode42.a * tex2DNode60.r );
				float AlphaClipThreshold = _alpha_treshold;

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

			sampler2D _Mask;
			sampler2D _TextureSample2;
			sampler2D _TextureSample0;
			CBUFFER_START( UnityPerMaterial )
			float _SpeedX;
			float _SpeedY;
			float _Speed_X_Secondary;
			float _Speed_Y_Secondary;
			float _Tiles_X_Secondary;
			float _Tiles_Y_Secondary;
			float _Displace_Intensity;
			float _TileX;
			float _TileY;
			float _emissivetreshold;
			float _Intensity;
			float4 _Color0;
			float4 _Mask_ST;
			float _alpha_treshold;
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

				float2 uv_Mask = IN.ase_texcoord2.xy * _Mask_ST.xy + _Mask_ST.zw;
				float4 tex2DNode42 = tex2D( _Mask, uv_Mask );
				float2 appendResult4_g11 = (float2(_SpeedX , _SpeedY));
				float2 appendResult4_g9 = (float2(_Speed_X_Secondary , _Speed_Y_Secondary));
				float2 uv050 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g9 = (float2(_Tiles_X_Secondary , _Tiles_Y_Secondary));
				float2 panner6_g9 = ( _TimeParameters.x * appendResult4_g9 + ( uv050 * appendResult12_g9 ));
				float4 tex2DNode14 = tex2D( _TextureSample0, panner6_g9 );
				float2 uv011 = IN.ase_texcoord2.xy * float2( 1,1 ) + ( tex2DNode14 * _Displace_Intensity ).rg;
				float2 appendResult12_g11 = (float2(_TileX , _TileY));
				float2 panner6_g11 = ( _TimeParameters.x * appendResult4_g11 + ( uv011 * appendResult12_g11 ));
				float2 temp_output_49_0 = panner6_g11;
				float4 tex2DNode60 = tex2D( _TextureSample2, temp_output_49_0 );
				
				float Alpha = ( tex2DNode42.a * tex2DNode60.r );
				float AlphaClipThreshold = _alpha_treshold;

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

			sampler2D _Mask;
			sampler2D _TextureSample2;
			sampler2D _TextureSample0;
			CBUFFER_START( UnityPerMaterial )
			float _SpeedX;
			float _SpeedY;
			float _Speed_X_Secondary;
			float _Speed_Y_Secondary;
			float _Tiles_X_Secondary;
			float _Tiles_Y_Secondary;
			float _Displace_Intensity;
			float _TileX;
			float _TileY;
			float _emissivetreshold;
			float _Intensity;
			float4 _Color0;
			float4 _Mask_ST;
			float _alpha_treshold;
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

				float2 uv_Mask = IN.ase_texcoord2.xy * _Mask_ST.xy + _Mask_ST.zw;
				float4 tex2DNode42 = tex2D( _Mask, uv_Mask );
				float2 appendResult4_g11 = (float2(_SpeedX , _SpeedY));
				float2 appendResult4_g9 = (float2(_Speed_X_Secondary , _Speed_Y_Secondary));
				float2 uv050 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g9 = (float2(_Tiles_X_Secondary , _Tiles_Y_Secondary));
				float2 panner6_g9 = ( _TimeParameters.x * appendResult4_g9 + ( uv050 * appendResult12_g9 ));
				float4 tex2DNode14 = tex2D( _TextureSample0, panner6_g9 );
				float2 uv011 = IN.ase_texcoord2.xy * float2( 1,1 ) + ( tex2DNode14 * _Displace_Intensity ).rg;
				float2 appendResult12_g11 = (float2(_TileX , _TileY));
				float2 panner6_g11 = ( _TimeParameters.x * appendResult4_g11 + ( uv011 * appendResult12_g11 ));
				float2 temp_output_49_0 = panner6_g11;
				float4 tex2DNode60 = tex2D( _TextureSample2, temp_output_49_0 );
				
				float Alpha = ( tex2DNode42.a * tex2DNode60.r );
				float AlphaClipThreshold = _alpha_treshold;

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
0;6;1280;653;1320.138;424.7153;1.835574;True;False
Node;AmplifyShaderEditor.RangedFloatNode;24;-3731.83,-217.6409;Inherit;False;Property;_Speed_Y_Secondary;Speed_Y_Secondary;8;0;Create;True;0;0;False;0;-0.075;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;50;-4016.281,-47.43628;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;26;-3597.023,-56.26837;Inherit;False;Property;_Tiles_Y_Secondary;Tiles_Y_Secondary;6;0;Create;True;0;0;False;0;-0.075;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-3574.675,-129.5244;Inherit;False;Property;_Tiles_X_Secondary;Tiles_X_Secondary;5;0;Create;True;0;0;False;0;-0.075;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-3532.157,-249.0528;Inherit;False;Property;_Speed_X_Secondary;Speed_X_Secondary;7;0;Create;True;0;0;False;0;-0.075;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;47;-3287.877,-242.9459;Inherit;False;MF_Tiles;-1;;9;2fa329d2d99691549897442d611b24f3;0;6;14;FLOAT2;0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;10;FLOAT;1;False;13;FLOAT;1;False;11;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;14;-2983.999,-278.2952;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;False;0;-1;bdbe94d7623ec3940947b62544306f1c;bdbe94d7623ec3940947b62544306f1c;True;0;False;white;Auto;False;Instance;6;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;10;-2473.562,293.1383;Inherit;False;Property;_Displace_Intensity;Displace_Intensity;9;0;Create;True;0;0;False;0;0.3;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-2042.515,266.5503;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-1111.612,-1.432682;Inherit;False;Property;_SpeedX;Speed X;21;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-1130.077,75.33376;Inherit;False;Property;_TileY;Tile Y;19;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1665.578,217.9866;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;52;-979.178,48.73356;Inherit;False;Property;_TileX;Tile X;20;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-1242.743,21.70082;Inherit;False;Property;_SpeedY;Speed Y;18;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;49;-707.0433,-25.90757;Inherit;False;MF_Tiles;-1;;11;2fa329d2d99691549897442d611b24f3;0;6;14;FLOAT2;0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;10;FLOAT;1;False;13;FLOAT;1;False;11;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;42;128.9846,518.8489;Inherit;True;Property;_Mask;Mask;15;0;Create;True;0;0;False;0;-1;361bc5bac9aefbd43943686ea4427130;361bc5bac9aefbd43943686ea4427130;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;60;-776.8082,239.7626;Inherit;True;Property;_TextureSample2;Texture Sample 2;24;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;28;-3619.373,253.5177;Inherit;False;Property;_Tiles_Y_Primary;Tiles_Y_Primary;2;0;Create;True;0;0;False;0;-0.075;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;29;-538.8848,464.9501;Inherit;True;Flipbook;-1;;12;53c2488c220f6564ca6c90721ee16673;2,71,1,68,0;8;51;SAMPLER2D;0.0;False;13;FLOAT2;0,0;False;4;FLOAT;2;False;5;FLOAT;2;False;24;FLOAT;1;False;2;FLOAT;0;False;55;FLOAT;0;False;70;FLOAT;0;False;5;COLOR;53;FLOAT2;0;FLOAT;47;FLOAT;48;FLOAT;62
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;687.4,339.452;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-2990.379,67.73962;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;-1;bdbe94d7623ec3940947b62544306f1c;bdbe94d7623ec3940947b62544306f1c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-704.0807,632.6873;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-866.4579,528.5333;Inherit;False;Property;_rowcollumn;row collumn;23;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;31;-1247.589,353.3459;Inherit;True;Property;_ssssss;ssssss;13;0;Create;True;0;0;False;0;dce32c8df964c9b44a008475525d2bb2;dce32c8df964c9b44a008475525d2bb2;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.FunctionNode;48;-3293.2,58.9589;Inherit;False;MF_Tiles;-1;;10;2fa329d2d99691549897442d611b24f3;0;6;14;FLOAT2;0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;10;FLOAT;1;False;13;FLOAT;1;False;11;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-3677.096,80.78333;Inherit;False;Property;_Speed_Y_Primary;Speed_Y_Primary;4;0;Create;True;0;0;False;0;-0.06;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-3597.023,180.2617;Inherit;False;Property;_Tiles_X_Primary;Tiles_X_Primary;1;0;Create;True;0;0;False;0;-0.075;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;22;-172.3747,-111.226;Inherit;False;MF_Emissive_handler;-1;;15;4c2d144224f39b24a93af8da62996f6d;0;4;11;FLOAT;0;False;9;COLOR;0,0,0,0;False;10;FLOAT;0;False;12;FLOAT;0;False;2;COLOR;0;FLOAT;13
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-2764.295,297.3054;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;32;-92.78682,107.2471;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;38;-835.2807,742.2873;Inherit;False;Property;_speedtime;speed time;14;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;57;-1090.723,-234.7669;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;8;-3558.092,62.38322;Inherit;False;Property;_Speed_X_Primary;Speed_X_Primary;3;0;Create;True;0;0;False;0;-0.06;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;18;-601.5132,-270.3856;Inherit;False;Property;_Color0;Color 0;10;0;Create;True;0;0;False;0;0,0.8124628,1,0;0,0.8124628,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;41;497.2769,-261.3605;Inherit;True;MF_Alpha_handler;-1;;13;9ba53a059d6724547ba534bf0c40c79e;0;4;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;13;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;214.6643,-354.0691;Inherit;False;Property;_Alphaglobal;Alpha global;17;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;688.9586,41.02594;Inherit;False;Property;_alpha_treshold;alpha_treshold;22;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;74.39208,-198.0359;Inherit;False;Property;_Dissolve;Dissolve;16;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;33;-1048.038,634.2763;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-427.7547,-70.37664;Inherit;False;Property;_Intensity;Intensity;11;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-383.7785,168.3017;Inherit;False;Property;_emissivetreshold;emissive treshold;12;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;860.3177,-111.5086;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;M_LineDeformer;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;1;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;True;False;False;;0
WireConnection;47;14;50;0
WireConnection;47;7;16;0
WireConnection;47;8;24;0
WireConnection;47;10;25;0
WireConnection;47;13;26;0
WireConnection;14;1;47;0
WireConnection;12;0;14;0
WireConnection;12;1;10;0
WireConnection;11;1;12;0
WireConnection;49;14;11;0
WireConnection;49;7;54;0
WireConnection;49;8;53;0
WireConnection;49;10;52;0
WireConnection;49;13;51;0
WireConnection;60;1;49;0
WireConnection;29;51;31;0
WireConnection;29;13;49;0
WireConnection;29;4;58;0
WireConnection;29;5;58;0
WireConnection;29;2;34;0
WireConnection;59;0;42;4
WireConnection;59;1;60;1
WireConnection;6;1;48;0
WireConnection;34;0;33;0
WireConnection;34;1;38;0
WireConnection;48;14;50;0
WireConnection;48;7;8;0
WireConnection;48;8;23;0
WireConnection;48;10;27;0
WireConnection;48;13;28;0
WireConnection;22;11;60;1
WireConnection;22;9;18;0
WireConnection;22;10;19;0
WireConnection;22;12;20;0
WireConnection;13;0;6;0
WireConnection;13;1;14;0
WireConnection;32;0;60;0
WireConnection;41;6;44;0
WireConnection;41;7;43;0
WireConnection;41;8;60;1
WireConnection;41;13;42;4
WireConnection;1;2;22;0
WireConnection;1;3;59;0
WireConnection;1;4;56;0
ASEEND*/
//CHKSM=4C382C04CA8229C0E9DDC6E5FCFBDA6B55798836