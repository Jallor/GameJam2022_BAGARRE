// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_BorderShader"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[ASEBegin]_MainTex("_MainTex", 2D) = "white" {}
		[Header(Global)]_propagation("propagation", Range( 0 , 20)) = 0
		_Y_Offset("Y_Offset", Range( -4 , 4)) = -1.2
		[Header(VALUE 01)]_1color("1 - color", Color) = (1,0,0.1665177,0)
		_1emissiveintensity("1 - emissive intensity", Range( 0 , 25)) = 6
		_1radius("1 - radius", Range( 0 , 20)) = 2
		_1Y_Offset("1 - Y_Offset", Range( -4 , 4)) = -1.2
		[Header(VALUE 01)]_2color("2 - color", Color) = (0,0.5176471,1,0)
		_2emissiveintensity("2 - emissive intensity", Range( 0 , 25)) = 2
		_Float1("Float 1", Float) = 0
		[ASEEnd]_dissolve_Structure1("*5-visible_Structure ?", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

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

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull Off
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
			#define _RECEIVE_SHADOWS_OFF 1
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
			float4 _2color;
			float4 _1color;
			float _Y_Offset;
			float _propagation;
			float _1Y_Offset;
			float _1radius;
			float _Float1;
			float _2emissiveintensity;
			float _1emissiveintensity;
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
			float3 _PlayerPosition;
			sampler2D _interactionRT;
			float4 _interactionCameraPos;
			float _environmentInteractionCaptureSize;
			UNITY_INSTANCING_BUFFER_START(M_BorderShader)
				UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float, _dissolve_Structure1)
			UNITY_INSTANCING_BUFFER_END(M_BorderShader)


						
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
				float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(M_BorderShader,_MainTex_ST);
				float2 uv_MainTex = IN.ase_texcoord3.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
				float3 PLAYERPOS8 = _PlayerPosition;
				float3 break3_g572 = PLAYERPOS8;
				float4 appendResult2_g572 = (float4(( break3_g572.x + 0.0 ) , ( break3_g572.y + _Y_Offset ) , ( break3_g572.z + 0.0 ) , 0.0));
				float3 break9_g573 = appendResult2_g572.xyz;
				float2 appendResult2_g573 = (float2(break9_g573.x , break9_g573.y));
				float2 appendResult5_g573 = (float2(WorldPosition.x , WorldPosition.y));
				float WorldPos12 = distance( appendResult2_g573 , appendResult5_g573 );
				float3 temp_cast_1 = (WorldPos12).xxx;
				float SCAN_Radius5_g575 = saturate( ( temp_cast_1 / _propagation ).x );
				float saferPower30 = max( SCAN_Radius5_g575 , 0.0001 );
				float smoothstepResult24 = smoothstep( 0.3 , 1.0 , (1.0 + (pow( saferPower30 , 2.0 ) - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)));
				float temp_output_16_0 = saturate( ( tex2D( _MainTex, uv_MainTex ).a * smoothstepResult24 ) );
				float3 temp_cast_2 = (temp_output_16_0).xxx;
				float3 saferPower14_g593 = max( temp_cast_2 , 0.0001 );
				float3 temp_cast_3 = (1.0).xxx;
				float3 temp_output_15_0_g593 = saturate( pow( saferPower14_g593 , temp_cast_3 ) );
				float3 break3_g591 = PLAYERPOS8;
				float4 appendResult2_g591 = (float4(( break3_g591.x + 0.0 ) , ( break3_g591.y + _1Y_Offset ) , ( break3_g591.z + 0.0 ) , 0.0));
				float3 break9_g592 = appendResult2_g591.xyz;
				float2 appendResult2_g592 = (float2(break9_g592.x , break9_g592.y));
				float2 appendResult5_g592 = (float2(WorldPosition.x , WorldPosition.y));
				float3 temp_cast_6 = (distance( appendResult2_g592 , appendResult5_g592 )).xxx;
				float SCAN_Radius5_g589 = saturate( ( temp_cast_6 / _1radius ).x );
				float saferPower48 = max( SCAN_Radius5_g589 , 0.0001 );
				float smoothstepResult50 = smoothstep( 0.3 , 1.0 , (1.0 + (pow( saferPower48 , 2.0 ) - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)));
				float saferPower41 = max( smoothstepResult50 , 0.0001 );
				float temp_output_41_0 = pow( saferPower41 , 50.0 );
				float4 lerpResult37 = lerp( _2color , _1color , saturate( ( temp_output_41_0 * _Float1 ) ));
				float lerpResult51 = lerp( _2emissiveintensity , _1emissiveintensity , temp_output_41_0);
				
				float2 _Vector0 = float2(1,1);
				float2 appendResult1_g587 = (float2(WorldPosition.x , WorldPosition.y));
				float2 appendResult4_g587 = (float2(_interactionCameraPos.x , _interactionCameraPos.y));
				float2 appendResult7_g587 = (float2(_environmentInteractionCaptureSize , _environmentInteractionCaptureSize));
				float RT_G_channel58 = tex2D( _interactionRT, ( _Vector0 * ( ( ( appendResult1_g587 - appendResult4_g587 ) + ( appendResult7_g587 * _Vector0 ) ) / ( _environmentInteractionCaptureSize * 2.0 ) ) ) ).g;
				float lerpResult68 = lerp( temp_output_16_0 , 0.0 , saturate( pow( ( RT_G_channel58 * ( 1.0 - -15.0 ) ) , 1.3 ) ));
				float _dissolve_Structure1_Instance = UNITY_ACCESS_INSTANCED_PROP(M_BorderShader,_dissolve_Structure1);
				float lerpResult76 = lerp( lerpResult68 , temp_output_16_0 , _dissolve_Structure1_Instance);
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( float4( temp_output_15_0_g593 , 0.0 ) * lerpResult37 ) * lerpResult51 ).rgb;
				float Alpha = saturate( lerpResult76 );
				float AlphaClipThreshold = 0.1;
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
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			#define _RECEIVE_SHADOWS_OFF 1
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
			float4 _2color;
			float4 _1color;
			float _Y_Offset;
			float _propagation;
			float _1Y_Offset;
			float _1radius;
			float _Float1;
			float _2emissiveintensity;
			float _1emissiveintensity;
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
			float3 _PlayerPosition;
			sampler2D _interactionRT;
			float4 _interactionCameraPos;
			float _environmentInteractionCaptureSize;
			UNITY_INSTANCING_BUFFER_START(M_BorderShader)
				UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
				UNITY_DEFINE_INSTANCED_PROP(float, _dissolve_Structure1)
			UNITY_INSTANCING_BUFFER_END(M_BorderShader)


			
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

				float4 _MainTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(M_BorderShader,_MainTex_ST);
				float2 uv_MainTex = IN.ase_texcoord2.xy * _MainTex_ST_Instance.xy + _MainTex_ST_Instance.zw;
				float3 PLAYERPOS8 = _PlayerPosition;
				float3 break3_g572 = PLAYERPOS8;
				float4 appendResult2_g572 = (float4(( break3_g572.x + 0.0 ) , ( break3_g572.y + _Y_Offset ) , ( break3_g572.z + 0.0 ) , 0.0));
				float3 break9_g573 = appendResult2_g572.xyz;
				float2 appendResult2_g573 = (float2(break9_g573.x , break9_g573.y));
				float2 appendResult5_g573 = (float2(WorldPosition.x , WorldPosition.y));
				float WorldPos12 = distance( appendResult2_g573 , appendResult5_g573 );
				float3 temp_cast_1 = (WorldPos12).xxx;
				float SCAN_Radius5_g575 = saturate( ( temp_cast_1 / _propagation ).x );
				float saferPower30 = max( SCAN_Radius5_g575 , 0.0001 );
				float smoothstepResult24 = smoothstep( 0.3 , 1.0 , (1.0 + (pow( saferPower30 , 2.0 ) - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)));
				float temp_output_16_0 = saturate( ( tex2D( _MainTex, uv_MainTex ).a * smoothstepResult24 ) );
				float2 _Vector0 = float2(1,1);
				float2 appendResult1_g587 = (float2(WorldPosition.x , WorldPosition.y));
				float2 appendResult4_g587 = (float2(_interactionCameraPos.x , _interactionCameraPos.y));
				float2 appendResult7_g587 = (float2(_environmentInteractionCaptureSize , _environmentInteractionCaptureSize));
				float RT_G_channel58 = tex2D( _interactionRT, ( _Vector0 * ( ( ( appendResult1_g587 - appendResult4_g587 ) + ( appendResult7_g587 * _Vector0 ) ) / ( _environmentInteractionCaptureSize * 2.0 ) ) ) ).g;
				float lerpResult68 = lerp( temp_output_16_0 , 0.0 , saturate( pow( ( RT_G_channel58 * ( 1.0 - -15.0 ) ) , 1.3 ) ));
				float _dissolve_Structure1_Instance = UNITY_ACCESS_INSTANCED_PROP(M_BorderShader,_dissolve_Structure1);
				float lerpResult76 = lerp( lerpResult68 , temp_output_16_0 , _dissolve_Structure1_Instance);
				
				float Alpha = saturate( lerpResult76 );
				float AlphaClipThreshold = 0.1;

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
-1768;0;1768;931;-763.8014;576.6418;1.48033;True;False
Node;AmplifyShaderEditor.CommentaryNode;6;-2255.41,-128.6463;Inherit;False;636.2307;633.3192;;2;8;7;VAR - Get World Pos;1,0.5,0.9176471,1;0;0
Node;AmplifyShaderEditor.Vector3Node;7;-2206.633,84.20561;Inherit;False;Global;_PlayerPosition;_PlayerPosition;19;0;Create;True;0;0;0;False;0;False;0,0,0;0,-9.19946,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;5;-1488.916,-126.7494;Inherit;False;1788.152;632.2553;;14;15;14;12;11;10;9;4;3;2;0;27;30;31;53;Get World Pos + Offset;1,0.5,0.9176471,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-1864.896,85.47868;Inherit;False;PLAYERPOS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;10;-1456.693,346.4337;Inherit;False;8;PLAYERPOS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1304.366,177.0407;Inherit;False;Property;_Y_Offset;Y_Offset;4;0;Create;True;0;0;0;False;0;False;-1.2;1;-4;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;9;-1042.804,15.70268;Inherit;False;MF_GetPosWordToUV_and_Offset;-1;;572;88a5cd5b8bdc0aa4f8359e1a313a7837;0;4;9;FLOAT3;0,0,0;False;13;FLOAT;0;False;10;FLOAT;0;False;14;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;-587.3586,11.54558;Inherit;False;WorldPos;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-677.2043,223.6074;Inherit;False;Property;_propagation;propagation;3;1;[Header];Create;True;1;Global;0;0;False;0;False;0;4.2;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;14;-383.9524,89.12434;Inherit;False;MF_RadiusWorldPos;0;;575;7bbbddb5cca01274c8a2d2bacb9ca244;0;2;19;FLOAT3;0,0,0;False;16;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-291.1458,243.223;Inherit;False;Constant;_2propagation;2 - propagation;7;1;[Header];Create;True;1;VALUE 02;0;0;False;0;False;2;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;54;-2264.597,-1024.579;Inherit;False;1018.784;395.0092;Comment;4;58;57;56;55;RT;1,0.5019608,0.9176471,1;0;0
Node;AmplifyShaderEditor.TexturePropertyNode;55;-2133.131,-974.5782;Float;True;Global;_interactionRT;_interactionRT;11;0;Create;False;0;0;0;False;0;False;4f2d2a870ee9daa44bf761e06019ee54;4f2d2a870ee9daa44bf761e06019ee54;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;56;-2172.208,-785.8292;Inherit;False;MF_RT_InteractiveEnvironmentUVs;-1;;587;1f54e1dca3031bf4184027e8134d7360;0;0;1;FLOAT2;17
Node;AmplifyShaderEditor.PowerNode;30;-59.68795,90.0756;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;57;-1837.525,-974.5252;Inherit;True;Property;_TextureSample3;Texture Sample 3;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;25;608.6909,238.2279;Inherit;False;Constant;_Min;Min;6;0;Create;True;0;0;0;False;0;False;0.3;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;27;133.178,89.04678;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;486.8539,147.6072;Inherit;False;Constant;_Max;Max;6;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;17;-268.6912,-355.0329;Inherit;True;Property;_MainTex;_MainTex;2;0;Create;False;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SmoothstepOpNode;24;951.9247,104.819;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;-1460.825,-863.2672;Inherit;False;RT_G_channel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;18;35.14856,-355.9229;Inherit;True;Property;_TextureSample0;Texture Sample 0;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;1192.773,-256.4469;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;692.9099,902.5853;Inherit;False;Constant;_Float0;Float 0;12;0;Create;True;0;0;0;False;0;False;-15;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;898.2661,940.9175;Inherit;False;Constant;_LVL_00_powerFULLEMPTY;LVL_00_power [FULL EMPTY];6;0;Create;True;0;0;0;False;0;False;1.3;25;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;1210.85,893.4482;Inherit;False;58;RT_G_channel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;70;1558.004,897.9121;Inherit;False;MF_Dissolve;-1;;588;4cf975892ccec4f448d1402993968409;0;3;5;FLOAT;0;False;6;FLOAT;0;False;8;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;16;1333.987,194.6561;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;2039.249,521.6116;Inherit;False;InstancedProperty;_dissolve_Structure1;*5-visible_Structure ?;13;0;Create;False;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;68;2140.507,195.3661;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;76;2415.06,394.3942;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;2328.664,-777.0307;Inherit;False;Constant;_tresh;tresh;7;0;Create;True;0;0;0;False;0;False;0.1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;32;1650.863,-825.5688;Inherit;False;MF_Emissive_handler;-1;;593;4c2d144224f39b24a93af8da62996f6d;0;4;11;FLOAT3;0,0,0;False;9;COLOR;0,0,0,0;False;10;FLOAT;0;False;12;FLOAT;1;False;2;COLOR;0;FLOAT3;13
Node;AmplifyShaderEditor.SmoothstepOpNode;50;888.0883,527.417;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-575.709,408.4554;Inherit;False;Property;_1radius;1 - radius;7;0;Create;True;0;0;0;False;0;False;2;7.3;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;49;127.823,532.4672;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;525.0706,-374.937;Inherit;False;Property;_1emissiveintensity;1 - emissive intensity;6;0;Create;True;0;0;0;False;0;False;6;4;0;25;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;47;-387.0506,533.8853;Inherit;False;MF_RadiusWorldPos;0;;589;7bbbddb5cca01274c8a2d2bacb9ca244;0;2;19;FLOAT3;0,0,0;False;16;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;41;581.3801,-585.8961;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-1373.755,577.2987;Inherit;False;Property;_1Y_Offset;1 - Y_Offset;8;0;Create;True;0;0;0;False;0;False;-1.2;3.07;-4;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;44;-996.289,533.022;Inherit;False;MF_GetPosWordToUV_and_Offset;-1;;591;88a5cd5b8bdc0aa4f8359e1a313a7837;0;4;9;FLOAT3;0,0,0;False;13;FLOAT;0;False;10;FLOAT;0;False;14;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;532.755,-454.1148;Inherit;False;Property;_2emissiveintensity;2 - emissive intensity;10;0;Create;True;0;0;0;False;0;False;2;5;0;25;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;73;1093.814,-912.6007;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;48;-61.65102,536.3535;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;33;-252.2268,-793.592;Inherit;False;Property;_2color;2 - color;9;1;[Header];Create;True;1;VALUE 01;0;0;False;0;False;0,0.5176471,1,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;36;-253.5288,-614.3085;Inherit;False;Property;_1color;1 - color;5;1;[Header];Create;True;1;VALUE 01;0;0;False;0;False;1,0,0.1665177,0;0,0.682353,0.8000001,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;963.1027,-636.8456;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;51;1045.94,-468.5247;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;67;2659.523,197.4037;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;37;1288.369,-841.2569;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;75;844.8719,-557.5779;Inherit;False;Property;_Float1;Float 1;12;0;Create;True;0;0;0;False;0;False;0;2000;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;248.2698,-561.0665;Inherit;False;Constant;_2dividepropagation;2 - divide propagation;9;0;Create;True;0;0;0;False;0;False;50;1;0;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;False;False;False;False;0;False;-1;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;3033.78,-831.2115;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;M_BorderShader;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;True;0;False;-1;True;2;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;  Blend;0;Two Sided;0;Cast Shadows;0;  Use Shadow Threshold;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;DOTS Instancing;0;Meta Pass;0;Extra Pre Pass;0;Tessellation;0;  Phong;0;  Strength;0.5,False,-1;  Type;0;  Tess;16,False,-1;  Min;10,False,-1;  Max;25,False,-1;  Edge Length;16,False,-1;  Max Displacement;25,False,-1;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;False;True;False;False;;False;0
WireConnection;8;0;7;0
WireConnection;9;9;10;0
WireConnection;9;10;11;0
WireConnection;12;0;9;0
WireConnection;14;19;12;0
WireConnection;14;16;15;0
WireConnection;30;0;14;0
WireConnection;30;1;31;0
WireConnection;57;0;55;0
WireConnection;57;1;56;17
WireConnection;27;0;30;0
WireConnection;24;0;27;0
WireConnection;24;1;25;0
WireConnection;24;2;26;0
WireConnection;58;0;57;2
WireConnection;18;0;17;0
WireConnection;28;0;18;4
WireConnection;28;1;24;0
WireConnection;70;5;69;0
WireConnection;70;6;64;0
WireConnection;70;8;71;0
WireConnection;16;0;28;0
WireConnection;68;0;16;0
WireConnection;68;2;70;0
WireConnection;76;0;68;0
WireConnection;76;1;16;0
WireConnection;76;2;77;0
WireConnection;32;11;16;0
WireConnection;32;9;37;0
WireConnection;32;10;51;0
WireConnection;50;0;49;0
WireConnection;50;1;25;0
WireConnection;50;2;26;0
WireConnection;49;0;48;0
WireConnection;47;19;44;0
WireConnection;47;16;53;0
WireConnection;41;0;50;0
WireConnection;41;1;42;0
WireConnection;44;9;10;0
WireConnection;44;10;45;0
WireConnection;73;0;74;0
WireConnection;48;0;47;0
WireConnection;48;1;31;0
WireConnection;74;0;41;0
WireConnection;74;1;75;0
WireConnection;51;0;34;0
WireConnection;51;1;52;0
WireConnection;51;2;41;0
WireConnection;67;0;76;0
WireConnection;37;0;33;0
WireConnection;37;1;36;0
WireConnection;37;2;73;0
WireConnection;1;2;32;0
WireConnection;1;3;67;0
WireConnection;1;4;19;0
ASEEND*/
//CHKSM=CEE8B7C50C2D763364159A3B74C0A98C744BA2B6