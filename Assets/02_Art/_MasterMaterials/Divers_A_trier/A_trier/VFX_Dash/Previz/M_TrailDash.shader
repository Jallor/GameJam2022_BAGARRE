// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_TrailDash"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_MainTex_color("MainTex_color", Color) = (1,0,0,0)
		_MainTexture("_MainTexture", 2D) = "white" {}
		_Main_X_speed("Main_X_speed", Float) = 0
		_Main_Y_speed("Main_Y_speed", Float) = 0
		_NoiseMask_tex("NoiseMask_tex", 2D) = "white" {}
		_NoiseMask_size("NoiseMask_size", Float) = 0
		_NoiseMask_X_speed("NoiseMask_X_speed", Float) = 0
		_NoiseMask_Y_speed("NoiseMask_Y_speed", Float) = 0
		_Secondary_tex("Secondary_tex", 2D) = "white" {}
		_Secondary_X_speed("Secondary_X_speed", Float) = 0
		_Secondary_Y_speed("Secondary_Y_speed", Float) = 0
		_Secondary_X_tiles("Secondary_X_tiles", Float) = 1
		_Secondary_Y_tiles("Secondary_Y_tiles", Float) = 1
		_MaskGlobal_tex("MaskGlobal_tex", 2D) = "white" {}
		_MaskGlobal_X_speed("MaskGlobal_X_speed", Float) = 0
		_MaskGlobal_Y_speed("MaskGlobal_Y_speed", Float) = 0
		_MaskGlobal_tiles("MaskGlobal_tiles", Float) = 0
		_NoiseDeformer_Scale("NoiseDeformer_Scale", Float) = 2
		_NoiseDeformer_Amount("NoiseDeformer_Amount", Float) = 0.5
		_Emissive_intensity("Emissive_intensity", Float) = 0
		[Toggle(_DEBUG_ON)] _DEBUG("DEBUG?", Float) = 0
		[Toggle(_DEBUGFLUXORLINE_ON)] _DEBUGFLUXORLINE("DEBUG FLUX OR LINE", Float) = 0
		_TX_Line_Dissolve("TX_Line_Dissolve", 2D) = "white" {}
		_DISSOLVE("DISSOLVE !", Float) = 0.5
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

			#pragma shader_feature_local _DEBUG_ON
			#pragma shader_feature_local _DEBUGFLUXORLINE_ON


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

			sampler2D _Secondary_tex;
			float _TimeScale;
			sampler2D _MainTexture;
			sampler2D _MaskGlobal_tex;
			sampler2D _NoiseMask_tex;
			sampler2D _TX_Line_Dissolve;
			CBUFFER_START( UnityPerMaterial )
			float _Secondary_X_speed;
			float _Secondary_Y_speed;
			float _Secondary_X_tiles;
			float _Secondary_Y_tiles;
			float _Main_Y_speed;
			float _Main_X_speed;
			float _NoiseDeformer_Scale;
			float _NoiseDeformer_Amount;
			float4 _MainTex_color;
			float _Emissive_intensity;
			float _MaskGlobal_X_speed;
			float _MaskGlobal_Y_speed;
			float _MaskGlobal_tiles;
			float _NoiseMask_X_speed;
			float _NoiseMask_Y_speed;
			float _NoiseMask_size;
			float4 _TX_Line_Dissolve_ST;
			float _DISSOLVE;
			CBUFFER_END


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

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
				float TimeScale146 = _TimeScale;
				float mulTime5_g8 = _TimeParameters.x * TimeScale146;
				float2 appendResult4_g8 = (float2(_Secondary_X_speed , _Secondary_Y_speed));
				float2 uv03_g8 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g8 = (float2(_Secondary_X_tiles , _Secondary_Y_tiles));
				float2 panner6_g8 = ( mulTime5_g8 * appendResult4_g8 + ( uv03_g8 * appendResult12_g8 ));
				float4 tex2DNode90 = tex2D( _Secondary_tex, panner6_g8 );
				float4 Secondary_AlbedoEmissive159 = tex2DNode90;
				float4 VERTEXCOLOR121 = IN.ase_color;
				float mulTime5_g5 = _TimeParameters.x * TimeScale146;
				float2 appendResult4_g5 = (float2(_Main_Y_speed , _Main_X_speed));
				float2 uv03_g5 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g5 = (float2(1.0 , 1.0));
				float2 panner6_g5 = ( mulTime5_g5 * appendResult4_g5 + ( uv03_g5 * appendResult12_g5 ));
				float2 uv06 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 TextureCoordinate106 = uv06;
				float mulTime2 = _TimeParameters.x * TimeScale146;
				float simplePerlin2D19 = snoise( ( ( mulTime2 * 1.0 ) + TextureCoordinate106 )*_NoiseDeformer_Scale );
				simplePerlin2D19 = simplePerlin2D19*0.5 + 0.5;
				float2 temp_cast_0 = (pow( simplePerlin2D19 , 2.0 )).xx;
				float2 lerpResult25 = lerp( TextureCoordinate106 , temp_cast_0 , _NoiseDeformer_Amount);
				float4 MainTex101 = tex2D( _MainTexture, ( panner6_g5 + lerpResult25 ) );
				float4 Main_AlbedoEmissive111 = ( ( VERTEXCOLOR121 * ( MainTex101 * _MainTex_color ) ) * _Emissive_intensity );
				float mulTime5_g9 = _TimeParameters.x * TimeScale146;
				float2 appendResult4_g9 = (float2(_MaskGlobal_X_speed , _MaskGlobal_Y_speed));
				float2 uv03_g9 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g9 = (float2(_MaskGlobal_tiles , _MaskGlobal_tiles));
				float2 panner6_g9 = ( mulTime5_g9 * appendResult4_g9 + ( uv03_g9 * appendResult12_g9 ));
				float MaskGlobal185 = tex2D( _MaskGlobal_tex, panner6_g9 ).a;
				float4 lerpResult93 = lerp( Secondary_AlbedoEmissive159 , Main_AlbedoEmissive111 , MaskGlobal185);
				#ifdef _DEBUGFLUXORLINE_ON
				float4 staticSwitch156 = Secondary_AlbedoEmissive159;
				#else
				float4 staticSwitch156 = Main_AlbedoEmissive111;
				#endif
				#ifdef _DEBUG_ON
				float4 staticSwitch116 = staticSwitch156;
				#else
				float4 staticSwitch116 = lerpResult93;
				#endif
				
				float Secondary_Alpha160 = tex2DNode90.a;
				float mulTime5_g6 = _TimeParameters.x * TimeScale146;
				float2 appendResult4_g6 = (float2(_NoiseMask_X_speed , _NoiseMask_Y_speed));
				float2 uv03_g6 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g6 = (float2(_NoiseMask_size , _NoiseMask_size));
				float2 panner6_g6 = ( mulTime5_g6 * appendResult4_g6 + ( uv03_g6 * appendResult12_g6 ));
				float NoiseMask100 = tex2D( _NoiseMask_tex, panner6_g6 ).a;
				float Main_Alpha112 = ( MainTex101.a * NoiseMask100 );
				float lerpResult94 = lerp( Secondary_Alpha160 , Main_Alpha112 , MaskGlobal185);
				#ifdef _DEBUGFLUXORLINE_ON
				float staticSwitch164 = Secondary_Alpha160;
				#else
				float staticSwitch164 = Main_Alpha112;
				#endif
				#ifdef _DEBUG_ON
				float staticSwitch117 = staticSwitch164;
				#else
				float staticSwitch117 = lerpResult94;
				#endif
				float temp_output_12_0 = ( staticSwitch117 * VERTEXCOLOR121.a );
				float2 uv_TX_Line_Dissolve = IN.ase_texcoord3.xy * _TX_Line_Dissolve_ST.xy + _TX_Line_Dissolve_ST.zw;
				float temp_output_177_0 = ( 1.0 - _DISSOLVE );
				float temp_output_176_0 = ( tex2D( _TX_Line_Dissolve, uv_TX_Line_Dissolve ).a + temp_output_177_0 );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = staticSwitch116.rgb;
				float Alpha = ( temp_output_12_0 * temp_output_176_0 );
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

			#pragma shader_feature_local _DEBUG_ON
			#pragma shader_feature_local _DEBUGFLUXORLINE_ON


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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _Secondary_tex;
			float _TimeScale;
			sampler2D _MainTexture;
			sampler2D _NoiseMask_tex;
			sampler2D _MaskGlobal_tex;
			sampler2D _TX_Line_Dissolve;
			CBUFFER_START( UnityPerMaterial )
			float _Secondary_X_speed;
			float _Secondary_Y_speed;
			float _Secondary_X_tiles;
			float _Secondary_Y_tiles;
			float _Main_Y_speed;
			float _Main_X_speed;
			float _NoiseDeformer_Scale;
			float _NoiseDeformer_Amount;
			float4 _MainTex_color;
			float _Emissive_intensity;
			float _MaskGlobal_X_speed;
			float _MaskGlobal_Y_speed;
			float _MaskGlobal_tiles;
			float _NoiseMask_X_speed;
			float _NoiseMask_Y_speed;
			float _NoiseMask_size;
			float4 _TX_Line_Dissolve_ST;
			float _DISSOLVE;
			CBUFFER_END


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			float3 _LightDirection;

			VertexOutput ShadowPassVertex( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
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

				float TimeScale146 = _TimeScale;
				float mulTime5_g8 = _TimeParameters.x * TimeScale146;
				float2 appendResult4_g8 = (float2(_Secondary_X_speed , _Secondary_Y_speed));
				float2 uv03_g8 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g8 = (float2(_Secondary_X_tiles , _Secondary_Y_tiles));
				float2 panner6_g8 = ( mulTime5_g8 * appendResult4_g8 + ( uv03_g8 * appendResult12_g8 ));
				float4 tex2DNode90 = tex2D( _Secondary_tex, panner6_g8 );
				float Secondary_Alpha160 = tex2DNode90.a;
				float mulTime5_g5 = _TimeParameters.x * TimeScale146;
				float2 appendResult4_g5 = (float2(_Main_Y_speed , _Main_X_speed));
				float2 uv03_g5 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g5 = (float2(1.0 , 1.0));
				float2 panner6_g5 = ( mulTime5_g5 * appendResult4_g5 + ( uv03_g5 * appendResult12_g5 ));
				float2 uv06 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 TextureCoordinate106 = uv06;
				float mulTime2 = _TimeParameters.x * TimeScale146;
				float simplePerlin2D19 = snoise( ( ( mulTime2 * 1.0 ) + TextureCoordinate106 )*_NoiseDeformer_Scale );
				simplePerlin2D19 = simplePerlin2D19*0.5 + 0.5;
				float2 temp_cast_0 = (pow( simplePerlin2D19 , 2.0 )).xx;
				float2 lerpResult25 = lerp( TextureCoordinate106 , temp_cast_0 , _NoiseDeformer_Amount);
				float4 MainTex101 = tex2D( _MainTexture, ( panner6_g5 + lerpResult25 ) );
				float mulTime5_g6 = _TimeParameters.x * TimeScale146;
				float2 appendResult4_g6 = (float2(_NoiseMask_X_speed , _NoiseMask_Y_speed));
				float2 uv03_g6 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g6 = (float2(_NoiseMask_size , _NoiseMask_size));
				float2 panner6_g6 = ( mulTime5_g6 * appendResult4_g6 + ( uv03_g6 * appendResult12_g6 ));
				float NoiseMask100 = tex2D( _NoiseMask_tex, panner6_g6 ).a;
				float Main_Alpha112 = ( MainTex101.a * NoiseMask100 );
				float mulTime5_g9 = _TimeParameters.x * TimeScale146;
				float2 appendResult4_g9 = (float2(_MaskGlobal_X_speed , _MaskGlobal_Y_speed));
				float2 uv03_g9 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g9 = (float2(_MaskGlobal_tiles , _MaskGlobal_tiles));
				float2 panner6_g9 = ( mulTime5_g9 * appendResult4_g9 + ( uv03_g9 * appendResult12_g9 ));
				float MaskGlobal185 = tex2D( _MaskGlobal_tex, panner6_g9 ).a;
				float lerpResult94 = lerp( Secondary_Alpha160 , Main_Alpha112 , MaskGlobal185);
				#ifdef _DEBUGFLUXORLINE_ON
				float staticSwitch164 = Secondary_Alpha160;
				#else
				float staticSwitch164 = Main_Alpha112;
				#endif
				#ifdef _DEBUG_ON
				float staticSwitch117 = staticSwitch164;
				#else
				float staticSwitch117 = lerpResult94;
				#endif
				float4 VERTEXCOLOR121 = IN.ase_color;
				float temp_output_12_0 = ( staticSwitch117 * VERTEXCOLOR121.a );
				float2 uv_TX_Line_Dissolve = IN.ase_texcoord2.xy * _TX_Line_Dissolve_ST.xy + _TX_Line_Dissolve_ST.zw;
				float temp_output_177_0 = ( 1.0 - _DISSOLVE );
				float temp_output_176_0 = ( tex2D( _TX_Line_Dissolve, uv_TX_Line_Dissolve ).a + temp_output_177_0 );
				
				float Alpha = ( temp_output_12_0 * temp_output_176_0 );
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

			#pragma shader_feature_local _DEBUG_ON
			#pragma shader_feature_local _DEBUGFLUXORLINE_ON


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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _Secondary_tex;
			float _TimeScale;
			sampler2D _MainTexture;
			sampler2D _NoiseMask_tex;
			sampler2D _MaskGlobal_tex;
			sampler2D _TX_Line_Dissolve;
			CBUFFER_START( UnityPerMaterial )
			float _Secondary_X_speed;
			float _Secondary_Y_speed;
			float _Secondary_X_tiles;
			float _Secondary_Y_tiles;
			float _Main_Y_speed;
			float _Main_X_speed;
			float _NoiseDeformer_Scale;
			float _NoiseDeformer_Amount;
			float4 _MainTex_color;
			float _Emissive_intensity;
			float _MaskGlobal_X_speed;
			float _MaskGlobal_Y_speed;
			float _MaskGlobal_tiles;
			float _NoiseMask_X_speed;
			float _NoiseMask_Y_speed;
			float _NoiseMask_size;
			float4 _TX_Line_Dissolve_ST;
			float _DISSOLVE;
			CBUFFER_END


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
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

				float TimeScale146 = _TimeScale;
				float mulTime5_g8 = _TimeParameters.x * TimeScale146;
				float2 appendResult4_g8 = (float2(_Secondary_X_speed , _Secondary_Y_speed));
				float2 uv03_g8 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g8 = (float2(_Secondary_X_tiles , _Secondary_Y_tiles));
				float2 panner6_g8 = ( mulTime5_g8 * appendResult4_g8 + ( uv03_g8 * appendResult12_g8 ));
				float4 tex2DNode90 = tex2D( _Secondary_tex, panner6_g8 );
				float Secondary_Alpha160 = tex2DNode90.a;
				float mulTime5_g5 = _TimeParameters.x * TimeScale146;
				float2 appendResult4_g5 = (float2(_Main_Y_speed , _Main_X_speed));
				float2 uv03_g5 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g5 = (float2(1.0 , 1.0));
				float2 panner6_g5 = ( mulTime5_g5 * appendResult4_g5 + ( uv03_g5 * appendResult12_g5 ));
				float2 uv06 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 TextureCoordinate106 = uv06;
				float mulTime2 = _TimeParameters.x * TimeScale146;
				float simplePerlin2D19 = snoise( ( ( mulTime2 * 1.0 ) + TextureCoordinate106 )*_NoiseDeformer_Scale );
				simplePerlin2D19 = simplePerlin2D19*0.5 + 0.5;
				float2 temp_cast_0 = (pow( simplePerlin2D19 , 2.0 )).xx;
				float2 lerpResult25 = lerp( TextureCoordinate106 , temp_cast_0 , _NoiseDeformer_Amount);
				float4 MainTex101 = tex2D( _MainTexture, ( panner6_g5 + lerpResult25 ) );
				float mulTime5_g6 = _TimeParameters.x * TimeScale146;
				float2 appendResult4_g6 = (float2(_NoiseMask_X_speed , _NoiseMask_Y_speed));
				float2 uv03_g6 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g6 = (float2(_NoiseMask_size , _NoiseMask_size));
				float2 panner6_g6 = ( mulTime5_g6 * appendResult4_g6 + ( uv03_g6 * appendResult12_g6 ));
				float NoiseMask100 = tex2D( _NoiseMask_tex, panner6_g6 ).a;
				float Main_Alpha112 = ( MainTex101.a * NoiseMask100 );
				float mulTime5_g9 = _TimeParameters.x * TimeScale146;
				float2 appendResult4_g9 = (float2(_MaskGlobal_X_speed , _MaskGlobal_Y_speed));
				float2 uv03_g9 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12_g9 = (float2(_MaskGlobal_tiles , _MaskGlobal_tiles));
				float2 panner6_g9 = ( mulTime5_g9 * appendResult4_g9 + ( uv03_g9 * appendResult12_g9 ));
				float MaskGlobal185 = tex2D( _MaskGlobal_tex, panner6_g9 ).a;
				float lerpResult94 = lerp( Secondary_Alpha160 , Main_Alpha112 , MaskGlobal185);
				#ifdef _DEBUGFLUXORLINE_ON
				float staticSwitch164 = Secondary_Alpha160;
				#else
				float staticSwitch164 = Main_Alpha112;
				#endif
				#ifdef _DEBUG_ON
				float staticSwitch117 = staticSwitch164;
				#else
				float staticSwitch117 = lerpResult94;
				#endif
				float4 VERTEXCOLOR121 = IN.ase_color;
				float temp_output_12_0 = ( staticSwitch117 * VERTEXCOLOR121.a );
				float2 uv_TX_Line_Dissolve = IN.ase_texcoord2.xy * _TX_Line_Dissolve_ST.xy + _TX_Line_Dissolve_ST.zw;
				float temp_output_177_0 = ( 1.0 - _DISSOLVE );
				float temp_output_176_0 = ( tex2D( _TX_Line_Dissolve, uv_TX_Line_Dissolve ).a + temp_output_177_0 );
				
				float Alpha = ( temp_output_12_0 * temp_output_176_0 );
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
0;6;1280;653;4727.355;373.029;2.539637;True;False
Node;AmplifyShaderEditor.CommentaryNode;145;-3809.761,629.1464;Inherit;False;547.9703;166.2141;TimeScale;2;147;146;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-3759.761,679.3603;Inherit;False;Global;_TimeScale;_TimeScale;12;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;146;-3485.79,679.1464;Inherit;False;TimeScale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;109;-3805.41,83.97681;Inherit;False;694.7114;209;Texture coordinate;2;6;106;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-3755.41,133.9768;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;110;-2753.032,586.6585;Inherit;False;1835.511;713.6932;NoiseDeformer;11;23;19;21;2;22;108;20;24;25;107;26;;0,0.4901961,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;144;-2901.91,735.9357;Inherit;False;146;TimeScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;106;-3356.699,134.1469;Inherit;False;TextureCoordinate;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;2;-2706.924,740.1882;Inherit;False;1;0;FLOAT;200;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-2703.032,859.1835;Inherit;False;Constant;_NoiseDeformer_speed;NoiseDeformer_speed;6;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;-2554.803,636.6585;Inherit;False;106;TextureCoordinate;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-2471.409,744.0427;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-2320.851,931.2108;Inherit;False;Property;_NoiseDeformer_Scale;NoiseDeformer_Scale;17;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;23;-2288.42,746.6412;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;128;-1592.664,154.8687;Inherit;False;1594.442;335.4109;MainTex;7;36;4;5;1;101;149;140;;0,1,0,1;0;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;19;-2103.907,906.2274;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;-1484.996,879.7844;Inherit;False;106;TextureCoordinate;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-1542.664,251.7543;Inherit;False;Property;_Main_X_speed;Main_X_speed;2;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-1361.835,228.2181;Inherit;False;Property;_Main_Y_speed;Main_Y_speed;3;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;24;-1750.241,913.9195;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1514.353,1184.352;Inherit;False;Property;_NoiseDeformer_Amount;NoiseDeformer_Amount;18;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;-1395.671,326.3958;Inherit;False;146;TimeScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;131;-1717.814,-213.7813;Inherit;False;1741.273;280;Comment;6;70;75;69;14;100;150;;0,0.4901961,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;140;-1136.128,234.5406;Inherit;False;MF_Tiles;-1;;5;2fa329d2d99691549897442d611b24f3;0;5;7;FLOAT;0;False;8;FLOAT;0;False;10;FLOAT;1;False;13;FLOAT;1;False;11;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;25;-1182.52,886.0737;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-1238.508,-93.02417;Inherit;False;Property;_NoiseMask_size;NoiseMask_size;5;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;150;-1430.642,-43.48201;Inherit;False;146;TimeScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-1667.814,-143.0046;Inherit;False;Property;_NoiseMask_X_speed;NoiseMask_X_speed;6;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-1446.05,-118.7837;Inherit;False;Property;_NoiseMask_Y_speed;NoiseMask_Y_speed;7;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;5;-878.2708,236.2796;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;141;-967.2156,-136.2;Inherit;False;MF_Tiles;-1;;6;2fa329d2d99691549897442d611b24f3;0;5;7;FLOAT;0;False;8;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT;1;False;11;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-540.2566,205.371;Inherit;True;Property;_MainTexture;_MainTexture;1;0;Create;True;0;0;False;0;-1;3cb4aeda878220e4a9dd9615f2d716ab;3cb4aeda878220e4a9dd9615f2d716ab;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;129;264.2898,-64.35423;Inherit;False;2282.352;488.5809;Comment;17;66;64;65;99;73;112;111;104;67;7;122;68;13;8;62;103;102;;0.7058824,0,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;127;2693.877,440.6889;Inherit;False;1556.482;350.9862;Second Texture;7;148;154;171;90;143;89;83;;0,1,0,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-222.2222,204.8687;Inherit;False;MainTex;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;14;-545.2963,-163.7813;Inherit;True;Property;_NoiseMask_tex;NoiseMask_tex;4;0;Create;True;0;0;False;0;-1;09e58f811a4ad7846a83090ab62decc8;09e58f811a4ad7846a83090ab62decc8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;126;2686.749,-100.3517;Inherit;False;1545.504;288.7837;Global Mask;6;151;142;76;77;82;95;;0,0.4901961,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;89;2977.624,510.9735;Inherit;False;Property;_Secondary_X_speed;Secondary_X_speed;9;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;2740.877,535.6286;Inherit;False;Property;_Secondary_Y_speed;Secondary_Y_speed;10;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;2975.979,11.1823;Inherit;False;Property;_MaskGlobal_Y_speed;MaskGlobal_Y_speed;15;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;151;3226.415,82.95349;Inherit;False;146;TimeScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;171;3111.529,560.2224;Inherit;False;Property;_Secondary_X_tiles;Secondary_X_tiles;11;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;154;2943.044,584.7692;Inherit;False;Property;_Secondary_Y_tiles;Secondary_Y_tiles;12;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;148;2973.322,686.2588;Inherit;False;146;TimeScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;2771.504,34.62541;Inherit;False;Property;_MaskGlobal_tiles;MaskGlobal_tiles;16;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;1046.096,157.4439;Inherit;False;101;MainTex;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;100;-200.5415,-66.53988;Inherit;False;NoiseMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;3180.754,-13.78573;Inherit;False;Property;_MaskGlobal_X_speed;MaskGlobal_X_speed;14;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;143;3389.702,517.5836;Inherit;False;MF_Tiles;-1;;8;2fa329d2d99691549897442d611b24f3;0;5;7;FLOAT;0;False;8;FLOAT;0;False;10;FLOAT;1;False;13;FLOAT;1;False;11;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;103;1317.971,164.6429;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.FunctionNode;142;3541.085,-7.262813;Inherit;False;MF_Tiles;-1;;9;2fa329d2d99691549897442d611b24f3;0;5;7;FLOAT;0;False;8;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT;1;False;11;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;1775.575,261.8041;Inherit;False;100;NoiseMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;90;3642.332,490.6889;Inherit;True;Property;_Secondary_tex;Secondary_tex;8;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;95;3927.21,-37.36909;Inherit;True;Property;_MaskGlobal_tex;MaskGlobal_tex;13;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;125;-3807.038,326.8344;Inherit;False;696.2063;261.9018;VertexColor;2;121;10;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;1994.236,243.5724;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;112;2287.382,237.8382;Inherit;False;Main_Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;124;4564.905,436.9025;Inherit;False;1473.901;738.4189;Alpha;8;114;94;117;12;123;11;158;187;;0.7058824,0,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;185;4261.906,57.54679;Inherit;False;MaskGlobal;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;160;4278.683,587.794;Inherit;False;Secondary_Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;10;-3757.038,381.7362;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;168;4803.656,1328.397;Inherit;False;731.7427;192.2938;DEBUG;3;164;166;165;;0.9963673,1,0,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;4809.257,628.3948;Inherit;False;112;Main_Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;158;4601.044,605.6498;Inherit;False;160;Secondary_Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;166;4853.656,1386.588;Inherit;False;112;Main_Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;165;4942.795,1404.691;Inherit;False;160;Secondary_Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;187;4946.308,653.5229;Inherit;False;185;MaskGlobal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;121;-3326,378.8063;Inherit;False;VERTEXCOLOR;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;123;5325.744,988.2266;Inherit;False;121;VERTEXCOLOR;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;164;5296.398,1378.397;Inherit;False;Property;_Keyword0;Keyword 0;21;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Reference;156;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;94;5149.404,610.1552;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;175;6683.346,1130.571;Inherit;False;Property;_DISSOLVE;DISSOLVE !;24;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;117;5534.426,600.3505;Inherit;False;Property;_Keyword0;Keyword 0;20;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Reference;116;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;11;5606.712,992.3207;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SamplerNode;174;6604.924,823.7335;Inherit;True;Property;_TX_Line_Dissolve;TX_Line_Dissolve;23;0;Create;True;0;0;False;0;-1;a312d72d446d4f744b9f65b184bbc68e;a312d72d446d4f744b9f65b184bbc68e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;177;6894.843,1135.856;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;5846.033,602.4012;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;176;7116.11,927.1131;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;130;4571.717,-219.2317;Inherit;False;1474.059;507.8991;Color;5;116;93;113;161;186;;0.7058824,0,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;169;4969.04,-571.3995;Inherit;False;887.918;202.308;DEBUG;3;156;162;119;;0.9963673,1,0,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;5064.26,12.77141;Inherit;False;185;MaskGlobal;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;4883.717,-148.2856;Inherit;False;111;Main_AlbedoEmissive;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;93;5268.249,-169.2317;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;159;4274.922,490.7707;Inherit;False;Secondary_AlbedoEmissive;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;161;4594.148,-171.1941;Inherit;False;159;Secondary_AlbedoEmissive;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;68;1667.985,11.23737;Inherit;False;Property;_Emissive_intensity;Emissive_intensity;19;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;135;-2886.546,364.909;Inherit;False;Property;__TimeScale;__TimeScale;22;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;1317.935,-1.387673;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;116;5904.303,-163.9041;Inherit;False;Property;_DEBUG;DEBUG?;20;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;8;314.2898,37.911;Inherit;False;Property;_MainTex_color;MainTex_color;0;0;Create;True;0;0;False;0;1,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;2284.641,-14.35423;Inherit;False;Main_AlbedoEmissive;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;6932.35,207.1176;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;104;525.7322,14.15229;Inherit;False;101;MainTex;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;122;1007.939,-8.443098;Inherit;False;121;VERTEXCOLOR;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;1997.777,-7.609417;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;6875.087,1267.634;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;180;7336.944,485.2544;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;7146.471,1227.18;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;178;7619.72,959.649;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;162;5235.181,-496.0928;Inherit;False;159;Secondary_AlbedoEmissive;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;5019.04,-518.5741;Inherit;False;111;Main_AlbedoEmissive;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;817.6577,19.54737;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;156;5617.958,-521.3995;Inherit;False;Property;_DEBUGFLUXORLINE;DEBUG FLUX OR LINE;21;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;64;1289.719,374.2267;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;62;2224.24,208.2742;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;65;1289.719,374.2267;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;66;1289.719,374.2267;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;63;6877.707,-163.4291;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;4;M_TrailDash;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;1;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;True;False;False;;0
WireConnection;146;0;147;0
WireConnection;106;0;6;0
WireConnection;2;0;144;0
WireConnection;21;0;2;0
WireConnection;21;1;22;0
WireConnection;23;0;21;0
WireConnection;23;1;108;0
WireConnection;19;0;23;0
WireConnection;19;1;20;0
WireConnection;24;0;19;0
WireConnection;140;7;4;0
WireConnection;140;8;36;0
WireConnection;140;11;149;0
WireConnection;25;0;107;0
WireConnection;25;1;24;0
WireConnection;25;2;26;0
WireConnection;5;0;140;0
WireConnection;5;1;25;0
WireConnection;141;7;69;0
WireConnection;141;8;70;0
WireConnection;141;10;75;0
WireConnection;141;13;75;0
WireConnection;141;11;150;0
WireConnection;1;1;5;0
WireConnection;101;0;1;0
WireConnection;14;1;141;0
WireConnection;100;0;14;4
WireConnection;143;7;89;0
WireConnection;143;8;83;0
WireConnection;143;10;171;0
WireConnection;143;13;154;0
WireConnection;143;11;148;0
WireConnection;103;0;102;0
WireConnection;142;7;82;0
WireConnection;142;8;76;0
WireConnection;142;10;77;0
WireConnection;142;13;77;0
WireConnection;142;11;151;0
WireConnection;90;1;143;0
WireConnection;95;1;142;0
WireConnection;73;0;103;3
WireConnection;73;1;99;0
WireConnection;112;0;73;0
WireConnection;185;0;95;4
WireConnection;160;0;90;4
WireConnection;121;0;10;0
WireConnection;164;1;166;0
WireConnection;164;0;165;0
WireConnection;94;0;158;0
WireConnection;94;1;114;0
WireConnection;94;2;187;0
WireConnection;117;1;94;0
WireConnection;117;0;164;0
WireConnection;11;0;123;0
WireConnection;177;0;175;0
WireConnection;12;0;117;0
WireConnection;12;1;11;3
WireConnection;176;0;174;4
WireConnection;176;1;177;0
WireConnection;93;0;161;0
WireConnection;93;1;113;0
WireConnection;93;2;186;0
WireConnection;159;0;90;0
WireConnection;13;0;122;0
WireConnection;13;1;7;0
WireConnection;116;1;93;0
WireConnection;116;0;156;0
WireConnection;111;0;67;0
WireConnection;181;0;12;0
WireConnection;181;1;176;0
WireConnection;67;0;13;0
WireConnection;67;1;68;0
WireConnection;184;0;175;0
WireConnection;180;0;12;0
WireConnection;180;1;176;0
WireConnection;182;0;177;0
WireConnection;178;0;176;0
WireConnection;7;0;104;0
WireConnection;7;1;8;0
WireConnection;156;1;119;0
WireConnection;156;0;162;0
WireConnection;63;2;116;0
WireConnection;63;3;181;0
ASEEND*/
//CHKSM=45D7DFEA9F80ADF987EC885626D091F462CE1FF7