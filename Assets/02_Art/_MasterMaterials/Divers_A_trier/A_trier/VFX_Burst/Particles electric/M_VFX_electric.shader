// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_VFX_electric"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		_1TX_base_texture1("1- TX_base_texture", 2D) = "white" {}
		_2L_DEFORMspeedXYnoiseScaleNoiseInt1("2- L_DEFORM - speed X/Y - noise Scale - Noise Int", Vector) = (1,2,2.75,0.15)
		_3TX_S_DEFORM1("3- TX_S_DEFORM", 2D) = "white" {}
		_3S_DEFORMspeedXYtilesXY1("3- S_DEFORM - speed X/Y - tiles X/Y", Vector) = (0.2,0.3,0.04,0.01)
		_3S_DEFORMmin1("3- S_DEFORM - min", Range( 0 , 1)) = 0.2
		_3S_DEFORMmax1("3- S_DEFORM - max", Range( 0 , 1)) = 0.4
		_4baseInttresholdintemissiveInt1("4- base Int - treshold int - emissive Int - ", Vector) = (10,5,5,0)
		_4colorbase1("4- color base", Color) = (0,0.5215687,1,0)
		_4coloremissive1("4- color emissive", Color) = (0.6352941,0.9411765,1,0)
		_4sharpness1("4- sharpness", Range( 0 , 5)) = 3
		_5Spherescale1("5- Sphere scale", Range( 0 , 5)) = 1
		_5Spheresharpness1("5- Sphere sharpness", Range( 0 , 25)) = 3.5

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
			#define _RECEIVE_SHADOWS_OFF 1
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

			sampler2D _1TX_base_texture1;
			sampler2D _3TX_S_DEFORM1;
			CBUFFER_START( UnityPerMaterial )
			float _5Spherescale1;
			float _5Spheresharpness1;
			float4 _2L_DEFORMspeedXYnoiseScaleNoiseInt1;
			float4 _3S_DEFORMspeedXYtilesXY1;
			float _3S_DEFORMmin1;
			float _3S_DEFORMmax1;
			float _4sharpness1;
			float4 _4baseInttresholdintemissiveInt1;
			float4 _4coloremissive1;
			float4 _4colorbase1;
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
				o.ase_texcoord4 = v.ase_texcoord1;
				
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
				float2 CenteredUV15_g39 = ( IN.ase_texcoord3.xy - float2( 0.5,0.5 ) );
				float2 break17_g39 = CenteredUV15_g39;
				float2 appendResult23_g39 = (float2(( length( CenteredUV15_g39 ) * (10.0 + (_5Spherescale1 - 0.0) * (1.0 - 10.0) / (1.0 - 0.0)) * 2.0 ) , ( atan2( break17_g39.x , break17_g39.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float BaseCIrcle18_g37 = ( saturate( ( 1.0 - appendResult23_g39.x ) ) * _5Spheresharpness1 );
				float2 appendResult8_g40 = (float2(_2L_DEFORMspeedXYnoiseScaleNoiseInt1.x , _2L_DEFORMspeedXYnoiseScaleNoiseInt1.y));
				float2 appendResult4_g41 = (float2(_3S_DEFORMspeedXYtilesXY1.x , _3S_DEFORMspeedXYtilesXY1.y));
				float2 uv054_g37 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_41_0_g40 = uv054_g37;
				float2 appendResult12_g41 = (float2(_3S_DEFORMspeedXYtilesXY1.z , _3S_DEFORMspeedXYtilesXY1.w));
				float2 panner6_g41 = ( _TimeParameters.x * appendResult4_g41 + ( temp_output_41_0_g40 * appendResult12_g41 ));
				float2 temp_cast_0 = (( tex2D( _3TX_S_DEFORM1, panner6_g41 ).r * (_3S_DEFORMmin1 + (sin( _TimeParameters.x ) - -1.0) * (_3S_DEFORMmax1 - _3S_DEFORMmin1) / (1.0 - -1.0)) )).xx;
				float2 uv013_g40 = IN.ase_texcoord3.xy * float2( 1,1 ) + temp_cast_0;
				float2 panner17_g40 = ( 1.0 * _Time.y * appendResult8_g40 + ( uv013_g40 * 0.5 ));
				float simplePerlin2D18_g40 = snoise( panner17_g40*( _2L_DEFORMspeedXYnoiseScaleNoiseInt1.z * IN.ase_texcoord4.w ) );
				simplePerlin2D18_g40 = simplePerlin2D18_g40*0.5 + 0.5;
				float2 break26_g40 = (float2( -1,-1 ) + (temp_output_41_0_g40 - float2( 0,0 )) * (float2( 1,1 ) - float2( -1,-1 )) / (float2( 1,1 ) - float2( 0,0 )));
				float2 appendResult21_g40 = (float2(( _TimeParameters.x * IN.ase_texcoord4.z ) , ( ( simplePerlin2D18_g40 * ( _2L_DEFORMspeedXYnoiseScaleNoiseInt1.w * IN.ase_texcoord4.w ) ) + ( ( atan2( break26_g40.x , break26_g40.y ) / TWO_PI ) + 0.5 ) )));
				float Lightenings60_g37 = saturate( tex2D( _1TX_base_texture1, appendResult21_g40 ).r );
				float LighteningsSharpness17_g37 = ( pow( Lightenings60_g37 , _4sharpness1 ) * IN.ase_texcoord4.x );
				float temp_output_20_0_g37 = ( BaseCIrcle18_g37 * LighteningsSharpness17_g37 );
				float3 temp_cast_1 = (saturate( temp_output_20_0_g37 )).xxx;
				float3 saferPower14_g42 = max( temp_cast_1 , 0.0001 );
				float3 temp_cast_2 = (_4baseInttresholdintemissiveInt1.y).xxx;
				float3 temp_output_14_0_g42 = pow( saferPower14_g42 , temp_cast_2 );
				float4 Color_Emissive11 = _4coloremissive1;
				float4 Color_Emissive28_g37 = Color_Emissive11;
				float4 Color_Base10 = _4colorbase1;
				float4 Color_Base31_g37 = Color_Base10;
				float4 Lighteningscolor37_g37 = ( ( float4( ( temp_output_14_0_g42 * ( _4baseInttresholdintemissiveInt1.z * IN.ase_texcoord4.y ) ) , 0.0 ) * Color_Emissive28_g37 ) + ( ( temp_output_20_0_g37 * Color_Base31_g37 ) * _4baseInttresholdintemissiveInt1.x ) );
				float4 Lighteningscolor29 = Lighteningscolor37_g37;
				
				float Lighteningsalpha36_g37 = saturate( temp_output_20_0_g37 );
				float Lighteningsalpha30 = Lighteningsalpha36_g37;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = Lighteningscolor29.rgb;
				float Alpha = Lighteningsalpha30;
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
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#define _RECEIVE_SHADOWS_OFF 1
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
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _1TX_base_texture1;
			sampler2D _3TX_S_DEFORM1;
			CBUFFER_START( UnityPerMaterial )
			float _5Spherescale1;
			float _5Spheresharpness1;
			float4 _2L_DEFORMspeedXYnoiseScaleNoiseInt1;
			float4 _3S_DEFORMspeedXYtilesXY1;
			float _3S_DEFORMmin1;
			float _3S_DEFORMmax1;
			float _4sharpness1;
			float4 _4baseInttresholdintemissiveInt1;
			float4 _4coloremissive1;
			float4 _4colorbase1;
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
				o.ase_texcoord3 = v.ase_texcoord1;
				
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

				float2 CenteredUV15_g39 = ( IN.ase_texcoord2.xy - float2( 0.5,0.5 ) );
				float2 break17_g39 = CenteredUV15_g39;
				float2 appendResult23_g39 = (float2(( length( CenteredUV15_g39 ) * (10.0 + (_5Spherescale1 - 0.0) * (1.0 - 10.0) / (1.0 - 0.0)) * 2.0 ) , ( atan2( break17_g39.x , break17_g39.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float BaseCIrcle18_g37 = ( saturate( ( 1.0 - appendResult23_g39.x ) ) * _5Spheresharpness1 );
				float2 appendResult8_g40 = (float2(_2L_DEFORMspeedXYnoiseScaleNoiseInt1.x , _2L_DEFORMspeedXYnoiseScaleNoiseInt1.y));
				float2 appendResult4_g41 = (float2(_3S_DEFORMspeedXYtilesXY1.x , _3S_DEFORMspeedXYtilesXY1.y));
				float2 uv054_g37 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_41_0_g40 = uv054_g37;
				float2 appendResult12_g41 = (float2(_3S_DEFORMspeedXYtilesXY1.z , _3S_DEFORMspeedXYtilesXY1.w));
				float2 panner6_g41 = ( _TimeParameters.x * appendResult4_g41 + ( temp_output_41_0_g40 * appendResult12_g41 ));
				float2 temp_cast_0 = (( tex2D( _3TX_S_DEFORM1, panner6_g41 ).r * (_3S_DEFORMmin1 + (sin( _TimeParameters.x ) - -1.0) * (_3S_DEFORMmax1 - _3S_DEFORMmin1) / (1.0 - -1.0)) )).xx;
				float2 uv013_g40 = IN.ase_texcoord2.xy * float2( 1,1 ) + temp_cast_0;
				float2 panner17_g40 = ( 1.0 * _Time.y * appendResult8_g40 + ( uv013_g40 * 0.5 ));
				float simplePerlin2D18_g40 = snoise( panner17_g40*( _2L_DEFORMspeedXYnoiseScaleNoiseInt1.z * IN.ase_texcoord3.w ) );
				simplePerlin2D18_g40 = simplePerlin2D18_g40*0.5 + 0.5;
				float2 break26_g40 = (float2( -1,-1 ) + (temp_output_41_0_g40 - float2( 0,0 )) * (float2( 1,1 ) - float2( -1,-1 )) / (float2( 1,1 ) - float2( 0,0 )));
				float2 appendResult21_g40 = (float2(( _TimeParameters.x * IN.ase_texcoord3.z ) , ( ( simplePerlin2D18_g40 * ( _2L_DEFORMspeedXYnoiseScaleNoiseInt1.w * IN.ase_texcoord3.w ) ) + ( ( atan2( break26_g40.x , break26_g40.y ) / TWO_PI ) + 0.5 ) )));
				float Lightenings60_g37 = saturate( tex2D( _1TX_base_texture1, appendResult21_g40 ).r );
				float LighteningsSharpness17_g37 = ( pow( Lightenings60_g37 , _4sharpness1 ) * IN.ase_texcoord3.x );
				float temp_output_20_0_g37 = ( BaseCIrcle18_g37 * LighteningsSharpness17_g37 );
				float Lighteningsalpha36_g37 = saturate( temp_output_20_0_g37 );
				float Lighteningsalpha30 = Lighteningsalpha36_g37;
				
				float Alpha = Lighteningsalpha30;
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
-1280;84;1280;659;3757.656;72.26859;1.658016;True;False
Node;AmplifyShaderEditor.CommentaryNode;7;-3417.209,-757.1212;Inherit;False;510.6692;516.6895;;4;11;10;9;8;VAR -  color;1,0.5019608,0.9176471,1;0;0
Node;AmplifyShaderEditor.ColorNode;8;-3362.592,-707.1212;Inherit;False;Property;_4colorbase1;4- color base;27;0;Create;True;0;0;False;0;0,0.5215687,1,0;0,0.5215685,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;9;-3367.209,-452.4317;Inherit;False;Property;_4coloremissive1;4- color emissive;28;0;Create;True;0;0;False;0;0.6352941,0.9411765,1,0;0.635294,0.9411765,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;12;-3410.534,8.978546;Inherit;False;2930.84;654.5895;;13;26;25;24;23;22;21;20;18;17;15;14;13;33;Lightenings;1,0.5019608,0.9176471,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-3121.541,-449.8779;Inherit;False;Color_Emissive;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;-3120.422,-703.7706;Inherit;False;Color_Base;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector4Node;21;-3101.169,132.0942;Inherit;False;Property;_2L_DEFORMspeedXYnoiseScaleNoiseInt1;2- L_DEFORM - speed X/Y - noise Scale - Noise Int;21;0;Create;True;0;0;False;0;1,2,2.75,0.15;1,2,2.75,0.15;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;13;-936.5717,406.7996;Inherit;False;Property;_4baseInttresholdintemissiveInt1;4- base Int - treshold int - emissive Int - ;26;0;Create;True;0;0;False;0;10,5,5,0;10,5,5,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;5;-2500.938,747.093;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-2513.023,548.4854;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-165.985,545.5372;Inherit;False;Property;_5Spherescale1;5- Sphere scale;30;0;Create;True;0;0;False;0;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1187.943,529.1215;Inherit;False;Property;_4sharpness1;4- sharpness;29;0;Create;True;0;0;False;0;3;3;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-2747.412,656.8016;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-505.556,797.3151;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;24;-3390.333,235.5676;Inherit;False;Property;_3S_DEFORMspeedXYtilesXY1;3- S_DEFORM - speed X/Y - tiles X/Y;23;0;Create;True;0;0;False;0;0.2,0.3,0.04,0.01;0.2,0.3,0.04,0.01;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;15;-1416.732,416.8792;Inherit;False;10;Color_Base;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-449.537,569.744;Inherit;False;Property;_5Spheresharpness1;5- Sphere sharpness;31;0;Create;True;0;0;False;0;3.5;3;0;25;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-1242.431,450.2554;Inherit;False;11;Color_Emissive;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;23;-2326.997,236.7122;Inherit;True;Property;_3TX_S_DEFORM1;3- TX_S_DEFORM;22;0;Create;True;0;0;True;0;None;bdbe94d7623ec3940947b62544306f1c;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;25;-2534.823,109.0232;Inherit;True;Property;_1TX_base_texture1;1- TX_base_texture;19;0;Create;True;0;0;True;0;None;b895ecea225dd4540a48d6293e2070ee;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-2649.774,352.8953;Inherit;False;Property;_3S_DEFORMmin1;3- S_DEFORM - min;24;0;Create;True;0;0;False;0;0.2;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-2936.279,376.4655;Inherit;False;Property;_3S_DEFORMmax1;3- S_DEFORM - max;25;0;Create;True;0;0;False;0;0.4;0.4;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;27;176.5165,71.23193;Inherit;False;MF_Lightenings_and_circle;0;;37;ab5f87db33f8fd5409ed675ac42e9451;0;23;68;FLOAT2;0,0;False;74;FLOAT;0.5;False;42;FLOAT;0.5;False;73;SAMPLER2D;0;False;69;FLOAT;1;False;70;FLOAT;2;False;71;FLOAT;2.75;False;72;FLOAT;0.15;False;65;SAMPLER2D;0;False;64;FLOAT;0.2;False;61;FLOAT;0.3;False;62;FLOAT;0.04;False;63;FLOAT;0.01;False;66;FLOAT;0.2;False;67;FLOAT;0.4;False;47;COLOR;0,0.5215687,1,0;False;43;FLOAT;10;False;46;COLOR;0.6352941,0.9411765,1,0;False;44;FLOAT;5;False;45;FLOAT;5;False;41;FLOAT;3;False;48;FLOAT;1;False;49;FLOAT;3.5;False;3;FLOAT;39;COLOR;38;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;796.51,117.5762;Inherit;False;Lighteningsalpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2114.719,81.95935;Inherit;False;Property;_1GlobalSpeed1;1- Global Speed;18;0;Create;True;0;0;False;0;0.5;0.5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1400.969,94.81085;Inherit;False;Property;_1Lighteningopacity1;1- Lightening opacity;20;0;Create;True;0;0;False;0;0.5;0.5;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;1162.314,89.88733;Inherit;False;Lighteningscolor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;915.7994,61.68015;Inherit;False;BaseCIrcle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;1048.418,937.0065;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;1642.945,96.7613;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;M_VFX_electric;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;False;True;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;11;0;9;0
WireConnection;10;0;8;0
WireConnection;33;0;21;3
WireConnection;33;1;5;4
WireConnection;34;0;21;4
WireConnection;34;1;5;4
WireConnection;32;0;13;3
WireConnection;32;1;5;2
WireConnection;27;74;5;3
WireConnection;27;42;5;1
WireConnection;27;73;25;0
WireConnection;27;69;21;1
WireConnection;27;70;21;2
WireConnection;27;71;33;0
WireConnection;27;72;34;0
WireConnection;27;65;23;0
WireConnection;27;64;24;1
WireConnection;27;61;24;2
WireConnection;27;62;24;3
WireConnection;27;63;24;4
WireConnection;27;66;22;0
WireConnection;27;67;17;0
WireConnection;27;47;15;0
WireConnection;27;43;13;1
WireConnection;27;46;20;0
WireConnection;27;44;13;2
WireConnection;27;45;32;0
WireConnection;27;41;14;0
WireConnection;27;48;16;0
WireConnection;27;49;19;0
WireConnection;30;0;27;0
WireConnection;29;0;27;38
WireConnection;28;0;27;39
WireConnection;31;0;30;0
WireConnection;31;1;5;1
WireConnection;1;2;29;0
WireConnection;1;3;30;0
ASEEND*/
//CHKSM=B54FE17EC48DCE9AD62D7546489EA83C756D993D