// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "M_renderTarget_target"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[SingleLineTexture]_TX_Dissolve1("_TX_Dissolve", 2D) = "white" {}
		[SingleLineTexture]_LVL_00_TX_BackGround1("LVL_00_TX_BackGround", 2D) = "white" {}
		[SingleLineTexture]_LVL_02_TX_fire1("LVL_02_TX_fire", 2D) = "white" {}
		[SingleLineTexture]_LVL_03_TX_Cracks1("LVL_03_TX_Cracks", 2D) = "white" {}
		_LVL_02_power_edge("LVL_02_power_edge", Float) = 0
		_LVL_00_visibility("LVL_00_visibility", Range( 0 , 1)) = 0
		_LVL_00_dissolveFULLEMPTY("LVL_00_dissolve [FULL EMPTY]", Range( -20 , 0)) = -3
		_LVL_00_powerFULLEMPTY("LVL_00_power [FULL EMPTY]", Range( 0 , 50)) = 5
		_LVL_04_color("LVL_04_color", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _LVL_03_TX_Cracks1;
			sampler2D _interactionRT;
			float4 _interactionCameraPos;
			float _environmentInteractionCaptureSize;
			sampler2D _LVL_02_TX_fire1;
			sampler2D _LVL_00_TX_BackGround1;
			sampler2D _TX_Dissolve1;
			CBUFFER_START( UnityPerMaterial )
			float4 _LVL_04_color;
			float4 _LVL_03_TX_Cracks1_ST;
			float _LVL_02_power_edge;
			float4 _TX_Dissolve1_ST;
			float _LVL_00_dissolveFULLEMPTY;
			float _LVL_00_powerFULLEMPTY;
			float _LVL_00_visibility;
			CBUFFER_END


			
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
				float3 temp_output_85_0_g1 = _LVL_04_color.rgb;
				float2 uv_LVL_03_TX_Cracks1 = IN.ase_texcoord3.xy * _LVL_03_TX_Cracks1_ST.xy + _LVL_03_TX_Cracks1_ST.zw;
				float4 TX_Cracks63_g1 = tex2D( _LVL_03_TX_Cracks1, uv_LVL_03_TX_Cracks1 );
				float2 _Vector0 = float2(1,1);
				float2 appendResult1_g39 = (float2(WorldPosition.x , WorldPosition.y));
				float2 appendResult4_g39 = (float2(_interactionCameraPos.x , _interactionCameraPos.y));
				float2 appendResult7_g39 = (float2(_environmentInteractionCaptureSize , _environmentInteractionCaptureSize));
				float RT_G6_g1 = tex2D( _interactionRT, ( _Vector0 * ( ( ( appendResult1_g39 - appendResult4_g39 ) + ( appendResult7_g39 * _Vector0 ) ) / ( _environmentInteractionCaptureSize * 2.0 ) ) ) ).r;
				float LVL_03_CRACKS48_g1 = saturate( pow( ( RT_G6_g1 * ( 1.0 - -14.7 ) ) , 0.5 ) );
				float4 lerpResult72_g1 = lerp( float4( temp_output_85_0_g1 , 0.0 ) , ( float4( temp_output_85_0_g1 , 0.0 ) * TX_Cracks63_g1 ) , LVL_03_CRACKS48_g1);
				float4 color61_g1 = IsGammaSpace() ? float4(1,0.09411765,0,0) : float4(1,0.009134057,0,0);
				float4 _Vector2 = float4(0.1,0.4,0.1,0);
				float2 appendResult4_g62 = (float2(_Vector2.x , _Vector2.y));
				float2 appendResult51_g1 = (float2(WorldPosition.x , WorldPosition.y));
				float2 appendResult12_g62 = (float2(_Vector2.z , _Vector2.z));
				float2 panner6_g62 = ( _TimeParameters.x * appendResult4_g62 + ( appendResult51_g1 * appendResult12_g62 ));
				float4 color75_g1 = IsGammaSpace() ? float4(1,0.6210262,0,0) : float4(1,0.3436423,0,0);
				float LVL_01_FIRE27_g1 = saturate( pow( ( RT_G6_g1 * ( 1.0 - -12.5 ) ) , 3.6 ) );
				float temp_output_79_0_g1 = pow( LVL_01_FIRE27_g1 , _LVL_02_power_edge );
				float4 lerpResult59_g1 = lerp( lerpResult72_g1 , ( 75.0 * ( color61_g1 + ( tex2D( _LVL_02_TX_fire1, panner6_g62 ).r * color75_g1 ) ) ) , temp_output_79_0_g1);
				float2 uv030_g1 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode36_g1 = tex2D( _LVL_00_TX_BackGround1, uv030_g1 );
				float4 lerpResult53_g1 = lerp( lerpResult59_g1 , tex2DNode36_g1 , temp_output_79_0_g1);
				float4 COLOR68_g1 = lerpResult53_g1;
				
				float2 uv_TX_Dissolve1 = IN.ase_texcoord3.xy * _TX_Dissolve1_ST.xy + _TX_Dissolve1_ST.zw;
				float TX_Dissolve_R_Channel15_g1 = tex2D( _TX_Dissolve1, uv_TX_Dissolve1 ).r;
				float LVL_00_EMPTY14_g1 = saturate( pow( ( RT_G6_g1 * ( 1.0 - _LVL_00_dissolveFULLEMPTY ) ) , _LVL_00_powerFULLEMPTY ) );
				float lerpResult39_g1 = lerp( saturate( (1.0 + (( pow( ( TX_Dissolve_R_Channel15_g1 + LVL_00_EMPTY14_g1 ) , 1000.0 ) - TX_Dissolve_R_Channel15_g1 ) - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) , 1.0 , _LVL_00_visibility);
				float ALPHA44_g1 = lerpResult39_g1;
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = COLOR68_g1.rgb;
				float Alpha = ALPHA44_g1;
				float AlphaClipThreshold = ( ( pow( ( TX_Dissolve_R_Channel15_g1 + LVL_01_FIRE27_g1 ) , 1000.0 ) - TX_Dissolve_R_Channel15_g1 ) * pow( (1.0 + (tex2DNode36_g1.a - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) , 1.1 ) );

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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _TX_Dissolve1;
			sampler2D _interactionRT;
			float4 _interactionCameraPos;
			float _environmentInteractionCaptureSize;
			sampler2D _LVL_00_TX_BackGround1;
			CBUFFER_START( UnityPerMaterial )
			float4 _LVL_04_color;
			float4 _LVL_03_TX_Cracks1_ST;
			float _LVL_02_power_edge;
			float4 _TX_Dissolve1_ST;
			float _LVL_00_dissolveFULLEMPTY;
			float _LVL_00_powerFULLEMPTY;
			float _LVL_00_visibility;
			CBUFFER_END


			
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

				float2 uv_TX_Dissolve1 = IN.ase_texcoord2.xy * _TX_Dissolve1_ST.xy + _TX_Dissolve1_ST.zw;
				float TX_Dissolve_R_Channel15_g1 = tex2D( _TX_Dissolve1, uv_TX_Dissolve1 ).r;
				float2 _Vector0 = float2(1,1);
				float2 appendResult1_g39 = (float2(WorldPosition.x , WorldPosition.y));
				float2 appendResult4_g39 = (float2(_interactionCameraPos.x , _interactionCameraPos.y));
				float2 appendResult7_g39 = (float2(_environmentInteractionCaptureSize , _environmentInteractionCaptureSize));
				float RT_G6_g1 = tex2D( _interactionRT, ( _Vector0 * ( ( ( appendResult1_g39 - appendResult4_g39 ) + ( appendResult7_g39 * _Vector0 ) ) / ( _environmentInteractionCaptureSize * 2.0 ) ) ) ).r;
				float LVL_00_EMPTY14_g1 = saturate( pow( ( RT_G6_g1 * ( 1.0 - _LVL_00_dissolveFULLEMPTY ) ) , _LVL_00_powerFULLEMPTY ) );
				float lerpResult39_g1 = lerp( saturate( (1.0 + (( pow( ( TX_Dissolve_R_Channel15_g1 + LVL_00_EMPTY14_g1 ) , 1000.0 ) - TX_Dissolve_R_Channel15_g1 ) - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) ) , 1.0 , _LVL_00_visibility);
				float ALPHA44_g1 = lerpResult39_g1;
				
				float LVL_01_FIRE27_g1 = saturate( pow( ( RT_G6_g1 * ( 1.0 - -12.5 ) ) , 3.6 ) );
				float2 uv030_g1 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode36_g1 = tex2D( _LVL_00_TX_BackGround1, uv030_g1 );
				
				float Alpha = ALPHA44_g1;
				float AlphaClipThreshold = ( ( pow( ( TX_Dissolve_R_Channel15_g1 + LVL_01_FIRE27_g1 ) , 1000.0 ) - TX_Dissolve_R_Channel15_g1 ) * pow( (1.0 + (tex2DNode36_g1.a - 0.0) * (0.0 - 1.0) / (1.0 - 0.0)) , 1.1 ) );

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
-1280;84;1280;659;5983.042;-509.3836;1.3;True;False
Node;AmplifyShaderEditor.CommentaryNode;244;-5228.782,861.0344;Inherit;False;1234.968;384.6663;;3;11;192;10;RT;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;192;-5171.329,1134.701;Inherit;False;MF_RT_InteractiveEnvironmentUVs;-1;;39;1f54e1dca3031bf4184027e8134d7360;0;0;1;FLOAT2;17
Node;AmplifyShaderEditor.TexturePropertyNode;11;-5178.782,911.0344;Float;True;Global;_interactionRT;_interactionRT;0;0;Create;True;0;0;False;0;4f2d2a870ee9daa44bf761e06019ee54;4f2d2a870ee9daa44bf761e06019ee54;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;293;-1583.516,997.6667;Inherit;False;Property;_LVL_02_power_edge;LVL_02_power_edge;12;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;180;-2707.097,975.7454;Inherit;False;Property;_LVL_00_powerFULLEMPTY;LVL_00_power [FULL EMPTY];15;0;Create;True;0;0;False;0;5;25;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;183;-2075.019,950.4009;Inherit;False;Property;_LVL_00_dissolveFULLEMPTY;LVL_00_dissolve [FULL EMPTY];14;0;Create;True;0;0;False;0;-3;-2.35;-20;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;216;-2369.592,916.8537;Inherit;False;Property;_LVL_00_visibility;LVL_00_visibility;13;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;10;-4732.425,911.8165;Inherit;True;Property;_TextureSample3;Texture Sample 3;4;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;7;-1830.107,687.411;Inherit;False;Property;_LVL_04_color;LVL_04_color;16;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;294;-1761.936,460.6234;Inherit;True;Property;_MainTex;_MainTex;11;0;Create;False;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;295;-1247.844,883.2047;Inherit;False;MF_RT_RemapGradient;0;;1;ad9f167183bbcec4e9fe721f379a9749;0;6;85;FLOAT3;0,0,0;False;89;FLOAT;0;False;88;FLOAT;0;False;83;FLOAT;-3;False;84;FLOAT;5;False;86;FLOAT;3;False;3;COLOR;0;FLOAT;80;FLOAT;81
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;True;False;False;False;False;0;False;-1;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-1093.893,-881.761;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;-343.9582,888.5245;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;M_renderTarget_target;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;7;False;False;False;True;0;False;-1;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=TransparentCutout=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;11;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;Meta Pass;0;Extra Pre Pass;0;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;False;True;False;False;;0
WireConnection;10;0;11;0
WireConnection;10;1;192;17
WireConnection;295;85;7;0
WireConnection;295;89;10;0
WireConnection;295;88;216;0
WireConnection;295;83;183;0
WireConnection;295;84;180;0
WireConnection;295;86;293;0
WireConnection;1;2;295;0
WireConnection;1;3;295;80
WireConnection;1;4;295;81
ASEEND*/
//CHKSM=B84C82CA7F0116FB9352BEDD99A762FFD6C18A0C