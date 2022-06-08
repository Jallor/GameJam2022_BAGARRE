// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_Outliner"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[ASEBegin]_MainTex("_MainTex", 2D) = "white" {}
		_TX_Distort("_TX_Distort", 2D) = "white" {}
		_00color_base("00 - color_base", Color) = (0.8018868,0.6985526,0.2609915,0)
		_01emissive_color("01 - emissive_color", Color) = (0.03529429,1,0,0)
		_01emissive_int("01 - emissive_int", Range( 0 , 10)) = 1
		_02PlayerPos_radius("02 - PlayerPos_radius", Float) = 0
		_02PlayerPos_Hardness("02 - PlayerPos_Hardness", Float) = 0
		_03emissive_color("03 - emissive_color", Color) = (0,0.8746934,1,0)
		_ColorPiece("Color Piece", Color) = (1,0.8377492,0,0)
		_03emissive_int("03 - emissive_int", Range( 0 , 10)) = 1
		_Hasbeentouched("_Hasbeentouched", Range( 0 , 1)) = 0
		_Isattract("_Isattract", Range( 0 , 1)) = 0
		[ASEEnd]_TX_VFX_Reflect("TX_VFX_Reflect", 2D) = "white" {}

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

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="TransparentCutout" "Queue"="Transparent" }
		
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

			#define ASE_NEEDS_FRAG_WORLD_POSITION


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
			float4 _00color_base;
			float4 _01emissive_color;
			float4 _ColorPiece;
			float4 _03emissive_color;
			float _Isattract;
			float _01emissive_int;
			float _03emissive_int;
			float _Hasbeentouched;
			float _02PlayerPos_radius;
			float _02PlayerPos_Hardness;
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
			sampler2D _TX_Distort;
			sampler2D _TX_VFX_Reflect;
			float3 _PlayerPosition;
			UNITY_INSTANCING_BUFFER_START(M_Outliner)
			UNITY_INSTANCING_BUFFER_END(M_Outliner)


						
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
				float2 texCoord292 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult4_g1 = (float2(0.25 , 1.5));
				float2 texCoord309 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_18_0_g1 = 0.5;
				float2 appendResult16_g1 = (float2(temp_output_18_0_g1 , temp_output_18_0_g1));
				float2 panner6_g1 = ( _TimeParameters.x * appendResult4_g1 + ( texCoord309 * appendResult16_g1 ));
				float4 tex2DNode307 = tex2D( _TX_Distort, panner6_g1 );
				float2 appendResult308 = (float2(tex2DNode307.r , tex2DNode307.r));
				float temp_output_325_0 = ( _Isattract / 2.0 );
				float2 lerpResult311 = lerp( texCoord292 , ( texCoord292 * appendResult308 ) , temp_output_325_0);
				float temp_output_300_0 = (1.0 + (_Isattract - 0.0) * (3.0 - 1.0) / (1.0 - 0.0));
				float2 _Vector0 = float2(-1,-1);
				float2 lerpResult322 = lerp( _Vector0 , ( _Vector0 + float2( 0.5,0.5 ) ) , (0.0 + (temp_output_325_0 - 0.0) * (1.0 - 0.0) / (0.5 - 0.0)));
				float2 lerpResult296 = lerp( float2( 0,0 ) , lerpResult322 , (0.0 + (temp_output_300_0 - 1.0) * (1.0 - 0.0) / (3.0 - 1.0)));
				float4 tex2DNode5 = tex2D( _MainTex, (lerpResult311*temp_output_300_0 + lerpResult296) );
				float R139 = tex2DNode5.r;
				float _IsAttract336 = _Isattract;
				float temp_output_341_0 = (0.0 + (_IsAttract336 - 0.3) * (1.0 - 0.0) / (0.6 - 0.3));
				float REMAPAttract362 = temp_output_341_0;
				float4 lerpResult366 = lerp( _01emissive_color , _ColorPiece , REMAPAttract362);
				float4 emissive_color_01142 = lerpResult366;
				float4 temp_output_265_0 = ( emissive_color_01142 * _01emissive_int );
				float G164 = tex2DNode5.g;
				float4 lerpResult253 = lerp( ( R139 * _00color_base ) , temp_output_265_0 , G164);
				float4 lerpResult364 = lerp( _03emissive_color , _ColorPiece , REMAPAttract362);
				float4 emissive_color_02183 = lerpResult364;
				float4 lerpResult263 = lerp( ( emissive_color_02183 * _03emissive_int ) , emissive_color_01142 , G164);
				float4 lerpResult257 = lerp( lerpResult253 , lerpResult263 , _Hasbeentouched);
				float2 appendResult284 = (float2(_PlayerPosition.x , _PlayerPosition.y));
				float3 temp_output_5_0_g357 = ( ( WorldPosition - float3( appendResult284 ,  0.0 ) ) / _02PlayerPos_radius );
				float dotResult8_g357 = dot( temp_output_5_0_g357 , temp_output_5_0_g357 );
				float PLAYERPOS235 = saturate( pow( saturate( dotResult8_g357 ) , _02PlayerPos_Hardness ) );
				float2 lerpResult333 = lerp( float2( 0.8,0.1 ) , float2( -0.7,-0.1 ) , PLAYERPOS235);
				float2 texCoord330 = IN.ase_texcoord3.xy * float2( 1,1 ) + lerpResult333;
				
				float A146 = tex2DNode5.a;
				float lerpResult353 = lerp( saturate( A146 ) , 0.0 , (0.0 + (_IsAttract336 - ( 0.3 / 2.0 )) * (1.0 - 0.0) / (0.6 - ( 0.3 / 2.0 ))));
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( lerpResult257 + ( tex2D( _TX_VFX_Reflect, texCoord330 ).a * temp_output_265_0 ) ).rgb;
				float Alpha = saturate( lerpResult353 );
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
			float4 _00color_base;
			float4 _01emissive_color;
			float4 _ColorPiece;
			float4 _03emissive_color;
			float _Isattract;
			float _01emissive_int;
			float _03emissive_int;
			float _Hasbeentouched;
			float _02PlayerPos_radius;
			float _02PlayerPos_Hardness;
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
			sampler2D _TX_Distort;
			UNITY_INSTANCING_BUFFER_START(M_Outliner)
			UNITY_INSTANCING_BUFFER_END(M_Outliner)


			
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

				float2 texCoord292 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult4_g1 = (float2(0.25 , 1.5));
				float2 texCoord309 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_18_0_g1 = 0.5;
				float2 appendResult16_g1 = (float2(temp_output_18_0_g1 , temp_output_18_0_g1));
				float2 panner6_g1 = ( _TimeParameters.x * appendResult4_g1 + ( texCoord309 * appendResult16_g1 ));
				float4 tex2DNode307 = tex2D( _TX_Distort, panner6_g1 );
				float2 appendResult308 = (float2(tex2DNode307.r , tex2DNode307.r));
				float temp_output_325_0 = ( _Isattract / 2.0 );
				float2 lerpResult311 = lerp( texCoord292 , ( texCoord292 * appendResult308 ) , temp_output_325_0);
				float temp_output_300_0 = (1.0 + (_Isattract - 0.0) * (3.0 - 1.0) / (1.0 - 0.0));
				float2 _Vector0 = float2(-1,-1);
				float2 lerpResult322 = lerp( _Vector0 , ( _Vector0 + float2( 0.5,0.5 ) ) , (0.0 + (temp_output_325_0 - 0.0) * (1.0 - 0.0) / (0.5 - 0.0)));
				float2 lerpResult296 = lerp( float2( 0,0 ) , lerpResult322 , (0.0 + (temp_output_300_0 - 1.0) * (1.0 - 0.0) / (3.0 - 1.0)));
				float4 tex2DNode5 = tex2D( _MainTex, (lerpResult311*temp_output_300_0 + lerpResult296) );
				float A146 = tex2DNode5.a;
				float _IsAttract336 = _Isattract;
				float lerpResult353 = lerp( saturate( A146 ) , 0.0 , (0.0 + (_IsAttract336 - ( 0.3 / 2.0 )) * (1.0 - 0.0) / (0.6 - ( 0.3 / 2.0 ))));
				
				float Alpha = saturate( lerpResult353 );
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
			float4 _00color_base;
			float4 _01emissive_color;
			float4 _ColorPiece;
			float4 _03emissive_color;
			float _Isattract;
			float _01emissive_int;
			float _03emissive_int;
			float _Hasbeentouched;
			float _02PlayerPos_radius;
			float _02PlayerPos_Hardness;
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
			sampler2D _TX_Distort;
			UNITY_INSTANCING_BUFFER_START(M_Outliner)
			UNITY_INSTANCING_BUFFER_END(M_Outliner)


			
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

				float2 texCoord292 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult4_g1 = (float2(0.25 , 1.5));
				float2 texCoord309 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_18_0_g1 = 0.5;
				float2 appendResult16_g1 = (float2(temp_output_18_0_g1 , temp_output_18_0_g1));
				float2 panner6_g1 = ( _TimeParameters.x * appendResult4_g1 + ( texCoord309 * appendResult16_g1 ));
				float4 tex2DNode307 = tex2D( _TX_Distort, panner6_g1 );
				float2 appendResult308 = (float2(tex2DNode307.r , tex2DNode307.r));
				float temp_output_325_0 = ( _Isattract / 2.0 );
				float2 lerpResult311 = lerp( texCoord292 , ( texCoord292 * appendResult308 ) , temp_output_325_0);
				float temp_output_300_0 = (1.0 + (_Isattract - 0.0) * (3.0 - 1.0) / (1.0 - 0.0));
				float2 _Vector0 = float2(-1,-1);
				float2 lerpResult322 = lerp( _Vector0 , ( _Vector0 + float2( 0.5,0.5 ) ) , (0.0 + (temp_output_325_0 - 0.0) * (1.0 - 0.0) / (0.5 - 0.0)));
				float2 lerpResult296 = lerp( float2( 0,0 ) , lerpResult322 , (0.0 + (temp_output_300_0 - 1.0) * (1.0 - 0.0) / (3.0 - 1.0)));
				float4 tex2DNode5 = tex2D( _MainTex, (lerpResult311*temp_output_300_0 + lerpResult296) );
				float A146 = tex2DNode5.a;
				float _IsAttract336 = _Isattract;
				float lerpResult353 = lerp( saturate( A146 ) , 0.0 , (0.0 + (_IsAttract336 - ( 0.3 / 2.0 )) * (1.0 - 0.0) / (0.6 - ( 0.3 / 2.0 ))));
				
				float Alpha = saturate( lerpResult353 );
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
-1768;0;1768;931;-6266.336;-549.5492;1;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;309;2111.967,-299.0647;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;305;1997.53,-130.7771;Inherit;False;Constant;_SpeedY;Speed Y;17;0;Create;True;0;0;0;False;0;False;1.5;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;304;2174.53,-155.777;Inherit;False;Constant;_SpeedX;Speed X;16;0;Create;True;0;0;0;False;0;False;0.25;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;306;1875.53,-103.7771;Inherit;False;Constant;_TilesXY;Tiles XY;18;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;303;2398.23,-175.077;Inherit;False;MF_Tiles;-1;;1;2fa329d2d99691549897442d611b24f3;1,17,0;7;14;FLOAT2;0,0;False;7;FLOAT;0;False;8;FLOAT;0;False;10;FLOAT;1;False;18;FLOAT;1;False;13;FLOAT;1;False;11;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;298;1747.382,346.2813;Inherit;False;Property;_Isattract;_Isattract;16;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;294;2744.21,706.9583;Inherit;False;Constant;_Vector0;Vector 0;15;0;Create;True;0;0;0;False;0;False;-1,-1;-1,-1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;307;2663.086,-198.0491;Inherit;True;Property;_TX_Distort;_TX_Distort;2;0;Create;True;0;0;0;False;0;False;-1;None;2a81ea6a3e2e94843b47056dc9b6dd5c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;325;2363.044,592.4846;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;320;2798.346,990.8288;Inherit;False;Constant;_Vector1;Vector 1;15;0;Create;True;0;0;0;False;0;False;0.5,0.5;-1,-1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;292;2708.327,363.242;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;324;3151.918,579.1232;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;321;3090.346,971.8288;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;308;2993.583,-167.349;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;300;2426.427,376.5886;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;322;3332.327,919.9947;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;302;3311.623,86.6638;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;295;2512.986,803.849;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;3;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;311;3447.638,370.2854;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;296;3510.724,753.7993;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;291;3771.618,385.434;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;5;4133.289,338.7088;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;0;False;0;False;-1;1b292aeefba260a48a2d17ee27d3a11a;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;158;3627.025,959.3257;Inherit;False;1147.051;255.3057;Comment;2;147;123;ALPHA HANDLER;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;356;6991.907,890.9927;Inherit;False;Constant;_Float0;Float 0;18;0;Create;True;0;0;0;False;0;False;0.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;336;2044.865,306.029;Inherit;False;_IsAttract;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;146;4925.982,431.5075;Inherit;False;A;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;147;3726.344,1004.29;Inherit;False;146;A;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;361;6698.636,1018.155;Inherit;False;336;_IsAttract;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;358;7106.072,1141.083;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;360;7154.288,1267.756;Inherit;False;Constant;_Float1;Float 1;18;0;Create;True;0;0;0;False;0;False;0.6;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;357;7495.072,1124.083;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;123;4616.985,1010.859;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;353;7773.498,1109.068;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;159;1158.748,516.5011;Inherit;False;1016.719;630.1412;Comment;3;56;64;45;Emissive Flicking;1,0.85,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;161;-3725.106,-1531.377;Inherit;False;1034.59;1656.092;;9;183;142;8;182;195;342;364;365;366;VAR;0,1,0,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;265;5909.635,-498.0315;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;280;3806.388,-436.8123;Inherit;False;Property;_02PlayerPos_Hardness;02 - PlayerPos_Hardness;8;0;Create;True;0;0;0;False;0;False;0;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;257;7022.849,-174.7684;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;139;4719.181,358.1913;Inherit;False;R;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;250;4975.544,-748.4353;Inherit;False;139;R;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;326;7091.942,-1367.907;Inherit;True;Property;_TX_VFX_Reflect;TX_VFX_Reflect;18;0;Create;True;0;0;0;False;0;False;-1;f6f061d6d272a534cb72962408e29b22;f6f061d6d272a534cb72962408e29b22;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;341;7691.082,774.0133;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;334;5114.319,-1286.292;Inherit;False;Constant;_Vector2;Vector 2;18;0;Create;True;0;0;0;False;0;False;-0.7,-0.1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;338;5258.746,-1159.387;Inherit;False;235;PLAYERPOS;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;355;8396.255,1103.883;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;359;6691.281,874.2549;Inherit;False;Property;_Float2;Float 2;17;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;235;5049.565,-477.2242;Inherit;False;PLAYERPOS;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;164;4464.197,386.2319;Inherit;False;G;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;333;6090.389,-1297.49;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;363;4223.519,-1139.378;Inherit;False;362;REMAPAttract;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;343;5566.658,18.69674;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;258;5970.982,-245.5244;Inherit;False;183;emissive_color_02;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;362;7920.411,725.4314;Inherit;False;REMAPAttract;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;342;-3649.969,-556.2303;Inherit;False;Property;_ColorPiece;Color Piece;11;0;Create;True;0;0;0;False;0;False;1,0.8377492,0,0;1,0.794463,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;256;5176.03,-652.702;Inherit;False;Property;_00color_base;00 - color_base;3;0;Create;True;0;0;0;False;0;False;0.8018868,0.6985526,0.2609915,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;278;3727.088,-729.0126;Inherit;False;Global;_PlayerPosition;_PlayerPosition;19;0;Create;True;0;0;0;False;0;False;0,0,0;0,9.087746,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;345;6940.516,772.6232;Inherit;False;InstancedProperty;_Dissapear;Dissapear;1;0;Create;True;0;0;0;False;0;False;0;0.987;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;259;6678.2,163.3846;Inherit;False;Property;_Hasbeentouched;_Hasbeentouched;15;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;364;-3206.319,-86.71521;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;266;5514.184,-476.983;Inherit;False;Property;_01emissive_int;01 - emissive_int;5;0;Create;True;0;0;0;False;0;False;1;3;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;366;-3227.851,-433.7116;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;365;-3453.319,-235.7152;Inherit;False;362;REMAPAttract;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;181;1155.89,170.2217;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;1481.246,660.3596;Inherit;False;Constant;_flickemissive_max_int;flick - emissive_max_int;4;0;Create;True;0;0;0;False;0;False;2;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;279;4063.59,-461.7126;Inherit;False;Property;_02PlayerPos_radius;02 - PlayerPos_radius;7;0;Create;True;0;0;0;False;0;False;0;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;330;6421.67,-1345.369;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;281;6331.203,-335.1695;Inherit;False;235;PLAYERPOS;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;267;5879.485,28.86059;Inherit;False;Property;_03emissive_int;03 - emissive_int;12;0;Create;True;0;0;0;False;0;False;1;3.65;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;268;6219.569,-132.6031;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;283;4839.29,-472.6758;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;349;8562.798,131.0385;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;5;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;8;-3651.942,-317.7458;Inherit;False;Property;_01emissive_color;01 - emissive_color;4;0;Create;True;0;0;0;False;0;False;0.03529429,1,0,0;0.5663421,1,0.5518868,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;254;5557.746,-739.3204;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;263;6730.551,-154.5793;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;340;7131.165,-758.2094;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;64;1629.736,848.6188;Inherit;False;Property;_flickemissive_int;flick - emissive_int;6;0;Create;True;0;0;0;False;0;False;1;3.5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;264;6469.192,165.2013;Inherit;False;164;G;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;247;5703.499,-694.4339;Inherit;False;164;G;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;284;4158.089,-704.0756;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;253;6190.979,-735.9817;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;242;5566.208,-144.6363;Inherit;False;142;emissive_color_01;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;241;6736.482,-503.555;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;344;5229.907,10.06268;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;236;4505.521,-479.7222;Inherit;False;SphereMask;-1;;357;988803ee12caf5f4690caee3c8c4a5bb;0;3;15;FLOAT2;0,0;False;14;FLOAT;0;False;12;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;1765.659,641.6781;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;142;-3002.696,-316.8861;Inherit;False;emissive_color_01;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;350;8291.196,778.0639;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;183;-2962.289,-98.82426;Inherit;False;emissive_color_02;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;195;-3705.988,-1347.949;Inherit;False;Property;_multiplyemissive_global;03 - multiply emissive_global;13;0;Create;False;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;339;7530.982,-174.2511;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;351;8771.224,-8.364232;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;252;6028.544,279.4448;Inherit;False;Property;_lerp;lerp;14;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;335;5399.064,-1321.592;Inherit;False;Constant;_Vector3;Vector 3;18;0;Create;True;0;0;0;False;0;False;0.8,0.1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;182;-3647.028,-99.684;Inherit;False;Property;_03emissive_color;03 - emissive_color;10;0;Create;True;0;0;0;False;0;False;0,0.8746934,1,0;0,1,0.9717826,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;347;8230.3,151.2875;Inherit;False;Property;_EmissiveAttract;Emissive Attract;9;0;Create;True;0;0;0;False;0;False;3;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;39.18423,983.5934;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;False;False;False;False;0;False;-1;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;8899.214,1076.56;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;M_Outliner;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=TransparentCutout=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;1;  Use Shadow Threshold;0;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;DOTS Instancing;0;Meta Pass;0;Extra Pre Pass;0;Tessellation;0;  Phong;0;  Strength;0.5,False,-1;  Type;0;  Tess;16,False,-1;  Min;10,False,-1;  Max;25,False,-1;  Edge Length;16,False,-1;  Max Displacement;25,False,-1;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.CommentaryNode;220;-4143.18,350.0292;Inherit;False;587.281;657.495;;0;VAR - Color;1,0.5,0.9176471,1;0;0
WireConnection;303;14;309;0
WireConnection;303;7;304;0
WireConnection;303;8;305;0
WireConnection;303;18;306;0
WireConnection;307;1;303;0
WireConnection;325;0;298;0
WireConnection;324;0;325;0
WireConnection;321;0;294;0
WireConnection;321;1;320;0
WireConnection;308;0;307;1
WireConnection;308;1;307;1
WireConnection;300;0;298;0
WireConnection;322;0;294;0
WireConnection;322;1;321;0
WireConnection;322;2;324;0
WireConnection;302;0;292;0
WireConnection;302;1;308;0
WireConnection;295;0;300;0
WireConnection;311;0;292;0
WireConnection;311;1;302;0
WireConnection;311;2;325;0
WireConnection;296;1;322;0
WireConnection;296;2;295;0
WireConnection;291;0;311;0
WireConnection;291;1;300;0
WireConnection;291;2;296;0
WireConnection;5;1;291;0
WireConnection;336;0;298;0
WireConnection;146;0;5;4
WireConnection;358;0;356;0
WireConnection;357;0;361;0
WireConnection;357;1;358;0
WireConnection;357;2;360;0
WireConnection;123;0;147;0
WireConnection;353;0;123;0
WireConnection;353;2;357;0
WireConnection;265;0;242;0
WireConnection;265;1;266;0
WireConnection;257;0;253;0
WireConnection;257;1;263;0
WireConnection;257;2;259;0
WireConnection;139;0;5;1
WireConnection;326;1;330;0
WireConnection;341;0;361;0
WireConnection;341;1;356;0
WireConnection;341;2;360;0
WireConnection;355;0;353;0
WireConnection;235;0;283;0
WireConnection;164;0;5;2
WireConnection;333;0;335;0
WireConnection;333;1;334;0
WireConnection;333;2;338;0
WireConnection;343;0;256;0
WireConnection;343;1;342;0
WireConnection;343;2;344;0
WireConnection;362;0;341;0
WireConnection;364;0;182;0
WireConnection;364;1;342;0
WireConnection;364;2;365;0
WireConnection;366;0;8;0
WireConnection;366;1;342;0
WireConnection;366;2;365;0
WireConnection;330;1;333;0
WireConnection;268;0;258;0
WireConnection;268;1;267;0
WireConnection;283;0;236;0
WireConnection;349;1;347;0
WireConnection;349;2;350;0
WireConnection;254;0;250;0
WireConnection;254;1;256;0
WireConnection;263;0;268;0
WireConnection;263;1;242;0
WireConnection;263;2;264;0
WireConnection;340;0;326;4
WireConnection;340;1;265;0
WireConnection;284;0;278;1
WireConnection;284;1;278;2
WireConnection;253;0;254;0
WireConnection;253;1;265;0
WireConnection;253;2;247;0
WireConnection;241;0;265;0
WireConnection;241;2;281;0
WireConnection;344;0;341;0
WireConnection;236;15;284;0
WireConnection;236;14;279;0
WireConnection;236;12;280;0
WireConnection;56;1;45;0
WireConnection;142;0;366;0
WireConnection;350;0;341;0
WireConnection;183;0;364;0
WireConnection;339;0;257;0
WireConnection;339;1;340;0
WireConnection;351;0;343;0
WireConnection;351;1;349;0
WireConnection;1;2;339;0
WireConnection;1;3;355;0
ASEEND*/
//CHKSM=BCEEBA81CFE2CD90BD0E3CDCCB758FB80D5AD340