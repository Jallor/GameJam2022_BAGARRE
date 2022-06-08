// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_Cloths"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_MainTex("_MainTex", 2D) = "white" {}
		[Toggle(_DEBUGGRADIENT_ON)] _debugGradient("_debug Gradient", Float) = 0
		[Toggle(_DEBUGWIND_ON)] _debugwind("_debug wind ", Float) = 0
		_gradient_Height("gradient_Height", Range( 0 , 30)) = 11
		_gradientSharpness("gradient Sharpness", Range( -20 , 20)) = -15.65
		_WindTex("_WindTex", 2D) = "white" {}
		_wind_TilesX("wind_Tiles X", Float) = 1
		_wind_TilesY("wind_Tiles Y", Float) = 1
		_wind_SpeedX("wind_Speed X", Float) = 0.5
		_wind_SpeedY("wind_Speed Y", Float) = 0
		_wind_intensity("wind_intensity", Range( 0 , 20)) = 0
		_vertex_OffsetX("vertex_Offset X ?", Range( 0 , 1)) = 1
		_vertex_Offset_X("vertex_Offset_X", Range( -3 , 3)) = 0
		_vertex_OffsetY("vertex_Offset Y ?", Range( 0 , 1)) = 1
		_vertex_Offset_Y("vertex_Offset_Y", Range( -3 , 3)) = 0
		_vertex_OffsetZ("vertex_Offset Z ?", Range( 0 , 1)) = 1
		_vertex_Offset_Z("vertex_Offset_Z", Range( -3 , 3)) = 0
		_wind_Sine_Speed("wind_Sine_Speed", Range( 0 , 20)) = 0
		_light_color("light_color", Color) = (1,0.740566,0.8553975,0)
		_light_intensity("light_intensity", Float) = 0
		_light_radius("light_radius", Float) = 0
		_light_sharpness("light_sharpness", Float) = 0
		_shadow_color("shadow_color", Color) = (0,0,0,0)
		_shadow__volume_intensity("shadow_&_volume_intensity", Float) = 0

	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="TransparentCutout" "Queue"="Transparent" }
		
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
			#pragma multi_compile_instancing
			#pragma shader_feature_local _DEBUGWIND_ON
			#pragma shader_feature_local _DEBUGGRADIENT_ON


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

			sampler2D _WindTex;
			sampler2D _MainTex;
			float3 _PlayerPosition;
			UNITY_INSTANCING_BUFFER_START(M_Cloths)
				UNITY_DEFINE_INSTANCED_PROP(float, _wind_intensity)
			UNITY_INSTANCING_BUFFER_END(M_Cloths)
			CBUFFER_START( UnityPerMaterial )
			float _wind_SpeedX;
			float _wind_SpeedY;
			float _wind_TilesX;
			float _wind_TilesY;
			float _wind_Sine_Speed;
			float _vertex_Offset_X;
			float _vertex_OffsetX;
			float _vertex_OffsetY;
			float _vertex_Offset_Y;
			float _vertex_Offset_Z;
			float _vertex_OffsetZ;
			float _gradient_Height;
			float _gradientSharpness;
			float4 _light_color;
			float _light_intensity;
			float _light_radius;
			float _light_sharpness;
			float _shadow__volume_intensity;
			float4 _shadow_color;
			CBUFFER_END


			
			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 appendResult4_g11 = (float2(_wind_SpeedX , _wind_SpeedY));
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float4 appendResult144 = (float4(ase_worldPos.x , ase_worldPos.y , 0.0 , 0.0));
				float2 appendResult12_g11 = (float2(_wind_TilesX , _wind_TilesY));
				float2 panner6_g11 = ( _TimeParameters.x * appendResult4_g11 + ( appendResult144.xy * appendResult12_g11 ));
				float clampResult140 = clamp( tex2Dlod( _WindTex, float4( panner6_g11, 0, 0.0) ).r , -1.0 , 1.0 );
				float WIND178 = clampResult140;
				float mulTime152 = _TimeParameters.x * _wind_Sine_Speed;
				float WindSinus192 = ( WIND178 * sin( mulTime152 ) );
				float offsetclampMIN183 = ( 1.0 - 5.0 );
				float offsetclampMAX182 = 5.0;
				float clampResult160 = clamp( WindSinus192 , offsetclampMIN183 , offsetclampMAX182 );
				float WindSinusclamped194 = clampResult160;
				float3 appendResult146 = (float3(( (_vertex_Offset_X + (WindSinusclamped194 - offsetclampMIN183) * (( _vertex_Offset_X + 2.0 ) - _vertex_Offset_X) / (offsetclampMAX182 - offsetclampMIN183)) * _vertex_OffsetX ) , ( _vertex_OffsetY * (_vertex_Offset_Y + (WindSinusclamped194 - offsetclampMIN183) * (( _vertex_Offset_Y + 2.0 ) - _vertex_Offset_Y) / (offsetclampMAX182 - offsetclampMIN183)) ) , ( (_vertex_Offset_Z + (WindSinusclamped194 - offsetclampMIN183) * (( _vertex_Offset_Z + 2.0 ) - _vertex_Offset_Z) / (offsetclampMAX182 - offsetclampMIN183)) * _vertex_OffsetZ )));
				float _wind_intensity_Instance = UNITY_ACCESS_INSTANCED_PROP(M_Cloths,_wind_intensity);
				float4 transform4_g12 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float LOCALPOSITION171 = pow( saturate( ( 0.02 - ( ( (( transform4_g12 - float4( ase_worldPos , 0.0 ) )).y - ( 1.0 - _gradient_Height ) ) / _gradientSharpness ) ) ) , (float)3 );
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( ( appendResult146 * _wind_intensity_Instance ) * LOCALPOSITION171 );
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
				float2 uv0232 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode5 = tex2D( _MainTex, uv0232 );
				float4 color29 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
				float4 color30 = IsGammaSpace() ? float4(0,1,0.004989147,0) : float4(0,1,0.0003861569,0);
				float4 transform4_g12 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float LOCALPOSITION171 = pow( saturate( ( 0.02 - ( ( (( transform4_g12 - float4( WorldPosition , 0.0 ) )).y - ( 1.0 - _gradient_Height ) ) / _gradientSharpness ) ) ) , (float)3 );
				float4 lerpResult28 = lerp( color29 , color30 , LOCALPOSITION171);
				float4 DEBUG174 = lerpResult28;
				#ifdef _DEBUGGRADIENT_ON
				float4 staticSwitch149 = DEBUG174;
				#else
				float4 staticSwitch149 = tex2DNode5;
				#endif
				float2 appendResult4_g11 = (float2(_wind_SpeedX , _wind_SpeedY));
				float4 appendResult144 = (float4(WorldPosition.x , WorldPosition.y , 0.0 , 0.0));
				float2 appendResult12_g11 = (float2(_wind_TilesX , _wind_TilesY));
				float2 panner6_g11 = ( _TimeParameters.x * appendResult4_g11 + ( appendResult144.xy * appendResult12_g11 ));
				float clampResult140 = clamp( tex2D( _WindTex, panner6_g11 ).r , -1.0 , 1.0 );
				float WIND178 = clampResult140;
				float4 temp_cast_3 = (WIND178).xxxx;
				#ifdef _DEBUGWIND_ON
				float4 staticSwitch233 = temp_cast_3;
				#else
				float4 staticSwitch233 = staticSwitch149;
				#endif
				float4 COLOR41_g13 = staticSwitch233;
				float4 light_color_value46_g13 = _light_color;
				float4 blendOpSrc35_g13 = COLOR41_g13;
				float4 blendOpDest35_g13 = light_color_value46_g13;
				float light_intensity_value52_g13 = _light_intensity;
				float3 break9_g14 = _PlayerPosition;
				float2 appendResult2_g14 = (float2(break9_g14.x , break9_g14.y));
				float2 appendResult5_g14 = (float2(WorldPosition.x , WorldPosition.y));
				float WorldPos39_g13 = distance( appendResult2_g14 , appendResult5_g14 );
				float light_radius_value42_g13 = _light_radius;
				float LIGHT_Radius30_g13 = saturate( ( WorldPos39_g13 / light_radius_value42_g13 ) );
				float light_sharpness_value49_g13 = _light_sharpness;
				float LIGHT_sharpness18_g13 = saturate( ( LIGHT_Radius30_g13 * light_sharpness_value49_g13 ) );
				float4 lerpResult22_g13 = lerp( (  (( blendOpSrc35_g13 > 0.5 ) ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpSrc35_g13 - 0.5 ) ) * ( 1.0 - blendOpDest35_g13 ) ) : ( 2.0 * blendOpSrc35_g13 * blendOpDest35_g13 ) ) * light_intensity_value52_g13 ) , COLOR41_g13 , LIGHT_sharpness18_g13);
				float4 LIGHT21_g13 = lerpResult22_g13;
				float shadow__volume_intensity_value55_g13 = _shadow__volume_intensity;
				float4 temp_cast_4 = (( LIGHT_Radius30_g13 * shadow__volume_intensity_value55_g13 )).xxxx;
				float4 shadow_color_value59_g13 = _shadow_color;
				float4 SHADOW14_g13 = ( ( LIGHT21_g13 - temp_cast_4 ) * shadow_color_value59_g13 );
				float4 lerpResult17_g13 = lerp( LIGHT21_g13 , SHADOW14_g13 , LIGHT_sharpness18_g13);
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult17_g13.rgb;
				float Alpha = tex2DNode5.a;
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
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#pragma multi_compile_instancing


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

			sampler2D _WindTex;
			sampler2D _MainTex;
			UNITY_INSTANCING_BUFFER_START(M_Cloths)
				UNITY_DEFINE_INSTANCED_PROP(float, _wind_intensity)
			UNITY_INSTANCING_BUFFER_END(M_Cloths)
			CBUFFER_START( UnityPerMaterial )
			float _wind_SpeedX;
			float _wind_SpeedY;
			float _wind_TilesX;
			float _wind_TilesY;
			float _wind_Sine_Speed;
			float _vertex_Offset_X;
			float _vertex_OffsetX;
			float _vertex_OffsetY;
			float _vertex_Offset_Y;
			float _vertex_Offset_Z;
			float _vertex_OffsetZ;
			float _gradient_Height;
			float _gradientSharpness;
			float4 _light_color;
			float _light_intensity;
			float _light_radius;
			float _light_sharpness;
			float _shadow__volume_intensity;
			float4 _shadow_color;
			CBUFFER_END


			
			float3 _LightDirection;

			VertexOutput ShadowPassVertex( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float2 appendResult4_g11 = (float2(_wind_SpeedX , _wind_SpeedY));
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float4 appendResult144 = (float4(ase_worldPos.x , ase_worldPos.y , 0.0 , 0.0));
				float2 appendResult12_g11 = (float2(_wind_TilesX , _wind_TilesY));
				float2 panner6_g11 = ( _TimeParameters.x * appendResult4_g11 + ( appendResult144.xy * appendResult12_g11 ));
				float clampResult140 = clamp( tex2Dlod( _WindTex, float4( panner6_g11, 0, 0.0) ).r , -1.0 , 1.0 );
				float WIND178 = clampResult140;
				float mulTime152 = _TimeParameters.x * _wind_Sine_Speed;
				float WindSinus192 = ( WIND178 * sin( mulTime152 ) );
				float offsetclampMIN183 = ( 1.0 - 5.0 );
				float offsetclampMAX182 = 5.0;
				float clampResult160 = clamp( WindSinus192 , offsetclampMIN183 , offsetclampMAX182 );
				float WindSinusclamped194 = clampResult160;
				float3 appendResult146 = (float3(( (_vertex_Offset_X + (WindSinusclamped194 - offsetclampMIN183) * (( _vertex_Offset_X + 2.0 ) - _vertex_Offset_X) / (offsetclampMAX182 - offsetclampMIN183)) * _vertex_OffsetX ) , ( _vertex_OffsetY * (_vertex_Offset_Y + (WindSinusclamped194 - offsetclampMIN183) * (( _vertex_Offset_Y + 2.0 ) - _vertex_Offset_Y) / (offsetclampMAX182 - offsetclampMIN183)) ) , ( (_vertex_Offset_Z + (WindSinusclamped194 - offsetclampMIN183) * (( _vertex_Offset_Z + 2.0 ) - _vertex_Offset_Z) / (offsetclampMAX182 - offsetclampMIN183)) * _vertex_OffsetZ )));
				float _wind_intensity_Instance = UNITY_ACCESS_INSTANCED_PROP(M_Cloths,_wind_intensity);
				float4 transform4_g12 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float LOCALPOSITION171 = pow( saturate( ( 0.02 - ( ( (( transform4_g12 - float4( ase_worldPos , 0.0 ) )).y - ( 1.0 - _gradient_Height ) ) / _gradientSharpness ) ) ) , (float)3 );
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( ( appendResult146 * _wind_intensity_Instance ) * LOCALPOSITION171 );
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

				float2 uv0232 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode5 = tex2D( _MainTex, uv0232 );
				
				float Alpha = tex2DNode5.a;
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
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#pragma multi_compile_instancing


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

			sampler2D _WindTex;
			sampler2D _MainTex;
			UNITY_INSTANCING_BUFFER_START(M_Cloths)
				UNITY_DEFINE_INSTANCED_PROP(float, _wind_intensity)
			UNITY_INSTANCING_BUFFER_END(M_Cloths)
			CBUFFER_START( UnityPerMaterial )
			float _wind_SpeedX;
			float _wind_SpeedY;
			float _wind_TilesX;
			float _wind_TilesY;
			float _wind_Sine_Speed;
			float _vertex_Offset_X;
			float _vertex_OffsetX;
			float _vertex_OffsetY;
			float _vertex_Offset_Y;
			float _vertex_Offset_Z;
			float _vertex_OffsetZ;
			float _gradient_Height;
			float _gradientSharpness;
			float4 _light_color;
			float _light_intensity;
			float _light_radius;
			float _light_sharpness;
			float _shadow__volume_intensity;
			float4 _shadow_color;
			CBUFFER_END


			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 appendResult4_g11 = (float2(_wind_SpeedX , _wind_SpeedY));
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float4 appendResult144 = (float4(ase_worldPos.x , ase_worldPos.y , 0.0 , 0.0));
				float2 appendResult12_g11 = (float2(_wind_TilesX , _wind_TilesY));
				float2 panner6_g11 = ( _TimeParameters.x * appendResult4_g11 + ( appendResult144.xy * appendResult12_g11 ));
				float clampResult140 = clamp( tex2Dlod( _WindTex, float4( panner6_g11, 0, 0.0) ).r , -1.0 , 1.0 );
				float WIND178 = clampResult140;
				float mulTime152 = _TimeParameters.x * _wind_Sine_Speed;
				float WindSinus192 = ( WIND178 * sin( mulTime152 ) );
				float offsetclampMIN183 = ( 1.0 - 5.0 );
				float offsetclampMAX182 = 5.0;
				float clampResult160 = clamp( WindSinus192 , offsetclampMIN183 , offsetclampMAX182 );
				float WindSinusclamped194 = clampResult160;
				float3 appendResult146 = (float3(( (_vertex_Offset_X + (WindSinusclamped194 - offsetclampMIN183) * (( _vertex_Offset_X + 2.0 ) - _vertex_Offset_X) / (offsetclampMAX182 - offsetclampMIN183)) * _vertex_OffsetX ) , ( _vertex_OffsetY * (_vertex_Offset_Y + (WindSinusclamped194 - offsetclampMIN183) * (( _vertex_Offset_Y + 2.0 ) - _vertex_Offset_Y) / (offsetclampMAX182 - offsetclampMIN183)) ) , ( (_vertex_Offset_Z + (WindSinusclamped194 - offsetclampMIN183) * (( _vertex_Offset_Z + 2.0 ) - _vertex_Offset_Z) / (offsetclampMAX182 - offsetclampMIN183)) * _vertex_OffsetZ )));
				float _wind_intensity_Instance = UNITY_ACCESS_INSTANCED_PROP(M_Cloths,_wind_intensity);
				float4 transform4_g12 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float LOCALPOSITION171 = pow( saturate( ( 0.02 - ( ( (( transform4_g12 - float4( ase_worldPos , 0.0 ) )).y - ( 1.0 - _gradient_Height ) ) / _gradientSharpness ) ) ) , (float)3 );
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( ( appendResult146 * _wind_intensity_Instance ) * LOCALPOSITION171 );
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

				float2 uv0232 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode5 = tex2D( _MainTex, uv0232 );
				
				float Alpha = tex2DNode5.a;
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
0;0;1280;659;-3376.699;-80.32985;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;177;-1278.763,131.4971;Inherit;False;2684.946;379.1829;Comment;10;178;140;6;144;143;12;11;9;10;7;WIND;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;143;-1160.837,185.5063;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;9;-143.1108,228.5613;Inherit;False;Property;_wind_SpeedX;wind_Speed X;8;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-701.9529,302.003;Inherit;False;Property;_wind_TilesY;wind_Tiles Y;7;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-311.0598,252.8968;Inherit;False;Property;_wind_SpeedY;wind_Speed Y;9;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-546.0294,275.939;Inherit;False;Property;_wind_TilesX;wind_Tiles X;6;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;144;-954.2103,210.6141;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;7;214.5993,211.5144;Inherit;False;MF_Tiles;-1;;11;2fa329d2d99691549897442d611b24f3;0;6;14;FLOAT2;0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;10;FLOAT;1;False;13;FLOAT;1;False;11;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;6;584.9006,181.4971;Inherit;True;Property;_WindTex;_WindTex;5;0;Create;True;0;0;False;0;-1;805c2a2e8c690af4099aee14fa61baf3;805c2a2e8c690af4099aee14fa61baf3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;180;134.7765,645.1219;Inherit;False;1274.439;375.6752;Comment;7;156;151;152;15;179;153;192;WIND SINUS;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;153;276.4046,912.7927;Inherit;False;Property;_wind_Sine_Speed;wind_Sine_Speed;18;0;Create;True;0;0;False;0;0;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;140;921.1824,285.7497;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;152;615.813,916.7823;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;178;1204.633,206.5616;Inherit;False;WIND;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;179;637.6048,686.1421;Inherit;False;178;WIND;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;210;1525.666,1099.271;Inherit;False;Constant;_ClampSin;Clamp Sin;18;0;Create;True;0;0;False;0;5;1;1;8;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;151;870.3857,918.777;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;170;-3327.967,-717.9648;Inherit;False;3454.944;716.8763;Comment;13;125;127;81;100;88;79;77;80;75;78;89;58;171;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;209;1834.134,1016.015;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;156;1040.68,692.8734;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;182;2033.512,1099.467;Inherit;False;offsetclampMAX;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;89;-3241.46,-661.9795;Inherit;False;MF_LocalPosition;-1;;12;4d3191ce81dc15e42a5e77a1cf1d2aa2;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;183;2035.74,1010.567;Inherit;False;offsetclampMIN;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-2547.311,-537.4728;Inherit;False;Property;_gradient_Height;gradient_Height;3;0;Create;True;0;0;False;0;11;0;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;192;1207.865,686.5815;Inherit;False;WindSinus;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;75;-2894.785,-667.9648;Inherit;False;False;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;78;-2161.159,-534.4941;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;190;1840.206,712.0526;Inherit;False;183;offsetclampMIN;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;193;1559.08,689.1283;Inherit;False;192;WindSinus;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;181;1803.913,735.9836;Inherit;False;182;offsetclampMAX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;77;-1954.69,-657.2653;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;160;2197.532,693.9474;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-2049.371,-205.7669;Inherit;False;Property;_gradientSharpness;gradient Sharpness;4;0;Create;True;0;0;False;0;-15.65;0.02;-20;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;148;2964.499,663.4603;Inherit;False;Property;_vertex_Offset_Z;vertex_Offset_Z;17;0;Create;True;0;0;False;0;0;0;-3;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;205;2751.93,713.5021;Inherit;False;Constant;_vertex_Offset_Z_MAX;vertex_Offset_Z_MAX;15;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;169;3209.822,1218.423;Inherit;False;Property;_vertex_Offset_Y;vertex_Offset_Y;15;0;Create;True;0;0;False;0;0;0;-3;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;168;2989.64,1266.245;Inherit;False;Constant;_vertex_Offset_YMAX;vertex_Offset_Y MAX;15;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;79;-1705.759,-562.5731;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-1423.403,-203.109;Inherit;False;Constant;_multiply;multiply;11;0;Create;True;0;0;False;0;0.02;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;163;2747.029,216.7981;Inherit;False;Constant;_vertex_Offset_XMAX;vertex_Offset_X MAX;12;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;162;2961.777,168.4682;Inherit;False;Property;_vertex_Offset_X;vertex_Offset_X;13;0;Create;True;0;0;False;0;0;0;-3;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;194;2401.051,690.1102;Inherit;False;WindSinusclamped;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;195;3886.18,1139.077;Inherit;False;194;WindSinusclamped;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;189;3605.589,142.2035;Inherit;False;182;offsetclampMAX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;3346.284,610.085;Inherit;False;183;offsetclampMIN;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;200;3826.533,588.934;Inherit;False;194;WindSinusclamped;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;100;-1265.895,-584.0967;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;188;3414.526,114.8177;Inherit;False;183;offsetclampMIN;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;187;3405.931,1160.228;Inherit;False;183;offsetclampMIN;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;206;3251.848,695.9709;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;197;3876.687,89.59319;Inherit;False;194;WindSinusclamped;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;3544.311,634.244;Inherit;False;182;offsetclampMAX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;198;3528.708,1246.868;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;184;3603.957,1184.387;Inherit;False;182;offsetclampMAX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;199;3244.636,197.1678;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;81;-814.6358,-584.9197;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;127;-727.3538,-374.6457;Inherit;False;Constant;_Int0;Int 0;13;0;Create;True;0;0;False;0;3;0;0;1;INT;0
Node;AmplifyShaderEditor.TFHCRemapNode;203;4143.361,593.555;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;207;4076.101,775.7687;Inherit;False;Property;_vertex_OffsetZ;vertex_Offset Z ?;16;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;167;4149.577,1143.698;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;147;4084.689,950.7114;Inherit;False;Property;_vertex_OffsetY;vertex_Offset Y ?;14;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;3818.503,268.2064;Inherit;False;Property;_vertex_OffsetX;vertex_Offset X ?;12;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;164;4131.447,94.3872;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;150;4347.207,955.2471;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;125;-533.6371,-392.5564;Inherit;False;False;2;0;FLOAT;0;False;1;INT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;208;4369.407,591.4732;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;158;4344.252,381.3163;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;171;-129.2667,-392.0629;Inherit;False;LOCALPOSITION;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;213;5017.41,595.2405;Inherit;False;InstancedProperty;_wind_intensity;wind_intensity;10;0;Create;True;0;0;False;0;0;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;146;4818.248,540.8372;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;215;5975.354,-935.7659;Inherit;False;1531.973;1135.317;;1;216;MIXER_Output;0,1,0.01366544,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;218;3931.969,-939.8724;Inherit;False;255.6746;626.8203;;1;227;VAR - Get World Pos;1,0.5,0.9176471,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;217;5208.743,-948.3835;Inherit;False;637.8219;638.1299;;3;229;223;220;SHADOW_handler;0,0.754045,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;219;4315.658,-946.4482;Inherit;False;762.0344;634.9038;;3;226;225;224;LIGHT_handler;0,0.754045,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;214;5354.768,541.9935;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;232;5204.283,345.23;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;216;6008.846,-807.1603;Inherit;False;813.0991;369.8679;;1;230;LIGHT assembly;0.5,1,0.6135951,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;173;645.0956,-1275.351;Inherit;False;1272.757;501.8876;Comment;5;174;29;172;30;28;DEBUG;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;176;6068.346,556.6005;Inherit;False;171;LOCALPOSITION;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;233;6688.04,378.9404;Inherit;False;Property;_debugwind;_debug wind ;2;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;29;693.1582,-1225.351;Inherit;False;Constant;_1;1;7;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;175;6093.979,406.5033;Inherit;False;174;DEBUG;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;149;6335.918,384.274;Inherit;False;Property;_debugGradient;_debug Gradient;1;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;234;6496.044,470.5345;Inherit;False;178;WIND;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;28;1402.624,-1053.876;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;5;5590.406,383.0243;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;False;0;-1;bdbe94d7623ec3940947b62544306f1c;bdbe94d7623ec3940947b62544306f1c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;30;693.8997,-1037.772;Inherit;False;Constant;_2;2;8;0;Create;True;0;0;False;0;0,1,0.004989147,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;172;1020.863,-1010.378;Inherit;False;171;LOCALPOSITION;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;227;3969.747,-727.0205;Inherit;False;Global;_PlayerPosition;_PlayerPosition;19;0;Create;True;0;0;False;0;0,0,0;-28.47244,5.543856,-0.9226656;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;220;5571.962,-579.6711;Inherit;False;Property;_shadow_color;shadow_color;23;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;165;1532.26,1000.922;Inherit;False;Constant;_minBase;min Base;18;0;Create;True;0;0;False;0;-5;0;0;1;INT;0
Node;AmplifyShaderEditor.FunctionNode;230;6042.637,-721.0864;Inherit;False;MF_LightBased_PlayerPosition;-1;;13;eab9ff93f05f9f34086d71492f982bb5;0;8;62;FLOAT3;0,0,0;False;40;COLOR;0,0,0,0;False;45;COLOR;1,0.740566,0.8553975,0;False;51;FLOAT;0;False;43;FLOAT;1;False;48;FLOAT;1;False;58;COLOR;0,0,0,0;False;56;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;224;4671.289,-683.1185;Inherit;False;Property;_light_color;light_color;19;0;Create;True;0;0;False;0;1,0.740566,0.8553975,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;286.5477,711.7404;Inherit;False;InstancedProperty;_wind_Intensity;wind_Intensity;11;0;Create;True;0;0;False;0;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;6340.238,538.9574;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;174;1700.249,-1057.838;Inherit;False;DEBUG;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;223;5572.292,-655.4437;Inherit;False;Property;_light_intensity;light_intensity;20;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;226;4467.954,-611.0013;Inherit;False;Property;_light_sharpness;light_sharpness;22;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;225;4895.605,-643.0972;Inherit;False;Property;_light_radius;light_radius;21;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;229;5292.932,-559.9167;Inherit;False;Property;_shadow__volume_intensity;shadow_&_volume_intensity;24;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;235;3831.05,450.1927;Inherit;False;Constant;_Vector0;Vector 0;25;0;Create;True;0;0;False;0;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;7093.562,468.6613;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;M_Cloths;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=TransparentCutout=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;1;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;True;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1917.669,421.3352;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;144;0;143;1
WireConnection;144;1;143;2
WireConnection;7;14;144;0
WireConnection;7;7;9;0
WireConnection;7;8;10;0
WireConnection;7;10;11;0
WireConnection;7;13;12;0
WireConnection;6;1;7;0
WireConnection;140;0;6;1
WireConnection;152;0;153;0
WireConnection;178;0;140;0
WireConnection;151;0;152;0
WireConnection;209;0;210;0
WireConnection;156;0;179;0
WireConnection;156;1;151;0
WireConnection;182;0;210;0
WireConnection;183;0;209;0
WireConnection;192;0;156;0
WireConnection;75;0;89;0
WireConnection;78;0;58;0
WireConnection;77;0;75;0
WireConnection;77;1;78;0
WireConnection;160;0;193;0
WireConnection;160;1;190;0
WireConnection;160;2;181;0
WireConnection;79;0;77;0
WireConnection;79;1;80;0
WireConnection;194;0;160;0
WireConnection;100;0;88;0
WireConnection;100;1;79;0
WireConnection;206;0;148;0
WireConnection;206;1;205;0
WireConnection;198;0;169;0
WireConnection;198;1;168;0
WireConnection;199;0;162;0
WireConnection;199;1;163;0
WireConnection;81;0;100;0
WireConnection;203;0;200;0
WireConnection;203;1;202;0
WireConnection;203;2;201;0
WireConnection;203;3;148;0
WireConnection;203;4;206;0
WireConnection;167;0;195;0
WireConnection;167;1;187;0
WireConnection;167;2;184;0
WireConnection;167;3;169;0
WireConnection;167;4;198;0
WireConnection;164;0;197;0
WireConnection;164;1;188;0
WireConnection;164;2;189;0
WireConnection;164;3;162;0
WireConnection;164;4;199;0
WireConnection;150;0;147;0
WireConnection;150;1;167;0
WireConnection;125;0;81;0
WireConnection;125;1;127;0
WireConnection;208;0;203;0
WireConnection;208;1;207;0
WireConnection;158;0;164;0
WireConnection;158;1;145;0
WireConnection;171;0;125;0
WireConnection;146;0;158;0
WireConnection;146;1;150;0
WireConnection;146;2;208;0
WireConnection;214;0;146;0
WireConnection;214;1;213;0
WireConnection;233;1;149;0
WireConnection;233;0;234;0
WireConnection;149;1;5;0
WireConnection;149;0;175;0
WireConnection;28;0;29;0
WireConnection;28;1;30;0
WireConnection;28;2;172;0
WireConnection;5;1;232;0
WireConnection;230;62;227;0
WireConnection;230;40;233;0
WireConnection;230;45;224;0
WireConnection;230;51;223;0
WireConnection;230;43;225;0
WireConnection;230;48;226;0
WireConnection;230;58;220;0
WireConnection;230;56;229;0
WireConnection;139;0;214;0
WireConnection;139;1;176;0
WireConnection;174;0;28;0
WireConnection;1;2;230;0
WireConnection;1;3;5;4
WireConnection;1;5;139;0
ASEEND*/
//CHKSM=0034B145588BC7CC6631B18432D4981430322281