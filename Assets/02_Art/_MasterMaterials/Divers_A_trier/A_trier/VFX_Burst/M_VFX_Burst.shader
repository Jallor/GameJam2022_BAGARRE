// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_VFX_Burst"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_1GlobalSpeed("1- Global Speed", Range( 0 , 5)) = 0.5
		_1TX_base_texture("1- TX_base_texture", 2D) = "white" {}
		_1Lighteningopacity("1- Lightening opacity", Range( 0 , 0.5)) = 0.5
		_2L_DEFORMspeedXYnoiseScaleNoiseInt("2- L_DEFORM - speed X/Y - noise Scale - Noise Int", Vector) = (1,2,2.75,0.15)
		_3TX_S_DEFORM("3- TX_S_DEFORM", 2D) = "white" {}
		_3S_DEFORMspeedXYtilesXY("3- S_DEFORM - speed X/Y - tiles X/Y", Vector) = (0.2,0.3,0.04,0.01)
		_3S_DEFORMmin("3- S_DEFORM - min", Range( 0 , 1)) = 0.2
		_3S_DEFORMmax("3- S_DEFORM - max", Range( 0 , 1)) = 0.4
		_4baseInttresholdintemissiveInt("4- base Int - treshold int - emissive Int - ", Vector) = (10,5,5,0)
		_4colorbase("4- color base", Color) = (0,0.5215687,1,0)
		_4coloremissive("4- color emissive", Color) = (0.6352941,0.9411765,1,0)
		_4sharpness("4- sharpness", Range( 0 , 5)) = 3
		_5Spherescale("5- Sphere scale", Range( 0 , 5)) = 1
		_5Spheresharpness("5- Sphere sharpness", Range( 0 , 25)) = 3.5
		_5Sphere_emissive_Int("5- Sphere_emissive_Int", Range( 0 , 10)) = 1
		_5Sphere_opacity("5- Sphere_opacity", Range( 0 , 1)) = 1

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
			#define _RECEIVE_SHADOWS_OFF 1
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

			sampler2D _1TX_base_texture;
			sampler2D _3TX_S_DEFORM;
			CBUFFER_START( UnityPerMaterial )
			float4 _4coloremissive;
			float _5Spherescale;
			float _5Spheresharpness;
			float _5Sphere_opacity;
			float _5Sphere_emissive_Int;
			float4 _4colorbase;
			float _1GlobalSpeed;
			float4 _2L_DEFORMspeedXYnoiseScaleNoiseInt;
			float4 _3S_DEFORMspeedXYtilesXY;
			float _3S_DEFORMmin;
			float _3S_DEFORMmax;
			float _4sharpness;
			float _1Lighteningopacity;
			float4 _4baseInttresholdintemissiveInt;
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
				float4 Color_Emissive188 = _4coloremissive;
				float2 CenteredUV15_g39 = ( IN.ase_texcoord3.xy - float2( 0.5,0.5 ) );
				float2 break17_g39 = CenteredUV15_g39;
				float2 appendResult23_g39 = (float2(( length( CenteredUV15_g39 ) * (10.0 + (_5Spherescale - 0.0) * (1.0 - 10.0) / (1.0 - 0.0)) * 2.0 ) , ( atan2( break17_g39.x , break17_g39.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float BaseCIrcle18_g37 = ( saturate( ( 1.0 - appendResult23_g39.x ) ) * _5Spheresharpness );
				float BaseCIrcle156 = BaseCIrcle18_g37;
				float4 temp_cast_0 = (BaseCIrcle156).xxxx;
				float4 temp_cast_1 = (0.85).xxxx;
				float4 temp_cast_2 = (1.355).xxxx;
				float4 temp_output_6_0_g43 = pow( saturate( ( pow( temp_cast_0 , temp_cast_1 ) / 0.35 ) ) , temp_cast_2 );
				float4 break14_g43 = temp_output_6_0_g43;
				float temp_output_196_0 = ( ( break14_g43.r * (1.0 + (BaseCIrcle156 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) * _5Sphere_opacity );
				float3 saferPower14_g44 = max( ( Color_Emissive188 + temp_output_196_0 ).rgb , 0.0001 );
				float3 temp_cast_4 = (5.0).xxx;
				float3 temp_output_14_0_g44 = pow( saferPower14_g44 , temp_cast_4 );
				float4 Color_Base189 = _4colorbase;
				float mulTime172 = _TimeParameters.x * 50.0;
				float mulTime182 = _TimeParameters.x * 10.0;
				float4 CircleColor183 = ( ( float4( ( temp_output_14_0_g44 * _5Sphere_emissive_Int ) , 0.0 ) * Color_Base189 ) * (_5Sphere_emissive_Int + (( sin( mulTime172 ) * cos( mulTime182 ) ) - -1.0) * (( _5Sphere_emissive_Int * 5.0 ) - _5Sphere_emissive_Int) / (1.0 - -1.0)) );
				float2 appendResult8_g40 = (float2(_2L_DEFORMspeedXYnoiseScaleNoiseInt.x , _2L_DEFORMspeedXYnoiseScaleNoiseInt.y));
				float2 appendResult4_g41 = (float2(_3S_DEFORMspeedXYtilesXY.x , _3S_DEFORMspeedXYtilesXY.y));
				float2 uv054_g37 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_41_0_g40 = uv054_g37;
				float2 appendResult12_g41 = (float2(_3S_DEFORMspeedXYtilesXY.z , _3S_DEFORMspeedXYtilesXY.w));
				float2 panner6_g41 = ( _TimeParameters.x * appendResult4_g41 + ( temp_output_41_0_g40 * appendResult12_g41 ));
				float2 temp_cast_6 = (( tex2D( _3TX_S_DEFORM, panner6_g41 ).r * (_3S_DEFORMmin + (sin( _TimeParameters.x ) - -1.0) * (_3S_DEFORMmax - _3S_DEFORMmin) / (1.0 - -1.0)) )).xx;
				float2 uv013_g40 = IN.ase_texcoord3.xy * float2( 1,1 ) + temp_cast_6;
				float2 panner17_g40 = ( 1.0 * _Time.y * appendResult8_g40 + ( uv013_g40 * 0.5 ));
				float simplePerlin2D18_g40 = snoise( panner17_g40*_2L_DEFORMspeedXYnoiseScaleNoiseInt.z );
				simplePerlin2D18_g40 = simplePerlin2D18_g40*0.5 + 0.5;
				float2 break26_g40 = (float2( -1,-1 ) + (temp_output_41_0_g40 - float2( 0,0 )) * (float2( 1,1 ) - float2( -1,-1 )) / (float2( 1,1 ) - float2( 0,0 )));
				float2 appendResult21_g40 = (float2(( _TimeParameters.x * _1GlobalSpeed ) , ( ( simplePerlin2D18_g40 * _2L_DEFORMspeedXYnoiseScaleNoiseInt.w ) + ( ( atan2( break26_g40.x , break26_g40.y ) / TWO_PI ) + 0.5 ) )));
				float Lightenings60_g37 = saturate( tex2D( _1TX_base_texture, appendResult21_g40 ).r );
				float LighteningsSharpness17_g37 = ( pow( Lightenings60_g37 , _4sharpness ) * _1Lighteningopacity );
				float temp_output_20_0_g37 = ( BaseCIrcle18_g37 * LighteningsSharpness17_g37 );
				float3 temp_cast_7 = (saturate( temp_output_20_0_g37 )).xxx;
				float3 saferPower14_g42 = max( temp_cast_7 , 0.0001 );
				float3 temp_cast_8 = (_4baseInttresholdintemissiveInt.y).xxx;
				float3 temp_output_14_0_g42 = pow( saferPower14_g42 , temp_cast_8 );
				float4 Color_Emissive28_g37 = Color_Emissive188;
				float4 Color_Base31_g37 = Color_Base189;
				float4 Lighteningscolor37_g37 = ( ( float4( ( temp_output_14_0_g42 * _4baseInttresholdintemissiveInt.z ) , 0.0 ) * Color_Emissive28_g37 ) + ( ( temp_output_20_0_g37 * Color_Base31_g37 ) * _4baseInttresholdintemissiveInt.x ) );
				float4 Lighteningscolor159 = Lighteningscolor37_g37;
				
				float Lighteningsalpha36_g37 = saturate( temp_output_20_0_g37 );
				float Lighteningsalpha160 = Lighteningsalpha36_g37;
				float CircleAlpha185 = saturate( ( temp_output_196_0 * 0.3 ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( CircleColor183 + Lighteningscolor159 ).rgb;
				float Alpha = saturate( ( Lighteningsalpha160 + CircleAlpha185 ) );
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
			#define _RECEIVE_SHADOWS_OFF 1
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

			sampler2D _1TX_base_texture;
			sampler2D _3TX_S_DEFORM;
			CBUFFER_START( UnityPerMaterial )
			float4 _4coloremissive;
			float _5Spherescale;
			float _5Spheresharpness;
			float _5Sphere_opacity;
			float _5Sphere_emissive_Int;
			float4 _4colorbase;
			float _1GlobalSpeed;
			float4 _2L_DEFORMspeedXYnoiseScaleNoiseInt;
			float4 _3S_DEFORMspeedXYtilesXY;
			float _3S_DEFORMmin;
			float _3S_DEFORMmax;
			float _4sharpness;
			float _1Lighteningopacity;
			float4 _4baseInttresholdintemissiveInt;
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

				float2 CenteredUV15_g39 = ( IN.ase_texcoord2.xy - float2( 0.5,0.5 ) );
				float2 break17_g39 = CenteredUV15_g39;
				float2 appendResult23_g39 = (float2(( length( CenteredUV15_g39 ) * (10.0 + (_5Spherescale - 0.0) * (1.0 - 10.0) / (1.0 - 0.0)) * 2.0 ) , ( atan2( break17_g39.x , break17_g39.y ) * ( 1.0 / TWO_PI ) * 1.0 )));
				float BaseCIrcle18_g37 = ( saturate( ( 1.0 - appendResult23_g39.x ) ) * _5Spheresharpness );
				float2 appendResult8_g40 = (float2(_2L_DEFORMspeedXYnoiseScaleNoiseInt.x , _2L_DEFORMspeedXYnoiseScaleNoiseInt.y));
				float2 appendResult4_g41 = (float2(_3S_DEFORMspeedXYtilesXY.x , _3S_DEFORMspeedXYtilesXY.y));
				float2 uv054_g37 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_41_0_g40 = uv054_g37;
				float2 appendResult12_g41 = (float2(_3S_DEFORMspeedXYtilesXY.z , _3S_DEFORMspeedXYtilesXY.w));
				float2 panner6_g41 = ( _TimeParameters.x * appendResult4_g41 + ( temp_output_41_0_g40 * appendResult12_g41 ));
				float2 temp_cast_0 = (( tex2D( _3TX_S_DEFORM, panner6_g41 ).r * (_3S_DEFORMmin + (sin( _TimeParameters.x ) - -1.0) * (_3S_DEFORMmax - _3S_DEFORMmin) / (1.0 - -1.0)) )).xx;
				float2 uv013_g40 = IN.ase_texcoord2.xy * float2( 1,1 ) + temp_cast_0;
				float2 panner17_g40 = ( 1.0 * _Time.y * appendResult8_g40 + ( uv013_g40 * 0.5 ));
				float simplePerlin2D18_g40 = snoise( panner17_g40*_2L_DEFORMspeedXYnoiseScaleNoiseInt.z );
				simplePerlin2D18_g40 = simplePerlin2D18_g40*0.5 + 0.5;
				float2 break26_g40 = (float2( -1,-1 ) + (temp_output_41_0_g40 - float2( 0,0 )) * (float2( 1,1 ) - float2( -1,-1 )) / (float2( 1,1 ) - float2( 0,0 )));
				float2 appendResult21_g40 = (float2(( _TimeParameters.x * _1GlobalSpeed ) , ( ( simplePerlin2D18_g40 * _2L_DEFORMspeedXYnoiseScaleNoiseInt.w ) + ( ( atan2( break26_g40.x , break26_g40.y ) / TWO_PI ) + 0.5 ) )));
				float Lightenings60_g37 = saturate( tex2D( _1TX_base_texture, appendResult21_g40 ).r );
				float LighteningsSharpness17_g37 = ( pow( Lightenings60_g37 , _4sharpness ) * _1Lighteningopacity );
				float temp_output_20_0_g37 = ( BaseCIrcle18_g37 * LighteningsSharpness17_g37 );
				float Lighteningsalpha36_g37 = saturate( temp_output_20_0_g37 );
				float Lighteningsalpha160 = Lighteningsalpha36_g37;
				float BaseCIrcle156 = BaseCIrcle18_g37;
				float4 temp_cast_1 = (BaseCIrcle156).xxxx;
				float4 temp_cast_2 = (0.85).xxxx;
				float4 temp_cast_3 = (1.355).xxxx;
				float4 temp_output_6_0_g43 = pow( saturate( ( pow( temp_cast_1 , temp_cast_2 ) / 0.35 ) ) , temp_cast_3 );
				float4 break14_g43 = temp_output_6_0_g43;
				float temp_output_196_0 = ( ( break14_g43.r * (1.0 + (BaseCIrcle156 - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) * _5Sphere_opacity );
				float CircleAlpha185 = saturate( ( temp_output_196_0 * 0.3 ) );
				
				float Alpha = saturate( ( Lighteningsalpha160 + CircleAlpha185 ) );
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
-1280;84;1280;659;2673.573;397.8804;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;205;-2431.28,-390.6258;Inherit;False;510.6692;516.6895;;4;189;188;102;106;VAR -  color;1,0.5019608,0.9176471,1;0;0
Node;AmplifyShaderEditor.ColorNode;106;-2376.662,-340.6258;Inherit;False;Property;_4colorbase;4- color base;27;0;Create;True;0;0;False;0;0,0.5215687,1,0;0,0.5215685,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;102;-2381.28,-85.93634;Inherit;False;Property;_4coloremissive;4- color emissive;28;0;Create;True;0;0;False;0;0.6352941,0.9411765,1,0;0.635294,0.9411765,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;189;-2134.493,-337.2753;Inherit;False;Color_Base;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;188;-2135.611,-83.38251;Inherit;False;Color_Emissive;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;150;-2424.604,375.4739;Inherit;False;2930.84;654.5895;;12;201;128;94;200;108;146;51;147;125;126;124;118;Lightenings;1,0.5019608,0.9176471,1;0;0
Node;AmplifyShaderEditor.Vector4Node;128;49.35788,773.295;Inherit;False;Property;_4baseInttresholdintemissiveInt;4- base Int - treshold int - emissive Int - ;26;0;Create;True;0;0;False;0;10,5,5,0;10,5,5,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;94;-202.0139,895.6169;Inherit;False;Property;_4sharpness;4- sharpness;29;0;Create;True;0;0;False;0;3;3;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;200;-430.8024,783.3745;Inherit;False;189;Color_Base;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;11;819.9445,912.0326;Inherit;False;Property;_5Spherescale;5- Sphere scale;30;0;Create;True;0;0;False;0;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-1950.349,742.9609;Inherit;False;Property;_3S_DEFORMmax;3- S_DEFORM - max;25;0;Create;True;0;0;False;0;0.4;0.4;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-415.0397,461.3062;Inherit;False;Property;_1Lighteningopacity;1- Lightening opacity;20;0;Create;True;0;0;False;0;0.5;0.5;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;536.3925,936.2394;Inherit;False;Property;_5Spheresharpness;5- Sphere sharpness;31;0;Create;True;0;0;False;0;3.5;3;0;25;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;-256.5011,816.7508;Inherit;False;188;Color_Emissive;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector4Node;126;-2115.24,498.5896;Inherit;False;Property;_2L_DEFORMspeedXYnoiseScaleNoiseInt;2- L_DEFORM - speed X/Y - noise Scale - Noise Int;21;0;Create;True;0;0;False;0;1,2,2.75,0.15;1,2,2.75,0.15;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;118;-1663.845,719.3907;Inherit;False;Property;_3S_DEFORMmin;3- S_DEFORM - min;24;0;Create;True;0;0;False;0;0.2;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;146;-1341.067,603.2075;Inherit;True;Property;_3TX_S_DEFORM;3- TX_S_DEFORM;22;0;Create;True;0;0;True;0;None;bdbe94d7623ec3940947b62544306f1c;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.Vector4Node;125;-2404.403,602.0629;Inherit;False;Property;_3S_DEFORMspeedXYtilesXY;3- S_DEFORM - speed X/Y - tiles X/Y;23;0;Create;True;0;0;False;0;0.2,0.3,0.04,0.01;0.2,0.3,0.04,0.01;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;147;-1548.893,475.5186;Inherit;True;Property;_1TX_base_texture;1- TX_base_texture;19;0;Create;True;0;0;True;0;None;b895ecea225dd4540a48d6293e2070ee;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-1128.789,448.4547;Inherit;False;Property;_1GlobalSpeed;1- Global Speed;18;0;Create;True;0;0;False;0;0.5;0.5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;206;1162.446,437.7273;Inherit;False;MF_Lightenings_and_circle;0;;37;ab5f87db33f8fd5409ed675ac42e9451;0;23;68;FLOAT2;0,0;False;74;FLOAT;0.5;False;42;FLOAT;0.5;False;73;SAMPLER2D;0;False;69;FLOAT;1;False;70;FLOAT;2;False;71;FLOAT;2.75;False;72;FLOAT;0.15;False;65;SAMPLER2D;0;False;64;FLOAT;0.2;False;61;FLOAT;0.3;False;62;FLOAT;0.04;False;63;FLOAT;0.01;False;66;FLOAT;0.2;False;67;FLOAT;0.4;False;47;COLOR;0,0.5215687,1,0;False;43;FLOAT;10;False;46;COLOR;0.6352941,0.9411765,1,0;False;44;FLOAT;5;False;45;FLOAT;5;False;41;FLOAT;3;False;48;FLOAT;1;False;49;FLOAT;3.5;False;3;FLOAT;39;COLOR;38;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;156;1903.213,383.6577;Inherit;False;BaseCIrcle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;194;2691.223,387.9037;Inherit;False;1914.5;1016.641;;7;19;20;15;21;17;202;203;circle_REMAP;1,0.5019608,0.9176471,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;19;3565.088,825.9333;Inherit;False;Constant;_resharp;resharp;6;0;Create;True;0;0;False;0;1.355;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;3994.704,780.3293;Inherit;False;Constant;_base_sharpness;base_sharpness;7;0;Create;True;0;0;False;0;0.85;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;3641.275,1170.167;Inherit;False;156;BaseCIrcle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;203;4054.061,972.0009;Inherit;False;156;BaseCIrcle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;3764.192,801.3049;Inherit;False;Constant;_resize;resize;8;0;Create;True;0;0;False;0;0.35;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;195;4737.451,387.9037;Inherit;False;2171.831;1018.813;;22;25;182;180;172;171;192;169;167;23;0;183;185;28;170;144;175;181;174;27;193;166;196;circle COLOR;1,0.2509804,0.2509804,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;21;3841.366,1189.575;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;15;4285.113,761.5925;Inherit;False;MF_Remap;-1;;43;d197793f79a52624396d10fda693fcd3;0;4;13;COLOR;0,0,0,0;False;10;FLOAT;5;False;11;FLOAT;0.5;False;12;FLOAT;1;False;4;COLOR;0;FLOAT;15;FLOAT;16;FLOAT;17
Node;AmplifyShaderEditor.RangedFloatNode;197;4780.739,1366.786;Inherit;False;Property;_5Sphere_opacity;5- Sphere_opacity;33;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;4810.703,1164.757;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;144;6005.35,1205.695;Inherit;False;Constant;_opacitymulitply;opacity mulitply;19;0;Create;True;0;0;False;0;0.3;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;196;5102.279,1169.195;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;6249.533,1171.225;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;28;6449.224,1172.584;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;160;1753.429,515.9023;Inherit;False;Lighteningsalpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;187;7170.786,770.7537;Inherit;False;1575.347;380.5644;;8;141;1;184;162;164;186;163;139;MIXER;0,1,0.01176471,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;185;6642.951,1169.063;Inherit;False;CircleAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;7485.362,976.5923;Inherit;False;185;CircleAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;163;7670.37,951.9724;Inherit;False;160;Lighteningsalpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;139;7961.01,957.2877;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;141;8218.797,958.1763;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;159;2082.952,496.4486;Inherit;False;Lighteningscolor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;193;5568.651,465.7117;Inherit;False;189;Color_Base;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;164;7776.867,824.4704;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleTimeNode;182;5307.237,1086.292;Inherit;False;1;0;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;5703.173,963.1412;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;183;6637.45,931.5527;Inherit;False;CircleColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;174;5851.795,959.7941;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;166;5918.038,452.5577;Inherit;False;MF_Emissive_handler;-1;;44;4c2d144224f39b24a93af8da62996f6d;0;4;11;FLOAT3;0,0,0;False;9;COLOR;0,0,0,0;False;10;FLOAT;0;False;12;FLOAT;50;False;2;COLOR;0;FLOAT3;13
Node;AmplifyShaderEditor.GetLocalVarNode;192;4891.773,437.9038;Inherit;False;188;Color_Emissive;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;184;7222.417,820.7537;Inherit;False;183;CircleColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;162;7430.839,843.735;Inherit;False;159;Lighteningscolor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;175;5617.836,1188.55;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;170;6363.26,936.7142;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleTimeNode;172;5319.023,983.3718;Inherit;False;1;0;FLOAT;50;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;171;5479.96,971.3143;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;180;5525.729,1084.968;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;5341.771,811.712;Inherit;False;Property;_5Sphere_emissive_Int;5- Sphere_emissive_Int;32;0;Create;True;0;0;False;0;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;169;5119.195,444.1917;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;167;5327.123,521.3353;Inherit;False;Constant;_emissive_treshold2;emissive_treshold 2;17;0;Create;True;0;0;False;0;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;5490.244,598.6437;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;8465.128,823.5908;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;M_VFX_Burst;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=TransparentCutout=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;False;True;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;189;0;106;0
WireConnection;188;0;102;0
WireConnection;206;74;51;0
WireConnection;206;42;108;0
WireConnection;206;73;147;0
WireConnection;206;69;126;1
WireConnection;206;70;126;2
WireConnection;206;71;126;3
WireConnection;206;72;126;4
WireConnection;206;65;146;0
WireConnection;206;64;125;1
WireConnection;206;61;125;2
WireConnection;206;62;125;3
WireConnection;206;63;125;4
WireConnection;206;66;118;0
WireConnection;206;67;124;0
WireConnection;206;47;200;0
WireConnection;206;43;128;1
WireConnection;206;46;201;0
WireConnection;206;44;128;2
WireConnection;206;45;128;3
WireConnection;206;41;94;0
WireConnection;206;48;11;0
WireConnection;206;49;10;0
WireConnection;156;0;206;39
WireConnection;21;0;202;0
WireConnection;15;13;203;0
WireConnection;15;10;20;0
WireConnection;15;11;17;0
WireConnection;15;12;19;0
WireConnection;23;0;15;15
WireConnection;23;1;21;0
WireConnection;196;0;23;0
WireConnection;196;1;197;0
WireConnection;27;0;196;0
WireConnection;27;1;144;0
WireConnection;28;0;27;0
WireConnection;160;0;206;0
WireConnection;185;0;28;0
WireConnection;139;0;163;0
WireConnection;139;1;186;0
WireConnection;141;0;139;0
WireConnection;159;0;206;38
WireConnection;164;0;184;0
WireConnection;164;1;162;0
WireConnection;181;0;171;0
WireConnection;181;1;180;0
WireConnection;183;0;170;0
WireConnection;174;0;181;0
WireConnection;174;3;25;0
WireConnection;174;4;175;0
WireConnection;166;11;169;0
WireConnection;166;9;193;0
WireConnection;166;10;25;0
WireConnection;166;12;167;0
WireConnection;175;0;25;0
WireConnection;170;0;166;0
WireConnection;170;1;174;0
WireConnection;171;0;172;0
WireConnection;180;0;182;0
WireConnection;169;0;192;0
WireConnection;169;1;196;0
WireConnection;1;2;164;0
WireConnection;1;3;141;0
ASEEND*/
//CHKSM=ABABA5EE8746FA0C7CB6CD66454A78EE95730DE4