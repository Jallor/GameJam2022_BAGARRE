// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_Tile_ObjectSize"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[Toggle(_ENABLEWORLDUV_ON)] _enableworldUV("enable world UV ?", Float) = 1
		_tiles_X("tiles_X", Float) = 0.15
		_MainTex("_MainTex", 2D) = "white" {}
		_distmin("dist min", Float) = 0
		_distmax("dist max", Float) = 0
		_Fogintensity("Fog intensity", Range( 0 , 1)) = 0
		_1color_near("1-color_near", Color) = (1,0.7490196,0.9764706,0)
		_1color_far("1-color_far", Color) = (1,0.7490196,0.9764706,0)
		_1intensity_foregroundRchannel("1-intensity_foreground (R channel)", Range( 0 , 20)) = 1
		_1color_emissive("1-color_emissive", Color) = (1,0.4313726,0,0)
		_intensity_emissiveBBchannel1("1-intensity_emissive B (B channel)", Range( 0 , 30)) = 5.2

	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
		
		Cull Back
		HLSLINCLUDE
		#pragma target 2.0
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend One Zero , One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
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

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _ENABLEWORLDUV_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
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
			float _tiles_X;
			float4 _1color_near;
			float4 _1color_far;
			float _distmin;
			float _distmax;
			float _1intensity_foregroundRchannel;
			float _Fogintensity;
			float _intensity_emissiveBBchannel1;
			float4 _1color_emissive;
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
				v.ase_normal = v.ase_tangent.xyz;

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
				float2 uv0149 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_99_0 = ( WorldPosition.y * _tiles_X );
				float2 appendResult105 = (float2(1.0 , temp_output_99_0));
				float2 uv0106 = IN.ase_texcoord3.xy * appendResult105 + float2( 0,0 );
				float2 appendResult107 = (float2(uv0106.x , temp_output_99_0));
				#ifdef _ENABLEWORLDUV_ON
				float2 staticSwitch147 = appendResult107;
				#else
				float2 staticSwitch147 = uv0149;
				#endif
				float2 UV150 = staticSwitch147;
				float4 tex2DNode3_g420 = tex2D( _MainTex, UV150 );
				float R4_g420 = tex2DNode3_g420.r;
				float Distance110 = (0.0 + (distance( WorldPosition.z , _WorldSpaceCameraPos.z ) - _distmin) * (1.0 - 0.0) / (_distmax - _distmin));
				float4 lerpResult114 = lerp( _1color_near , _1color_far , Distance110);
				float4 lerpResult43_g420 = lerp( float4( 0,0,0,0 ) , ( ( float4( 0,0,0,0 ) * R4_g420 ) * 0.0 ) , 1.0);
				float G6_g420 = tex2DNode3_g420.g;
				float4 lerpResult20_g420 = lerp( ( ( R4_g420 * lerpResult114 ) * _1intensity_foregroundRchannel ) , lerpResult43_g420 , G6_g420);
				float4 lerpResult112 = lerp( lerpResult20_g420 , lerpResult114 , Distance110);
				float4 lerpResult128 = lerp( lerpResult112 , lerpResult114 , _Fogintensity);
				float B17_g420 = tex2DNode3_g420.b;
				float3 temp_cast_0 = (B17_g420).xxx;
				float3 saferPower14_g421 = max( temp_cast_0 , 0.0001 );
				float3 temp_cast_1 = (25.0).xxx;
				float3 temp_output_14_0_g421 = pow( saferPower14_g421 , temp_cast_1 );
				float lerpResult118 = lerp( _intensity_emissiveBBchannel1 , ( _intensity_emissiveBBchannel1 / 5.0 ) , Distance110);
				
				float A27_g420 = tex2DNode3_g420.a;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( lerpResult128 + ( float4( ( temp_output_14_0_g421 * lerpResult118 ) , 0.0 ) * _1color_emissive ) ).rgb;
				float Alpha = A27_g420;
				float AlphaClipThreshold = 1.0;

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
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _ENABLEWORLDUV_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
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
			float _tiles_X;
			float4 _1color_near;
			float4 _1color_far;
			float _distmin;
			float _distmax;
			float _1intensity_foregroundRchannel;
			float _Fogintensity;
			float _intensity_emissiveBBchannel1;
			float4 _1color_emissive;
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

				v.ase_normal = v.ase_tangent.xyz;

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

				float2 uv0149 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_99_0 = ( WorldPosition.y * _tiles_X );
				float2 appendResult105 = (float2(1.0 , temp_output_99_0));
				float2 uv0106 = IN.ase_texcoord2.xy * appendResult105 + float2( 0,0 );
				float2 appendResult107 = (float2(uv0106.x , temp_output_99_0));
				#ifdef _ENABLEWORLDUV_ON
				float2 staticSwitch147 = appendResult107;
				#else
				float2 staticSwitch147 = uv0149;
				#endif
				float2 UV150 = staticSwitch147;
				float4 tex2DNode3_g420 = tex2D( _MainTex, UV150 );
				float A27_g420 = tex2DNode3_g420.a;
				
				float Alpha = A27_g420;
				float AlphaClipThreshold = 1.0;

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
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _ENABLEWORLDUV_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
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
			float _tiles_X;
			float4 _1color_near;
			float4 _1color_far;
			float _distmin;
			float _distmax;
			float _1intensity_foregroundRchannel;
			float _Fogintensity;
			float _intensity_emissiveBBchannel1;
			float4 _1color_emissive;
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

				v.ase_normal = v.ase_tangent.xyz;

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

				float2 uv0149 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_99_0 = ( WorldPosition.y * _tiles_X );
				float2 appendResult105 = (float2(1.0 , temp_output_99_0));
				float2 uv0106 = IN.ase_texcoord2.xy * appendResult105 + float2( 0,0 );
				float2 appendResult107 = (float2(uv0106.x , temp_output_99_0));
				#ifdef _ENABLEWORLDUV_ON
				float2 staticSwitch147 = appendResult107;
				#else
				float2 staticSwitch147 = uv0149;
				#endif
				float2 UV150 = staticSwitch147;
				float4 tex2DNode3_g420 = tex2D( _MainTex, UV150 );
				float A27_g420 = tex2DNode3_g420.a;
				
				float Alpha = A27_g420;
				float AlphaClipThreshold = 1.0;

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
-1280;84;1280;659;631.9038;1253.355;1.065281;True;False
Node;AmplifyShaderEditor.RangedFloatNode;18;-1408.851,81.85267;Inherit;False;Property;_tiles_X;tiles_X;1;0;Create;True;0;0;False;0;0.15;0.015;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;6;-1619.018,14.96568;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-1172.828,62.64015;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;135;-1039.565,54.28506;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;134;-1039.565,-15.1436;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;130;-1034.933,-240.2055;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;131;-991.4996,-290.1879;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;105;-930.1321,35.31693;Inherit;False;FLOAT2;4;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;133;-914.0596,-298.199;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;106;-756.6169,12.47133;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;113;298.571,-395.4448;Inherit;False;Property;_1color_far;1-color_far;14;0;Create;True;0;0;False;0;1,0.7490196,0.9764706,0;0,0.5593619,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;116;-217.6016,-1055.725;Inherit;False;Property;_distmin;dist min;3;0;Create;True;0;0;False;0;0;4.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;117;-213.9147,-978.3016;Inherit;False;Property;_distmax;dist max;4;0;Create;True;0;0;False;0;0;2084.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;132;-529.5312,-298.199;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;145;594.4762,-406.3066;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;152;27.9781,-1006.933;Inherit;False;MF_Distance;-1;;1;cfca586c1e83c7b47a47f224eae6a7ef;0;2;8;FLOAT;750;False;9;FLOAT;900;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;149;-1087.944,-470.654;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;107;-553.1553,-356.251;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;147;-412.0069,-478.5493;Inherit;False;Property;_enableworldUV;enable world UV ?;0;0;Create;True;0;0;False;0;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;144;625.3151,-531.0029;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;25;641.4358,99.17942;Inherit;False;Property;_intensity_emissiveBBchannel1;1-intensity_emissive B (B channel);17;0;Create;False;0;0;False;0;5.2;6.3;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;110;329.8337,-1010.306;Inherit;False;Distance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;150;-144.4175,-477.7838;Inherit;False;UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;27;299.0392,-651.7704;Inherit;False;Property;_1color_near;1-color_near;13;0;Create;True;0;0;False;0;1,0.7490196,0.9764706,0;1,0,0.9058824,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;146;650.7907,-569.8867;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;647.0446,-40.37748;Inherit;False;110;Distance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;121;1029.213,96.01094;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;645.6603,-713.6428;Inherit;False;110;Distance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;634.2344,-332.068;Inherit;False;Property;_1intensity_foregroundRchannel;1-intensity_foreground (R channel);15;0;Create;True;0;0;False;0;1;1;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;151;940.6282,-375.7419;Inherit;False;150;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;114;829.8723,-648.0397;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;96;-170.4613,-382.9823;Inherit;True;Property;_MainTex;_MainTex;2;0;Create;True;0;0;True;0;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.LerpOp;118;1103.631,-86.38531;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;28;300.8918,-220.5774;Inherit;False;Property;_1color_emissive;1-color_emissive;16;0;Create;True;0;0;False;0;1,0.4313726,0,0;1,0.4313726,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;129;1344.084,-415.8944;Inherit;False;MF_Colorize_RGB;6;;420;09864a89fc748b5448601e7177115326;0;10;44;FLOAT;1;False;36;SAMPLER2D;0;False;42;FLOAT2;0,0;False;33;COLOR;0,0,0,0;False;30;FLOAT;0;False;34;COLOR;0,0,0,0;False;31;FLOAT;0;False;47;FLOAT;25;False;35;COLOR;0,0,0,0;False;32;FLOAT;0;False;7;COLOR;28;FLOAT3;29;COLOR;0;FLOAT;37;FLOAT;38;FLOAT;39;FLOAT;40
Node;AmplifyShaderEditor.WireNode;137;1846.105,-227.08;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;138;2699.763,-227.08;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;126;1758.9,-1005.984;Inherit;False;Property;_Fogintensity;Fog intensity;5;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;140;1261.269,-974.2234;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;109;1834.474,-623.2274;Inherit;False;110;Distance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;136;2752.458,-242.8883;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TangentVertexDataNode;98;2763.045,-217.9444;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;128;2292.93,-1050.045;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;141;2154.413,-994.8345;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;143;1391.806,-984.5289;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;20;2755.945,-357.0844;Inherit;False;Constant;_trehsold;trehsold;15;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;2484.653,-395.6372;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;112;2104.955,-666.3566;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;139;1134.169,-915.8253;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;142;1116.993,-788.7245;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;3003.735,-400.0634;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;M_Tile_ObjectSize;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;1;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;True;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;99;0;6;2
WireConnection;99;1;18;0
WireConnection;135;0;99;0
WireConnection;134;0;135;0
WireConnection;130;0;134;0
WireConnection;131;0;130;0
WireConnection;105;1;99;0
WireConnection;133;0;131;0
WireConnection;106;0;105;0
WireConnection;132;0;133;0
WireConnection;145;0;113;0
WireConnection;152;8;116;0
WireConnection;152;9;117;0
WireConnection;107;0;106;1
WireConnection;107;1;132;0
WireConnection;147;1;149;0
WireConnection;147;0;107;0
WireConnection;144;0;145;0
WireConnection;110;0;152;0
WireConnection;150;0;147;0
WireConnection;146;0;144;0
WireConnection;121;0;25;0
WireConnection;114;0;27;0
WireConnection;114;1;146;0
WireConnection;114;2;115;0
WireConnection;118;0;25;0
WireConnection;118;1;121;0
WireConnection;118;2;120;0
WireConnection;129;36;96;0
WireConnection;129;42;151;0
WireConnection;129;33;114;0
WireConnection;129;30;26;0
WireConnection;129;35;28;0
WireConnection;129;32;118;0
WireConnection;137;0;129;40
WireConnection;138;0;137;0
WireConnection;140;0;139;0
WireConnection;136;0;138;0
WireConnection;128;0;112;0
WireConnection;128;1;141;0
WireConnection;128;2;126;0
WireConnection;141;0;143;0
WireConnection;143;0;140;0
WireConnection;32;0;128;0
WireConnection;32;1;129;0
WireConnection;112;0;129;28
WireConnection;112;1;114;0
WireConnection;112;2;109;0
WireConnection;139;0;142;0
WireConnection;142;0;114;0
WireConnection;1;2;32;0
WireConnection;1;3;136;0
WireConnection;1;4;20;0
WireConnection;1;6;98;0
ASEEND*/
//CHKSM=CB5EF09ACE9772C7E64E33C0D34047CB3AFEDB82