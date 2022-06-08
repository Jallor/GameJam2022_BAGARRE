// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_Sparks_MeshDriven"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_global_Offset_X("_global_Offset_X", Range( 0 , 1)) = 0
		[SingleLineTexture]_TX_fire("_TX_fire", 2D) = "white" {}
		_fire_size_XYoffset_Y("fire_size_XY/../offset_Y", Vector) = (5,5,0,-0.02)
		_emissive_Color("emissive_Color", Color) = (1,0.4495072,0,0)
		_emissive_Intensity("emissive_Intensity", Range( 0 , 75)) = 20
		_emissive_treshold("emissive_treshold", Range( 0 , 50)) = 1
		[SingleLineTexture]_TX_smoke("_TX_smoke", 2D) = "white" {}
		_Smoke("Smoke ?", Range( 0 , 1)) = 0
		_smoke_size_XYoffset_XY("smoke_size_XY/../offset_XY", Vector) = (4,4,0,-0.04)
		_smoke_add_Offset_X("smoke_add_Offset_X", Range( -0.3 , 0.3)) = 0
		[SingleLineTexture]_TX_dissolve("_TX_dissolve", 2D) = "white" {}
		_dissolve_size_XYspeed_XY("dissolve_size_XY/speed_XY", Vector) = (0.75,1.5,0.85,0.1)
		_alpha_Mask_X("alpha_Mask_X", Range( 0 , 1)) = 1
		_alpha_mesh_Intensity("alpha_mesh_Intensity", Range( 0 , 5)) = 0
		_gravity_Intensity("gravity_Intensity", Range( -50 , 50)) = -25
		_gravity_begin("gravity_% begin", Range( 0 , 1)) = 0
		_Y("Y", Int) = 3
		_X("X", Int) = 5
		_sizenoise("size noise", Float) = 0.025

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

			#define ASE_NEEDS_VERT_NORMAL


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

			sampler2D _TX_fire;
			sampler2D _TX_smoke;
			sampler2D _TX_dissolve;
			CBUFFER_START( UnityPerMaterial )
			float _global_Offset_X;
			float4 _fire_size_XYoffset_Y;
			float _gravity_Intensity;
			float _gravity_begin;
			float _emissive_treshold;
			float _emissive_Intensity;
			float4 _emissive_Color;
			float _smoke_add_Offset_X;
			float4 _smoke_size_XYoffset_XY;
			int _X;
			int _Y;
			float _sizenoise;
			float _Smoke;
			float4 _dissolve_size_XYspeed_XY;
			float _alpha_mesh_Intensity;
			float _alpha_Mask_X;
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

				float Xpanning0_1147 = _global_Offset_X;
				float3 lerpResult160 = lerp( ( v.ase_normal * ( 0.39 / 300.0 ) ) , float3( 0,0,0 ) , Xpanning0_1147);
				float Xpanning1_190 = (-1.0 + (_global_Offset_X - 0.0) * (1.0 - -1.0) / (1.0 - 0.0));
				float2 appendResult5_g14 = (float2(Xpanning1_190 , _fire_size_XYoffset_Y.w));
				float2 uv06_g14 = v.ase_texcoord.xy * float2( 1,1 ) + appendResult5_g14;
				float2 break10_g14 = (float2( -0.5,-0.5 ) + (uv06_g14 - float2( 0,0 )) * (float2( 0.5,0.5 ) - float2( -0.5,-0.5 )) / (float2( 1,1 ) - float2( 0,0 )));
				float2 appendResult14_g14 = (float2(( break10_g14.x * _fire_size_XYoffset_Y.x ) , ( break10_g14.y * _fire_size_XYoffset_Y.y )));
				float2 MovealongUV_0195 = ( appendResult14_g14 + float2( 0.5,0.5 ) );
				float3 lerpResult157 = lerp( float3( 0,0,0 ) , lerpResult160 , MovealongUV_0195.x);
				float4 transform209 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,0 ));
				float clampResult217 = clamp( Xpanning0_1147 , _gravity_begin , 1.0 );
				float lerpResult214 = lerp( 0.0 , _gravity_Intensity , ( clampResult217 - _gravity_begin ));
				float4 appendResult211 = (float4(transform209.x , ( transform209.y + ( lerpResult214 / 10.0 ) ) , transform209.z , transform209.w));
				float3 worldToObjDir212 = mul( GetWorldToObjectMatrix(), float4( appendResult211.xyz, 0 ) ).xyz;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( lerpResult157 + worldToObjDir212 );
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
				float Xpanning1_190 = (-1.0 + (_global_Offset_X - 0.0) * (1.0 - -1.0) / (1.0 - 0.0));
				float2 appendResult5_g14 = (float2(Xpanning1_190 , _fire_size_XYoffset_Y.w));
				float2 uv06_g14 = IN.ase_texcoord3.xy * float2( 1,1 ) + appendResult5_g14;
				float2 break10_g14 = (float2( -0.5,-0.5 ) + (uv06_g14 - float2( 0,0 )) * (float2( 0.5,0.5 ) - float2( -0.5,-0.5 )) / (float2( 1,1 ) - float2( 0,0 )));
				float2 appendResult14_g14 = (float2(( break10_g14.x * _fire_size_XYoffset_Y.x ) , ( break10_g14.y * _fire_size_XYoffset_Y.y )));
				float2 MovealongUV_0195 = ( appendResult14_g14 + float2( 0.5,0.5 ) );
				float4 Fire_var182 = tex2D( _TX_fire, MovealongUV_0195 );
				float3 saferPower14_g21 = max( Fire_var182.rgb , 0.0001 );
				float3 temp_cast_1 = (_emissive_treshold).xxx;
				float3 temp_output_14_0_g21 = pow( saferPower14_g21 , temp_cast_1 );
				float2 appendResult5_g15 = (float2(( _smoke_add_Offset_X + Xpanning1_190 ) , _smoke_size_XYoffset_XY.w));
				float2 uv06_g15 = IN.ase_texcoord3.xy * float2( 1,1 ) + appendResult5_g15;
				float2 break10_g15 = (float2( -0.5,-0.5 ) + (uv06_g15 - float2( 0,0 )) * (float2( 0.5,0.5 ) - float2( -0.5,-0.5 )) / (float2( 1,1 ) - float2( 0,0 )));
				float2 appendResult14_g15 = (float2(( break10_g15.x * _smoke_size_XYoffset_XY.x ) , ( break10_g15.y * _smoke_size_XYoffset_XY.y )));
				float2 MovealongUV_02117 = ( appendResult14_g15 + float2( 0.5,0.5 ) );
				float2 appendResult235 = (float2((float)_X , (float)_Y));
				float2 panner239 = ( 1.0 * _Time.y * appendResult235 + MovealongUV_0195);
				float simplePerlin2D240 = snoise( panner239*_sizenoise );
				simplePerlin2D240 = simplePerlin2D240*0.5 + 0.5;
				float2 temp_cast_5 = (simplePerlin2D240).xx;
				float Xpanning0_1147 = _global_Offset_X;
				float lerpResult244 = lerp( 0.0 , 0.5 , Xpanning0_1147);
				float2 lerpResult237 = lerp( MovealongUV_02117 , temp_cast_5 , lerpResult244);
				float4 Smoke_var192 = tex2D( _TX_smoke, lerpResult237 );
				float SmokeOrNot196 = _Smoke;
				float4 lerpResult173 = lerp( float4( 0,0,0,0 ) , Smoke_var192 , SmokeOrNot196);
				float4 lerpResult137 = lerp( ( Fire_var182 * ( float4( ( temp_output_14_0_g21 * _emissive_Intensity ) , 0.0 ) * _emissive_Color ) ) , lerpResult173 , saturate( ( MovealongUV_02117.x + Xpanning0_1147 ) ));
				
				float2 appendResult4_g16 = (float2(_dissolve_size_XYspeed_XY.z , _dissolve_size_XYspeed_XY.w));
				float2 uv046 = IN.ase_texcoord3.xy * float2( 3,3 ) + float2( 0,0 );
				float2 appendResult12_g16 = (float2(_dissolve_size_XYspeed_XY.x , _dissolve_size_XYspeed_XY.y));
				float2 panner6_g16 = ( _TimeParameters.x * appendResult4_g16 + ( uv046 * appendResult12_g16 ));
				float4 Dissolve_var180 = tex2D( _TX_dissolve, panner6_g16 );
				float4 temp_cast_7 = (( Xpanning1_190 * 5.0 )).xxxx;
				float4 lerpResult5_g17 = lerp( saturate( pow( Dissolve_var180 , temp_cast_7 ) ) , float4( 0,0,0,0 ) , 0.0);
				float lerpResult175 = lerp( 0.0 , Smoke_var192.a , SmokeOrNot196);
				float2 uv026 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult32 = lerp( 1.0 , 0.0 , uv026.x);
				float saferPower38 = max( ( lerpResult32 * uv026.x ) , 0.0001 );
				float Alpha_MeshLimits87 = saturate( ( pow( saferPower38 , _alpha_mesh_Intensity ) * ( _alpha_mesh_Intensity * 50.0 ) ) );
				float4 temp_cast_8 = (( ( lerpResult175 + Fire_var182.a ) * Alpha_MeshLimits87 )).xxxx;
				float lerpResult102 = lerp( 1.0 , 0.0 , saturate( ( MovealongUV_0195.x - (-1.0 + (_alpha_Mask_X - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) ));
				float4 Alpha_Var201 = ( saturate( ( lerpResult5_g17 * temp_cast_8 ) ) * saturate( ( ( lerpResult102 * saturate( MovealongUV_0195.x ) ) * 1.65 ) ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult137.rgb;
				float Alpha = Alpha_Var201.r;
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

			#define ASE_NEEDS_VERT_NORMAL


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

			sampler2D _TX_dissolve;
			sampler2D _TX_smoke;
			sampler2D _TX_fire;
			CBUFFER_START( UnityPerMaterial )
			float _global_Offset_X;
			float4 _fire_size_XYoffset_Y;
			float _gravity_Intensity;
			float _gravity_begin;
			float _emissive_treshold;
			float _emissive_Intensity;
			float4 _emissive_Color;
			float _smoke_add_Offset_X;
			float4 _smoke_size_XYoffset_XY;
			int _X;
			int _Y;
			float _sizenoise;
			float _Smoke;
			float4 _dissolve_size_XYspeed_XY;
			float _alpha_mesh_Intensity;
			float _alpha_Mask_X;
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

				float Xpanning0_1147 = _global_Offset_X;
				float3 lerpResult160 = lerp( ( v.ase_normal * ( 0.39 / 300.0 ) ) , float3( 0,0,0 ) , Xpanning0_1147);
				float Xpanning1_190 = (-1.0 + (_global_Offset_X - 0.0) * (1.0 - -1.0) / (1.0 - 0.0));
				float2 appendResult5_g14 = (float2(Xpanning1_190 , _fire_size_XYoffset_Y.w));
				float2 uv06_g14 = v.ase_texcoord.xy * float2( 1,1 ) + appendResult5_g14;
				float2 break10_g14 = (float2( -0.5,-0.5 ) + (uv06_g14 - float2( 0,0 )) * (float2( 0.5,0.5 ) - float2( -0.5,-0.5 )) / (float2( 1,1 ) - float2( 0,0 )));
				float2 appendResult14_g14 = (float2(( break10_g14.x * _fire_size_XYoffset_Y.x ) , ( break10_g14.y * _fire_size_XYoffset_Y.y )));
				float2 MovealongUV_0195 = ( appendResult14_g14 + float2( 0.5,0.5 ) );
				float3 lerpResult157 = lerp( float3( 0,0,0 ) , lerpResult160 , MovealongUV_0195.x);
				float4 transform209 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,0 ));
				float clampResult217 = clamp( Xpanning0_1147 , _gravity_begin , 1.0 );
				float lerpResult214 = lerp( 0.0 , _gravity_Intensity , ( clampResult217 - _gravity_begin ));
				float4 appendResult211 = (float4(transform209.x , ( transform209.y + ( lerpResult214 / 10.0 ) ) , transform209.z , transform209.w));
				float3 worldToObjDir212 = mul( GetWorldToObjectMatrix(), float4( appendResult211.xyz, 0 ) ).xyz;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( lerpResult157 + worldToObjDir212 );
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

				float2 appendResult4_g16 = (float2(_dissolve_size_XYspeed_XY.z , _dissolve_size_XYspeed_XY.w));
				float2 uv046 = IN.ase_texcoord2.xy * float2( 3,3 ) + float2( 0,0 );
				float2 appendResult12_g16 = (float2(_dissolve_size_XYspeed_XY.x , _dissolve_size_XYspeed_XY.y));
				float2 panner6_g16 = ( _TimeParameters.x * appendResult4_g16 + ( uv046 * appendResult12_g16 ));
				float4 Dissolve_var180 = tex2D( _TX_dissolve, panner6_g16 );
				float Xpanning1_190 = (-1.0 + (_global_Offset_X - 0.0) * (1.0 - -1.0) / (1.0 - 0.0));
				float4 temp_cast_0 = (( Xpanning1_190 * 5.0 )).xxxx;
				float4 lerpResult5_g17 = lerp( saturate( pow( Dissolve_var180 , temp_cast_0 ) ) , float4( 0,0,0,0 ) , 0.0);
				float2 appendResult5_g15 = (float2(( _smoke_add_Offset_X + Xpanning1_190 ) , _smoke_size_XYoffset_XY.w));
				float2 uv06_g15 = IN.ase_texcoord2.xy * float2( 1,1 ) + appendResult5_g15;
				float2 break10_g15 = (float2( -0.5,-0.5 ) + (uv06_g15 - float2( 0,0 )) * (float2( 0.5,0.5 ) - float2( -0.5,-0.5 )) / (float2( 1,1 ) - float2( 0,0 )));
				float2 appendResult14_g15 = (float2(( break10_g15.x * _smoke_size_XYoffset_XY.x ) , ( break10_g15.y * _smoke_size_XYoffset_XY.y )));
				float2 MovealongUV_02117 = ( appendResult14_g15 + float2( 0.5,0.5 ) );
				float2 appendResult235 = (float2((float)_X , (float)_Y));
				float2 appendResult5_g14 = (float2(Xpanning1_190 , _fire_size_XYoffset_Y.w));
				float2 uv06_g14 = IN.ase_texcoord2.xy * float2( 1,1 ) + appendResult5_g14;
				float2 break10_g14 = (float2( -0.5,-0.5 ) + (uv06_g14 - float2( 0,0 )) * (float2( 0.5,0.5 ) - float2( -0.5,-0.5 )) / (float2( 1,1 ) - float2( 0,0 )));
				float2 appendResult14_g14 = (float2(( break10_g14.x * _fire_size_XYoffset_Y.x ) , ( break10_g14.y * _fire_size_XYoffset_Y.y )));
				float2 MovealongUV_0195 = ( appendResult14_g14 + float2( 0.5,0.5 ) );
				float2 panner239 = ( 1.0 * _Time.y * appendResult235 + MovealongUV_0195);
				float simplePerlin2D240 = snoise( panner239*_sizenoise );
				simplePerlin2D240 = simplePerlin2D240*0.5 + 0.5;
				float2 temp_cast_3 = (simplePerlin2D240).xx;
				float Xpanning0_1147 = _global_Offset_X;
				float lerpResult244 = lerp( 0.0 , 0.5 , Xpanning0_1147);
				float2 lerpResult237 = lerp( MovealongUV_02117 , temp_cast_3 , lerpResult244);
				float4 Smoke_var192 = tex2D( _TX_smoke, lerpResult237 );
				float SmokeOrNot196 = _Smoke;
				float lerpResult175 = lerp( 0.0 , Smoke_var192.a , SmokeOrNot196);
				float4 Fire_var182 = tex2D( _TX_fire, MovealongUV_0195 );
				float2 uv026 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult32 = lerp( 1.0 , 0.0 , uv026.x);
				float saferPower38 = max( ( lerpResult32 * uv026.x ) , 0.0001 );
				float Alpha_MeshLimits87 = saturate( ( pow( saferPower38 , _alpha_mesh_Intensity ) * ( _alpha_mesh_Intensity * 50.0 ) ) );
				float4 temp_cast_4 = (( ( lerpResult175 + Fire_var182.a ) * Alpha_MeshLimits87 )).xxxx;
				float lerpResult102 = lerp( 1.0 , 0.0 , saturate( ( MovealongUV_0195.x - (-1.0 + (_alpha_Mask_X - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) ));
				float4 Alpha_Var201 = ( saturate( ( lerpResult5_g17 * temp_cast_4 ) ) * saturate( ( ( lerpResult102 * saturate( MovealongUV_0195.x ) ) * 1.65 ) ) );
				
				float Alpha = Alpha_Var201.r;
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

			#define ASE_NEEDS_VERT_NORMAL


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

			sampler2D _TX_dissolve;
			sampler2D _TX_smoke;
			sampler2D _TX_fire;
			CBUFFER_START( UnityPerMaterial )
			float _global_Offset_X;
			float4 _fire_size_XYoffset_Y;
			float _gravity_Intensity;
			float _gravity_begin;
			float _emissive_treshold;
			float _emissive_Intensity;
			float4 _emissive_Color;
			float _smoke_add_Offset_X;
			float4 _smoke_size_XYoffset_XY;
			int _X;
			int _Y;
			float _sizenoise;
			float _Smoke;
			float4 _dissolve_size_XYspeed_XY;
			float _alpha_mesh_Intensity;
			float _alpha_Mask_X;
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

				float Xpanning0_1147 = _global_Offset_X;
				float3 lerpResult160 = lerp( ( v.ase_normal * ( 0.39 / 300.0 ) ) , float3( 0,0,0 ) , Xpanning0_1147);
				float Xpanning1_190 = (-1.0 + (_global_Offset_X - 0.0) * (1.0 - -1.0) / (1.0 - 0.0));
				float2 appendResult5_g14 = (float2(Xpanning1_190 , _fire_size_XYoffset_Y.w));
				float2 uv06_g14 = v.ase_texcoord.xy * float2( 1,1 ) + appendResult5_g14;
				float2 break10_g14 = (float2( -0.5,-0.5 ) + (uv06_g14 - float2( 0,0 )) * (float2( 0.5,0.5 ) - float2( -0.5,-0.5 )) / (float2( 1,1 ) - float2( 0,0 )));
				float2 appendResult14_g14 = (float2(( break10_g14.x * _fire_size_XYoffset_Y.x ) , ( break10_g14.y * _fire_size_XYoffset_Y.y )));
				float2 MovealongUV_0195 = ( appendResult14_g14 + float2( 0.5,0.5 ) );
				float3 lerpResult157 = lerp( float3( 0,0,0 ) , lerpResult160 , MovealongUV_0195.x);
				float4 transform209 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,0 ));
				float clampResult217 = clamp( Xpanning0_1147 , _gravity_begin , 1.0 );
				float lerpResult214 = lerp( 0.0 , _gravity_Intensity , ( clampResult217 - _gravity_begin ));
				float4 appendResult211 = (float4(transform209.x , ( transform209.y + ( lerpResult214 / 10.0 ) ) , transform209.z , transform209.w));
				float3 worldToObjDir212 = mul( GetWorldToObjectMatrix(), float4( appendResult211.xyz, 0 ) ).xyz;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( lerpResult157 + worldToObjDir212 );
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

				float2 appendResult4_g16 = (float2(_dissolve_size_XYspeed_XY.z , _dissolve_size_XYspeed_XY.w));
				float2 uv046 = IN.ase_texcoord2.xy * float2( 3,3 ) + float2( 0,0 );
				float2 appendResult12_g16 = (float2(_dissolve_size_XYspeed_XY.x , _dissolve_size_XYspeed_XY.y));
				float2 panner6_g16 = ( _TimeParameters.x * appendResult4_g16 + ( uv046 * appendResult12_g16 ));
				float4 Dissolve_var180 = tex2D( _TX_dissolve, panner6_g16 );
				float Xpanning1_190 = (-1.0 + (_global_Offset_X - 0.0) * (1.0 - -1.0) / (1.0 - 0.0));
				float4 temp_cast_0 = (( Xpanning1_190 * 5.0 )).xxxx;
				float4 lerpResult5_g17 = lerp( saturate( pow( Dissolve_var180 , temp_cast_0 ) ) , float4( 0,0,0,0 ) , 0.0);
				float2 appendResult5_g15 = (float2(( _smoke_add_Offset_X + Xpanning1_190 ) , _smoke_size_XYoffset_XY.w));
				float2 uv06_g15 = IN.ase_texcoord2.xy * float2( 1,1 ) + appendResult5_g15;
				float2 break10_g15 = (float2( -0.5,-0.5 ) + (uv06_g15 - float2( 0,0 )) * (float2( 0.5,0.5 ) - float2( -0.5,-0.5 )) / (float2( 1,1 ) - float2( 0,0 )));
				float2 appendResult14_g15 = (float2(( break10_g15.x * _smoke_size_XYoffset_XY.x ) , ( break10_g15.y * _smoke_size_XYoffset_XY.y )));
				float2 MovealongUV_02117 = ( appendResult14_g15 + float2( 0.5,0.5 ) );
				float2 appendResult235 = (float2((float)_X , (float)_Y));
				float2 appendResult5_g14 = (float2(Xpanning1_190 , _fire_size_XYoffset_Y.w));
				float2 uv06_g14 = IN.ase_texcoord2.xy * float2( 1,1 ) + appendResult5_g14;
				float2 break10_g14 = (float2( -0.5,-0.5 ) + (uv06_g14 - float2( 0,0 )) * (float2( 0.5,0.5 ) - float2( -0.5,-0.5 )) / (float2( 1,1 ) - float2( 0,0 )));
				float2 appendResult14_g14 = (float2(( break10_g14.x * _fire_size_XYoffset_Y.x ) , ( break10_g14.y * _fire_size_XYoffset_Y.y )));
				float2 MovealongUV_0195 = ( appendResult14_g14 + float2( 0.5,0.5 ) );
				float2 panner239 = ( 1.0 * _Time.y * appendResult235 + MovealongUV_0195);
				float simplePerlin2D240 = snoise( panner239*_sizenoise );
				simplePerlin2D240 = simplePerlin2D240*0.5 + 0.5;
				float2 temp_cast_3 = (simplePerlin2D240).xx;
				float Xpanning0_1147 = _global_Offset_X;
				float lerpResult244 = lerp( 0.0 , 0.5 , Xpanning0_1147);
				float2 lerpResult237 = lerp( MovealongUV_02117 , temp_cast_3 , lerpResult244);
				float4 Smoke_var192 = tex2D( _TX_smoke, lerpResult237 );
				float SmokeOrNot196 = _Smoke;
				float lerpResult175 = lerp( 0.0 , Smoke_var192.a , SmokeOrNot196);
				float4 Fire_var182 = tex2D( _TX_fire, MovealongUV_0195 );
				float2 uv026 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float lerpResult32 = lerp( 1.0 , 0.0 , uv026.x);
				float saferPower38 = max( ( lerpResult32 * uv026.x ) , 0.0001 );
				float Alpha_MeshLimits87 = saturate( ( pow( saferPower38 , _alpha_mesh_Intensity ) * ( _alpha_mesh_Intensity * 50.0 ) ) );
				float4 temp_cast_4 = (( ( lerpResult175 + Fire_var182.a ) * Alpha_MeshLimits87 )).xxxx;
				float lerpResult102 = lerp( 1.0 , 0.0 , saturate( ( MovealongUV_0195.x - (-1.0 + (_alpha_Mask_X - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) ));
				float4 Alpha_Var201 = ( saturate( ( lerpResult5_g17 * temp_cast_4 ) ) * saturate( ( ( lerpResult102 * saturate( MovealongUV_0195.x ) ) * 1.65 ) ) );
				
				float Alpha = Alpha_Var201.r;
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
-1280;84;1280;659;3399.828;1.670571;1.90663;True;False
Node;AmplifyShaderEditor.CommentaryNode;191;-4730.054,901.908;Inherit;False;1017.461;1656.181;;6;174;90;147;7;146;196;VAR;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-4600.921,1026.53;Inherit;False;Property;_global_Offset_X;_global_Offset_X;0;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;146;-4253.229,1030.333;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;190;-3579.721,896.9801;Inherit;False;2044.114;633.6841;;9;124;91;171;161;162;163;95;117;123;UV Fire/smoke;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;-3966.745,1024.481;Inherit;False;Xpanning1_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-3361.248,1390.902;Inherit;False;90;Xpanning1_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;161;-2769.541,1317.884;Inherit;False;Property;_fire_size_XYoffset_Y;fire_size_XY/../offset_Y;2;0;Create;True;0;0;False;0;5,5,0,-0.02;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;124;-3450.3,1137.773;Inherit;False;Property;_smoke_add_Offset_X;smoke_add_Offset_X;9;0;Create;True;0;0;False;0;0;0;-0.3;0.3;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;163;-2173.247,1350.164;Inherit;False;MF_PanAndScale_AlongUV;-1;;14;856695674fe521149b74bc234805bbdd;0;4;18;FLOAT;1;False;17;FLOAT;1;False;19;FLOAT;0;False;20;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.IntNode;231;-2699.68,329.7751;Inherit;False;Property;_X;X;18;0;Create;True;0;0;False;0;5;5;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;230;-2837.025,358.2922;Inherit;False;Property;_Y;Y;17;0;Create;True;0;0;False;0;3;3;0;1;INT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;-1788.505,1346.117;Inherit;False;MovealongUV_01;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;171;-2799.226,982.9801;Inherit;False;Property;_smoke_size_XYoffset_XY;smoke_size_XY/../offset_XY;8;0;Create;True;0;0;False;0;4,4,0,-0.04;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;123;-2935.249,1142.655;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;243;-2345.463,196.6189;Inherit;False;95;MovealongUV_01;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;235;-2257.366,339.0612;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;162;-2172.501,1014.667;Inherit;False;MF_PanAndScale_AlongUV;-1;;15;856695674fe521149b74bc234805bbdd;0;4;18;FLOAT;1;False;17;FLOAT;1;False;19;FLOAT;0;False;20;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;147;-3967.036,1409.362;Inherit;False;Xpanning0_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;117;-1788.608,1012.62;Inherit;False;MovealongUV_02;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;188;-1405.553,1411.154;Inherit;False;2045.4;635.5255;;9;33;39;34;38;28;32;26;87;35;ALPHA FROM MESH;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;236;-2350.106,523.1048;Inherit;False;Property;_sizenoise;size noise;19;0;Create;True;0;0;False;0;0.025;0.025;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;239;-1913.97,316.5881;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;234;-2445.771,746.4334;Inherit;False;147;Xpanning0_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;244;-1702.928,707.5958;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;26;-1344.717,1844.749;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;240;-1798.245,524.0496;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;122;-2217.39,122.3282;Inherit;False;117;MovealongUV_02;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;237;-1477.97,391.7934;Inherit;False;3;0;FLOAT2;15,0;False;1;FLOAT2;50,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;32;-747.6802,1782.731;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;200;-1403.802,388.0912;Inherit;False;889.1691;376.2897;;2;192;112;SMOKE;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;189;-1406.276,897.1137;Inherit;False;890.967;382.5679;;3;97;182;5;FIRE;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-550.5122,1843.337;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;112;-1098.668,457.6128;Inherit;True;Property;_TX_smoke;_TX_smoke;6;1;[SingleLineTexture];Create;True;0;0;True;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;97;-1342.213,993.4893;Inherit;False;95;MovealongUV_01;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-863.1055,1692.458;Inherit;False;Property;_alpha_mesh_Intensity;alpha_mesh_Intensity;13;0;Create;True;0;0;False;0;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;38;-228.6133,1845.828;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;174;-4605.998,1595.972;Inherit;False;Property;_Smoke;Smoke ?;7;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;187;-1404.134,2178.682;Inherit;False;2042.262;380.1555;;5;180;42;46;47;170;DISSOLVE;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;5;-1120.101,969.076;Inherit;True;Property;_TX_fire;_TX_fire;1;1;[SingleLineTexture];Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;192;-760.2812,457.7103;Inherit;False;Smoke_var;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;199;773.1453,1412.596;Inherit;False;2811.337;1145.749;;32;201;113;99;98;105;169;0;110;41;45;111;181;31;94;92;107;109;126;186;175;100;102;106;195;185;198;104;194;225;226;227;228;ALPHA_mixer;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-474.4666,1489.32;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;50;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;170;-1354.134,2253.087;Inherit;False;Property;_dissolve_size_XYspeed_XY;dissolve_size_XY/speed_XY;11;0;Create;True;0;0;False;0;0.75,1.5,0.85,0.1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;196;-3963.509,1595.656;Inherit;False;SmokeOrNot;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;46;-935.7117,2259.627;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;3,3;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;182;-762.1257,968.0941;Inherit;False;Fire_var;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;194;823.1453,1489.409;Inherit;False;192;Smoke_var;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-33.41769,1466.757;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;35;169.9236,1467.205;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;195;1111.543,1495.47;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.CommentaryNode;206;3717.679,1668.4;Inherit;False;2806.805;887.2834;;15;212;211;207;210;208;214;215;220;219;217;209;221;222;223;224;Y WORLD OFFSET;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;185;831.8711,1728.118;Inherit;False;182;Fire_var;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;1113.85,1641.275;Inherit;False;196;SmokeOrNot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;47;-560.9917,2258.618;Inherit;False;MF_Tiles;-1;;16;2fa329d2d99691549897442d611b24f3;0;6;14;FLOAT2;0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;10;FLOAT;1;False;13;FLOAT;1;False;11;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;887.0089,2213.597;Inherit;False;95;MovealongUV_01;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;105;865.0459,2017.543;Inherit;False;Property;_alpha_Mask_X;alpha_Mask_X;12;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;186;1111.047,1732.396;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.LerpOp;175;1399.049,1543.352;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;42;-110.1298,2228.682;Inherit;True;Property;_TX_dissolve;_TX_dissolve;10;1;[SingleLineTexture];Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;220;3976.301,2283.228;Inherit;False;Property;_gravity_begin;gravity_% begin;15;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;333.4593,1461.154;Inherit;False;Alpha_MeshLimits;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;126;1597.345,1780.537;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;99;1131.583,2218.345;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.WireNode;223;4214.81,2447.023;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;1938.098,1683.141;Inherit;False;90;Xpanning1_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;1909.189,1895.523;Inherit;False;87;Alpha_MeshLimits;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;169;1177.306,2022.464;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;180;326.4697,2232.239;Inherit;False;Dissolve_var;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;181;2294.842,1712.655;Inherit;False;180;Dissolve_var;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;2157.229,1687.756;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;224;4257.41,2449.528;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;2242.594,1779.175;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;215;4358.747,2393.564;Inherit;False;147;Xpanning0_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;104;1473.046,2090.344;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;217;4559.052,2399.138;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;106;1665.047,2378.345;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;41;2556.215,1668.639;Inherit;False;MF_Alpha_handler;-1;;17;9ba53a059d6724547ba534bf0c40c79e;0;4;6;FLOAT;0;False;7;FLOAT;0;False;8;COLOR;0,0,0,0;False;13;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;102;1905.046,2330.345;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;219;4657.835,2268.553;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;225;2934.441,1741.717;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;207;4347.139,2235.298;Inherit;False;Property;_gravity_Intensity;gravity_Intensity;14;0;Create;True;0;0;False;0;-25;0;-50;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;205;3716.965,899.3422;Inherit;False;1148.189;634.6101;;9;157;156;160;155;152;159;151;154;150;VERTEX_handler;1,1,1,1;0;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;209;3876.602,1877.011;Inherit;False;1;0;FLOAT4;0,0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;100;1921.046,2218.345;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;221;4066.964,2198.945;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;214;4853.971,2218.274;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;226;2911,1786.667;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;150;3766.965,1302.671;Inherit;False;Constant;_vertex;vertex;22;0;Create;True;0;0;False;0;0.39;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;2129.047,2330.345;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;109;2129.047,2442.345;Inherit;False;Constant;_Power;Power;16;0;Create;True;0;0;False;0;1.65;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;208;5128.529,2219.375;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;227;2911.842,2243.128;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;154;4121.304,1307.296;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;300;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;111;2353.047,2330.345;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;151;4072.17,1138.828;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;222;4184.74,2211.474;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;110;2497.047,2346.345;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;210;5308.419,2194.7;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;159;3803.044,1430.201;Inherit;False;147;Xpanning0_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;155;3781.693,951.3839;Inherit;False;95;MovealongUV_01;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;228;2895.04,2312.186;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;4302.879,1282.77;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;211;5429.345,1896.872;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;160;4469.201,1388.227;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;156;4408.289,959.4678;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;3131.041,2326.297;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;201;3330.354,2320.073;Inherit;False;Alpha_Var;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;157;4685.196,1364.406;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;203;133.8542,256.5606;Inherit;False;3451.947;760.0476;;18;137;85;143;139;149;197;183;20;179;138;21;193;19;136;140;173;88;184;COLOR_Mixer;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;204;3712.219,269.6029;Inherit;False;1150.817;381.5196;Comment;4;176;89;86;202;ALPHA_debug;1,1,1,1;0;0
Node;AmplifyShaderEditor.TransformDirectionNode;212;5799.019,1892.44;Inherit;False;World;Object;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;242;-2223.439,783.8611;Inherit;False;Property;_int;int;21;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;583.6265,567.601;Inherit;False;Property;_emissive_Intensity;emissive_Intensity;4;0;Create;True;0;0;False;0;20;0;0;75;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;213;6228.861,1370.87;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;229;-2701.812,650.4247;Inherit;False;Constant;_beginnoise1;begin noise;8;0;Create;True;0;0;False;0;15;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;86;4095.661,333.8335;Inherit;False;Property;_Keyword0;Keyword 0;16;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Reference;85;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;3971.596,533.4077;Inherit;False;201;Alpha_Var;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;21;874.3221,594.0569;Inherit;False;Property;_emissive_treshold;emissive_treshold;5;0;Create;True;0;0;False;0;1;1;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;179;1225.008,527.3938;Inherit;False;MF_Emissive_handler;-1;;21;4c2d144224f39b24a93af8da62996f6d;0;4;11;FLOAT3;0,0,0;False;9;COLOR;0,0,0,0;False;10;FLOAT;0;False;12;FLOAT;50;False;2;COLOR;0;FLOAT3;13
Node;AmplifyShaderEditor.BreakToComponentsNode;139;2141.996,752.2356;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;88;3012.074,839.0673;Inherit;False;87;Alpha_MeshLimits;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;138;1888.962,748.1632;Inherit;False;117;MovealongUV_02;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;183;530.6565,517.0737;Inherit;False;182;Fire_var;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;2177.87,854.9669;Inherit;False;147;Xpanning0_1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;173;2812.794,306.5606;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;137;3102.778,506.0212;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;85;3396.568,320.0316;Inherit;False;Property;_DEBUG;DEBUG ?;16;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;238;-2032.938,626.9047;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;193;2550.473,324.7746;Inherit;False;192;Smoke_var;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;197;2265.655,347.6466;Inherit;False;196;SmokeOrNot;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;184;1402.237,412.526;Inherit;False;182;Fire_var;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;176;4517.101,336.7933;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.IntNode;89;3785.759,361.6492;Inherit;False;Constant;_Int0;Int 0;15;0;Create;True;0;0;False;0;1;0;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;233;-2860.653,681.326;Inherit;False;Property;_endnoise;endnoise;20;0;Create;True;0;0;False;0;100;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;19;285.2607,541.9654;Inherit;False;Property;_emissive_Color;emissive_Color;3;0;Create;True;0;0;False;0;1,0.4495072,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;143;2543.384,837.4999;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;140;2825.919,841.5249;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;1666.375,503.7402;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;6547.946,523.2222;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;M_Sparks_MeshDriven;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=TransparentCutout=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;1;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;True;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1285.062,1462.596;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
WireConnection;146;0;7;0
WireConnection;90;0;146;0
WireConnection;163;18;161;1
WireConnection;163;17;161;2
WireConnection;163;19;91;0
WireConnection;163;20;161;4
WireConnection;95;0;163;0
WireConnection;123;0;124;0
WireConnection;123;1;91;0
WireConnection;235;0;231;0
WireConnection;235;1;230;0
WireConnection;162;18;171;1
WireConnection;162;17;171;2
WireConnection;162;19;123;0
WireConnection;162;20;171;4
WireConnection;147;0;7;0
WireConnection;117;0;162;0
WireConnection;239;0;243;0
WireConnection;239;2;235;0
WireConnection;244;2;234;0
WireConnection;240;0;239;0
WireConnection;240;1;236;0
WireConnection;237;0;122;0
WireConnection;237;1;240;0
WireConnection;237;2;244;0
WireConnection;32;2;26;1
WireConnection;28;0;32;0
WireConnection;28;1;26;1
WireConnection;112;1;237;0
WireConnection;38;0;28;0
WireConnection;38;1;34;0
WireConnection;5;1;97;0
WireConnection;192;0;112;0
WireConnection;39;0;34;0
WireConnection;196;0;174;0
WireConnection;182;0;5;0
WireConnection;33;0;38;0
WireConnection;33;1;39;0
WireConnection;35;0;33;0
WireConnection;195;0;194;0
WireConnection;47;14;46;0
WireConnection;47;7;170;3
WireConnection;47;8;170;4
WireConnection;47;10;170;1
WireConnection;47;13;170;2
WireConnection;186;0;185;0
WireConnection;175;1;195;3
WireConnection;175;2;198;0
WireConnection;42;1;47;0
WireConnection;87;0;35;0
WireConnection;126;0;175;0
WireConnection;126;1;186;3
WireConnection;99;0;98;0
WireConnection;223;0;220;0
WireConnection;169;0;105;0
WireConnection;180;0;42;0
WireConnection;45;0;92;0
WireConnection;224;0;223;0
WireConnection;31;0;126;0
WireConnection;31;1;94;0
WireConnection;104;0;99;0
WireConnection;104;1;169;0
WireConnection;217;0;215;0
WireConnection;217;1;224;0
WireConnection;106;0;104;0
WireConnection;41;7;45;0
WireConnection;41;8;181;0
WireConnection;41;13;31;0
WireConnection;102;2;106;0
WireConnection;219;0;217;0
WireConnection;219;1;220;0
WireConnection;225;0;41;0
WireConnection;100;0;99;0
WireConnection;221;0;209;2
WireConnection;214;1;207;0
WireConnection;214;2;219;0
WireConnection;226;0;225;0
WireConnection;107;0;102;0
WireConnection;107;1;100;0
WireConnection;208;0;214;0
WireConnection;227;0;226;0
WireConnection;154;0;150;0
WireConnection;111;0;107;0
WireConnection;111;1;109;0
WireConnection;222;0;221;0
WireConnection;110;0;111;0
WireConnection;210;0;222;0
WireConnection;210;1;208;0
WireConnection;228;0;227;0
WireConnection;152;0;151;0
WireConnection;152;1;154;0
WireConnection;211;0;209;1
WireConnection;211;1;210;0
WireConnection;211;2;209;3
WireConnection;211;3;209;4
WireConnection;160;0;152;0
WireConnection;160;2;159;0
WireConnection;156;0;155;0
WireConnection;113;0;228;0
WireConnection;113;1;110;0
WireConnection;201;0;113;0
WireConnection;157;1;160;0
WireConnection;157;2;156;0
WireConnection;212;0;211;0
WireConnection;213;0;157;0
WireConnection;213;1;212;0
WireConnection;86;1;202;0
WireConnection;86;0;89;0
WireConnection;179;11;183;0
WireConnection;179;9;19;0
WireConnection;179;10;20;0
WireConnection;179;12;21;0
WireConnection;139;0;138;0
WireConnection;173;1;193;0
WireConnection;173;2;197;0
WireConnection;137;0;136;0
WireConnection;137;1;173;0
WireConnection;137;2;140;0
WireConnection;85;1;137;0
WireConnection;85;0;88;0
WireConnection;238;0;236;0
WireConnection;238;1;233;0
WireConnection;176;0;86;0
WireConnection;143;0;139;0
WireConnection;143;1;149;0
WireConnection;140;0;143;0
WireConnection;136;0;184;0
WireConnection;136;1;179;0
WireConnection;1;2;137;0
WireConnection;1;3;202;0
WireConnection;1;5;213;0
ASEEND*/
//CHKSM=F29963656E705141CA1DE1BFE2FE1409BE14DD38