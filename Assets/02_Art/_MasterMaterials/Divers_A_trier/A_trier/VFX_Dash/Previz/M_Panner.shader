// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_Panner"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		_MainTex("MainTex", 2D) = "white" {}
		_MainTex01_X_speed("MainTex01_X_speed", Float) = 0
		_MainTex01_Y_speed("MainTex01_Y_speed", Float) = 0
		_MainTex01_tiles("MainTex01_tiles", Float) = 0
		_MainTex02_X_speed("MainTex02_X_speed", Float) = 1
		_MainTex02_Y_speed("MainTex02_Y_speed", Float) = 1
		_MainTex02_tiles("MainTex02_tiles", Float) = 1
		_Color("Color", Color) = (0,0,0,0)
		_Emissive_intensity("Emissive_intensity", Float) = 0
		_MaskLimits("MaskLimits", 2D) = "white" {}
		_Fresnel_power("Fresnel_power", Float) = 0
		_MainTex_blendtwovalues("MainTex_blend two values", Float) = 0

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

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
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

			sampler2D _MainTex;
			float _TimeScale;
			sampler2D _MaskLimits;
			CBUFFER_START( UnityPerMaterial )
			float _MainTex01_X_speed;
			float _MainTex01_Y_speed;
			float _MainTex01_tiles;
			float _MainTex02_X_speed;
			float _MainTex02_Y_speed;
			float _MainTex02_tiles;
			float4 _Color;
			float _MainTex_blendtwovalues;
			float _Fresnel_power;
			float _Emissive_intensity;
			CBUFFER_END


			
			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_texcoord3.zw = v.ase_texcoord1.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.w = 0;
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
				float TimeScale87 = _TimeScale;
				float mulTime5_g3 = _TimeParameters.x * TimeScale87;
				float2 appendResult4_g3 = (float2(_MainTex01_X_speed , _MainTex01_Y_speed));
				float2 uv03_g3 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner6_g3 = ( mulTime5_g3 * appendResult4_g3 + ( uv03_g3 * _MainTex01_tiles ));
				float4 MainTex_0151 = tex2D( _MainTex, panner6_g3 );
				float mulTime5_g4 = _TimeParameters.x * TimeScale87;
				float2 appendResult4_g4 = (float2(_MainTex02_X_speed , _MainTex02_Y_speed));
				float2 uv03_g4 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner6_g4 = ( mulTime5_g4 * appendResult4_g4 + ( uv03_g4 * _MainTex02_tiles ));
				float4 MainTex_0250 = tex2D( _MainTex, panner6_g4 );
				float4 lerpResult45 = lerp( MainTex_0151 , MainTex_0250 , _MainTex_blendtwovalues);
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float fresnelNdotV30 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode30 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV30, _Fresnel_power ) );
				float4 lerpResult14 = lerp( ( MainTex_0151 * MainTex_0250 ) , ( _Color * lerpResult45 ) , fresnelNode30);
				
				float lerpResult47 = lerp( MainTex_0151.a , MainTex_0250.a , _MainTex_blendtwovalues);
				float2 uv126 = IN.ase_texcoord3.zw * float2( 1,1 ) + float2( 0,0 );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( lerpResult14 * _Emissive_intensity ).rgb;
				float Alpha = saturate( ( lerpResult47 - tex2D( _MaskLimits, uv126 ).a ) );
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

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
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
			float _TimeScale;
			sampler2D _MaskLimits;
			CBUFFER_START( UnityPerMaterial )
			float _MainTex01_X_speed;
			float _MainTex01_Y_speed;
			float _MainTex01_tiles;
			float _MainTex02_X_speed;
			float _MainTex02_Y_speed;
			float _MainTex02_tiles;
			float4 _Color;
			float _MainTex_blendtwovalues;
			float _Fresnel_power;
			float _Emissive_intensity;
			CBUFFER_END


			
			float3 _LightDirection;

			VertexOutput ShadowPassVertex( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord2.zw = v.ase_texcoord1.xy;
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

				float TimeScale87 = _TimeScale;
				float mulTime5_g3 = _TimeParameters.x * TimeScale87;
				float2 appendResult4_g3 = (float2(_MainTex01_X_speed , _MainTex01_Y_speed));
				float2 uv03_g3 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner6_g3 = ( mulTime5_g3 * appendResult4_g3 + ( uv03_g3 * _MainTex01_tiles ));
				float4 MainTex_0151 = tex2D( _MainTex, panner6_g3 );
				float mulTime5_g4 = _TimeParameters.x * TimeScale87;
				float2 appendResult4_g4 = (float2(_MainTex02_X_speed , _MainTex02_Y_speed));
				float2 uv03_g4 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner6_g4 = ( mulTime5_g4 * appendResult4_g4 + ( uv03_g4 * _MainTex02_tiles ));
				float4 MainTex_0250 = tex2D( _MainTex, panner6_g4 );
				float lerpResult47 = lerp( MainTex_0151.a , MainTex_0250.a , _MainTex_blendtwovalues);
				float2 uv126 = IN.ase_texcoord2.zw * float2( 1,1 ) + float2( 0,0 );
				
				float Alpha = saturate( ( lerpResult47 - tex2D( _MaskLimits, uv126 ).a ) );
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

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
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
			float _TimeScale;
			sampler2D _MaskLimits;
			CBUFFER_START( UnityPerMaterial )
			float _MainTex01_X_speed;
			float _MainTex01_Y_speed;
			float _MainTex01_tiles;
			float _MainTex02_X_speed;
			float _MainTex02_Y_speed;
			float _MainTex02_tiles;
			float4 _Color;
			float _MainTex_blendtwovalues;
			float _Fresnel_power;
			float _Emissive_intensity;
			CBUFFER_END


			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord2.zw = v.ase_texcoord1.xy;
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

				float TimeScale87 = _TimeScale;
				float mulTime5_g3 = _TimeParameters.x * TimeScale87;
				float2 appendResult4_g3 = (float2(_MainTex01_X_speed , _MainTex01_Y_speed));
				float2 uv03_g3 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner6_g3 = ( mulTime5_g3 * appendResult4_g3 + ( uv03_g3 * _MainTex01_tiles ));
				float4 MainTex_0151 = tex2D( _MainTex, panner6_g3 );
				float mulTime5_g4 = _TimeParameters.x * TimeScale87;
				float2 appendResult4_g4 = (float2(_MainTex02_X_speed , _MainTex02_Y_speed));
				float2 uv03_g4 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner6_g4 = ( mulTime5_g4 * appendResult4_g4 + ( uv03_g4 * _MainTex02_tiles ));
				float4 MainTex_0250 = tex2D( _MainTex, panner6_g4 );
				float lerpResult47 = lerp( MainTex_0151.a , MainTex_0250.a , _MainTex_blendtwovalues);
				float2 uv126 = IN.ase_texcoord2.zw * float2( 1,1 ) + float2( 0,0 );
				
				float Alpha = saturate( ( lerpResult47 - tex2D( _MaskLimits, uv126 ).a ) );
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
569;217;1101;617;-1795.24;-327.0469;2.078175;True;True
Node;AmplifyShaderEditor.CommentaryNode;90;-739.1499,454.8458;Inherit;False;547.9703;166.2141;TimeScale;2;87;84;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-689.1499,505.0598;Inherit;False;Global;_TimeScale;_TimeScale;12;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;48;-1154.359,-366.7231;Inherit;False;1413.959;641.2231;MainTex;14;37;3;4;0;2;10;43;9;42;7;41;8;86;88;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;-415.1795,504.8458;Inherit;False;TimeScale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-738.7185,-288.4427;Inherit;False;Property;_MainTex02_Y_speed;MainTex02_Y_speed;5;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;86;-674.0349,136.1129;Inherit;False;87;TimeScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-993.8801,-316.7231;Inherit;False;Property;_MainTex02_X_speed;MainTex02_X_speed;4;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-988.4001,116.5;Inherit;False;Property;_MainTex01_tiles;MainTex01_tiles;3;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-701.2,88.30001;Inherit;False;Property;_MainTex01_Y_speed;MainTex01_Y_speed;2;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-857.2,68.9;Inherit;False;Property;_MainTex01_X_speed;MainTex01_X_speed;1;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-1104.359,-260.243;Inherit;False;Property;_MainTex02_tiles;MainTex02_tiles;6;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-540.791,-238.2343;Inherit;False;87;TimeScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;83;-295.0614,-305.4088;Inherit;False;MF_Tiles;-1;;4;2fa329d2d99691549897442d611b24f3;0;4;7;FLOAT;0;False;8;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;82;-424,69.5;Inherit;False;MF_Tiles;-1;;3;2fa329d2d99691549897442d611b24f3;0;4;7;FLOAT;0;False;8;FLOAT;0;False;10;FLOAT;0;False;11;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;10;-60.40002,44.50002;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;False;0;-1;6de8369f81bc68848b5ca719c5bebae8;6de8369f81bc68848b5ca719c5bebae8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;37;-61.39082,-202.7318;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;False;0;-1;6de8369f81bc68848b5ca719c5bebae8;6de8369f81bc68848b5ca719c5bebae8;True;0;False;white;Auto;False;Instance;10;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;50;346.79,-201.0086;Inherit;False;MainTex_02;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;335.6793,43.08289;Inherit;False;MainTex_01;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;46;1043.154,-84.14597;Inherit;False;Property;_MainTex_blendtwovalues;MainTex_blend two values;11;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;1566.866,723.463;Inherit;False;50;MainTex_02;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;1748.062,594.8826;Inherit;False;51;MainTex_01;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;57;2021.088,598.5107;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;58;1806.687,729.7108;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TextureCoordinatesNode;26;1825.227,1031.728;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;93;1479.229,811.3269;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;24;2198.322,1003.632;Inherit;True;Property;_MaskLimits;MaskLimits;9;0;Create;True;0;0;False;0;-1;7d72ce7458c0384488e2ffc755565ea2;7d72ce7458c0384488e2ffc755565ea2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;47;2291.904,781.2454;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;100;2725.742,875.698;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;103;2940.121,898.0453;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;65;2531.74,5.680386;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;102;3911.405,888.1193;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;1329.632,-103.3223;Inherit;False;50;MainTex_02;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;4392.061,290.4331;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;67;3464.577,525.5181;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;12;4128.75,310.1615;Inherit;False;Property;_Emissive_intensity;Emissive_intensity;8;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;3446.023,-225.3077;Inherit;False;51;MainTex_01;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;14;4037.111,487.5795;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;71;2696.179,22.87436;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;68;3374.873,275.6569;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;72;2444.221,-88.37994;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;66;3393.561,439.1672;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;16;2002.957,-169.9142;Inherit;False;Property;_Color;Color;7;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;45;1677.073,-124.5972;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;3866.532,-221.4754;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;30;3065.972,532.1328;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;2300.312,-147.1814;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;3249.3,-194.687;Inherit;False;50;MainTex_02;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;64;3339.098,57.20105;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;1483.526,-129.2024;Inherit;False;51;MainTex_01;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;70;3664.747,536.6073;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;32;2758.173,623.3331;Inherit;False;Property;_Fresnel_power;Fresnel_power;10;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;69;3088.842,16.32977;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;91;3897.813,503.9578;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;4651.96,291.042;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;M_Panner;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;1;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;True;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;87;0;84;0
WireConnection;83;7;42;0
WireConnection;83;8;41;0
WireConnection;83;10;43;0
WireConnection;83;11;88;0
WireConnection;82;7;7;0
WireConnection;82;8;8;0
WireConnection;82;10;9;0
WireConnection;82;11;86;0
WireConnection;10;1;82;0
WireConnection;37;1;83;0
WireConnection;50;0;37;0
WireConnection;51;0;10;0
WireConnection;57;0;56;0
WireConnection;58;0;55;0
WireConnection;93;0;46;0
WireConnection;24;1;26;0
WireConnection;47;0;57;3
WireConnection;47;1;58;3
WireConnection;47;2;93;0
WireConnection;100;0;47;0
WireConnection;100;1;24;4
WireConnection;103;0;100;0
WireConnection;65;0;72;0
WireConnection;102;0;103;0
WireConnection;11;0;14;0
WireConnection;11;1;12;0
WireConnection;67;0;66;0
WireConnection;14;0;38;0
WireConnection;14;1;91;0
WireConnection;14;2;30;0
WireConnection;71;0;65;0
WireConnection;68;0;64;0
WireConnection;72;0;31;0
WireConnection;66;0;68;0
WireConnection;45;0;54;0
WireConnection;45;1;53;0
WireConnection;45;2;46;0
WireConnection;38;0;49;0
WireConnection;38;1;52;0
WireConnection;30;3;32;0
WireConnection;31;0;16;0
WireConnection;31;1;45;0
WireConnection;64;0;69;0
WireConnection;70;0;67;0
WireConnection;69;0;71;0
WireConnection;91;0;70;0
WireConnection;1;2;11;0
WireConnection;1;3;102;0
ASEEND*/
//CHKSM=0790D14A6187958CE3207262426E31D3858F0263