// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_VFX_Explosion"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_Dissolve_texture("Dissolve_texture", 2D) = "white" {}
		_dissolve_Intensity("dissolve_Intensity", Range( 0 , 20)) = 0
		_dissolve_TilesX("dissolve_Tiles X", Float) = 1
		_dissolve_TilesY("dissolve_Tiles Y", Float) = 1
		_dissolve_Speed_X("dissolve_Speed_X", Float) = 0
		_dissolve_SpeedY("dissolve_Speed Y", Float) = 0
		_emissiveColor("emissive Color", Color) = (1,0.4221933,0,0)
		_emissive_Intensity("emissive_Intensity", Range( 0 , 200)) = 0
		_emissive_Treshold("emissive_Treshold", Range( 0 , 25)) = 0
		_color_Base("color_Base", Color) = (0,0,0,0)
		_fresnelAlpha_Scale("fresnelAlpha_Scale", Range( 0 , 200)) = 1
		_fresnelAlpha_Power("fresnelAlpha_Power", Range( 0 , 50)) = 3
		_AlphaGlobal("Alpha Global", Range( 0 , 1)) = 0
		_Alpha_Treshold("Alpha_Treshold", Range( 0 , 1)) = 0
		_fresnelColor_Scale("fresnelColor_Scale", Range( 0 , 50)) = 1
		_fresnelColor_Power("fresnelColor_Power", Float) = 3
		_fresnel_Color("fresnel_Color", Color) = (1,0.5287268,0,0)
		_fresnel_Emissive_Intensity("fresnel_Emissive_Intensity", Range( 0 , 100)) = 0
		_Flow_texture("Flow_texture", 2D) = "white" {}
		_flow_TilesX("flow_Tiles X", Float) = 0
		_flow_TilesY("flow_Tiles Y", Float) = 0
		_flow_Speed_X("flow_Speed_X", Float) = 1
		_flow_SpeedY("flow_Speed Y", Float) = 1
		_flow_speed_Multiplier_VertexMask("flow_speed_Multiplier_VertexMask", Float) = 0
		_YOffset("Y Offset", Float) = 0
		_triplanar_sharpness("triplanar_sharpness", Float) = 0

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
			#pragma multi_compile_fog
			#define ASE_FOG 1
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
			#define ASE_NEEDS_VERT_NORMAL


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
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

			sampler2D _Flow_texture;
			sampler2D _Dissolve_texture;
			CBUFFER_START( UnityPerMaterial )
			float _YOffset;
			float4 _fresnel_Color;
			float _fresnel_Emissive_Intensity;
			float _fresnelColor_Scale;
			float _fresnelColor_Power;
			float _flow_Speed_X;
			float _flow_SpeedY;
			float _flow_TilesX;
			float _flow_TilesY;
			float _triplanar_sharpness;
			float4 _color_Base;
			float _dissolve_Speed_X;
			float _dissolve_SpeedY;
			float _dissolve_TilesX;
			float _dissolve_TilesY;
			float _dissolve_Intensity;
			float _flow_speed_Multiplier_VertexMask;
			float _AlphaGlobal;
			float _fresnelAlpha_Scale;
			float _fresnelAlpha_Power;
			float _emissive_Treshold;
			float4 _emissiveColor;
			float _emissive_Intensity;
			float _Alpha_Treshold;
			CBUFFER_END


			
			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 transform143 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,0 ));
				float4 appendResult141 = (float4(transform143.x , ( transform143.y + ( _YOffset / 10.0 ) ) , transform143.z , transform143.w));
				float3 worldToObjDir130 = mul( GetWorldToObjectMatrix(), float4( appendResult141.xyz, 0 ) ).xyz;
				
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord3.xyz = ase_worldNormal;
				
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = worldToObjDir130;
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
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float fresnelNdotV39 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode39 = ( 0.0 + _fresnelColor_Scale * pow( max( 1.0 - fresnelNdotV39 , 0.0001 ), _fresnelColor_Power ) );
				float2 appendResult15_g31 = (float2(_flow_Speed_X , _flow_SpeedY));
				float2 Speed20_g31 = appendResult15_g31;
				float3 WorldPos148 = WorldPosition;
				float3 break4_g31 = WorldPos148;
				float2 appendResult10_g31 = (float2(break4_g31.z , break4_g31.y));
				float2 appendResult12_g31 = (float2(_flow_TilesX , _flow_TilesY));
				float2 tilling22_g31 = appendResult12_g31;
				float2 panner1_g31 = ( 1.0 * _Time.y * Speed20_g31 + ( appendResult10_g31 * tilling22_g31 ));
				float3 WorldNormal226 = ase_worldNormal;
				float Sharprrrrpr231 = _triplanar_sharpness;
				float3 temp_cast_0 = (Sharprrrrpr231).xxx;
				float3 break29_g31 = pow( abs( WorldNormal226 ) , temp_cast_0 );
				float4 lerpResult37_g31 = lerp( float4( 0,0,0,0 ) , tex2D( _Flow_texture, panner1_g31 ) , saturate( break29_g31.x ));
				float2 appendResult9_g31 = (float2(break4_g31.x , break4_g31.z));
				float2 panner6_g31 = ( 1.0 * _Time.y * Speed20_g31 + ( appendResult9_g31 * tilling22_g31 ));
				float4 lerpResult39_g31 = lerp( float4( 0,0,0,0 ) , tex2D( _Flow_texture, panner6_g31 ) , saturate( break29_g31.y ));
				float2 appendResult11_g31 = (float2(break4_g31.x , break4_g31.y));
				float2 panner2_g31 = ( 1.0 * _Time.y * Speed20_g31 + ( appendResult11_g31 * tilling22_g31 ));
				float4 lerpResult38_g31 = lerp( float4( 0,0,0,0 ) , tex2D( _Flow_texture, panner2_g31 ) , saturate( break29_g31.z ));
				float4 FlowFire83 = ( lerpResult37_g31 + lerpResult39_g31 + lerpResult38_g31 );
				float4 Fresnel_Color167 = saturate( ( fresnelNode39 / ( FlowFire83 * 2.0 ) ) );
				float4 lerpResult40 = lerp( ( _fresnel_Color * _fresnel_Emissive_Intensity ) , float4( 0,0,0,0 ) , Fresnel_Color167);
				float2 appendResult15_g27 = (float2(_dissolve_Speed_X , _dissolve_SpeedY));
				float2 Speed20_g27 = appendResult15_g27;
				float3 break4_g27 = WorldPos148;
				float2 appendResult10_g27 = (float2(break4_g27.z , break4_g27.y));
				float2 appendResult12_g27 = (float2(_dissolve_TilesX , _dissolve_TilesY));
				float2 tilling22_g27 = appendResult12_g27;
				float2 panner1_g27 = ( 1.0 * _Time.y * Speed20_g27 + ( appendResult10_g27 * tilling22_g27 ));
				float3 temp_cast_1 = (Sharprrrrpr231).xxx;
				float3 break29_g27 = pow( abs( WorldNormal226 ) , temp_cast_1 );
				float4 lerpResult37_g27 = lerp( float4( 0,0,0,0 ) , tex2D( _Dissolve_texture, panner1_g27 ) , saturate( break29_g27.x ));
				float2 appendResult9_g27 = (float2(break4_g27.x , break4_g27.z));
				float2 panner6_g27 = ( 1.0 * _Time.y * Speed20_g27 + ( appendResult9_g27 * tilling22_g27 ));
				float4 lerpResult39_g27 = lerp( float4( 0,0,0,0 ) , tex2D( _Dissolve_texture, panner6_g27 ) , saturate( break29_g27.y ));
				float2 appendResult11_g27 = (float2(break4_g27.x , break4_g27.y));
				float2 panner2_g27 = ( 1.0 * _Time.y * Speed20_g27 + ( appendResult11_g27 * tilling22_g27 ));
				float4 lerpResult38_g27 = lerp( float4( 0,0,0,0 ) , tex2D( _Dissolve_texture, panner2_g27 ) , saturate( break29_g27.z ));
				float lerpResult77 = lerp( 1.0 , IN.ase_color.g , saturate( ( _dissolve_Intensity / 2.0 ) ));
				float4 temp_cast_2 = (lerpResult77).xxxx;
				float2 appendResult15_g33 = (float2(( _flow_Speed_X * _flow_speed_Multiplier_VertexMask ) , ( _flow_SpeedY * _flow_speed_Multiplier_VertexMask )));
				float2 Speed20_g33 = appendResult15_g33;
				float3 break4_g33 = WorldPos148;
				float2 appendResult10_g33 = (float2(break4_g33.z , break4_g33.y));
				float2 appendResult12_g33 = (float2(_flow_TilesX , _flow_TilesY));
				float2 tilling22_g33 = appendResult12_g33;
				float2 panner1_g33 = ( 1.0 * _Time.y * Speed20_g33 + ( appendResult10_g33 * tilling22_g33 ));
				float3 temp_cast_3 = (Sharprrrrpr231).xxx;
				float3 break29_g33 = pow( abs( WorldNormal226 ) , temp_cast_3 );
				float4 lerpResult37_g33 = lerp( float4( 0,0,0,0 ) , tex2D( _Flow_texture, panner1_g33 ) , saturate( break29_g33.x ));
				float2 appendResult9_g33 = (float2(break4_g33.x , break4_g33.z));
				float2 panner6_g33 = ( 1.0 * _Time.y * Speed20_g33 + ( appendResult9_g33 * tilling22_g33 ));
				float4 lerpResult39_g33 = lerp( float4( 0,0,0,0 ) , tex2D( _Flow_texture, panner6_g33 ) , saturate( break29_g33.y ));
				float2 appendResult11_g33 = (float2(break4_g33.x , break4_g33.y));
				float2 panner2_g33 = ( 1.0 * _Time.y * Speed20_g33 + ( appendResult11_g33 * tilling22_g33 ));
				float4 lerpResult38_g33 = lerp( float4( 0,0,0,0 ) , tex2D( _Flow_texture, panner2_g33 ) , saturate( break29_g33.z ));
				float4 FlowSmoke88 = ( lerpResult37_g33 + lerpResult39_g33 + lerpResult38_g33 );
				float4 DissolveVertex85 = ( temp_cast_2 - FlowSmoke88 );
				float4 temp_cast_4 = (( _dissolve_Intensity / 10.0 )).xxxx;
				float4 lerpResult5_g34 = lerp( saturate( pow( saturate( ( ( lerpResult37_g27 + lerpResult39_g27 + lerpResult38_g27 ).b * DissolveVertex85 ) ) , temp_cast_4 ) ) , float4( 0,0,0,0 ) , _AlphaGlobal);
				float fresnelNdotV175 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode175 = ( 0.0 + _fresnelAlpha_Scale * pow( max( 1.0 - fresnelNdotV175 , 0.0001 ), _fresnelAlpha_Power ) );
				float Fresnel_Alpha178 = saturate( fresnelNode175 );
				float4 lerpResult166 = lerp( saturate( ( lerpResult5_g34 * float4( 1,1,1,0 ) ) ) , float4( 0,0,0,0 ) , Fresnel_Alpha178);
				float4 Alpha80 = lerpResult166;
				float temp_output_6_0_g32 = pow( Alpha80.r , _emissive_Treshold );
				float4 lerpResult36 = lerp( _color_Base , ( ( temp_output_6_0_g32 * ( _emissiveColor * FlowFire83 ) ) * _emissive_Intensity ) , saturate( ( temp_output_6_0_g32 * DissolveVertex85 ) ));
				float4 BaseDiffuse90 = lerpResult36;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( lerpResult40 + BaseDiffuse90 ).rgb;
				float Alpha = Alpha80.r;
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
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0

			HLSLPROGRAM
			#define _RECEIVE_SHADOWS_OFF 1
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
			#define ASE_FOG 1
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
			#define ASE_NEEDS_VERT_NORMAL


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _Dissolve_texture;
			sampler2D _Flow_texture;
			CBUFFER_START( UnityPerMaterial )
			float _YOffset;
			float4 _fresnel_Color;
			float _fresnel_Emissive_Intensity;
			float _fresnelColor_Scale;
			float _fresnelColor_Power;
			float _flow_Speed_X;
			float _flow_SpeedY;
			float _flow_TilesX;
			float _flow_TilesY;
			float _triplanar_sharpness;
			float4 _color_Base;
			float _dissolve_Speed_X;
			float _dissolve_SpeedY;
			float _dissolve_TilesX;
			float _dissolve_TilesY;
			float _dissolve_Intensity;
			float _flow_speed_Multiplier_VertexMask;
			float _AlphaGlobal;
			float _fresnelAlpha_Scale;
			float _fresnelAlpha_Power;
			float _emissive_Treshold;
			float4 _emissiveColor;
			float _emissive_Intensity;
			float _Alpha_Treshold;
			CBUFFER_END


			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 transform143 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,0 ));
				float4 appendResult141 = (float4(transform143.x , ( transform143.y + ( _YOffset / 10.0 ) ) , transform143.z , transform143.w));
				float3 worldToObjDir130 = mul( GetWorldToObjectMatrix(), float4( appendResult141.xyz, 0 ) ).xyz;
				
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = worldToObjDir130;
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

				float2 appendResult15_g27 = (float2(_dissolve_Speed_X , _dissolve_SpeedY));
				float2 Speed20_g27 = appendResult15_g27;
				float3 WorldPos148 = WorldPosition;
				float3 break4_g27 = WorldPos148;
				float2 appendResult10_g27 = (float2(break4_g27.z , break4_g27.y));
				float2 appendResult12_g27 = (float2(_dissolve_TilesX , _dissolve_TilesY));
				float2 tilling22_g27 = appendResult12_g27;
				float2 panner1_g27 = ( 1.0 * _Time.y * Speed20_g27 + ( appendResult10_g27 * tilling22_g27 ));
				float3 ase_worldNormal = IN.ase_texcoord2.xyz;
				float3 WorldNormal226 = ase_worldNormal;
				float Sharprrrrpr231 = _triplanar_sharpness;
				float3 temp_cast_0 = (Sharprrrrpr231).xxx;
				float3 break29_g27 = pow( abs( WorldNormal226 ) , temp_cast_0 );
				float4 lerpResult37_g27 = lerp( float4( 0,0,0,0 ) , tex2D( _Dissolve_texture, panner1_g27 ) , saturate( break29_g27.x ));
				float2 appendResult9_g27 = (float2(break4_g27.x , break4_g27.z));
				float2 panner6_g27 = ( 1.0 * _Time.y * Speed20_g27 + ( appendResult9_g27 * tilling22_g27 ));
				float4 lerpResult39_g27 = lerp( float4( 0,0,0,0 ) , tex2D( _Dissolve_texture, panner6_g27 ) , saturate( break29_g27.y ));
				float2 appendResult11_g27 = (float2(break4_g27.x , break4_g27.y));
				float2 panner2_g27 = ( 1.0 * _Time.y * Speed20_g27 + ( appendResult11_g27 * tilling22_g27 ));
				float4 lerpResult38_g27 = lerp( float4( 0,0,0,0 ) , tex2D( _Dissolve_texture, panner2_g27 ) , saturate( break29_g27.z ));
				float lerpResult77 = lerp( 1.0 , IN.ase_color.g , saturate( ( _dissolve_Intensity / 2.0 ) ));
				float4 temp_cast_1 = (lerpResult77).xxxx;
				float2 appendResult15_g33 = (float2(( _flow_Speed_X * _flow_speed_Multiplier_VertexMask ) , ( _flow_SpeedY * _flow_speed_Multiplier_VertexMask )));
				float2 Speed20_g33 = appendResult15_g33;
				float3 break4_g33 = WorldPos148;
				float2 appendResult10_g33 = (float2(break4_g33.z , break4_g33.y));
				float2 appendResult12_g33 = (float2(_flow_TilesX , _flow_TilesY));
				float2 tilling22_g33 = appendResult12_g33;
				float2 panner1_g33 = ( 1.0 * _Time.y * Speed20_g33 + ( appendResult10_g33 * tilling22_g33 ));
				float3 temp_cast_2 = (Sharprrrrpr231).xxx;
				float3 break29_g33 = pow( abs( WorldNormal226 ) , temp_cast_2 );
				float4 lerpResult37_g33 = lerp( float4( 0,0,0,0 ) , tex2D( _Flow_texture, panner1_g33 ) , saturate( break29_g33.x ));
				float2 appendResult9_g33 = (float2(break4_g33.x , break4_g33.z));
				float2 panner6_g33 = ( 1.0 * _Time.y * Speed20_g33 + ( appendResult9_g33 * tilling22_g33 ));
				float4 lerpResult39_g33 = lerp( float4( 0,0,0,0 ) , tex2D( _Flow_texture, panner6_g33 ) , saturate( break29_g33.y ));
				float2 appendResult11_g33 = (float2(break4_g33.x , break4_g33.y));
				float2 panner2_g33 = ( 1.0 * _Time.y * Speed20_g33 + ( appendResult11_g33 * tilling22_g33 ));
				float4 lerpResult38_g33 = lerp( float4( 0,0,0,0 ) , tex2D( _Flow_texture, panner2_g33 ) , saturate( break29_g33.z ));
				float4 FlowSmoke88 = ( lerpResult37_g33 + lerpResult39_g33 + lerpResult38_g33 );
				float4 DissolveVertex85 = ( temp_cast_1 - FlowSmoke88 );
				float4 temp_cast_3 = (( _dissolve_Intensity / 10.0 )).xxxx;
				float4 lerpResult5_g34 = lerp( saturate( pow( saturate( ( ( lerpResult37_g27 + lerpResult39_g27 + lerpResult38_g27 ).b * DissolveVertex85 ) ) , temp_cast_3 ) ) , float4( 0,0,0,0 ) , _AlphaGlobal);
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float fresnelNdotV175 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode175 = ( 0.0 + _fresnelAlpha_Scale * pow( max( 1.0 - fresnelNdotV175 , 0.0001 ), _fresnelAlpha_Power ) );
				float Fresnel_Alpha178 = saturate( fresnelNode175 );
				float4 lerpResult166 = lerp( saturate( ( lerpResult5_g34 * float4( 1,1,1,0 ) ) ) , float4( 0,0,0,0 ) , Fresnel_Alpha178);
				float4 Alpha80 = lerpResult166;
				
				float Alpha = Alpha80.r;
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
-1280;93;1280;650;8622.997;2128.682;5.731017;True;False
Node;AmplifyShaderEditor.CommentaryNode;98;-5645.695,-640.4935;Inherit;False;2052.895;1023.304;FLOW;27;97;70;94;71;73;54;93;92;53;95;96;55;56;232;237;240;239;241;244;214;243;228;227;238;88;219;83;;1,0.4901961,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;212;-6784.465,-636.494;Inherit;False;1019.989;888.7086;VAR UV;8;242;218;231;217;226;148;57;225;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-5595.695,-292.5736;Inherit;False;Property;_flow_TilesY;flow_Tiles Y;20;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-5418.446,-316.1039;Inherit;False;Property;_flow_TilesX;flow_Tiles X;19;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;225;-6757.362,-360.3743;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WireNode;96;-5396.317,-46.40992;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;57;-6748.394,-586.494;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WireNode;95;-5547.188,-60.55427;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;217;-6771.864,-180.8223;Inherit;False;Property;_triplanar_sharpness;triplanar_sharpness;25;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;218;-6766.917,-58.76234;Inherit;True;Property;_Flow_texture;Flow_texture;18;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-5306.481,-33.05976;Inherit;False;Property;_flow_speed_Multiplier_VertexMask;flow_speed_Multiplier_VertexMask;23;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;231;-5979.582,-181.5827;Inherit;False;Sharprrrrpr;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;242;-5977.492,-56.95166;Inherit;False;Flow_texture;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-4986.563,-375.5252;Inherit;False;Property;_flow_Speed_X;flow_Speed_X;21;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-5144.318,-345.9431;Inherit;False;Property;_flow_SpeedY;flow_Speed Y;22;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;93;-5403.39,87.95915;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;226;-5969.015,-365.6923;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;148;-5987.106,-588.3411;Inherit;False;WorldPos;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;92;-5492.969,130.3914;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-4775.464,-47.11145;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;241;-4846.078,202.961;Inherit;False;231;Sharprrrrpr;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-4939.037,86.06331;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;97;-5292.593,135.1062;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;94;-5294.951,165.7517;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;99;-3453.786,-125.1156;Inherit;False;3193.673;1033.059;DISSOLVE & ALPHA HANDLER;27;0;80;166;169;38;66;24;35;87;85;154;153;65;155;77;89;79;5;78;18;234;223;229;230;233;235;236;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;239;-4691.542,147.7178;Inherit;False;148;WorldPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;240;-4508.972,180.945;Inherit;False;226;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;244;-4510.13,34.09756;Inherit;False;242;Flow_texture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-3349.786,0.316941;Inherit;False;Property;_dissolve_Intensity;dissolve_Intensity;1;0;Create;True;0;0;False;0;0;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;237;-4281.129,40.71563;Inherit;False;MF_Triplanar;-1;;33;e9f680472a64edf478cb4ee3f89b3c88;0;8;45;SAMPLER2D;0;False;26;FLOAT;0;False;27;FLOAT;0.5;False;19;FLOAT;1;False;18;FLOAT;1;False;28;FLOAT3;0,0,0;False;46;FLOAT3;0,0,0;False;47;FLOAT;5;False;3;COLOR;0;COLOR;24;COLOR;25
Node;AmplifyShaderEditor.SimpleAddOpNode;238;-3998.942,40.58224;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;78;-3019.747,-55.73276;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;88;-3806.374,33.30923;Inherit;False;FlowSmoke;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;5;-3013.476,140.5616;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;79;-2840.948,-51.6691;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;152;-3490.593,641.5133;Inherit;False;Property;_dissolve_TilesX;dissolve_Tiles X;2;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;234;-2772.648,571.373;Inherit;True;Property;_Dissolve_texture;Dissolve_texture;0;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;229;-2917.097,690.7863;Inherit;False;148;WorldPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;233;-2770.054,741.6166;Inherit;False;231;Sharprrrrpr;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;230;-3100.634,715.0388;Inherit;False;226;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;154;-3008.464,618.4743;Inherit;False;Property;_dissolve_SpeedY;dissolve_Speed Y;5;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;153;-3297.341,664.0436;Inherit;False;Property;_dissolve_TilesY;dissolve_Tiles Y;3;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;77;-2514.718,167.0961;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;-2466.5,-44.84421;Inherit;False;88;FlowSmoke;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;155;-3210.809,590.1921;Inherit;False;Property;_dissolve_Speed_X;dissolve_Speed_X;4;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;223;-2425.388,574.9456;Inherit;False;MF_Triplanar;-1;;27;e9f680472a64edf478cb4ee3f89b3c88;0;8;45;SAMPLER2D;0;False;26;FLOAT;0;False;27;FLOAT;0.5;False;19;FLOAT;1;False;18;FLOAT;1;False;28;FLOAT3;0,0,0;False;46;FLOAT3;0,0,0;False;47;FLOAT;5;False;3;COLOR;0;COLOR;24;COLOR;25
Node;AmplifyShaderEditor.CommentaryNode;209;2190.858,-1305.012;Inherit;False;2072.668;548.6595;;14;176;177;175;190;178;39;167;193;45;192;44;207;188;194;FRESNEL HANDLER;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;65;-2254.567,-67.01913;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;177;2240.858,-893.3336;Inherit;False;Property;_fresnelAlpha_Scale;fresnelAlpha_Scale;10;0;Create;True;0;0;False;0;1;0;0;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;85;-2072.643,-72.27537;Inherit;False;DissolveVertex;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;235;-2152.251,574.9285;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;176;2542.078,-872.3527;Inherit;False;Property;_fresnelAlpha_Power;fresnelAlpha_Power;11;0;Create;True;0;0;False;0;3;0;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;236;-1995.667,577.8774;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;87;-1964.479,727.0896;Inherit;False;85;DissolveVertex;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;175;2866.347,-963.8012;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;210;4742.81,-125.4354;Inherit;False;1231.229;418.6033;;6;143;141;125;137;104;130;Y WORLD OFFSET;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;190;3154.112,-882.0903;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-1682.841,623.8146;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;104;4792.81,-59.2533;Inherit;False;Property;_YOffset;Y Offset;24;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;178;3330.401,-885.0351;Inherit;False;Fresnel_Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-1686.078,226.0358;Inherit;False;Property;_AlphaGlobal;Alpha Global;12;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;24;-1573.773,5.274919;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;66;-1520.507,621.4595;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;169;-1271.84,605.9761;Inherit;False;178;Fresnel_Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;245;-1362.961,231.635;Inherit;False;MF_Alpha_handler;-1;;34;9ba53a059d6724547ba534bf0c40c79e;0;4;6;FLOAT;0;False;7;FLOAT;0;False;8;COLOR;0,0,0,0;False;13;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;137;4959.268,-54.21732;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;143;4899.734,83.17599;Inherit;False;1;0;FLOAT4;0,0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;125;5163.345,-75.43532;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;166;-798.8934,232.2366;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;100;-116.373,-632.8077;Inherit;False;2423.547;734.777;COLOR HANDLER;16;4;3;2;29;32;84;86;82;36;48;30;90;64;49;31;37;;0,1,0,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-574.0063,227.5941;Inherit;False;Alpha;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;101;2445.62,-635.4133;Inherit;False;2164.121;923.811;COMBINE HANDLER;7;168;43;41;40;91;42;189;;0.6862745,0,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;141;5366.366,109.5998;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;31;789.3232,-240.4235;Inherit;False;Property;_emissive_Intensity;emissive_Intensity;7;0;Create;True;0;0;False;0;0;0;0;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;2556.233,-1163.564;Inherit;False;Property;_fresnelColor_Power;fresnelColor_Power;15;0;Create;True;0;0;False;0;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;1633.907,-92.43008;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;167;4039.526,-1097.234;Inherit;False;Fresnel_Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;40;3451.688,-583.2407;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;228;-4509.465,-260.8968;Inherit;False;148;WorldPos;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;2105.254,-319.9687;Inherit;False;BaseDiffuse;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;219;-4001.999,-375.7543;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;227;-4680.605,-232.3114;Inherit;False;226;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;43;2723.818,-258.9861;Inherit;False;Property;_fresnel_Emissive_Intensity;fresnel_Emissive_Intensity;17;0;Create;True;0;0;False;0;0;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;232;-4832.589,-216.1444;Inherit;False;231;Sharprrrrpr;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;243;-4536.887,-384.5904;Inherit;False;242;Flow_texture;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;30;975.1314,-225.0153;Inherit;False;Property;_emissive_Treshold;emissive_Treshold;8;0;Create;True;0;0;False;0;0;0;0;25;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;168;2823.228,-536.4893;Inherit;False;167;Fresnel_Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;193;3273.293,-1064.455;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;81;5537.018,-256.3534;Inherit;False;80;Alpha;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;83;-3824.511,-381.1211;Inherit;False;FlowFire;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;214;-4275.323,-376.615;Inherit;False;MF_Triplanar;-1;;31;e9f680472a64edf478cb4ee3f89b3c88;0;8;45;SAMPLER2D;0;False;26;FLOAT;0;False;27;FLOAT;0.5;False;19;FLOAT;1;False;18;FLOAT;1;False;28;FLOAT3;0,0,0;False;46;FLOAT3;0,0,0;False;47;FLOAT;5;False;3;COLOR;0;COLOR;24;COLOR;25
Node;AmplifyShaderEditor.RangedFloatNode;44;2260.163,-1188.069;Inherit;False;Property;_fresnelColor_Scale;fresnelColor_Scale;14;0;Create;True;0;0;False;0;1;0;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;36;1920.385,-315.6313;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;37;1484.965,-474.112;Inherit;False;Property;_color_Base;color_Base;9;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;32;330.0878,-582.8082;Inherit;False;Property;_emissiveColor;emissive Color;6;0;Create;True;0;0;False;0;1,0.4221933,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;188;3722.317,-1094.784;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TransformDirectionNode;130;5736.04,105.1678;Inherit;False;World;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;49;1799.336,-118.8869;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;3030.829,-398.1107;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;82;1086.87,-295.269;Inherit;False;80;Alpha;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;207;3490.63,-1094.77;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;41;2513.445,-404.6919;Inherit;False;Property;_fresnel_Color;fresnel_Color;16;0;Create;True;0;0;False;0;1,0.5287268,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;29;1349.866,-291.4395;Inherit;False;MF_Emissive_handler;-1;;32;4c2d144224f39b24a93af8da62996f6d;0;4;11;FLOAT;0;False;9;COLOR;0,0,0,0;False;10;FLOAT;0;False;12;FLOAT;0;False;2;COLOR;0;FLOAT;13
Node;AmplifyShaderEditor.GetLocalVarNode;91;3447.269,-214.2004;Inherit;False;90;BaseDiffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;189;3937.758,-405.2086;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;84;643.7872,-555.5395;Inherit;False;83;FlowFire;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;19;5714.184,-357.9646;Inherit;False;Property;_Alpha_Treshold;Alpha_Treshold;13;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;39;2880.502,-1255.012;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;192;2794.263,-1075.275;Inherit;False;83;FlowFire;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;948.2978,-577.3496;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;194;3069.307,-1081.427;Inherit;False;Constant;_Float0;Float 0;26;0;Create;True;0;0;False;0;2;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;1359.406,-72.24163;Inherit;False;85;DissolveVertex;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;6200.336,-401.8839;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;M_VFX_Explosion;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;1;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;False;True;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-1141.095,-56.54941;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;96;0;55;0
WireConnection;95;0;56;0
WireConnection;231;0;217;0
WireConnection;242;0;218;0
WireConnection;93;0;96;0
WireConnection;226;0;225;0
WireConnection;148;0;57;0
WireConnection;92;0;95;0
WireConnection;70;0;53;0
WireConnection;70;1;73;0
WireConnection;71;0;54;0
WireConnection;71;1;73;0
WireConnection;97;0;93;0
WireConnection;94;0;92;0
WireConnection;237;45;244;0
WireConnection;237;26;70;0
WireConnection;237;27;71;0
WireConnection;237;19;97;0
WireConnection;237;18;94;0
WireConnection;237;28;239;0
WireConnection;237;46;240;0
WireConnection;237;47;241;0
WireConnection;238;0;237;0
WireConnection;238;1;237;24
WireConnection;238;2;237;25
WireConnection;78;0;18;0
WireConnection;88;0;238;0
WireConnection;79;0;78;0
WireConnection;77;1;5;2
WireConnection;77;2;79;0
WireConnection;223;45;234;0
WireConnection;223;26;155;0
WireConnection;223;27;154;0
WireConnection;223;19;152;0
WireConnection;223;18;153;0
WireConnection;223;28;229;0
WireConnection;223;46;230;0
WireConnection;223;47;233;0
WireConnection;65;0;77;0
WireConnection;65;1;89;0
WireConnection;85;0;65;0
WireConnection;235;0;223;0
WireConnection;235;1;223;24
WireConnection;235;2;223;25
WireConnection;236;0;235;0
WireConnection;175;2;177;0
WireConnection;175;3;176;0
WireConnection;190;0;175;0
WireConnection;35;0;236;2
WireConnection;35;1;87;0
WireConnection;178;0;190;0
WireConnection;24;0;18;0
WireConnection;66;0;35;0
WireConnection;245;6;38;0
WireConnection;245;7;24;0
WireConnection;245;8;66;0
WireConnection;137;0;104;0
WireConnection;125;0;143;2
WireConnection;125;1;137;0
WireConnection;166;0;245;0
WireConnection;166;2;169;0
WireConnection;80;0;166;0
WireConnection;141;0;143;1
WireConnection;141;1;125;0
WireConnection;141;2;143;3
WireConnection;141;3;143;4
WireConnection;48;0;29;13
WireConnection;48;1;86;0
WireConnection;167;0;188;0
WireConnection;40;0;42;0
WireConnection;40;2;168;0
WireConnection;90;0;36;0
WireConnection;219;0;214;0
WireConnection;219;1;214;24
WireConnection;219;2;214;25
WireConnection;193;0;192;0
WireConnection;193;1;194;0
WireConnection;83;0;219;0
WireConnection;214;45;243;0
WireConnection;214;26;53;0
WireConnection;214;27;54;0
WireConnection;214;19;55;0
WireConnection;214;18;56;0
WireConnection;214;28;228;0
WireConnection;214;46;227;0
WireConnection;214;47;232;0
WireConnection;36;0;37;0
WireConnection;36;1;29;0
WireConnection;36;2;49;0
WireConnection;188;0;207;0
WireConnection;130;0;141;0
WireConnection;49;0;48;0
WireConnection;42;0;41;0
WireConnection;42;1;43;0
WireConnection;207;0;39;0
WireConnection;207;1;193;0
WireConnection;29;11;82;0
WireConnection;29;9;64;0
WireConnection;29;10;31;0
WireConnection;29;12;30;0
WireConnection;189;0;40;0
WireConnection;189;1;91;0
WireConnection;39;2;44;0
WireConnection;39;3;45;0
WireConnection;64;0;32;0
WireConnection;64;1;84;0
WireConnection;1;2;189;0
WireConnection;1;3;81;0
WireConnection;1;4;19;0
WireConnection;1;5;130;0
ASEEND*/
//CHKSM=F276D5EEB6D922B50EFA7303172376382E042DAA