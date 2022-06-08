// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_Distance & Dissolve Shader"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		_MainTex("_MainTex", 2D) = "white" {}
		_Color_Back("Color_Back", Color) = (1,0.8352942,0.6078432,1)
		_Color_Front("Color_Front", Color) = (0.5686275,0.3294118,0.5921569,1)
		_color_MaxDist("color_MaxDist", Int) = 900
		_color_MinDist("color_MinDist", Int) = 750
		_MainRadius_size("MainRadius_size", Range( 0 , 10)) = 0
		_MainRadius_Sharpness("MainRadius_Sharpness", Range( 0 , 500)) = 0
		_GlobalRadius_Offset("GlobalRadius_Offset", Range( -10 , 10)) = 0
		_Texture_Dissolve_radius("Texture_Dissolve_radius", 2D) = "white" {}
		_Dissolve_size("Dissolve_size", Range( 0 , 1)) = 0
		_Dissolve_Sharpness("Dissolve_Sharpness", Range( 0 , 500)) = 0
		_Dissolve_01_Speed_Y("Dissolve_01_Speed_Y", Range( -15 , 15)) = 0
		_Dissolve_02_Speed_Y("Dissolve_02_Speed_Y", Range( -15 , 15)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
		
		Cull Back
		HLSLINCLUDE
		#pragma target 2.0
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend One Zero , One Zero
			ZWrite On
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
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _MainTex;
			float3 _PlayerPosition;
			sampler2D _Texture_Dissolve_radius;
			CBUFFER_START( UnityPerMaterial )
			float4 _Color_Front;
			float4 _Color_Back;
			int _color_MinDist;
			int _color_MaxDist;
			float4 _MainTex_ST;
			float _GlobalRadius_Offset;
			float _MainRadius_size;
			float _MainRadius_Sharpness;
			float _Dissolve_size;
			float _Dissolve_01_Speed_Y;
			float _Dissolve_02_Speed_Y;
			float _Dissolve_Sharpness;
			CBUFFER_END


			
			VertexOutput vert ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				
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
				float4 transform8 = mul(GetObjectToWorldMatrix(),float4( 0,0,0,1 ));
				float4 lerpResult11 = lerp( _Color_Front , _Color_Back , (0.0 + (distance( transform8.z , _WorldSpaceCameraPos.z ) - (float)_color_MinDist) * (1.0 - 0.0) / ((float)_color_MaxDist - (float)_color_MinDist)));
				
				float2 uv_MainTex = IN.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float3 break92 = WorldPosition;
				float2 appendResult93 = (float2(break92.x , break92.y));
				float3 break88 = _PlayerPosition;
				float2 appendResult91 = (float2(break88.x , ( break88.y + _GlobalRadius_Offset )));
				float temp_output_49_0 = ( distance( appendResult93 , appendResult91 ) / _MainRadius_size );
				float2 appendResult98 = (float2(0.0 , _Dissolve_01_Speed_Y));
				float4 screenPos = IN.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float4 break95 = ase_screenPosNorm;
				float2 appendResult96 = (float2(break95.x , break95.y));
				float2 panner97 = ( 1.0 * _Time.y * appendResult98 + appendResult96);
				float2 uv055 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult106 = (float2(0.0 , _Dissolve_02_Speed_Y));
				float2 panner105 = ( 1.0 * _Time.y * appendResult106 + appendResult96);
				float2 uv0108 = IN.ase_texcoord3.xy * float2( 0.5,0.5 ) + float2( 0,0 );
				float4 temp_cast_3 = (_Dissolve_Sharpness).xxxx;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult11.rgb;
				float Alpha = saturate( ( tex2D( _MainTex, uv_MainTex ).a * ( saturate( pow( temp_output_49_0 , _MainRadius_Sharpness ) ) * ( pow( ( temp_output_49_0 * _Dissolve_size ) , _MainRadius_Sharpness ) + pow( ( tex2D( _Texture_Dissolve_radius, ( panner97 + uv055 ) ) * tex2D( _Texture_Dissolve_radius, ( panner105 + uv0108 ) ) ) , temp_cast_3 ) ) ) ) ).r;
				float AlphaClipThreshold = 0.35;

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
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _MainTex;
			float3 _PlayerPosition;
			sampler2D _Texture_Dissolve_radius;
			CBUFFER_START( UnityPerMaterial )
			float4 _Color_Front;
			float4 _Color_Back;
			int _color_MinDist;
			int _color_MaxDist;
			float4 _MainTex_ST;
			float _GlobalRadius_Offset;
			float _MainRadius_size;
			float _MainRadius_Sharpness;
			float _Dissolve_size;
			float _Dissolve_01_Speed_Y;
			float _Dissolve_02_Speed_Y;
			float _Dissolve_Sharpness;
			CBUFFER_END


			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				
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

				float2 uv_MainTex = IN.ase_texcoord2.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float3 break92 = WorldPosition;
				float2 appendResult93 = (float2(break92.x , break92.y));
				float3 break88 = _PlayerPosition;
				float2 appendResult91 = (float2(break88.x , ( break88.y + _GlobalRadius_Offset )));
				float temp_output_49_0 = ( distance( appendResult93 , appendResult91 ) / _MainRadius_size );
				float2 appendResult98 = (float2(0.0 , _Dissolve_01_Speed_Y));
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float4 break95 = ase_screenPosNorm;
				float2 appendResult96 = (float2(break95.x , break95.y));
				float2 panner97 = ( 1.0 * _Time.y * appendResult98 + appendResult96);
				float2 uv055 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult106 = (float2(0.0 , _Dissolve_02_Speed_Y));
				float2 panner105 = ( 1.0 * _Time.y * appendResult106 + appendResult96);
				float2 uv0108 = IN.ase_texcoord2.xy * float2( 0.5,0.5 ) + float2( 0,0 );
				float4 temp_cast_0 = (_Dissolve_Sharpness).xxxx;
				
				float Alpha = saturate( ( tex2D( _MainTex, uv_MainTex ).a * ( saturate( pow( temp_output_49_0 , _MainRadius_Sharpness ) ) * ( pow( ( temp_output_49_0 * _Dissolve_size ) , _MainRadius_Sharpness ) + pow( ( tex2D( _Texture_Dissolve_radius, ( panner97 + uv055 ) ) * tex2D( _Texture_Dissolve_radius, ( panner105 + uv0108 ) ) ) , temp_cast_0 ) ) ) ) ).r;
				float AlphaClipThreshold = 0.35;

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
0;0;1280;659;6458.387;1873.768;8.132461;True;False
Node;AmplifyShaderEditor.CommentaryNode;111;-2247.112,1981.294;Inherit;False;2751.044;1257.466;Comment;18;99;98;55;97;109;61;72;101;106;105;107;100;53;58;95;96;108;104;Movement In Radius Limits;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;110;-1675.587,915.8388;Inherit;False;2467.488;745.1102;;19;49;69;63;70;66;85;46;90;48;88;92;91;50;47;86;84;79;93;89;Get Player Pos;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;58;-2197.112,2713.488;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;46;-1569.06,1468.803;Inherit;False;Global;_PlayerPosition;_PlayerPosition;5;0;Create;False;0;0;False;0;0,0,0;-35,0,5.2;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;104;-1278.139,2859.584;Inherit;False;Property;_Dissolve_02_Speed_Y;Dissolve_02_Speed_Y;12;0;Create;True;0;0;False;0;0;0;-15;15;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;99;-1261.121,2577.752;Inherit;False;Property;_Dissolve_01_Speed_Y;Dissolve_01_Speed_Y;11;0;Create;True;0;0;False;0;0;0;-15;15;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;90;-1328.777,1340.654;Inherit;False;Property;_GlobalRadius_Offset;GlobalRadius_Offset;7;0;Create;True;0;0;False;0;0;0;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;48;-1625.587,996.054;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;95;-1855.653,2721.939;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;88;-1292.321,1476.717;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;89;-1067.345,1321.02;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;106;-1035.307,2841.442;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;96;-1539.8,2728.119;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;98;-1039.792,2558.067;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;92;-1346.723,1091.993;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TextureCoordinatesNode;55;-817.4034,2314.906;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;108;-794.818,3079.759;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.5,0.5;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;105;-823.4774,2820.254;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;91;-979.6494,1497.811;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;93;-1032.981,1091.8;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;97;-833.3154,2533.559;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DistanceOpNode;47;-834.5536,1001.617;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;100;-483.9217,2286.061;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;107;-474.6133,2816.654;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-867.4746,1214.652;Inherit;False;Property;_MainRadius_size;MainRadius_size;5;0;Create;True;0;0;False;0;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;101;-284.8974,2505.939;Inherit;True;Property;_TextureSample1;Texture Sample 1;8;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Instance;53;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;53;-300.5965,2031.294;Inherit;True;Property;_Texture_Dissolve_radius;Texture_Dissolve_radius;8;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;86;-853.1927,1437.371;Inherit;False;Property;_Dissolve_size;Dissolve_size;9;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;49;-656.2764,1120.266;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;11.99823,2363.379;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-501.5804,1419.086;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-574.046,964.1356;Inherit;False;Property;_MainRadius_Sharpness;MainRadius_Sharpness;6;0;Create;True;0;0;False;0;0;0;0;500;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;50.34236,2051.278;Inherit;False;Property;_Dissolve_Sharpness;Dissolve_Sharpness;10;0;Create;True;0;0;False;0;0;0;0;500;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;70;-351.3543,1525.949;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;72;326.9317,2033.37;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;66;-323.56,1120.383;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;84;488.9562,1523.278;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;85;108.2344,1117.308;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;14;303.7791,339.0428;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;629.9006,1114.709;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;112;-1205.116,-101.4576;Inherit;False;1293.076;699.986;Comment;9;11;12;8;6;20;5;10;21;7;Distance Coloring;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;712.6652,440.6685;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;7;-940.4413,345.1104;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;8;-910.4391,148.8085;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;67;900.8105,442.0092;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DistanceOpNode;6;-514.1395,221.6085;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;12;-658.2396,-24.09163;Inherit;False;Property;_Color_Back;Color_Back;1;0;Create;True;0;0;False;0;1,0.8352942,0.6078432,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;10;-334.5397,323.0084;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1000;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;5;-1155.116,-51.45762;Inherit;False;Property;_Color_Front;Color_Front;2;0;Create;True;0;0;False;0;0.5686275,0.3294118,0.5921569,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;20;-569.7402,482.5283;Inherit;False;Property;_color_MaxDist;color_MaxDist;3;0;Create;True;0;0;False;0;900;0;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;96.98682,5.472961;Inherit;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;False;0;0.35;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;11;-94.03983,-42.29164;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.IntNode;21;-564.7401,398.4085;Inherit;False;Property;_color_MinDist;color_MinDist;4;0;Create;True;0;0;False;0;750;0;0;1;INT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;43;314.5999,-41.59999;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;41;314.5999,-41.59999;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;45;314.5999,-41.59999;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;44;314.5999,-41.59999;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;42;1060.99,-37.53252;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;M_Distance & Dissolve Shader;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;0;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;False;True;False;False;;0
WireConnection;95;0;58;0
WireConnection;88;0;46;0
WireConnection;89;0;88;1
WireConnection;89;1;90;0
WireConnection;106;1;104;0
WireConnection;96;0;95;0
WireConnection;96;1;95;1
WireConnection;98;1;99;0
WireConnection;92;0;48;0
WireConnection;105;0;96;0
WireConnection;105;2;106;0
WireConnection;91;0;88;0
WireConnection;91;1;89;0
WireConnection;93;0;92;0
WireConnection;93;1;92;1
WireConnection;97;0;96;0
WireConnection;97;2;98;0
WireConnection;47;0;93;0
WireConnection;47;1;91;0
WireConnection;100;0;97;0
WireConnection;100;1;55;0
WireConnection;107;0;105;0
WireConnection;107;1;108;0
WireConnection;101;1;107;0
WireConnection;53;1;100;0
WireConnection;49;0;47;0
WireConnection;49;1;50;0
WireConnection;109;0;53;0
WireConnection;109;1;101;0
WireConnection;69;0;49;0
WireConnection;69;1;86;0
WireConnection;70;0;69;0
WireConnection;70;1;63;0
WireConnection;72;0;109;0
WireConnection;72;1;61;0
WireConnection;66;0;49;0
WireConnection;66;1;63;0
WireConnection;84;0;70;0
WireConnection;84;1;72;0
WireConnection;85;0;66;0
WireConnection;79;0;85;0
WireConnection;79;1;84;0
WireConnection;51;0;14;4
WireConnection;51;1;79;0
WireConnection;67;0;51;0
WireConnection;6;0;8;3
WireConnection;6;1;7;3
WireConnection;10;0;6;0
WireConnection;10;1;21;0
WireConnection;10;2;20;0
WireConnection;11;0;5;0
WireConnection;11;1;12;0
WireConnection;11;2;10;0
WireConnection;42;2;11;0
WireConnection;42;3;67;0
WireConnection;42;4;34;0
ASEEND*/
//CHKSM=C095113A487A0E586CF2FFE70CDCAA1C0696DA67