// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_Flares"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_TX_Flares_RGB("TX_Flares_RGB", 2D) = "white" {}
		_base_Color("base_Color", Color) = (0.4103774,0.7254236,1,0)
		_base_Intensity("base_Intensity", Float) = 0
		_emissive_Color("emissive_Color", Color) = (0,1,0.9472467,0)
		_emissive_Intensity("emissive_Intensity", Range( 0 , 25)) = 2
		_DISSOLVE("DISSOLVE!", Range( 0 , 1)) = 0
		_dissolve_01("dissolve_01", 2D) = "white" {}
		_dissolve01_Tile_XY("dissolve01_Tile_XY", Range( 0 , 50)) = 1.5
		_dissolve01_Speed_X("dissolve01_Speed_X", Range( -5 , 5)) = 0
		_dissolve01_Speed_Y("dissolve01_Speed_Y", Range( -5 , 5)) = -2
		_dissolve_02("dissolve_02", 2D) = "white" {}
		_dissolve02_Tile_X("dissolve02_Tile_X", Range( 0 , 50)) = 1.5
		_dissolve02_Tile_Y("dissolve02_Tile_Y", Range( 0 , 5)) = 0.5
		_dissolve02_Speed_X("dissolve02_Speed_X", Range( -5 , 5)) = 0.075
		_dissolve02_Speed_Y("dissolve02_Speed_Y", Range( -5 , 5)) = -1
		_ItemPickUp_alpha("ItemPickUp_alpha", 2D) = "white" {}
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

			sampler2D _dissolve_01;
			sampler2D _dissolve_02;
			sampler2D _TX_Flares_RGB;
			sampler2D _ItemPickUp_alpha;
			CBUFFER_START( UnityPerMaterial )
			float _dissolve01_Speed_X;
			float _dissolve01_Speed_Y;
			float _dissolve01_Tile_XY;
			float _DISSOLVE;
			float _dissolve02_Speed_X;
			float _dissolve02_Speed_Y;
			float _dissolve02_Tile_X;
			float _dissolve02_Tile_Y;
			float4 _emissive_Color;
			float _emissive_Intensity;
			float4 _base_Color;
			float4 _TX_Flares_RGB_ST;
			float _base_Intensity;
			float4 _ItemPickUp_alpha_ST;
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
				float2 uv038 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 UV62 = uv038;
				float2 appendResult4_g8 = (float2(_dissolve01_Speed_X , _dissolve01_Speed_Y));
				float2 appendResult12_g8 = (float2(1.0 , 1.0));
				float2 panner6_g8 = ( _TimeParameters.x * appendResult4_g8 + ( UV62 * appendResult12_g8 ));
				float simplePerlin2D36 = snoise( panner6_g8*_dissolve01_Tile_XY );
				simplePerlin2D36 = simplePerlin2D36*0.5 + 0.5;
				float2 temp_cast_0 = (simplePerlin2D36).xx;
				float lerpResult83 = lerp( 1.0 , 0.0 , _DISSOLVE);
				float Dissolve_0_156 = lerpResult83;
				float2 lerpResult39 = lerp( UV62 , temp_cast_0 , Dissolve_0_156);
				float2 appendResult4_g9 = (float2(_dissolve02_Speed_X , _dissolve02_Speed_Y));
				float2 appendResult12_g9 = (float2(_dissolve02_Tile_X , _dissolve02_Tile_Y));
				float2 panner6_g9 = ( _TimeParameters.x * appendResult4_g9 + ( UV62 * appendResult12_g9 ));
				float4 tex2DNode24 = tex2D( _dissolve_02, panner6_g9 );
				float4 saferPower44 = max( tex2DNode24 , 0.0001 );
				float lerpResult46 = lerp( 0.0 , 0.75 , Dissolve_0_156);
				float temp_output_49_0 = saturate( ( Dissolve_0_156 + lerpResult46 ) );
				float lerpResult53 = lerp( 1.0 , 0.0 , temp_output_49_0);
				float4 lerpResult23 = lerp( tex2D( _dissolve_01, lerpResult39 ) , ( ( pow( saferPower44 , 1.5 ) * lerpResult53 ) + tex2DNode24 ) , temp_output_49_0);
				float4 Dissolvetexturefinal74 = lerpResult23;
				float3 temp_output_11_0_g11 = Dissolvetexturefinal74.rgb;
				float temp_output_12_0_g11 = 1.0;
				float3 temp_cast_2 = (temp_output_12_0_g11).xxx;
				float3 temp_output_14_0_g11 = pow( temp_output_11_0_g11 , temp_cast_2 );
				float mulTime79 = _TimeParameters.x * 50.0;
				float2 uv_TX_Flares_RGB = IN.ase_texcoord3.xy * _TX_Flares_RGB_ST.xy + _TX_Flares_RGB_ST.zw;
				
				float Dissolve_0_2054 = (0.0 + (lerpResult83 - 0.0) * (20.0 - 0.0) / (1.0 - 0.0));
				float4 temp_cast_5 = (Dissolve_0_2054).xxxx;
				float4 lerpResult5_g10 = lerp( saturate( pow( Dissolvetexturefinal74 , temp_cast_5 ) ) , float4( 0,0,0,0 ) , 0.0);
				float2 uv_ItemPickUp_alpha = IN.ase_texcoord3.xy * _ItemPickUp_alpha_ST.xy + _ItemPickUp_alpha_ST.zw;
				float4 lerpResult18 = lerp( saturate( ( lerpResult5_g10 * tex2D( _ItemPickUp_alpha, uv_ItemPickUp_alpha ) ) ) , float4( 0,0,0,0 ) , Dissolve_0_156);
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( ( float4( temp_output_14_0_g11 , 0.0 ) * _emissive_Color ) * ( _emissive_Intensity + sin( mulTime79 ) ) ) + ( ( _base_Color * tex2D( _TX_Flares_RGB, uv_TX_Flares_RGB ).r ) * _base_Intensity ) ).rgb;
				float Alpha = saturate( lerpResult18 ).r;
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

			sampler2D _dissolve_01;
			sampler2D _dissolve_02;
			sampler2D _ItemPickUp_alpha;
			CBUFFER_START( UnityPerMaterial )
			float _dissolve01_Speed_X;
			float _dissolve01_Speed_Y;
			float _dissolve01_Tile_XY;
			float _DISSOLVE;
			float _dissolve02_Speed_X;
			float _dissolve02_Speed_Y;
			float _dissolve02_Tile_X;
			float _dissolve02_Tile_Y;
			float4 _emissive_Color;
			float _emissive_Intensity;
			float4 _base_Color;
			float4 _TX_Flares_RGB_ST;
			float _base_Intensity;
			float4 _ItemPickUp_alpha_ST;
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

				float2 uv038 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 UV62 = uv038;
				float2 appendResult4_g8 = (float2(_dissolve01_Speed_X , _dissolve01_Speed_Y));
				float2 appendResult12_g8 = (float2(1.0 , 1.0));
				float2 panner6_g8 = ( _TimeParameters.x * appendResult4_g8 + ( UV62 * appendResult12_g8 ));
				float simplePerlin2D36 = snoise( panner6_g8*_dissolve01_Tile_XY );
				simplePerlin2D36 = simplePerlin2D36*0.5 + 0.5;
				float2 temp_cast_0 = (simplePerlin2D36).xx;
				float lerpResult83 = lerp( 1.0 , 0.0 , _DISSOLVE);
				float Dissolve_0_156 = lerpResult83;
				float2 lerpResult39 = lerp( UV62 , temp_cast_0 , Dissolve_0_156);
				float2 appendResult4_g9 = (float2(_dissolve02_Speed_X , _dissolve02_Speed_Y));
				float2 appendResult12_g9 = (float2(_dissolve02_Tile_X , _dissolve02_Tile_Y));
				float2 panner6_g9 = ( _TimeParameters.x * appendResult4_g9 + ( UV62 * appendResult12_g9 ));
				float4 tex2DNode24 = tex2D( _dissolve_02, panner6_g9 );
				float4 saferPower44 = max( tex2DNode24 , 0.0001 );
				float lerpResult46 = lerp( 0.0 , 0.75 , Dissolve_0_156);
				float temp_output_49_0 = saturate( ( Dissolve_0_156 + lerpResult46 ) );
				float lerpResult53 = lerp( 1.0 , 0.0 , temp_output_49_0);
				float4 lerpResult23 = lerp( tex2D( _dissolve_01, lerpResult39 ) , ( ( pow( saferPower44 , 1.5 ) * lerpResult53 ) + tex2DNode24 ) , temp_output_49_0);
				float4 Dissolvetexturefinal74 = lerpResult23;
				float Dissolve_0_2054 = (0.0 + (lerpResult83 - 0.0) * (20.0 - 0.0) / (1.0 - 0.0));
				float4 temp_cast_1 = (Dissolve_0_2054).xxxx;
				float4 lerpResult5_g10 = lerp( saturate( pow( Dissolvetexturefinal74 , temp_cast_1 ) ) , float4( 0,0,0,0 ) , 0.0);
				float2 uv_ItemPickUp_alpha = IN.ase_texcoord2.xy * _ItemPickUp_alpha_ST.xy + _ItemPickUp_alpha_ST.zw;
				float4 lerpResult18 = lerp( saturate( ( lerpResult5_g10 * tex2D( _ItemPickUp_alpha, uv_ItemPickUp_alpha ) ) ) , float4( 0,0,0,0 ) , Dissolve_0_156);
				
				float Alpha = saturate( lerpResult18 ).r;
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

			sampler2D _dissolve_01;
			sampler2D _dissolve_02;
			sampler2D _ItemPickUp_alpha;
			CBUFFER_START( UnityPerMaterial )
			float _dissolve01_Speed_X;
			float _dissolve01_Speed_Y;
			float _dissolve01_Tile_XY;
			float _DISSOLVE;
			float _dissolve02_Speed_X;
			float _dissolve02_Speed_Y;
			float _dissolve02_Tile_X;
			float _dissolve02_Tile_Y;
			float4 _emissive_Color;
			float _emissive_Intensity;
			float4 _base_Color;
			float4 _TX_Flares_RGB_ST;
			float _base_Intensity;
			float4 _ItemPickUp_alpha_ST;
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

				float2 uv038 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 UV62 = uv038;
				float2 appendResult4_g8 = (float2(_dissolve01_Speed_X , _dissolve01_Speed_Y));
				float2 appendResult12_g8 = (float2(1.0 , 1.0));
				float2 panner6_g8 = ( _TimeParameters.x * appendResult4_g8 + ( UV62 * appendResult12_g8 ));
				float simplePerlin2D36 = snoise( panner6_g8*_dissolve01_Tile_XY );
				simplePerlin2D36 = simplePerlin2D36*0.5 + 0.5;
				float2 temp_cast_0 = (simplePerlin2D36).xx;
				float lerpResult83 = lerp( 1.0 , 0.0 , _DISSOLVE);
				float Dissolve_0_156 = lerpResult83;
				float2 lerpResult39 = lerp( UV62 , temp_cast_0 , Dissolve_0_156);
				float2 appendResult4_g9 = (float2(_dissolve02_Speed_X , _dissolve02_Speed_Y));
				float2 appendResult12_g9 = (float2(_dissolve02_Tile_X , _dissolve02_Tile_Y));
				float2 panner6_g9 = ( _TimeParameters.x * appendResult4_g9 + ( UV62 * appendResult12_g9 ));
				float4 tex2DNode24 = tex2D( _dissolve_02, panner6_g9 );
				float4 saferPower44 = max( tex2DNode24 , 0.0001 );
				float lerpResult46 = lerp( 0.0 , 0.75 , Dissolve_0_156);
				float temp_output_49_0 = saturate( ( Dissolve_0_156 + lerpResult46 ) );
				float lerpResult53 = lerp( 1.0 , 0.0 , temp_output_49_0);
				float4 lerpResult23 = lerp( tex2D( _dissolve_01, lerpResult39 ) , ( ( pow( saferPower44 , 1.5 ) * lerpResult53 ) + tex2DNode24 ) , temp_output_49_0);
				float4 Dissolvetexturefinal74 = lerpResult23;
				float Dissolve_0_2054 = (0.0 + (lerpResult83 - 0.0) * (20.0 - 0.0) / (1.0 - 0.0));
				float4 temp_cast_1 = (Dissolve_0_2054).xxxx;
				float4 lerpResult5_g10 = lerp( saturate( pow( Dissolvetexturefinal74 , temp_cast_1 ) ) , float4( 0,0,0,0 ) , 0.0);
				float2 uv_ItemPickUp_alpha = IN.ase_texcoord2.xy * _ItemPickUp_alpha_ST.xy + _ItemPickUp_alpha_ST.zw;
				float4 lerpResult18 = lerp( saturate( ( lerpResult5_g10 * tex2D( _ItemPickUp_alpha, uv_ItemPickUp_alpha ) ) ) , float4( 0,0,0,0 ) , Dissolve_0_156);
				
				float Alpha = saturate( lerpResult18 ).r;
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
-1280;84;1280;659;6444.529;-693.0464;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;73;-6023.097,717.469;Inherit;False;926.0527;544.2408;;7;62;38;57;56;54;58;83;VAR;0,1,0,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-6229.097,1186.01;Inherit;False;Property;_DISSOLVE;DISSOLVE!;5;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;83;-5877.529,1147.046;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;38;-5675.334,774.1913;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;68;-4739.121,196.2504;Inherit;False;3247.105;662.7603;;18;27;31;30;32;28;24;63;66;17;43;42;41;39;37;65;61;64;36;DISSOLVE BLEND;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-5342.536,767.469;Inherit;False;UV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;-5321.044,1145.71;Inherit;False;Dissolve_0_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-4177.526,395.5653;Inherit;False;Property;_dissolve01_Speed_Y;dissolve01_Speed_Y;9;0;Create;True;0;0;False;0;-2;0;-5;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-3989.072,365.1198;Inherit;False;Property;_dissolve01_Speed_X;dissolve01_Speed_X;8;0;Create;True;0;0;False;0;0;0;-5;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-3728.587,313.9041;Inherit;False;62;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-2631.52,1418.017;Inherit;False;56;Dissolve_0_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;46;-2412.228,1311.099;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.75;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-4689.121,388.9528;Inherit;False;Property;_dissolve01_Tile_XY;dissolve01_Tile_XY;7;0;Create;True;0;0;False;0;1.5;0.025;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-2950.284,642.931;Inherit;False;Property;_dissolve02_Speed_X;dissolve02_Speed_X;13;0;Create;True;0;0;False;0;0.075;0;-5;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;41;-3496.683,346.7117;Inherit;False;MF_Tiles;-1;;8;2fa329d2d99691549897442d611b24f3;0;6;14;FLOAT2;0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;10;FLOAT;1;False;13;FLOAT;1;False;11;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;-3107.369,612.8846;Inherit;False;62;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2659.857,694.0112;Inherit;False;Property;_dissolve02_Tile_X;dissolve02_Tile_X;11;0;Create;True;0;0;False;0;1.5;0;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-2810.692,669.0558;Inherit;False;Property;_dissolve02_Speed_Y;dissolve02_Speed_Y;14;0;Create;True;0;0;False;0;-1;0;-5;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-2960.745,719.2931;Inherit;False;Property;_dissolve02_Tile_Y;dissolve02_Tile_Y;12;0;Create;True;0;0;False;0;0.5;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-3001.134,246.2504;Inherit;False;62;UV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;28;-2383.309,628.0107;Inherit;False;MF_Tiles;-1;;9;2fa329d2d99691549897442d611b24f3;0;6;14;FLOAT2;0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;10;FLOAT;1;False;13;FLOAT;1;False;11;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;-3009.656,451.5432;Inherit;False;56;Dissolve_0_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;-2184.598,1420.323;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;36;-3012.791,337.8179;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;39;-2695.174,316.0466;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-1505.552,1363.061;Inherit;False;Constant;_dissolve_Power;dissolve_Power;17;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;24;-1947.662,598.1335;Inherit;True;Property;_dissolve_02;dissolve_02;10;0;Create;True;0;0;False;0;-1;258584cdd0599e945b812bba93200625;258584cdd0599e945b812bba93200625;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;49;-1987.456,1419.923;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;44;-1295.778,608.6064;Inherit;False;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;1.5;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;53;-1114.222,1369.428;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;66;-1574.016,499.2063;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;17;-1949.779,283.8032;Inherit;True;Property;_dissolve_01;dissolve_01;6;0;Create;True;0;0;False;0;-1;258584cdd0599e945b812bba93200625;258584cdd0599e945b812bba93200625;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;70;-780.5352,319.6878;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-892.8276,607.6501;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;67;-1486.396,499.2063;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-778.2042,442.1959;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;69;-638.8062,324.1167;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;58;-5569.934,974.9769;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;23;-482.2789,417.5909;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-5321.657,1017.781;Inherit;False;Dissolve_0_20;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;74;-297.7124,413.1512;Inherit;False;Dissolvetexturefinal;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;72;136.809,394.1416;Inherit;False;1260.908;757.1832;Comment;7;59;60;18;21;10;22;76;ALPHA HANDLER;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;22;186.809,921.3248;Inherit;True;Property;_ItemPickUp_alpha;ItemPickUp_alpha;15;0;Create;True;0;0;False;0;-1;a4c19ef38916bf440a0b2059b064d5b4;a4c19ef38916bf440a0b2059b064d5b4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;76;169.8272,488.1831;Inherit;False;74;Dissolvetexturefinal;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;59;204.2949,615.281;Inherit;False;54;Dissolve_0_20;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;742.5989,621.3488;Inherit;False;56;Dissolve_0_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;10;504.2792,444.1416;Inherit;False;MF_Alpha_handler;-1;;10;9ba53a059d6724547ba534bf0c40c79e;0;4;6;FLOAT;0;False;7;FLOAT;0;False;8;COLOR;0,0,0,0;False;13;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;18;977.4888,447.1663;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;71;-1416.948,-501.4711;Inherit;False;2754.583;411.0167;;11;14;8;12;9;6;15;16;13;5;7;75;EMISSIVE HANDLER;1,1,0,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;79;-958.4138,-716.9011;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;78;-706.0288,-715.5656;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;629.6123,-314.7149;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-904.6179,-406.9566;Inherit;False;Property;_emissive_Intensity;emissive_Intensity;4;0;Create;True;0;0;False;0;2;0;0;25;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;410.2777,-399.1614;Inherit;False;Property;_base_Intensity;base_Intensity;2;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;21;1232.717,450.7735;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-561.8356,-384.0911;Inherit;False;Constant;_tresh;tresh;4;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;7;-1366.948,-429.0348;Inherit;False;Property;_emissive_Color;emissive_Color;3;0;Create;True;0;0;False;0;0,1,0.9472467,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;13;129.9749,-322.0987;Inherit;False;Property;_base_Color;base_Color;1;0;Create;True;0;0;False;0;0.4103774,0.7254236,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;6;-321.4195,-451.4711;Inherit;False;MF_Emissive_handler;-1;;11;4c2d144224f39b24a93af8da62996f6d;0;4;11;FLOAT3;0,0,0;False;9;COLOR;0,0,0,0;False;10;FLOAT;0;False;12;FLOAT;50;False;2;COLOR;0;FLOAT3;13
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;805.6993,-420.4781;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;-563.8599,-195.5222;Inherit;False;74;Dissolvetexturefinal;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-1150.682,-715.5657;Inherit;False;Constant;_Float0;Float 0;16;0;Create;True;0;0;False;0;50;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;1185.635,-444.3339;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;5;-919.9536,-320.4544;Inherit;True;Property;_TX_Flares_RGB;TX_Flares_RGB;0;0;Create;True;0;0;False;0;-1;5ffa095bc2ec03248b2a8f444b9eb7f3;5ffa095bc2ec03248b2a8f444b9eb7f3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-503.0528,-647.4619;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;1543.01,-59.37516;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;M_Flares;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;1;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;True;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;608.5291,-18.89842;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;83;2;57;0
WireConnection;62;0;38;0
WireConnection;56;0;83;0
WireConnection;46;2;55;0
WireConnection;41;14;65;0
WireConnection;41;7;42;0
WireConnection;41;8;43;0
WireConnection;28;14;63;0
WireConnection;28;7;31;0
WireConnection;28;8;32;0
WireConnection;28;10;30;0
WireConnection;28;13;27;0
WireConnection;47;0;55;0
WireConnection;47;1;46;0
WireConnection;36;0;41;0
WireConnection;36;1;37;0
WireConnection;39;0;64;0
WireConnection;39;1;36;0
WireConnection;39;2;61;0
WireConnection;24;1;28;0
WireConnection;49;0;47;0
WireConnection;44;0;24;0
WireConnection;53;0;45;0
WireConnection;53;2;49;0
WireConnection;66;0;24;0
WireConnection;17;1;39;0
WireConnection;70;0;17;0
WireConnection;50;0;44;0
WireConnection;50;1;53;0
WireConnection;67;0;66;0
WireConnection;52;0;50;0
WireConnection;52;1;67;0
WireConnection;69;0;70;0
WireConnection;58;0;83;0
WireConnection;23;0;69;0
WireConnection;23;1;52;0
WireConnection;23;2;49;0
WireConnection;54;0;58;0
WireConnection;74;0;23;0
WireConnection;10;7;59;0
WireConnection;10;8;76;0
WireConnection;10;13;22;0
WireConnection;18;0;10;0
WireConnection;18;2;60;0
WireConnection;79;0;80;0
WireConnection;78;0;79;0
WireConnection;14;0;13;0
WireConnection;14;1;5;1
WireConnection;21;0;18;0
WireConnection;6;11;75;0
WireConnection;6;9;7;0
WireConnection;6;10;77;0
WireConnection;6;12;9;0
WireConnection;15;0;14;0
WireConnection;15;1;16;0
WireConnection;12;0;6;0
WireConnection;12;1;15;0
WireConnection;77;0;8;0
WireConnection;77;1;78;0
WireConnection;1;2;12;0
WireConnection;1;3;21;0
ASEEND*/
//CHKSM=BAC06C785D9FB0A7513BB7F714140D130BA96D49