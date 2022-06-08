// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_TextGlitch"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_MainTex("_MainTex", 2D) = "white" {}
		_ColorMult("Color Mult", Color) = (0,0,0,0)
		[Toggle(_GLITCH_ON)] _Glitch("Glitch ?", Float) = 1
		_TX_Glitch("TX_Glitch", 2D) = "white" {}
		[PerRendererData]_Glitchintensity("Glitch intensity", Range( 0 , 1)) = 0
		_Glitchlerp("Glitch lerp", Range( 0 , 1)) = 0.735
		_SpeedX("Speed X", Float) = 0
		_SpeedY("Speed Y", Float) = 0
		_Tiles("Tiles", Float) = 1
		_Color01("Color 01", Color) = (1,0,0,0)
		_AddU01("Add U 01", Range( -1 , 1)) = 0
		_AddV01("Add V 01", Range( -1 , 1)) = 0
		_Tilesmult("Tiles mult", Float) = 1
		_SpeedMult("Speed Mult", Float) = 0
		_Color02("Color 02", Color) = (0,1,0,0)
		_AddU02("Add U 02", Range( -1 , 1)) = 0
		_AddV02("Add V 02", Range( -1 , 1)) = 0
		[Header(Alpha)]_AlphaGlobal("Alpha Global", Range( 0 , 1)) = 0
		_AlphaReflect("Alpha Reflect", Range( 0 , 1)) = 1
		_AlphaBase("Alpha Base", Range( 0 , 1)) = 1
		[ASEEnd]_AlphaGlitch("Alpha Glitch", Range( 0 , 1)) = 1

		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Overlay" "Queue"="Transparent" }
		
		Cull Back
		AlphaToMask Off
		HLSLINCLUDE
		#pragma target 2.0

		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}
		
		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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

			#pragma shader_feature_local _GLITCH_ON
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
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color02;
			float4 _Color01;
			float4 _ColorMult;
			float _SpeedX;
			float _AlphaBase;
			float _AlphaGlitch;
			float _AddV02;
			float _AlphaReflect;
			float _AddU02;
			float _AddU01;
			float _Glitchlerp;
			float _SpeedMult;
			float _Tilesmult;
			float _Tiles;
			float _SpeedY;
			float _AddV01;
			float _AlphaGlobal;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _TX_Glitch;
			UNITY_INSTANCING_BUFFER_START(M_TextGlitch)
				UNITY_DEFINE_INSTANCED_PROP(float, _Glitchintensity)
			UNITY_INSTANCING_BUFFER_END(M_TextGlitch)


						
			VertexOutput VertexFunction ( VertexInput v  )
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

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

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
				float2 texCoord131 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord69 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_26_0_g375 = _SpeedX;
				float temp_output_24_0_g375 = _SpeedY;
				float2 appendResult4_g376 = (float2(temp_output_26_0_g375 , temp_output_24_0_g375));
				float2 texCoord2_g374 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_22_0_g375 = texCoord2_g374;
				float temp_output_42_0_g375 = _Tiles;
				float temp_output_29_0_g375 = _Tilesmult;
				float temp_output_18_0_g376 = ( temp_output_42_0_g375 * temp_output_29_0_g375 );
				float2 appendResult16_g376 = (float2(temp_output_18_0_g376 , temp_output_18_0_g376));
				float2 panner6_g376 = ( _TimeParameters.x * appendResult4_g376 + ( temp_output_22_0_g375 * appendResult16_g376 ));
				float2 temp_output_59_0_g375 = panner6_g376;
				float4 tex2DNode11_g375 = tex2D( _TX_Glitch, temp_output_59_0_g375 );
				float temp_output_25_0_g375 = _SpeedMult;
				float2 appendResult4_g377 = (float2(( -temp_output_24_0_g375 * temp_output_25_0_g375 ) , ( temp_output_26_0_g375 * temp_output_25_0_g375 )));
				float temp_output_18_0_g377 = ( temp_output_29_0_g375 * temp_output_42_0_g375 );
				float2 appendResult16_g377 = (float2(temp_output_18_0_g377 , temp_output_18_0_g377));
				float2 panner6_g377 = ( _TimeParameters.x * appendResult4_g377 + ( temp_output_22_0_g375 * appendResult16_g377 ));
				float2 temp_output_58_0_g375 = panner6_g377;
				float4 tex2DNode1_g375 = tex2D( _TX_Glitch, temp_output_58_0_g375 );
				float4 temp_output_22_0_g374 = ( tex2DNode11_g375 * tex2DNode1_g375 );
				float GlitchG12_g374 = (temp_output_22_0_g374).g;
				float GlitchG106 = GlitchG12_g374;
				float2 appendResult71 = (float2(( GlitchG106 * texCoord69.x ) , texCoord69.y));
				float2 lerpResult72 = lerp( texCoord69 , appendResult71 , ( _Glitchlerp / 10.0 ));
				float2 appendResult91 = (float2(_AddU01 , _AddV01));
				float2 temp_output_90_0 = ( lerpResult72 + appendResult91 );
				float2 texCoord111 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float GlitchR11_g374 = (temp_output_22_0_g374).r;
				float GlitchR107 = GlitchR11_g374;
				float2 appendResult114 = (float2(( GlitchR107 * texCoord111.x ) , texCoord111.y));
				float2 lerpResult116 = lerp( texCoord111 , appendResult114 , ( _Glitchlerp / 10.0 ));
				float2 appendResult96 = (float2(_AddU02 , _AddV02));
				float2 temp_output_93_0 = ( lerpResult116 + appendResult96 );
				float _Glitchintensity_Instance = UNITY_ACCESS_INSTANCED_PROP(M_TextGlitch,_Glitchintensity);
				float GlitchIntensity126 = _Glitchintensity_Instance;
				float2 lerpResult130 = lerp( texCoord131 , ( temp_output_90_0 + temp_output_93_0 ) , floor( GlitchIntensity126 ));
				#ifdef _GLITCH_ON
				float2 staticSwitch144 = lerpResult130;
				#else
				float2 staticSwitch144 = texCoord131;
				#endif
				float4 tex2DNode5 = tex2D( _MainTex, staticSwitch144 );
				float GlitchB14_g374 = (temp_output_22_0_g374).b;
				float GlitchB108 = GlitchB14_g374;
				float4 lerpResult169 = lerp( float4( 1,1,1,0 ) , ( tex2DNode5 + GlitchB108 ) , _AlphaGlitch);
				float4 tex2DNode56 = tex2D( _MainTex, temp_output_90_0 );
				float4 tex2DNode89 = tex2D( _MainTex, temp_output_93_0 );
				float4 lerpResult104 = lerp( ( tex2DNode56 + _Color01 ) , ( tex2DNode89 + _Color02 ) , tex2DNode89.a);
				float temp_output_159_0 = ( 1.0 - step( tex2DNode5.r , 0.6 ) );
				float lerpResult171 = lerp( ( tex2DNode5.a * _AlphaBase ) , ( temp_output_159_0 * _AlphaReflect ) , temp_output_159_0);
				float temp_output_148_0 = saturate( ( lerpResult171 * tex2DNode5.a ) );
				float4 lerpResult87 = lerp( lerpResult104 , tex2DNode5 , temp_output_148_0);
				float4 lerpResult121 = lerp( tex2DNode5 , ( lerpResult87 + GlitchG106 + GlitchR107 ) , ceil( GlitchIntensity126 ));
				#ifdef _GLITCH_ON
				float4 staticSwitch136 = ( lerpResult121 + GlitchB108 + GlitchG106 );
				#else
				float4 staticSwitch136 = ( _ColorMult * lerpResult169 );
				#endif
				float4 lerpResult152 = lerp( ( tex2DNode5 * _ColorMult ) , staticSwitch136 , _AlphaGlitch);
				
				float lerpResult123 = lerp( tex2DNode5.a , saturate( ( tex2DNode56.a + tex2DNode89.a ) ) , GlitchIntensity126);
				#ifdef _GLITCH_ON
				float staticSwitch138 = saturate( lerpResult123 );
				#else
				float staticSwitch138 = temp_output_148_0;
				#endif
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult152.rgb;
				float Alpha = saturate( ( staticSwitch138 * _AlphaGlobal ) );
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
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
			AlphaToMask Off

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

			#pragma shader_feature_local _GLITCH_ON
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

			CBUFFER_START(UnityPerMaterial)
			float4 _Color02;
			float4 _Color01;
			float4 _ColorMult;
			float _SpeedX;
			float _AlphaBase;
			float _AlphaGlitch;
			float _AddV02;
			float _AlphaReflect;
			float _AddU02;
			float _AddU01;
			float _Glitchlerp;
			float _SpeedMult;
			float _Tilesmult;
			float _Tiles;
			float _SpeedY;
			float _AddV01;
			float _AlphaGlobal;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _TX_Glitch;
			UNITY_INSTANCING_BUFFER_START(M_TextGlitch)
				UNITY_DEFINE_INSTANCED_PROP(float, _Glitchintensity)
			UNITY_INSTANCING_BUFFER_END(M_TextGlitch)


			
			float3 _LightDirection;

			VertexOutput VertexFunction( VertexInput v )
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
			
			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
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

				float2 texCoord131 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord69 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_26_0_g375 = _SpeedX;
				float temp_output_24_0_g375 = _SpeedY;
				float2 appendResult4_g376 = (float2(temp_output_26_0_g375 , temp_output_24_0_g375));
				float2 texCoord2_g374 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_22_0_g375 = texCoord2_g374;
				float temp_output_42_0_g375 = _Tiles;
				float temp_output_29_0_g375 = _Tilesmult;
				float temp_output_18_0_g376 = ( temp_output_42_0_g375 * temp_output_29_0_g375 );
				float2 appendResult16_g376 = (float2(temp_output_18_0_g376 , temp_output_18_0_g376));
				float2 panner6_g376 = ( _TimeParameters.x * appendResult4_g376 + ( temp_output_22_0_g375 * appendResult16_g376 ));
				float2 temp_output_59_0_g375 = panner6_g376;
				float4 tex2DNode11_g375 = tex2D( _TX_Glitch, temp_output_59_0_g375 );
				float temp_output_25_0_g375 = _SpeedMult;
				float2 appendResult4_g377 = (float2(( -temp_output_24_0_g375 * temp_output_25_0_g375 ) , ( temp_output_26_0_g375 * temp_output_25_0_g375 )));
				float temp_output_18_0_g377 = ( temp_output_29_0_g375 * temp_output_42_0_g375 );
				float2 appendResult16_g377 = (float2(temp_output_18_0_g377 , temp_output_18_0_g377));
				float2 panner6_g377 = ( _TimeParameters.x * appendResult4_g377 + ( temp_output_22_0_g375 * appendResult16_g377 ));
				float2 temp_output_58_0_g375 = panner6_g377;
				float4 tex2DNode1_g375 = tex2D( _TX_Glitch, temp_output_58_0_g375 );
				float4 temp_output_22_0_g374 = ( tex2DNode11_g375 * tex2DNode1_g375 );
				float GlitchG12_g374 = (temp_output_22_0_g374).g;
				float GlitchG106 = GlitchG12_g374;
				float2 appendResult71 = (float2(( GlitchG106 * texCoord69.x ) , texCoord69.y));
				float2 lerpResult72 = lerp( texCoord69 , appendResult71 , ( _Glitchlerp / 10.0 ));
				float2 appendResult91 = (float2(_AddU01 , _AddV01));
				float2 temp_output_90_0 = ( lerpResult72 + appendResult91 );
				float2 texCoord111 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float GlitchR11_g374 = (temp_output_22_0_g374).r;
				float GlitchR107 = GlitchR11_g374;
				float2 appendResult114 = (float2(( GlitchR107 * texCoord111.x ) , texCoord111.y));
				float2 lerpResult116 = lerp( texCoord111 , appendResult114 , ( _Glitchlerp / 10.0 ));
				float2 appendResult96 = (float2(_AddU02 , _AddV02));
				float2 temp_output_93_0 = ( lerpResult116 + appendResult96 );
				float _Glitchintensity_Instance = UNITY_ACCESS_INSTANCED_PROP(M_TextGlitch,_Glitchintensity);
				float GlitchIntensity126 = _Glitchintensity_Instance;
				float2 lerpResult130 = lerp( texCoord131 , ( temp_output_90_0 + temp_output_93_0 ) , floor( GlitchIntensity126 ));
				#ifdef _GLITCH_ON
				float2 staticSwitch144 = lerpResult130;
				#else
				float2 staticSwitch144 = texCoord131;
				#endif
				float4 tex2DNode5 = tex2D( _MainTex, staticSwitch144 );
				float temp_output_159_0 = ( 1.0 - step( tex2DNode5.r , 0.6 ) );
				float lerpResult171 = lerp( ( tex2DNode5.a * _AlphaBase ) , ( temp_output_159_0 * _AlphaReflect ) , temp_output_159_0);
				float temp_output_148_0 = saturate( ( lerpResult171 * tex2DNode5.a ) );
				float4 tex2DNode56 = tex2D( _MainTex, temp_output_90_0 );
				float4 tex2DNode89 = tex2D( _MainTex, temp_output_93_0 );
				float lerpResult123 = lerp( tex2DNode5.a , saturate( ( tex2DNode56.a + tex2DNode89.a ) ) , GlitchIntensity126);
				#ifdef _GLITCH_ON
				float staticSwitch138 = saturate( lerpResult123 );
				#else
				float staticSwitch138 = temp_output_148_0;
				#endif
				
				float Alpha = saturate( ( staticSwitch138 * _AlphaGlobal ) );
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
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
			AlphaToMask Off

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

			#pragma shader_feature_local _GLITCH_ON
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

			CBUFFER_START(UnityPerMaterial)
			float4 _Color02;
			float4 _Color01;
			float4 _ColorMult;
			float _SpeedX;
			float _AlphaBase;
			float _AlphaGlitch;
			float _AddV02;
			float _AlphaReflect;
			float _AddU02;
			float _AddU01;
			float _Glitchlerp;
			float _SpeedMult;
			float _Tilesmult;
			float _Tiles;
			float _SpeedY;
			float _AddV01;
			float _AlphaGlobal;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _MainTex;
			sampler2D _TX_Glitch;
			UNITY_INSTANCING_BUFFER_START(M_TextGlitch)
				UNITY_DEFINE_INSTANCED_PROP(float, _Glitchintensity)
			UNITY_INSTANCING_BUFFER_END(M_TextGlitch)


			
			VertexOutput VertexFunction( VertexInput v  )
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

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

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

				float2 texCoord131 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 texCoord69 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_26_0_g375 = _SpeedX;
				float temp_output_24_0_g375 = _SpeedY;
				float2 appendResult4_g376 = (float2(temp_output_26_0_g375 , temp_output_24_0_g375));
				float2 texCoord2_g374 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_output_22_0_g375 = texCoord2_g374;
				float temp_output_42_0_g375 = _Tiles;
				float temp_output_29_0_g375 = _Tilesmult;
				float temp_output_18_0_g376 = ( temp_output_42_0_g375 * temp_output_29_0_g375 );
				float2 appendResult16_g376 = (float2(temp_output_18_0_g376 , temp_output_18_0_g376));
				float2 panner6_g376 = ( _TimeParameters.x * appendResult4_g376 + ( temp_output_22_0_g375 * appendResult16_g376 ));
				float2 temp_output_59_0_g375 = panner6_g376;
				float4 tex2DNode11_g375 = tex2D( _TX_Glitch, temp_output_59_0_g375 );
				float temp_output_25_0_g375 = _SpeedMult;
				float2 appendResult4_g377 = (float2(( -temp_output_24_0_g375 * temp_output_25_0_g375 ) , ( temp_output_26_0_g375 * temp_output_25_0_g375 )));
				float temp_output_18_0_g377 = ( temp_output_29_0_g375 * temp_output_42_0_g375 );
				float2 appendResult16_g377 = (float2(temp_output_18_0_g377 , temp_output_18_0_g377));
				float2 panner6_g377 = ( _TimeParameters.x * appendResult4_g377 + ( temp_output_22_0_g375 * appendResult16_g377 ));
				float2 temp_output_58_0_g375 = panner6_g377;
				float4 tex2DNode1_g375 = tex2D( _TX_Glitch, temp_output_58_0_g375 );
				float4 temp_output_22_0_g374 = ( tex2DNode11_g375 * tex2DNode1_g375 );
				float GlitchG12_g374 = (temp_output_22_0_g374).g;
				float GlitchG106 = GlitchG12_g374;
				float2 appendResult71 = (float2(( GlitchG106 * texCoord69.x ) , texCoord69.y));
				float2 lerpResult72 = lerp( texCoord69 , appendResult71 , ( _Glitchlerp / 10.0 ));
				float2 appendResult91 = (float2(_AddU01 , _AddV01));
				float2 temp_output_90_0 = ( lerpResult72 + appendResult91 );
				float2 texCoord111 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float GlitchR11_g374 = (temp_output_22_0_g374).r;
				float GlitchR107 = GlitchR11_g374;
				float2 appendResult114 = (float2(( GlitchR107 * texCoord111.x ) , texCoord111.y));
				float2 lerpResult116 = lerp( texCoord111 , appendResult114 , ( _Glitchlerp / 10.0 ));
				float2 appendResult96 = (float2(_AddU02 , _AddV02));
				float2 temp_output_93_0 = ( lerpResult116 + appendResult96 );
				float _Glitchintensity_Instance = UNITY_ACCESS_INSTANCED_PROP(M_TextGlitch,_Glitchintensity);
				float GlitchIntensity126 = _Glitchintensity_Instance;
				float2 lerpResult130 = lerp( texCoord131 , ( temp_output_90_0 + temp_output_93_0 ) , floor( GlitchIntensity126 ));
				#ifdef _GLITCH_ON
				float2 staticSwitch144 = lerpResult130;
				#else
				float2 staticSwitch144 = texCoord131;
				#endif
				float4 tex2DNode5 = tex2D( _MainTex, staticSwitch144 );
				float temp_output_159_0 = ( 1.0 - step( tex2DNode5.r , 0.6 ) );
				float lerpResult171 = lerp( ( tex2DNode5.a * _AlphaBase ) , ( temp_output_159_0 * _AlphaReflect ) , temp_output_159_0);
				float temp_output_148_0 = saturate( ( lerpResult171 * tex2DNode5.a ) );
				float4 tex2DNode56 = tex2D( _MainTex, temp_output_90_0 );
				float4 tex2DNode89 = tex2D( _MainTex, temp_output_93_0 );
				float lerpResult123 = lerp( tex2DNode5.a , saturate( ( tex2DNode56.a + tex2DNode89.a ) ) , GlitchIntensity126);
				#ifdef _GLITCH_ON
				float staticSwitch138 = saturate( lerpResult123 );
				#else
				float staticSwitch138 = temp_output_148_0;
				#endif
				
				float Alpha = saturate( ( staticSwitch138 * _AlphaGlobal ) );
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
Version=18712
-1768;0;1768;931;-268.7146;674.2382;1.679555;True;False
Node;AmplifyShaderEditor.RangedFloatNode;61;-3918.559,-15.65027;Inherit;False;Property;_Tiles;Tiles;14;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-3580.286,-67.44466;Inherit;False;Property;_SpeedX;Speed X;12;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2917.636,11.73328;Inherit;False;Property;_SpeedMult;Speed Mult;19;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-3715.039,-42.82294;Inherit;False;Property;_SpeedY;Speed Y;13;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-3214.497,31.47107;Inherit;False;Property;_Tilesmult;Tiles mult;18;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;143;-2412.252,-274.3922;Inherit;False;MF_Glitch;3;;374;93ce140afa429e14abc86f0bf8ab85df;0;5;17;FLOAT;0.5;False;18;FLOAT;2;False;19;FLOAT;1;False;20;FLOAT;1;False;21;FLOAT;10;False;3;FLOAT;0;FLOAT;15;FLOAT;16
Node;AmplifyShaderEditor.RegisterLocalVarNode;107;-1845.617,-109.3076;Inherit;False;GlitchR;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;106;-1846.365,-28.37701;Inherit;False;GlitchG;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;69;-1973.525,454.3179;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;117;-1886.454,942.0629;Inherit;False;107;GlitchR;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;-1885.916,266.8046;Inherit;False;106;GlitchG;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;111;-1974.063,1129.576;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;74;-1378.833,846.2776;Inherit;False;Property;_Glitchlerp;Glitch lerp;11;0;Create;True;0;0;0;False;0;False;0.735;0.735;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;-1690,947.2587;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-1689.462,272.0005;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;829.2664,922.7081;Inherit;False;InstancedProperty;_Glitchintensity;Glitch intensity;10;1;[PerRendererData];Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-1625.304,758.7104;Inherit;False;Property;_AddV01;Add V 01;17;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-1069.932,1414.906;Inherit;False;Property;_AddU02;Add U 02;21;0;Create;True;0;0;0;False;0;False;0;0.075;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;88;-1066.693,591.0815;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;71;-1243.337,273.3649;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;114;-1243.875,948.6232;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-1931.396,734.2234;Inherit;False;Property;_AddU01;Add U 01;16;0;Create;True;0;0;0;False;0;False;0;0.1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;115;-1067.23,1266.339;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-1369.697,1439.392;Inherit;False;Property;_AddV02;Add V 02;22;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;1229.215,750.8175;Inherit;False;GlitchIntensity;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;116;-977.0204,1126.197;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;91;-985.212,737.9811;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;72;-976.4834,450.9388;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;96;-578.0447,1419.751;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;128;-526.0757,112.0154;Inherit;False;126;GlitchIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;90;-453.3551,467.2768;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;93;-422.5723,1124.217;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;131;-593.6987,-258.3466;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FloorOpNode;129;-346.6771,88.64832;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;125;-341.4207,192.3601;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;130;-217.4771,-97.65169;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;55;-1159.663,-8.528683;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;False;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.StaticSwitch;144;1.579882,-238.0951;Inherit;False;Property;_Glitch;Glitch ?;2;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Reference;136;True;True;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;5;189.9951,1.113269;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;156;-43.17879,-604.1005;Inherit;False;Constant;_test;test;21;0;Create;True;0;0;0;False;0;False;0.6;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;157;311.4859,-616.1246;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;159;426.6383,-601.7085;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;150;152.1857,-773.752;Inherit;False;Property;_AlphaReflect;Alpha Reflect;24;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;160;-101.9624,116.8861;Inherit;False;Property;_AlphaBase;Alpha Base;25;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;89;-53.48715,558.7178;Inherit;True;Property;_TextureSample3;Texture Sample 3;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;56;-52.71115,325.8878;Inherit;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;84;1281.918,580.0738;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;638.0396,-788.9986;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;161;701.6487,104.1135;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;127;1147.036,369.5757;Inherit;False;126;GlitchIntensity;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;85;1462.991,586.192;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;171;863.4057,-807.9701;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;123;1790.96,378.3361;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;167;1078.579,-808.8236;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;148;1222.764,-814.117;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;145;2181.101,476.9554;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;138;2422.017,448.9006;Inherit;False;Property;_Glitch;Glitch ?;2;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;136;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;140;2510.457,696.6798;Inherit;False;Property;_AlphaGlobal;Alpha Global;23;1;[Header];Create;True;1;Alpha;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;2851.38,464.7147;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;164;1937.724,-1269.824;Inherit;False;Property;_ColorMult;Color Mult;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;136;2385.78,-945.665;Inherit;False;Property;_Glitch;Glitch ?;2;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;172;1614.992,-555.3676;Inherit;False;106;GlitchG;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;1168.755,195.683;Inherit;False;107;GlitchR;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;118;1167.555,108.736;Inherit;False;106;GlitchG;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;87;1171.885,-17.80161;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;98;335.5494,646.2086;Inherit;False;Property;_Color02;Color 02;20;0;Create;True;0;0;0;False;0;False;0,1,0,0;0,1,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;137;1676.441,-895.7117;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;133;1363.649,-874.5682;Inherit;False;108;GlitchB;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;119;1541.399,12.96731;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;132;2114.278,-598.3796;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;166;2253.203,-1243.236;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CeilOpNode;124;1544.863,154.9907;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;169;1947.395,-921.5592;Inherit;False;3;0;COLOR;1,1,1,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;2319.866,-81.22937;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;53;336.8025,393.9113;Inherit;False;Property;_Color01;Color 01;15;0;Create;True;0;0;0;False;0;False;1,0,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;121;1951.655,-243.1576;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;108;-1849.272,47.85111;Inherit;False;GlitchB;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;141;3093.885,469.0135;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;104;968.6479,600.8384;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;97;707.9338,564.1082;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;152;2873.369,-156.3183;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;147;1558.077,-411.5878;Inherit;False;Property;_AlphaGlitch;Alpha Glitch;26;0;Create;True;0;0;0;False;0;False;1;0.682;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;700.6972,328.7428;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;3294.425,116.6119;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;M_TextGlitch;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Overlay=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;1;  Use Shadow Threshold;0;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;DOTS Instancing;0;Meta Pass;0;Extra Pre Pass;0;Tessellation;0;  Phong;0;  Strength;0.5,False,-1;  Type;0;  Tess;16,False,-1;  Min;10,False,-1;  Max;25,False,-1;  Edge Length;16,False,-1;  Max Displacement;25,False,-1;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;570.9951,7.613269;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;False;False;False;False;0;False;-1;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;143;17;62;0
WireConnection;143;18;63;0
WireConnection;143;19;59;0
WireConnection;143;20;60;0
WireConnection;143;21;61;0
WireConnection;107;0;143;0
WireConnection;106;0;143;15
WireConnection;112;0;117;0
WireConnection;112;1;111;1
WireConnection;70;0;105;0
WireConnection;70;1;69;1
WireConnection;88;0;74;0
WireConnection;71;0;70;0
WireConnection;71;1;69;2
WireConnection;114;0;112;0
WireConnection;114;1;111;2
WireConnection;115;0;74;0
WireConnection;126;0;122;0
WireConnection;116;0;111;0
WireConnection;116;1;114;0
WireConnection;116;2;115;0
WireConnection;91;0;81;0
WireConnection;91;1;82;0
WireConnection;72;0;69;0
WireConnection;72;1;71;0
WireConnection;72;2;88;0
WireConnection;96;0;94;0
WireConnection;96;1;95;0
WireConnection;90;0;72;0
WireConnection;90;1;91;0
WireConnection;93;0;116;0
WireConnection;93;1;96;0
WireConnection;129;0;128;0
WireConnection;125;0;90;0
WireConnection;125;1;93;0
WireConnection;130;0;131;0
WireConnection;130;1;125;0
WireConnection;130;2;129;0
WireConnection;144;1;131;0
WireConnection;144;0;130;0
WireConnection;5;0;55;0
WireConnection;5;1;144;0
WireConnection;157;0;5;1
WireConnection;157;1;156;0
WireConnection;159;0;157;0
WireConnection;89;0;55;0
WireConnection;89;1;93;0
WireConnection;56;0;55;0
WireConnection;56;1;90;0
WireConnection;84;0;56;4
WireConnection;84;1;89;4
WireConnection;149;0;159;0
WireConnection;149;1;150;0
WireConnection;161;0;5;4
WireConnection;161;1;160;0
WireConnection;85;0;84;0
WireConnection;171;0;161;0
WireConnection;171;1;149;0
WireConnection;171;2;159;0
WireConnection;123;0;5;4
WireConnection;123;1;85;0
WireConnection;123;2;127;0
WireConnection;167;0;171;0
WireConnection;167;1;5;4
WireConnection;148;0;167;0
WireConnection;145;0;123;0
WireConnection;138;1;148;0
WireConnection;138;0;145;0
WireConnection;139;0;138;0
WireConnection;139;1;140;0
WireConnection;136;1;166;0
WireConnection;136;0;132;0
WireConnection;87;0;104;0
WireConnection;87;1;5;0
WireConnection;87;2;148;0
WireConnection;137;0;5;0
WireConnection;137;1;133;0
WireConnection;119;0;87;0
WireConnection;119;1;118;0
WireConnection;119;2;120;0
WireConnection;132;0;121;0
WireConnection;132;1;133;0
WireConnection;132;2;172;0
WireConnection;166;0;164;0
WireConnection;166;1;169;0
WireConnection;124;0;127;0
WireConnection;169;1;137;0
WireConnection;169;2;147;0
WireConnection;168;0;5;0
WireConnection;168;1;164;0
WireConnection;121;0;5;0
WireConnection;121;1;119;0
WireConnection;121;2;124;0
WireConnection;108;0;143;16
WireConnection;141;0;139;0
WireConnection;104;0;52;0
WireConnection;104;1;97;0
WireConnection;104;2;89;4
WireConnection;97;0;89;0
WireConnection;97;1;98;0
WireConnection;152;0;168;0
WireConnection;152;1;136;0
WireConnection;152;2;147;0
WireConnection;52;0;56;0
WireConnection;52;1;53;0
WireConnection;1;2;152;0
WireConnection;1;3;141;0
ASEEND*/
//CHKSM=A291F132C861739CA7B35416B25E8154BFBB0802